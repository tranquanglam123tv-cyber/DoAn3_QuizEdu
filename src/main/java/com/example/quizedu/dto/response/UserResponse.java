package com.example.quizedu.dto.response;

import com.example.quizedu.entity.User;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class UserResponse {
    private Long id;
    private String email;
    private String fullName;
    private String role;
    private String avatarUrl;
    private User.Gender gender;
    private LocalDate dateOfBirth;
    private LocalDateTime createdAt;
}
