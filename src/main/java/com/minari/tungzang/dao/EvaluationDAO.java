package com.minari.tungzang.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.minari.tungzang.model.Course;
import com.minari.tungzang.model.Evaluation;
import com.minari.tungzang.util.DatabaseUtil;

public class EvaluationDAO {

    public List<Evaluation> getRecentEvaluations(int limit) {
        List<Evaluation> evaluations = new ArrayList<>();
        String sql = "SELECT e.*, c.name as course_name, c.professor, u.name as user_name " +
                "FROM evaluations e " +
                "JOIN courses c ON e.course_id = c.id " +
                "JOIN users u ON e.user_id = u.id " +
                "ORDER BY e.date DESC LIMIT ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limit);
            System.out.println("DEBUG: 최근 평가 조회 SQL: " + sql + ", 파라미터: " + limit);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Evaluation evaluation = mapResultSetToEvaluation(rs);
                    evaluation.setCourseName(rs.getString("course_name"));
                    evaluation.setProfessor(rs.getString("professor"));
                    evaluation.setUserName(rs.getString("user_name"));

                    // 특성(features) 조회
                    loadEvaluationFeatures(conn, evaluation);

                    evaluations.add(evaluation);
                }
            }
            System.out.println("DEBUG: 조회된 최근 평가 수: " + evaluations.size());
        } catch (SQLException e) {
            System.err.println("ERROR: 최근 평가 조회 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();
        }

        return evaluations;
    }

    public List<Evaluation> getEvaluationsByCourseId(int courseId) {
        List<Evaluation> evaluations = new ArrayList<>();
        String sql = "SELECT e.*, u.name as user_name " +
                "FROM evaluations e " +
                "JOIN users u ON e.user_id = u.id " +
                "WHERE e.course_id = ? " +
                "ORDER BY e.date DESC";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, courseId);
            System.out.println("DEBUG: 강의별 평가 조회 SQL: " + sql + ", 파라미터: " + courseId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Evaluation evaluation = mapResultSetToEvaluation(rs);
                    evaluation.setUserName(rs.getString("user_name"));

                    // 특성(features) 조회
                    loadEvaluationFeatures(conn, evaluation);

                    evaluations.add(evaluation);
                }
            }
            System.out.println("DEBUG: 조회된 강의별 평가 수: " + evaluations.size());
        } catch (SQLException e) {
            System.err.println("ERROR: 강의별 평가 조회 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();
        }

        return evaluations;
    }

    public List<Evaluation> getEvaluationsByUserId(int userId) {
        List<Evaluation> evaluations = new ArrayList<>();
        String sql = "SELECT e.*, c.name as course_name, c.professor " +
                "FROM evaluations e " +
                "JOIN courses c ON e.course_id = c.id " +
                "WHERE e.user_id = ? " +
                "ORDER BY e.date DESC";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            System.out.println("DEBUG: 사용자별 평가 조회 SQL: " + sql + ", 파라미터: " + userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Evaluation evaluation = mapResultSetToEvaluation(rs);
                    evaluation.setCourseName(rs.getString("course_name"));
                    evaluation.setProfessor(rs.getString("professor"));

                    // 특성(features) 조회
                    loadEvaluationFeatures(conn, evaluation);

                    evaluations.add(evaluation);
                }
            }
            System.out.println("DEBUG: 조회된 사용자별 평가 수: " + evaluations.size());
        } catch (SQLException e) {
            System.err.println("ERROR: 사용자별 평가 조회 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();
        }

        return evaluations;
    }

    public Evaluation getEvaluationById(int id) {
        Evaluation evaluation = null;
        String sql = "SELECT e.*, c.name as course_name, c.professor, u.name as user_name " +
                "FROM evaluations e " +
                "JOIN courses c ON e.course_id = c.id " +
                "JOIN users u ON e.user_id = u.id " +
                "WHERE e.id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            System.out.println("DEBUG: 평가 ID 조회 SQL: " + sql + ", 파라미터: " + id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    evaluation = mapResultSetToEvaluation(rs);
                    evaluation.setCourseName(rs.getString("course_name"));
                    evaluation.setProfessor(rs.getString("professor"));
                    evaluation.setUserName(rs.getString("user_name"));

                    // 특성(features) 조회
                    loadEvaluationFeatures(conn, evaluation);

                    System.out.println("DEBUG: 평가 ID " + id + " 조회 성공");
                } else {
                    System.out.println("DEBUG: 평가 ID " + id + "에 해당하는 평가가 없습니다.");
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR: 평가 ID 조회 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();
        }

        return evaluation;
    }

    public boolean addEvaluation(Evaluation evaluation) {
        // 디버그 로그
        System.out.println("DEBUG: evaluations 테이블에 평가 추가 시도 중...");
        System.out.println("DEBUG: 평가 객체 정보:");
        System.out.println("DEBUG: courseId: " + evaluation.getCourseId());
        System.out.println("DEBUG: userId: " + evaluation.getUserId());
        System.out.println("DEBUG: rating: " + evaluation.getRating());
        System.out.println("DEBUG: difficulty: " + evaluation.getDifficulty());
        System.out.println("DEBUG: homework: " + evaluation.getHomework());
        System.out.println("DEBUG: courseType: " + evaluation.getCourseType());
        System.out.println("DEBUG: comment 길이: " + (evaluation.getComment() != null ? evaluation.getComment().length() : 0));
        System.out.println("DEBUG: features: " + (evaluation.getFeatures() != null ? String.join(",", evaluation.getFeatures()) : "없음"));

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet generatedKeys = null;

        try {
            conn = DatabaseUtil.getConnection();

            // 자동 커밋 비활성화 (트랜잭션 시작)
            conn.setAutoCommit(false);

            // 1. evaluations 테이블에 기본 정보 삽입
            String sql = "INSERT INTO evaluations (course_id, user_id, rating, difficulty, homework, course_type, comment, team_project) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setInt(1, evaluation.getCourseId());
            pstmt.setInt(2, evaluation.getUserId());
            pstmt.setInt(3, evaluation.getRating());
            pstmt.setInt(4, evaluation.getDifficulty());
            pstmt.setInt(5, evaluation.getHomework());
            pstmt.setString(6, evaluation.getCourseType());
            pstmt.setString(7, evaluation.getComment());

            // 팀 프로젝트 여부
            boolean teamProject = false;
            if (evaluation.getFeatures() != null) {
                teamProject = evaluation.getFeatures().contains("팀 프로젝트");
            }
            pstmt.setBoolean(8, teamProject);

            System.out.println("DEBUG: SQL 쿼리 실행: " + sql);
            System.out.println("DEBUG: 파라미터 - courseId: " + evaluation.getCourseId());
            System.out.println("DEBUG: 파라미터 - userId: " + evaluation.getUserId());
            System.out.println("DEBUG: 파라미터 - rating: " + evaluation.getRating());
            System.out.println("DEBUG: 파라미터 - difficulty: " + evaluation.getDifficulty());
            System.out.println("DEBUG: 파라미터 - homework: " + evaluation.getHomework());
            System.out.println("DEBUG: 파라미터 - courseType: " + evaluation.getCourseType());
            System.out.println("DEBUG: 파라미터 - teamProject: " + teamProject);

            int rowsAffected = pstmt.executeUpdate();
            System.out.println("DEBUG: 영향받은 행 수: " + rowsAffected);

            if (rowsAffected > 0) {
                // 생성된 ID 가져오기
                generatedKeys = pstmt.getGeneratedKeys();
                int evaluationId = -1;

                if (generatedKeys.next()) {
                    evaluationId = generatedKeys.getInt(1);
                    System.out.println("DEBUG: 생성된 평가 ID: " + evaluationId);
                    evaluation.setId(evaluationId);
                } else {
                    throw new SQLException("평가 ID를 가져오지 못했습니다.");
                }

                // 2. evaluation_features 테이블에 특성 삽입
                if (evaluation.getFeatures() != null && !evaluation.getFeatures().isEmpty()) {
                    insertEvaluationFeatures(conn, evaluationId, evaluation.getFeatures());
                }

                // 3. 강의 평점 업데이트
                updateCourseRating(conn, evaluation.getCourseId());

                // 트랜잭션 커밋
                conn.commit();
                return true;
            } else {
                // 변경된 행이 없으면 롤백
                conn.rollback();
                return false;
            }

        } catch (SQLException e) {
            System.err.println("ERROR: 평가 추가 실패: " + e.getMessage());
            System.err.println("SQL 상태: " + e.getSQLState());
            System.err.println("오류 코드: " + e.getErrorCode());

            // 중복 키 오류 확인 (MySQL 오류 코드 1062)
            if (e.getErrorCode() == 1062) {
                System.err.println("ERROR: 중복 키 오류 - 이미 이 강의에 대한 평가가 존재합니다.");
            }

            e.printStackTrace();

            // 오류 발생 시 롤백
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            return false;
        } finally {
            // 리소스 정리
            if (generatedKeys != null) {
                try {
                    generatedKeys.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

            if (conn != null) {
                try {
                    // 자동 커밋 다시 활성화
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void insertEvaluationFeatures(Connection conn, int evaluationId, List<String> features) throws SQLException {
        String sql = "INSERT INTO evaluation_features (evaluation_id, feature) VALUES (?, ?)";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            for (String feature : features) {
                pstmt.setInt(1, evaluationId);
                pstmt.setString(2, feature);
                pstmt.addBatch();
                System.out.println("DEBUG: 특성 추가 - evaluationId: " + evaluationId + ", feature: " + feature);
            }

            int[] results = pstmt.executeBatch();
            System.out.println("DEBUG: 특성 추가 결과 - 총 " + results.length + "개 추가됨");
        }
    }

    private void loadEvaluationFeatures(Connection conn, Evaluation evaluation) {
        String sql = "SELECT feature FROM evaluation_features WHERE evaluation_id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, evaluation.getId());

            try (ResultSet rs = pstmt.executeQuery()) {
                List<String> features = new ArrayList<>();
                while (rs.next()) {
                    features.add(rs.getString("feature"));
                }
                evaluation.setFeatures(features);
                System.out.println("DEBUG: 평가 ID " + evaluation.getId() + "의 특성 " + features.size() + "개 로드됨");
            }
        } catch (SQLException e) {
            System.err.println("ERROR: 평가 특성 조회 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();
            evaluation.setFeatures(new ArrayList<>());
        }
    }

    public boolean updateEvaluation(Evaluation evaluation) {
        Connection conn = null;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. evaluations 테이블 업데이트
            String sql = "UPDATE evaluations SET rating = ?, difficulty = ?, homework = ?, comment = ?, " +
                    "course_type = ?, team_project = ? WHERE id = ? AND user_id = ?";

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, evaluation.getRating());
                pstmt.setInt(2, evaluation.getDifficulty());
                pstmt.setInt(3, evaluation.getHomework());
                pstmt.setString(4, evaluation.getComment());
                pstmt.setString(5, evaluation.getCourseType());

                // 팀 프로젝트 여부
                boolean teamProject = false;
                if (evaluation.getFeatures() != null) {
                    teamProject = evaluation.getFeatures().contains("팀 프로젝트");
                }
                pstmt.setBoolean(6, teamProject);

                pstmt.setInt(7, evaluation.getId());
                pstmt.setInt(8, evaluation.getUserId());

                System.out.println("DEBUG: 평가 업데이트 SQL: " + sql);
                int rowsAffected = pstmt.executeUpdate();
                System.out.println("DEBUG: 영향받은 행 수: " + rowsAffected);

                if (rowsAffected > 0) {
                    // 2. evaluation_features 테이블 업데이트 (기존 항목 삭제 후 새로 삽입)
                    deleteEvaluationFeatures(conn, evaluation.getId());

                    if (evaluation.getFeatures() != null && !evaluation.getFeatures().isEmpty()) {
                        insertEvaluationFeatures(conn, evaluation.getId(), evaluation.getFeatures());
                    }

                    // 3. 강의 평점 업데이트
                    updateCourseRating(conn, evaluation.getCourseId());

                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                    return false;
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR: 평가 업데이트 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void deleteEvaluationFeatures(Connection conn, int evaluationId) throws SQLException {
        String sql = "DELETE FROM evaluation_features WHERE evaluation_id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, evaluationId);
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("DEBUG: 평가 ID " + evaluationId + "의 특성 " + rowsAffected + "개 삭제됨");
        }
    }

    public boolean deleteEvaluation(int id, int userId) {
        Connection conn = null;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. 강의 ID 조회
            String sql = "SELECT course_id FROM evaluations WHERE id = ? AND user_id = ?";
            Integer courseId = null;

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, id);
                pstmt.setInt(2, userId);

                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        courseId = rs.getInt("course_id");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            // 2. evaluation_features 테이블에서 특성 삭제
            deleteEvaluationFeatures(conn, id);

            // 3. evaluations 테이블에서 평가 삭제
            sql = "DELETE FROM evaluations WHERE id = ? AND user_id = ?";

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, id);
                pstmt.setInt(2, userId);

                int rowsAffected = pstmt.executeUpdate();

                if (rowsAffected > 0 && courseId != null) {
                    // 4. 강의 평점 업데이트
                    updateCourseRating(conn, courseId);

                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                    return false;
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR: 평가 삭제 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void updateCourseRating(Connection conn, int courseId) throws SQLException {
        String sql = "SELECT AVG(rating) as avg_rating, COUNT(*) as count, " +
                "AVG(difficulty) as avg_difficulty, AVG(homework) as avg_homework, " +
                "SUM(CASE WHEN team_project = true THEN 1 ELSE 0 END) as team_project_count " +
                "FROM evaluations WHERE course_id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, courseId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    double avgRating = rs.getDouble("avg_rating");
                    int count = rs.getInt("count");
                    double avgDifficulty = rs.getDouble("avg_difficulty");
                    double avgHomework = rs.getDouble("avg_homework");
                    int teamProjectCount = rs.getInt("team_project_count");

                    Course course = new Course();
                    course.setId(courseId);
                    course.setRating(avgRating);
                    course.setEvaluationCount(count);
                    course.setDifficulty(avgDifficulty);
                    course.setHomework(avgHomework);
                    course.setTeamProject(teamProjectCount > 0);
                    course.setPopular(count >= 5);

                    CourseDAO courseDAO = new CourseDAO();
                    courseDAO.updateCourseRating(conn, course);
                }
            }
        }
    }

    private Evaluation mapResultSetToEvaluation(ResultSet rs) throws SQLException {
        Evaluation evaluation = new Evaluation();
        evaluation.setId(rs.getInt("id"));
        evaluation.setCourseId(rs.getInt("course_id"));
        evaluation.setUserId(rs.getInt("user_id"));
        evaluation.setRating(rs.getInt("rating"));
        evaluation.setDifficulty(rs.getInt("difficulty"));
        evaluation.setHomework(rs.getInt("homework"));
        evaluation.setComment(rs.getString("comment"));
        evaluation.setCourseType(rs.getString("course_type"));
        evaluation.setDate(rs.getTimestamp("date"));

        // features는 별도 테이블에서 로드하므로 여기서는 빈 리스트로 초기화
        evaluation.setFeatures(new ArrayList<>());

        try {
            evaluation.setReported(rs.getBoolean("is_reported"));
        } catch (SQLException e) {
            // is_reported 컬럼이 없는 경우 기본값 false 설정
            evaluation.setReported(false);
        }

        return evaluation;
    }

    // 모든 평가 조회
    public List<Evaluation> getAllEvaluations() {
        List<Evaluation> evaluations = new ArrayList<>();
        String sql = "SELECT e.*, c.name as course_name, c.professor, u.name as user_name " +
                "FROM evaluations e " +
                "JOIN courses c ON e.course_id = c.id " +
                "JOIN users u ON e.user_id = u.id " +
                "ORDER BY e.date DESC";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            System.out.println("DEBUG: 모든 평가 조회 SQL: " + sql);
            while (rs.next()) {
                Evaluation evaluation = mapResultSetToEvaluation(rs);
                evaluation.setCourseName(rs.getString("course_name"));
                evaluation.setProfessor(rs.getString("professor"));
                evaluation.setUserName(rs.getString("user_name"));

                // 특성(features) 조회
                loadEvaluationFeatures(conn, evaluation);

                evaluations.add(evaluation);
            }
            System.out.println("DEBUG: 조회된 모든 평가 수: " + evaluations.size());
        } catch (SQLException e) {
            System.err.println("ERROR: 모든 평가 조회 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();
        }

        return evaluations;
    }

    // 전체 평가 수 조회 메서드 추가
    public int getEvaluationCount() {
        String sql = "SELECT COUNT(*) FROM evaluations";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("ERROR: 전체 평가 수 조회 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * 신고된 강의평가 목록을 조회합니다.
     * @return 신고된 강의평가 목록
     */
    public List<Evaluation> getReportedEvaluations() {
        List<Evaluation> evaluations = new ArrayList<>();
        String sql = "SELECT e.*, c.name as course_name, c.professor, u.name as user_name " +
                "FROM evaluations e " +
                "JOIN courses c ON e.course_id = c.id " +
                "JOIN users u ON e.user_id = u.id " +
                "WHERE e.is_reported = true " +
                "ORDER BY e.date DESC";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Evaluation evaluation = mapResultSetToEvaluation(rs);
                evaluation.setCourseName(rs.getString("course_name"));
                evaluation.setProfessor(rs.getString("professor"));
                evaluation.setUserName(rs.getString("user_name"));

                // 특성(features) 조회
                loadEvaluationFeatures(conn, evaluation);

                evaluations.add(evaluation);
            }
        } catch (SQLException e) {
            System.err.println("ERROR: 신고된 강의평가 조회 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();
        }

        return evaluations;
    }

    /**
     * 강의평가의 신고 상태를 업데이트합니다.
     * @param evaluationId 강의평가 ID
     * @param isReported 신고 상태 (true: 신고됨, false: 신고되지 않음)
     * @return 업데이트 성공 여부
     */
    public boolean updateEvaluationReportStatus(int evaluationId, boolean isReported) {
        String sql = "UPDATE evaluations SET is_reported = ? WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBoolean(1, isReported);
            pstmt.setInt(2, evaluationId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("ERROR: 강의평가 신고 상태 업데이트 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 강의평가를 신고합니다.
     * @param evaluationId 강의평가 ID
     * @param userId 신고자 ID
     * @param reason 신고 사유
     * @return 신고 성공 여부
     */
    public boolean reportEvaluation(int evaluationId, int userId, String reason) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. 강의평가 존재 여부 확인
            String checkSql = "SELECT id FROM evaluations WHERE id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, evaluationId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next()) {
                    System.err.println("ERROR: 강의평가 ID " + evaluationId + "를 찾을 수 없습니다.");
                    return false;
                }
            }

            // 2. 이미 신고한 경우 확인
            pstmt.close();
            String checkReportSql = "SELECT id FROM reports WHERE content_type = 'evaluation' AND content_id = ? AND reporter_id = ?";
            pstmt = conn.prepareStatement(checkReportSql);
            pstmt.setInt(1, evaluationId);
            pstmt.setInt(2, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    System.err.println("ERROR: 사용자 ID " + userId + "는 이미 강의평가 ID " + evaluationId + "를 신고했습니다.");
                    return false;
                }
            }

            // 3. 신고 정보 저장
            pstmt.close();
            String insertSql = "INSERT INTO reports (content_type, content_id, reporter_id, reason, report_date) VALUES (?, ?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, "evaluation");
            pstmt.setInt(2, evaluationId);
            pstmt.setInt(3, userId);
            pstmt.setString(4, reason);

            int insertResult = pstmt.executeUpdate();

            // 4. 강의평가 신고 상태 업데이트
            if (insertResult > 0) {
                pstmt.close();
                String updateSql = "UPDATE evaluations SET is_reported = true WHERE id = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, evaluationId);

                int updateResult = pstmt.executeUpdate();
                success = updateResult > 0;
            }

            if (success) {
                conn.commit();
                System.out.println("DEBUG: 강의평가 ID " + evaluationId + " 신고 성공 (신고자 ID: " + userId + ")");
            } else {
                conn.rollback();
                System.err.println("ERROR: 강의평가 ID " + evaluationId + " 신고 실패 (신고자 ID: " + userId + ")");
            }

            return success;
        } catch (SQLException e) {
            System.err.println("ERROR: 강의평가 신고 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            return false;
        } finally {
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * 강의평가 신고를 무시합니다. (관리자 기능)
     * @param evaluationId 강의평가 ID
     * @return 성공 여부
     */
    public boolean ignoreEvaluationReport(int evaluationId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. 신고 상태 업데이트
            String updateSql = "UPDATE evaluations SET is_reported = false WHERE id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setInt(1, evaluationId);

            int updateResult = pstmt.executeUpdate();

            // 2. 신고 테이블에서 해당 강의평가 신고 삭제
            if (updateResult > 0) {
                pstmt.close();
                String deleteSql = "DELETE FROM reports WHERE content_type = 'evaluation' AND content_id = ?";
                pstmt = conn.prepareStatement(deleteSql);
                pstmt.setInt(1, evaluationId);

                pstmt.executeUpdate();
                success = true;
            }

            if (success) {
                conn.commit();
                System.out.println("DEBUG: 강의평가 ID " + evaluationId + " 신고 무시 성공");
            } else {
                conn.rollback();
                System.err.println("ERROR: 강의평가 ID " + evaluationId + " 신고 무시 실패");
            }

            return success;
        } catch (SQLException e) {
            System.err.println("ERROR: 강의평가 신고 무시 중 SQL 오류: " + e.getMessage());
            e.printStackTrace();

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            return false;
        } finally {
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }

            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // 배지에 필요한 메소드
    public int getUserEvaluationCount(int userId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT COUNT(*) FROM evaluations WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DatabaseUtil.close(rs, pstmt, conn);
        }

        return count;
    }

    /**
     * 특정 사용자의 모든 강의평가를 삭제합니다.
     */
    public boolean deleteEvaluationsByUserId(int userId) {
        String sql = "DELETE FROM evaluations WHERE user_id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);

            int affectedRows = pstmt.executeUpdate();
            System.out.println("DEBUG: 사용자의 모든 강의평가 삭제: userId=" + userId + ", 영향받은 행: " + affectedRows);

            return true; // 삭제할 강의평가가 없어도 성공으로 간주

        } catch (SQLException e) {
            System.err.println("ERROR: 사용자의 모든 강의평가 삭제 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
