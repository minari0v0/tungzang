package com.minari.tungzang.dao;

import com.minari.tungzang.model.TimetableCourse;
import com.minari.tungzang.util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TimetableDAO {
    private static final Logger LOGGER = Logger.getLogger(TimetableDAO.class.getName());

    /**
     * 특정 사용자의 시간표 강의 목록을 조회합니다.
     */
    public List<TimetableCourse> getTimetableCoursesByUserId(Connection conn, int userId) throws SQLException {
        List<TimetableCourse> courses = new ArrayList<>();
        String sql = "SELECT * FROM timetable_courses WHERE user_id = ? ORDER BY day, start_time";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            LOGGER.info("시간표 조회 SQL 실행: userId=" + userId);

            while (rs.next()) {
                TimetableCourse course = new TimetableCourse();
                course.setId(rs.getInt("id"));
                course.setUserId(rs.getInt("user_id"));
                course.setName(rs.getString("name"));
                course.setProfessor(rs.getString("professor"));
                course.setDay(rs.getString("day"));
                course.setStartTime(rs.getInt("start_time"));
                course.setEndTime(rs.getInt("end_time"));
                course.setLocation(rs.getString("location"));
                course.setColor(rs.getString("color"));
                course.setCreatedAt(rs.getTimestamp("created_at"));

                courses.add(course);
                LOGGER.info("시간표 강의 로드: " + course.getName() + " (" + course.getDay() + " " + course.getStartTime() + "-" + course.getEndTime() + ")");
            }

            LOGGER.info("총 " + courses.size() + "개의 시간표 강의를 조회했습니다.");

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "시간표 조회 중 오류 발생: userId=" + userId, e);
            throw e;
        } finally {
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "ResultSet 닫기 실패", e);
                }
            }
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "PreparedStatement 닫기 실패", e);
                }
            }
        }

        return courses;
    }

    /**
     * 특정 ID의 시간표 강의를 조회합니다.
     */
    public TimetableCourse getTimetableCourseById(Connection conn, int id) throws SQLException {
        String sql = "SELECT * FROM timetable_courses WHERE id = ?";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                TimetableCourse course = new TimetableCourse();
                course.setId(rs.getInt("id"));
                course.setUserId(rs.getInt("user_id"));
                course.setName(rs.getString("name"));
                course.setProfessor(rs.getString("professor"));
                course.setDay(rs.getString("day"));
                course.setStartTime(rs.getInt("start_time"));
                course.setEndTime(rs.getInt("end_time"));
                course.setLocation(rs.getString("location"));
                course.setColor(rs.getString("color"));
                course.setCreatedAt(rs.getTimestamp("created_at"));

                LOGGER.info("시간표 강의 조회 성공: " + course.getName());
                return course;
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "시간표 강의 조회 중 오류 발생: courseId=" + id, e);
            throw e;
        } finally {
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "ResultSet 닫기 실패", e);
                }
            }
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "PreparedStatement 닫기 실패", e);
                }
            }
        }

        LOGGER.info("시간표 강의를 찾을 수 없습니다: courseId=" + id);
        return null;
    }

    /**
     * 새로운 시간표 강의를 추가합니다.
     */
    public int addTimetableCourse(Connection conn, TimetableCourse course) throws SQLException {
        String sql = "INSERT INTO timetable_courses (user_id, name, professor, day, start_time, end_time, location, color) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement pstmt = null;
        ResultSet generatedKeys = null;
        int generatedId = -1;

        try {
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setInt(1, course.getUserId());
            pstmt.setString(2, course.getName());
            pstmt.setString(3, course.getProfessor());
            pstmt.setString(4, course.getDay());
            pstmt.setInt(5, course.getStartTime());
            pstmt.setInt(6, course.getEndTime());
            pstmt.setString(7, course.getLocation());
            pstmt.setString(8, course.getColor());

            int affectedRows = pstmt.executeUpdate();
            LOGGER.info("시간표 강의 추가: " + course.getName() + ", 영향받은 행: " + affectedRows);

            if (affectedRows > 0) {
                generatedKeys = pstmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    generatedId = generatedKeys.getInt(1);
                    course.setId(generatedId);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "시간표 강의 추가 중 오류 발생", e);
            throw e;
        } finally {
            if (generatedKeys != null) {
                try {
                    generatedKeys.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "ResultSet 닫기 실패", e);
                }
            }
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "PreparedStatement 닫기 실패", e);
                }
            }
        }

        return generatedId;
    }

    /**
     * 시간표 강의를 삭제합니다.
     */
    public boolean deleteTimetableCourse(Connection conn, int courseId) throws SQLException {
        String sql = "DELETE FROM timetable_courses WHERE id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, courseId);

            int affectedRows = pstmt.executeUpdate();
            LOGGER.info("시간표 강의 삭제: courseId=" + courseId + ", 영향받은 행: " + affectedRows);

            return affectedRows > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "시간표 강의 삭제 중 오류 발생", e);
            throw e;
        } finally {
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "PreparedStatement 닫기 실패", e);
                }
            }
        }
    }

    /**
     * 특정 사용자의 모든 시간표 강의를 삭제합니다.
     */
    public boolean deleteAllTimetableCoursesByUserId(Connection conn, int userId) throws SQLException {
        String sql = "DELETE FROM timetable_courses WHERE user_id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);

            int affectedRows = pstmt.executeUpdate();
            LOGGER.info("사용자의 모든 시간표 강의 삭제: userId=" + userId + ", 영향받은 행: " + affectedRows);

            return true; // 삭제할 강의가 없어도 성공으로 간주

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자의 모든 시간표 강의 삭제 중 오류 발생", e);
            throw e;
        } finally {
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "PreparedStatement 닫기 실패", e);
                }
            }
        }
    }

    /**
     * 사용자의 시간표 강의 수를 가져옵니다.
     */
    public int getUserTimetableCount(int userId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT COUNT(*) FROM timetable_courses WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }

            LOGGER.info("사용자 시간표 강의 수 조회: userId=" + userId + ", 개수=" + count);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "사용자 시간표 강의 수 조회 중 오류 발생", e);
        } finally {
            DatabaseUtil.close(rs, pstmt, conn);
        }

        return count;
    }

    /**
     * 시간표 강의를 업데이트합니다.
     */
    public boolean updateTimetableCourse(Connection conn, TimetableCourse course) throws SQLException {
        String sql = "UPDATE timetable_courses SET name = ?, professor = ?, day = ?, start_time = ?, end_time = ?, location = ?, color = ? WHERE id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, course.getName());
            pstmt.setString(2, course.getProfessor());
            pstmt.setString(3, course.getDay());
            pstmt.setInt(4, course.getStartTime());
            pstmt.setInt(5, course.getEndTime());
            pstmt.setString(6, course.getLocation());
            pstmt.setString(7, course.getColor());
            pstmt.setInt(8, course.getId());

            int affectedRows = pstmt.executeUpdate();
            LOGGER.info("시간표 강의 업데이트: " + course.getName() + ", 영향받은 행: " + affectedRows);

            return affectedRows > 0;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "시간표 강의 업데이트 중 오류 발생", e);
            throw e;
        } finally {
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "PreparedStatement 닫기 실패", e);
                }
            }
        }
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
