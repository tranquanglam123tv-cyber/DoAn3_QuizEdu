package com.example.quizedu.service;

import com.example.quizedu.exception.AiException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestClient;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class GeminiService {

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.url}")
    private String apiUrl;

    @Value("${gemini.model}")
    private String model;

    private final ObjectMapper objectMapper;

    private RestClient restClient;

    @PostConstruct
    public void init() {
        restClient = RestClient.create();
    }

    private static final int MAX_CONTENT_LENGTH = 8000;

    public <T> T generate(String prompt, Class<T> responseType) {
        Map<String, Object> requestBody = Map.of(
                "model", model,
                "messages", List.of(Map.of("role", "user", "content", prompt)),
                "max_tokens", 4000
        );

        Map<?, ?> response;
        try {
            response = restClient.post()
                    .uri(apiUrl)
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + apiKey)
                    .body(requestBody)
                    .retrieve()
                    .body(Map.class);
        } catch (RestClientResponseException e) {
            log.error("AI API HTTP {}: {}", e.getStatusCode(), e.getResponseBodyAsString());
            throw new AiException("AI API lỗi HTTP " + e.getStatusCode() + ". Vui lòng thử lại sau.", e);
        } catch (Exception e) {
            log.error("AI API call failed: {}", e.getMessage());
            throw new AiException("Không thể kết nối đến AI. Vui lòng thử lại sau.", e);
        }

        if (response == null) {
            throw new AiException("AI trả về phản hồi rỗng.", null);
        }

        if (response.containsKey("error")) {
            Object err = response.get("error");
            log.error("AI API error: {}", err);
            throw new AiException("AI API lỗi: " + err, null);
        }

        try {
            var choices = (List<?>) response.get("choices");
            if (choices == null || choices.isEmpty()) {
                throw new AiException("AI không trả về kết quả.", null);
            }
            var first = (Map<?, ?>) choices.get(0);
            var message = (Map<?, ?>) first.get("message");
            String rawContent = message.get("content").toString().trim();
            log.info("AI raw response length: {} chars", rawContent.length());

            String json = extractJson(rawContent);
            log.debug("AI extracted JSON: {}", json);

            return objectMapper.readValue(json, responseType);
        } catch (AiException e) {
            throw e;
        } catch (Exception e) {
            log.error("Failed to parse AI response: {}", e.getMessage(), e);
            throw new AiException("Không thể xử lý phản hồi từ AI. Vui lòng thử lại.", e);
        }
    }

    private String extractJson(String raw) {
        if (raw.startsWith("{") || raw.startsWith("[")) return raw;

        int start = raw.indexOf("```json");
        if (start != -1) {
            start = raw.indexOf('\n', start) + 1;
        } else {
            start = raw.indexOf("```");
            if (start != -1) start = raw.indexOf('\n', start) + 1;
        }
        int end = start != -1 ? raw.lastIndexOf("```") : -1;

        if (start != -1 && end > start) return raw.substring(start, end).trim();

        int jsonStart = raw.indexOf('{');
        int jsonEnd = raw.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd > jsonStart) return raw.substring(jsonStart, jsonEnd + 1);

        return raw;
    }

    public String truncate(String content) {
        if (content == null || content.isBlank()) return "";
        return content.length() > MAX_CONTENT_LENGTH
                ? content.substring(0, MAX_CONTENT_LENGTH) + "\n...[nội dung bị cắt bớt]"
                : content;
    }
}
