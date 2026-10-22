package com.easyvote.backend.boiteblanche;

import com.easyvote.backend.TestFixtures;
import com.easyvote.backend.entity.VoteToken;
import com.easyvote.backend.entity.enums.ElectionStatus;
import com.easyvote.backend.exception.ResourceNotFoundException;
import com.easyvote.backend.repository.ElectionRepository;
import com.easyvote.backend.repository.UserRepository;
import com.easyvote.backend.repository.VoteTokenRepository;
import com.easyvote.backend.service.VoteTokenService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * BOÎTE BLANCHE — Couverture des branches.
 * Cible : VoteTokenService.generateTokensForElection(), qui a 3 branches :
 *   B1  election introuvable            → exception
 *   B2  jetons déjà générés             → return (idempotence)
 *   B3  sinon : boucle sur les électeurs → 1 jeton haché par électeur
 * 3 tests = 100 % des branches.
 */
@DisplayName("BB-BR : Couverture des branches — génération des jetons")
class CouvertureBranchesTokensTest {

    private final VoteTokenRepository tokenRepo = mock(VoteTokenRepository.class);
    private final UserRepository userRepo = mock(UserRepository.class);
    private final ElectionRepository electionRepo = mock(ElectionRepository.class);
    private final VoteTokenService service = new VoteTokenService(tokenRepo, userRepo, electionRepo);

    @Test
    @DisplayName("B1 élection inexistante → ResourceNotFoundException")
    void brancheElectionIntrouvable() {
        when(electionRepo.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.generateTokensForElection(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("B2 jetons déjà générés → aucun nouveau jeton (idempotence, IT-03)")
    void brancheIdempotence() {
        when(electionRepo.findById(1L)).thenReturn(Optional.of(TestFixtures.election(1L, ElectionStatus.CAMPAIGN_ACTIVE)));
        when(tokenRepo.existsByElectionId(1L)).thenReturn(true);

        service.generateTokensForElection(1L);

        verify(tokenRepo, never()).save(any());
    }

    @Test
    @DisplayName("B3 3 électeurs vérifiés → 3 jetons, seul le hash SHA-256 est stocké")
    void brancheGeneration() {
        when(electionRepo.findById(1L)).thenReturn(Optional.of(TestFixtures.election(1L, ElectionStatus.CAMPAIGN_ACTIVE)));
        when(tokenRepo.existsByElectionId(1L)).thenReturn(false);
        when(userRepo.findByIsVerifiedTrue()).thenReturn(List.of(
                TestFixtures.student(1L, true), TestFixtures.student(2L, true), TestFixtures.student(3L, true)));

        service.generateTokensForElection(1L);

        ArgumentCaptor<VoteToken> captor = ArgumentCaptor.forClass(VoteToken.class);
        verify(tokenRepo, times(3)).save(captor.capture());
        assertThat(captor.getAllValues())
                .extracting(VoteToken::getTokenHash)
                .allMatch(h -> h.matches("[0-9a-f]{64}"))
                .doesNotHaveDuplicates();
    }
}
