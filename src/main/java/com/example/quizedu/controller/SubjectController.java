package com.example.quizedu.controller;

import com.example.quizedu.dto.request.SubjectRequest;
import com.example.quizedu.dto.response.ApiResponse;
import com.example.quizedu.dto.response.SubjectResponse;
import com.example.quizedu.service.SubjectService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/subjects")
@RequiredArgsConstructor
public class SubjectController {

    private final SubjectService subjectService;

    @PostMapping
    public ResponseEntity<ApiResponse<SubjectResponse>> create(@Valid @RequestBody SubjectRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(subjectService.create(request)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<SubjectResponse>>> getAll(){
        return ResponseEntity.ok(ApiResponse.success(subjectService.getAll()));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<SubjectResponse>> update(@PathVariable Long id,
                                                               @Valid @RequestBody SubjectRequest request) {
        return ResponseEntity.ok(ApiResponse.success(subjectService.update(id,request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long id){
        subjectService.delete(id);
        return ResponseEntity.ok(ApiResponse.success("Subject deleted successfully", null));
    }
}
