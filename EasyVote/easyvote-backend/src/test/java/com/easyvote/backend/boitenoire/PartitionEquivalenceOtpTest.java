package com.easyvote.backend.boitenoire;

import com.easyvote.backend.dto.auth.OtpVerifyRequest;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * BOÎTE NOIRE — Partition d'équivalence.
 * Règle (CDC 4.4.1) : le code OTP contient exactement 6 chiffres.
 * Classes : [valide : 6 chiffres] [invalide : longueur ≠ 6] [invalide : non numérique]
 * On prend UN représentant par classe.
 */
@DisplayName("BN-PE : Partition d'équivalence — code OTP")
class PartitionEquivalenceOtpTest {

    private static Validator validator;

    @BeforeAll
    static void initValidator() {
        validator = Validation.buildDefaultValidatorFactory().getValidator();
    }

    private Set<ConstraintViolation<OtpVerifyRequest>> valider(String code) {
        return validator.validate(new OtpVerifyRequest("etudiant@test.com", code));
    }

    @Test
    @DisplayName("PE-01 classe valide : '123456' est accepté")
    void codeValideSixChiffres() {
        assertThat(valider("123456")).isEmpty();
    }

    @Test
    @DisplayName("PE-02 classe invalide (longueur) : '12345' est rejeté")
    void codeTropCourt() {
        assertThat(valider("12345")).isNotEmpty();
    }

    @Test
    @DisplayName("PE-03 classe invalide (non numérique) : '12AB56' est rejeté")
    void codeNonNumerique() {
        assertThat(valider("12AB56"))
                .extracting(ConstraintViolation::getMessage)
                .contains("Le code OTP doit contenir uniquement des chiffres");
    }
}
