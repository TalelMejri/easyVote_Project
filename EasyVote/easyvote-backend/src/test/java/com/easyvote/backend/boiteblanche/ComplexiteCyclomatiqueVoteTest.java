package com.easyvote.backend.boiteblanche;

import com.easyvote.backend.TestFixtures;
import com.easyvote.backend.dto.vote.CastVoteRequest;
import com.easyvote.backend.entity.Candidate;
import com.easyvote.backend.entity.Election;
import com.easyvote.backend.entity.User;
import com.easyvote.backend.entity.Vote;
import com.easyvote.backend.entity.enums.CandidateStatus;
import com.easyvote.backend.entity.enums.ElectionStatus;
import com.easyvote.backend.exception.BusinessException;
import com.easyvote.backend.exception.ForbiddenException;
import com.easyvote.backend.repository.*;
import com.easyvote.backend.service.VoteService;
import com.easyvote.backend.service.VoteTokenService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * BOÎTE BLANCHE — Complexité cyclomatique et chemins indépendants.
 * Cible : VoteService.castVote().
 * Points de décision : user absent, !verified, election absente, candidat absent,
 * mauvaise élection, candidat non validé, statut ≠ VOTE_ACTIVE, voteEnd≠null && dépassé (2),
 * jeton absent, jeton utilisé  → 11 décisions ⇒ V(G) = 11 + 1 = 12.
 * Les 3 tests ci-dessous couvrent 3 chemins indépendants NON couverts par la table
 * de décision (BN-TD) ; les autres chemins sont couverts par BN-TD et BB-MCDC.
 */
@DisplayName("BB-CC : Complexité cyclomatique — chemins de castVote()")
class ComplexiteCyclomatiqueVoteTest {

    private final UserRepository userRepo = mock(UserRepository.class);
    private final ElectionRepository electionRepo = mock(ElectionRepository.class);
    private final CandidateRepository candidateRepo = mock(CandidateRepository.class);
    private final VoteRepository voteRepo = mock(VoteRepository.class);
    private final VoteTokenRepository tokenRepo = mock(VoteTokenRepository.class);
    private VoteService voteService;
    private Election election;

    @BeforeEach
    void setUp() {
        voteService = new VoteService(voteRepo, tokenRepo, electionRepo, candidateRepo, userRepo,
                new VoteTokenService(tokenRepo, userRepo, electionRepo));
        election = TestFixtures.election(10L, ElectionStatus.VOTE_ACTIVE);
        when(electionRepo.findById(10L)).thenReturn(Optional.of(election));
        when(tokenRepo.save(any())).thenAnswer(inv -> inv.getArgument(0));
    }

    @Test
    @DisplayName("Chemin 1 : utilisateur non vérifié → ForbiddenException (sortie à la décision 2)")
    void cheminCompteNonVerifie() {
        when(userRepo.findById(1L)).thenReturn(Optional.of(TestFixtures.student(1L, false)));

        assertThatThrownBy(() -> voteService.castVote(1L, 10L, new CastVoteRequest(5L)))
                .isInstanceOf(ForbiddenException.class);
    }

    @Test
    @DisplayName("Chemin 2 : candidat d'une autre élection → BusinessException (décision 5)")
    void cheminCandidatAutreElection() {
        when(userRepo.findById(1L)).thenReturn(Optional.of(TestFixtures.student(1L, true)));
        Candidate intrus = TestFixtures.candidate(5L, TestFixtures.election(77L, ElectionStatus.VOTE_ACTIVE),
                CandidateStatus.VALIDATED);
        when(candidateRepo.findById(5L)).thenReturn(Optional.of(intrus));

        assertThatThrownBy(() -> voteService.castVote(1L, 10L, new CastVoteRequest(5L)))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("ne participe pas");
    }

    @Test
    @DisplayName("Chemin 3 : aucun jeton pré-généré → jeton créé à la volée, vote ANONYME enregistré")
    void cheminJetonGenereALaVolee() {
        when(userRepo.findById(1L)).thenReturn(Optional.of(TestFixtures.student(1L, true)));
        when(candidateRepo.findById(5L)).thenReturn(
                Optional.of(TestFixtures.candidate(5L, election, CandidateStatus.VALIDATED)));
        when(tokenRepo.findByUserIdAndElectionId(1L, 10L)).thenReturn(Optional.empty());

        voteService.castVote(1L, 10L, new CastVoteRequest(5L));

        ArgumentCaptor<Vote> vote = ArgumentCaptor.forClass(Vote.class);
        verify(voteRepo).save(vote.capture());
        assertThat(vote.getValue().getTokenHash()).matches("[0-9a-f]{64}");
        // Anonymat : l'entité Vote ne possède AUCUN champ de type User
        assertThat(Arrays.stream(Vote.class.getDeclaredFields()).map(Field::getType).toList())
                .noneMatch(type -> type == User.class);
    }
}
