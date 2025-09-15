package com.minari.tungzang.controller;

import com.minari.tungzang.model.Post;
import com.minari.tungzang.model.User;
import com.minari.tungzang.service.PostService;
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

@WebServlet("/posts/*")
public class PostsServlet extends HttpServlet {

    private PostService postService;

    @Override
    public void init() throws ServletException {
        super.init();
        postService = new PostService();
    }

    /**
     * GET 요청 처리
     * - /posts: 모든 게시글 목록 조회
     * - /posts?category=X: 특정 카테고리의 게시글 목록 조회
     * - /posts?userId=X: 특정 사용자의 게시글 목록 조회
     * - /posts?search=X: 게시글 검색
     * - /posts/hot: 인기 게시글 목록 조회
     * - /posts/X: ID가 X인 게시글 상세 조회
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        String categoryParam = request.getParameter("category");
        String userIdParam = request.getParameter("userId");
        String searchParam = request.getParameter("search");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // 인기 게시글 목록 조회
            if (pathInfo != null && pathInfo.equals("/hot")) {
                int limit = 10;
                try {
                    String limitParam = request.getParameter("limit");
                    if (limitParam != null && !limitParam.isEmpty()) {
                        limit = Integer.parseInt(limitParam);
                    }
                } catch (NumberFormatException e) {
                    // 기본값 사용
                }

                List<Post> posts = postService.getHotPosts(limit);
                JSONArray jsonPosts = new JSONArray();
                for (Post post : posts) {
                    jsonPosts.put(convertPostToJson(post));
                }

                out.print(jsonPosts.toString());
            }
            // 특정 ID의 게시글 상세 조회
            else if (pathInfo != null && !pathInfo.equals("/")) {
                int postId = Integer.parseInt(pathInfo.substring(1));
                Post post = postService.getPostById(postId);

                if (post != null) {
                    // 조회수 증가
                    postService.incrementPostViews(postId);

                    JSONObject jsonPost = convertPostToJson(post);
                    out.print(jsonPost.toString());
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"게시글을 찾을 수 없습니다.\"}");
                }
            }
            // 특정 카테고리의 게시글 목록 조회
            else if (categoryParam != null && !categoryParam.isEmpty()) {
                List<Post> posts = postService.getPostsByCategory(categoryParam);
                JSONArray jsonPosts = new JSONArray();
                for (Post post : posts) {
                    jsonPosts.put(convertPostToJson(post));
                }

                out.print(jsonPosts.toString());
            }
            // 특정 사용자의 게시글 목록 조회
            else if (userIdParam != null && !userIdParam.isEmpty()) {
                int userId = Integer.parseInt(userIdParam);
                List<Post> posts = postService.getPostsByUserId(userId);
                JSONArray jsonPosts = new JSONArray();
                for (Post post : posts) {
                    jsonPosts.put(convertPostToJson(post));
                }

                out.print(jsonPosts.toString());
            }
            // 게시글 검색
            else if (searchParam != null && !searchParam.isEmpty()) {
                List<Post> posts = postService.searchPosts(searchParam);
                JSONArray jsonPosts = new JSONArray();
                for (Post post : posts) {
                    jsonPosts.put(convertPostToJson(post));
                }

                out.print(jsonPosts.toString());
            }
            // 모든 게시글 목록 조회
            else {
                List<Post> posts = postService.getAllPosts();
                JSONArray jsonPosts = new JSONArray();
                for (Post post : posts) {
                    jsonPosts.put(convertPostToJson(post));
                }

                out.print(jsonPosts.toString());
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"잘못된 요청 형식입니다.\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * POST 요청 처리
     * - /posts: 새로운 게시글 작성
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

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // 요청 본문에서 JSON 데이터 읽기
            BufferedReader reader = request.getReader();
            StringBuilder jsonBuilder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuilder.append(line);
            }

            JSONObject jsonData = new JSONObject(jsonBuilder.toString());

            // JSON 데이터에서 필요한 정보 추출
            String title = jsonData.getString("title");
            String content = jsonData.getString("content");
            String category = jsonData.getString("category");

            // 게시글 객체 생성
            Post post = new Post();
            post.setTitle(title);
            post.setContent(content);
            post.setCategory(category);
            post.setAuthorId(user.getId());

            // 게시글 저장
            int postId = postService.addPost(post);

            if (postId > 0) {
                // 게시글 저장 성공
                post.setId(postId);
                JSONObject jsonPost = convertPostToJson(post);
                response.setStatus(HttpServletResponse.SC_CREATED);
                out.print(jsonPost.toString());
            } else {
                // 게시글 저장 실패
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"게시글 저장에 실패했습니다.\"}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * PUT 요청 처리
     * - /posts/X: ID가 X인 게시글 수정
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

        if (pathInfo == null || pathInfo.equals("/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"게시글 ID가 필요합니다.\"}");
            return;
        }

        try {
            int postId = Integer.parseInt(pathInfo.substring(1));
            Post existingPost = postService.getPostById(postId);

            if (existingPost == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"게시글을 찾을 수 없습니다.\"}");
                return;
            }

            // 본인이 작성한 게시글만 수정 가능 (관리자는 모든 게시글 수정 가능)
            if (existingPost.getAuthorId() != user.getId() && !user.isAdmin()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"error\": \"본인이 작성한 게시글만 수정할 수 있습니다.\"}");
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
            if (jsonData.has("title")) {
                existingPost.setTitle(jsonData.getString("title"));
            }
            if (jsonData.has("content")) {
                existingPost.setContent(jsonData.getString("content"));
            }
            if (jsonData.has("category")) {
                existingPost.setCategory(jsonData.getString("category"));
            }

            // 게시글 업데이트
            boolean updated = postService.updatePost(existingPost);

            if (updated) {
                // 게시글 업데이트 성공
                JSONObject jsonPost = convertPostToJson(existingPost);
                out.print(jsonPost.toString());
            } else {
                // 게시글 업데이트 실패
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"게시글 업데이트에 실패했습니다.\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"잘못된 요청 형식입니다.\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * DELETE 요청 처리
     * - /posts/X: ID가 X인 게시글 삭제
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

        if (pathInfo == null || pathInfo.equals("/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"게시글 ID가 필요합니다.\"}");
            return;
        }

        try {
            int postId = Integer.parseInt(pathInfo.substring(1));
            Post post = postService.getPostById(postId);

            if (post == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"게시글을 찾을 수 없습니다.\"}");
                return;
            }

            // 본인이 작성한 게시글만 삭제 가능 (관리자는 모든 게시글 삭제 가능)
            if (post.getAuthorId() != user.getId() && !user.isAdmin()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"error\": \"본인이 작성한 게시글만 삭제할 수 있습니다.\"}");
                return;
            }

            // 게시글 삭제
            boolean deleted = postService.deletePost(postId);

            if (deleted) {
                // 게시글 삭제 성공
                response.setStatus(HttpServletResponse.SC_NO_CONTENT);
            } else {
                // 게시글 삭제 실패
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"게시글 삭제에 실패했습니다.\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"잘못된 요청 형식입니다.\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * Post 객체를 JSON 객체로 변환
     */
    private JSONObject convertPostToJson(Post post) {
        JSONObject jsonPost = new JSONObject();
        jsonPost.put("id", post.getId());
        jsonPost.put("title", post.getTitle());
        jsonPost.put("content", post.getContent());
        jsonPost.put("category", post.getCategory());
        jsonPost.put("authorId", post.getAuthorId());
        jsonPost.put("likes", post.getLikes());
        jsonPost.put("commentCount", post.getCommentCount());
        jsonPost.put("views", post.getViews());
        jsonPost.put("isHot", post.isHot());
        jsonPost.put("date", post.getDate().toString());

        // 작성자 정보 추가 (조인된 경우)
        if (post.getAuthorName() != null) {
            jsonPost.put("authorName", post.getAuthorName());
        }
        if (post.getAuthorUsername() != null) {
            jsonPost.put("authorUsername", post.getAuthorUsername());
        }

        return jsonPost;
    }
}