package com.example.quizedu.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class SubmitExamRequest {

    @NotNull
    private Long examId;

    @NotEmpty
    private List<ExamAnswerRequest> answers;
}
