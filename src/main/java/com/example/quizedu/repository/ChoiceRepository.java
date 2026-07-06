package com.example.quizedu.repository;

import com.example.quizedu.entity.Choice;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChoiceRepository extends JpaRepository<Choice, Long> {
}
