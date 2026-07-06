package com.example.quizedu.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank(message = "FUll NAME IS REQUIRED")
    private String fullName;

    @NotBlank(message = "EMAIL IS REQUIRED")
    @Email(message = "EMAIL IS INVALID")
    private String email;

    @NotBlank(message = "PASSWORD IS REQUIRED")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;
}
