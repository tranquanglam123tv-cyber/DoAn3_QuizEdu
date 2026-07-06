package com.example.quizedu.dto.request;

import com.example.quizedu.entity.Quiz.DifficultyLevel;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class QuizRequest {

    @NotNull
    private Long documentId;

    @NotNull
    private Integer questionCount; // 10, 20, 40

    @NotNull
    private DifficultyLevel difficulty;
}
