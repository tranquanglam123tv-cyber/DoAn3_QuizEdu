package com.example.quizedu.service;

import com.example.quizedu.dto.response.AdminDashboardResponse;
import com.example.quizedu.dto.response.StudentDashboardResponse;
import com.example.quizedu.entity.Exam;
import com.example.quizedu.entity.User;
import com.example.quizedu.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final UserRepository userRepository;
    private final SubjectRepository subjectRepository;
    private final DocumentRepository documentRepository;
    private final QuizRepository quizRepository;
    private final ExamRepository examRepository;

    public StudentDashboardResponse getStudentDashboard() {
        User user = getCurrentUser();
        Long userId = user.getId();

        List<Exam> submittedExams = examRepository
                .findAllByUserIdAndStatus(userId, Exam.ExamStatus.SUBMITTED);

        double averageScore = submittedExams.stream()
                .mapToDouble(Exam::getScore)
                .average()
                .orElse(0.0);

        long totalCorrect = submittedExams.stream()
                .mapToLong(Exam::getCorrectCount)
                .sum();

        long totalAnswers = submittedExams.stream()
                .mapToLong(Exam::getTotalQuestions)
                .sum();

        return StudentDashboardResponse.builder()
                .totalSubjects(subjectRepository.countByUserId(userId))
                .totalDocuments(documentRepository.countByUserId(userId))
                .totalQuizzes(quizRepository.countByUserId(userId))
                .totalExams((long) submittedExams.size())
                .averageScore(Math.round(averageScore * 10.0) / 10.0)
                .totalCorrectAnswers(totalCorrect)
                .totalAnswers(totalAnswers)
                .build();
    }

    public AdminDashboardResponse getAdminDashboard() {
        return AdminDashboardResponse.builder()
                .totalUsers(userRepository.count())
                .totalSubjects(subjectRepository.count())
                .totalDocuments(documentRepository.count())
                .totalQuizzes(quizRepository.count())
                .totalExams(examRepository.count())
                .build();
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalStateException("User not found"));
    }
}
