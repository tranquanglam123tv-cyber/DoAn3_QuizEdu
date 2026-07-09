# QuizEdu - Sơ đồ UML cho Báo cáo Đồ án

## 📁 Các file sơ đồ

| File | Mô tả |
|------|--------|
| `usecase_quizedu.puml` | Sơ đồ Use Case - Tổng quan chức năng hệ thống |
| `class_diagram_quizedu.puml` | Sơ đồ Class - Cấu trúc classes và relationships |
| `erd_quizedu.puml` | Sơ đồ ERD - Thiết kế cơ sở dữ liệu |
| `sequence_auth.puml` | Sơ đồ Sequence - Đăng ký, Đăng nhập, Google Login |
| `sequence_quiz_exam.puml` | Sơ đồ Sequence - Upload tài liệu, AI, Quiz, Exam, History |
| `sequence_admin_dashboard.puml` | Sơ đồ Sequence - Dashboard, Admin, Contact, Export |

---

## 🚀 Cách render sơ đồ PlantUML

### Cách 1: VSCode / Cursor IDE (Khuyến nghị)

1. **Cài extension "PlantUML"**:
   - VSCode: Search `jebbs.plantuml`
   - Cursor: Search `jebbs.plantuml`

2. **Cài Graphviz** (cần thiết để render):
   - **Windows**: Download từ https://graphviz.org/download/
   - Thêm `dot` vào PATH

3. **Render sơ đồ**:
   - Mở file `.puml`
   - Nhấn `Alt+D` để preview
   - Hoặc Right-click → "Preview Current Diagram"

### Cách 2: Online PlantUML Viewer

1. Truy cập: https://www.plantuml.com/plantuml/uml/
2. Paste nội dung file `.puml` vào
3. Copy URL hoặc tải ảnh về

### Cách 3: Docker

```bash
docker run -d -p 8080:8080 plantuml/plantuml-server:jetty
# Truy cập http://localhost:8080
```

---

## 📋 Nội dung chi tiết các sơ đồ

### 1. Sơ đồ Use Case (`usecase_quizedu.puml`)

**Actors**:
- **Student**: Người dùng học sinh/sinh viên
- **Admin**: Quản trị viên hệ thống
- **AI System**: Hệ thống AI (Gemini 2.0 Flash)
- **Google Auth**: Xác thực Google

**Packages/Chức năng**:
| Package | Use Cases |
|---------|-----------|
| Authentication | Register Account, Login, Google Login, Logout |
| Subject Management | Create Subject, View Subjects, Update Subject, Delete Subject |
| Document Management | Upload Document, View Documents, Delete Document |
| AI Assistant | Summarize Document, Generate Flashcards, Generate Quiz |
| Quiz and Exam | Start Exam, Answer Questions, Submit Exam, View Result, View History |
| Profile Management | View Profile, Update Profile, Upload Avatar, Change Password |
| Dashboard and Stats | View Student Dashboard, View Admin Dashboard, View Stats by Subject, View Stats by Document |
| Contact and Support | Send Contact, View Contacts, Respond Contact |
| Data Export | Request Export, Process Export, Send Export Email, View Export Requests |
| User Management | View All Users, View User Detail, Toggle User Lock |

---

### 2. Sơ đồ Class (`class_diagram_quizedu.puml`)

**Entity Classes** (10):
| Class | Mô tả |
|-------|-------|
| User | Người dùng (id, email, password, fullName, avatarUrl, gender, dateOfBirth, role, createdAt, locked) |
| Subject | Môn học (id, name, description, createdAt) |
| Document | Tài liệu (id, fileName, fileType, fileSize, filePath, content, contentSummary, contentKeywords, createdAt) |
| Quiz | Bài quiz (id, questionCount, difficulty, createdAt) |
| Question | Câu hỏi (id, content, explanation) |
| Choice | Lựa chọn (id, content, correct) |
| Exam | Bài thi (id, totalQuestions, correctCount, score, status, startedAt, submittedAt) |
| ExamAnswer | Câu trả lời thi (id, correct) |
| Contact | Liên hệ (id, userName, email, subject, message, status, adminResponse, respondedAt, createdAt) |
| ExportRequest | Yêu cầu xuất dữ liệu (id, email, includeDocuments, includeQuizzes, includeHistory, includeStats, status, createdAt, processedAt) |

