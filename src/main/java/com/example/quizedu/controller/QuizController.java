package com.example.quizedu.controller;

import com.example.quizedu.dto.request.QuizRequest;
import com.example.quizedu.dto.response.ApiResponse;
import com.example.quizedu.dto.response.QuizResponse;
import com.example.quizedu.service.QuizService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/quiz")
@RequiredArgsConstructor
public class QuizController {

    private final QuizService quizService;

    @PostMapping("/generate")
    public ResponseEntity<ApiResponse<QuizResponse>> generate(@Valid @RequestBody QuizRequest request) {
        return ResponseEntity.ok(ApiResponse.success(quizService.generate(request)));
    }

    @GetMapping("/{quizId}")
    public ResponseEntity<ApiResponse<QuizResponse>> getQuiz(@PathVariable Long quizId) {
        return ResponseEntity.ok(ApiResponse.success(quizService.getQuiz(quizId)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<QuizResponse>>> getAll() {
        return ResponseEntity.ok(ApiResponse.success(quizService.getAll()));
    }
}
