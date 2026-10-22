package com.easyvote.backend.unitaire;

import com.easyvote.backend.repository.CandidateRepository;
import com.easyvote.backend.repository.ElectionRepository;
import com.easyvote.backend.repository.VoteRepository;
import com.easyvote.backend.service.ChatbotRulesService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

/**
 * NIVEAU UNITAIRE — Chatbot EasyBot, couche 1 (règles).
 * Mélange volontaire de types : 1 fonctionnel nominal, 1 NON-fonctionnel (performance),
 * 1 fonctionnel issu d'une question suggérée par le chatbot lui-même.
 */
@DisplayName("UT-CB : Chatbot — couche règles")
class ChatbotRulesTest {

    private final ChatbotRulesService chatbot = new ChatbotRulesService(
            mock(ElectionRepository.class), mock(CandidateRepository.class), mock(VoteRepository.class));

    @Test
    @DisplayName("UT-01 (fonctionnel) « Bonjour » → message de bienvenue")
    void salutation() {
        assertThat(chatbot.tryMatchRule("Bonjour", 1L)).get().asString().contains("assistant EasyVote");
    }

    @Test
    @DisplayName("UT-06 (non-fonctionnel) réponse de la couche règles < 50 ms (CDC 5.1)")
    void performanceMoinsDe50ms() {
        chatbot.tryMatchRule("échauffement JVM", 1L);
        long debut = System.nanoTime();
        chatbot.tryMatchRule("Comment voter ?", 1L);
        long dureeMs = (System.nanoTime() - debut) / 1_000_000;

        assertThat(dureeMs).isLessThan(50);
    }
}
