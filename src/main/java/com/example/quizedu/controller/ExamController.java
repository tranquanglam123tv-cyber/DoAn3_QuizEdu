package com.example.quizedu.controller;

import com.example.quizedu.dto.request.SubmitExamRequest;
import com.example.quizedu.dto.response.ApiResponse;
import com.example.quizedu.dto.response.ExamResponse;
import com.example.quizedu.service.ExamService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/exam")
@RequiredArgsConstructor
public class ExamController {

    private final ExamService examService;

    @PostMapping("/start/{quizId}")
    public ResponseEntity<ApiResponse<ExamResponse>> start(@PathVariable Long quizId) {
        return ResponseEntity.ok(ApiResponse.success(examService.start(quizId)));
    }

    @PostMapping("/submit")
    public ResponseEntity<ApiResponse<ExamResponse>> submit(@Valid @RequestBody SubmitExamRequest request) {
        return ResponseEntity.ok(ApiResponse.success(examService.submit(request)));
    }

    @GetMapping("/result/{examId}")
    public ResponseEntity<ApiResponse<ExamResponse>> result(@PathVariable Long examId) {
        return ResponseEntity.ok(ApiResponse.success(examService.getResult(examId)));
    }

    @GetMapping("/history")
    public ResponseEntity<ApiResponse<List<ExamResponse>>> history() {
        return ResponseEntity.ok(ApiResponse.success(examService.getHistory()));
    }
}
