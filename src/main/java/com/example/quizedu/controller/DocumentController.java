package com.example.quizedu.controller;

import com.example.quizedu.dto.response.ApiResponse;
import com.example.quizedu.dto.response.DocumentResponse;
import com.example.quizedu.service.DocumentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/subjects/{subjectId}/documents")
@RequiredArgsConstructor
@Slf4j
public class DocumentController {

    private final DocumentService documentService;

    @PostMapping
    public ResponseEntity<ApiResponse<DocumentResponse>> upload(@PathVariable Long subjectId,
                                                               @RequestParam("file") MultipartFile file) {
        try {
            log.info("Received upload request for subject: {}, file: {}", subjectId, file.getOriginalFilename());
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success(documentService.upload(subjectId, file)));
        } catch (IllegalStateException e) {
            log.error("Validation error during upload: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        } catch (IOException e) {
            log.error("IO error during upload: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to process file: " + e.getMessage()));
        } catch (Exception e) {
            log.error("Unexpected error during upload: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("An unexpected error occurred"));
        }
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<DocumentResponse>>> getAll(@PathVariable Long subjectId) {
        return ResponseEntity.ok(ApiResponse.success(documentService.getAll(subjectId)));
    }

    

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long subjectId,
                                                    @PathVariable Long id) {
        documentService.delete(id);
        return ResponseEntity.ok(ApiResponse.success("Document deleted successfully", null));
    }
}
