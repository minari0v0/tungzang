package com.minari.tungzang.service;

import com.minari.tungzang.dao.CommentDAO;
import com.minari.tungzang.model.Comment;
import com.minari.tungzang.util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CommentService {

    private static final Logger LOGGER = Logger.getLogger(CommentService.class.getName());
    private CommentDAO commentDAO;
    private PostService postService;

    public CommentService() {
        this.commentDAO = new CommentDAO();
        this.postService = new PostService();
    }

    /**
     * 특정 게시글의 댓글 목록을 조회합니다.
     */
    public List<Comment> getCommentsByPostId(int postId) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return commentDAO.getCommentsByPostId(conn, postId);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 ID로 댓글 조회 중 오류 발생: " + postId, e);
            return new ArrayList<>();
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 특정 ID의 댓글을 조회합니다.
     */
    public Comment getCommentById(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return commentDAO.getCommentById(conn, id);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "ID로 댓글 조회 중 오류 발생: " + id, e);
            return null;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 특정 사용자의 댓글 목록을 조회합니다.
     */
    public List<Comment> getCommentsByUserId(int userId) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return commentDAO.getCommentsByUserId(conn, userId);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 ID로 댓글 조회 중 오류 발생: " + userId, e);
            return new ArrayList<>();
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 새로운 댓글을 추가합니다.
     */
    public int addComment(Comment comment) {
        Connection conn = null;
        try {
            // 사용자 ID 유효성 검사
            if (comment.getAuthorId() <= 0) {
                LOGGER.severe("유효하지 않은 사용자 ID: " + comment.getAuthorId());
                throw new SQLException("유효하지 않은 사용자 ID: " + comment.getAuthorId());
            }

            conn = DatabaseUtil.getConnection();
            int commentId = commentDAO.addComment(conn, comment);

            if (commentId > 0) {
                // 게시글 댓글 수 업데이트
                postService.updatePostCommentCount(comment.getPostId());
            }

            return commentId;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "댓글 추가 중 오류 발생", e);
            return -1;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 댓글을 수정합니다.
     */
    public boolean updateComment(Comment comment) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return commentDAO.updateComment(conn, comment);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "댓글 수정 중 오류 발생: " + comment.getId(), e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 댓글을 삭제합니다.
     */
    public boolean deleteComment(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            Comment comment = commentDAO.getCommentById(conn, id);

            if (comment != null) {
                boolean deleted = commentDAO.deleteComment(conn, id);

                if (deleted) {
                    // 게시글 댓글 수 업데이트
                    postService.updatePostCommentCount(comment.getPostId());
                }

                return deleted;
            }

            return false;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "댓글 삭제 중 오류 발생: " + id, e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 댓글 좋아요 수를 증가시킵니다.
     */
    public boolean incrementCommentLikes(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return commentDAO.incrementCommentLikes(conn, id);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "댓글 좋아요 증가 중 오류 발생: " + id, e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 댓글 좋아요 수를 감소시킵니다.
     */
    public boolean decrementCommentLikes(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return commentDAO.decrementCommentLikes(conn, id);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "댓글 좋아요 감소 중 오류 발생: " + id, e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 사용자가 댓글에 좋아요를 눌렀는지 확인합니다.
     */
    public boolean isCommentLikedByUser(int commentId, int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean liked = false;

        try {
            // 사용자 ID 유효성 검사
            if (userId <= 0) {
                LOGGER.severe("유효하지 않은 사용자 ID: " + userId);
                return false;
            }

            conn = DatabaseUtil.getConnection();
            String sql = "SELECT * FROM comment_likes WHERE comment_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentId);
            pstmt.setInt(2, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                liked = true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "댓글 좋아요 확인 중 오류 발생: " + commentId + ", " + userId, e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "리소스 닫기 중 오류 발생", e);
            }
        }

        return liked;
    }

    /**
     * 댓글 좋아요를 토글합니다. (좋아요가 없으면 추가, 있으면 제거)
     */
    public boolean toggleCommentLike(int commentId, int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean liked = false;
        boolean wasAutoCommit = true;

        try {
            // 사용자 ID 유효성 검사
            if (userId <= 0) {
                LOGGER.severe("유효하지 않은 사용자 ID: " + userId);
                throw new SQLException("유효하지 않은 사용자 ID: " + userId);
            }

            // 사용자 ID가 유효한지 확인
            conn = DatabaseUtil.getConnection();

            // 현재 autoCommit 상태 저장
            wasAutoCommit = conn.getAutoCommit();

            String checkUserSql = "SELECT id FROM users WHERE id = ?";
            PreparedStatement checkUserStmt = conn.prepareStatement(checkUserSql);
            checkUserStmt.setInt(1, userId);
            ResultSet userRs = checkUserStmt.executeQuery();

            if (!userRs.next()) {
                LOGGER.severe("댓글 좋아요 토글 실패: 유효하지 않은 사용자 ID: " + userId);
                throw new SQLException("유효하지 않은 사용자 ID: " + userId);
            }

            userRs.close();
            checkUserStmt.close();

            // 트랜잭션 시작
            conn.setAutoCommit(false);

            // 좋아요 여부 확인
            String checkSql = "SELECT * FROM comment_likes WHERE comment_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, commentId);
            pstmt.setInt(2, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // 좋아요가 이미 있으면 제거
                String deleteSql = "DELETE FROM comment_likes WHERE comment_id = ? AND user_id = ?";
                pstmt.close();
                pstmt = conn.prepareStatement(deleteSql);
                pstmt.setInt(1, commentId);
                pstmt.setInt(2, userId);
                pstmt.executeUpdate();

                // 댓글의 좋아요 수 감소
                String updateSql = "UPDATE comments SET likes = GREATEST(0, likes - 1) WHERE id = ?";
                pstmt.close();
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, commentId);
                pstmt.executeUpdate();

                liked = false;
            } else {
                try {
                    // 좋아요가 없으면 추가
                    String insertSql = "INSERT INTO comment_likes (comment_id, user_id) VALUES (?, ?)";
                    if (pstmt != null) pstmt.close();
                    pstmt = conn.prepareStatement(insertSql);
                    pstmt.setInt(1, commentId);
                    pstmt.setInt(2, userId);
                    pstmt.executeUpdate();

                    // 댓글의 좋아요 수 증가
                    String updateSql = "UPDATE comments SET likes = likes + 1 WHERE id = ?";
                    pstmt.close();
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setInt(1, commentId);
                    pstmt.executeUpdate();

                    liked = true;
                } catch (SQLException e) {
                    // 중복 키 예외 처리
                    if (e.getMessage() != null && e.getMessage().contains("Duplicate entry")) {
                        LOGGER.warning("이미 좋아요를 누른 댓글입니다: " + commentId + ", " + userId);
                        // 이미 좋아요가 있는 경우 제거로 처리
                        String deleteSql = "DELETE FROM comment_likes WHERE comment_id = ? AND user_id = ?";
                        if (pstmt != null) pstmt.close();
                        pstmt = conn.prepareStatement(deleteSql);
                        pstmt.setInt(1, commentId);
                        pstmt.setInt(2, userId);
                        pstmt.executeUpdate();

                        // 댓글의 좋아요 수 감소
                        String updateSql = "UPDATE comments SET likes = GREATEST(0, likes - 1) WHERE id = ?";
                        pstmt.close();
                        pstmt = conn.prepareStatement(updateSql);
                        pstmt.setInt(1, commentId);
                        pstmt.executeUpdate();

                        liked = false;
                    } else {
                        throw e;
                    }
                }
            }

            conn.commit();
        } catch (SQLException e) {
            try {
                if (conn != null && !conn.getAutoCommit()) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "롤백 중 오류 발생", ex);
            }
            LOGGER.log(Level.SEVERE, "댓글 좋아요 토글 중 오류 발생: " + commentId + ", " + userId, e);
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    // 원래 autoCommit 상태로 복원
                    conn.setAutoCommit(wasAutoCommit);
                    conn.close();
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "리소스 닫기 중 오류 발생", e);
            }
        }

        return liked;
    }

    /**
     * 월별 댓글 수를 조회합니다.
     * @return 월별 댓글 수 배열 (1월부터 12월까지)
     */
    public int[] getMonthlyCommentCounts() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int[] monthlyCounts = new int[12]; // 1월부터 12월까지

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT MONTH(date) as month, COUNT(*) as count " +
                    "FROM comments " +
                    "WHERE YEAR(date) = YEAR(CURRENT_DATE()) " +
                    "GROUP BY MONTH(date) " +
                    "ORDER BY MONTH(date)";

            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            // 초기화
            for (int i = 0; i < 12; i++) {
                monthlyCounts[i] = 0;
            }

            // 결과 매핑
            while (rs.next()) {
                int month = rs.getInt("month");
                int count = rs.getInt("count");
                if (month >= 1 && month <= 12) {
                    monthlyCounts[month - 1] = count; // 배열은 0부터 시작하므로 month-1
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "월별 댓글 수 조회 중 오류 발생", e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "리소스 닫기 중 오류 발생", e);
            }
        }

        return monthlyCounts;
    }

    /**
     * 최근 댓글 목록을 조회합니다.
     * @param limit 조회할 댓글 수
     * @return 최근 댓글 목록
     */
    public List<Comment> getRecentComments(int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Comment> comments = new ArrayList<>();

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT c.*, u.name as author_name, u.username as author_username, " +
                    "p.title as post_title " +
                    "FROM comments c " +
                    "JOIN users u ON c.author_id = u.id " +
                    "JOIN posts p ON c.post_id = p.id " +
                    "ORDER BY c.date DESC LIMIT ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Comment comment = new Comment();
                comment.setId(rs.getInt("id"));
                comment.setPostId(rs.getInt("post_id"));
                comment.setAuthorId(rs.getInt("author_id"));
                comment.setContent(rs.getString("content"));
                comment.setLikes(rs.getInt("likes"));
                comment.setDate(rs.getTimestamp("date"));
                comment.setUpdatedAt(rs.getTimestamp("updated_at"));
                comment.setAuthorName(rs.getString("author_name"));
                comment.setAuthorUsername(rs.getString("author_username"));
                comment.setPostTitle(rs.getString("post_title"));

                comments.add(comment);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "최근 댓글 조회 중 오류 발생", e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "리소스 닫기 중 오류 발생", e);
            }
        }

        return comments;
    }

    /**
     * 총 댓글 수를 조회합니다.
     * @return 총 댓글 수
     */
    public int getTotalCommentCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT COUNT(*) FROM comments";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "총 댓글 수 조회 중 오류 발생", e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "리소스 닫기 중 오류 발생", e);
            }
        }

        return count;
    }

    /**
     * 총 좋아요 수를 조회합니다.
     * @return 총 좋아요 수
     */
    public int getTotalLikesCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT SUM(likes) FROM comments";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "총 좋아요 수 조회 중 오류 발생", e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "리소스 닫기 중 오류 발생", e);
            }
        }

        return count;
    }

    /**
     * 신고된 댓글 목록을 조회합니다.
     * @return 신고된 댓글 목록
     */
    public List<Comment> getReportedComments() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Comment> comments = new ArrayList<>();

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT c.*, u.name as author_name, u.username as author_username, " +
                    "p.title as post_title " +
                    "FROM comments c " +
                    "JOIN users u ON c.author_id = u.id " +
                    "JOIN posts p ON c.post_id = p.id " +
                    "WHERE c.is_reported = true " +
                    "ORDER BY c.date DESC";

            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Comment comment = new Comment();
                comment.setId(rs.getInt("id"));
                comment.setPostId(rs.getInt("post_id"));
                comment.setAuthorId(rs.getInt("author_id"));
                comment.setContent(rs.getString("content"));
                comment.setLikes(rs.getInt("likes"));
                comment.setDate(rs.getTimestamp("date"));
                comment.setUpdatedAt(rs.getTimestamp("updated_at"));
                comment.setAuthorName(rs.getString("author_name"));
                comment.setAuthorUsername(rs.getString("author_username"));
                comment.setPostTitle(rs.getString("post_title"));
                comment.setReported(true);

                comments.add(comment);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "신고된 댓글 조회 중 오류 발생", e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "리소스 닫기 중 오류 발생", e);
            }
        }

        return comments;
    }

    /**
     * 댓글을 신고합니다.
     * @param commentId 댓글 ID
     * @param userId 신고자 ID
     * @param reason 신고 이유
     * @return 신고 성공 여부
     */
    public boolean reportComment(int commentId, int userId, String reason) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. 댓글 존재 여부 확인
            Comment comment = getCommentById(commentId);
            if (comment == null) {
                return false;
            }

            // 2. 이미 신고한 경우 확인
            String checkSql = "SELECT id FROM reports WHERE content_type = 'comment' AND content_id = ? AND reporter_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, commentId);
            pstmt.setInt(2, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    // 이미 신고한 경우
                    return false;
                }
            }

            // 3. 신고 정보 저장
            String insertSql = "INSERT INTO reports (content_type, content_id, reporter_id, reason) VALUES (?, ?, ?, ?)";
            pstmt.close();
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, "comment");
            pstmt.setInt(2, commentId);
            pstmt.setInt(3, userId);
            pstmt.setString(4, reason);

            int insertResult = pstmt.executeUpdate();

            // 4. 댓글 신고 상태 업데이트
            if (insertResult > 0) {
                pstmt.close();
                String updateSql = "UPDATE comments SET is_reported = true WHERE id = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, commentId);

                int updateResult = pstmt.executeUpdate();
                success = updateResult > 0;
            }

            if (success) {
                conn.commit();
            } else {
                conn.rollback();
            }

            return success;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "댓글 신고 중 오류 발생", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "롤백 중 오류 발생", ex);
                }
            }
            return false;
        } finally {
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "PreparedStatement 닫기 중 오류 발생", e);
                }
            }
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Connection 닫기 중 오류 발생", e);
                }
            }
        }
    }

    /**
     * 댓글 신고를 무시합니다. (관리자 기능)
     * @param commentId 댓글 ID
     * @return 성공 여부
     */
    public boolean ignoreCommentReport(int commentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "UPDATE comments SET is_reported = false WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentId);

            int result = pstmt.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "댓글 신고 무시 중 오류 발생", e);
            return false;
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "리소스 닫기 중 오류 발생", e);
            }
        }
    }

    /**
     * 특정 사용자의 모든 댓글을 삭제합니다. (회원탈퇴용)
     */
    public boolean deleteCommentsByUserId(int userId) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return commentDAO.deleteCommentsByUserId(conn, userId);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 댓글 삭제 중 오류 발생: userId=" + userId, e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

}
