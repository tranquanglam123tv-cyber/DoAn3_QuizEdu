package com.example.quizedu;

import com.example.quizedu.entity.Role;
import com.example.quizedu.entity.User;
import com.example.quizedu.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        if (!userRepository.existsByEmail("admin@edutech.com")) {
            User admin = User.builder()
                    .email("admin@edutech.com")
                    .password(passwordEncoder.encode("Admin@123"))
                    .fullName("System Admin")
                    .role(Role.ADMIN)
                    .build();
            userRepository.save(admin);
            log.info("✅ Admin account created: admin@edutech.com / Admin@123");
        } else {
            log.info("ℹ️ Admin account already exists.");
        }
    }
}
