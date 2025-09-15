package com.minari.tungzang.controller;

import com.minari.tungzang.model.Comment;
import com.minari.tungzang.model.User;
import com.minari.tungzang.service.CommentService;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/comments/*")
public class CommentsServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CommentsServlet.class.getName());
    private CommentService commentService;

    @Override
    public void init() throws ServletException {
        super.init();
        commentService = new CommentService();
    }

    /**
     * GET 요청 처리
     * - /comments?postId=X: 특정 게시글의 댓글 목록 조회
     * - /comments?userId=X: 특정 사용자의 댓글 목록 조회
     * - /comments/X: ID가 X인 댓글 상세 조회
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        String postIdParam = request.getParameter("postId");
        String userIdParam = request.getParameter("userId");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // 특정 ID의 댓글 상세 조회
            if (pathInfo != null && !pathInfo.equals("/")) {
                int commentId = Integer.parseInt(pathInfo.substring(1));
                Comment comment = commentService.getCommentById(commentId);

                if (comment != null) {
                    JSONObject jsonComment = convertCommentToJson(comment);
                    out.print(jsonComment.toString());
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"댓글을 찾을 수 없습니다.\"}");
                }
            }
            // 특정 게시글의 댓글 목록 조회
            else if (postIdParam != null && !postIdParam.isEmpty()) {
                int postId = Integer.parseInt(postIdParam);
                List<Comment> comments = commentService.getCommentsByPostId(postId);
                JSONArray jsonComments = new JSONArray();
                for (Comment comment : comments) {
                    jsonComments.put(convertCommentToJson(comment));
                }

                out.print(jsonComments.toString());
            }
            // 특정 사용자의 댓글 목록 조회
            else if (userIdParam != null && !userIdParam.isEmpty()) {
                int userId = Integer.parseInt(userIdParam);
                List<Comment> comments = commentService.getCommentsByUserId(userId);
                JSONArray jsonComments = new JSONArray();
                for (Comment comment : comments) {
                    jsonComments.put(convertCommentToJson(comment));
                }

                out.print(jsonComments.toString());
            }
            // 잘못된 요청
            else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"게시글 ID 또는 사용자 ID가 필요합니다.\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"잘못된 요청 형식입니다.\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "댓글 조회 중 오류 발생", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * POST 요청 처리
     * - /comments: 새로운 댓글 작성
     * - /comments/like: 댓글 좋아요
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\": \"로그인이 필요합니다.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // 사용자 ID 유효성 검사
        if (user.getId() <= 0) {
            LOGGER.severe("유효하지 않은 사용자 ID: " + user.getId());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"유효하지 않은 사용자 ID입니다. 다시 로그인해주세요.\"}");
            // 세션 무효화
            session.invalidate();
            return;
        }

        try {
            // 댓글 좋아요 처리
            if (pathInfo != null && pathInfo.equals("/like")) {
                String commentIdStr = request.getParameter("commentId");

                if (commentIdStr == null || commentIdStr.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\": \"댓글 ID가 필요합니다.\"}");
                    return;
                }

                int commentId = Integer.parseInt(commentIdStr);
                Comment comment = commentService.getCommentById(commentId);

                if (comment == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"댓글을 찾을 수 없습니다.\"}");
                    return;
                }

                // 좋아요 토글
                boolean liked = commentService.toggleCommentLike(commentId, user.getId());

                // 업데이트된 댓글 정보 가져오기
                comment = commentService.getCommentById(commentId);

                JSONObject jsonResponse = new JSONObject();
                jsonResponse.put("success", true);
                jsonResponse.put("liked", liked);
                jsonResponse.put("likeCount", comment.getLikes());

                out.print(jsonResponse.toString());
                return;
            }

            // 댓글 신고 처리
            if (pathInfo != null && pathInfo.equals("/report")) {
                String commentIdStr = request.getParameter("commentId");
                String reason = request.getParameter("reason");

                if (commentIdStr == null || commentIdStr.isEmpty() || reason == null || reason.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\": \"댓글 ID와 신고 이유가 필요합니다.\"}");
                    return;
                }

                int commentId = Integer.parseInt(commentIdStr);
                Comment comment = commentService.getCommentById(commentId);

                if (comment == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"댓글을 찾을 수 없습니다.\"}");
                    return;
                }

                // 자신의 댓글은 신고할 수 없음
                if (comment.getAuthorId() == user.getId()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\": \"자신의 댓글은 신고할 수 없습니다.\"}");
                    return;
                }

                // 댓글 신고
                boolean reported = commentService.reportComment(commentId, user.getId(), reason);

                JSONObject jsonResponse = new JSONObject();
                if (reported) {
                    jsonResponse.put("success", true);
                    jsonResponse.put("message", "댓글이 신고되었습니다.");
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "이미 신고한 댓글이거나 신고 처리 중 오류가 발생했습니다.");
                }

                out.print(jsonResponse.toString());
                return;
            }

            // 새 댓글 작성 처리
            String postIdStr = request.getParameter("postId");
            String content = request.getParameter("content");

            if (postIdStr == null || content == null || postIdStr.isEmpty() || content.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"게시글 ID와 내용이 필요합니다.\"}");
                return;
            }

            int postId = Integer.parseInt(postIdStr);

            // 사용자 ID 로깅 추가
            LOGGER.info("댓글 작성 시도: 사용자 ID=" + user.getId() + ", 이름=" + user.getName());

            try {
                // 댓글 객체 생성
                Comment comment = new Comment();
                comment.setPostId(postId);
                comment.setAuthorId(user.getId());
                comment.setAuthorName(user.getName()); // 작성자 이름 설정
                comment.setContent(content);

                // 댓글 저장
                int commentId = commentService.addComment(comment);

                if (commentId > 0) {
                    // 댓글 저장 성공
                    comment.setId(commentId);
                    JSONObject jsonComment = convertCommentToJson(comment);
                    response.setStatus(HttpServletResponse.SC_CREATED);
                    out.print(jsonComment.toString());
                    LOGGER.info("댓글 작성 성공: 댓글 ID=" + commentId);
                } else {
                    // 댓글 저장 실패
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"error\": \"댓글 저장에 실패했습니다.\"}");
                    LOGGER.warning("댓글 작성 실패: 댓글 ID가 반환되지 않음");
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "댓글 저장 중 예외 발생", e);
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"댓글 저장 중 오류: " + e.getMessage() + "\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"잘못된 요청 형식입니다.\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "댓글 작성 중 오류 발생", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * PUT 요청 처리
     * - /comments/X: ID가 X인 댓글 수정
     */
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\": \"로그인이 필요합니다.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // 사용자 ID 유효성 검사
        if (user.getId() <= 0) {
            LOGGER.severe("유효하지 않은 사용자 ID: " + user.getId());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"유효하지 않은 사용자 ID입니다. 다시 로그인해주세요.\"}");
            // 세션 무효화
            session.invalidate();
            return;
        }

        if (pathInfo == null || pathInfo.equals("/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"댓글 ID가 필요합니다.\"}");
            return;
        }

        try {
            int commentId = Integer.parseInt(pathInfo.substring(1));
            Comment existingComment = commentService.getCommentById(commentId);

            if (existingComment == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"댓글을 찾을 수 없습니다.\"}");
                return;
            }

            // 본인이 작성한 댓글만 수정 가능 (관리자는 모든 댓글 수정 가능)
            if (existingComment.getAuthorId() != user.getId() && !user.isAdmin()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"error\": \"본인이 작성한 댓글만 수정할 수 있습니다.\"}");
                return;
            }

            // 요청 본문에서 JSON 데이터 읽기
            BufferedReader reader = request.getReader();
            StringBuilder jsonBuilder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuilder.append(line);
            }

            JSONObject jsonData = new JSONObject(jsonBuilder.toString());

            // JSON 데이터에서 필요한 정보 추출
            if (jsonData.has("content")) {
                existingComment.setContent(jsonData.getString("content"));
            }

            // 댓글 업데이트
            boolean updated = commentService.updateComment(existingComment);

            if (updated) {
                // 댓글 업데이트 성공
                JSONObject jsonComment = convertCommentToJson(existingComment);
                out.print(jsonComment.toString());
            } else {
                // 댓글 업데이트 실패
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"댓글 업데이트에 실패했습니다.\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"잘못된 요청 형식입니다.\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "댓글 수정 중 오류 발생", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * DELETE 요청 처리
     * - /comments/X: ID가 X인 댓글 삭제
     */
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\": \"로그인이 필요합니다.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // 사용자 ID 유효성 검사
        if (user.getId() <= 0) {
            LOGGER.severe("유효하지 않은 사용자 ID: " + user.getId());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"유효하지 않은 사용자 ID입니다. 다시 로그인해주세요.\"}");
            // 세션 무효화
            session.invalidate();
            return;
        }

        if (pathInfo == null || pathInfo.equals("/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"댓글 ID가 필요합니다.\"}");
            return;
        }

        try {
            int commentId = Integer.parseInt(pathInfo.substring(1));
            Comment comment = commentService.getCommentById(commentId);

            if (comment == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"댓글을 찾을 수 없습니다.\"}");
                return;
            }

            // 본인이 작성한 댓글만 삭제 가능 (관리자는 모든 댓글 삭제 가능)
            if (comment.getAuthorId() != user.getId() && !user.isAdmin()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"error\": \"본인이 작성한 댓글만 삭제할 수 있습니다.\"}");
                return;
            }

            // 댓글 삭제
            boolean deleted = commentService.deleteComment(commentId);

            if (deleted) {
                // 댓글 삭제 성공
                response.setStatus(HttpServletResponse.SC_NO_CONTENT);
            } else {
                // 댓글 삭제 실패
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"댓글 삭제에 실패했습니다.\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"잘못된 요청 형식입니다.\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "댓글 삭제 중 오류 발생", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * Comment 객체를 JSON 객체로 변환
     */
    private JSONObject convertCommentToJson(Comment comment) {
        JSONObject jsonComment = new JSONObject();
        jsonComment.put("id", comment.getId());
        jsonComment.put("postId", comment.getPostId());
        jsonComment.put("authorId", comment.getAuthorId());
        jsonComment.put("content", comment.getContent());
        jsonComment.put("likes", comment.getLikes());
        jsonComment.put("date", comment.getDate() != null ? comment.getDate().toString() : "");

        // 작성자 정보 추가 (조인된 경우)
        if (comment.getAuthorName() != null) {
            jsonComment.put("authorName", comment.getAuthorName());
        }
        if (comment.getAuthorUsername() != null) {
            jsonComment.put("authorUsername", comment.getAuthorUsername());
        }

        return jsonComment;
    }
}
