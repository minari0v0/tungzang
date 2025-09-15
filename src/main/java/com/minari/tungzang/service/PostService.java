package com.minari.tungzang.service;

import com.minari.tungzang.dao.CommentDAO;
import com.minari.tungzang.dao.PostDAO;
import com.minari.tungzang.model.Post;
import com.minari.tungzang.util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PostService {

    private static final Logger LOGGER = Logger.getLogger(PostService.class.getName());
    private PostDAO postDAO;
    private CommentDAO commentDAO;

    public PostService() {
        this.postDAO = new PostDAO();
        this.commentDAO = new CommentDAO();
    }

    /**
     * 모든 게시글 목록을 조회합니다.
     */
    public List<Post> getAllPosts() {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return postDAO.getAllPosts(conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "모든 게시글 조회 중 오류 발생", e);
            return new ArrayList<>();
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 특정 ID의 게시글을 조회합니다.
     */
    public Post getPostById(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return postDAO.getPostById(conn, id);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "ID로 게시글 조회 중 오류 발생: " + id, e);
            return null;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 특정 카테고리의 게시글 목록을 조회합니다.
     */
    public List<Post> getPostsByCategory(String category) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return postDAO.getPostsByCategory(conn, category);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "카테고리로 게시글 조회 중 오류 발생: " + category, e);
            return new ArrayList<>();
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 특정 사용자의 게시글 목록을 조회합니다.
     */
    public List<Post> getPostsByUserId(int userId) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return postDAO.getPostsByUserId(conn, userId);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 ID로 게시글 조회 중 오류 발생: " + userId, e);
            return new ArrayList<>();
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 인기 게시글 목록을 조회합니다.
     */
    public List<Post> getHotPosts(int limit) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return postDAO.getHotPosts(conn, limit);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "인기 게시글 조회 중 오류 발생", e);
            return new ArrayList<>();
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 게시글을 검색합니다.
     */
    public List<Post> searchPosts(String keyword) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return postDAO.searchPosts(conn, keyword);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 검색 중 오류 발생: " + keyword, e);
            return new ArrayList<>();
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 새로운 게시글을 추가합니다.
     */
    public int addPost(Post post) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();

            // 사용자 ID 유효성 검사
            if (post.getUserId() <= 0) {
                LOGGER.severe("유효하지 않은 사용자 ID: " + post.getUserId());
                throw new SQLException("유효하지 않은 사용자 ID: " + post.getUserId());
            }

            // 사용자 ID가 유효한지 확인
            String checkUserSql = "SELECT id FROM users WHERE id = ?";
            PreparedStatement checkUserStmt = conn.prepareStatement(checkUserSql);
            checkUserStmt.setInt(1, post.getUserId());
            ResultSet userRs = checkUserStmt.executeQuery();

            if (!userRs.next()) {
                LOGGER.severe("게시글 추가 실패: 유효하지 않은 사용자 ID: " + post.getUserId());
                throw new SQLException("유효하지 않은 사용자 ID: " + post.getUserId());
            }

            userRs.close();
            checkUserStmt.close();

            return postDAO.addPost(conn, post);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 추가 중 오류 발생", e);
            return -1;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 게시글을 수정합니다.
     */
    public boolean updatePost(Post post) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();

            // 사용자 ID 유효성 검사
            if (post.getUserId() <= 0) {
                LOGGER.severe("유효하지 않은 사용자 ID: " + post.getUserId());
                throw new SQLException("유효하지 않은 사용자 ID: " + post.getUserId());
            }

            return postDAO.updatePost(conn, post);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 수정 중 오류 발생: " + post.getId(), e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 게시글을 삭제합니다.
     */
    public boolean deletePost(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return postDAO.deletePost(conn, id);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 삭제 중 오류 발생: " + id, e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 게시글 조회수를 증가시킵니다.
     */
    public boolean incrementPostViews(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return postDAO.incrementPostViews(conn, id);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 조회수 증가 중 오류 발생: " + id, e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 게시글 좋아요 수를 증가시킵니다.
     */
    public boolean incrementPostLikes(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            boolean result = postDAO.incrementPostLikes(conn, id);

            // 인기 게시글 여부 업데이트
            updatePostHotStatus(id);

            return result;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 좋아요 증가 중 오류 발생: " + id, e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 게시글 좋아요 수를 감소시킵니다.
     */
    public boolean decrementPostLikes(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            boolean result = postDAO.decrementPostLikes(conn, id);

            // 인기 게시글 여부 업데이트
            updatePostHotStatus(id);

            return result;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 좋아요 감소 중 오류 발생: " + id, e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 게시글 댓글 수를 업데이트합니다.
     */
    public boolean updatePostCommentCount(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            int commentCount = commentDAO.getCommentCountByPostId(conn, id);
            boolean result = postDAO.updatePostCommentCount(conn, id, commentCount);

            // 인기 게시글 여부 업데이트
            updatePostHotStatus(id);

            return result;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 댓글 수 업데이트 중 오류 발생: " + id, e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 게시글의 인기 여부를 업데이트합니다.
     */
    private void updatePostHotStatus(int id) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            Post post = postDAO.getPostById(conn, id);

            if (post != null) {
                // 좋아요 수가 20 이상이거나 댓글 수가 10 이상이면 인기 게시글로 설정
                boolean isHot = post.getLikes() >= 20 || post.getCommentCount() >= 10;
                postDAO.updatePostHotStatus(conn, id, isHot);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 인기 여부 업데이트 중 오류 발생: " + id, e);
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 사용자가 게시글에 좋아요를 눌렀는지 확인합니다.
     */
    public boolean isPostLikedByUser(int postId, int userId) {
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
            String sql = "SELECT * FROM post_likes WHERE post_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            pstmt.setInt(2, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                liked = true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 좋아요 확인 중 오류 발생: " + postId + ", " + userId, e);
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
     * 게시글 좋아요를 토글합니다. (좋아요가 없으면 추가, 있으면 제거)
     */
    public boolean togglePostLike(int postId, int userId) {
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
                LOGGER.severe("게시글 좋아요 토글 실패: 유효하지 않은 사용자 ID: " + userId);
                throw new SQLException("유효하지 않은 사용자 ID: " + userId);
            }

            userRs.close();
            checkUserStmt.close();

            // 트랜잭션 시작
            conn.setAutoCommit(false);

            // 좋아요 여부 확인
            String checkSql = "SELECT * FROM post_likes WHERE post_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, postId);
            pstmt.setInt(2, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // 좋아요가 이미 있으면 제거
                String deleteSql = "DELETE FROM post_likes WHERE post_id = ? AND user_id = ?";
                pstmt.close();
                pstmt = conn.prepareStatement(deleteSql);
                pstmt.setInt(1, postId);
                pstmt.setInt(2, userId);
                pstmt.executeUpdate();

                // 게시글의 좋아요 수 감소
                String updateSql = "UPDATE posts SET likes = GREATEST(0, likes - 1) WHERE id = ?";
                pstmt.close();
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, postId);
                pstmt.executeUpdate();

                liked = false;
            } else {
                try {
                    // 좋아요가 없으면 추가
                    String insertSql = "INSERT INTO post_likes (post_id, user_id) VALUES (?, ?)";
                    if (pstmt != null) pstmt.close();
                    pstmt = conn.prepareStatement(insertSql);
                    pstmt.setInt(1, postId);
                    pstmt.setInt(2, userId);
                    pstmt.executeUpdate();

                    // 게시글의 좋아요 수 증가
                    String updateSql = "UPDATE posts SET likes = likes + 1 WHERE id = ?";
                    pstmt.close();
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setInt(1, postId);
                    pstmt.executeUpdate();

                    liked = true;
                } catch (SQLException e) {
                    // 중복 키 예외 처리
                    if (e.getMessage() != null && e.getMessage().contains("Duplicate entry")) {
                        LOGGER.warning("이미 좋아요를 누른 게시글입니다: " + postId + ", " + userId);
                        // 이미 좋아요가 있는 경우 제거로 처리
                        String deleteSql = "DELETE FROM post_likes WHERE post_id = ? AND user_id = ?";
                        if (pstmt != null) pstmt.close();
                        pstmt = conn.prepareStatement(deleteSql);
                        pstmt.setInt(1, postId);
                        pstmt.setInt(2, userId);
                        pstmt.executeUpdate();

                        // 게시글의 좋아요 수 감소
                        String updateSql = "UPDATE posts SET likes = GREATEST(0, likes - 1) WHERE id = ?";
                        pstmt.close();
                        pstmt = conn.prepareStatement(updateSql);
                        pstmt.setInt(1, postId);
                        pstmt.executeUpdate();

                        liked = false;
                    } else {
                        throw e;
                    }
                }
            }

            // 인기 게시글 여부 업데이트
            String hotSql = "UPDATE posts SET is_hot = (likes >= 20 OR comment_count >= 10) WHERE id = ?";
            pstmt.close();
            pstmt = conn.prepareStatement(hotSql);
            pstmt.setInt(1, postId);
            pstmt.executeUpdate();

            conn.commit();
        } catch (SQLException e) {
            try {
                if (conn != null && !conn.getAutoCommit()) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "롤백 중 오류 발생", ex);
            }
            LOGGER.log(Level.SEVERE, "게시글 좋아요 토글 중 오류 발생: " + postId + ", " + userId, e);
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
     * 신고된 게시글 목록을 조회합니다.
     * @return 신고된 게시글 목록
     */
    public List<Post> getReportedPosts() {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return postDAO.getReportedPosts(conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "신고된 게시글 조회 중 오류 발생", e);
            return new ArrayList<>();
        } finally {
            DatabaseUtil.close(conn);
        }
    }

    /**
     * 게시글을 신고합니다.
     * @param postId 게시글 ID
     * @param userId 신고자 ID
     * @param reason 신고 사유
     * @return 신고 성공 여부
     */
    public boolean reportPost(int postId, int userId, String reason) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DatabaseUtil.getConnection();

            // 1. 게시글 존재 여부 확인
            Post post = getPostById(postId);
            if (post == null) {
                LOGGER.severe("게시글 ID " + postId + "를 찾을 수 없습니다.");
                return false;
            }

            // 2. 게시글 신고 상태 업데이트
            String updateSql = "UPDATE posts SET is_reported = true WHERE id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setInt(1, postId);

            int updateResult = pstmt.executeUpdate();
            success = updateResult > 0;

            if (success) {
                LOGGER.info("게시글 ID " + postId + " 신고 성공 (신고자 ID: " + userId + ")");
            } else {
                LOGGER.severe("게시글 ID " + postId + " 신고 실패 (신고자 ID: " + userId + ")");
            }

            return success;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 신고 중 오류 발생", e);
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
     * 게시글 신고를 무시합니다. (관리자 기능)
     * @param postId 게시글 ID
     * @return 성공 여부
     */
    public boolean ignorePostReport(int postId) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "UPDATE posts SET is_reported = false WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);

            int result = pstmt.executeUpdate();
            boolean success = result > 0;

            if (success) {
                LOGGER.info("게시글 ID " + postId + " 신고 무시 성공");
            } else {
                LOGGER.severe("게시글 ID " + postId + " 신고 무시 실패");
            }

            return success;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 신고 무시 중 오류 발생", e);
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
     * 특정 사용자의 모든 게시글을 삭제합니다. (회원탈퇴용)
     */
    public boolean deletePostsByUserId(int userId) {
        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            return postDAO.deletePostsByUserId(conn, userId);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 게시글 삭제 중 오류 발생: userId=" + userId, e);
            return false;
        } finally {
            DatabaseUtil.close(conn);
        }
    }
}
