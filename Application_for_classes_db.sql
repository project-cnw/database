DROP DATABASE IF EXISTS `high_school_banking_system_webpage`;

CREATE DATABASE high_school_banking_system_webpage
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE `high_school_banking_system_webpage`;

-- 이메일 검증
CREATE TABLE IF NOT EXISTS `email_verification` (
    email_verification_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email_verification_email VARCHAR(255) NOT NULL,
    email_verification_token VARCHAR(255) NOT NULL,
    email_verification_code VARCHAR(10) NOT NULL,
    email_verification_expires_at DATETIME NOT NULL,
    email_verification_is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 학교 테이블
CREATE TABLE IF NOT EXISTS school (
    school_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    school_name VARCHAR(30) NOT NULL,
    school_address VARCHAR(255) NOT NULL,
    school_contact_number VARCHAR(20) NOT NULL,
    school_code INT UNIQUE NOT NULL,
    school_email VARCHAR(30) UNIQUE NOT NULL,
    school_admin_username VARCHAR(50) UNIQUE NOT NULL,
    school_admin_password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 관리자
CREATE TABLE IF NOT EXISTS `admin` (
	admin_id BIGINT PRIMARY KEY,
    school_id BIGINT NOT NULL,
    admin_name VARCHAR(30) NOT NULL,
    admin_username VARCHAR(50) UNIQUE NOT NULL,
    admin_password VARCHAR(255) NOT NULL,
    admin_email VARCHAR(50) UNIQUE NOT NULL,
    admin_birth_date DATE NOT NULL,
    admin_phone_number VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY(school_id) REFERENCES school(school_id)
);

-- 교사
CREATE TABLE IF NOT EXISTS `teacher` (
    teacher_id BIGINT AUTO_INCREMENT PRIMARY KEY,
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

-- 과목 마스터 (전체 과목 목록)
CREATE TABLE IF NOT EXISTS `subject_master` (
    subject_master_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(30) UNIQUE NOT NULL,
    subject_name VARCHAR(50) NOT NULL,
    subject_type ENUM('REQUIRED', 'ELECTIVE') NOT NULL,
    subject_affiliation ENUM('LIBERAL_ARTS', 'NATURAL_SCIENCES', 'COMMON') NOT NULL,
    available_grades VARCHAR(20) NOT NULL,
    credits DECIMAL(2,1) NOT NULL DEFAULT 3.0,
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 과목 (각 학교별 과목 신청)
CREATE TABLE IF NOT EXISTS `subject` (
    subject_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT NOT NULL,
    teacher_id BIGINT NOT NULL,
    subject_master_id BIGINT NOT NULL,
    subject_grade VARCHAR(10) NOT NULL,
    subject_status ENUM('APPROVED', 'PENDING', 'REJECTED') DEFAULT 'PENDING',
    subject_max_enrollment INT NOT NULL,
    subject_semester ENUM('1학기', '2학기') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES school(school_id),
    FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id),
    FOREIGN KEY (subject_master_id) REFERENCES subject_master(subject_master_id)
);

-- 학생
CREATE TABLE IF NOT EXISTS `student` (
    student_id BIGINT AUTO_INCREMENT PRIMARY KEY,
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
    total_credits DECIMAL(5,1) DEFAULT 192.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES school(school_id)
);

-- 강의
CREATE TABLE IF NOT EXISTS `lecture` (
    lecture_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT NOT NULL,
    subject_id BIGINT NOT NULL,
    teacher_id BIGINT NOT NULL,
    lecture_name VARCHAR(100) NOT NULL,
    lecture_code VARCHAR(30) NOT NULL,
    academic_year YEAR NOT NULL DEFAULT 2025,
    semester ENUM('1학기', '2학기') NOT NULL DEFAULT '1학기',
    lecture_day_of_week ENUM('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY') NOT NULL,
    lecture_period INT NOT NULL,
    lecture_allowed_grade VARCHAR(10) NOT NULL,
    lecture_max_enrollment INT NOT NULL,
    lecture_current_enrollment INT DEFAULT 0,
    classroom VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subject(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id),
    FOREIGN KEY (school_id) REFERENCES school(school_id)
);

-- 수강 신청
CREATE TABLE IF NOT EXISTS `course_registration` (
    registration_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    lecture_id BIGINT NOT NULL,
    course_registration_academic_year YEAR NOT NULL,
    registration_status ENUM('CART', 'APPLIED', 'APPROVED', 'CANCELLED') DEFAULT 'CART',
    course_registration_semester ENUM('1학기', '2학기') NOT NULL DEFAULT '1학기',
    course_registration_approval_status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    course_registration_approval_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    academic_status ENUM('ENROLLED', 'COMPLETED', 'NOT_ENROLLED') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student(student_id),
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id)
);

-- 수강 이력
CREATE TABLE IF NOT EXISTS `course_history` (
    course_history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    lecture_id BIGINT NOT NULL,
    course_history_academic_year YEAR NOT NULL,
    course_history_semester ENUM('1학기', '2학기') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student(student_id),
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id)
);

-- 공지사항
CREATE TABLE IF NOT EXISTS `notice` (
    notice_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,
    author_type ENUM('ADMIN','TEACHER') NOT NULL,
    author_name VARCHAR(50) NOT NULL DEFAULT '교무처',
    notice_title VARCHAR(255) NOT NULL,
    notice_content TEXT NOT NULL,
    notice_target_audience ENUM('ALL', 'STUDENT', 'TEACHER') NOT NULL,
    notice_start_date DATE NOT NULL,
    notice_end_date DATE NOT NULL,
    notice_view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES school(school_id)
);

-- 문의사항
CREATE TABLE IF NOT EXISTS `inquiry` (
	inquiry_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT NOT NULL,
    inquiry_title VARCHAR(255) NOT NULL,
    inquiry_content TEXT NOT NULL,
    inquiry_author_type ENUM('STUDENT', 'TEACHER') NOT NULL,
    inquiry_author_id BIGINT NOT NULL,
    inquiry_status ENUM('NEW', 'IN_PROGRESS', 'CLOSED') DEFAULT 'NEW',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY(school_id) REFERENCES school(school_id)
);

INSERT INTO school (
    school_code,
    school_name,
    school_address,
    school_contact_number,
    school_email,
    school_admin_username,
    school_admin_password
) VALUES
(1001, '부산 코딩고등학교', '부산광역시 코딩구 코딩로 1', '051-123-4567', 'coding@school.com', 'admincoding', 'password1'),
(1002, '부산 컴퓨터고등학교', '부산광역시 컴퓨터구 컴퓨터로 2', '051-234-5678', 'computer@school.com', 'admincomputer', 'password2'),
(1003, '부산 아이티고등학교', '부산광역시 아이티구 아이티로 3', '051-345-6789', 'it@school.com', 'adminit', 'password3'),
(1004, '부산 자바고등학교', '부산광역시 자바구 자바로 4', '051-456-7890', 'java@school.com','adminjava',  'password4'),
(1005, '부산 백엔드 고등학교', '부산광역시 백엔드구 백엔드로 5', '051-567-8901', 'backend@school.com','adminbackend', 'password5');

-- 과목 전체 목록 (학년별로 분류)
INSERT INTO subject_master (subject_code, subject_name, subject_type, subject_affiliation, available_grades, credits, description) VALUES

-- ==================== 1학년 과목 ====================
-- 1학년 필수과목
('KOR001', '국어', 'REQUIRED', 'COMMON', '1', 3.0, '1학년 기본 국어'),
('MATH001', '수학', 'REQUIRED', 'COMMON', '1', 3.0, '1학년 기본 수학'),
('ENG001', '영어', 'REQUIRED', 'COMMON', '1', 3.0, '1학년 기본 영어'),
('SOC001', '통합사회', 'REQUIRED', 'COMMON', '1', 3.0, '1학년 사회 통합 과목'),
('SCI001', '통합과학', 'REQUIRED', 'COMMON', '1', 3.0, '1학년 과학 통합 과목'),
('PE001', '체육', 'REQUIRED', 'COMMON', '1', 3.0, '1학년 체육'),

-- 1학년 선택과목
('TECH001', '기술·가정', 'ELECTIVE', 'COMMON', '1', 3.0, '1학년 기술과 가정'),
('ART001', '음악', 'ELECTIVE', 'COMMON', '1', 3.0, '1학년 음악 교육'),
('ART002', '미술', 'ELECTIVE', 'COMMON', '1', 3.0, '1학년 미술 교육'),
('TECH002', '정보', 'ELECTIVE', 'COMMON', '1', 3.0, '1학년 컴퓨터 정보'),
('CUL005', '보건', 'ELECTIVE', 'COMMON', '1', 3.0, '1학년 보건교육'),

-- ==================== 2학년 과목 ====================
-- 2학년 필수과목 (공통)
('KOR011', '화법과 작문', 'REQUIRED', 'COMMON', '2', 3.0, '2학년 말하기와 글쓰기'),
('KOR012', '독서', 'REQUIRED', 'COMMON', '2', 3.0, '2학년 독서 능력 향상'),
('MATH011', '수학Ⅰ', 'REQUIRED', 'COMMON', '2', 3.0, '2학년 수학 1단계'),
('MATH012', '수학Ⅱ', 'REQUIRED', 'COMMON', '2', 3.0, '2학년 수학 2단계'),
('ENG011', '영어Ⅰ', 'REQUIRED', 'COMMON', '2', 3.0, '2학년 영어 심화'),
('SOC011', '한국사', 'REQUIRED', 'COMMON', '2', 3.0, '2학년 한국사'),
('PE011', '체육', 'REQUIRED', 'COMMON', '2', 3.0, '2학년 체육'),

-- 2학년 선택과목 (문과)
('SOC021', '세계사', 'ELECTIVE', 'LIBERAL_ARTS', '2', 3.0, '2학년 세계 역사'),
('SOC022', '동아시아사', 'ELECTIVE', 'LIBERAL_ARTS', '2', 3.0, '2학년 동아시아 역사'),
('SOC023', '경제', 'ELECTIVE', 'LIBERAL_ARTS', '2', 3.0, '2학년 경제학 기초'),
('SOC024', '정치와 법', 'ELECTIVE', 'LIBERAL_ARTS', '2', 3.0, '2학년 정치학과 법학'),
('SOC025', '사회·문화', 'ELECTIVE', 'LIBERAL_ARTS', '2', 3.0, '2학년 사회학과 문화인류학'),

-- 2학년 선택과목 (이과)
('SCI021', '물리학Ⅰ', 'ELECTIVE', 'NATURAL_SCIENCES', '2', 3.0, '2학년 물리학 기초'),
('SCI022', '화학Ⅰ', 'ELECTIVE', 'NATURAL_SCIENCES', '2', 3.0, '2학년 화학 기초'),
('SCI023', '생명과학Ⅰ', 'ELECTIVE', 'NATURAL_SCIENCES', '2', 3.0, '2학년 생명과학 기초'),
('SCI024', '지구과학Ⅰ', 'ELECTIVE', 'NATURAL_SCIENCES', '2', 3.0, '2학년 지구과학 기초'),
('MATH021', '확률과 통계', 'ELECTIVE', 'NATURAL_SCIENCES', '2', 3.0, '2학년 확률론과 통계학'),
('MATH022', '미적분', 'ELECTIVE', 'NATURAL_SCIENCES', '2', 3.0, '2학년 미분과 적분'),

-- 2학년 공통 선택과목
('FOR021', '중국어Ⅰ', 'ELECTIVE', 'COMMON', '2', 3.0, '2학년 중국어 기초'),
('FOR022', '일본어Ⅰ', 'ELECTIVE', 'COMMON', '2', 3.0, '2학년 일본어 기초'),
('FOR023', '프랑스어Ⅰ', 'ELECTIVE', 'COMMON', '2', 3.0, '2학년 프랑스어 기초'),
('ENG021', '영어회화', 'ELECTIVE', 'COMMON', '2', 3.0, '2학년 영어 회화'),
('CAR021', '진로와 직업', 'ELECTIVE', 'COMMON', '2', 3.0, '2학년 진로 탐색'),
('CUL021', '철학', 'ELECTIVE', 'COMMON', '2', 3.0, '2학년 철학 개론'),
('CUL022', '심리학', 'ELECTIVE', 'COMMON', '2', 3.0, '2학년 심리학 개론'),

-- ==================== 3학년 과목 ====================
-- 3학년 필수과목
('KOR031', '문학', 'REQUIRED', 'COMMON', '3', 3.0, '3학년 한국 문학'),
('MATH031', '확률과 통계', 'REQUIRED', 'COMMON', '3', 3.0, '3학년 확률과 통계'),
('MATH032', '미적분', 'REQUIRED', 'COMMON', '3', 3.0, '3학년 미적분'),
('ENG031', '영어Ⅱ', 'REQUIRED', 'COMMON', '3', 3.0, '3학년 영어Ⅱ'),
('ENG032', '영어독해와 작문', 'REQUIRED', 'COMMON', '3', 3.0, '3학년 영어독해와 작문'),
('SOC031', '한국사', 'REQUIRED', 'COMMON', '3', 3.0, '3학년 한국사 심화'),
('PE031', '체육', 'REQUIRED', 'COMMON', '3', 3.0, '3학년 체육'),

-- 3학년 문과 심화과목
('KOR041', '언어와 매체', 'ELECTIVE', 'LIBERAL_ARTS', '3', 3.0, '3학년 언어학과 매체'),
('KOR042', '심화국어', 'ELECTIVE', 'LIBERAL_ARTS', '3', 3.0, '3학년 국어 심화과정'),
('SOC041', '세계사 심화', 'ELECTIVE', 'LIBERAL_ARTS', '3', 3.0, '3학년 세계사 심화'),
('SOC042', '경제 심화', 'ELECTIVE', 'LIBERAL_ARTS', '3', 3.0, '3학년 경제학 심화'),
('SOC043', '사회문제 탐구', 'ELECTIVE', 'LIBERAL_ARTS', '3', 3.0, '3학년 사회문제 분석'),

-- 3학년 이과 심화과목
('SCI041', '물리학Ⅱ', 'ELECTIVE', 'NATURAL_SCIENCES', '3', 3.0, '3학년 물리학 심화'),
('SCI042', '화학Ⅱ', 'ELECTIVE', 'NATURAL_SCIENCES', '3', 3.0, '3학년 화학 심화'),
('SCI043', '생명과학Ⅱ', 'ELECTIVE', 'NATURAL_SCIENCES', '3', 3.0, '3학년 생명과학 심화'),
('SCI044', '지구과학Ⅱ', 'ELECTIVE', 'NATURAL_SCIENCES', '3', 3.0, '3학년 지구과학 심화'),
('MATH041', '기하', 'ELECTIVE', 'NATURAL_SCIENCES', '3', 3.0, '3학년 기하학'),
('MATH042', '심화수학', 'ELECTIVE', 'NATURAL_SCIENCES', '3', 3.0, '3학년 수학 심화과정'),
('ADV041', '고급물리', 'ELECTIVE', 'NATURAL_SCIENCES', '3', 3.0, '3학년 물리 고급과정'),
('ADV042', '고급화학', 'ELECTIVE', 'NATURAL_SCIENCES', '3', 3.0, '3학년 화학 고급과정'),

-- 3학년 진로선택과목
('CAR041', '실용국어', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 실생활 국어'),
('CAR042', '실용수학', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 실생활 수학'),
('CAR043', '창의경영', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 창업과 경영'),
('CAR044', '사회봉사', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 사회봉사활동'),

-- 3학년 제2외국어 심화
('FOR041', '중국어Ⅱ', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 중국어 심화'),
('FOR042', '일본어Ⅱ', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 일본어 심화'),
('FOR043', '독일어Ⅰ', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 독일어 기초'),
('FOR044', '스페인어Ⅰ', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 스페인어 기초'),

-- 3학년 교양/예체능
('ENG041', '심화영어', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 영어 심화과정'),
('ENG042', '영미문학', 'ELECTIVE', 'LIBERAL_ARTS', '3', 3.0, '3학년 영미문학 개론'),
('ART041', '음악 창작', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 음악 창작'),
('ART042', '미술 창작', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 미술 창작'),
('CUL041', '교육학', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 교육학 개론'),
('CUL042', '환경과학', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 환경과학'),
('TECH041', '정보처리', 'ELECTIVE', 'COMMON', '3', 3.0, '3학년 고급 컴퓨터');

SELECT * FROM subject_master;