package com.easyvote.backend.boiteblanche;

import com.easyvote.backend.dto.election.CreateElectionRequest;
import com.easyvote.backend.dto.election.ElectionResponse;
import com.easyvote.backend.entity.enums.ElectionStatus;
import com.easyvote.backend.exception.BusinessException;
import com.easyvote.backend.repository.CandidateRepository;
import com.easyvote.backend.repository.ElectionRepository;
import com.easyvote.backend.repository.VoteRepository;
import com.easyvote.backend.service.ElectionService;
import com.easyvote.backend.service.NotificationService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * BOÎTE BLANCHE — Couverture des décisions / conditions.
 * Cible : ElectionService.validateDates() (appelée par createElection) :
 *   D1 if (!campaignStart.isBefore(campaignEnd)) → exception
 *   D2 if (campaignEnd.isAfter(voteStart))        → exception
 *   D3 if (!voteStart.isBefore(voteEnd))          → exception
 * Test 1 : D1=F, D2=F, D3=F (chemin nominal)  | Test 2 : D1=V | Test 3 : D3=V
 */
@DisplayName("BB-DC : Couverture des décisions — validation des dates d'élection")
class CouvertureDecisionsConditionsTest {

    private final ElectionRepository electionRepo = mock(ElectionRepository.class);
    private final ElectionService service = new ElectionService(
            electionRepo, mock(CandidateRepository.class), mock(VoteRepository.class), mock(NotificationService.class));

    private static final LocalDateTime J = LocalDateTime.now().plusDays(1);

    private CreateElectionRequest requete(LocalDateTime cs, LocalDateTime ce, LocalDateTime vs, LocalDateTime ve) {
        return CreateElectionRequest.builder()
                .title("Élection test").campaignStart(cs).campaignEnd(ce).voteStart(vs).voteEnd(ve).build();
    }

    @Test
    @DisplayName("DC-01 dates cohérentes → toutes les décisions FAUSSES → élection créée en DRAFT")
    void datesValides() {
        when(electionRepo.save(any())).thenAnswer(inv -> inv.getArgument(0));

        ElectionResponse r = service.createElection(requete(J, J.plusDays(2), J.plusDays(3), J.plusDays(4)));

        assertThat(r.getStatus()).isEqualTo(ElectionStatus.DRAFT);
    }

    @Test
    @DisplayName("DC-02 début campagne = fin campagne → D1 VRAIE → rejet")
    void campagneDeDureeNulle() {
        assertThatThrownBy(() -> service.createElection(requete(J, J, J.plusDays(3), J.plusDays(4))))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("début de campagne");
        verify(electionRepo, never()).save(any());
    }

    @Test
    @DisplayName("DC-03 fin du vote avant le début du vote → D3 VRAIE → rejet")
    void voteInverse() {
        assertThatThrownBy(() -> service.createElection(requete(J, J.plusDays(2), J.plusDays(4), J.plusDays(3))))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("début de vote");
        verify(electionRepo, never()).save(any());
    }
}
