package com.easyvote.backend.boitenoire;

import com.easyvote.backend.TestFixtures;
import com.easyvote.backend.dto.vote.CastVoteRequest;
import com.easyvote.backend.dto.vote.VoteResponse;
import com.easyvote.backend.entity.Candidate;
import com.easyvote.backend.entity.Election;
import com.easyvote.backend.entity.Vote;
import com.easyvote.backend.entity.VoteToken;
import com.easyvote.backend.entity.enums.CandidateStatus;
import com.easyvote.backend.entity.enums.ElectionStatus;
import com.easyvote.backend.exception.BusinessException;
import com.easyvote.backend.repository.*;
import com.easyvote.backend.service.VoteService;
import com.easyvote.backend.service.VoteTokenService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * BOÎTE NOIRE — Table de décision du vote.
 *
 *  Règle | C1 VOTE_ACTIVE | C2 pas déjà voté | Action
 *  R1    |       V        |        V         | A1 vote enregistré + code
 *  R2    |       F        |        -         | A2 erreur "vote non ouvert"
 *  R3    |       V        |        F         | A3 erreur "déjà voté"
 */
@DisplayName("BN-TD : Table de décision — vote d'un étudiant")
class TableDecisionVoteTest {

    private final UserRepository userRepo = mock(UserRepository.class);
    private final ElectionRepository electionRepo = mock(ElectionRepository.class);
    private final CandidateRepository candidateRepo = mock(CandidateRepository.class);
    private final VoteRepository voteRepo = mock(VoteRepository.class);
    private final VoteTokenRepository tokenRepo = mock(VoteTokenRepository.class);
    private VoteService voteService;

    @BeforeEach
    void setUp() {
        VoteTokenService tokenService = new VoteTokenService(tokenRepo, userRepo, electionRepo);
        voteService = new VoteService(voteRepo, tokenRepo, electionRepo, candidateRepo, userRepo, tokenService);
        when(userRepo.findById(1L)).thenReturn(Optional.of(TestFixtures.student(1L, true)));
        when(tokenRepo.save(any())).thenAnswer(inv -> inv.getArgument(0));
    }

    private void preparer(ElectionStatus statut, boolean dejaVote) {
        Election election = TestFixtures.election(10L, statut);
        Candidate candidat = TestFixtures.candidate(5L, election, CandidateStatus.VALIDATED);
        when(electionRepo.findById(10L)).thenReturn(Optional.of(election));
        when(candidateRepo.findById(5L)).thenReturn(Optional.of(candidat));
        VoteToken jeton = VoteToken.builder().tokenHash("hash-jeton").used(dejaVote).build();
        when(tokenRepo.findByUserIdAndElectionId(1L, 10L)).thenReturn(Optional.of(jeton));
    }

    @Test
    @DisplayName("R1 (V,V) → vote enregistré + code de confirmation de 10 caractères")
    void r1VoteAutorise() {
        preparer(ElectionStatus.VOTE_ACTIVE, false);

        VoteResponse reponse = voteService.castVote(1L, 10L, new CastVoteRequest(5L));

        assertThat(reponse.getConfirmationCode()).hasSize(10).matches("[A-Z0-9]{10}");
        verify(voteRepo).save(any(Vote.class));
    }

    @Test
    @DisplayName("R2 (F,-) → élection non active : vote refusé")
    void r2ElectionNonActive() {
        preparer(ElectionStatus.CAMPAIGN_ACTIVE, false);

        assertThatThrownBy(() -> voteService.castVote(1L, 10L, new CastVoteRequest(5L)))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("pas ouvert");
        verify(voteRepo, never()).save(any());
    }

    @Test
    @DisplayName("R3 (V,F) → étudiant ayant déjà voté : vote refusé")
    void r3DejaVote() {
        preparer(ElectionStatus.VOTE_ACTIVE, true);

        assertThatThrownBy(() -> voteService.castVote(1L, 10L, new CastVoteRequest(5L)))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("déjà voté");
        verify(voteRepo, never()).save(any());
    }
}
