package com.easyvote.backend.unitaire;

import com.easyvote.backend.dto.vote.CandidateVoteResult;
import com.easyvote.backend.dto.vote.ElectionResultsResponse;
import com.easyvote.backend.entity.Candidate;
import com.easyvote.backend.entity.Election;
import com.easyvote.backend.entity.User;
import com.easyvote.backend.entity.enums.CandidateStatus;
import com.easyvote.backend.entity.enums.ElectionStatus;
import com.easyvote.backend.repository.CandidateRepository;
import com.easyvote.backend.repository.ElectionRepository;
import com.easyvote.backend.repository.UserRepository;
import com.easyvote.backend.repository.VoteRepository;
import com.easyvote.backend.service.VoteAnalyticsService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * NIVEAU UNITAIRE — Non-régression du calcul des résultats (VoteAnalyticsService.getResults).
 * Jeu de votes de référence : 10 votes exprimés (5 / 3 / 2) sur 20 électeurs vérifiés.
 * Les valeurs attendues sont figées : tout refactoring doit produire exactement le même résultat.
 */
@DisplayName("UT-M : Non-régression — calcul des résultats")
class RegressionResultatsTest {

    private static final Long ELECTION_ID = 1L;

    @Test
    @DisplayName("UT-M01 (régression) jeu de votes de référence → classement, pourcentages et participation inchangés")
    void calculDesResultatsInchange() {
        ElectionRepository electionRepo = mock(ElectionRepository.class);
        CandidateRepository candidateRepo = mock(CandidateRepository.class);
        VoteRepository voteRepo = mock(VoteRepository.class);
        UserRepository userRepo = mock(UserRepository.class);

        Election election = Election.builder().id(ELECTION_ID).title("BDE 2026")
                .status(ElectionStatus.CLOSED).build();
        // volontairement dans le désordre pour vérifier le tri par nombre de votes
        Candidate sami = candidat(11L, "Sami", "Pour tous");
        Candidate amel = candidat(12L, "Amel", "Ensemble");
        Candidate walid = candidat(13L, "Walid", "Avancer");

        when(electionRepo.findById(ELECTION_ID)).thenReturn(Optional.of(election));
        when(candidateRepo.findByElectionIdAndStatus(ELECTION_ID, CandidateStatus.VALIDATED))
                .thenReturn(List.of(sami, amel, walid));
        when(voteRepo.countByElectionId(ELECTION_ID)).thenReturn(10L);
        when(voteRepo.countByElectionIdAndCandidateId(ELECTION_ID, 11L)).thenReturn(2L);
        when(voteRepo.countByElectionIdAndCandidateId(ELECTION_ID, 12L)).thenReturn(5L);
        when(voteRepo.countByElectionIdAndCandidateId(ELECTION_ID, 13L)).thenReturn(3L);
        when(userRepo.countByIsVerifiedTrue()).thenReturn(20L);

        ElectionResultsResponse r = new VoteAnalyticsService(voteRepo, electionRepo, candidateRepo, userRepo)
                .getResults(ELECTION_ID);

        assertThat(r.getTotalVotes()).isEqualTo(10);
        assertThat(r.getTotalEligibleVoters()).isEqualTo(20);
        assertThat(r.getParticipationRate()).isCloseTo(50.0, within(0.001));
        assertThat(r.isFinal()).isTrue();

        assertThat(r.getResults()).extracting(CandidateVoteResult::getFullName)
                .containsExactly("Amel", "Walid", "Sami");
        assertThat(r.getResults()).extracting(CandidateVoteResult::getVotes)
                .containsExactly(5L, 3L, 2L);
        assertThat(r.getResults()).extracting(CandidateVoteResult::getRank)
                .containsExactly(1, 2, 3);
        assertThat(r.getResults().get(0).getPercentage()).isCloseTo(50.0, within(0.001));
        assertThat(r.getResults().get(1).getPercentage()).isCloseTo(30.0, within(0.001));
        assertThat(r.getResults().get(2).getPercentage()).isCloseTo(20.0, within(0.001));
    }

    private static Candidate candidat(Long id, String nom, String slogan) {
        User user = User.builder().email(nom.toLowerCase() + "@test.com").fullName(nom).build();
        return Candidate.builder().id(id).user(user).slogan(slogan).status(CandidateStatus.VALIDATED).build();
    }
}
