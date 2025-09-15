package com.minari.tungzang.dao;

import com.minari.tungzang.model.Post;
import com.minari.tungzang.util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PostDAO {

    private static final Logger LOGGER = Logger.getLogger(PostDAO.class.getName());

    /**
     * 모든 게시글 목록을 조회합니다.
     */
    public List<Post> getAllPosts(Connection conn) throws SQLException {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.*, u.name as author_name, u.username as author_username " +
                "FROM posts p " +
                "JOIN users u ON p.author_id = u.id " +
                "ORDER BY p.date DESC";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Post post = mapResultSetToPost(rs);
                posts.add(post);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return posts;
    }

    /**
     * 특정 ID의 게시글을 조회합니다.
     */
    public Post getPostById(Connection conn, int id) throws SQLException {
        String sql = "SELECT p.*, u.name as author_name, u.username as author_username " +
                "FROM posts p " +
                "JOIN users u ON p.author_id = u.id " +
                "WHERE p.id = ?";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToPost(rs);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return null;
    }

    /**
     * 특정 카테고리의 게시글 목록을 조회합니다.
     */
    public List<Post> getPostsByCategory(Connection conn, String category) throws SQLException {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.*, u.name as author_name, u.username as author_username " +
                "FROM posts p " +
                "JOIN users u ON p.author_id = u.id " +
                "WHERE p.category = ? " +
                "ORDER BY p.date DESC";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, category);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Post post = mapResultSetToPost(rs);
                posts.add(post);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return posts;
    }

    /**
     * 특정 사용자의 게시글 목록을 조회합니다.
     */
    public List<Post> getPostsByUserId(Connection conn, int userId) throws SQLException {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.*, u.name as author_name, u.username as author_username " +
                "FROM posts p " +
                "JOIN users u ON p.author_id = u.id " +
                "WHERE p.author_id = ? " +
                "ORDER BY p.date DESC";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Post post = mapResultSetToPost(rs);
                posts.add(post);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return posts;
    }

    /**
     * 인기 게시글 목록을 조회합니다.
     */
    public List<Post> getHotPosts(Connection conn, int limit) throws SQLException {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.*, u.name as author_name, u.username as author_username " +
                "FROM posts p " +
                "JOIN users u ON p.author_id = u.id " +
                "WHERE p.is_hot = TRUE " +
                "ORDER BY p.likes DESC, p.comment_count DESC, p.date DESC " +
                "LIMIT ?";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Post post = mapResultSetToPost(rs);
                posts.add(post);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return posts;
    }

    /**
     * 게시글을 검색합니다.
     */
    public List<Post> searchPosts(Connection conn, String keyword) throws SQLException {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.*, u.name as author_name, u.username as author_username " +
                "FROM posts p " +
                "JOIN users u ON p.author_id = u.id " +
                "WHERE p.title LIKE ? OR p.content LIKE ? " +
                "ORDER BY p.date DESC";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            String searchKeyword = "%" + keyword + "%";
            pstmt.setString(1, searchKeyword);
            pstmt.setString(2, searchKeyword);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Post post = mapResultSetToPost(rs);
                posts.add(post);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return posts;
    }

    /**
     * 새로운 게시글을 추가합니다.
     */
    public int addPost(Connection conn, Post post) throws SQLException {
        String sql = "INSERT INTO posts (title, content, category, author_id, likes, comment_count, views, is_hot) " +
                "VALUES (?, ?, ?, ?, 0, 0, 0, FALSE)";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, post.getTitle());
            pstmt.setString(2, post.getContent());
            pstmt.setString(3, post.getCategory());
            pstmt.setInt(4, post.getAuthorId());

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("게시글 추가 실패, 영향받은 행이 없습니다.");
            }

            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            } else {
                throw new SQLException("게시글 추가 실패, ID를 가져올 수 없습니다.");
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }
    }

    /**
     * 게시글을 수정합니다.
     */
    public boolean updatePost(Connection conn, Post post) throws SQLException {
        String sql = "UPDATE posts SET title = ?, content = ?, category = ? WHERE id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, post.getTitle());
            pstmt.setString(2, post.getContent());
            pstmt.setString(3, post.getCategory());
            pstmt.setInt(4, post.getId());

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } finally {
            DatabaseUtil.close(pstmt);
        }
    }

    /**
     * 게시글을 삭제합니다.
     */
    public boolean deletePost(Connection conn, int id) throws SQLException {
        String sql = "DELETE FROM posts WHERE id = ?";

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
     * 게시글 조회수를 증가시킵니다.
     */
    public boolean incrementPostViews(Connection conn, int id) throws SQLException {
        String sql = "UPDATE posts SET views = views + 1 WHERE id = ?";

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
     * 게시글 좋아요 수를 증가시킵니다.
     */
    public boolean incrementPostLikes(Connection conn, int id) throws SQLException {
        String sql = "UPDATE posts SET likes = likes + 1 WHERE id = ?";

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
     * 게시글 좋아요 수를 감소시킵니다.
     */
    public boolean decrementPostLikes(Connection conn, int id) throws SQLException {
        String sql = "UPDATE posts SET likes = GREATEST(0, likes - 1) WHERE id = ?";

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
     * 게시글 댓글 수를 업데이트합니다.
     */
    public boolean updatePostCommentCount(Connection conn, int id, int commentCount) throws SQLException {
        String sql = "UPDATE posts SET comment_count = ? WHERE id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentCount);
            pstmt.setInt(2, id);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } finally {
            DatabaseUtil.close(pstmt);
        }
    }

    /**
     * 게시글의 인기 여부를 업데이트합니다.
     */
    public boolean updatePostHotStatus(Connection conn, int id, boolean isHot) throws SQLException {
        String sql = "UPDATE posts SET is_hot = ? WHERE id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setBoolean(1, isHot);
            pstmt.setInt(2, id);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } finally {
            DatabaseUtil.close(pstmt);
        }
    }

    /**
     * ResultSet에서 Post 객체로 매핑합니다.
     */
    // ResultSet에서 Post 객체로 매핑하는 메소드 수정
    private Post mapResultSetToPost(ResultSet rs) throws SQLException {
        Post post = new Post();
        post.setId(rs.getInt("id"));
        post.setTitle(rs.getString("title"));
        post.setContent(rs.getString("content"));
        post.setCategory(rs.getString("category"));
        post.setAuthorId(rs.getInt("author_id"));
        post.setLikes(rs.getInt("likes"));
        post.setCommentCount(rs.getInt("comment_count"));
        post.setViews(rs.getInt("views"));
        post.setHot(rs.getBoolean("is_hot"));
        post.setDate(rs.getTimestamp("date"));
        post.setUpdatedAt(rs.getTimestamp("updated_at"));

        // is_reported 컬럼이 있는 경우에만 설정
        try {
            post.setReported(rs.getBoolean("is_reported"));
        } catch (SQLException e) {
            // 컬럼이 없는 경우 기본값 false 설정
            post.setReported(false);
        }

        // 조인된 필드가 있는 경우
        try {
            post.setAuthorName(rs.getString("author_name"));
            post.setAuthorUsername(rs.getString("author_username"));
        } catch (SQLException e) {
            // 조인된 필드가 없는 경우 무시
        }

        return post;
    }

    // 신고된 게시글 조회 메서드 수정
    public List<Post> getReportedPosts(Connection conn) throws SQLException {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.*, u.name as author_name, u.username as author_username " +
                "FROM posts p " +
                "JOIN users u ON p.author_id = u.id " +
                "WHERE p.is_reported = true " +
                "ORDER BY p.date DESC";

        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Post post = mapResultSetToPost(rs);
                posts.add(post);
            }
        } finally {
            DatabaseUtil.close(rs, pstmt);
        }

        return posts;
    }

    /**
     * 전체 게시글 수를 조회합니다.
     */
    public int getPostCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT COUNT(*) FROM posts";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 수 조회 중 오류 발생", e);
        } finally {
            DatabaseUtil.close(rs, pstmt, conn);
        }

        return count;
    }

    /**
     * 최근 게시글 목록을 조회합니다.
     * @param limit 조회할 게시글 수
     * @return 최근 게시글 목록
     */
    public List<Post> getRecentPosts(int limit) {
        List<Post> posts = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT p.*, u.name as author_name, u.username as author_username " +
                    "FROM posts p " +
                    "JOIN users u ON p.author_id = u.id " +
                    "ORDER BY p.date DESC " +
                    "LIMIT ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Post post = mapResultSetToPost(rs);
                posts.add(post);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "최근 게시글 조회 중 오류 발생", e);
        } finally {
            DatabaseUtil.close(rs, pstmt, conn);
        }

        return posts;
    }

    /**
     * 게시글의 신고 상태를 업데이트합니다.
     * @param postId 게시글 ID
     * @param isReported 신고 상태 (true: 신고됨, false: 신고되지 않음)
     * @return 업데이트 성공 여부
     */
    public boolean updatePostReportStatus(int postId, boolean isReported) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "UPDATE posts SET is_reported = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setBoolean(1, isReported);
            pstmt.setInt(2, postId);

            int affectedRows = pstmt.executeUpdate();
            success = affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "게시글 신고 상태 업데이트 중 오류 발생", e);
        } finally {
            DatabaseUtil.close(pstmt, conn);
        }

        return success;
    }


    // 배지에 필요한 메소드
    public int getUserPostCount(int userId) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "SELECT COUNT(*) FROM posts WHERE author_id = ?";
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
     * 특정 사용자의 모든 게시글을 삭제합니다.
     */
    public boolean deletePostsByUserId(Connection conn, int userId) throws SQLException {
        String sql = "DELETE FROM posts WHERE author_id = ?";

        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);

            int affectedRows = pstmt.executeUpdate();
            LOGGER.info("사용자의 모든 게시글 삭제: userId=" + userId + ", 영향받은 행: " + affectedRows);

            return true; // 삭제할 게시글이 없어도 성공으로 간주

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자의 모든 게시글 삭제 중 오류 발생", e);
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