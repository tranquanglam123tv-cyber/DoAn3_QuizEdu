package com.example.quizedu.dto.ai;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;

import java.util.List;

@Data
public class FlashcardResult {
    private List<FlashcardItem> flashcards;

    @Data
    public static class FlashcardItem {
        private String question;
        private JsonNode answer;
    }
}
