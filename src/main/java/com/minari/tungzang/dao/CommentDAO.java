package com.minari.tungzang.dao;

import com.minari.tungzang.model.Comment;
import com.minari.tungzang.util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CommentDAO {

    private static final Logger LOGGER = Logger.getLogger(CommentDAO.class.getName());

    /**
     * 특정 게시글의 댓글 목록을 조회합니다.
     */
    public List<Comment> getCommentsByPostId(Connection conn, int postId) throws SQLException {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT c.*, u.name as author_name, u.username as author_username " +
                "FROM comments c " +
                "JOIN users u ON c.author_id = u.id " +
                "WHERE c.post_id = ? " +
                "ORDER BY c.date DESC";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Comment comment = mapResultSetToComment(rs);
                comments.add(comment);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return comments;
    }

    /**
     * 특정 ID의 댓글을 조회합니다.
     */
    public Comment getCommentById(Connection conn, int id) throws SQLException {
        String sql = "SELECT c.*, u.name as author_name, u.username as author_username " +
                "FROM comments c " +
                "JOIN users u ON c.author_id = u.id " +
                "WHERE c.id = ?";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToComment(rs);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return null;
    }

    /**
     * 특정 사용자의 댓글 목록을 조회합니다.
     */
    public List<Comment> getCommentsByUserId(Connection conn, int userId) throws SQLException {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT c.*, u.name as author_name, u.username as author_username, " +
                "p.title as post_title " +
                "FROM comments c " +
                "JOIN users u ON c.author_id = u.id " +
                "JOIN posts p ON c.post_id = p.id " +
                "WHERE c.author_id = ? " +
                "ORDER BY c.date DESC";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Comment comment = mapResultSetToComment(rs);
                comments.add(comment);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return comments;
    }

    /**
     * 새로운 댓글을 추가합니다.
     */
    public int addComment(Connection conn, Comment comment) throws SQLException {
        String sql = "INSERT INTO comments (post_id, author_id, content, likes) VALUES (?, ?, ?, 0)";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // 사용자 ID가 유효한지 확인
            String checkUserSql = "SELECT id FROM users WHERE id = ?";
            PreparedStatement checkUserStmt = conn.prepareStatement(checkUserSql);
            checkUserStmt.setInt(1, comment.getAuthorId());
            ResultSet userRs = checkUserStmt.executeQuery();

            if (!userRs.next()) {
                LOGGER.log(Level.SEVERE, "댓글 추가 실패: 유효하지 않은 사용자 ID: " + comment.getAuthorId());
                throw new SQLException("유효하지 않은 사용자 ID: " + comment.getAuthorId());
            }

            userRs.close();
            checkUserStmt.close();

            // 게시글 ID가 유효한지 확인
            String checkPostSql = "SELECT id FROM posts WHERE id = ?";
            PreparedStatement checkPostStmt = conn.prepareStatement(checkPostSql);
            checkPostStmt.setInt(1, comment.getPostId());
            ResultSet postRs = checkPostStmt.executeQuery();

            if (!postRs.next()) {
                LOGGER.log(Level.SEVERE, "댓글 추가 실패: 유효하지 않은 게시글 ID: " + comment.getPostId());
                throw new SQLException("유효하지 않은 게시글 ID: " + comment.getPostId());
            }

            postRs.close();
            checkPostStmt.close();

            // 댓글 추가
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setInt(1, comment.getPostId());
            pstmt.setInt(2, comment.getAuthorId());
            pstmt.setString(3, comment.getContent());

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("댓글 추가 실패, 영향받은 행이 없습니다.");
            }

            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            } else {
                throw new SQLException("댓글 추가 실패, ID를 가져올 수 없습니다.");
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }
    }


    /**
     * 댓글을 수정합니다.
     */
    public boolean updateComment(Connection conn, Comment comment) throws SQLException {
        String sql = "UPDATE comments SET content = ? WHERE id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, comment.getContent());
            pstmt.setInt(2, comment.getId());

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } finally {
            DatabaseUtil.close(pstmt);
        }
    }

    /**
     * 댓글을 삭제합니다.
     */
    public boolean deleteComment(Connection conn, int id) throws SQLException {
        String sql = "DELETE FROM comments WHERE id = ?";

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
     * 특정 게시글의 댓글 수를 조회합니다.
     */
    public int getCommentCountByPostId(Connection conn, int postId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM comments WHERE post_id = ?";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return 0;
    }

    /**
     * 댓글 좋아요 수를 증가시킵니다.
     */
    public boolean incrementCommentLikes(Connection conn, int id) throws SQLException {
        String sql = "UPDATE comments SET likes = likes + 1 WHERE id = ?";

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
     * 댓글 좋아요 수를 감소시킵니다.
     */
    public boolean decrementCommentLikes(Connection conn, int id) throws SQLException {
        String sql = "UPDATE comments SET likes = GREATEST(0, likes - 1) WHERE id = ?";

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
     * ResultSet에서 Comment 객체로 매핑합니다.
     */
    private Comment mapResultSetToComment(ResultSet rs) throws SQLException {
        Comment comment = new Comment();
        comment.setId(rs.getInt("id"));
        comment.setPostId(rs.getInt("post_id"));
        comment.setAuthorId(rs.getInt("author_id"));
        comment.setContent(rs.getString("content"));
        comment.setLikes(rs.getInt("likes"));
        comment.setDate(rs.getTimestamp("date"));
        comment.setUpdatedAt(rs.getTimestamp("updated_at"));

        // 조인된 필드가 있는 경우
        try {
            comment.setAuthorName(rs.getString("author_name"));
            comment.setAuthorUsername(rs.getString("author_username"));
        } catch (SQLException e) {
            // 조인된 필드가 없는 경우 무시
        }

        try {
            comment.setReported(rs.getBoolean("is_reported"));
        } catch (SQLException e) {
            // is_reported 컬럼이 없는 경우 기본값 false 설정
            comment.setReported(false);
        }

        return comment;
    }

    // 댓글 수 조회
    public int getCommentCount() {
        String sql = "SELECT COUNT(*) FROM comments";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 최근 댓글 조회
    public List<Comment> getRecentComments(int limit) {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT c.*, u.name AS author_name, u.username AS author_username, p.title AS post_title " +
                "FROM comments c " +
                "JOIN users u ON c.author_id = u.id " +
                "JOIN posts p ON c.post_id = p.id " +
                "ORDER BY c.date DESC LIMIT ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            try (ResultSet rs = pstmt.executeQuery()) {
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
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }

    // 월별 댓글 수 조회
    public String getMonthlyCommentCounts() {
        StringBuilder counts = new StringBuilder("[");
        String sql = "SELECT MONTH(date) as month, COUNT(*) as count " +
                "FROM comments " +
                "WHERE YEAR(date) = YEAR(CURRENT_DATE()) " +
                "GROUP BY MONTH(date) " +
                "ORDER BY month";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            // 1월부터 12월까지의 데이터를 저장할 배열
            int[] monthCounts = new int[12];

            // 결과에서 월별 데이터 추출
            while (rs.next()) {
                int month = rs.getInt("month");
                int count = rs.getInt("count");
                if (month >= 1 && month <= 12) {
                    monthCounts[month - 1] = count;
                }
            }

            // 배열을 JSON 형식의 문자열로 변환
            for (int i = 0; i < 12; i++) {
                counts.append(monthCounts[i]);
                if (i < 11) {
                    counts.append(", ");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // 오류 발생 시 기본값 반환
            return "[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]";
        }

        counts.append("]");
        return counts.toString();
    }

    // 댓글 좋아요 총합 조회
    public int getTotalLikes() {
        String sql = "SELECT SUM(likes) FROM comments";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * 신고된 댓글 목록을 조회합니다.
     * @return 신고된 댓글 목록
     */
    public List<Comment> getReportedComments() {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT c.*, u.name as author_name, u.username as author_username, " +
                "p.title as post_title " +
                "FROM comments c " +
                "JOIN users u ON c.author_id = u.id " +
                "JOIN posts p ON c.post_id = p.id " +
                "WHERE c.is_reported = true " +
                "ORDER BY c.date DESC";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Comment comment = mapResultSetToComment(rs);
                comment.setPostTitle(rs.getString("post_title"));
                comments.add(comment);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "신고된 댓글 조회 중 오류 발생", e);
        }

        return comments;
    }

    /**
     * 댓글 신고 상태를 업데이트합니다.
     * @param commentId 댓글 ID
     * @param isReported 신고 상태 (true: 신고됨, false: 신고되지 않음)
     * @return 업데이트 성공 여부
     */
    public boolean updateCommentReportStatus(int commentId, boolean isReported) {
        String sql = "UPDATE comments SET is_reported = ? WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBoolean(1, isReported);
            pstmt.setInt(2, commentId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "댓글 신고 상태 업데이트 중 오류 발생", e);
            return false;
        }
    }

    // 배지에 필요한 메소드
    public int getUserCommentCount(int userId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT COUNT(*) FROM comments WHERE author_id = ?";
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
     * 특정 사용자의 모든 댓글을 삭제합니다.
     */
    public boolean deleteCommentsByUserId(Connection conn, int userId) throws SQLException {
        String sql = "DELETE FROM comments WHERE author_id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);

            int affectedRows = pstmt.executeUpdate();
            LOGGER.info("사용자의 모든 댓글 삭제: userId=" + userId + ", 영향받은 행: " + affectedRows);

            return true; // 삭제할 댓글이 없어도 성공으로 간주

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자의 모든 댓글 삭제 중 오류 발생", e);
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

}
