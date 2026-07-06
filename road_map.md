# Quiz EduTech AI

## 60-Day Development Roadmap

Version: 1.1

---

# Project Goal

Xây dựng hệ thống hỗ trợ học tập thông minh sử dụng AI giúp người học:

- Quản lý môn học.
- Quản lý tài liệu học tập.
- AI tóm tắt nội dung tài liệu.
- AI tạo Flashcards.
- AI sinh đề trắc nghiệm.
- Làm bài và chấm điểm tự động.
- Theo dõi kết quả học tập.

---

# Technology Stack

## Backend

- Java 17
- Spring Boot 3.x
- Spring Security
- JWT Authentication
- Spring Data JPA
- Hibernate
- Maven

## Mobile

- Flutter
- Dart

## Database

- MySQL 8

## AI

- Google Gemini API

## Testing

- Postman

---

# Phase 1 (Day 1 - Day 10)

## Foundation & Authentication

### Backend

- Khởi tạo Spring Boot Project
- Cấu hình MySQL
- Cấu hình JPA
- Thiết lập Spring Security
- JWT Authentication
- Global Exception Handler
- Validation
- Swagger/OpenAPI

### Database

Thiết kế các bảng:

- Role
- User
- Refresh Token (nếu sử dụng)
- Subject

### Flutter

- Tạo Project
- Cấu trúc thư mục
- Theme
- Routing
- API Client
- Secure Storage

### Chức năng

- Register
- Login (Email/Password + Google)
- Logout
- Xem Profile
- Cập nhật Profile

### Deliverable

✅ Authentication hoàn chỉnh (Email/Password + Google OAuth)

---

# Phase 2 (Day 11 - Day 20)

## Subject & Document Management

### Subject Module

- Tạo môn học
- Cập nhật môn học
- Xóa môn học
- Danh sách môn học

### Document Module

Upload:

- PDF
- DOCX

Kiểm tra:

- Định dạng file
- Kích thước file

Lưu:

- Metadata
- File

Đọc nội dung:

- PDF Extraction
- DOCX Extraction

### Flutter

- Subject List
- Create Subject
- Upload Document
- Document Detail
- Delete Document

### Deliverable

✅ Người dùng có thể quản lý môn học và tải tài liệu.

---

# Phase 3 (Day 21 - Day 30)

## AI Processing Module

### Gemini Integration

- Kết nối Gemini API
- Quản lý Prompt
- Xử lý Response

### AI Summary

Sinh:

- Summary
- Key Points

### Flashcards

Sinh Flashcards từ tài liệu.

Lưu Flashcards vào Database.

### Deliverable

✅ AI tạo Summary và Flashcards thành công.

---

# Phase 4 (Day 31 - Day 40)

## Quiz Generation Module

### AI Quiz

Người dùng chọn:

- Một tài liệu

Tùy chọn:

- 5 câu
- 10 câu
- 20 câu
- 40 câu

Độ khó:

- Easy
- Medium
- Hard

### Backend

Sinh:

- Quiz
- Question
- Choice
- Explanation

Lưu toàn bộ vào Database.

### Flutter

- Quiz Configuration
- Quiz Preview

### Deliverable

✅ AI tạo đề trắc nghiệm hoàn chỉnh.

---

# Phase 5 (Day 41 - Day 50)

## Exam Module

### Backend

- Bắt đầu bài thi
- Lưu câu trả lời
- Nộp bài
- Chấm điểm tự động
- Tính điểm

### Flutter

- Quiz Screen
- Timer
- Auto Save
- Submit
- Result Screen

### Hiển thị

- Điểm số
- Đáp án đúng
- Giải thích từng câu

### Deliverable

✅ Hoàn thành quy trình làm bài và chấm điểm.

---

# Phase 6 (Day 51 - Day 60)

## Dashboard & Testing

### Student Dashboard

Hiển thị:

- Tổng số môn học
- Tổng tài liệu
- Tổng Quiz
- Số lần làm bài
- Điểm trung bình
- Biểu đồ kết quả học tập

### Testing

- API Testing
- Integration Testing
- Bug Fix

### Documentation

- Swagger
- README
- Database Script

### Deliverable

✅ MVP hoàn chỉnh sẵn sàng demo.

---

# Weekly Milestones

## Week 1

- Setup Project
- Authentication (Email + Google)

## Week 2

- Subject CRUD
- Upload Document

## Week 3

- AI Summary
- AI Flashcards

## Week 4

- AI Quiz Generation

## Week 5

- Exam
- Auto Scoring
- Result

## Week 6

- Dashboard
- Testing
- Bug Fix
- Documentation

---

# Final Deliverables

## Backend

- RESTful API
- JWT Authentication
- Subject CRUD
- Document Upload
- Gemini Integration
- Quiz Engine
- Exam Engine
- Dashboard API

---

## Mobile

- Authentication (Email + Google)
- Subject Management
- Upload Document
- AI Summary
- Flashcards
- AI Quiz
- Take Quiz
- Result
- Dashboard

---

## Database

- MySQL
- Quan hệ dữ liệu chuẩn
- Migration Script

---

## Documentation

- Software Requirement Specification (SRS)
- Entity Relationship Diagram (ERD)
- Use Case Diagram
- Class Diagram
- Sequence Diagram
- Activity Diagram
- API Documentation
- Test Case

---

# Success Criteria

## Functional

- Người dùng đăng ký và đăng nhập thành công (Email + Google).
- Quản lý môn học.
- Upload và quản lý tài liệu.
- AI tạo Summary và Flashcards.
- AI sinh đề trắc nghiệm.
- Làm bài và chấm điểm tự động.
- Dashboard thống kê học tập.

---

## Technical

- Spring Boot REST API.
- Flutter Mobile Application.
- JWT Authentication.
- MySQL Database.
- Google Gemini API Integration.
- Kiến trúc nhiều tầng (Controller – Service – Repository).
- API Response chuẩn JSON.

---

# Project Outcome

Sau 60 ngày, dự án sẽ hoàn thành phiên bản MVP của **Quiz EduTech AI**. Người dùng có thể tải tài liệu học tập, sử dụng AI để tóm tắt nội dung, tạo Flashcards và sinh đề trắc nghiệm tự động. Hệ thống hỗ trợ làm bài, chấm điểm và theo dõi kết quả học tập thông qua Dashboard.
