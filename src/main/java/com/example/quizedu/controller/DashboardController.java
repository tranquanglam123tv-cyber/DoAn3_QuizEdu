package com.example.quizedu.controller;

import com.example.quizedu.dto.response.AdminDashboardResponse;
import com.example.quizedu.dto.response.ApiResponse;
import com.example.quizedu.dto.response.StudentDashboardResponse;
import com.example.quizedu.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/student")
    public ResponseEntity<ApiResponse<StudentDashboardResponse>> student() {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getStudentDashboard()));
    }

    @GetMapping("/admin")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<AdminDashboardResponse>> admin() {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getAdminDashboard()));
    }
}
