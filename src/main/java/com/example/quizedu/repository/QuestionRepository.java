package com.example.quizedu.repository;

import com.example.quizedu.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface QuestionRepository extends JpaRepository<Question, Long> {
    Optional<Question> findByIdAndQuizId(Long id, Long quizId);
}
