-- Quiz EduTech AI — Database Script
-- MySQL 8.0+
-- Run this script to initialize the database

CREATE DATABASE IF NOT EXISTS edutech_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE edutech_db;

-- ─── Users ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  email      VARCHAR(255) NOT NULL UNIQUE,
  password   VARCHAR(255) NOT NULL,
  full_name  VARCHAR(255) NOT NULL,
  role       ENUM('STUDENT','ADMIN') NOT NULL DEFAULT 'STUDENT',
  locked     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ─── Subjects ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS subjects (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(255) NOT NULL,
  description TEXT,
  user_id     BIGINT NOT NULL,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_subject_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ─── Documents ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS documents (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  file_name   VARCHAR(255) NOT NULL,
  file_type   VARCHAR(20)  NOT NULL,
  file_size   BIGINT       NOT NULL,
  file_path   VARCHAR(500) NOT NULL,
  content     LONGTEXT,
  subject_id  BIGINT NOT NULL,
  user_id     BIGINT NOT NULL,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_document_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
  CONSTRAINT fk_document_user    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE
);

-- ─── Quizzes ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS quizzes (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  question_count INT          NOT NULL,
  difficulty     ENUM('EASY','MEDIUM','HARD') NOT NULL DEFAULT 'MEDIUM',
  document_id    BIGINT NOT NULL,
  user_id        BIGINT NOT NULL,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_quiz_document FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
  CONSTRAINT fk_quiz_user     FOREIGN KEY (user_id)     REFERENCES users(id)     ON DELETE CASCADE
);

-- ─── Questions ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS questions (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  content     TEXT NOT NULL,
  explanation TEXT,
  quiz_id     BIGINT NOT NULL,
  CONSTRAINT fk_question_quiz FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);

-- ─── Choices ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS choices (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  content     TEXT    NOT NULL,
  correct     BOOLEAN NOT NULL DEFAULT FALSE,
  question_id BIGINT  NOT NULL,
  CONSTRAINT fk_choice_question FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- ─── Exams ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS exams (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  status          ENUM('IN_PROGRESS','COMPLETED') NOT NULL DEFAULT 'IN_PROGRESS',
  total_questions INT    NOT NULL DEFAULT 0,
  correct_count   INT    NOT NULL DEFAULT 0,
  score           DOUBLE NOT NULL DEFAULT 0,
  started_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  submitted_at    DATETIME,
  quiz_id         BIGINT NOT NULL,
  user_id         BIGINT NOT NULL,
  CONSTRAINT fk_exam_quiz FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE,
  CONSTRAINT fk_exam_user FOREIGN KEY (user_id) REFERENCES users(id)   ON DELETE CASCADE
);

-- ─── Exam Answers ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS exam_answers (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  exam_id     BIGINT NOT NULL,
  question_id BIGINT NOT NULL,
  choice_id   BIGINT NOT NULL,
  CONSTRAINT fk_answer_exam     FOREIGN KEY (exam_id)     REFERENCES exams(id)     ON DELETE CASCADE,
  CONSTRAINT fk_answer_question FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
  CONSTRAINT fk_answer_choice   FOREIGN KEY (choice_id)   REFERENCES choices(id)   ON DELETE CASCADE
);

-- ─── Default Admin ────────────────────────────────────────────────────────────
-- Password: Admin@123 (BCrypt encoded)
INSERT IGNORE INTO users (email, password, full_name, role)
VALUES (
  'admin@edutech.ai',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh7y',
  'Administrator',
  'ADMIN'
);
