package com.example.quizedu.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AdminDashboardResponse {
    private long totalUsers;
    private long totalSubjects;
    private long totalDocuments;
    private long totalQuizzes;
    private long totalExams;
}
