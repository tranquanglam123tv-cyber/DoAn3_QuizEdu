package com.example.quizedu.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class StudentDashboardResponse {
    private long totalSubjects;
    private long totalDocuments;
    private long totalQuizzes;
    private long totalExams;
    private double averageScore;
    private long totalCorrectAnswers;
    private long totalAnswers;
}
