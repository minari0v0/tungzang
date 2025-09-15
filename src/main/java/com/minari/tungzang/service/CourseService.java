package com.minari.tungzang.service;

import com.minari.tungzang.dao.CourseDAO;
import com.minari.tungzang.model.Course;
import com.minari.tungzang.model.Evaluation;
import com.minari.tungzang.util.DatabaseUtil;
import com.minari.tungzang.util.TagAnalyzer;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class CourseService {

    private CourseDAO courseDAO;
    private EvaluationService evaluationService;

    public CourseService() {
        this.courseDAO = new CourseDAO();
        this.evaluationService = new EvaluationService();
    }

    /**
     * 모든 강의 목록을 조회합니다.
     */
    public List<Course> getAllCourses() {
        try (Connection conn = DatabaseUtil.getConnection()) {
            List<Course> courses = courseDAO.getAllCourses(conn);

            // 각 강의의 태그 정보 가져오기
            for (Course course : courses) {
                String[] tags = courseDAO.getCourseTags(conn, course.getId());
                course.setTags(tags);
            }

            return courses;
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    /**
     * 특정 ID의 강의를 조회합니다.
     */
    public Course getCourseById(int id) {
        try (Connection conn = DatabaseUtil.getConnection()) {
            Course course = courseDAO.getCourseById(conn, id);

            if (course != null) {
                String[] tags = courseDAO.getCourseTags(conn, course.getId());
                course.setTags(tags);
            }

            return course;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * 특정 학과의 강의 목록을 조회합니다.
     */
    public List<Course> getCoursesByDepartment(String departmentId) {
        try (Connection conn = DatabaseUtil.getConnection()) {
            List<Course> courses = courseDAO.getCoursesByDepartment(conn, departmentId);

            // 각 강의의 태그 정보 가져오기
            for (Course course : courses) {
                String[] tags = courseDAO.getCourseTags(conn, course.getId());
                course.setTags(tags);
            }

            return courses;
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    /**
     * 특정 유형의 강의 목록을 조회합니다.
     */
    public List<Course> getCoursesByType(String type) {
        try (Connection conn = DatabaseUtil.getConnection()) {
            List<Course> courses = courseDAO.getCoursesByType(conn, type);

            // 각 강의의 태그 정보 가져오기
            for (Course course : courses) {
                String[] tags = courseDAO.getCourseTags(conn, course.getId());
                course.setTags(tags);
            }

            return courses;
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    /**
     * 인기 강의 목록을 조회합니다.
     */
    public List<Course> getPopularCourses(int limit) {
        try (Connection conn = DatabaseUtil.getConnection()) {
            List<Course> courses = courseDAO.getPopularCourses(conn, limit);

            // 각 강의의 태그 정보 가져오기
            for (Course course : courses) {
                String[] tags = courseDAO.getCourseTags(conn, course.getId());
                course.setTags(tags);
            }

            return courses;
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    /**
     * 강의를 검색합니다.
     */
    public List<Course> searchCourses(String keyword) {
        try (Connection conn = DatabaseUtil.getConnection()) {
            List<Course> courses = courseDAO.searchCourses(conn, keyword);

            // 각 강의의 태그 정보 가져오기
            for (Course course : courses) {
                String[] tags = courseDAO.getCourseTags(conn, course.getId());
                course.setTags(tags);
            }

            return courses;
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    /**
     * 새로운 강의를 추가합니다.
     */
    public int addCourse(Course course) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            int courseId = courseDAO.addCourse(conn, course);

            // 강의 태그 추가
            if (course.getTags() != null && course.getTags().length > 0) {
                for (String tag : course.getTags()) {
                    courseDAO.addCourseTag(conn, courseId, tag);
                }
            }

            conn.commit();
            return courseId;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return -1;
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

    /**
     * 강의 정보를 업데이트합니다.
     */
    public boolean updateCourse(Course course) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            boolean updated = courseDAO.updateCourse(conn, course);

            if (updated) {
                // 기존 태그 삭제
                courseDAO.deleteAllCourseTags(conn, course.getId());

                // 새로운 태그 추가
                if (course.getTags() != null && course.getTags().length > 0) {
                    for (String tag : course.getTags()) {
                        courseDAO.addCourseTag(conn, course.getId(), tag);
                    }
                }
            }

            conn.commit();
            return updated;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
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

    /**
     * 강의를 삭제합니다.
     */
    public boolean deleteCourse(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // 강의 태그 삭제
            courseDAO.deleteAllCourseTags(conn, id);

            // 강의 삭제
            boolean deleted = courseDAO.deleteCourse(conn, id);

            conn.commit();
            return deleted;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
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

    /**
     * 강의 평가 데이터를 분석하여 태그를 업데이트합니다.
     */
    public void updateCourseTags(int courseId) {
        try {
            // 강의 평가 목록 가져오기
            List<Evaluation> evaluations = evaluationService.getEvaluationsByCourse(courseId);

            // 태그 분석
            List<String> generatedTags = TagAnalyzer.analyzeTags(evaluations);

            // 기존 강의 정보 가져오기
            Course course = getCourseById(courseId);

            if (course != null) {
                // 기존 태그와 새로 생성된 태그 병합
                List<String> existingTags = new ArrayList<>();
                if (course.getTags() != null) {
                    existingTags.addAll(Arrays.asList(course.getTags()));
                }

                // 중복 제거하면서 태그 병합
                for (String tag : generatedTags) {
                    if (!existingTags.contains(tag)) {
                        existingTags.add(tag);
                    }
                }

                // 태그 업데이트
                course.setTags(existingTags.toArray(new String[0]));

                // 데이터베이스에 저장
                updateCourse(course);

                System.out.println("DEBUG: 강의 ID " + courseId + "의 태그가 업데이트되었습니다. 태그 개수: " + existingTags.size());
            }
        } catch (Exception e) {
            System.out.println("ERROR: 태그 업데이트 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 모든 강의의 태그를 업데이트합니다.
     */
    public void updateAllCourseTags() {
        try {
            List<Course> allCourses = getAllCourses();
            for (Course course : allCourses) {
                updateCourseTags(course.getId());
            }
            System.out.println("DEBUG: 모든 강의의 태그가 업데이트되었습니다. 강의 개수: " + allCourses.size());
        } catch (Exception e) {
            System.out.println("ERROR: 모든 태그 업데이트 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
