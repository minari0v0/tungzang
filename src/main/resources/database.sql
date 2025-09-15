-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS tungzang CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE tungzang;

-- 사용자 테이블
CREATE TABLE IF NOT EXISTS users (
                                     id INT AUTO_INCREMENT PRIMARY KEY,
                                     username VARCHAR(50) NOT NULL UNIQUE,
                                     password VARCHAR(255) NOT NULL,
                                     name VARCHAR(50) NOT NULL,
                                     email VARCHAR(100) NOT NULL UNIQUE,
                                     department VARCHAR(100),
                                     student_id VARCHAR(20),
                                     is_admin BOOLEAN DEFAULT FALSE,
                                     grade VARCHAR(20) DEFAULT '새내기',
                                     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 강의 테이블
CREATE TABLE IF NOT EXISTS courses (
                                       id INT AUTO_INCREMENT PRIMARY KEY,
                                       name VARCHAR(100) NOT NULL,
                                       professor VARCHAR(50) NOT NULL,
                                       department VARCHAR(100) NOT NULL,
                                       department_id VARCHAR(50) NOT NULL,
                                       type VARCHAR(20) DEFAULT 'major',
                                       rating DOUBLE DEFAULT 0,
                                       evaluation_count INT DEFAULT 0,
                                       difficulty DOUBLE DEFAULT 0,
                                       homework DOUBLE DEFAULT 0,
                                       team_project BOOLEAN DEFAULT FALSE,
                                       exam_count INT DEFAULT 0,
                                       is_popular BOOLEAN DEFAULT FALSE,
                                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                       UNIQUE KEY course_unique (name, professor, department)
);

-- 강의 태그 테이블
CREATE TABLE IF NOT EXISTS course_tags (
                                           id INT AUTO_INCREMENT PRIMARY KEY,
                                           course_id INT NOT NULL,
                                           tag VARCHAR(50) NOT NULL,
                                           FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 강의 평가 테이블
CREATE TABLE IF NOT EXISTS evaluations (
                                           id INT AUTO_INCREMENT PRIMARY KEY,
                                           course_id INT NOT NULL,
                                           user_id INT NOT NULL,
                                           rating INT NOT NULL,
                                           difficulty INT NOT NULL,
                                           homework INT NOT NULL,
                                           course_type VARCHAR(20) NOT NULL,
                                           comment TEXT NOT NULL,
                                           features TEXT,
                                           team_project tinyint(1) DEFAULT 0,
                                           is_reported BOOLEAN DEFAULT FALSE,
                                           date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                           updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                           FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
                                           FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                                           UNIQUE KEY user_course_unique (user_id, course_id)
);


-- 강의 평가 특성 테이블
CREATE TABLE IF NOT EXISTS evaluation_features (
                                                   id INT AUTO_INCREMENT PRIMARY KEY,
                                                   evaluation_id INT NOT NULL,
                                                   feature VARCHAR(50) NOT NULL,
                                                   FOREIGN KEY (evaluation_id) REFERENCES evaluations(id) ON DELETE CASCADE
);

-- 게시글 테이블
CREATE TABLE IF NOT EXISTS posts (
                                     id INT AUTO_INCREMENT PRIMARY KEY,
                                     title VARCHAR(255) NOT NULL,
                                     content TEXT NOT NULL,
                                     category VARCHAR(50) NOT NULL,
                                     author_id INT NOT NULL,
                                     likes INT DEFAULT 0,
                                     comment_count INT DEFAULT 0,
                                     views INT DEFAULT 0,
                                     is_hot BOOLEAN DEFAULT FALSE,
                                     is_reported BOOLEAN DEFAULT FALSE,
                                     date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                     FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 댓글 테이블
CREATE TABLE IF NOT EXISTS comments (
                                        id INT AUTO_INCREMENT PRIMARY KEY,
                                        post_id INT NOT NULL,
                                        author_id INT NOT NULL,
                                        content TEXT NOT NULL,
                                        likes INT DEFAULT 0,
                                        is_reported BOOLEAN DEFAULT FALSE,
                                        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
                                        FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 시간표 강의 테이블
CREATE TABLE IF NOT EXISTS timetable_courses (
                                                 id INT AUTO_INCREMENT PRIMARY KEY,
                                                 user_id INT NOT NULL,
                                                 name VARCHAR(100) NOT NULL,
                                                 professor VARCHAR(50) NOT NULL,
                                                 day VARCHAR(10) NOT NULL,
                                                 start_time INT NOT NULL,
                                                 end_time INT NOT NULL,
                                                 location VARCHAR(100),
                                                 color VARCHAR(20) DEFAULT '#4f46e5',
                                                 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                                 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                                 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 게시글 좋아요 테이블
CREATE TABLE IF NOT EXISTS post_likes (
                                          id INT AUTO_INCREMENT PRIMARY KEY,
                                          post_id INT NOT NULL,
                                          user_id INT NOT NULL,
                                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                          FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
                                          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                                          UNIQUE KEY post_user_unique (post_id, user_id)
);

-- 댓글 좋아요 테이블
CREATE TABLE IF NOT EXISTS comment_likes (
                                             id INT AUTO_INCREMENT PRIMARY KEY,
                                             comment_id INT NOT NULL,
                                             user_id INT NOT NULL,
                                             created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                             FOREIGN KEY (comment_id) REFERENCES comments(id) ON DELETE CASCADE,
                                             FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                                             UNIQUE KEY comment_user_unique (comment_id, user_id)
);

-- reports 테이블이 없다면 생성
CREATE TABLE IF NOT EXISTS reports (
                                       id INT AUTO_INCREMENT PRIMARY KEY,
                                       content_type ENUM('post', 'comment', 'evaluation') NOT NULL,
                                       content_id INT NOT NULL,
                                       reporter_id INT NOT NULL,
                                       reason TEXT NOT NULL,
                                       report_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                       status ENUM('pending', 'resolved', 'ignored') DEFAULT 'pending',
                                       admin_id INT,
                                       admin_action VARCHAR(100),
                                       processed_at TIMESTAMP NULL,
                                       FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE,
                                       FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL,
                                       UNIQUE KEY unique_report (content_type, content_id, reporter_id),
                                       INDEX idx_content (content_type, content_id),
                                       INDEX idx_status (status)
);

-- 테스트용 신고 데이터 삽입 (선택사항)
-- 게시글 신고 테스트 데이터
INSERT IGNORE INTO reports (content_type, content_id, reporter_id, reason) VALUES
                                                                               ('post', 1, 2, '부적절한 내용'),
                                                                               ('post', 2, 3, '스팸성 게시글');

-- 댓글 신고 테스트 데이터
INSERT IGNORE INTO reports (content_type, content_id, reporter_id, reason) VALUES
                                                                               ('comment', 1, 3, '욕설 및 비방'),
                                                                               ('comment', 2, 2, '광고성 댓글');

-- 강의평가 신고 테스트 데이터
INSERT IGNORE INTO reports (content_type, content_id, reporter_id, reason) VALUES
                                                                               ('evaluation', 1, 3, '허위 정보'),
                                                                               ('evaluation', 2, 2, '부적절한 표현');

-- 신고된 콘텐츠의 is_reported 플래그 업데이트
UPDATE posts SET is_reported = 1 WHERE id IN (
    SELECT DISTINCT content_id FROM reports WHERE content_type = 'post' AND status = 'pending'
);

UPDATE comments SET is_reported = 1 WHERE id IN (
    SELECT DISTINCT content_id FROM reports WHERE content_type = 'comment' AND status = 'pending'
);

UPDATE evaluations SET is_reported = 1 WHERE id IN (
    SELECT DISTINCT content_id FROM reports WHERE content_type = 'evaluation' AND status = 'pending'
);

-- 신고 사유 테이블 (선택사항 - 드롭다운용)
CREATE TABLE IF NOT EXISTS report_reasons (
                                              id INT AUTO_INCREMENT PRIMARY KEY,
                                              target_type ENUM('post', 'comment', 'evaluation') NOT NULL,
                                              reason_code VARCHAR(50) NOT NULL,
                                              reason_text VARCHAR(100) NOT NULL,
                                              is_active TINYINT(1) DEFAULT 1,
                                              sort_order INT DEFAULT 0
);

-- 샘플 데이터 삽입
-- 관리자 계정 (비밀번호: admin123)
INSERT INTO users (username, password, name, email, is_admin) VALUES
    ('admin', '$2a$10$hKDVYxLefVHV/vtuPhWD3OigtRyOykRLDdUAp80Z1crSoS1lFqaFS', '관리자', 'admin@example.com', TRUE);

-- 일반 사용자 계정 (비밀번호: password123)
INSERT INTO users (username, password, name, email, department, student_id) VALUES
                                                                                ('user1', '$2a$10$hKDVYxLefVHV/vtuPhWD3OigtRyOykRLDdUAp80Z1crSoS1lFqaFS', '홍길동', 'user1@example.com', '컴퓨터공학과', '2020123456'),
                                                                                ('user2', '$2a$10$hKDVYxLefVHV/vtuPhWD3OigtRyOykRLDdUAp80Z1crSoS1lFqaFS', '김철수', 'user2@example.com', '경영학과', '2021234567'),
                                                                                ('user3', '$2a$10$hKDVYxLefVHV/vtuPhWD3OigtRyOykRLDdUAp80Z1crSoS1lFqaFS', '이영희', 'user3@example.com', '심리학과', '2019345678');

-- 샘플 강의 데이터
INSERT INTO courses (name, professor, department, department_id, type, rating, evaluation_count, difficulty, homework, team_project, exam_count, is_popular) VALUES
                                                                                                                                                                 ('컴퓨터 프로그래밍', '김교수', '컴퓨터공학과', 'cs', 'major', 4.7, 128, 3.5, 4.2, TRUE, 2, TRUE),
                                                                                                                                                                 ('경영학 원론', '이교수', '경영학과', 'business', 'major', 4.5, 95, 2.8, 3.0, TRUE, 3, TRUE),
                                                                                                                                                                 ('심리학 개론', '박교수', '심리학과', 'psychology', 'general', 4.8, 87, 2.2, 2.5, FALSE, 2, TRUE),
                                                                                                                                                                 ('미적분학', '최교수', '수학과', 'math', 'major', 4.2, 76, 4.5, 4.8, FALSE, 4, FALSE),
                                                                                                                                                                 ('데이터베이스 개론', '정교수', '컴퓨터공학과', 'cs', 'major', 4.4, 65, 3.8, 4.0, TRUE, 2, FALSE);

-- 샘플 강의 태그
INSERT INTO course_tags (course_id, tag) VALUES
                                             (1, '코딩'), (1, '실습'), (1, '팀프로젝트'),
                                             (2, '이론'), (2, '발표'), (2, '토론'),
                                             (3, '교양'), (3, '이론'), (3, '쉬움'),
                                             (4, '어려움'), (4, '증명'), (4, '계산'),
                                             (5, 'SQL'), (5, '프로젝트'), (5, '실습');

-- 샘플 강의 평가
INSERT INTO evaluations (course_id, user_id, rating, difficulty, homework, course_type, comment) VALUES
                                                                                                     (1, 2, 4, 4, 4, 'major', '강의 내용이 알차고 교수님이 열정적으로 가르치십니다. 과제는 조금 많은 편이지만 배우는 것이 많습니다.'),
                                                                                                     (2, 3, 5, 3, 3, 'major', '정말 좋은 강의입니다. 실무에 도움이 많이 될 것 같아요. 교수님의 설명이 명확하고 이해하기 쉽습니다.'),
                                                                                                     (3, 2, 3, 5, 5, 'major', '강의 자체는 좋지만 과제가 너무 많고 시험이 어려운 편입니다. 시간 투자를 많이 해야 하는 과목입니다.');

-- 샘플 강의 평가 특성
INSERT INTO evaluation_features (evaluation_id, feature) VALUES
                                                             (1, '팀 프로젝트'), (1, '출석 중요'), (1, '실습 위주'),
                                                             (2, '실습 위주'), (2, '시험 비중 높음'),
                                                             (3, '시험 비중 높음'), (3, '과제 많음');

-- 샘플 게시글
INSERT INTO posts (title, content, category, author_id, likes, comment_count, views, is_hot) VALUES
                                                                                                 ('기말고사 시험 범위 공유합니다', '이번 학기 데이터베이스 개론 기말고사 범위입니다. 9장부터 15장까지이며, 특히 정규화와 트랜잭션 부분이 중요하다고 합니다.', 'info', 2, 42, 2, 230, TRUE),
                                                                                                 ('컴공과 졸업요건 변경 소식', '2024학년도부터 컴퓨터공학과 졸업요건이 변경된다고 합니다. 필수 과목에 인공지능 개론이 추가되었습니다.', 'info', 3, 38, 1, 185, TRUE),
                                                                                                 ('알고리즘 스터디 모집합니다', '다음 학기 코딩 테스트 준비를 위한 알고리즘 스터디를 모집합니다. 주 2회 온라인으로 진행할 예정이며, 백준 문제를 함께 풀어볼 계획입니다.', 'study', 2, 29, 0, 142, TRUE);

-- 샘플 댓글
INSERT INTO comments (post_id, author_id, content, likes) VALUES
                                                              (1, 3, '정보 공유 감사합니다! 혹시 참고할만한 예상 문제 있을까요?', 5),
                                                              (1, 2, '지난 학기 시험 문제와 유사할 것 같아요. 작년 기출문제도 참고하시면 좋을 것 같습니다.', 3),
                                                              (2, 2, '혹시 추천하는 참고 자료가 있을까요?', 2);

-- 샘플 시간표 강의
INSERT INTO timetable_courses (user_id, name, professor, day, start_time, end_time, location, color) VALUES
                                                                                                         (2, '데이터베이스 개론', '김교수', '월', 9, 12, '공학관 305호', '#4f46e5'),
                                                                                                         (2, '알고리즘 분석', '이교수', '화', 13, 15, '공학관 401호', '#0891b2'),
                                                                                                         (2, '인공지능 입문', '박교수', '목', 15, 18, '과학관 202호', '#ca8a04');

-- 등급 업데이트를 위한 저장 프로시저 생성 최종 버전임
-- 디버깅용 로그 테이블 생성
CREATE TABLE IF NOT EXISTS grade_update_log (
                                                id INT AUTO_INCREMENT PRIMARY KEY,
                                                user_id INT,
                                                old_grade VARCHAR(20),
                                                new_grade VARCHAR(20),
                                                total_activity INT,
                                                evaluation_count INT DEFAULT 0,
                                                post_count INT DEFAULT 0,
                                                comment_count INT DEFAULT 0,
                                                timetable_count INT DEFAULT 0,
                                                update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE PROCEDURE UpdateUserGrade(IN p_user_id INT)
BEGIN
    DECLARE v_evaluation_count INT DEFAULT 0;
    DECLARE v_post_count INT DEFAULT 0;
    DECLARE v_comment_count INT DEFAULT 0;
    DECLARE v_timetable_count INT DEFAULT 0;
    DECLARE v_total_activity INT DEFAULT 0;
    DECLARE v_new_grade VARCHAR(20) DEFAULT '새내기';
    DECLARE v_old_grade VARCHAR(20) DEFAULT '새내기';
    DECLARE v_is_admin BOOLEAN DEFAULT FALSE;

    -- 현재 사용자 정보 조회
    SELECT is_admin, grade INTO v_is_admin, v_old_grade
    FROM users
    WHERE id = p_user_id;

    -- 관리자면 마스터 등급으로 설정하고 종료
    IF v_is_admin = TRUE THEN
        UPDATE users SET grade = '마스터' WHERE id = p_user_id;
        INSERT INTO grade_update_log (user_id, old_grade, new_grade, total_activity)
        VALUES (p_user_id, v_old_grade, '마스터', 999);
    ELSE
        -- 각 활동별 개수 조회 (올바른 컬럼명 사용)

        -- evaluations 테이블: user_id 사용
        SELECT COALESCE(COUNT(*), 0) INTO v_evaluation_count
        FROM evaluations
        WHERE user_id = p_user_id;

        -- posts 테이블: author_id 사용
        SELECT COALESCE(COUNT(*), 0) INTO v_post_count
        FROM posts
        WHERE author_id = p_user_id;

        -- comments 테이블: author_id 사용
        SELECT COALESCE(COUNT(*), 0) INTO v_comment_count
        FROM comments
        WHERE author_id = p_user_id;

        -- timetable_courses 테이블: user_id 사용
        SELECT COALESCE(COUNT(*), 0) INTO v_timetable_count
        FROM timetable_courses
        WHERE user_id = p_user_id;

        -- 총 활동 수 계산
        SET v_total_activity = v_evaluation_count + v_post_count + v_comment_count + v_timetable_count;

        -- 등급 결정 로직
        IF v_total_activity >= 100 THEN
            SET v_new_grade = '마스터';
        ELSEIF v_total_activity >= 50 THEN
            SET v_new_grade = '전문가';
        ELSEIF v_total_activity >= 20 THEN
            SET v_new_grade = '숙련자';
        ELSEIF v_total_activity >= 5 THEN
            SET v_new_grade = '초급자';
        ELSE
            SET v_new_grade = '새내기';
        END IF;

        -- 로그 기록
        INSERT INTO grade_update_log (
            user_id, old_grade, new_grade, total_activity,
            evaluation_count, post_count, comment_count, timetable_count
        ) VALUES (
                     p_user_id, v_old_grade, v_new_grade, v_total_activity,
                     v_evaluation_count, v_post_count, v_comment_count, v_timetable_count
                 );

        -- 등급 업데이트
        UPDATE users SET grade = v_new_grade WHERE id = p_user_id;
    END IF;

END //

DELIMITER ;


-- 모든 관리자 계정 등급 즉시 업데이트
UPDATE users SET grade = '마스터' WHERE is_admin = TRUE;

-- 업데이트 결과 확인
SELECT id, username, name, grade, is_admin,
       (SELECT COUNT(*) FROM evaluations WHERE user_id = users.id) as eval_count,
       (SELECT COUNT(*) FROM posts WHERE author_id = users.id) as post_count,
       (SELECT COUNT(*) FROM comments WHERE author_id = users.id) as comment_count,
       (SELECT COUNT(*) FROM timetable_courses WHERE user_id = users.id) as timetable_count,
       CASE WHEN is_admin = TRUE THEN '👑 관리자' ELSE '일반 사용자' END as user_type
FROM users
ORDER BY is_admin DESC, grade DESC, id;
