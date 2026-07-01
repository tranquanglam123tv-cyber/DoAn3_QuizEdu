# Quiz EduTech AI

Hệ thống hỗ trợ học tập thông minh sử dụng AI — sinh đề trắc nghiệm, tóm tắt tài liệu, tạo flashcard tự động.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Java 17, Spring Boot 3.4, Spring Security, JWT |
| Mobile/Web | Flutter, Dart |
| Database | MySQL 8 |
| AI | OpenRouter API (Gemini 2.0 Flash) |
| Docs | Swagger / OpenAPI 3 |

---

## Cấu trúc dự án

```
QuizEdu/
├── quizedu/          # Spring Boot Backend
│   └── src/main/java/com/example/quizedu/
│       ├── controller/
│       ├── service/
│       ├── repository/
│       ├── entity/
│       ├── dto/
│       ├── security/
│       └── exception/
└── edutech_app/      # Flutter Frontend
    └── lib/
        ├── core/
        │   ├── api/
        │   ├── storage/
        │   ├── theme/
        │   └── widgets/
        └── features/
            ├── auth/
            ├── dashboard/
            ├── subject/
            ├── document/
            ├── ai/
            ├── quiz/
            ├── exam/
            ├── profile/
            └── admin/
```

---

## Database Schema (ERD)

```
User
├── id (PK)
├── email (UNIQUE)
├── password
├── fullName
├── role (STUDENT | ADMIN)
├── locked
└── createdAt

Subject
├── id (PK)
├── name
├── description
├── user_id (FK → User)
└── createdAt

Document
├── id (PK)
├── fileName
├── fileType (pdf | docx)
├── fileSize
├── filePath
├── content (LONGTEXT)
├── subject_id (FK → Subject)
├── user_id (FK → User)
└── createdAt

Quiz
├── id (PK)
├── questionCount
├── difficulty (EASY | MEDIUM | HARD)
├── document_id (FK → Document)
├── user_id (FK → User)
└── createdAt

Question
├── id (PK)
├── content
├── explanation
└── quiz_id (FK → Quiz)

Choice
├── id (PK)
├── content
├── correct (boolean)
└── question_id (FK → Question)

Exam
├── id (PK)
├── status (IN_PROGRESS | COMPLETED)
├── totalQuestions
├── correctCount
├── score
├── startedAt
├── submittedAt
├── quiz_id (FK → Quiz)
└── user_id (FK → User)

ExamAnswer
├── id (PK)
├── exam_id (FK → Exam)
├── question_id (FK → Question)
└── choice_id (FK → Choice)
```

---

## API Endpoints

### Auth
| Method | Endpoint | Mô tả |
|---|---|---|
| POST | /api/auth/register | Đăng ký |
| POST | /api/auth/login | Đăng nhập |

### Users
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/users/profile | Xem profile |
| PUT | /api/users/profile | Cập nhật profile |
| PUT | /api/users/change-password | Đổi mật khẩu |

### Subjects
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/subjects | Danh sách môn học |
| POST | /api/subjects | Tạo môn học |
| PUT | /api/subjects/{id} | Cập nhật môn học |
| DELETE | /api/subjects/{id} | Xoá môn học |

### Documents
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/subjects/{id}/documents | Danh sách tài liệu |
| POST | /api/subjects/{id}/documents | Upload tài liệu |
| DELETE | /api/subjects/{subjectId}/documents/{id} | Xoá tài liệu |

### AI
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/ai/summarize/{documentId} | Tóm tắt tài liệu |
| GET | /api/ai/flashcards/{documentId} | Tạo flashcard |

### Quiz
| Method | Endpoint | Mô tả |
|---|---|---|
| POST | /api/quiz/generate | Sinh đề trắc nghiệm |

### Exam
| Method | Endpoint | Mô tả |
|---|---|---|
| POST | /api/exam/start/{quizId} | Bắt đầu bài thi |
| POST | /api/exam/submit | Nộp bài |
| GET | /api/exam/history | Lịch sử thi |

### Dashboard
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/dashboard/student | Thống kê học sinh |
| GET | /api/dashboard/admin | Thống kê admin |

### Admin
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | /api/admin/users | Danh sách người dùng |
| PUT | /api/admin/users/{id}/lock | Khoá tài khoản |
| PUT | /api/admin/users/{id}/unlock | Mở khoá tài khoản |
| GET | /api/admin/documents | Tất cả tài liệu |
| DELETE | /api/admin/documents/{id} | Xoá tài liệu |

---

## Cài đặt & Chạy

### Backend

1. Tạo database MySQL:
```sql
CREATE DATABASE edutech_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. Cấu hình `application-local.properties`:
```properties
DB_USERNAME=root
DB_PASSWORD=your_password
JWT_SECRET=your_jwt_secret
gemini.api.key=your_openrouter_key
```

3. Chạy:
```bash
cd quizedu
./mvnw spring-boot:run
```

4. Swagger UI: http://localhost:8081/swagger-ui/index.html

### Flutter

1. Cấu hình `.env`:
```
BASE_URL=http://localhost:8081/api
```

2. Chạy:
```bash
cd edutech_app
flutter run -d edge
```

---

## Tính năng

- ✅ Đăng ký / Đăng nhập / JWT Authentication
- ✅ Quản lý môn học (CRUD)
- ✅ Upload tài liệu PDF/DOCX
- ✅ AI tóm tắt tài liệu
- ✅ AI tạo Flashcard
- ✅ AI sinh đề trắc nghiệm (Easy/Medium/Hard)
- ✅ Làm bài thi với timer đếm ngược
- ✅ Chấm điểm tự động + giải thích từng câu
- ✅ Dashboard thống kê học tập + biểu đồ
- ✅ Admin quản lý user, tài liệu, thống kê hệ thống