**Enums** (6):
| Enum | Values |
|------|--------|
| Role | STUDENT, ADMIN |
| User.Gender | MALE, FEMALE, OTHER |
| DifficultyLevel | EASY, MEDIUM, HARD |
| ExamStatus | IN_PROGRESS, SUBMITTED |
| ContactStatus | PENDING, RESPONDED, CLOSED |
| ExportStatus | PENDING, PROCESSING, COMPLETED, CANCELLED |

**DTO Request Classes** (12):
| Class | Fields |
|-------|--------|
| RegisterRequest | email, password, fullName |
| LoginRequest | email, password |
| GoogleLoginRequest | idToken |
| SubjectRequest | name, description |
| QuizRequest | documentId, questionCount, difficulty |
| SubmitExamRequest | examId, List<ExamAnswerRequest> |
| ExamAnswerRequest | questionId, selectedChoiceId |
| UpdateProfileRequest | fullName, gender, dateOfBirth |
| ChangePasswordRequest | currentPassword, newPassword |
| ContactCreateRequest | userName, email, subject, message |
| ExportRequestDto | email, includeDocuments, includeQuizzes, includeHistory, includeStats |

**DTO Response Classes** (18):
| Class | Mô tả |
|-------|-------|
| ApiResponse<T> | Generic wrapper (success, message, data) |
| AuthResponse | token, user |
| UserResponse | id, email, fullName, avatarUrl, gender, role, createdAt |
| UserListResponse | id, email, fullName, avatarUrl, role, locked, createdAt |
| SubjectResponse | id, name, description, createdAt, documentCount |
| DocumentResponse | id, fileName, fileType, fileSize, contentSummary, createdAt |
| QuizResponse | id, documentId, questionCount, difficulty, createdAt, questions |
| QuestionResponse | id, content, explanation, choices |
| ChoiceResponse | id, content, correct |
| ExamResponse | id, totalQuestions, correctCount, score, status, startedAt, submittedAt, questions, answers |
| ExamAnswerResponse | questionId, selectedChoiceId, correct, correctChoiceId |
| SummaryResult | overview, keyPoints (List<String>) |
| FlashcardResult | flashcards (List<FlashcardItem>) |
| FlashcardItem | question, answer (JsonNode) |
| QuizResult | questions (List<QuestionItem>) |
| QuestionItem | content, explanation, choices (List<ChoiceItem>) |
| ChoiceItem | content, correct |
| ContactResponse | id, userName, email, subject, message, status, adminResponse, respondedAt, createdAt |
| ExportRequestResponse | id, email, includeDocuments, includeQuizzes, includeHistory, includeStats, status, createdAt, processedAt |
| StudentDashboardResponse | totalSubjects, totalDocuments, totalQuizzes, totalExams, averageScore |
| AdminDashboardResponse | totalUsers, totalSubjects, totalDocuments, totalExams, monthlyStats |
| SubjectStatsResponse | subjectId, subjectName, documentCount, examCount, averageScore |
| DocumentStatsResponse | documentId, fileName, examCount, averageScore |

**Controllers** (12):
| Controller | Endpoints |
|------------|-----------|
| AuthController | /api/auth - register, login, google |
| UserController | /api/users - profile, avatar, change-password |
| SubjectController | /api/subjects - create, getAll, update, delete |
| AdminSubjectController | /api/admin/subjects - getAll, update, delete |
| DocumentController | /api/subjects/{id}/documents - upload, getAll, delete, batchDelete |
| QuizController | /api/quiz - generate, getQuiz, getAll, delete |
| ExamController | /api/exam - start, submit, result, history |
| AIController | /api/ai - summarize, flashcards |
| ContactController | /api/contact - createContact |
| ExportRequestController | /api/export - createExportRequest |
| DashboardController | /api/dashboard - student, admin, stats-by-subject, stats-by-document |
| AdminController | /api/admin - users, contacts, export-requests, toggle-lock, export |

