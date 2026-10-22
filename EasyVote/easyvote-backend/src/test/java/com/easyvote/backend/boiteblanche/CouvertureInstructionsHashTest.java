package com.easyvote.backend.boiteblanche;

import com.easyvote.backend.repository.ElectionRepository;
import com.easyvote.backend.repository.UserRepository;
import com.easyvote.backend.repository.VoteTokenRepository;
import com.easyvote.backend.service.VoteTokenService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

/**
 * BOÎTE BLANCHE — Couverture des instructions.
 * Cible : VoteTokenService.hashToken() et generateRawToken().
 * Ces 3 tests exécutent toutes les instructions atteignables des deux méthodes
 * (le bloc catch NoSuchAlgorithmException est inatteignable : SHA-256 est
 * toujours présent dans la JVM — à signaler dans le rapport de couverture).
 */
@DisplayName("BB-INS : Couverture des instructions — hachage des jetons")
class CouvertureInstructionsHashTest {

    private final VoteTokenService service = new VoteTokenService(
            mock(VoteTokenRepository.class), mock(UserRepository.class), mock(ElectionRepository.class));

    @Test
    @DisplayName("UT-01a SHA-256('abc') = vecteur de test officiel NIST")
    void vecteurNist() {
        assertThat(service.hashToken("abc"))
                .isEqualTo("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
    }

    @Test
    @DisplayName("UT-01b hash = 64 caractères hexadécimaux, déterministe, différent du jeton brut")
    void formatEtDeterminisme() {
        String brut = service.generateRawToken();
        String h1 = service.hashToken(brut);
        String h2 = service.hashToken(brut);

        assertThat(h1).matches("[0-9a-f]{64}").isEqualTo(h2).isNotEqualTo(brut);
    }

    @Test
    @DisplayName("UT-01c deux jetons bruts générés sont différents (aléa cryptographique)")
    void jetonsBrutsUniques() {
        assertThat(service.generateRawToken()).isNotEqualTo(service.generateRawToken());
    }
}
