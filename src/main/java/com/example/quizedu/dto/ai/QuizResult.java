package com.example.quizedu.dto.ai;

import lombok.Data;
import java.util.List;

@Data
public class QuizResult {

    private List<QuestionItem> questions;

    @Data
    public static class QuestionItem {
        private String content;
        private String explanation;
        private List<ChoiceItem> choices;
    }

    @Data
    public static class ChoiceItem {
        private String content;
        private boolean correct;
    }
}
