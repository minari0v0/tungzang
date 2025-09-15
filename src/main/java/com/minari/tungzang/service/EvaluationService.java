package com.minari.tungzang.service;

import com.minari.tungzang.dao.EvaluationDAO;
import com.minari.tungzang.dao.CourseDAO;
import com.minari.tungzang.model.Evaluation;
import com.minari.tungzang.model.Course;
import com.minari.tungzang.model.TimetableCourse;
import com.minari.tungzang.model.User;
import com.minari.tungzang.util.DatabaseUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class EvaluationService {

    private EvaluationDAO evaluationDAO;
    private CourseDAO courseDAO;

    public EvaluationService() {
        this.evaluationDAO = new EvaluationDAO();
        this.courseDAO = new CourseDAO();
    }


    public List<Evaluation> getEvaluationsByCourse(int courseId) {
        System.out.println("DEBUG: 강의 ID " + courseId + "의 평가 목록 조회 중");
        return evaluationDAO.getEvaluationsByCourseId(courseId);
    }

    public List<Evaluation> getRecentEvaluations(int limit) {
        System.out.println("DEBUG: 최근 평가 " + limit + "개 조회 중");
        return evaluationDAO.getRecentEvaluations(limit);
    }

    public List<Evaluation> getUserEvaluations(int userId) {
        System.out.println("DEBUG: 사용자 ID " + userId + "의 평가 목록 조회 중");
        return evaluationDAO.getEvaluationsByUserId(userId);
    }

    public Course getCourseById(int courseId) {
        System.out.println("DEBUG: 강의 ID " + courseId + " 조회 중");
        try (Connection conn = DatabaseUtil.getConnection()) {
            return courseDAO.getCourseById(conn, courseId);
        } catch (Exception e) {
            System.err.println("ERROR: 강의 조회 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public List<Course> searchCourses(String keyword) {
        System.out.println("DEBUG: 키워드 '" + keyword + "'로 강의 검색 중");
        try (Connection conn = DatabaseUtil.getConnection()) {
            return courseDAO.searchCourses(conn, keyword);
        } catch (Exception e) {
            System.err.println("ERROR: 강의 검색 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public List<Course> getPopularCourses(int limit) {
        System.out.println("DEBUG: 인기 강의 " + limit + "개 조회 중");
        try (Connection conn = DatabaseUtil.getConnection()) {
            return courseDAO.getPopularCourses(conn, limit);
        } catch (Exception e) {
            System.err.println("ERROR: 인기 강의 조회 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public Evaluation getEvaluationById(int evaluationId) {
        System.out.println("DEBUG: 평가 ID " + evaluationId + " 조회 중");
        return evaluationDAO.getEvaluationById(evaluationId);
    }

    // 모든 평가 조회
    public List<Evaluation> getAllEvaluations() {
        System.out.println("DEBUG: 모든 평가 조회 중");
        return evaluationDAO.getAllEvaluations();
    }

    // 기존의 평가 업데이트 메소드 추가
    public boolean updateEvaluation(Evaluation evaluation) {
        System.out.println("DEBUG: 평가 ID " + evaluation.getId() + " 업데이트 중");
        return evaluationDAO.updateEvaluation(evaluation);
    }

    /**
     * 강의 평가를 추가합니다.
     */
    public boolean addEvaluation(Evaluation evaluation) {
        System.out.println("DEBUG: EvaluationService.addEvaluation 시작");
        System.out.println("DEBUG: 강의 ID: " + evaluation.getCourseId());
        System.out.println("DEBUG: 사용자 ID: " + evaluation.getUserId());
        System.out.println("DEBUG: 평점: " + evaluation.getRating());

        try {
            // 필수 필드 검증
            if (evaluation.getCourseId() <= 0) {
                System.out.println("ERROR: 유효하지 않은 강의 ID: " + evaluation.getCourseId());
                return false;
            }

            if (evaluation.getUserId() <= 0) {
                System.out.println("ERROR: 유효하지 않은 사용자 ID: " + evaluation.getUserId());
                return false;
            }

            if (evaluation.getRating() < 1 || evaluation.getRating() > 5) {
                System.out.println("ERROR: 유효하지 않은 평점: " + evaluation.getRating());
                return false;
            }

            // 중복 평가 확인
            List<Evaluation> userEvaluations = evaluationDAO.getEvaluationsByUserId(evaluation.getUserId());
            for (Evaluation e : userEvaluations) {
                if (e.getCourseId() == evaluation.getCourseId()) {
                    System.out.println("ERROR: 이미 평가한 강의입니다. 강의 ID: " + evaluation.getCourseId());
                    return false;
                }
            }

            // 평가 저장
            boolean result = evaluationDAO.addEvaluation(evaluation);
            System.out.println("DEBUG: 평가 저장 결과: " + (result ? "성공" : "실패"));
            return result;
        } catch (Exception e) {
            System.out.println("ERROR: 평가 추가 중 예외 발생: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 강의 평가를 삭제합니다.
     *
     * @param evaluationId 삭제할 평가 ID
     * @param userId 삭제 요청한 사용자 ID (작성자 확인용)
     * @return 삭제 성공 여부
     */
    public boolean deleteEvaluation(int evaluationId, int userId) {
        System.out.println("DEBUG: 평가 ID " + evaluationId + " 삭제 중 (사용자 ID: " + userId + ")");

        try {
            // 평가 조회
            Evaluation evaluation = getEvaluationById(evaluationId);

            if (evaluation == null) {
                System.out.println("ERROR: 평가 ID " + evaluationId + "를 찾을 수 없습니다.");
                return false;
            }

            // 작성자 확인
            if (evaluation.getUserId() != userId) {
                System.out.println("ERROR: 사용자 ID " + userId + "는 평가 ID " + evaluationId + "의 작성자가 아닙니다.");
                return false;
            }

            // 평가 삭제
            boolean result = evaluationDAO.deleteEvaluation(evaluationId, userId);
            System.out.println("DEBUG: 평가 삭제 결과: " + (result ? "성공" : "실패"));

            return result;
        } catch (Exception e) {
            System.out.println("ERROR: 평가 삭제 중 예외 발생: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 신고된 강의평가 목록을 조회합니다.
     * @return 신고된 강의평가 목록
     */
    public List<Evaluation> getReportedEvaluations() {
        System.out.println("DEBUG: 신고된 강의평가 목록 조회 중");
        return evaluationDAO.getReportedEvaluations();
    }

    /**
     * 강의평가를 신고합니다.
     * @param evaluationId 강의평가 ID
     * @param userId 신고자 ID
     * @param reason 신고 이유
     * @return 신고 성공 여부
     */
    public boolean reportEvaluation(int evaluationId, int userId, String reason) {
        System.out.println("DEBUG: 강의평가 ID " + evaluationId + " 신고 중 (사용자 ID: " + userId + ")");

        try {
            // 강의평가 조회
            Evaluation evaluation = getEvaluationById(evaluationId);

            if (evaluation == null) {
                System.out.println("ERROR: 강의평가 ID " + evaluationId + "를 찾을 수 없습니다.");
                return false;
            }

            // 자신의 강의평가는 신고할 수 없음
            if (evaluation.getUserId() == userId) {
                System.out.println("ERROR: 사용자 ID " + userId + "는 자신의 강의평가를 신고할 수 없습니다.");
                return false;
            }

            // 강의평가 신고
            boolean result = evaluationDAO.reportEvaluation(evaluationId, userId, reason);
            System.out.println("DEBUG: 강의평가 신고 결과: " + (result ? "성공" : "실패"));

            return result;
        } catch (Exception e) {
            System.out.println("ERROR: 강의평가 신고 중 예외 발생: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 강의평가 신고를 무시합니다. (관리자 기능)
     * @param evaluationId 강의평가 ID
     * @return 성공 여부
     */
    public boolean ignoreEvaluationReport(int evaluationId) {
        System.out.println("DEBUG: 강의평가 ID " + evaluationId + " 신고 무시 중");
        return evaluationDAO.ignoreEvaluationReport(evaluationId);
    }

    /**
     * 특정 사용자의 모든 강의평가를 삭제합니다. (회원탈퇴용)
     */
    public boolean deleteEvaluationsByUserId(int userId) {
        System.out.println("DEBUG: 사용자 ID " + userId + "의 모든 강의평가 삭제 중");
        return evaluationDAO.deleteEvaluationsByUserId(userId);
    }

}
