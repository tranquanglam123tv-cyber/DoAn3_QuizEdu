package com.example.quizedu.controller;

import com.example.quizedu.dto.ai.FlashcardResult;
import com.example.quizedu.dto.ai.SummaryResult;
import com.example.quizedu.dto.response.ApiResponse;
import com.example.quizedu.service.AIService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AIController {

    private final AIService aiService;

    @GetMapping("/summarize/{documentId}")
    public ResponseEntity<ApiResponse<SummaryResult>> summarize(@PathVariable Long documentId) {
        return ResponseEntity.ok(ApiResponse.success(aiService.summarize(documentId)));
    }

    @GetMapping("/flashcards/{documentId}")
    public ResponseEntity<ApiResponse<FlashcardResult>> flashcards(
            @PathVariable Long documentId,
            @RequestParam(defaultValue = "8") int count) {
        return ResponseEntity.ok(ApiResponse.success(aiService.generateFlashcards(documentId, count)));
    }
}
