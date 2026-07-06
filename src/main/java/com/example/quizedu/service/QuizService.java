package com.example.quizedu.service;

import com.example.quizedu.dto.ai.QuizResult;
import com.example.quizedu.dto.request.QuizRequest;
import com.example.quizedu.dto.response.QuizResponse;
import com.example.quizedu.entity.*;
import com.example.quizedu.repository.DocumentRepository;
import com.example.quizedu.repository.QuizRepository;
import com.example.quizedu.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class QuizService {

    private final AIService aiService;
    private final QuizRepository quizRepository;
    private final DocumentRepository documentRepository;
    private final UserRepository userRepository;

    @Transactional
    public QuizResponse generate(QuizRequest request) {
        User user = getCurrentUser();

        Document document = documentRepository.findByIdAndUserId(request.getDocumentId(), user.getId())
                .orElseThrow(() -> new IllegalStateException("Document not found"));

        QuizResult result = aiService.generateQuiz(
                request.getDocumentId(),
                request.getQuestionCount(),
                request.getDifficulty().name()
        );

        Quiz quiz = new Quiz();
        quiz.setDocument(document);
        quiz.setUser(user);
        quiz.setQuestionCount(request.getQuestionCount());
        quiz.setDifficulty(request.getDifficulty());

        List<Question> questions = new ArrayList<>();
        for (QuizResult.QuestionItem qi : result.getQuestions()) {
            Question question = new Question();
            question.setContent(qi.getContent());
            question.setExplanation(qi.getExplanation());
            question.setQuiz(quiz);

            List<Choice> choices = new ArrayList<>();
            for (QuizResult.ChoiceItem ci : qi.getChoices()) {
                Choice choice = new Choice();
                choice.setContent(ci.getContent());
                choice.setCorrect(ci.isCorrect());
                choice.setQuestion(question);
                choices.add(choice);
            }
            question.setChoices(choices);
            questions.add(question);
        }

        quiz.setQuestions(questions);
        return toResponse(quizRepository.save(quiz));
    }

    @Transactional(readOnly = true)
    public QuizResponse getQuiz(Long quizId) {
        User user = getCurrentUser();
        Quiz quiz = quizRepository.findByIdAndUserId(quizId, user.getId())
                .orElseThrow(() -> new IllegalStateException("Quiz not found"));
        return toResponse(quiz);
    }

    @Transactional(readOnly = true)
    public List<QuizResponse> getAll() {
        User user = getCurrentUser();
        return quizRepository.findAllByUserId(user.getId())
                .stream().map(this::toResponse).toList();
    }

    private QuizResponse toResponse(Quiz quiz) {
        QuizResponse res = new QuizResponse();
        res.setId(quiz.getId());
        res.setDocumentId(quiz.getDocument().getId());
        res.setQuestionCount(quiz.getQuestionCount());
        res.setDifficulty(quiz.getDifficulty());
        res.setCreatedAt(quiz.getCreatedAt());

        List<QuizResponse.QuestionResponse> questions = new ArrayList<>();
        for (Question q : quiz.getQuestions()) {
            QuizResponse.QuestionResponse qr = new QuizResponse.QuestionResponse();
            qr.setId(q.getId());
            qr.setContent(q.getContent());
            qr.setExplanation(q.getExplanation());

            List<QuizResponse.ChoiceResponse> choices = new ArrayList<>();
            for (Choice c : q.getChoices()) {
                QuizResponse.ChoiceResponse cr = new QuizResponse.ChoiceResponse();
                cr.setId(c.getId());
                cr.setContent(c.getContent());
                cr.setCorrect(c.isCorrect());
                choices.add(cr);
            }
            qr.setChoices(choices);
            questions.add(qr);
        }

        res.setQuestions(questions);
        return res;
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalStateException("User not found"));
    }
}
