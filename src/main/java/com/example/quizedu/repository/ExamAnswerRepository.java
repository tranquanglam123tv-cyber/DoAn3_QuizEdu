package com.example.quizedu.repository;

import com.example.quizedu.entity.ExamAnswer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ExamAnswerRepository extends JpaRepository<ExamAnswer, Long> {
}
