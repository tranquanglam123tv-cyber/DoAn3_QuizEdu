package com.example.quizedu.dto.response;

import com.example.quizedu.entity.Exam.ExamStatus;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class ExamResponse {

    private Long id;
    private Long quizId;
    private String quizName;
    private String difficulty;
    private ExamStatus status;
    private int totalQuestions;
    private int correctCount;
    private double score;
    private LocalDateTime startedAt;
    private LocalDateTime submittedAt;
    private List<AnswerResultResponse> answers;

    @Data
    public static class AnswerResultResponse {
        private Long questionId;
        private String questionContent;
        private String selectedChoice;
        private String correctChoice;
        private String explanation;
        private boolean correct;
    }
}
