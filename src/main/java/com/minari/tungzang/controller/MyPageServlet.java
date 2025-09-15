package com.minari.tungzang.controller;

import com.minari.tungzang.model.Evaluation;
import com.minari.tungzang.model.Post;
import com.minari.tungzang.model.Comment;
import com.minari.tungzang.model.User;
import com.minari.tungzang.model.TimetableCourse;
import com.minari.tungzang.model.Badge;
import com.minari.tungzang.service.EvaluationService;
import com.minari.tungzang.service.PostService;
import com.minari.tungzang.service.CommentService;
import com.minari.tungzang.service.UserService;
import com.minari.tungzang.service.TimetableService;
import com.minari.tungzang.service.BadgeService;
import com.minari.tungzang.util.ValidationUtil;
import com.minari.tungzang.dao.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.ArrayList;

@WebServlet("/mypage/*")
public class MyPageServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MyPageServlet.class.getName());
    private UserService userService;
    private EvaluationService evaluationService;
    private PostService postService;
    private CommentService commentService;
    private TimetableService timetableService;
    private BadgeService badgeService;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        userService = new UserService();
        evaluationService = new EvaluationService();
        postService = new PostService();
        commentService = new CommentService();
        timetableService = new TimetableService();
        badgeService = new BadgeService();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=mypage");
            return;
        }

        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // 마이페이지 메인
                List<Evaluation> userEvaluations = evaluationService.getUserEvaluations(user.getId());
                List<Post> userPosts = postService.getPostsByUserId(user.getId());
                List<Comment> userComments = commentService.getCommentsByUserId(user.getId());

                // 시간표 데이터 가져오기 - 디버깅 추가
                LOGGER.info("시간표 데이터 조회 시작: 사용자 ID=" + user.getId());
                List<TimetableCourse> userTimetable = timetableService.getTimetableCoursesByUserId(user.getId());

                // 수정된 부분: null 체크를 더 명확하게 하고 로깅 개선
                if (userTimetable == null) {
                    userTimetable = new ArrayList<>();
                    LOGGER.warning("시간표 서비스에서 null 반환됨, 빈 리스트로 초기화");
                }

                // 명시적으로 true로 설정 (userTimetable.size() > 0)
                boolean hasTimetableData = userTimetable.size() > 0;
                LOGGER.info("시간표 데이터 조회 완료: 리스트 크기=" + userTimetable.size() + ", 데이터 존재=" + hasTimetableData);

                // 디버깅을 위해 시간표 데이터 로깅
                if (hasTimetableData) {
                    LOGGER.info("시간표 데이터 상세:");
                    for (int i = 0; i < userTimetable.size(); i++) {
                        TimetableCourse course = userTimetable.get(i);
                        LOGGER.info("  [" + (i+1) + "] ID=" + course.getId() + ", 이름=" + course.getName() +
                                ", 요일=" + course.getDay() + ", 시작=" + course.getStartTime() +
                                ", 종료=" + course.getEndTime() + ", 색상=" + course.getColor());
                    }
                } else {
                    LOGGER.info("시간표 데이터가 비어있습니다.");
                }

                // 배지 시스템 데이터 추가
                List<Badge> userBadges = badgeService.getUserBadges(user);
                Map<String, Integer> activityCounts = badgeService.getUserActivityCounts(user);
                String userGrade = badgeService.getUserGrade(userBadges);
                int earnedBadgeCount = badgeService.getEarnedBadgeCount(userBadges);
                int totalBadgeCount = userBadges.size();

                request.setAttribute("userEvaluations", userEvaluations);
                request.setAttribute("userPosts", userPosts);
                request.setAttribute("userComments", userComments);
                request.setAttribute("userTimetable", userTimetable);
                request.setAttribute("hasTimetableData", hasTimetableData);
                request.setAttribute("userBadges", userBadges);
                request.setAttribute("activityCounts", activityCounts);
                request.setAttribute("userGrade", userGrade);
                request.setAttribute("earnedBadgeCount", earnedBadgeCount);
                request.setAttribute("totalBadgeCount", totalBadgeCount);

                request.getRequestDispatcher("/WEB-INF/views/my-page.jsp").forward(request, response);
            } else if (pathInfo.equals("/profile")) {
                // 프로필 수정 페이지
                request.getRequestDispatcher("/WEB-INF/views/profile-edit.jsp").forward(request, response);
            } else if (pathInfo.equals("/password")) {
                // 비밀번호 변경 페이지
                request.getRequestDispatcher("/WEB-INF/views/password-change.jsp").forward(request, response);
            } else if (pathInfo.equals("/settings")) {
                // 계정 설정 페이지
                request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "마이페이지 처리 중 오류 발생", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/profile")) {
                // 프로필 수정 처리
                handleProfileUpdate(request, response, user, session);
            } else if (pathInfo.equals("/password")) {
                // 기존 비밀번호 변경 처리
                handlePasswordChange(request, response, user);
            } else if (pathInfo.equals("/change-password")) {
                // 새로운 비밀번호 변경 처리 (계정 설정에서)
                handleAccountPasswordChange(request, response, user);
            } else if (pathInfo.equals("/delete-account")) {
                // 회원탈퇴 처리
                handleAccountDeletion(request, response, user, session);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "마이페이지 POST 요청 처리 중 오류 발생", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void handleProfileUpdate(HttpServletRequest request, HttpServletResponse response, User user, HttpSession session)
            throws ServletException, IOException, SQLException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String department = request.getParameter("department");
        String studentId = request.getParameter("studentId");

        if (ValidationUtil.isEmpty(name) || !ValidationUtil.isValidEmail(email)) {
            request.setAttribute("error", "이름과 이메일을 올바르게 입력해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/profile-edit.jsp").forward(request, response);
            return;
        }

        User updatedUser = new User();
        updatedUser.setId(user.getId());
        updatedUser.setName(name);
        updatedUser.setEmail(email);
        updatedUser.setDepartment(department);
        updatedUser.setStudentId(studentId);

        boolean success = false;
        try {
            success = userService.updateUser(updatedUser);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 정보 업데이트 중 오류 발생", e);
            request.setAttribute("error", "프로필 업데이트에 실패했습니다. 다시 시도해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/profile-edit.jsp").forward(request, response);
            return;
        }

        if (success) {
            // 세션 업데이트
            User refreshedUser = userService.getUser(user.getId());
            session.setAttribute("user", refreshedUser);

            response.sendRedirect(request.getContextPath() + "/mypage?success=profile");
        } else {
            request.setAttribute("error", "프로필 업데이트에 실패했습니다. 다시 시도해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/profile-edit.jsp").forward(request, response);
        }
    }

    private void handlePasswordChange(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException, SQLException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (ValidationUtil.isEmpty(currentPassword) || ValidationUtil.isEmpty(newPassword) ||
                ValidationUtil.isEmpty(confirmPassword)) {
            request.setAttribute("error", "모든 필드를 입력해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/password-change.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "새 비밀번호와 확인 비밀번호가 일치하지 않습니다.");
            request.getRequestDispatcher("/WEB-INF/views/password-change.jsp").forward(request, response);
            return;
        }

        boolean success = false;
        try {
            success = userService.updatePassword(user.getId(), currentPassword, newPassword);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "비밀번호 변경 중 오류 발생", e);
            request.setAttribute("error", "비밀번호 변경에 실패했습니다. 다시 시도해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/password-change.jsp").forward(request, response);
            return;
        }

        if (success) {
            response.sendRedirect(request.getContextPath() + "/mypage?success=password");
        } else {
            request.setAttribute("error", "비밀번호 변경에 실패했습니다. 현재 비밀번호를 확인해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/password-change.jsp").forward(request, response);
        }
    }

    private void handleAccountPasswordChange(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // 디버깅 로그 추가
        LOGGER.info("=== 비밀번호 변경 디버깅 ===");
        LOGGER.info("사용자 ID: " + user.getId());
        LOGGER.info("현재 비밀번호 입력값: " + currentPassword);
        LOGGER.info("새 비밀번호 입력값: " + newPassword);
        LOGGER.info("확인 비밀번호 입력값: " + confirmPassword);

        // 입력값 검증
        if (ValidationUtil.isEmpty(currentPassword) || ValidationUtil.isEmpty(newPassword) ||
                ValidationUtil.isEmpty(confirmPassword)) {
            request.setAttribute("error", "모든 필드를 입력해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() < 8) {
            request.setAttribute("error", "새 비밀번호는 8자 이상이어야 합니다.");
            request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "새 비밀번호와 확인 비밀번호가 일치하지 않습니다.");
            request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
            return;
        }

        if (currentPassword.equals(newPassword)) {
            request.setAttribute("error", "현재 비밀번호와 새 비밀번호가 같습니다. 다른 비밀번호를 입력해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
            return;
        }

        // 기존 코드 제거:
        // if (!userDAO.verifyPassword(user.getId(), currentPassword)) {
        //     request.setAttribute("error", "현재 비밀번호가 올바르지 않습니다.");
        //     request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
        //     return;
        // }
        // boolean success = userDAO.updatePassword(user.getId(), newPassword);

        // 새로운 코드로 교체:
        boolean success = false;
        try {
            success = userService.updatePassword(user.getId(), currentPassword, newPassword);
            LOGGER.info("비밀번호 변경 결과: " + success);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "비밀번호 변경 중 오류 발생", e);
            request.setAttribute("error", "비밀번호 변경에 실패했습니다. 다시 시도해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
            return;
        }

        if (success) {
            LOGGER.info("비밀번호 변경 성공: 사용자 ID=" + user.getId());
            response.sendRedirect(request.getContextPath() + "/mypage/settings?success=password_changed");
        } else {
            request.setAttribute("error", "현재 비밀번호가 올바르지 않습니다.");
            request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
        }
    }

    private void handleAccountDeletion(HttpServletRequest request, HttpServletResponse response, User user, HttpSession session)
            throws ServletException, IOException {
        String password = request.getParameter("password");

        // 입력값 검증
        if (ValidationUtil.isEmpty(password)) {
            request.setAttribute("error", "비밀번호를 입력해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
            return;
        }

        // 관리자 계정 삭제 방지
        if (user.isAdmin()) {
            request.setAttribute("error", "관리자 계정은 삭제할 수 없습니다.");
            request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
            return;
        }

        // 비밀번호 확인
        if (!userDAO.verifyPassword(user.getId(), password)) {
            request.setAttribute("error", "비밀번호가 올바르지 않습니다.");
            request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
            return;
        }

        try {
            // 관련 데이터 삭제 (외래키 제약조건 때문에 순서 중요)
            // 1. 댓글 삭제
            commentService.deleteCommentsByUserId(user.getId());

            // 2. 게시글 삭제
            postService.deletePostsByUserId(user.getId());

            // 3. 강의평가 삭제
            evaluationService.deleteEvaluationsByUserId(user.getId());

            // 4. 시간표 삭제
            timetableService.deleteTimetableByUserId(user.getId());

            // 5. 사용자 계정 삭제
            boolean success = userDAO.deleteUser(user.getId());

            if (success) {
                LOGGER.info("계정 삭제 성공: 사용자 ID=" + user.getId() + ", 이름=" + user.getName());

                // 세션 무효화
                session.invalidate();

                // 계정 삭제 완료 페이지로 리다이렉트
                response.sendRedirect(request.getContextPath() + "/account-deleted.jsp");
            } else {
                request.setAttribute("error", "계정 삭제에 실패했습니다. 다시 시도해주세요.");
                request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "계정 삭제 중 오류 발생: 사용자 ID=" + user.getId(), e);
            request.setAttribute("error", "계정 삭제 중 오류가 발생했습니다. 관리자에게 문의해주세요.");
            request.getRequestDispatcher("/WEB-INF/views/account-settings.jsp").forward(request, response);
        }
    }
}