package com.example.quizedu.repository;

import com.example.quizedu.entity.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface QuizRepository extends JpaRepository<Quiz, Long> {
    List<Quiz> findAllByUserId(Long userId);
    Optional<Quiz> findByIdAndUserId(Long id, Long userId);
    long countByUserId(Long userId);
}
