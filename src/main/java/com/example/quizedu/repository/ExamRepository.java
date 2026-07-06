package com.example.quizedu.repository;

import com.example.quizedu.entity.Exam;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ExamRepository extends JpaRepository<Exam, Long> {
    Optional<Exam> findByIdAndUserId(Long id, Long userId);
    List<Exam> findAllByUserId(Long userId);
    long countByUserIdAndStatus(Long userId, Exam.ExamStatus status);
    List<Exam> findAllByUserIdAndStatus(Long userId, Exam.ExamStatus status);
}
