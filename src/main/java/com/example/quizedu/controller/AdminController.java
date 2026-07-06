package com.example.quizedu.controller;

import com.example.quizedu.dto.response.ApiResponse;
import com.example.quizedu.dto.response.UserResponse;
import com.example.quizedu.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/users")
    public ResponseEntity<ApiResponse<List<UserResponse>>> getAllUsers() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getAllUsers()));
    }

    @PutMapping("/users/{userId}/lock")
    public ResponseEntity<ApiResponse<UserResponse>> lockUser(@PathVariable Long userId) {
        return ResponseEntity.ok(ApiResponse.success(adminService.lockUser(userId)));
    }

    @PutMapping("/users/{userId}/unlock")
    public ResponseEntity<ApiResponse<UserResponse>> unlockUser(@PathVariable Long userId) {
        return ResponseEntity.ok(ApiResponse.success(adminService.unlockUser(userId)));
    }
}
