package com.minari.tungzang.controller;

import com.minari.tungzang.model.Evaluation;
import com.minari.tungzang.model.User;
import com.minari.tungzang.service.EvaluationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/evaluationsList/*")
public class EvaluationsListServlet extends HttpServlet {

    private EvaluationService evaluationService;

    @Override
    public void init() throws ServletException {
        super.init();
        evaluationService = new EvaluationService();
    }

    /**
     * GET 요청 처리 - JSP 페이지 서빙만 담당
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        String departmentParam = request.getParameter("department");
        String sortByParam = request.getParameter("sortBy");
        String searchParam = request.getParameter("search");
        String filterParam = request.getParameter("filter");

        System.out.println("DEBUG: EvaluationsListServlet - pathInfo = " + pathInfo);
        System.out.println("DEBUG: searchParam = " + searchParam);
        System.out.println("DEBUG: departmentParam = " + departmentParam);
        System.out.println("DEBUG: sortByParam = " + sortByParam);
        System.out.println("DEBUG: filterParam = " + filterParam);

        // 로그인 상태 확인
        HttpSession session = request.getSession(false);
        User currentUser = null;
        boolean isLoggedIn = false;

        if (session != null && session.getAttribute("user") != null) {
            currentUser = (User) session.getAttribute("user");
            isLoggedIn = true;
        }

        // 강의평가 목록 페이지 처리
        System.out.println("DEBUG: 강의평가 목록 페이지 처리 중");

        // 모든 강의평가 가져오기
        List<Evaluation> evaluations = evaluationService.getAllEvaluations();
        System.out.println("DEBUG: 강의평가 목록 가져옴 - 개수: " + evaluations.size());

        // 각 평가에 필요한 추가 정보 설정
        for (Evaluation evaluation : evaluations) {
            // userName이 있다면 이를 사용하여 authorInitial과 authorName 설정
            if (evaluation.getUserName() != null) {
                evaluation.setAuthorInitial(evaluation.getUserName().substring(0, 1));
                evaluation.setAuthorName(evaluation.getUserName());
            } else {
                evaluation.setAuthorInitial("U");
                evaluation.setAuthorName("익명 사용자");
            }

            // 학기 정보 설정
            evaluation.setSemester("2024년 2학기");

            // 제목 설정 (comment의 첫 부분을 사용)
            String comment = evaluation.getComment();
            if (comment != null && !comment.isEmpty()) {
                int endIndex = Math.min(comment.length(), 30);
                int newlineIndex = comment.indexOf("\n");
                if (newlineIndex > 0 && newlineIndex < endIndex) {
                    endIndex = newlineIndex;
                }
                evaluation.setTitle(comment.substring(0, endIndex) + (endIndex < comment.length() ? "..." : ""));
                evaluation.setContent(comment);
            } else {
                evaluation.setTitle("강의 평가");
                evaluation.setContent("");
            }

            // 좋아요 정보 설정 (임의로 설정)
            evaluation.setLiked(false);
            evaluation.setReported(false);
            evaluation.setLikes((int)(Math.random() * 15) + 1);
        }

        // 검색 파라미터가 있는 경우 필터링
        if (searchParam != null && !searchParam.isEmpty()) {
            System.out.println("DEBUG: 검색어로 필터링: " + searchParam);
            String search = searchParam.toLowerCase();
            evaluations = evaluations.stream()
                    .filter(e -> (e.getCourseName() != null && e.getCourseName().toLowerCase().contains(search)) ||
                            (e.getProfessor() != null && e.getProfessor().toLowerCase().contains(search)) ||
                            (e.getComment() != null && e.getComment().toLowerCase().contains(search)))
                    .collect(Collectors.toList());
            System.out.println("DEBUG: 검색 결과 개수: " + evaluations.size());
        }

        // 강의 유형 필터링
        if (filterParam != null && !filterParam.isEmpty() && !filterParam.equals("all")) {
            System.out.println("DEBUG: 강의 유형으로 필터링: " + filterParam);
            evaluations = evaluations.stream()
                    .filter(e -> e.getCourseType() != null && e.getCourseType().equals(filterParam))
                    .collect(Collectors.toList());
            System.out.println("DEBUG: 강의 유형 필터링 결과 개수: " + evaluations.size());
        }

        // 정렬
        if (sortByParam != null && !sortByParam.isEmpty()) {
            System.out.println("DEBUG: 정렬 방식: " + sortByParam);
            switch (sortByParam) {
                case "rating-high":
                    evaluations.sort((e1, e2) -> Integer.compare(e2.getRating(), e1.getRating()));
                    break;
                case "rating-low":
                    evaluations.sort((e1, e2) -> Integer.compare(e1.getRating(), e2.getRating()));
                    break;
                case "likes":
                    evaluations.sort((e1, e2) -> Integer.compare(e2.getLikes(), e1.getLikes()));
                    break;
                case "recent":
                default:
                    // 최신순은 기본 정렬 (날짜 기준 내림차순)
                    evaluations.sort((e1, e2) -> e2.getDate().compareTo(e1.getDate()));
                    break;
            }
        }

        // JSP에 데이터 전달
        request.setAttribute("evaluations", evaluations);
        request.setAttribute("isLoggedIn", isLoggedIn);
        request.setAttribute("currentUser", currentUser);

        // evaluationsList.jsp로 포워딩
        String jspPath = "/evaluationsList.jsp";
        System.out.println("DEBUG: JSP 포워딩 경로: " + jspPath);
        request.getRequestDispatcher(jspPath).forward(request, response);
    }
}
