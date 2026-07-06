package com.example.quizedu.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.InputStream;

@Component
public class FirebaseConfig {

    @Value("${firebase.credentials.path:firebase-service-account.json}")
    private String credentialsPath;

    @PostConstruct
    public void initialize() {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                ClassPathResource resource = new ClassPathResource(credentialsPath);
                InputStream serviceAccount = resource.getInputStream();

                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

                FirebaseApp.initializeApp(options);
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize Firebase Admin SDK: " + e.getMessage(), e);
        }
    }
}