**Services** (12):
| Service | Methods |
|---------|---------|
| AuthService | register, login, googleLogin |
| UserService | getProfile, updateProfile, uploadAvatar, changePassword |
| SubjectService | create, getAll, update, delete |
| DocumentService | upload, getAll, getById, delete |
| QuizService | generate, getQuiz, getAll, delete |
| ExamService | start, submit, getResult, getHistory |
| AIService | summarize, generateFlashcards |
| GeminiService | callGemini, generateQuiz, summarizeContent, generateFlashcards |
| ContactService | createContact |
| ExportRequestService | createRequest |
| DashboardService | getStudentDashboard, getAdminDashboard, getStatsBySubject, getStatsByDocument |
| AdminService | getAllUsers, getUserDetail, getContacts, respondContact, getExportRequests, processExportRequest, sendExportEmail, sendAllPendingExports, toggleUserLock, exportUserData, exportAllData |

**Security Classes**:
- JwtUtil, JwtAuthenticationFilter, SecurityConfig, RateLimitingFilter, CorsFilter

**Config Classes**:
- FirebaseConfig, SwaggerConfig, WebMvcConfig

**Exception Classes**:
- GlobalExceptionHandler, AiException

**Init Classes**:
- DataInitializer

---

### 3. Sơ đồ ERD (`erd_quizedu.puml`)

**Tables** (10):
| Table | PK | FK | Mô tả |
|-------|----|----|--------|
| users | id | - | Người dùng |
| subjects | id | user_id | Môn học |
| documents | id | subject_id, user_id | Tài liệu |
| quizzes | id | document_id, user_id | Bài quiz |
| questions | id | quiz_id | Câu hỏi |
| choices | id | question_id | Lựa chọn |
| exams | id | quiz_id, user_id | Bài thi |
| exam_answers | id | exam_id, question_id, selected_choice_id | Câu trả thi |
| contacts | id | (user không FK) | Liên hệ |
| export_requests | id | user_id | Yêu cầu xuất |

**Relationships**:
- users 1:N subjects
- users 1:N documents
- subjects 1:N documents
- documents 1:N quizzes
- users 1:N quizzes
- quizzes 1:N questions
- questions 1:N choices
- users 1:N exams
- quizzes 1:N exams
- exams 1:N exam_answers
- questions 1:N exam_answers
- choices 0..1 exam_answers (selected_choice)
- users 1:N export_requests

---

### 4. Sơ đồ Sequence - Auth (`sequence_auth.puml`)

**4.1 Register Account**:
1. Student fills register form (email, password, fullName)
2. Flutter validates input
3. POST /api/auth/register
4. AuthController → AuthService → UserService
5. Insert user to MySQL
6. Generate JWT token via JwtUtil
7. Return AuthResponse

**4.2 Login**:
1. Student enters email/password
2. POST /api/auth/login
3. AuthService verifies password (BCrypt)
4. Generate JWT token
5. Return AuthResponse
6. On failure: return 401 Unauthorized

**4.3 Google Login**:
1. Student clicks Google Sign-In
2. Flutter requests Google ID Token
3. POST /api/auth/google with token
4. Backend verifies with Firebase Auth
5. Find or create user
6. Generate JWT token

---

### 5. Sơ đồ Sequence - Quiz & Exam (`sequence_quiz_exam.puml`)

**5.1 Upload Document**:
1. Student selects PDF/DOCX file
2. Flutter extracts text from file
3. POST /api/subjects/{id}/documents
4. DocumentService saves to DB

