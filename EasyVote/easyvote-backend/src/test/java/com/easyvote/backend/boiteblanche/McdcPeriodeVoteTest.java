package com.easyvote.backend.boiteblanche;

import com.easyvote.backend.TestFixtures;
import com.easyvote.backend.dto.vote.CastVoteRequest;
import com.easyvote.backend.entity.Election;
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

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

/**
 * BOÎTE BLANCHE — MC/DC (Modified Condition / Decision Coverage).
 * Décision dans castVote() :  if (A && B)  avec
 *     A = election.getVoteEnd() != null
 *     B = now.isAfter(election.getVoteEnd())
 * MC/DC pour n = 2 conditions ⇒ n + 1 = 3 tests :
 *
 *   Test | A | B | Décision
 *   T1   | V | V |   V   (vote refusé)
 *   T2   | V | F |   F   → paire (T1,T2) : seul B change ⇒ B influe seul
 *   T3   | F | - |   F   → paire (T1,T3) : seul A change ⇒ A influe seul
 */
@DisplayName("BB-MCDC : MC/DC — fin de la période de vote")
class McdcPeriodeVoteTest {

    private final UserRepository userRepo = mock(UserRepository.class);
    private final ElectionRepository electionRepo = mock(ElectionRepository.class);
    private final CandidateRepository candidateRepo = mock(CandidateRepository.class);
    private final VoteTokenRepository tokenRepo = mock(VoteTokenRepository.class);
    private VoteService voteService;

    @BeforeEach
    void setUp() {
        voteService = new VoteService(mock(VoteRepository.class), tokenRepo, electionRepo, candidateRepo, userRepo,
                new VoteTokenService(tokenRepo, userRepo, electionRepo));
        when(userRepo.findById(1L)).thenReturn(Optional.of(TestFixtures.student(1L, true)));
        when(tokenRepo.findByUserIdAndElectionId(1L, 10L))
                .thenReturn(Optional.of(VoteToken.builder().tokenHash("h").used(false).build()));
    }

    private void electionAvecFinDeVote(LocalDateTime voteEnd) {
        Election e = TestFixtures.election(10L, ElectionStatus.VOTE_ACTIVE);
        e.setVoteEnd(voteEnd);
        when(electionRepo.findById(10L)).thenReturn(Optional.of(e));
        when(candidateRepo.findById(5L)).thenReturn(Optional.of(TestFixtures.candidate(5L, e, CandidateStatus.VALIDATED)));
    }

    @Test
    @DisplayName("T1 A=V, B=V : date de fin dépassée → vote refusé")
    void t1FinDepassee() {
        electionAvecFinDeVote(LocalDateTime.now().minusMinutes(1));
        assertThatThrownBy(() -> voteService.castVote(1L, 10L, new CastVoteRequest(5L)))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("terminée");
    }

    @Test
    @DisplayName("T2 A=V, B=F : date de fin dans le futur → vote accepté")
    void t2FinFuture() {
        electionAvecFinDeVote(LocalDateTime.now().plusHours(1));
        assertThatCode(() -> voteService.castVote(1L, 10L, new CastVoteRequest(5L))).doesNotThrowAnyException();
    }

    @Test
    @DisplayName("T3 A=F : pas de date de fin → vote accepté")
    void t3SansDateDeFin() {
        electionAvecFinDeVote(null);
        assertThatCode(() -> voteService.castVote(1L, 10L, new CastVoteRequest(5L))).doesNotThrowAnyException();
    }
}
