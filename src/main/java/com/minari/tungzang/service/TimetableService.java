package com.minari.tungzang.service;

import com.minari.tungzang.dao.TimetableDAO;
import com.minari.tungzang.model.TimetableCourse;
import com.minari.tungzang.util.DatabaseUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TimetableService {
    private static final Logger LOGGER = Logger.getLogger(TimetableService.class.getName());
    private TimetableDAO timetableDAO;

    public TimetableService() {
        this.timetableDAO = new TimetableDAO();
    }

    /**
     * 특정 사용자의 시간표 강의 목록을 조회합니다.
     */
    public List<TimetableCourse> getTimetableCoursesByUserId(int userId) {
        LOGGER.info("시간표 서비스: 사용자 " + userId + "의 시간표 조회 시작");

        if (userId <= 0) {
            LOGGER.warning("잘못된 사용자 ID: " + userId);
            return new ArrayList<>();
        }

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            List<TimetableCourse> courses = timetableDAO.getTimetableCoursesByUserId(conn, userId);

            LOGGER.info("시간표 서비스: " + courses.size() + "개의 강의를 조회했습니다.");
            return courses;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "시간표 조회 중 오류 발생: userId=" + userId, e);
            return new ArrayList<>();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Connection 닫기 실패", e);
                }
            }
        }
    }

    /**
     * 특정 ID의 시간표 강의를 조회합니다.
     */
    public TimetableCourse getTimetableCourseById(int id) {
        LOGGER.info("시간표 서비스: 강의 ID " + id + " 조회 시작");

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            TimetableCourse course = timetableDAO.getTimetableCourseById(conn, id);

            LOGGER.info("시간표 서비스: 강의 조회 " + (course != null ? "성공" : "실패"));
            return course;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "시간표 강의 조회 중 오류 발생: id=" + id, e);
            return null;
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Connection 닫기 실패", e);
                }
            }
        }
    }

    /**
     * 새로운 시간표 강의를 추가합니다.
     */
    public int addTimetableCourse(TimetableCourse course) {
        LOGGER.info("시간표 서비스: 강의 추가 시작 - " + course.getName());

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            int generatedId = timetableDAO.addTimetableCourse(conn, course);

            LOGGER.info("시간표 서비스: 강의 추가 " + (generatedId > 0 ? "성공" : "실패") + ", 생성된 ID: " + generatedId);
            return generatedId;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "시간표 강의 추가 중 오류 발생", e);
            return -1;
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Connection 닫기 실패", e);
                }
            }
        }
    }

    /**
     * 시간표 강의를 삭제합니다.
     */
    public boolean deleteTimetableCourse(int courseId) {
        LOGGER.info("시간표 서비스: 강의 삭제 시작 - courseId=" + courseId);

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            boolean result = timetableDAO.deleteTimetableCourse(conn, courseId);

            LOGGER.info("시간표 서비스: 강의 삭제 " + (result ? "성공" : "실패"));
            return result;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "시간표 강의 삭제 중 오류 발생", e);
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Connection 닫기 실패", e);
                }
            }
        }
    }

    /**
     * 특정 사용자의 모든 시간표 강의를 삭제합니다.
     */
    public boolean deleteAllTimetableCoursesByUserId(int userId) {
        LOGGER.info("시간표 서비스: 사용자의 모든 강의 삭제 시작 - userId=" + userId);

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            boolean result = timetableDAO.deleteAllTimetableCoursesByUserId(conn, userId);

            LOGGER.info("시간표 서비스: 사용자의 모든 강의 삭제 " + (result ? "성공" : "실패"));
            return result;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자의 모든 시간표 강의 삭제 중 오류 발생", e);
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Connection 닫기 실패", e);
                }
            }
        }
    }

    /**
     * 사용자의 시간표 강의 수를 가져옵니다.
     */
    public int getTimetableCourseCount(int userId) {
        LOGGER.info("시간표 서비스: 사용자 강의 수 조회 - userId=" + userId);
        return timetableDAO.getUserTimetableCount(userId);
    }

    /**
     * 시간표 강의를 업데이트합니다.
     */
    public boolean updateTimetableCourse(TimetableCourse course) {
        LOGGER.info("시간표 서비스: 강의 업데이트 시작 - " + course.getName());

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            boolean result = timetableDAO.updateTimetableCourse(conn, course);

            LOGGER.info("시간표 서비스: 강의 업데이트 " + (result ? "성공" : "실패"));
            return result;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "시간표 강의 업데이트 중 오류 발생", e);
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.WARNING, "Connection 닫기 실패", e);
                }
            }
        }
    }

    /**
     * 특정 사용자의 모든 시간표를 삭제합니다. (회원탈퇴용)
     */
    public boolean deleteTimetableByUserId(int userId) {
        LOGGER.info("시간표 서비스: 사용자의 모든 시간표 삭제 시작 - userId=" + userId);
        return deleteAllTimetableCoursesByUserId(userId);
    }
}
