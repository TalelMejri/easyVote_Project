package com.easyvote.backend.acceptation;

import com.easyvote.backend.entity.Candidate;
import com.easyvote.backend.entity.Election;
import com.easyvote.backend.entity.User;
import com.easyvote.backend.entity.enums.CandidateStatus;
import com.easyvote.backend.entity.enums.ElectionStatus;
import com.easyvote.backend.entity.enums.Role;
import com.easyvote.backend.repository.*;
import com.easyvote.backend.service.MailService;
import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * NIVEAU ACCEPTATION (recette) — scénarios métier vus par l'utilisateur final.
 * Un cas automatisable par type : fonctionnel, non-fonctionnel, structurel, régression.
 * Les critères humains (questionnaire, ergonomie) du plan UAT restent à valider manuellement.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DisplayName("UAT : Recette — scénarios métier")
class AcceptationTest {

    private static final String MOT_DE_PASSE = "password123";
    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    @Autowired MockMvc mvc;
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
        return userRepo.save(User.builder().email(email).password(encoder.encode(MOT_DE_PASSE))
                .fullName(email).role(role).isVerified(true).build());
    }

    /** Connexion réelle par l'API, comme le ferait l'utilisateur depuis l'écran de login. */
    private String seConnecter(String email) throws Exception {
        String corps = mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"" + email + "\",\"password\":\"" + MOT_DE_PASSE + "\"}"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(corps, "$.data.accessToken");
    }

    private Election electionEnVote() {
        LocalDateTime now = LocalDateTime.now();
        return electionRepo.save(Election.builder().title("BDE 2026")
                .campaignStart(now.minusDays(5)).campaignEnd(now.minusDays(2))
                .voteStart(now.minusDays(1)).voteEnd(now.plusDays(1))
                .status(ElectionStatus.VOTE_ACTIVE).build());
    }

    private Candidate candidatValide(Election election) {
        User u = creerUtilisateur("candidat@test.com", Role.CANDIDATE);
        return candidateRepo.save(Candidate.builder().user(u).election(election)
                .slogan("Ensemble").program("Programme").status(CandidateStatus.VALIDATED).build());
    }

    @Test
    @DisplayName("UAT-01 (fonctionnel) étudiant : connexion → consultation des élections → vote, sans blocage")
    void parcoursEtudiant() throws Exception {
        creerUtilisateur("etudiant@test.com", Role.STUDENT);
        Election election = electionEnVote();
        Candidate candidat = candidatValide(election);

        String jwt = seConnecter("etudiant@test.com");

        mvc.perform(get("/api/elections").header("Authorization", "Bearer " + jwt))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].title").value("BDE 2026"));

        mvc.perform(post("/api/elections/" + election.getId() + "/vote")
                        .header("Authorization", "Bearer " + jwt)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"candidateId\":" + candidat.getId() + "}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.confirmationCode").isNotEmpty());
    }

    @Test
    @DisplayName("UAT-06 (non-fonctionnel) le PDF officiel des résultats est un vrai document exploitable")
    void pdfOfficielExploitable() throws Exception {
        creerUtilisateur("etudiant@test.com", Role.STUDENT);
        Election election = electionEnVote();
        Candidate candidat = candidatValide(election);
        String jwt = seConnecter("etudiant@test.com");

        mvc.perform(post("/api/elections/" + election.getId() + "/vote")
                        .header("Authorization", "Bearer " + jwt)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"candidateId\":" + candidat.getId() + "}"))
                .andExpect(status().isCreated());
        election.setStatus(ElectionStatus.CLOSED);
        electionRepo.save(election);

        byte[] pdf = mvc.perform(get("/api/elections/" + election.getId() + "/results/pdf")
                        .header("Authorization", "Bearer " + jwt))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsByteArray();

        assertThat(new String(pdf, 0, 4, java.nio.charset.StandardCharsets.ISO_8859_1)).isEqualTo("%PDF");
        assertThat(pdf.length).as("taille du PDF (octets)").isGreaterThan(1000);
    }

    @Test
    @DisplayName("UAT-07 (structurel) test croisé des 3 rôles : chacun accède à ses fonctions, seul l'ADMIN à l'administration")
    void rolesEtDroitsConformes() throws Exception {
        creerUtilisateur("etudiant@test.com", Role.STUDENT);
        creerUtilisateur("candidat@test.com", Role.CANDIDATE);
        creerUtilisateur("admin@test.com", Role.ADMIN);

        for (String email : new String[]{"etudiant@test.com", "candidat@test.com", "admin@test.com"}) {
            String jwt = seConnecter(email);
            mvc.perform(get("/api/auth/me").header("Authorization", "Bearer " + jwt))
                    .andExpect(status().isOk());
            mvc.perform(get("/api/elections").header("Authorization", "Bearer " + jwt))
                    .andExpect(status().isOk());
        }

        mvc.perform(get("/api/admin/users").header("Authorization", "Bearer " + seConnecter("admin@test.com")))
                .andExpect(status().isOk());
        mvc.perform(get("/api/admin/users").header("Authorization", "Bearer " + seConnecter("etudiant@test.com")))
                .andExpect(status().isForbidden());
        mvc.perform(get("/api/admin/users").header("Authorization", "Bearer " + seConnecter("candidat@test.com")))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("UAT-M03 (régression) droits inchangés après mise à jour : seul l'ADMIN crée/pilote une élection, anonyme refusé")
    void droitsInchangesApresMiseAJour() throws Exception {
        creerUtilisateur("etudiant@test.com", Role.STUDENT);
        creerUtilisateur("admin@test.com", Role.ADMIN);
        LocalDateTime now = LocalDateTime.now();
        String election = "{\"title\":\"Nouvelle élection\",\"description\":\"recette\","
                + "\"campaignStart\":\"" + now.plusDays(1).format(DATE) + "\","
                + "\"campaignEnd\":\"" + now.plusDays(2).format(DATE) + "\","
                + "\"voteStart\":\"" + now.plusDays(2).format(DATE) + "\","
                + "\"voteEnd\":\"" + now.plusDays(3).format(DATE) + "\"}";

        // anonyme : refusé
        mvc.perform(post("/api/elections").contentType(MediaType.APPLICATION_JSON).content(election))
                .andExpect(status().isUnauthorized());
        // étudiant : refusé
        mvc.perform(post("/api/elections").contentType(MediaType.APPLICATION_JSON).content(election)
                        .header("Authorization", "Bearer " + seConnecter("etudiant@test.com")))
                .andExpect(status().isForbidden());
        // admin : autorisé, puis seul lui peut changer le statut
        String jwtAdmin = seConnecter("admin@test.com");
        String corps = mvc.perform(post("/api/elections").contentType(MediaType.APPLICATION_JSON).content(election)
                        .header("Authorization", "Bearer " + jwtAdmin))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        int id = JsonPath.read(corps, "$.data.id");

        mvc.perform(patch("/api/elections/" + id + "/status").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"CAMPAIGN_ACTIVE\"}")
                        .header("Authorization", "Bearer " + seConnecter("etudiant@test.com")))
                .andExpect(status().isForbidden());
        mvc.perform(patch("/api/elections/" + id + "/status").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"CAMPAIGN_ACTIVE\"}")
                        .header("Authorization", "Bearer " + jwtAdmin))
                .andExpect(status().isOk());
    }
}
