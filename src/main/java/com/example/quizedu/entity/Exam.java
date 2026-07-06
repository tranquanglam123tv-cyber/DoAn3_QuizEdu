package com.example.quizedu.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@ToString(exclude = "answers")
@Entity
@Table(name = "exams")
public class Exam {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "quiz_id")
    private Quiz quiz;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    private int totalQuestions;
    private int correctCount;
    private double score; // 0 - 10

    @Enumerated(EnumType.STRING)
    private ExamStatus status; // IN_PROGRESS, SUBMITTED

    private LocalDateTime startedAt;
    private LocalDateTime submittedAt;

    @OneToMany(mappedBy = "exam", cascade = CascadeType.ALL)
    private List<ExamAnswer> answers;

    @PrePersist
    protected void onCreate() {
        startedAt = LocalDateTime.now();
        status = ExamStatus.IN_PROGRESS;
    }

    public enum ExamStatus {
        IN_PROGRESS, SUBMITTED
    }
}
