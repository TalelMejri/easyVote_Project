package com.easyvote.backend.boitenoire;

import com.easyvote.backend.TestFixtures;
import com.easyvote.backend.entity.Election;
import com.easyvote.backend.entity.enums.ElectionStatus;
import com.easyvote.backend.exception.BusinessException;
import com.easyvote.backend.repository.CandidateRepository;
import com.easyvote.backend.repository.ElectionRepository;
import com.easyvote.backend.repository.VoteRepository;
import com.easyvote.backend.service.ElectionService;
import com.easyvote.backend.service.NotificationService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

/**
 * BOÎTE NOIRE — Test de transition d'état.
 * Automate (CDC 3.1.1) : DRAFT → CAMPAIGN_ACTIVE → VOTE_ACTIVE → CLOSED
 * On teste 2 transitions valides et 1 transition interdite (saut d'état).
 */
@DisplayName("BN-TE : Transitions d'état — cycle de vie d'une élection")
class TransitionEtatElectionTest {

    private final ElectionRepository electionRepo = mock(ElectionRepository.class);
    private final ElectionService service = new ElectionService(
            electionRepo, mock(CandidateRepository.class), mock(VoteRepository.class), mock(NotificationService.class));

    private Election electionEnStatut(ElectionStatus statut) {
        Election e = TestFixtures.election(1L, statut);
        when(electionRepo.findById(1L)).thenReturn(Optional.of(e));
        return e;
    }

    @Test
    @DisplayName("ST-20 DRAFT → CAMPAIGN_ACTIVE : transition acceptée")
    void draftVersCampagne() {
        Election e = electionEnStatut(ElectionStatus.DRAFT);
        service.updateElectionStatus(1L, ElectionStatus.CAMPAIGN_ACTIVE);
        assertThat(e.getStatus()).isEqualTo(ElectionStatus.CAMPAIGN_ACTIVE);
    }

    @Test
    @DisplayName("ST-21 CAMPAIGN_ACTIVE → VOTE_ACTIVE : transition acceptée")
    void campagneVersVote() {
        Election e = electionEnStatut(ElectionStatus.CAMPAIGN_ACTIVE);
        service.updateElectionStatus(1L, ElectionStatus.VOTE_ACTIVE);
        assertThat(e.getStatus()).isEqualTo(ElectionStatus.VOTE_ACTIVE);
    }

    @Test
    @DisplayName("ST-23 DRAFT → VOTE_ACTIVE (saut d'état) : transition rejetée")
    void sautDEtatInterdit() {
        Election e = electionEnStatut(ElectionStatus.DRAFT);
        assertThatThrownBy(() -> service.updateElectionStatus(1L, ElectionStatus.VOTE_ACTIVE))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("Transition de statut invalide");
        assertThat(e.getStatus()).isEqualTo(ElectionStatus.DRAFT);
        verify(electionRepo, never()).save(any());
    }
}
