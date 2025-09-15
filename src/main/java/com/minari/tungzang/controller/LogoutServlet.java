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

/**
 * 로그아웃 처리를 담당하는 서블릿
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(LogoutServlet.class.getName());

    /**
     * GET 요청 처리 - 로그아웃 수행
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LOGGER.info("로그아웃 요청 처리 시작: " + request.getRequestURI());

        try {
            // 세션 가져오기
            HttpSession session = request.getSession(false);

            if (session != null) {
                // 로그인된 사용자 정보 로깅
                Object user = session.getAttribute("user");
                if (user != null) {
                    LOGGER.info("사용자 로그아웃: " + user);
                }

                // 세션 무효화
                session.invalidate();
                LOGGER.info("세션 무효화 완료");
            } else {
                LOGGER.info("로그아웃 요청 시 세션이 없음");
            }

            // 컨텍스트 경로 가져오기
            String contextPath = request.getContextPath();

            // 이전 페이지 정보 가져오기
            String referer = request.getHeader("Referer");
            LOGGER.info("Referer: " + referer);

            // 홈페이지로 리다이렉트
            String redirectUrl = contextPath.isEmpty() ? "/" : contextPath;
            LOGGER.info("로그아웃 후 리다이렉트: " + redirectUrl);

            response.sendRedirect(redirectUrl);
            LOGGER.info("로그아웃 처리 완료");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "로그아웃 처리 중 오류 발생", e);
            // 오류가 발생해도 홈페이지로 리다이렉트
            response.sendRedirect(request.getContextPath() + "/");
        }
    }

    /**
     * POST 요청도 GET으로 처리
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
