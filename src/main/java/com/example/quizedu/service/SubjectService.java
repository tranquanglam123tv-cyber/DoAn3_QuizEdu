package com.example.quizedu.service;

import com.example.quizedu.dto.request.SubjectRequest;
import com.example.quizedu.dto.response.SubjectResponse;
import com.example.quizedu.entity.Subject;
import com.example.quizedu.entity.User;
import com.example.quizedu.repository.SubjectRepository;
import com.example.quizedu.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SubjectService {
    private final SubjectRepository subjectRepository;
    private final UserRepository userRepository;
    public SubjectResponse create(SubjectRequest request) {
        User user = getCurrentUser();
        Subject subject = Subject.builder()
                .name(request.getName())
                .description(request.getDescription())
                .user(user)
                .build();
        return toResponse(subjectRepository.save(subject));
    }

    public List<SubjectResponse> getAll(){
        User user = getCurrentUser();
        return subjectRepository.findAllByUserId(user.getId())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public SubjectResponse update(Long id, SubjectRequest request) {
        User user = getCurrentUser();
        Subject subject = subjectRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new IllegalStateException("Subject not found"));
        subject.setName(request.getName());
        subject.setDescription(request.getDescription());
        return toResponse(subjectRepository.save(subject));
    }

    public void delete(Long id) {
        User user = getCurrentUser();
        Subject subject = subjectRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new IllegalStateException("Subject not found"));
        subjectRepository.delete(subject);
    }
    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalStateException("User not found"));
    }

    private SubjectResponse toResponse(Subject subject){
        return new SubjectResponse(
                subject.getId(),
                subject.getName(),
                subject.getDescription(),
                subject.getCreatedAt()
        );
    }
}

