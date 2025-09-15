package com.minari.tungzang.controller;

import com.minari.tungzang.dao.UserDAO;
import com.minari.tungzang.dao.CourseDAO;
import com.minari.tungzang.dao.EvaluationDAO;
import com.minari.tungzang.dao.PostDAO;
import com.minari.tungzang.dao.CommentDAO;
import com.minari.tungzang.model.User;
import com.minari.tungzang.model.Post;
import com.minari.tungzang.model.Comment;
import com.minari.tungzang.model.Evaluation;
import com.minari.tungzang.service.PostService;
import com.minari.tungzang.service.CommentService;
import com.minari.tungzang.service.EvaluationService;
import com.minari.tungzang.service.CourseService;
import com.minari.tungzang.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdminServlet extends HttpServlet {

    private UserDAO userDAO;
    private CourseDAO courseDAO;
    private EvaluationDAO evaluationDAO;
    private PostDAO postDAO;
    private CommentDAO commentDAO;

    // 서비스 클래스들
    private PostService postService;
    private CommentService commentService;
    private EvaluationService evaluationService;
    private CourseService courseService;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        courseDAO = new CourseDAO();
        evaluationDAO = new EvaluationDAO();
        postDAO = new PostDAO();
        commentDAO = new CommentDAO();

        // 서비스 클래스 초기화
        postService = new PostService();
        commentService = new CommentService();
        evaluationService = new EvaluationService();
        courseService = new CourseService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        System.out.println("DEBUG: AdminServlet doGet() 호출됨");
        String pathInfo = req.getPathInfo();
        System.out.println("DEBUG: pathInfo = " + pathInfo);
        System.out.println("DEBUG: requestURI = " + req.getRequestURI());

        // 세션에서 사용자 정보 가져오기
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        System.out.println("DEBUG: 세션 사용자 = " + (user != null ? user.getUsername() : "null"));
        System.out.println("DEBUG: 관리자 여부 = " + (user != null ? user.isAdmin() : "false"));

        // 기본 경로 처리 (관리자 대시보드)
        if (pathInfo == null || pathInfo.equals("/")) {
            // 관리자 로그인 여부 확인
            if (user == null || !user.isAdmin()) {
                System.out.println("DEBUG: 관리자 권한 없음, 로그인 페이지로 리다이렉트");
                resp.sendRedirect(req.getContextPath() + "/admin/login");
                return;
            }

            System.out.println("DEBUG: 대시보드 데이터 로드 시작");
            // 대시보드 데이터 로드
            loadDashboardData(req);

            System.out.println("DEBUG: JSP 포워딩 시작");
            // 관리자 대시보드 페이지로 포워딩
            req.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(req, resp);
            System.out.println("DEBUG: JSP 포워딩 완료");
            return;
        }

        // 관리자 로그인 페이지
        if (pathInfo.equals("/login")) {
            System.out.println("DEBUG: 로그인 페이지 요청");
            // 이미 관리자로 로그인한 경우 대시보드로 리다이렉트
            if (user != null && user.isAdmin()) {
                System.out.println("DEBUG: 이미 로그인됨, 대시보드로 리다이렉트");
                resp.sendRedirect(req.getContextPath() + "/admin");
                return;
            }

            System.out.println("DEBUG: 로그인 페이지 포워딩");
            req.getRequestDispatcher("/WEB-INF/views/admin-login.jsp").forward(req, resp);
            return;
        }

        // 로그아웃
        if (pathInfo.equals("/logout")) {
            System.out.println("DEBUG: 로그아웃 요청");
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        // 그 외 경로는 404 에러
        System.out.println("DEBUG: 알 수 없는 경로: " + pathInfo);
        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        // 관리자 인증
        if (pathInfo.equals("/auth")) {
            authenticateAdmin(request, response);
            return;
        }

        // 비밀번호 변경
        if (pathInfo.equals("/change-password")) {
            changeAdminPassword(request, response);
            return;
        }

        // 사용자 추가
        if (pathInfo.equals("/users/add")) {
            addUser(request, response);
            return;
        }

        // 사용자 삭제
        if (pathInfo.startsWith("/users/delete/")) {
            deleteUser(request, response);
            return;
        }

        // 신고 관련 처리
        if (pathInfo.startsWith("/reports/")) {
            handleReports(request, response);
            return;
        }

        // 태그 업데이트 처리
        if (pathInfo.equals("/update-tags")) {
            updateTags(request, response);
            return;
        }

        // 그 외 경로는 404 에러
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    // 대시보드 데이터 로드
    private void loadDashboardData(HttpServletRequest request) {
        try {
            System.out.println("DEBUG: loadDashboardData() 시작");

            // 통계 데이터 로드
            System.out.println("DEBUG: 통계 데이터 로드 중...");
            int userCount = userDAO.getUserCount();
            int courseCount = courseDAO.getCourseCount();
            int evaluationCount = evaluationDAO.getEvaluationCount();
            int postCount = postDAO.getPostCount();

            System.out.println("DEBUG: 통계 데이터 로드 완료");

            // 최근 강의 평가 및 게시글 로드
            System.out.println("DEBUG: 최근 데이터 로드 중...");
            request.setAttribute("recentEvaluations", evaluationDAO.getRecentEvaluations(5));
            request.setAttribute("recentPosts", postDAO.getRecentPosts(5));
            request.setAttribute("users", userDAO.getAllUsers());

            System.out.println("DEBUG: 최근 데이터 로드 완료");

            // 신고된 콘텐츠 로드
            System.out.println("DEBUG: 신고된 콘텐츠 로드 중...");
            List<Post> reportedPosts = postService.getReportedPosts();
            List<Comment> reportedComments = commentService.getReportedComments();
            List<Evaluation> reportedEvaluations = evaluationService.getReportedEvaluations();

            // 신고된 콘텐츠 설정
            request.setAttribute("reportedPosts", reportedPosts);
            request.setAttribute("reportedComments", reportedComments);
            request.setAttribute("reportedEvaluations", reportedEvaluations);

            // 통계 데이터 설정
            request.setAttribute("userCount", userCount);
            request.setAttribute("courseCount", courseCount);
            request.setAttribute("evaluationCount", evaluationCount);
            request.setAttribute("postCount", postCount);

            System.out.println("DEBUG: 신고된 게시글 수: " + reportedPosts.size());
            System.out.println("DEBUG: 신고된 댓글 수: " + reportedComments.size());
            System.out.println("DEBUG: 신고된 강의평가 수: " + reportedEvaluations.size());

            // 통계 데이터 설정 후에 추가
            System.out.println("DEBUG: 사용자 수: " + userCount);
            System.out.println("DEBUG: 강의 수: " + courseCount);
            System.out.println("DEBUG: 평가 수: " + evaluationCount);
            System.out.println("DEBUG: 게시글 수: " + postCount);

            System.out.println("DEBUG: loadDashboardData() 완료");
        } catch (Exception e) {
            System.out.println("DEBUG: loadDashboardData() 예외 발생: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "대시보드 데이터를 로드하는 중 오류가 발생했습니다.");
        }
    }

    // 신고 관련 처리
    private void handleReports(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 세션에서 사용자 정보 가져오기
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 관리자 로그인 여부 확인
        if (user == null || !user.isAdmin()) {
            sendJsonResponse(response, false, "권한이 없습니다.");
            return;
        }

        String pathInfo = request.getPathInfo();

        // 게시글 삭제
        if (pathInfo.startsWith("/reports/delete-post/")) {
            int postId = Integer.parseInt(pathInfo.substring("/reports/delete-post/".length()));
            boolean success = postService.deletePost(postId);
            sendJsonResponse(response, success, success ? "게시글이 성공적으로 삭제되었습니다." : "게시글 삭제에 실패했습니다.");
            return;
        }

        // 게시글 신고 무시
        if (pathInfo.startsWith("/reports/ignore-post/")) {
            int postId = Integer.parseInt(pathInfo.substring("/reports/ignore-post/".length()));
            boolean success = postService.ignorePostReport(postId);
            sendJsonResponse(response, success, success ? "게시글 신고가 무시되었습니다." : "게시글 신고 무시에 실패했습니다.");
            return;
        }

        // 댓글 삭제
        if (pathInfo.startsWith("/reports/delete-comment/")) {
            int commentId = Integer.parseInt(pathInfo.substring("/reports/delete-comment/".length()));
            boolean success = commentService.deleteComment(commentId);
            sendJsonResponse(response, success, success ? "댓글이 성공적으로 삭제되었습니다." : "댓글 삭제에 실패했습니다.");
            return;
        }

        // 댓글 신고 무시
        if (pathInfo.startsWith("/reports/ignore-comment/")) {
            int commentId = Integer.parseInt(pathInfo.substring("/reports/ignore-comment/".length()));
            boolean success = commentService.ignoreCommentReport(commentId);
            sendJsonResponse(response, success, success ? "댓글 신고가 무시되었습니다." : "댓글 신고 무시에 실패했습니다.");
            return;
        }

        // 강의평가 삭제
        if (pathInfo.startsWith("/reports/delete-evaluation/")) {
            int evaluationId = Integer.parseInt(pathInfo.substring("/reports/delete-evaluation/".length()));
            // 관리자 권한으로 삭제하므로 userId를 0으로 전달 (관리자는 모든 평가 삭제 가능)
            boolean success = evaluationService.deleteEvaluation(evaluationId, 0);
            sendJsonResponse(response, success, success ? "강의평가가 성공적으로 삭제되었습니다." : "강의평가 삭제에 실패했습니다.");
            return;
        }

        // 강의평가 신고 무시
        if (pathInfo.startsWith("/reports/ignore-evaluation/")) {
            int evaluationId = Integer.parseInt(pathInfo.substring("/reports/ignore-evaluation/".length()));
            boolean success = evaluationService.ignoreEvaluationReport(evaluationId);
            sendJsonResponse(response, success, success ? "강의평가 신고가 무시되었습니다." : "강의평가 신고 무시에 실패했습니다.");
            return;
        }

        // 잘못된 경로
        sendJsonResponse(response, false, "잘못된 요청입니다.");
    }

    // 태그 업데이트 처리
    private void updateTags(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 세션에서 사용자 정보 가져오기
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 관리자 로그인 여부 확인
        if (user == null || !user.isAdmin()) {
            sendJsonResponse(response, false, "권한이 없습니다.");
            return;
        }

        try {
            courseService.updateAllCourseTags();
            sendJsonResponse(response, true, "모든 강의의 태그가 성공적으로 업데이트되었습니다.");
        } catch (Exception e) {
            sendJsonResponse(response, false, "태그 업데이트 중 오류가 발생했습니다: " + e.getMessage());
        }
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 올바른 JSON 형식으로 생성
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":").append(success).append(",");
        json.append("\"message\":\"").append(message.replace("\"", "\\\"")).append("\"");
        json.append("}");

        out.print(json.toString());
        out.flush();
    }

    private void authenticateAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 입력값 검증
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "아이디와 비밀번호를 모두 입력해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/admin-login.jsp").forward(request, response);
            return;
        }

        // 사용자 조회
        User user = userDAO.getUserByUsername(username);

        // 사용자가 존재하지 않거나 관리자가 아닌 경우
        if (user == null || !user.isAdmin()) {
            request.setAttribute("error", "관리자 계정이 아니거나 존재하지 않는 계정입니다.");
            request.getRequestDispatcher("/WEB-INF/views/admin-login.jsp").forward(request, response);
            return;
        }

        // 비밀번호 검증
        if (!PasswordUtil.verifyPassword(password, user.getPassword())) {
            request.setAttribute("error", "비밀번호가 일치하지 않습니다.");
            request.getRequestDispatcher("/WEB-INF/views/admin-login.jsp").forward(request, response);
            return;
        }

        // 세션에 사용자 정보 저장
        HttpSession session = request.getSession();
        session.setAttribute("user", user);

        // 관리자 대시보드로 리다이렉트
        response.sendRedirect(request.getContextPath() + "/admin");
    }

    private void changeAdminPassword(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // 세션에서 사용자 정보 가져오기
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 관리자 로그인 여부 확인
        if (user == null || !user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // 입력값 검증
        if (currentPassword == null || currentPassword.trim().isEmpty() ||
                newPassword == null || newPassword.trim().isEmpty() ||
                confirmPassword == null || confirmPassword.trim().isEmpty()) {
            request.setAttribute("passwordError", "모든 필드를 입력해주세요.");
            loadDashboardData(request);
            request.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(request, response);
            return;
        }

        // 현재 비밀번호 검증
        if (!PasswordUtil.verifyPassword(currentPassword, user.getPassword())) {
            request.setAttribute("passwordError", "현재 비밀번호가 일치하지 않습니다.");
            loadDashboardData(request);
            request.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(request, response);
            return;
        }

        // 새 비밀번호와 확인 비밀번호 일치 여부 검증
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("passwordError", "새 비밀번호와 확인 비밀번호가 일치하지 않습니다.");
            loadDashboardData(request);
            request.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(request, response);
            return;
        }

        // 비밀번호 복잡성 검증
        if (newPassword.length() < 8 || !newPassword.matches(".*[A-Za-z].*") ||
                !newPassword.matches(".*\\d.*") || !newPassword.matches(".*[!@#$%^&*()].*")) {
            request.setAttribute("passwordError", "비밀번호는 최소 8자 이상이어야 하며, 문자, 숫자, 특수문자를 포함해야 합니다.");
            loadDashboardData(request);
            request.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(request, response);
            return;
        }

        // 비밀번호 변경
        String hashedPassword = PasswordUtil.hashPassword(newPassword);
        boolean success = userDAO.updatePassword(user.getId(), hashedPassword);

        if (success) {
            // 세션에 저장된 사용자 정보 업데이트
            user.setPassword(hashedPassword);
            session.setAttribute("user", user);

            request.setAttribute("passwordSuccess", "비밀번호가 성공적으로 변경되었습니다.");
        } else {
            request.setAttribute("passwordError", "비밀번호 변경 중 오류가 발생했습니다.");
        }

        loadDashboardData(request);
        request.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(request, response);
    }

    private void addUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 세션에서 사용자 정보 가져오기
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 관리자 로그인 여부 확인
        if (user == null || !user.isAdmin()) {
            sendJsonResponse(response, false, "권한이 없습니다.");
            return;
        }

        // 요청 파라미터 가져오기
        String username = request.getParameter("username");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String department = request.getParameter("department");
        String studentId = request.getParameter("studentId");
        String password = request.getParameter("password");
        boolean isAdmin = "on".equals(request.getParameter("isAdmin"));

        // 필수 입력값 검증
        if (username == null || username.trim().isEmpty() ||
                name == null || name.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            sendJsonResponse(response, false, "필수 입력값이 누락되었습니다.");
            return;
        }

        try {
            // 사용자 생성
            User newUser = new User();
            newUser.setUsername(username);
            newUser.setName(name);
            newUser.setEmail(email);
            newUser.setDepartment(department);
            newUser.setStudentId(studentId);
            newUser.setPassword(PasswordUtil.hashPassword(password));
            newUser.setAdmin(isAdmin);

            // 사용자 추가
            boolean success = userDAO.addUser(newUser);

            if (success) {
                sendJsonResponse(response, true, "사용자가 성공적으로 추가되었습니다.");
            } else {
                sendJsonResponse(response, false, "사용자 추가 중 오류가 발생했습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, false, "사용자 추가 중 오류가 발생했습니다: " + e.getMessage());
        }
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 세션에서 사용자 정보 가져오기
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 관리자 로그인 여부 확인
        if (user == null || !user.isAdmin()) {
            sendJsonResponse(response, false, "권한이 없습니다.");
            return;
        }

        // 사용자 ID 추출
        String pathInfo = request.getPathInfo();
        String userId = pathInfo.substring("/users/delete/".length());

        try {
            int id = Integer.parseInt(userId);

            // 자기 자신은 삭제할 수 없음
            if (id == user.getId()) {
                sendJsonResponse(response, false, "자기 자신은 삭제할 수 없습니다.");
                return;
            }

            // 사용자 삭제
            boolean success = userDAO.deleteUser(id);

            if (success) {
                sendJsonResponse(response, true, "사용자가 성공적으로 삭제되었습니다.");
            } else {
                sendJsonResponse(response, false, "사용자 삭제 중 오류가 발생했습니다.");
            }
        } catch (NumberFormatException e) {
            sendJsonResponse(response, false, "잘못된 사용자 ID입니다.");
        } catch (Exception e) {
            e.printStackTrace();
            sendJsonResponse(response, false, "사용자 삭제 중 오류가 발생했습니다: " + e.getMessage());
        }
    }
}
