DROP DATABASE IF EXISTS `high_school_banking_system_webpage`;

CREATE DATABASE high_school_banking_system_webpage
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE `high_school_banking_system_webpage`;

-- 이메일 검증
CREATE TABLE IF NOT EXISTS `email_verification` (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- 학교 테이블
CREATE TABLE IF NOT EXISTS school (
    school_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    school_name VARCHAR(30) NOT NULL,
    school_address VARCHAR(255) NOT NULL,
    school_contact_number VARCHAR(20) NOT NULL,
    school_code INT NOT NULL UNIQUE,
    school_email VARCHAR(30) NOT NULL,
    school_admin_username VARCHAR(50) UNIQUE NOT NULL,
    school_admin_password VARCHAR(255) NOT NULL
);

-- 과목 마스터 (전체 과목 목록)
CREATE TABLE IF NOT EXISTS `subject_master` (
    subject_master_id VARCHAR(30) PRIMARY KEY,
    subject_name VARCHAR(50) NOT NULL,
    subject_type ENUM('REQUIRED', 'ELECTIVE') NOT NULL,
    subject_affiliation ENUM('LIBERAL_ARTS', 'NATURAL_SCIENCES', 'COMMON') NOT NULL,
    available_grades VARCHAR(20) NOT NULL, -- 예: "1,2,3" 또는 "2,3"
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 교사
CREATE TABLE IF NOT EXISTS `teacher` (
    teacher_id VARCHAR(30) PRIMARY KEY,
    school_id BIGINT NOT NULL,
    teacher_username VARCHAR(50) UNIQUE NOT NULL,
    teacher_password VARCHAR(255) NOT NULL,
    teacher_name VARCHAR(30) NOT NULL,
    teacher_email VARCHAR(50) UNIQUE NOT NULL,
    teacher_phone_number VARCHAR(20) NOT NULL,
    teacher_subject VARCHAR(50) NOT NULL,
    teacher_birth_date DATE NOT NULL,
    teacher_status ENUM('PENDING', 'APPROVED', 'ON_LEAVE', 'RETIRED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES school(school_id)
);

-- 과목 (각 학교별 과목 신청)
CREATE TABLE IF NOT EXISTS `subject` (
    subject_id VARCHAR(30) PRIMARY KEY,
    school_id BIGINT NOT NULL,
    teacher_id VARCHAR(30) NOT NULL,
    subject_master_id VARCHAR(30) NOT NULL,
    subject_name VARCHAR(50) NOT NULL,
    subject_grade VARCHAR(10) NOT NULL,
    subject_semester VARCHAR(10) NOT NULL,
    subject_affiliation ENUM('LIBERAL_ARTS', 'NATURAL_SCIENCES', 'COMMON') NOT NULL,
    subject_status ENUM('APPROVED', 'PENDING', 'REJECTED') DEFAULT 'PENDING',
    subject_max_enrollment INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES school(school_id),
    FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id),
    FOREIGN KEY (subject_master_id) REFERENCES subject_master(subject_master_id)
);

-- 학생
CREATE TABLE IF NOT EXISTS `student` (
    student_id VARCHAR(30) PRIMARY KEY,
    school_id BIGINT NOT NULL,
    student_username VARCHAR(50) UNIQUE NOT NULL,
    student_password VARCHAR(255) NOT NULL,
    student_number VARCHAR(30) UNIQUE NOT NULL,
    student_name VARCHAR(20) NOT NULL,
    student_grade VARCHAR(10) NOT NULL,
    student_email VARCHAR(50) UNIQUE NOT NULL,
    student_phone_number VARCHAR(20) NOT NULL,
    student_birth_date DATE NOT NULL,
    student_affiliation ENUM('LIBERAL_ARTS', 'NATURAL_SCIENCES') NOT NULL,
    student_status ENUM('PENDING', 'APPROVED','REJECTED', 'GRADUATED') DEFAULT 'PENDING',
    student_admission_year YEAR NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES school(school_id)
);

-- 강의
CREATE TABLE IF NOT EXISTS `lecture` (
    lecture_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT NOT NULL,
    subject_id VARCHAR(30) NOT NULL,
    teacher_id VARCHAR(30) NOT NULL,
    lecture_day_of_week ENUM('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY') NOT NULL,
    lecture_period INT NOT NULL,
    lecture_allowed_grade VARCHAR(10) NOT NULL,
    lecture_max_enrollment INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subject(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id),
    FOREIGN KEY (school_id) REFERENCES school(school_id)
);

-- 수강 신청
CREATE TABLE IF NOT EXISTS `course_registration` (
    registration_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(30) NOT NULL,
    lecture_id BIGINT NOT NULL,
    course_registration_academic_year YEAR NOT NULL,
    course_registration_semester VARCHAR(10) NOT NULL,
    course_registration_approval_status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    course_registration_approval_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    academic_status ENUM('ENROLLED', 'COMPLETED', 'WITHDRAWN') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student(student_id),
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id)
);

-- 수강 이력
CREATE TABLE IF NOT EXISTS `course_history` (
    course_history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(30),
    lecture_id BIGINT,
    course_history_academic_year YEAR NOT NULL,
    course_history_semester VARCHAR(10) NOT NULL,
    course_history_score VARCHAR(10) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student(student_id),
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id)
);

-- 공지사항
CREATE TABLE IF NOT EXISTS `notice` (
    notice_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT NOT NULL,
    notice_title VARCHAR(255) NOT NULL,
    notice_content TEXT NOT NULL,
    notice_target_audience ENUM('ALL', 'STUDENT', 'TEACHER') NOT NULL,
    notice_start_date DATE NOT NULL,
    notice_end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES school(school_id)
);