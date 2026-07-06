package com.example.quizedu.repository;

import com.example.quizedu.entity.Document;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DocumentRepository extends JpaRepository<Document, Long> {
    List<Document> findAllBySubjectIdAndUserId(Long subjectId, Long userId);
    Optional<Document> findByIdAndUserId(Long id, Long userId);
    long countByUserId(Long userId);
}
