package com.example.quizedu.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class DocumentResponse {
    private Long id;
    private String fileName;
    private String fileType;
    private Long fileSize;
    private Long subjectId;
    private LocalDateTime createdAt;
}
