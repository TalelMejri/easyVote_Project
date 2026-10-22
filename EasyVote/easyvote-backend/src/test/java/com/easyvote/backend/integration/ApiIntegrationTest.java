package com.easyvote.backend.integration;

import com.easyvote.backend.entity.Candidate;
import com.easyvote.backend.entity.Election;
import com.easyvote.backend.entity.User;
import com.easyvote.backend.entity.enums.CandidateStatus;
import com.easyvote.backend.entity.enums.ElectionStatus;
import com.easyvote.backend.entity.enums.Role;
import com.easyvote.backend.repository.*;
import com.easyvote.backend.security.JwtUtil;
import com.easyvote.backend.service.MailService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * NIVEAU INTÉGRATION — Controller ↔ Security ↔ Service ↔ Repository ↔ BDD (H2).
 * L'application Spring démarre réellement ; seul l'envoi d'email (Mailtrap) est simulé.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DisplayName("IT : Intégration API + sécurité + base de données")
class ApiIntegrationTest {

    @Autowired MockMvc mvc;
    @Autowired JdbcTemplate jdbc;
    @Autowired JwtUtil jwtUtil;
    @Autowired PasswordEncoder encoder;
    @Autowired UserRepository userRepo;
    @Autowired ElectionRepository electionRepo;
    @Autowired CandidateRepository candidateRepo;
    @Autowired VoteRepository voteRepo;
    @Autowired VoteTokenRepository tokenRepo;
    @Autowired NotificationRepository notificationRepo;
    @Autowired OtpCodeRepository otpRepo;

    @MockBean MailService mailService;

    @BeforeEach
    void viderBase() {
        voteRepo.deleteAll();
        tokenRepo.deleteAll();
        notificationRepo.deleteAll();
        candidateRepo.deleteAll();
        electionRepo.deleteAll();
        otpRepo.deleteAll();
        userRepo.deleteAll();
    }

    private User creerUtilisateur(String email, Role role) {
        return userRepo.save(User.builder().email(email).password(encoder.encode("password123"))
                .fullName(email).role(role).isVerified(true).build());
    }

    @Test
    @DisplayName("IT-01 POST /api/auth/register → compte STUDENT non vérifié, mot de passe haché BCrypt, OTP envoyé")
    void inscription() throws Exception {
        mvc.perform(post("/api/auth/register").contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"email":"nouveau@test.com","password":"Test@1234","fullName":"Nouvel Etudiant"}"""))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.email").value("nouveau@test.com"));

        User enBase = userRepo.findByEmail("nouveau@test.com").orElseThrow();
        assertThat(enBase.isVerified()).isFalse();
        assertThat(enBase.getRole()).isEqualTo(Role.STUDENT);
        assertThat(enBase.getPassword()).isNotEqualTo("Test@1234").startsWith("$2a$");
        org.mockito.Mockito.verify(mailService)
                .sendOtpEmail(org.mockito.ArgumentMatchers.eq("nouveau@test.com"),
                        org.mockito.ArgumentMatchers.anyString(),
                        org.mockito.ArgumentMatchers.matches("\\d{6}"));
    }

    @Test
    @DisplayName("IT-09 endpoint ADMIN : sans jeton → 401 ; avec jeton STUDENT → 403")
    void securiteRbac() throws Exception {
        User etudiant = creerUtilisateur("etudiant@test.com", Role.STUDENT);
        String jwt = jwtUtil.generateAccessToken(etudiant);

        mvc.perform(get("/api/admin/users"))
                .andExpect(status().isUnauthorized());
        mvc.perform(get("/api/admin/users").header("Authorization", "Bearer " + jwt))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("IT-04 POST /api/elections/{id}/vote → vote enregistré SANS user_id (anonymat vérifié en base)")
    void voteAnonymeEnBase() throws Exception {
        User electeur = creerUtilisateur("electeur@test.com", Role.STUDENT);
        User candidatUser = creerUtilisateur("candidat@test.com", Role.CANDIDATE);
        LocalDateTime now = LocalDateTime.now();
        Election election = electionRepo.save(Election.builder().title("BDE 2026")
                .campaignStart(now.minusDays(5)).campaignEnd(now.minusDays(2))
                .voteStart(now.minusDays(1)).voteEnd(now.plusDays(1))
                .status(ElectionStatus.VOTE_ACTIVE).build());
        Candidate candidat = candidateRepo.save(Candidate.builder().user(candidatUser).election(election)
                .slogan("Ensemble").program("Programme").status(CandidateStatus.VALIDATED).build());

        mvc.perform(post("/api/elections/" + election.getId() + "/vote")
                        .header("Authorization", "Bearer " + jwtUtil.generateAccessToken(electeur))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"candidateId\":" + candidat.getId() + "}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.confirmationCode").value(org.hamcrest.Matchers.matchesPattern("[A-Z0-9]{10}")));

        List<String> colonnes = jdbc.queryForList(
                "SELECT LOWER(column_name) FROM information_schema.columns WHERE LOWER(table_name) = 'votes'",
                String.class);
        assertThat(colonnes).contains("token_hash", "candidate_id", "election_id").doesNotContain("user_id");
        assertThat(voteRepo.count()).isEqualTo(1);
        assertThat(tokenRepo.findByUserIdAndElectionId(electeur.getId(), election.getId()).orElseThrow().isUsed())
                .isTrue();

        // CDC 4.4.2 : « Aucune requête SQL ne peut établir de lien entre un utilisateur et son vote ».
        // Pas de colonne user_id ne suffit pas : on tente une JOINTURE via le hash du jeton.
        // Défaut DEF-00 : votes.token_hash == vote_tokens.token_hash, et vote_tokens contient user_id.
        List<String> electeursIdentifies = jdbc.queryForList("""
                SELECT u.email FROM votes v
                JOIN vote_tokens t ON t.token_hash = v.token_hash
                JOIN users u ON u.id = t.user_id""", String.class);
        assertThat(electeursIdentifies)
                .as("la jointure votes ↔ vote_tokens ↔ users ne doit identifier aucun électeur")
                .isEmpty();
    }

    @Test
    @DisplayName("IT-07 GET /api/elections → temps de réponse moyen ≤ 200 ms sur 20 appels successifs")
    void tempsDeReponseListeElections() throws Exception {
        User etudiant = creerUtilisateur("etudiant@test.com", Role.STUDENT);
        String jwt = jwtUtil.generateAccessToken(etudiant);
        LocalDateTime now = LocalDateTime.now();
        for (int i = 1; i <= 5; i++) {
            electionRepo.save(Election.builder().title("Election " + i)
                    .campaignStart(now.minusDays(5)).campaignEnd(now.minusDays(2))
                    .voteStart(now.minusDays(1)).voteEnd(now.plusDays(1))
                    .status(ElectionStatus.VOTE_ACTIVE).build());
        }

        // appel de chauffe (initialisation Hibernate / sérialisation JSON), exclu de la mesure
        mvc.perform(get("/api/elections").header("Authorization", "Bearer " + jwt))
                .andExpect(status().isOk());

        final int appels = 20;
        long totalNanos = 0;
        for (int i = 0; i < appels; i++) {
            long debut = System.nanoTime();
            mvc.perform(get("/api/elections").header("Authorization", "Bearer " + jwt))
                    .andExpect(status().isOk());
            totalNanos += System.nanoTime() - debut;
        }

        double moyenneMs = totalNanos / (double) appels / 1_000_000.0;
        assertThat(moyenneMs)
                .as("temps de réponse moyen de GET /api/elections sur %d appels (ms)", appels)
                .isLessThanOrEqualTo(200.0);
    }
}
