package com.example.quizedu.service;

import com.example.quizedu.dto.request.SubmitExamRequest;
import com.example.quizedu.dto.response.ExamResponse;
import com.example.quizedu.entity.*;
import com.example.quizedu.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ExamService {

    private final ExamRepository examRepository;
    private final ExamAnswerRepository examAnswerRepository;
    private final QuizRepository quizRepository;
    private final QuestionRepository questionRepository;
    private final ChoiceRepository choiceRepository;
    private final UserRepository userRepository;

    @Transactional
    public ExamResponse start(Long quizId) {
        User user = getCurrentUser();

        Quiz quiz = quizRepository.findByIdAndUserId(quizId, user.getId())
                .orElseThrow(() -> new IllegalStateException("Quiz not found"));

        Exam exam = new Exam();
        exam.setQuiz(quiz);
        exam.setUser(user);
        exam.setTotalQuestions(quiz.getQuestions().size());

        return toResponse(examRepository.save(exam));
    }

    @Transactional
    public ExamResponse submit(SubmitExamRequest request) {
        User user = getCurrentUser();

        Exam exam = examRepository.findByIdAndUserId(request.getExamId(), user.getId())
                .orElseThrow(() -> new IllegalStateException("Exam not found"));

        if (exam.getStatus() == Exam.ExamStatus.SUBMITTED) {
            throw new IllegalStateException("Exam already submitted");
        }

        Long quizId = exam.getQuiz().getId();

        List<ExamAnswer> answers = new ArrayList<>();
        for (var ar : request.getAnswers()) {
            Question question = questionRepository.findByIdAndQuizId(ar.getQuestionId(), quizId)
                    .orElseThrow(() -> new IllegalStateException("Question not found or does not belong to this quiz"));

            Choice selected = choiceRepository.findById(ar.getSelectedChoiceId())
                    .orElseThrow(() -> new IllegalStateException("Choice not found"));

            ExamAnswer answer = new ExamAnswer();
            answer.setExam(exam);
            answer.setQuestion(question);
            answer.setSelectedChoice(selected);
            answer.setCorrect(selected.isCorrect());
            answers.add(answer);
        }

        examAnswerRepository.saveAll(answers);

        int correctCount = (int) answers.stream().filter(ExamAnswer::isCorrect).count();
        double score = (double) correctCount / exam.getTotalQuestions() * 10;

        exam.setCorrectCount(correctCount);
        exam.setScore(Math.round(score * 10.0) / 10.0);
        exam.setStatus(Exam.ExamStatus.SUBMITTED);
        exam.setSubmittedAt(LocalDateTime.now());

        return toResponse(examRepository.save(exam));
    }

    @Transactional(readOnly = true)
    public ExamResponse getResult(Long examId) {
        User user = getCurrentUser();
        Exam exam = examRepository.findByIdAndUserId(examId, user.getId())
                .orElseThrow(() -> new IllegalStateException("Exam not found"));
        return toResponse(exam);
    }

    @Transactional(readOnly = true)
    public List<ExamResponse> getHistory() {
        User user = getCurrentUser();
        return examRepository.findAllByUserId(user.getId())
                .stream().map(this::toResponse).toList();
    }

    private ExamResponse toResponse(Exam exam) {
        ExamResponse res = new ExamResponse();
        res.setId(exam.getId());
        res.setQuizId(exam.getQuiz().getId());
        res.setQuizName(exam.getQuiz().getDocument().getFileName());
        res.setDifficulty(exam.getQuiz().getDifficulty().name());
        res.setStatus(exam.getStatus());
        res.setTotalQuestions(exam.getTotalQuestions());
        res.setCorrectCount(exam.getCorrectCount());
        res.setScore(exam.getScore());
        res.setStartedAt(exam.getStartedAt());
        res.setSubmittedAt(exam.getSubmittedAt());

        if (exam.getAnswers() != null) {
            List<ExamResponse.AnswerResultResponse> answerResults = new ArrayList<>();
            for (ExamAnswer a : exam.getAnswers()) {
                ExamResponse.AnswerResultResponse ar = new ExamResponse.AnswerResultResponse();
                ar.setQuestionId(a.getQuestion().getId());
                ar.setQuestionContent(a.getQuestion().getContent());
                ar.setSelectedChoice(a.getSelectedChoice().getContent());
                ar.setExplanation(a.getQuestion().getExplanation());
                ar.setCorrect(a.isCorrect());

                a.getQuestion().getChoices().stream()
                        .filter(Choice::isCorrect)
                        .findFirst()
                        .ifPresent(c -> ar.setCorrectChoice(c.getContent()));

                answerResults.add(ar);
            }
            res.setAnswers(answerResults);
        }

        return res;
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalStateException("User not found"));
    }
}
