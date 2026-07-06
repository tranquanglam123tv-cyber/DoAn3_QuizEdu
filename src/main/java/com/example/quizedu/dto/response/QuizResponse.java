package com.example.quizedu.dto.response;

import com.example.quizedu.entity.Quiz.DifficultyLevel;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class QuizResponse {

    private Long id;
    private Long documentId;
    private int questionCount;
    private DifficultyLevel difficulty;
    private LocalDateTime createdAt;
    private List<QuestionResponse> questions;

    @Data
    public static class QuestionResponse {
        private Long id;
        private String content;
        private String explanation;
        private List<ChoiceResponse> choices;
    }

    @Data
    public static class ChoiceResponse {
        private Long id;
        private String content;
        private boolean correct;
    }
}
