package com.minari.tungzang.controller;

import com.minari.tungzang.model.Post;
import com.minari.tungzang.model.Comment;
import com.minari.tungzang.model.User;
import com.minari.tungzang.service.PostService;
import com.minari.tungzang.service.CommentService;
import com.minari.tungzang.util.ValidationUtil;
import com.minari.tungzang.util.DatabaseUtil;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.ArrayList;

@WebServlet(urlPatterns = {"/community", "/community/*"})
public class CommunityServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CommunityServlet.class.getName());
    private PostService postService;
    private CommentService commentService;

    @Override
    public void init() throws ServletException {
        super.init();
        LOGGER.info("CommunityServlet 초기화됨");
        try {
            postService = new PostService();
            commentService = new CommentService();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "서비스 초기화 중 오류 발생", e);
            throw new ServletException("서비스 초기화 실패", e);
        }
    }

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        LOGGER.info("CommunityServlet 호출됨: " + request.getRequestURI());
        super.service(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        LOGGER.info("doGet 메서드 호출됨, pathInfo: " + pathInfo);

        try {
            // pathInfo가 null이거나 "/"이거나 빈 문자열("")인 경우 메인 페이지로 처리
            if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("")) {
                // 커뮤니티 메인 페이지
                String category = request.getParameter("category");
                String keyword = request.getParameter("keyword");
                String pageStr = request.getParameter("page");

                int page = 1;
                if (pageStr != null && !pageStr.isEmpty()) {
                    try {
                        page = Integer.parseInt(pageStr);
                        if (page < 1) page = 1;
                    } catch (NumberFormatException e) {
                        // 페이지 번호가 유효하지 않으면 기본값 1 사용
                    }
                }

                List<Post> posts;

                if (category != null && !category.equals("all")) {
                    posts = postService.getPostsByCategory(category);
                } else if (keyword != null && !keyword.trim().isEmpty()) {
                    posts = postService.searchPosts(keyword);
                } else {
                    posts = postService.getAllPosts();
                }

                // 페이지네이션 처리 (클라이언트 측에서 처리)
                int pageSize = 10; // 페이지당 게시글 수
                int totalPosts = posts.size();
                int totalPages = (int) Math.ceil((double) totalPosts / pageSize);

                // 현재 페이지에 해당하는 게시글만 추출
                int startIndex = (page - 1) * pageSize;
                int endIndex = Math.min(startIndex + pageSize, totalPosts);

                if (startIndex < totalPosts) {
                    posts = posts.subList(startIndex, endIndex);
                }

                request.setAttribute("posts", posts);
                request.setAttribute("category", category != null ? category : "all");
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", totalPages);

                request.getRequestDispatcher("/WEB-INF/views/community.jsp").forward(request, response);
            } else if (pathInfo.equals("/write")) {
                // 게시글 작성 페이지
                HttpSession session = request.getSession();
                User user = (User) session.getAttribute("user");

                if (user == null) {
                    LOGGER.info("로그인되지 않은 사용자가 게시글 작성 페이지에 접근 시도");
                    // 로그인이 필요하다는 메시지와 함께 로그인 페이지로 리다이렉트
                    request.setAttribute("message", "게시글 작성을 위해 로그인이 필요합니다.");
                    request.setAttribute("redirectUrl", request.getContextPath() + "/login?redirect=community/write");

                    // 로그인 필요 페이지로 포워드
                    try {
                        request.getRequestDispatcher("/WEB-INF/views/login-required.jsp").forward(request, response);
                    } catch (Exception e) {
                        LOGGER.log(Level.SEVERE, "로그인 필요 페이지 포워드 중 오류 발생", e);
                        // 포워드 실패 시 리다이렉트로 대체
                        response.sendRedirect(request.getContextPath() + "/login?message=login_required");
                    }
                    return;
                }

                // 사용자 ID 유효성 검사
                if (user.getId() <= 0) {
                    LOGGER.severe("유효하지 않은 사용자 ID: " + user.getId());
                    // 세션 무효화
                    session.invalidate();
                    // 로그인 페이지로 리다이렉트
                    response.sendRedirect(request.getContextPath() + "/login?message=invalid_user");
                    return;
                }

                request.getRequestDispatcher("/WEB-INF/views/post-write.jsp").forward(request, response);
            } else if (pathInfo.startsWith("/post/")) {
                // 게시글 상세 페이지
                try {
                    int postId = Integer.parseInt(pathInfo.substring("/post/".length()));
                    Post post = postService.getPostById(postId);

                    if (post == null) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND);
                        return;
                    }

                    // 조회수 증가
                    postService.incrementPostViews(postId);

                    // 댓글 목록 가져오기
                    List<Comment> comments = new ArrayList<>();
                    try {
                        comments = commentService.getCommentsByPostId(postId);
                    } catch (Exception e) {
                        LOGGER.log(Level.WARNING, "댓글 목록 조회 중 오류 발생", e);
                        // 오류가 발생해도 게시글은 표시되어야 하므로 계속 진행
                    }

                    // 사용자가 좋아요를 눌렀는지 확인
                    boolean userLiked = false;
                    HttpSession session = request.getSession();
                    User user = (User) session.getAttribute("user");
                    if (user != null && user.getId() > 0) {
                        // 좋아요 여부 확인
                        userLiked = postService.isPostLikedByUser(postId, user.getId());
                    }

                    request.setAttribute("post", post);
                    request.setAttribute("comments", comments);
                    request.setAttribute("userLiked", userLiked);

                    request.getRequestDispatcher("/WEB-INF/views/post-detail.jsp").forward(request, response);
                } catch (NumberFormatException e) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                }
            } else if (pathInfo.startsWith("/edit/")) {
                // 게시글 수정 페이지
                HttpSession session = request.getSession();
                User user = (User) session.getAttribute("user");

                if (user == null) {
                    LOGGER.info("로그인되지 않은 사용자가 게시글 수정 페이지에 접근 시도");
                    // 로그인이 필요하다는 메시지와 함께 로그인 페이지로 리다이렉트
                    request.setAttribute("message", "게시글 수정을 위해 로그인이 필요합니다.");
                    request.setAttribute("redirectUrl", request.getContextPath() + "/login");

                    // 로그인 필요 페이지로 포워드
                    try {
                        request.getRequestDispatcher("/WEB-INF/views/login-required.jsp").forward(request, response);
                    } catch (Exception e) {
                        LOGGER.log(Level.SEVERE, "로그인 필요 페이지 포워드 중 오류 발생", e);
                        // 포워드 실패 시 리다이렉트로 대체
                        response.sendRedirect(request.getContextPath() + "/login?message=login_required");
                    }
                    return;
                }

                // 사용자 ID 유효성 검사
                if (user.getId() <= 0) {
                    LOGGER.severe("유효하지 않은 사용자 ID: " + user.getId());
                    // 세션 무효화
                    session.invalidate();
                    // 로그인 페이지로 리다이렉트
                    response.sendRedirect(request.getContextPath() + "/login?message=invalid_user");
                    return;
                }

                try {
                    int postId = Integer.parseInt(pathInfo.substring("/edit/".length()));
                    Post post = postService.getPostById(postId);

                    if (post == null) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND);
                        return;
                    }

                    // 작성자 확인
                    if (post.getUserId() != user.getId()) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }

                    request.setAttribute("post", post);
                    request.getRequestDispatcher("/WEB-INF/views/post-edit.jsp").forward(request, response);
                } catch (NumberFormatException e) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                }
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "커뮤니티 페이지 처리 중 오류 발생", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 로그인 확인 (좋아요와 신고는 별도 처리)
        if (user == null && !pathInfo.equals("/like") && !pathInfo.equals("/report")) {
            LOGGER.info("로그인되지 않은 사용자가 POST 요청 시도: " + pathInfo);
            // 로그인이 필요하다는 메시지와 함께 로그인 페이지로 리다이렉트
            request.setAttribute("message", "이 기능을 사용하기 위해 로그인이 필요합니다.");
            request.setAttribute("redirectUrl", request.getContextPath() + "/login");

            // 로그인 필요 페이지로 포워드
            try {
                request.getRequestDispatcher("/WEB-INF/views/login-required.jsp").forward(request, response);
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "로그인 필요 페이지 포워드 중 오류 발생", e);
                // 포워드 실패 시 리다이렉트로 대체
                response.sendRedirect(request.getContextPath() + "/login?message=login_required");
            }
            return;
        }

        // 사용자 ID 유효성 검사 (좋아요와 신고는 별도 처리)
        if (user != null && user.getId() <= 0 && !pathInfo.equals("/like") && !pathInfo.equals("/report")) {
            LOGGER.severe("유효하지 않은 사용자 ID: " + user.getId());
            // 세션 무효화
            session.invalidate();
            // 로그인 페이지로 리다이렉트
            response.sendRedirect(request.getContextPath() + "/login?message=invalid_user");
            return;
        }

        try {
            if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("/write")) {
                // 게시글 작성 처리
                String title = request.getParameter("title");
                String content = request.getParameter("content");
                String category = request.getParameter("category");

                // ValidationUtil.isEmpty() 메서드 사용 수정
                if (ValidationUtil.isEmpty(title) || ValidationUtil.isEmpty(content) ||
                        ValidationUtil.isEmpty(category)) {
                    request.setAttribute("error", "모든 필드를 입력해주세요.");
                    request.getRequestDispatcher("/WEB-INF/views/post-write.jsp").forward(request, response);
                    return;
                }

                Post post = new Post();
                post.setTitle(title);
                post.setContent(content);
                post.setCategory(category);
                post.setAuthorId(user.getId());
                post.setAuthorName(user.getName()); // 작성자 이름 설정

                int postId = postService.addPost(post);

                if (postId > 0) {
                    response.sendRedirect(request.getContextPath() + "/community/post/" + postId);
                } else {
                    request.setAttribute("error", "게시글 등록에 실패했습니다. 다시 시도해주세요.");
                    request.getRequestDispatcher("/WEB-INF/views/post-write.jsp").forward(request, response);
                }
            } else if (pathInfo.startsWith("/edit/")) {
                // 게시글 수정 처리
                try {
                    int postId = Integer.parseInt(pathInfo.substring("/edit/".length()));
                    Post existingPost = postService.getPostById(postId);

                    if (existingPost == null) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND);
                        return;
                    }

                    // 작성자 확인
                    if (existingPost.getUserId() != user.getId()) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }

                    String title = request.getParameter("title");
                    String content = request.getParameter("content");
                    String category = request.getParameter("category");

                    // ValidationUtil.isEmpty() 메서드 사용 수정
                    if (ValidationUtil.isEmpty(title) || ValidationUtil.isEmpty(content) ||
                            ValidationUtil.isEmpty(category)) {
                        request.setAttribute("error", "모든 필드를 입력해주세요.");
                        request.setAttribute("post", existingPost);
                        request.getRequestDispatcher("/WEB-INF/views/post-edit.jsp").forward(request, response);
                        return;
                    }

                    Post post = new Post();
                    post.setId(postId);
                    post.setTitle(title);
                    post.setContent(content);
                    post.setCategory(category);
                    post.setAuthorId(user.getId());

                    boolean success = postService.updatePost(post);

                    if (success) {
                        response.sendRedirect(request.getContextPath() + "/community/post/" + postId);
                    } else {
                        request.setAttribute("error", "게시글 수정에 실패했습니다. 다시 시도해주세요.");
                        request.setAttribute("post", existingPost);
                        request.getRequestDispatcher("/WEB-INF/views/post-edit.jsp").forward(request, response);
                    }
                } catch (NumberFormatException e) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                }
            } else if (pathInfo.equals("/delete")) {
                // 게시글 삭제 처리
                String postIdStr = request.getParameter("postId");

                if (!ValidationUtil.isValidNumber(postIdStr)) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }

                int postId = Integer.parseInt(postIdStr);
                Post post = postService.getPostById(postId);

                if (post == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                // 작성자 확인
                if (post.getUserId() != user.getId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                boolean success = postService.deletePost(postId);

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/community");
                } else {
                    response.sendRedirect(request.getContextPath() + "/community/post/" + postId + "?error=delete");
                }
            } else if (pathInfo.equals("/comment")) {
                // 댓글 작성 처리
                String postIdStr = request.getParameter("postId");
                String content = request.getParameter("content");

                // ValidationUtil.isEmpty() 메서드 사용 수정
                if (!ValidationUtil.isValidNumber(postIdStr) || ValidationUtil.isEmpty(content)) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }

                int postId = Integer.parseInt(postIdStr);

                Comment comment = new Comment();
                comment.setPostId(postId);
                comment.setAuthorId(user.getId());
                comment.setContent(content);
                comment.setAuthorName(user.getName()); // 작성자 이름 설정

                int commentId = commentService.addComment(comment);

                if (commentId > 0) {
                    // 게시글의 댓글 수 업데이트
                    postService.updatePostCommentCount(postId);
                    response.sendRedirect(request.getContextPath() + "/community/post/" + postId);
                } else {
                    response.sendRedirect(request.getContextPath() + "/community/post/" + postId + "?error=comment");
                }
            } else if (pathInfo.equals("/comment/delete")) {
                // 댓글 삭제 처리
                String commentIdStr = request.getParameter("commentId");
                String postIdStr = request.getParameter("postId");

                if (!ValidationUtil.isValidNumber(commentIdStr) || !ValidationUtil.isValidNumber(postIdStr)) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }

                int commentId = Integer.parseInt(commentIdStr);
                int postId = Integer.parseInt(postIdStr);

                Comment comment = commentService.getCommentById(commentId);

                if (comment == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                // 작성자 확인
                if (comment.getAuthorId() != user.getId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                boolean success = commentService.deleteComment(commentId);

                if (success) {
                    // 게시글의 댓글 수 업데이트
                    postService.updatePostCommentCount(postId);
                    response.sendRedirect(request.getContextPath() + "/community/post/" + postId);
                } else {
                    response.sendRedirect(request.getContextPath() + "/community/post/" + postId + "?error=deleteComment");
                }
            } else if (pathInfo.equals("/like")) {
                // 좋아요 처리
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");

                // 로그인 확인
                if (user == null) {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().write("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
                    return;
                }

                // 사용자 ID 유효성 검사
                if (user.getId() <= 0) {
                    LOGGER.severe("유효하지 않은 사용자 ID: " + user.getId());
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\": false, \"message\": \"유효하지 않은 사용자 ID입니다. 다시 로그인해주세요.\"}");
                    // 세션 무효화
                    session.invalidate();
                    return;
                }

                String postIdStr = request.getParameter("postId");

                if (!ValidationUtil.isValidNumber(postIdStr)) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\": false, \"message\": \"Invalid post ID\"}");
                    return;
                }

                int postId = Integer.parseInt(postIdStr);
                Post post = postService.getPostById(postId);

                if (post == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"success\": false, \"message\": \"Post not found\"}");
                    return;
                }

                // 좋아요 토글
                boolean liked = postService.togglePostLike(postId, user.getId());

                // 업데이트된 게시글 정보 가져오기
                post = postService.getPostById(postId);

                response.getWriter().write("{\"success\": true, \"liked\": " + liked + ", \"likeCount\": " + post.getLikes() + "}");
            } else if (pathInfo.equals("/report")) {
                // 신고 처리
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");

                // 로그인 확인
                if (user == null) {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().write("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
                    return;
                }

                // 사용자 ID 유효성 검사
                if (user.getId() <= 0) {
                    LOGGER.severe("유효하지 않은 사용자 ID: " + user.getId());
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\": false, \"message\": \"유효하지 않은 사용자 ID입니다. 다시 로그인해주세요.\"}");
                    // 세션 무효화
                    session.invalidate();
                    return;
                }

                String postIdStr = request.getParameter("postId");
                String reason = request.getParameter("reason");
                String detail = request.getParameter("detail");

                if (!ValidationUtil.isValidNumber(postIdStr) || ValidationUtil.isEmpty(reason)) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\": false, \"message\": \"Invalid parameters\"}");
                    return;
                }

                int postId = Integer.parseInt(postIdStr);
                Post post = postService.getPostById(postId);

                if (post == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"success\": false, \"message\": \"Post not found\"}");
                    return;
                }

                // 게시글 신고 처리 - is_reported 필드를 true로 업데이트
                Connection conn = null;
                PreparedStatement pstmt = null;

                try {
                    conn = DatabaseUtil.getConnection();

                    // 게시글 신고 상태 업데이트
                    String updateSql = "UPDATE posts SET is_reported = TRUE WHERE id = ?";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setInt(1, postId);
                    int updated = pstmt.executeUpdate();

                    if (updated > 0) {
                        // 신고 내역 저장 (신고 내역 테이블이 있다면)
                        // 여기에 신고 내역 저장 코드 추가

                        // 성공 응답
                        response.getWriter().write("{\"success\": true, \"message\": \"신고가 접수되었습니다.\"}");
                    } else {
                        // 실패 응답
                        response.getWriter().write("{\"success\": false, \"message\": \"신고 처리에 실패했습니다.\"}");
                    }
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "게시글 신고 처리 중 오류 발생", e);
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"success\": false, \"message\": \"서버 오류가 발생했습니다.\"}");
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
                            conn.close();
                        } catch (SQLException e) {
                            LOGGER.log(Level.SEVERE, "Connection 닫기 중 오류 발생", e);
                        }
                    }
                }
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "커뮤니티 POST 요청 처리 중 오류 발생", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
