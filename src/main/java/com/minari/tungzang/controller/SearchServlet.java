package com.minari.tungzang.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.minari.tungzang.model.User;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 검색어 파라미터 가져오기
        String query = request.getParameter("query");

        // 사용자 정보 가져오기 (이미 세션에 있음)

        // 검색 결과 (실제로는 DB에서 가져와야 함)
        List<Map<String, Object>> courseResults = new ArrayList<>();
        List<Map<String, Object>> evaluationResults = new ArrayList<>();
        List<Map<String, Object>> postResults = new ArrayList<>();

        if (query != null && !query.trim().isEmpty()) {
            // 강의 검색 결과 예시
            for (int i = 1; i <= 3; i++) {
                Map<String, Object> course = new HashMap<>();
                course.put("id", i);
                course.put("name", "자료구조와 알고리즘 " + i);
                course.put("professor", "김교수");
                course.put("department", "컴퓨터공학과");
                course.put("rating", 4.5);
                course.put("tags", new String[]{"꿀강의", "학점좋음", "과제많음"});
                courseResults.add(course);
            }

            // 강의평가 검색 결과 예시
            for (int i = 1; i <= 2; i++) {
                Map<String, Object> evaluation = new HashMap<>();
                evaluation.put("id", i);
                evaluation.put("courseName", "프로그래밍 기초 " + i);
                evaluation.put("professor", "이교수");
                evaluation.put("rating", 4.0);
                evaluation.put("content", "이 강의는 매우 유익했습니다. 교수님의 설명이 명확하고 이해하기 쉬웠습니다.");
                evaluation.put("semester", "2023년 1학기");
                evaluation.put("likes", 15);
                evaluation.put("author", "학생" + i);
                evaluation.put("date", "2023-06-15");
                evaluationResults.add(evaluation);
            }

            // 게시글 검색 결과 예시
            for (int i = 1; i <= 4; i++) {
                Map<String, Object> post = new HashMap<>();
                post.put("id", i);
                post.put("title", "시험 정보 공유합니다 " + i);
                post.put("content", "이번 중간고사 범위는 1장부터 5장까지입니다. 특히 3장이 중요하다고 하네요.");
                post.put("category", "정보공유");
                post.put("author", "익명" + i);
                post.put("date", "2023-06-20");
                post.put("views", 120);
                post.put("comments", 8);
                post.put("likes", 25);
                postResults.add(post);
            }
        }

        // 전체 결과 수
        int totalResults = courseResults.size() + evaluationResults.size() + postResults.size();

        // 최근 검색어 예시 (실제로는 세션이나 DB에서 가져와야 함)
        String[] recentSearches = {"자료구조", "알고리즘", "프로그래밍", "데이터베이스"};

        // 인기 검색어 예시 (실제로는 DB에서 가져와야 함)
        String[] popularSearches = {"기초프로그래밍", "자바", "파이썬", "웹개발", "인공지능"};

        // 검색 결과를 request에 설정
        request.setAttribute("query", query);
        request.setAttribute("courseResults", courseResults);
        request.setAttribute("evaluationResults", evaluationResults);
        request.setAttribute("postResults", postResults);
        request.setAttribute("totalResults", totalResults);
        request.setAttribute("recentSearches", recentSearches);
        request.setAttribute("popularSearches", popularSearches);

        // 검색 결과 페이지로 포워드
        request.getRequestDispatcher("/WEB-INF/views/search.jsp").forward(request, response);
    }
}
