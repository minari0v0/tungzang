package com.minari.tungzang.controller;

import com.minari.tungzang.model.Badge;
import com.minari.tungzang.model.User;
import com.minari.tungzang.service.BadgeService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.logging.Logger;

@WebServlet("/badges")
public class BadgeServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(BadgeServlet.class.getName());
    private BadgeService badgeService;

    @Override
    public void init() throws ServletException {
        super.init();
        badgeService = new BadgeService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // 로그인이 필요한 경우 현재 요청 경로를 저장하고 로그인 필요 페이지로 리다이렉트
            String requestURI = request.getRequestURI();
            String contextPath = request.getContextPath();
            String redirectPath = requestURI.substring(contextPath.length());

            if (redirectPath.startsWith("/")) {
                redirectPath = redirectPath.substring(1);
            }

            // AJAX 요청인지 확인
            String xRequestedWith = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equals(xRequestedWith)) {
                // AJAX 요청인 경우 JSON 응답으로 로그인 필요 상태 전달
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"needLogin\":true,\"redirectUrl\":\"" + redirectPath + "\"}");
                return;
            } else {
                // 일반 요청인 경우 로그인 필요 페이지로 리다이렉트
                request.setAttribute("redirectUrl", redirectPath);
                request.getRequestDispatcher("/WEB-INF/views/login-required.jsp").forward(request, response);
                return;
            }
        }

        try {
            // 사용자의 모든 배지 조회
            List<Badge> allBadges = badgeService.getUserBadges(user);

            // 카테고리별로 배지 분류
            Map<String, List<Badge>> badgesByCategory = allBadges.stream()
                    .collect(Collectors.groupingBy(Badge::getCategory));

            // 획득한 배지와 미획득 배지 분리
            List<Badge> earnedBadges = allBadges.stream()
                    .filter(Badge::isEarned)
                    .collect(Collectors.toList());

            List<Badge> unearnedBadges = allBadges.stream()
                    .filter(badge -> !badge.isEarned())
                    .collect(Collectors.toList());

            // 사용자 등급 계산 - User 객체를 함께 전달
            String userGrade = badgeService.getUserGrade(allBadges, user);
            int earnedCount = badgeService.getEarnedBadgeCount(allBadges);
            int totalCount = allBadges.size();

            // 사용자 활동 카운트 조회
            Map<String, Integer> userCounts = badgeService.getUserActivityCounts(user);

            // 요청 속성에 데이터 설정
            request.setAttribute("user", user); // user 객체 추가
            request.setAttribute("allBadges", allBadges);
            request.setAttribute("badgesByCategory", badgesByCategory);
            request.setAttribute("earnedBadges", earnedBadges);
            request.setAttribute("unearnedBadges", unearnedBadges);
            request.setAttribute("userGrade", userGrade);
            request.setAttribute("earnedCount", earnedCount);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("completionPercentage", (earnedCount * 100) / totalCount);
            request.setAttribute("userCounts", userCounts);

            // JSP 페이지로 포워드
            request.getRequestDispatcher("/WEB-INF/views/badge-collection.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.severe("Error loading badge collection page: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
