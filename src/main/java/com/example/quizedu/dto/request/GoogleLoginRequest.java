package com.example.quizedu.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class GoogleLoginRequest {

    @NotBlank(message = "Google id token is required")
    private String idToken;
}
