package com.minari.tungzang.controller;

import com.minari.tungzang.dao.CommentDAO;
import com.minari.tungzang.dao.EvaluationDAO;
import com.minari.tungzang.dao.PostDAO;
import com.minari.tungzang.model.User;
import com.minari.tungzang.util.DatabaseUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/reports/*")
public class AdminReportServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminReportServlet.class.getName());

    private PostDAO postDAO;
    private CommentDAO commentDAO;
    private EvaluationDAO evaluationDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        postDAO = new PostDAO();
        commentDAO = new CommentDAO();
        evaluationDAO = new EvaluationDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 관리자 권한 확인
        if (user == null || !user.isAdmin()) {
            sendJsonResponse(response, false, "관리자 권한이 필요합니다.");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            sendJsonResponse(response, false, "잘못된 요청입니다.");
            return;
        }

        LOGGER.info("AdminReportServlet 요청: " + pathInfo);

        try {
            if (pathInfo.startsWith("/delete-post/")) {
                handleDeletePost(request, response, user);
            } else if (pathInfo.startsWith("/delete-comment/")) {
                handleDeleteComment(request, response, user);
            } else if (pathInfo.startsWith("/delete-evaluation/")) {
                handleDeleteEvaluation(request, response, user);
            } else if (pathInfo.startsWith("/ignore-post/")) {
                handleIgnorePostReport(request, response, user);
            } else if (pathInfo.startsWith("/ignore-comment/")) {
                handleIgnoreCommentReport(request, response, user);
            } else if (pathInfo.startsWith("/ignore-evaluation/")) {
                handleIgnoreEvaluationReport(request, response, user);
            } else {
                sendJsonResponse(response, false, "요청한 기능을 찾을 수 없습니다.");
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "잘못된 ID 형식", e);
            sendJsonResponse(response, false, "잘못된 ID 형식입니다.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "신고 처리 중 오류 발생", e);
            sendJsonResponse(response, false, "서버 오류가 발생했습니다: " + e.getMessage());
        }
    }

    private void handleDeletePost(HttpServletRequest request, HttpServletResponse response, User admin) throws IOException {
        int postId = extractIdFromPath(request.getPathInfo(), "/delete-post/");
        if (postId <= 0) {
            sendJsonResponse(response, false, "유효하지 않은 게시글 ID입니다.");
            return;
        }

        LOGGER.info("게시글 삭제 시도: ID=" + postId);

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // 먼저 댓글들을 삭제
            String deleteCommentsSQL = "DELETE FROM comments WHERE post_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteCommentsSQL)) {
                pstmt.setInt(1, postId);
                int deletedComments = pstmt.executeUpdate();
                LOGGER.info("게시글 " + postId + "의 댓글 " + deletedComments + "개 삭제됨");
            }

            // 게시글 삭제
            boolean success = postDAO.deletePost(conn, postId);

            if (success) {
                conn.commit();
                LOGGER.info("게시글 삭제 성공: ID=" + postId);
                sendJsonResponse(response, true, "게시글이 성공적으로 삭제되었습니다.");
            } else {
                conn.rollback();
                LOGGER.warning("게시글 삭제 실패: ID=" + postId);
                sendJsonResponse(response, false, "게시글 삭제에 실패했습니다.");
            }
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            LOGGER.log(Level.SEVERE, "게시글 삭제 중 오류", e);
            sendJsonResponse(response, false, "게시글 삭제 중 오류가 발생했습니다.");
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

    private void handleDeleteComment(HttpServletRequest request, HttpServletResponse response, User admin) throws IOException {
        int commentId = extractIdFromPath(request.getPathInfo(), "/delete-comment/");
        if (commentId <= 0) {
            sendJsonResponse(response, false, "유효하지 않은 댓글 ID입니다.");
            return;
        }

        LOGGER.info("댓글 삭제 시도: ID=" + commentId);

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            boolean success = commentDAO.deleteComment(conn, commentId);

            if (success) {
                LOGGER.info("댓글 삭제 성공: ID=" + commentId);
                sendJsonResponse(response, true, "댓글이 성공적으로 삭제되었습니다.");
            } else {
                LOGGER.warning("댓글 삭제 실패: ID=" + commentId);
                sendJsonResponse(response, false, "댓글 삭제에 실패했습니다.");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "댓글 삭제 중 오류", e);
            sendJsonResponse(response, false, "댓글 삭제 중 오류가 발생했습니다.");
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    private void handleDeleteEvaluation(HttpServletRequest request, HttpServletResponse response, User admin) throws IOException {
        int evaluationId = extractIdFromPath(request.getPathInfo(), "/delete-evaluation/");
        if (evaluationId <= 0) {
            sendJsonResponse(response, false, "유효하지 않은 강의평가 ID입니다.");
            return;
        }

        LOGGER.info("강의평가 삭제 시도: ID=" + evaluationId);

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. evaluation_features 테이블에서 특성 삭제
            String deleteFeaturesSql = "DELETE FROM evaluation_features WHERE evaluation_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteFeaturesSql)) {
                pstmt.setInt(1, evaluationId);
                int deletedFeatures = pstmt.executeUpdate();
                LOGGER.info("강의평가 " + evaluationId + "의 특성 " + deletedFeatures + "개 삭제됨");
            }

            // 2. evaluations 테이블에서 평가 삭제 (관리자는 userId 체크 없이 삭제)
            String deleteEvalSql = "DELETE FROM evaluations WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteEvalSql)) {
                pstmt.setInt(1, evaluationId);
                int rowsAffected = pstmt.executeUpdate();

                if (rowsAffected > 0) {
                    conn.commit();
                    LOGGER.info("강의평가 삭제 성공: ID=" + evaluationId);
                    sendJsonResponse(response, true, "강의평가가 성공적으로 삭제되었습니다.");
                } else {
                    conn.rollback();
                    LOGGER.warning("강의평가 삭제 실패: ID=" + evaluationId);
                    sendJsonResponse(response, false, "강의평가 삭제에 실패했습니다.");
                }
            }
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            LOGGER.log(Level.SEVERE, "강의평가 삭제 중 오류", e);
            sendJsonResponse(response, false, "강의평가 삭제 중 오류가 발생했습니다.");
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

    private void handleIgnorePostReport(HttpServletRequest request, HttpServletResponse response, User admin) throws IOException {
        int postId = extractIdFromPath(request.getPathInfo(), "/ignore-post/");
        if (postId <= 0) {
            sendJsonResponse(response, false, "유효하지 않은 게시글 ID입니다.");
            return;
        }

        LOGGER.info("게시글 신고 무시 시도: ID=" + postId);

        try {
            boolean success = postDAO.updatePostReportStatus(postId, false);

            if (success) {
                LOGGER.info("게시글 신고 무시 성공: ID=" + postId);
                sendJsonResponse(response, true, "게시글 신고가 무시되었습니다.");
            } else {
                LOGGER.warning("게시글 신고 무시 실패: ID=" + postId);
                sendJsonResponse(response, false, "게시글 신고 무시에 실패했습니다.");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "게시글 신고 무시 중 오류", e);
            sendJsonResponse(response, false, "게시글 신고 무시 중 오류가 발생했습니다.");
        }
    }

    private void handleIgnoreCommentReport(HttpServletRequest request, HttpServletResponse response, User admin) throws IOException {
        int commentId = extractIdFromPath(request.getPathInfo(), "/ignore-comment/");
        if (commentId <= 0) {
            sendJsonResponse(response, false, "유효하지 않은 댓글 ID입니다.");
            return;
        }

        LOGGER.info("댓글 신고 무시 시도: ID=" + commentId);

        try {
            boolean success = commentDAO.updateCommentReportStatus(commentId, false);

            if (success) {
                LOGGER.info("댓글 신고 무시 성공: ID=" + commentId);
                sendJsonResponse(response, true, "댓글 신고가 무시되었습니다.");
            } else {
                LOGGER.warning("댓글 신고 무시 실패: ID=" + commentId);
                sendJsonResponse(response, false, "댓글 신고 무시에 실패했습니다.");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "댓글 신고 무시 중 오류", e);
            sendJsonResponse(response, false, "댓글 신고 무시 중 오류가 발생했습니다.");
        }
    }

    private void handleIgnoreEvaluationReport(HttpServletRequest request, HttpServletResponse response, User admin) throws IOException {
        int evaluationId = extractIdFromPath(request.getPathInfo(), "/ignore-evaluation/");
        if (evaluationId <= 0) {
            sendJsonResponse(response, false, "유효하지 않은 강의평가 ID입니다.");
            return;
        }

        LOGGER.info("강의평가 신고 무시 시도: ID=" + evaluationId);

        try {
            boolean success = evaluationDAO.updateEvaluationReportStatus(evaluationId, false);

            if (success) {
                LOGGER.info("강의평가 신고 무시 성공: ID=" + evaluationId);
                sendJsonResponse(response, true, "강의평가 신고가 무시되었습니다.");
            } else {
                LOGGER.warning("강의평가 신고 무시 실패: ID=" + evaluationId);
                sendJsonResponse(response, false, "강의평가 신고 무시에 실패했습니다.");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "강의평가 신고 무시 중 오류", e);
            sendJsonResponse(response, false, "강의평가 신고 무시 중 오류가 발생했습니다.");
        }
    }

    private int extractIdFromPath(String pathInfo, String prefix) {
        try {
            String idStr = pathInfo.substring(prefix.length());
            return Integer.parseInt(idStr);
        } catch (NumberFormatException | IndexOutOfBoundsException e) {
            return -1;
        }
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        out.print("{\"success\": " + success + ", \"message\": \"" + message + "\"}");
        out.flush();
    }
}
