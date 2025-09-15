package com.minari.tungzang.dao;

import com.minari.tungzang.model.Course;
import com.minari.tungzang.util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CourseDAO {
    private static final Logger LOGGER = Logger.getLogger(CourseDAO.class.getName());
    /**
     * 모든 강의 목록을 조회합니다.
     */
    public List<Course> getAllCourses(Connection conn) throws SQLException {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT * FROM courses ORDER BY name";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Course course = mapResultSetToCourse(rs);
                courses.add(course);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return courses;
    }

    /**
     * 특정 ID의 강의를 조회합니다.
     */
    public Course getCourseById(Connection conn, int id) throws SQLException {
        String sql = "SELECT * FROM courses WHERE id = ?";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToCourse(rs);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return null;
    }

    /**
     * 특정 학과의 강의 목록을 조회합니다.
     */
    public List<Course> getCoursesByDepartment(Connection conn, String departmentId) throws SQLException {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT * FROM courses WHERE department_id = ? ORDER BY name";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, departmentId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Course course = mapResultSetToCourse(rs);
                courses.add(course);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return courses;
    }

    /**
     * 특정 유형의 강의 목록을 조회합니다.
     */
    public List<Course> getCoursesByType(Connection conn, String type) throws SQLException {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT * FROM courses WHERE type = ? ORDER BY name";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, type);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Course course = mapResultSetToCourse(rs);
                courses.add(course);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return courses;
    }

    /**
     * 인기 강의 목록을 조회합니다.
     */
    public List<Course> getPopularCourses(Connection conn, int limit) throws SQLException {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT * FROM courses WHERE is_popular = TRUE ORDER BY rating DESC, evaluation_count DESC LIMIT ?";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Course course = mapResultSetToCourse(rs);
                courses.add(course);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return courses;
    }

    /**
     * 강의를 검색합니다.
     */
    public List<Course> searchCourses(Connection conn, String keyword) throws SQLException {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT * FROM courses WHERE name LIKE ? OR professor LIKE ? ORDER BY name";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            String searchKeyword = "%" + keyword + "%";
            pstmt.setString(1, searchKeyword);
            pstmt.setString(2, searchKeyword);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Course course = mapResultSetToCourse(rs);
                courses.add(course);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return courses;
    }

    /**
     * 새로운 강의를 추가합니다.
     */
    public int addCourse(Connection conn, Course course) throws SQLException {
        String sql = "INSERT INTO courses (name, professor, department, department_id, type, rating, evaluation_count, " +
                "difficulty, homework, team_project, exam_count, is_popular) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, course.getName());
            pstmt.setString(2, course.getProfessor());
            pstmt.setString(3, course.getDepartment());
            pstmt.setString(4, course.getDepartmentId());
            pstmt.setString(5, course.getType());
            pstmt.setDouble(6, course.getRating());
            pstmt.setInt(7, course.getEvaluationCount());
            pstmt.setDouble(8, course.getDifficulty());
            pstmt.setDouble(9, course.getHomework());
            pstmt.setBoolean(10, course.isTeamProject());
            pstmt.setInt(11, course.getExamCount());
            pstmt.setBoolean(12, course.isPopular());

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("강의 추가 실패, 영향받은 행이 없습니다.");
            }

            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            } else {
                throw new SQLException("강의 추가 실패, ID를 가져올 수 없습니다.");
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }
    }

    /**
     * 강의 정보를 업데이트합니다.
     */
    public boolean updateCourse(Connection conn, Course course) throws SQLException {
        String sql = "UPDATE courses SET name = ?, professor = ?, department = ?, department_id = ?, " +
                "type = ?, exam_count = ? WHERE id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, course.getName());
            pstmt.setString(2, course.getProfessor());
            pstmt.setString(3, course.getDepartment());
            pstmt.setString(4, course.getDepartmentId());
            pstmt.setString(5, course.getType());
            pstmt.setInt(6, course.getExamCount());
            pstmt.setInt(7, course.getId());

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } finally {
            DatabaseUtil.close(pstmt);
        }
    }

    /**
     * 강의 평점 정보를 업데이트합니다.
     */
    public boolean updateCourseRating(Connection conn, Course course) throws SQLException {
        String sql = "UPDATE courses SET rating = ?, evaluation_count = ?, difficulty = ?, " +
                "homework = ?, team_project = ?, is_popular = ? WHERE id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setDouble(1, course.getRating());
            pstmt.setInt(2, course.getEvaluationCount());
            pstmt.setDouble(3, course.getDifficulty());
            pstmt.setDouble(4, course.getHomework());
            pstmt.setBoolean(5, course.isTeamProject());
            pstmt.setBoolean(6, course.isPopular());
            pstmt.setInt(7, course.getId());

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } finally {
            DatabaseUtil.close(pstmt);
        }
    }

    /**
     * 강의를 삭제합니다.
     */
    public boolean deleteCourse(Connection conn, int id) throws SQLException {
        String sql = "DELETE FROM courses WHERE id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } finally {
            DatabaseUtil.close(pstmt);
        }
    }

    /**
     * 강의 태그를 추가합니다.
     */
    public boolean addCourseTag(Connection conn, int courseId, String tag) throws SQLException {
        String sql = "INSERT INTO course_tags (course_id, tag) VALUES (?, ?)";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);
            pstmt.setString(2, tag);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } finally {
            DatabaseUtil.close(pstmt);
        }
    }

    /**
     * 강의 태그를 삭제합니다.
     */
    public boolean deleteCourseTag(Connection conn, int courseId, String tag) throws SQLException {
        String sql = "DELETE FROM course_tags WHERE course_id = ? AND tag = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);
            pstmt.setString(2, tag);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } finally {
            DatabaseUtil.close(pstmt);
        }
    }

    /**
     * 강의의 모든 태그를 삭제합니다.
     */
    public boolean deleteAllCourseTags(Connection conn, int courseId) throws SQLException {
        String sql = "DELETE FROM course_tags WHERE course_id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);

            pstmt.executeUpdate();
            return true;
        } finally {
            DatabaseUtil.close(pstmt);
        }
    }

    /**
     * 강의의 태그 목록을 조회합니다.
     */
    public String[] getCourseTags(Connection conn, int courseId) throws SQLException {
        String sql = "SELECT tag FROM course_tags WHERE course_id = ?";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);
            rs = pstmt.executeQuery();

            List<String> tags = new ArrayList<>();
            while (rs.next()) {
                tags.add(rs.getString("tag"));
            }

            return tags.toArray(new String[0]);
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }
    }

    /**
     * ResultSet에서 Course 객체로 매핑합니다.
     */
    private Course mapResultSetToCourse(ResultSet rs) throws SQLException {
        Course course = new Course();
        course.setId(rs.getInt("id"));
        course.setName(rs.getString("name"));
        course.setProfessor(rs.getString("professor"));
        course.setDepartment(rs.getString("department"));
        course.setDepartmentId(rs.getString("department_id"));
        course.setType(rs.getString("type"));
        course.setRating(rs.getDouble("rating"));
        course.setEvaluationCount(rs.getInt("evaluation_count"));
        course.setDifficulty(rs.getDouble("difficulty"));
        course.setHomework(rs.getDouble("homework"));
        course.setTeamProject(rs.getBoolean("team_project"));
        course.setExamCount(rs.getInt("exam_count"));
        course.setPopular(rs.getBoolean("is_popular"));
        return course;
    }

    // 강의 수 조회 메서드 추가
    public int getCourseCount() {
        String sql = "SELECT COUNT(*) FROM courses";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "전체 강의 수 조회 중 오류 발생", e);
        }
        return 0;
    }

}