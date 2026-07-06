package com.example.quizedu.repository;

import com.example.quizedu.entity.Subject;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SubjectRepository extends JpaRepository<Subject, Long> {
    List<Subject> findAllByUserId(Long userId);
    Optional<Subject> findByIdAndUserId(Long id, Long userId);
    long countByUserId(Long userId);
}
