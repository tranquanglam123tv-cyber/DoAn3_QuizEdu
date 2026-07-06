package com.example.quizedu.service;

import com.example.quizedu.dto.response.DocumentResponse;
import com.example.quizedu.entity.Document;
import com.example.quizedu.entity.Subject;
import com.example.quizedu.entity.User;
import com.example.quizedu.repository.DocumentRepository;
import com.example.quizedu.repository.SubjectRepository;
import com.example.quizedu.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DocumentService {

    private final DocumentRepository documentRepository;
    private final SubjectRepository subjectRepository;
    private final UserRepository userRepository;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    public DocumentResponse upload(Long subjectId, MultipartFile file) throws IOException {
        log.info("Starting document upload for subject: {}", subjectId);
        log.info("File name: {}, size: {}, content type: {}", 
            file.getOriginalFilename(), file.getSize(), file.getContentType());
        
        if (file.isEmpty()) {
            log.error("Uploaded file is empty");
            throw new IllegalStateException("File is empty");
        }
        
        User user = getCurrentUser();

        Subject subject = subjectRepository.findByIdAndUserId(subjectId, user.getId())
                .orElseThrow(() -> new IllegalStateException("Subject not found"));

        String originalName = file.getOriginalFilename();
        String extension = getExtension(originalName);

        if (!extension.equals("pdf") && !extension.equals("docx")) {
            throw new IllegalStateException("Only PDF and DOCX files are allowed");
        }

        if (file.getSize() > 10 * 1024 * 1024) {
            throw new IllegalStateException("File size must not exceed 10MB");
        }

        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        String savedName = UUID.randomUUID() + "_" + originalName;
        Path filePath = uploadPath.resolve(savedName);
        Files.write(filePath, file.getBytes());

        String content = extension.equals("pdf")
                ? extractPdf(file)
                : extractDocx(file);

        Document document = Document.builder()
                .fileName(originalName)
                .fileType(extension)
                .fileSize(file.getSize())
                .filePath(filePath.toString())
                .content(content)
                .subject(subject)
                .user(user)
                .build();

        try {
            return toResponse(documentRepository.save(document));
        } catch (Exception e) {
            Files.deleteIfExists(filePath);
            throw e;
        }
    }

    public List<DocumentResponse> getAll(Long subjectId) {
        User user = getCurrentUser();
        return documentRepository.findAllBySubjectIdAndUserId(subjectId, user.getId())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public void delete(Long id) {
        User user = getCurrentUser();
        Document document = documentRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new IllegalStateException("Document not found"));

        Path filePath = Paths.get(document.getFilePath());
        try {
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            log.warn("Could not delete file: {}", filePath.getFileName());
        }

        documentRepository.delete(document);
    }

    private String extractPdf(MultipartFile file) throws IOException {
        try (PDDocument pdf = Loader.loadPDF(file.getBytes())) {
            return new PDFTextStripper().getText(pdf);
        }
    }

    private String extractDocx(MultipartFile file) throws IOException {
        try (XWPFDocument docx = new XWPFDocument(file.getInputStream())) {
            return docx.getParagraphs()
                    .stream()
                    .map(XWPFParagraph::getText)
                    .collect(Collectors.joining("\n"));
        }
    }

    private String getExtension(String fileName) {
        if (fileName == null || !fileName.contains(".")) return "";
        return fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase(Locale.ROOT);
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalStateException("User not found"));
    }

    private DocumentResponse toResponse(Document document) {
        return new DocumentResponse(
                document.getId(),
                document.getFileName(),
                document.getFileType(),
                document.getFileSize(),
                document.getSubject().getId(),
                document.getCreatedAt()
        );
    }
}
