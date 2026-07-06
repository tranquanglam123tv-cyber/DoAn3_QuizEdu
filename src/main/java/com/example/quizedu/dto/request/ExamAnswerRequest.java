package com.example.quizedu.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ExamAnswerRequest {
    @NotNull
    private Long questionId;

    @NotNull
    private Long selectedChoiceId;
}
