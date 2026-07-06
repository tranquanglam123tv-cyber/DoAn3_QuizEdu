package com.example.quizedu.service;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.example.quizedu.dto.ai.FlashcardResult;
import com.example.quizedu.dto.ai.QuizResult;
import com.example.quizedu.dto.ai.SummaryResult;
import com.example.quizedu.entity.Document;
import com.example.quizedu.entity.User;
import com.example.quizedu.repository.DocumentRepository;
import com.example.quizedu.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class AIService {

    private final GeminiService geminiService;
    private final DocumentRepository documentRepository;
    private final UserRepository userRepository;

    public SummaryResult summarize(Long documentId) {
        Document document = getDocument(documentId);

        if (document.getContentSummary() != null && !document.getContentSummary().isBlank()) {
            log.info("Using cached content summary for document {}", documentId);
            String keywordsPrompt = """
                    Từ nội dung đã được tóm tắt sau, hãy trích xuất các ý chính và từ khóa quan trọng.
                    Trả về JSON thuần, không có markdown:
                    {
                      "overview": "tóm tắt tổng quan 3-5 câu về nội dung chính",
                      "keyPoints": ["ý chính 1", "ý chính 2", "ý chính 3", "ý chính 4", "ý chính 5"]
                    }
                    Nội dung đã xử lý:
                    """ + document.getContentSummary();

            return geminiService.generate(keywordsPrompt, SummaryResult.class);
        }

        String content = geminiService.truncate(document.getContent());
        if (content.isBlank()) {
            throw new IllegalStateException("Tài liệu không có nội dung để tóm tắt.");
        }

        String prompt = """
                Tóm tắt tài liệu sau bằng tiếng Việt.
                Chỉ trả về JSON thuần, không có markdown, không giải thích thêm.
                {
                  "overview": "tóm tắt tổng quan 3-5 câu",
                  "keyPoints": ["ý chính 1", "ý chính 2", "ý chính 3"]
                }

                Nội dung tài liệu:
                """ + content;

        SummaryResult result = geminiService.generate(prompt, SummaryResult.class);
        document.setContentSummary(result.getOverview() + "\n---\n" + String.join("\n", result.getKeyPoints()));
        documentRepository.save(document);

        return result;
    }

    public FlashcardResult generateFlashcards(Long documentId, int count) {
        Document document = getDocument(documentId);

        String cachedContent = document.getContentSummary() != null && !document.getContentSummary().isBlank()
                ? document.getContentSummary()
                : geminiService.truncate(document.getContent());

        if (cachedContent.isBlank()) {
            throw new IllegalStateException("Tài liệu không có nội dung để tạo flashcard.");
        }

        String prompt = """
                Tạo %d flashcard từ tài liệu sau bằng tiếng Việt.
                QUAN TRỌNG:
                - "answer" phải là CHUỖI text ngắn gọn, không phải mảng/object
                - Mỗi flashcard có câu hỏi ngắn gọn và câu trả lời ngắn gọn (1-3 dòng)
                - Các câu hỏi phải đa dạng, cover nhiều khía cạnh của tài liệu

                Chỉ trả về JSON thuần, không có markdown:
                {
                  "flashcards": [
                    {"question": "câu hỏi?", "answer": "câu trả lời ngắn"}
                  ]
                }

                Nội dung tài liệu:
                """.formatted(count) + cachedContent;

        return geminiService.generate(prompt, FlashcardResult.class);
    }

    public QuizResult generateQuiz(Long documentId, int count, String difficulty) {
        Document document = getDocument(documentId);

        String cachedContent = document.getContentSummary() != null && !document.getContentSummary().isBlank()
                ? document.getContentSummary()
                : geminiService.truncate(document.getContent());

        if (cachedContent.isBlank()) {
            throw new IllegalStateException("Tài liệu không có nội dung để tạo câu hỏi.");
        }

        String diffInstruction = switch (difficulty.toUpperCase()) {
            case "EASY" -> """
                    Câu hỏi DỄ:
                    - Chỉ hỏi các khái niệm cơ bản, định nghĩa trực tiếp từ tài liệu
                    - Đáp án đúng phải là CHÍNH XÁC từ tài liệu
                    - Đáp án sai phải HOÀN TOÀN KHÁC NHAU và đều hợp lý (không phải "tất cả đều đúng" hay "không có đáp án nào đúng")
                    - Các đáp án nên có độ dài tương đương nhau (chênh lệch không quá 30 ký tự)
                    - KHÔNG BAO GIỜ có pattern như "Tất cả đáp án trên", "Không có đáp án nào đúng"
                    """;
            case "HARD" -> """
                    Câu hỏi KHÓ:
                    - Hỏi về mối liên hệ, phân tích, so sánh, đánh giá
                    - Yêu cầu học sinh phải HIỂU sâu mới trả lời được
                    - Đáp án sai phải rất hợp lý, gần đúng, dễ nhầm lẫn
                    - Các đáp án NÊN có độ dài KHÁC NHAU để tránh chọn đáp án dài nhất
                    - Đặc biệt KHÔNG dùng cụm "Tất cả đều đúng/sai"
                    """;
            default -> """
                    Câu hỏi TRUNG BÌNH:
                    - Hỏi về khái niệm và áp dụng cơ bản
                    - Đáp án đúng phải rõ ràng từ tài liệu
                    - Đáp án sai phải có tính thuyết phục, dễ nhầm nếu không đọc kỹ
                    - Đáp án nên có độ dài tương đương nhau (chênh lệch không quá 40 ký tự)
                    - KHÔNG dùng "Tất cả đáp án trên" hay "Chỉ A và B"
                    """;
        };

        String prompt = """
                Tạo %d câu hỏi trắc nghiệm từ tài liệu sau, độ khó: %s.

                %s

                QUAN TRỌNG - LUÔN TUÂN THỦ:
                - Mỗi câu phải có đúng 4 lựa chọn, chỉ 1 đáp án đúng
                - 4 lựa chọn phải KHÁC NHAU HOÀN TOÀN về nội dung
                - Đáp án sai phải hợp lý và có thể confuse người không hiểu bài
                - Độ dài các lựa chọn NÊN tương đương nhau để không thể đoán đáp án bằng độ dài
                - KHÔNG BAO GIỜ dùng: "Tất cả đáp án trên", "Không có đáp án nào đúng", "Chỉ A và B"
                - explanation phải GIẢI THÍCH tại sao đáp án đúng và tại sao các đáp án sai KHÔNG đúng

                Trả về JSON thuần, không có markdown, không giải thích thêm:
                {
                  "questions": [
                    {
                      "content": "nội dung câu hỏi rõ ràng",
                      "explanation": "Giải thích: đáp án A đúng vì... các đáp án còn lại sai vì...",
                      "choices": [
                        {"content": "lựa chọn A", "correct": true},
                        {"content": "lựa chọn B - hơi khác nhưng sai", "correct": false},
                        {"content": "lựa chọn C - nghe có lý nhưng sai", "correct": false},
                        {"content": "lựa chọn D - gần đúng nhưng không chính xác", "correct": false}
                      ]
                    }
                  ]
                }

                Nội dung tài liệu:
                """.formatted(count, difficulty.toUpperCase(), diffInstruction) + cachedContent;

        return geminiService.generate(prompt, QuizResult.class);
    }

    private Document getDocument(Long documentId) {
        User user = getCurrentUser();
        return documentRepository.findByIdAndUserId(documentId, user.getId())
                .orElseThrow(() -> new IllegalStateException("Document not found"));
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalStateException("User not found"));
    }
}
