package com.example.quizedu.service;

import com.example.quizedu.dto.request.ChangePasswordRequest;
import com.example.quizedu.dto.request.UpdateProfileRequest;
import com.example.quizedu.dto.response.UserResponse;
import com.example.quizedu.entity.User;
import com.example.quizedu.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Value("${app.base.url:http://localhost:8081}")
    private String baseUrl;

    public UserResponse getProfile() {
        User user = getCurrentUser();
        return toResponse(user);
    }

    public UserResponse updateProfile(UpdateProfileRequest request) {
        User user = getCurrentUser();
        user.setFullName(request.getFullName());
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl());
        }
        if (request.getGender() != null) {
            user.setGender(request.getGender());
        }
        if (request.getDateOfBirth() != null) {
            user.setDateOfBirth(request.getDateOfBirth());
        }
        return toResponse(userRepository.save(user));
    }

    public String uploadAvatar(MultipartFile file) {
        if (file.isEmpty()) {
            throw new IllegalStateException("File is empty");
        }
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalStateException("Only image files are allowed");
        }
        if (file.getSize() > 2 * 1024 * 1024) {
            throw new IllegalStateException("File size must not exceed 2MB");
        }

        User user = getCurrentUser();

        Path uploadPath = Paths.get(uploadDir, "avatars");
        if (!Files.exists(uploadPath)) {
            try {
                Files.createDirectories(uploadPath);
            } catch (IOException e) {
                throw new IllegalStateException("Could not create upload directory");
            }
        }

        String extension = contentType.substring(contentType.indexOf("/") + 1);
        String savedName = user.getId() + "_avatar." + extension;
        Path filePath = uploadPath.resolve(savedName);

        try {
            Files.write(filePath, file.getBytes());
        } catch (IOException e) {
            throw new IllegalStateException("Could not save avatar file");
        }

        String avatarUrl = baseUrl + "/uploads/avatars/" + savedName;
        user.setAvatarUrl(avatarUrl);
        userRepository.save(user);

        return avatarUrl;
    }

    public void changePassword(ChangePasswordRequest request) {
        User user = getCurrentUser();

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Mật khẩu cũ không đúng");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalStateException("User not found"));
    }

    private UserResponse toResponse(User user) {
        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getRole().name(),
                user.getAvatarUrl(),
                user.getGender(),
                user.getDateOfBirth(),
                user.getCreatedAt()
        );
    }
}