**5.2 AI Summarize**:
1. Student clicks Summarize
2. GET /api/ai/summarize/{docId}
3. Check cache (contentSummary)
4. If not cached: Call GeminiService → Gemini API
5. Save result to DB (contentSummary, contentKeywords)
6. Return SummaryResult (overview, keyPoints)

**5.3 AI Generate Flashcards**:
1. Student clicks Generate Flashcards
2. GET /api/ai/flashcards/{docId}?count=8
3. Call GeminiService → Gemini API
4. Return FlashcardResult (flashcards with question, answer)

**5.4 AI Generate Quiz**:
1. Student configures (count, difficulty)
2. POST /api/quiz/generate
3. QuizService calls GeminiService → Gemini API
4. Parse JSON response → QuizResult (questions, choices, correct, explanation)
5. Insert quiz, questions, choices to DB
6. Return QuizResponse

**5.5 Start Exam**:
1. Student clicks Start Exam
2. POST /api/exam/start/{quizId}
3. Create exam record (IN_PROGRESS)
4. Return ExamResponse with questions

**5.6 Answer Questions**:
1. Student reads each question
2. Selects answer
3. Save locally (state management)

**5.7 Submit Exam**:
1. Timer expires or student clicks Submit
2. POST /api/exam/submit
3. ExamService calculates score
4. Update exam (SUBMITTED, score)
5. Return ExamResponse with results

**5.8 View Exam Result**:
1. GET /api/exam/result/{examId}
2. Return detailed exam with explanations

**5.9 View History**:
1. GET /api/exam/history
2. Return list of past exams

---

### 6. Sơ đồ Sequence - Admin & Dashboard (`sequence_admin_dashboard.puml`)

**6.1 View Student Dashboard**:
1. GET /api/dashboard/student
2. DashboardService aggregates stats
3. Return StudentDashboardResponse

**6.2 View Stats by Subject**:
1. GET /api/dashboard/student/stats-by-subject
2. Return List<SubjectStatsResponse>

**6.3 View Admin Dashboard**:
1. GET /api/dashboard/admin
2. Return AdminDashboardResponse with counts and monthly stats

**6.4 Admin Manage Users**:
1. GET /api/admin/users - View all users
2. PUT /api/admin/users/{id}/toggle-lock - Lock/unlock user

**6.5 Admin Manage Subjects**:
1. GET /api/admin/subjects - View all subjects
2. PUT /api/admin/subjects/{id} - Update subject
3. DELETE /api/admin/subjects/{id} - Delete subject

**6.6 Admin Manage Contacts**:
1. GET /api/admin/contacts - View all contacts
2. PUT /api/admin/contacts/{id}/respond - Respond to contact

**6.7 Student Send Contact**:
1. POST /api/contact - Submit contact form

**6.8 Student Request Export**:
1. POST /api/export/request - Request data export

**6.9 Admin Export Data**:
1. GET /api/admin/export/all - Export all data
2. GET /api/admin/export/user/{id} - Export single user data

**6.10 Admin Process Export Request**:
1. POST /api/admin/export-requests/{id}/process - Process export

---

## 💡 Mẹo cho báo cáo

### Chèn ảnh vào Word:
1. Render file `.puml` thành PNG/SVG
2. Trong Word: Insert → Pictures → Chọn file

### Kích thước khuyến nghị:
- Use Case: 2000x1500 px
- Class: 4000x2500 px (lớn vì nhiều class)
- ERD: 2500x2000 px
- Sequence: 2500x3500 px (tùy độ dài)

---

## 🔧 Troubleshooting

### Lỗi "Graphviz not found":
```bash
# Windows - Thêm vào PATH
setx PATH "%PATH%;C:\Program Files\Graphviz\bin"
```

### Lỗi PlantUML extension trong VSCode/Cursor:
1. Reload window (`Ctrl+Shift+P` → "Reload Window")
2. Kiểm tra Graphviz đã cài đặt đúng cách

### Render offline:
```bash
# Cài PlantUML locally
java -jar plantuml.jar -tpng diagram.puml
```
