package com.easyvote.backend;

import com.easyvote.backend.entity.Candidate;
import com.easyvote.backend.entity.Election;
import com.easyvote.backend.entity.User;
import com.easyvote.backend.entity.enums.CandidateStatus;
import com.easyvote.backend.entity.enums.ElectionStatus;
import com.easyvote.backend.entity.enums.Role;

import java.time.LocalDateTime;

/**
 * Jeux de données réutilisés par les tests unitaires (objets en mémoire, pas de BDD).
 */
public final class TestFixtures {

    private TestFixtures() {
    }

    public static User student(Long id, boolean verified) {
        return User.builder()
                .id(id)
                .email("etudiant" + id + "@test.com")
                .password("hash")
                .fullName("Etudiant " + id)
                .role(Role.STUDENT)
                .isVerified(verified)
                .build();
    }

    /** Élection dont la période de vote est en cours (fin dans 2 jours). */
    public static Election election(Long id, ElectionStatus status) {
        LocalDateTime now = LocalDateTime.now();
        return Election.builder()
                .id(id)
                .title("Élection BDE " + id)
                .campaignStart(now.minusDays(10))
                .campaignEnd(now.minusDays(5))
                .voteStart(now.minusDays(1))
                .voteEnd(now.plusDays(2))
                .status(status)
                .build();
    }

    public static Candidate candidate(Long id, Election election, CandidateStatus status) {
        return Candidate.builder()
                .id(id)
                .user(student(100 + id, true))
                .election(election)
                .slogan("Slogan " + id)
                .program("Programme " + id)
                .status(status)
                .build();
    }
}
