package com.minari.tungzang.filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.minari.tungzang.model.User;

@WebFilter("/*")
public class AuthFilter implements Filter {
    private static final Logger LOGGER = Logger.getLogger(AuthFilter.class.getName());

    // 인증이 필요하지 않은 경로 목록
    private static final List<String> PUBLIC_PATHS = Arrays.asList(
            "/login.jsp", "/register.jsp", "/index.jsp", "/",
            "/auth/login", "/auth/register", "/auth/logout",
            "/resources/", "/error/", "/evaluations.jsp", "/timetable.jsp"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // 필터 초기화
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());

        // 정적 리소스 및 공개 경로는 인증 검사 제외
        boolean isPublicPath = false;
        for (String publicPath : PUBLIC_PATHS) {
            if (path.equals(publicPath) || path.startsWith(publicPath)) {
                isPublicPath = true;
                break;
            }
        }

        if (isPublicPath) {
            chain.doFilter(request, response);
            return;
        }

        // 세션 확인
        HttpSession session = httpRequest.getSession(false);
        User user = null;

        if (session != null) {
            user = (User) session.getAttribute("user");

            // 사용자 ID 유효성 검사
            if (user != null && user.getId() <= 0) {
                LOGGER.severe("세션에 저장된 사용자의 ID가 유효하지 않습니다: " + user.getId());
                session.invalidate();
                user = null;
            }
        }

        // 로그인 상태 확인
        if (user == null) {
            // 로그인이 필요한 경로에 대한 접근 시 로그인 페이지로 리다이렉트
            String redirectPath = httpRequest.getContextPath() + "/login.jsp";

            // 현재 요청 경로를 리다이렉트 파라미터로 추가
            if (!path.startsWith("/login") && !path.startsWith("/register")) {
                redirectPath += "?redirect=" + path.substring(1);
            }

            httpResponse.sendRedirect(redirectPath);
            return;
        }

        // 로그 추가: 요청 경로 및 사용자 정보 확인
        LOGGER.info("요청 경로: " + path + ", 사용자 ID: " + user.getId() + ", 이름: " + user.getName());

        // 필터 체인 계속 진행
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // 필터 종료
    }
}
