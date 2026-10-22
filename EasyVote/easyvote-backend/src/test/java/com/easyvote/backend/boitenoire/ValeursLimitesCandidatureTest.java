package com.easyvote.backend.boitenoire;

import com.easyvote.backend.dto.candidate.ApplyCandidateRequest;
import com.easyvote.backend.service.PhotoUploadService;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.util.ReflectionTestUtils;

import java.nio.file.Path;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;

/**
 * BOÎTE NOIRE — Analyse des valeurs limites.
 * Règles (CDC 3.1.2) : slogan ≤ 200 caractères, photo ≤ 5 Mo.
 * On teste exactement SUR la limite et JUSTE APRÈS.
 */
@DisplayName("BN-VL : Valeurs limites — candidature")
class ValeursLimitesCandidatureTest {

    private static Validator validator;

    @TempDir
    Path dossierUpload;

    @BeforeAll
    static void initValidator() {
        validator = Validation.buildDefaultValidatorFactory().getValidator();
    }

    private ApplyCandidateRequest candidatureAvecSlogan(int longueur) {
        return ApplyCandidateRequest.builder()
                .electionId(1L)
                .slogan("a".repeat(longueur))
                .program("Mon programme")
                .build();
    }

    @Test
    @DisplayName("VL-01 slogan = 200 caractères (limite) → accepté")
    void sloganExactementALaLimite() {
        assertThat(validator.validate(candidatureAvecSlogan(200))).isEmpty();
    }

    @Test
    @DisplayName("VL-02 slogan = 201 caractères (limite + 1) → rejeté")
    void sloganJusteAuDessusDeLaLimite() {
        assertThat(validator.validate(candidatureAvecSlogan(201))).isNotEmpty();
    }

    @Test
    @DisplayName("VL-03 photo = exactement 5 Mo (5 × 1024 × 1024 octets) → acceptée")
    void photoExactementCinqMo() {
        PhotoUploadService service = new PhotoUploadService();
        ReflectionTestUtils.setField(service, "uploadDir", dossierUpload.toString());
        ReflectionTestUtils.setField(service, "baseUrl", "/uploads");

        byte[] cinqMo = new byte[5 * 1024 * 1024];
        MockMultipartFile photo = new MockMultipartFile("file", "photo.jpg", "image/jpeg", cinqMo);

        // Attendu par le CDC : acceptée. Le code compare à 5 000 000 octets → défaut DEF-01.
        assertThatCode(() -> service.savePhoto(photo)).doesNotThrowAnyException();
    }
}
