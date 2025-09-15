package com.minari.tungzang.controller;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.minari.tungzang.dao.UserDAO;
import com.minari.tungzang.model.User;

import org.json.JSONObject;
import java.io.PrintWriter;

@WebServlet("/auth/*")
public class AuthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AuthServlet.class.getName());

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        LOGGER.info("🔍 AuthServlet 초기화됨");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        if (pathInfo != null && pathInfo.equals("/logout")) {
            // 로그아웃 요청을 LogoutServlet으로 리다이렉트
            LOGGER.info("AuthServlet에서 LogoutServlet으로 로그아웃 요청 리다이렉트");
            response.sendRedirect(request.getContextPath() + "/logout");
        } else if (pathInfo != null && pathInfo.equals("/check")) {
            // 로그인 상태 체크 API
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();

            HttpSession session = request.getSession(false);
            boolean isLoggedIn = session != null && session.getAttribute("user") != null;

            JSONObject jsonResponse = new JSONObject();
            jsonResponse.put("isLoggedIn", isLoggedIn);

            if (isLoggedIn) {
                User user = (User) session.getAttribute("user");
                jsonResponse.put("userId", user.getId());
                jsonResponse.put("userName", user.getName());
                LOGGER.info("🔍 로그인 상태 체크: 사용자 ID=" + user.getId() + ", 등급=" + user.getGrade());
            }

            out.print(jsonResponse.toString());
            return;
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo != null && pathInfo.equals("/login")) {
                // 로그인 처리
                String username = request.getParameter("username");
                String password = request.getParameter("password");
                String redirect = request.getParameter("redirect");

                LOGGER.info("🔍 로그인 시도: 사용자명=" + username);

                User user = userDAO.authenticate(username, password);

                if (user != null) {
                    // 사용자 ID 유효성 검사
                    if (user.getId() <= 0) {
                        LOGGER.severe("인증된 사용자의 ID가 유효하지 않습니다: " + user.getId());
                        request.setAttribute("error", "사용자 정보가 올바르지 않습니다. 관리자에게 문의하세요.");
                        request.getRequestDispatcher("/login.jsp").forward(request, response);
                        return;
                    }

                    LOGGER.info("🔍 로그인 성공: ID=" + user.getId() + ", 이름=" + user.getName() + ", 등급=" + user.getGrade());

                    // 세션에 사용자 정보 저장
                    HttpSession session = request.getSession();
                    session.setAttribute("user", user);

                    // 로그 추가: 세션에 저장된 사용자 정보 확인
                    LOGGER.info("세션에 사용자 정보 저장: ID=" + user.getId() + ", 이름=" + user.getName());

                    if (redirect != null && !redirect.isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/" + redirect);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/");
                    }
                } else {
                    LOGGER.info("🔍 로그인 실패: 사용자명=" + username);
                    request.setAttribute("error", "아이디 또는 비밀번호가 올바르지 않습니다.");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                }
            } else if (pathInfo != null && pathInfo.equals("/register")) {
                // 회원가입 처리
                LOGGER.info("🔍 AuthServlet 회원가입 처리 시작");
                String name = request.getParameter("name");
                String username = request.getParameter("username");
                String email = request.getParameter("email");
                String department = request.getParameter("department");
                String studentId = request.getParameter("studentId");
                String password = request.getParameter("password");
                String confirmPassword = request.getParameter("confirmPassword");

                LOGGER.info("🔍 회원가입 요청: 사용자명=" + username + ", 이름=" + name);

                // 비밀번호 확인
                if (!password.equals(confirmPassword)) {
                    request.setAttribute("error", "비밀번호가 일치하지 않습니다.");
                    request.getRequestDispatcher("/register.jsp").forward(request, response);
                    return;
                }

                // 사용자명 중복 확인
                if (userDAO.isUsernameTaken(username)) {
                    request.setAttribute("error", "이미 사용 중인 사용자명입니다.");
                    request.getRequestDispatcher("/register.jsp").forward(request, response);
                    return;
                }

                // 이메일 중복 확인
                if (userDAO.isEmailTaken(email)) {
                    request.setAttribute("error", "이미 사용 중인 이메일입니다.");
                    request.getRequestDispatcher("/register.jsp").forward(request, response);
                    return;
                }

                User user = new User();
                user.setName(name);
                user.setUsername(username);
                user.setEmail(email);
                user.setDepartment(department);
                user.setStudentId(studentId);

                LOGGER.info("🔍 회원가입 registerUser 호출 전");
                boolean success = userDAO.registerUser(user, password);
                LOGGER.info("🔍 회원가입 registerUser 호출 후: 성공=" + success);

                if (success) {
                    LOGGER.info("🔍 AuthServlet 회원가입 성공 - 추가 등급 업데이트 호출 없음");

                    // 등록된 사용자 정보 다시 조회해서 등급 확인
                    User registeredUser = userDAO.getUserByUsername(username);
                    if (registeredUser != null) {
                        LOGGER.info("🔍 등록 후 사용자 조회: ID=" + registeredUser.getId() + ", 등급=" + registeredUser.getGrade());
                    } else {
                        LOGGER.severe("🚨 등록 후 사용자 조회 실패!");
                    }

                    request.setAttribute("message", "회원가입이 완료되었습니다. 로그인해주세요.");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                } else {
                    LOGGER.severe("🚨 회원가입 실패");
                    request.setAttribute("error", "회원가입에 실패했습니다.");
                    request.getRequestDispatcher("/register.jsp").forward(request, response);
                }
            } else if (pathInfo != null && pathInfo.equals("/logout")) {
                // POST 로그아웃 요청을 LogoutServlet으로 리다이렉트
                LOGGER.info("AuthServlet에서 LogoutServlet으로 로그아웃 요청 리다이렉트 (POST)");
                response.sendRedirect(request.getContextPath() + "/logout");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "인증 처리 중 오류 발생", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "서버 오류가 발생했습니다.");
        }
    }
}
