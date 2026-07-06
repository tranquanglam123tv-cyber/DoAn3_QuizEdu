package com.example.quizedu.service;

import com.example.quizedu.dto.request.GoogleLoginRequest;
import com.example.quizedu.dto.request.LoginRequest;
import com.example.quizedu.dto.request.RegisterRequest;
import com.example.quizedu.dto.response.AuthResponse;
import com.example.quizedu.entity.Role;
import com.example.quizedu.entity.User;
import com.example.quizedu.repository.UserRepository;
import com.example.quizedu.security.JwtUtil;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Locale;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthResponse register(RegisterRequest request) {
        String email = request.getEmail().toLowerCase(Locale.ROOT);

        if (userRepository.existsByEmail(email)) {
            throw new IllegalStateException("Email already exists");
        }

        User user = User.builder()
                .email(email)
                .password(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .role(Role.STUDENT)
                .build();

        userRepository.save(user);

        String token = jwtUtil.generateToken(user.getEmail());
        return buildAuthResponse(user, token);
    }

    public AuthResponse login(LoginRequest request) {
        String email = request.getEmail().toLowerCase(Locale.ROOT);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalStateException("Invalid email or password"));

        if (user.isLocked()) {
            throw new IllegalStateException("Account is locked");
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new IllegalStateException("Invalid email or password");
        }

        String token = jwtUtil.generateToken(user.getEmail());
        return buildAuthResponse(user, token);
    }

    public AuthResponse googleLogin(GoogleLoginRequest request) {
        try {
            FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(request.getIdToken());
            String email = decoded.getEmail();
            if (email == null || email.isBlank()) {
                throw new IllegalStateException("Invalid Google token");
            }

            email = email.toLowerCase(Locale.ROOT);
            Optional<User> existing = userRepository.findByEmail(email);
            User user = existing.orElseGet(() -> createGoogleUser(decoded));
            String token = jwtUtil.generateToken(user.getEmail());
            return buildAuthResponse(user, token);
        } catch (Exception e) {
            throw new IllegalStateException("Google login failed: " + e.getMessage());
        }
    }

    private User createGoogleUser(FirebaseToken decoded) {
        String email = decoded.getEmail().toLowerCase(Locale.ROOT);
        String fullName = decoded.getName();
        if (fullName == null || fullName.isBlank()) {
            fullName = decoded.getEmail();
        }

        User user = User.builder()
                .email(email)
                .password(passwordEncoder.encode("GOOGLE_" + email))
                .fullName(fullName)
                .role(Role.STUDENT)
                .build();

        return userRepository.save(user);
    }

    private AuthResponse buildAuthResponse(User user, String token) {
        return new AuthResponse(
                token,
                "Bearer",
                user.getFullName(),
                user.getEmail(),
                user.getRole().name()
        );
    }
}
