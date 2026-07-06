package com.example.quizedu.dto.request;

import com.example.quizedu.entity.User;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalDate;

@Data
public class UpdateProfileRequest {

    @NotBlank(message = "Full name is required")
    private String fullName;

    private String avatarUrl;

    private User.Gender gender;

    private LocalDate dateOfBirth;
}
