package com.example.quizedu.service;

import com.example.quizedu.dto.response.UserResponse;
import com.example.quizedu.entity.User;
import com.example.quizedu.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminService {

    private final UserRepository userRepository;

    public List<UserResponse> getAllUsers() {
        return userRepository.findAll()
                .stream().map(this::toResponse).toList();
    }

    public UserResponse lockUser(Long userId) {
        User user = getUser(userId);
        user.setLocked(true);
        return toResponse(userRepository.save(user));
    }

    public UserResponse unlockUser(Long userId) {
        User user = getUser(userId);
        user.setLocked(false);
        return toResponse(userRepository.save(user));
    }

    private User getUser(Long userId) {
        return userRepository.findById(userId)
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
