package com.minari.tungzang.controller;

import com.minari.tungzang.model.Course;
import com.minari.tungzang.model.Evaluation;
import com.minari.tungzang.model.User;
import com.minari.tungzang.model.TimetableCourse;
import com.minari.tungzang.service.CourseService;
import com.minari.tungzang.service.EvaluationService;
import com.minari.tungzang.service.TimetableService;
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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/evaluations/*")
public class EvaluationsServlet extends HttpServlet {

    private EvaluationService evaluationService;
    private CourseService courseService;
    private TimetableService timetableService;

    @Override
    public void init() throws ServletException {
        super.init();
        evaluationService = new EvaluationService();
        courseService = new CourseService();
        timetableService = new TimetableService();

        // 서버 시작 시 모든 강의의 태그 업데이트 (선택 사항)
        // courseService.updateAllCourseTags();
    }

    /**
     * GET 요청 처리
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        String courseIdParam = request.getParameter("courseId");
        String departmentParam = request.getParameter("department");
        String sortByParam = request.getParameter("sortBy");
        String typeParam = request.getParameter("type");
        String searchParam = request.getParameter("search");
        String filterParam = request.getParameter("filter");
        String acceptHeader = request.getHeader("Accept");
        String requestURI = request.getRequestURI();

        System.out.println("DEBUG: pathInfo = " + pathInfo);
        System.out.println("DEBUG: requestURI = " + requestURI);
        System.out.println("DEBUG: searchParam = " + searchParam);
        System.out.println("DEBUG: departmentParam = " + departmentParam);
        System.out.println("DEBUG: sortByParam = " + sortByParam);
        System.out.println("DEBUG: filterParam = " + filterParam);

        // HTML 요청인지 확인 (브라우저에서 직접 접근)
        boolean isHtmlRequest = acceptHeader != null &&
                (acceptHeader.contains("text/html") || acceptHeader.contains("*/*"));

        // API 요청인지 확인 (명시적으로 JSON을 요청하는 경우)
        boolean isApiRequest = acceptHeader != null &&
                acceptHeader.contains("application/json");

        // /evaluations/write/X 패턴 확인 (강의 평가 작성 페이지)
        if (pathInfo != null && pathInfo.startsWith("/write/")) {
            System.out.println("DEBUG: /evaluations/write/X 패턴 감지됨");
            try {
                // 로그인 확인
                HttpSession session = request.getSession(false);
                if (session == null || session.getAttribute("user") == null) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=evaluations" + pathInfo);
                    return;
                }

                int courseId = Integer.parseInt(pathInfo.substring("/write/".length()));
                System.out.println("DEBUG: 강의 ID: " + courseId);

                Course course = courseService.getCourseById(courseId);

                if (course == null) {
                    System.out.println("DEBUG: 강의를 찾을 수 없음");
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "강의를 찾을 수 없습니다.");
                    return;
                }

                // JSP에 데이터 전달
                request.setAttribute("course", course);

                // evaluation-course-write.jsp로 포워딩
                String jspPath = "/WEB-INF/views/evaluation-course-write.jsp";
                System.out.println("DEBUG: JSP 포워딩 경로: " + jspPath);
                request.getRequestDispatcher(jspPath).forward(request, response);
                return;
            } catch (Exception e) {
                System.out.println("ERROR: " + e.getMessage());
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "서버 오류가 발생했습니다: " + e.getMessage());
                return;
            }
        }

        // /evaluations/course/X 패턴 확인 (강의 상세 페이지 요청)
        if (pathInfo != null && pathInfo.startsWith("/course/")) {
            System.out.println("DEBUG: /evaluations/course/X 패턴 감지됨");
            try {
                int courseId = Integer.parseInt(pathInfo.substring("/course/".length()));
                System.out.println("DEBUG: 강의 ID: " + courseId);

                Course course = courseService.getCourseById(courseId);

                if (course == null) {
                    System.out.println("DEBUG: 강의를 찾을 수 없음");
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "강의를 찾을 수 없습니다.");
                    return;
                }

                // 강의 평가 목록 가져오기
                List<Evaluation> evaluations = evaluationService.getEvaluationsByCourse(courseId);
                System.out.println("DEBUG: 강의 평가 개수: " + evaluations.size());

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

                    // 학기 정보 설정 (예: 2023년 1학기)
                    evaluation.setSemester("2023년 1학기");

                    // 제목 설정 (comment의 첫 부분을 사용)
                    String comment = evaluation.getComment();
                    if (comment != null && !comment.isEmpty()) {
                        // 첫 20자를 제목으로 사용하거나, 줄바꿈이 있으면 첫 줄을 사용
                        int endIndex = Math.min(comment.length(), 20);
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

                    // 성적 정보 설정 (임의로 A~F 중 하나 설정)
                    String[] grades = {"A+", "A", "B+", "B", "C+", "C", "D", "F"};
                    int gradeIndex = (int)(Math.random() * grades.length);
                    evaluation.setGrading(gradeIndex);

                    // 좋아요 정보 설정 (임의로 설정)
                    evaluation.setLiked(false);
                    evaluation.setReported(false);
                    evaluation.setLikes((int)(Math.random() * 10));
                }

                // JSP에 데이터 전달
                request.setAttribute("course", course);
                request.setAttribute("evaluations", evaluations);
                request.setAttribute("currentPage", 1);
                request.setAttribute("totalPages", 1);

                // evaluation-detail.jsp로 포워딩
                String jspPath = "/WEB-INF/views/evaluation-detail.jsp";
                System.out.println("DEBUG: JSP 포워딩 경로: " + jspPath);
                request.getRequestDispatcher(jspPath).forward(request, response);
                return;
            } catch (Exception e) {
                System.out.println("ERROR: " + e.getMessage());
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "서버 오류가 발생했습니다: " + e.getMessage());
                return;
            }
        }

        // /evaluations/write 패턴 확인 (강의 선택 페이지)
        if (pathInfo != null && pathInfo.equals("/write")) {
            System.out.println("DEBUG: /evaluations/write 패턴 감지됨");
            try {
                // 로그인 확인
                HttpSession session = request.getSession(false);
                if (session == null || session.getAttribute("user") == null) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=evaluations/write");
                    return;
                }

                User user = (User) session.getAttribute("user");

                // 사용자의 시간표에 등록된 강의 목록 가져오기
                List<TimetableCourse> timetableCourses = timetableService.getTimetableCoursesByUserId(user.getId());
                List<Course> userCourses = new ArrayList<>();

                // 시간표 강의를 기반으로 Course 객체 생성 또는 조회
                for (int i = 0; i < timetableCourses.size(); i++) {
                    TimetableCourse tc = timetableCourses.get(i);

                    // 먼저 기존 강의 검색
                    List<Course> existingCourses = courseService.searchCourses(tc.getName());
                    Course matchingCourse = null;

                    for (Course c : existingCourses) {
                        if (c.getName().equals(tc.getName()) && c.getProfessor().equals(tc.getProfessor())) {
                            matchingCourse = c;
                            break;
                        }
                    }

                    if (matchingCourse == null) {
                        // 기존 강의가 없으면 임시 Course 객체 생성
                        Course newCourse = new Course();
                        newCourse.setName(tc.getName());
                        newCourse.setProfessor(tc.getProfessor());
                        newCourse.setDepartment(user.getDepartment() != null ? user.getDepartment() : "기타");
                        newCourse.setDepartmentId("other");
                        newCourse.setType("unknown");

                        // 임시 ID 설정 (음수 값으로 설정)
                        newCourse.setId(-i - 1); // -1, -2, -3, ...
                        userCourses.add(newCourse);
                    } else {
                        userCourses.add(matchingCourse);
                    }
                }

                // 중복 제거
                List<Course> uniqueCourses = new ArrayList<>();
                for (Course c : userCourses) {
                    boolean isDuplicate = false;
                    for (Course uc : uniqueCourses) {
                        if (c.getName().equals(uc.getName()) && c.getProfessor().equals(uc.getProfessor())) {
                            isDuplicate = true;
                            break;
                        }
                    }
                    if (!isDuplicate) {
                        uniqueCourses.add(c);
                    }
                }

                // JSP에 데이터 전달
                request.setAttribute("courses", uniqueCourses);

                // evaluation-write.jsp로 포워딩
                String jspPath = "/WEB-INF/views/evaluation-write.jsp";
                System.out.println("DEBUG: JSP 포워딩 경로: " + jspPath);
                request.getRequestDispatcher(jspPath).forward(request, response);
                return;
            }catch (Exception e) {
                System.out.println("ERROR: " + e.getMessage());
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "서버 오류가 발생했습니다: " + e.getMessage());
                return;
            }
        }

        // /evaluations/delete/X 패턴 확인 (GET 요청으로 들어온 삭제 요청 처리)
        if (pathInfo != null && pathInfo.startsWith("/delete/")) {
            // 삭제 요청은 POST로만 처리하도록 리다이렉트
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "삭제 요청은 POST 메소드로만 가능합니다.");
            return;
        }

        // /evaluations/X 패턴 확인 (강의 상세 페이지로 리다이렉트)
        if (pathInfo != null && pathInfo.matches("/\\d+")) {
            System.out.println("DEBUG: /evaluations/X 패턴 감지됨: " + pathInfo);
            try {
                int courseId = Integer.parseInt(pathInfo.substring(1));
                System.out.println("DEBUG: 강의 ID: " + courseId);

                // 강의 상세 페이지로 리다이렉트
                response.sendRedirect(request.getContextPath() + "/evaluations/course/" + courseId);
                return;
            } catch (Exception e) {
                System.out.println("ERROR: " + e.getMessage());
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "서버 오류가 발생했습니다: " + e.getMessage());
                return;
            }
        }

        // HTML 요청이고 특정 경로가 없는 경우 (강의평가 목록 페이지)
        if ((isHtmlRequest && !isApiRequest) && (pathInfo == null || pathInfo.equals("/"))) {
            System.out.println("DEBUG: 강의평가 목록 페이지 처리 중");

            // 강의 목록 가져오기
            List<Course> courses = courseService.getAllCourses();
            System.out.println("DEBUG: 강의 목록 가져옴 - 개수: " + courses.size());

            // 검색 파라미터가 있는 경우 필터링
            if (searchParam != null && !searchParam.isEmpty()) {
                System.out.println("DEBUG: 검색어로 필터링: " + searchParam);
                String search = searchParam.toLowerCase();
                courses = courses.stream()
                        .filter(c -> c.getName().toLowerCase().contains(search) ||
                                c.getProfessor().toLowerCase().contains(search))
                        .collect(Collectors.toList());
                System.out.println("DEBUG: 검색 결과 개수: " + courses.size());
            }

            // 학과 필터링
            if (departmentParam != null && !departmentParam.isEmpty() && !departmentParam.equals("all")) {
                System.out.println("DEBUG: 학과로 필터링: " + departmentParam);
                courses = courses.stream()
                        .filter(c -> c.getDepartmentId() != null && c.getDepartmentId().equals(departmentParam))
                        .collect(Collectors.toList());
                System.out.println("DEBUG: 학과 필터링 결과 개수: " + courses.size());
            }

            // 강의 유형 필터링
            if (filterParam != null && !filterParam.isEmpty() && !filterParam.equals("all")) {
                System.out.println("DEBUG: 강의 유형으로 필터링: " + filterParam);
                if (filterParam.equals("major")) {
                    courses = courses.stream()
                            .filter(c -> "major".equals(c.getType()))
                            .collect(Collectors.toList());
                } else if (filterParam.equals("general")) {
                    courses = courses.stream()
                            .filter(c -> "general".equals(c.getType()))
                            .collect(Collectors.toList());
                } else if (filterParam.equals("other")) {
                    courses = courses.stream()
                            .filter(c -> !"major".equals(c.getType()) && !"general".equals(c.getType()))
                            .collect(Collectors.toList());
                } else if (filterParam.equals("popular")) {
                    courses = courses.stream()
                            .filter(c -> c.isPopular())
                            .collect(Collectors.toList());
                }
                System.out.println("DEBUG: 강의 유형 필터링 결과 개수: " + courses.size());
            }

            // 정렬
            if (sortByParam != null && !sortByParam.isEmpty()) {
                System.out.println("DEBUG: 정렬 방식: " + sortByParam);
                switch (sortByParam) {
                    case "rating-high":
                        courses.sort((c1, c2) -> Double.compare(c2.getRating(), c1.getRating()));
                        break;
                    case "rating-low":
                        courses.sort((c1, c2) -> Double.compare(c1.getRating(), c2.getRating()));
                        break;
                    case "reviews":
                        courses.sort((c1, c2) -> Integer.compare(c2.getEvaluationCount(), c1.getEvaluationCount()));
                        break;
                    case "recent":
                    default:
                        // 최신순은 기본 정렬 (ID 기준 내림차순)
                        courses.sort((c1, c2) -> Integer.compare(c2.getId(), c1.getId()));
                        break;
                }
            }

            // JSP에 데이터 전달
            request.setAttribute("courses", courses);

            // evaluations.jsp로 포워딩 - 경로 수정
            String jspPath = "/evaluations.jsp";
            System.out.println("DEBUG: JSP 포워딩 경로: " + jspPath);
            request.getRequestDispatcher(jspPath).forward(request, response);
            return;
        }

        // 이하는 API 응답 처리 코드 (명시적으로 JSON을 요청하거나 특정 API 경로인 경우)
        if (isApiRequest || (pathInfo != null && pathInfo.startsWith("/api/"))) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();

            try {
                // 특정 강의 평가 상세 조회
                if (pathInfo != null && pathInfo.startsWith("/api/") && pathInfo.length() > 5) {
                    int evaluationId = Integer.parseInt(pathInfo.substring(5));
                    Evaluation evaluation = evaluationService.getEvaluationById(evaluationId);

                    if (evaluation != null) {
                        JSONObject jsonEvaluation = convertEvaluationToJson(evaluation);
                        out.print(jsonEvaluation.toString());
                    } else {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        out.print("{\"error\": \"강의 평가를 찾을 수 없습니다.\"}");
                    }
                }
                // 특정 강의의 평가 목록 조회
                else if (courseIdParam != null && !courseIdParam.isEmpty()) {
                    int courseId = Integer.parseInt(courseIdParam);
                    List<Evaluation> evaluations = evaluationService.getEvaluationsByCourse(courseId);

                    JSONArray jsonEvaluations = new JSONArray();
                    for (Evaluation evaluation : evaluations) {
                        jsonEvaluations.put(convertEvaluationToJson(evaluation));
                    }

                    out.print(jsonEvaluations.toString());
                }
                // 필터링된 강의 평가 목록 조회
                else {
                    List<Evaluation> evaluations = evaluationService.getAllEvaluations();

                    // 학과 필터링
                    if (departmentParam != null && !departmentParam.isEmpty() && !departmentParam.equals("all")) {
                        evaluations = evaluations.stream()
                                .filter(e -> courseService.getCourseById(e.getCourseId())
                                        .getDepartmentId().equals(departmentParam))
                                .collect(Collectors.toList());
                    }

                    // 강의 유형 필터링
                    if (typeParam != null && !typeParam.isEmpty() && !typeParam.equals("all")) {
                        evaluations = evaluations.stream()
                                .filter(e -> e.getCourseType().equals(typeParam))
                                .collect(Collectors.toList());
                    }

                    // 검색어 필터링
                    if (searchParam != null && !searchParam.isEmpty()) {
                        String search = searchParam.toLowerCase();
                        evaluations = evaluations.stream()
                                .filter(e -> {
                                    String courseName = courseService.getCourseById(e.getCourseId()).getName().toLowerCase();
                                    String professor = courseService.getCourseById(e.getCourseId()).getProfessor().toLowerCase();
                                    return courseName.contains(search) || professor.contains(search);
                                })
                                .collect(Collectors.toList());
                    }

                    // 정렬
                    if (sortByParam != null && !sortByParam.isEmpty()) {
                        switch (sortByParam) {
                            case "rating-high":
                                evaluations.sort((e1, e2) -> Integer.compare(e2.getRating(), e1.getRating()));
                                break;
                            case "rating-low":
                                evaluations.sort((e1, e2) -> Integer.compare(e1.getRating(), e2.getRating()));
                                break;
                            case "recent":
                                evaluations.sort((e1, e2) -> e2.getDate().compareTo(e1.getDate()));
                                break;
                            default:
                                break;
                        }
                    }

                    JSONArray jsonEvaluations = new JSONArray();
                    for (Evaluation evaluation : evaluations) {
                        jsonEvaluations.put(convertEvaluationToJson(evaluation));
                    }

                    out.print(jsonEvaluations.toString());
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"잘못된 요청 형식입니다.\"}");
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"" + e.getMessage() + "\"}");
            }
            return;
        }

        // 기본 HTML 응답 (위의 조건에 해당하지 않는 경우)
        if (isHtmlRequest) {
            // 강의 목록 가져오기
            List<Course> courses = courseService.getAllCourses();

            // JSP에 데이터 전달
            request.setAttribute("courses", courses);

            // evaluations.jsp로 포워딩
            String jspPath = "/evaluations.jsp";
            request.getRequestDispatcher(jspPath).forward(request, response);
            return;
        }

        // 그 외의 경우 JSON 응답
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"message\": \"강의평가 API에 오신 것을 환영합니다.\"}");
    }

    /**
     * POST 요청 처리
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        System.out.println("DEBUG: POST 요청 경로: " + pathInfo);

        // 요청 인코딩 설정
        request.setCharacterEncoding("UTF-8");

        // 강의평가 삭제 처리
        if (pathInfo != null && pathInfo.startsWith("/delete/")) {
            // JSON 응답 설정
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            JSONObject jsonResponse = new JSONObject();

            try {
                // 로그인 확인
                HttpSession session = request.getSession(false);
                if (session == null || session.getAttribute("user") == null) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "로그인이 필요합니다.");
                    out.print(jsonResponse.toString());
                    return;
                }

                User user = (User) session.getAttribute("user");
                System.out.println("DEBUG: 사용자 ID: " + user.getId() + ", 이름: " + user.getName());

                // 평가 ID 추출
                int evaluationId = Integer.parseInt(pathInfo.substring("/delete/".length()));
                System.out.println("DEBUG: 삭제할 평가 ID: " + evaluationId);

                // 평가 조회
                Evaluation evaluation = evaluationService.getEvaluationById(evaluationId);

                if (evaluation == null) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "평가를 찾을 수 없습니다.");
                    out.print(jsonResponse.toString());
                    return;
                }

                // 작성자 확인
                if (evaluation.getUserId() != user.getId()) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "자신이 작성한 평가만 삭제할 수 있습니다.");
                    out.print(jsonResponse.toString());
                    return;
                }

                // 평가 삭제
                int courseId = evaluation.getCourseId(); // 태그 업데이트를 위해 강의 ID 저장
                boolean success = evaluationService.deleteEvaluation(evaluationId, user.getId());

                if (success) {
                    // 태그 업데이트
                    courseService.updateCourseTags(courseId);

                    jsonResponse.put("success", true);
                    jsonResponse.put("message", "평가가 성공적으로 삭제되었습니다.");
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "평가 삭제에 실패했습니다.");
                }

                out.print(jsonResponse.toString());
                System.out.println("DEBUG: 응답 JSON: " + jsonResponse.toString());

            } catch (NumberFormatException e) {
                System.out.println("ERROR: 숫자 변환 중 오류: " + e.getMessage());
                jsonResponse.put("success", false);
                jsonResponse.put("message", "잘못된 평가 ID 형식입니다.");
                out.print(jsonResponse.toString());
            } catch (Exception e) {
                System.out.println("ERROR: " + e.getMessage());
                e.printStackTrace();

                jsonResponse.put("success", false);
                jsonResponse.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
                out.print(jsonResponse.toString());
            }
            return;
        }

        // 강의평가 신고 처리
        else if (pathInfo != null && pathInfo.startsWith("/report/")) {
            // JSON 응답 설정
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            JSONObject jsonResponse = new JSONObject();

            try {
                // 로그인 확인
                HttpSession session = request.getSession(false);
                if (session == null || session.getAttribute("user") == null) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "로그인이 필요합니다.");
                    out.print(jsonResponse.toString());
                    return;
                }

                User user = (User) session.getAttribute("user");
                System.out.println("DEBUG: 사용자 ID: " + user.getId() + ", 이름: " + user.getName());

                // 평가 ID 추출
                int evaluationId = Integer.parseInt(pathInfo.substring("/report/".length()));
                System.out.println("DEBUG: 신고할 평가 ID: " + evaluationId);

                // 신고 이유 가져오기
                String reason = request.getParameter("reason");
                if (reason == null || reason.isEmpty()) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "신고 이유를 입력해주세요.");
                    out.print(jsonResponse.toString());
                    return;
                }

                // 평가 조회
                Evaluation evaluation = evaluationService.getEvaluationById(evaluationId);

                if (evaluation == null) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "평가를 찾을 수 없습니다.");
                    out.print(jsonResponse.toString());
                    return;
                }

                // 자신의 평가는 신고할 수 없음
                if (evaluation.getUserId() == user.getId()) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "자신의 평가는 신고할 수 없습니다.");
                    out.print(jsonResponse.toString());
                    return;
                }

                // 평가 신고
                boolean reported = evaluationService.reportEvaluation(evaluationId, user.getId(), reason);

                if (reported) {
                    jsonResponse.put("success", true);
                    jsonResponse.put("message", "평가가 신고되었습니다.");
                } else {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "이미 신고한 평가이거나 신고 처리 중 오류가 발생했습니다.");
                }

                out.print(jsonResponse.toString());
                System.out.println("DEBUG: 응답 JSON: " + jsonResponse.toString());

            } catch (NumberFormatException e) {
                System.out.println("ERROR: 숫자 변환 중 오류: " + e.getMessage());
                jsonResponse.put("success", false);
                jsonResponse.put("message", "잘못된 평가 ID 형식입니다.");
                out.print(jsonResponse.toString());
            } catch (Exception e) {
                System.out.println("ERROR: " + e.getMessage());
                e.printStackTrace();

                jsonResponse.put("success", false);
                jsonResponse.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
                out.print(jsonResponse.toString());
            }
            return;
        }

        // 강의평가 제출 처리
        else if (pathInfo != null && pathInfo.equals("/submit")) {
            // JSON 응답 설정
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            JSONObject jsonResponse = new JSONObject();

            try {
                // 로그인 확인
                HttpSession session = request.getSession(false);
                if (session == null || session.getAttribute("user") == null) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "로그인이 필요합니다.");
                    out.print(jsonResponse.toString());
                    return;
                }

                User user = (User) session.getAttribute("user");
                System.out.println("DEBUG: 사용자 ID: " + user.getId() + ", 이름: " + user.getName());

                // 모든 요청 파라미터 로깅
                System.out.println("DEBUG: 모든 요청 파라미터 목록:");
                Enumeration<String> paramNames = request.getParameterNames();
                while (paramNames.hasMoreElements()) {
                    String paramName = paramNames.nextElement();
                    String[] paramValues = request.getParameterValues(paramName);
                    for (String value : paramValues) {
                        System.out.println("DEBUG: " + paramName + " = " + value);
                    }
                }

                // 폼 데이터 가져오기
                String courseIdStr = request.getParameter("courseId");
                String ratingStr = request.getParameter("rating");
                String difficultyStr = request.getParameter("difficulty");
                String homeworkStr = request.getParameter("homework");
                String courseType = request.getParameter("courseType");
                if (courseType == null) {
                    // JSP 폼에서는 courseType으로 전송되지만, 서블릿에서는 course_type으로 처리하는 경우를 대비
                    courseType = request.getParameter("course_type");
                }
                String comment = request.getParameter("comment");
                String teamProjectStr = request.getParameter("teamProject");

                System.out.println("DEBUG: 강의 ID: " + courseIdStr);
                System.out.println("DEBUG: 평점: " + ratingStr);
                System.out.println("DEBUG: 난이도: " + difficultyStr);
                System.out.println("DEBUG: 과제량: " + homeworkStr);
                System.out.println("DEBUG: 강의 유형: " + courseType);
                System.out.println("DEBUG: 팀 프로젝트 여부: " + teamProjectStr);

                // 요청 본문 확인 (AJAX 요청의 경우)
                StringBuilder requestBody = new StringBuilder();
                try (BufferedReader reader = request.getReader()) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        requestBody.append(line);
                    }
                }

                if (requestBody.length() > 0) {
                    System.out.println("DEBUG: 요청 본문: " + requestBody.toString());
                }

                // 필수 파라미터 검증 부분에 더 자세한 로깅 추가
                if (courseIdStr == null || ratingStr == null || difficultyStr == null ||
                        homeworkStr == null || courseType == null || comment == null) {
                    System.out.println("ERROR: 필수 파라미터 누락");
                    System.out.println("courseIdStr: " + (courseIdStr == null ? "누락" : "있음"));
                    System.out.println("ratingStr: " + (ratingStr == null ? "누락" : "있음"));
                    System.out.println("difficultyStr: " + (difficultyStr == null ? "누락" : "있음"));
                    System.out.println("homeworkStr: " + (homeworkStr == null ? "누락" : "있음"));
                    System.out.println("courseType: " + (courseType == null ? "누락" : "있음"));
                    System.out.println("comment: " + (comment == null ? "누락" : "있음"));

                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "필수 항목을 모두 입력해주세요.");
                    out.print(jsonResponse.toString());
                    return;
                }

                try {
                    int courseId = Integer.parseInt(courseIdStr);
                    int rating = Integer.parseInt(ratingStr);
                    int difficulty = Integer.parseInt(difficultyStr);
                    int homework = Integer.parseInt(homeworkStr);
                    boolean teamProject = teamProjectStr != null && Boolean.parseBoolean(teamProjectStr);

                    System.out.println("DEBUG: 강의 ID: " + courseId);
                    System.out.println("DEBUG: 평점: " + rating);
                    System.out.println("DEBUG: 난이도: " + difficulty);
                    System.out.println("DEBUG: 과제량: " + homework);
                    System.out.println("DEBUG: 강의 유형: " + courseType);
                    System.out.println("DEBUG: 팀 프로젝트 여부: " + teamProject);

                    // 특성(features) 배열 가져오기
                    String[] featuresArray = request.getParameterValues("features");
                    List<String> features = (featuresArray != null) ? Arrays.asList(featuresArray) : new ArrayList<>();

                    System.out.println("DEBUG: 특성 개수: " + features.size());
                    for (String feature : features) {
                        System.out.println("DEBUG: 특성: " + feature);
                    }

                    // 평가 객체 생성
                    Evaluation evaluation = new Evaluation();
                    evaluation.setCourseId(courseId);
                    evaluation.setUserId(user.getId());
                    evaluation.setRating(rating);
                    evaluation.setDifficulty(difficulty);
                    evaluation.setHomework(homework);
                    evaluation.setCourseType(courseType);
                    evaluation.setComment(comment);
                    evaluation.setFeatures(features);

                    // 평가 저장 전 중복 체크
                    List<Evaluation> existingEvaluations = evaluationService.getEvaluationsByCourse(courseId);
                    boolean isDuplicate = false;

                    for (Evaluation existingEval : existingEvaluations) {
                        if (existingEval.getUserId() == user.getId()) {
                            isDuplicate = true;
                            break;
                        }
                    }

                    if (isDuplicate) {
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "이미 이 강의에 대한 평가를 작성하셨습니다.");
                        out.print(jsonResponse.toString());
                        return;
                    }

                    // 평가 저장
                    boolean success = evaluationService.addEvaluation(evaluation);
                    System.out.println("DEBUG: 평가 저장 결과: " + (success ? "성공" : "실패"));

                    if (success) {
                        // 태그 업데이트 - 새로운 평가가 추가되었으므로 태그를 업데이트합니다.
                        System.out.println("DEBUG: 강의 태그 업데이트 시작");
                        courseService.updateCourseTags(courseId);
                        System.out.println("DEBUG: 강의 태그 업데이트 완료");

                        // AJAX 요청인 경우 JSON 응답
                        if (isAjaxRequest(request)) {
                            jsonResponse.put("success", true);
                            jsonResponse.put("message", "강의 평가가 성공적으로 등록되었습니다.");
                            out.print(jsonResponse.toString());
                        } else {
                            // 일반 폼 제출인 경우 리다이렉트
                            response.sendRedirect(request.getContextPath() + "/evaluations/course/" + courseId);
                        }
                    } else {
                        if (isAjaxRequest(request)) {
                            jsonResponse.put("success", false);
                            jsonResponse.put("message", "강의 평가 등록에 실패했습니다. 다시 시도해주세요.");
                            out.print(jsonResponse.toString());
                        } else {
                            // 일반 폼 제출인 경우 오류 메시지와 함께 리다이렉트
                            response.sendRedirect(request.getContextPath() + "/evaluations/write/" + courseId + "?error=true");
                        }
                    }
                } catch (NumberFormatException e) {
                    System.out.println("ERROR: 숫자 변환 중 오류: " + e.getMessage());
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "잘못된 입력 형식입니다: " + e.getMessage());
                    out.print(jsonResponse.toString());
                }
            } catch (Exception e) {
                System.out.println("ERROR: " + e.getMessage());
                e.printStackTrace();

                try {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
                    out.print(jsonResponse.toString());
                    System.out.println("DEBUG: 오류 응답 JSON: " + jsonResponse.toString());
                } catch (Exception je) {
                    // JSON 생성 중 오류가 발생한 경우 간단한 문자열 응답
                    out.print("{\"success\": false, \"message\": \"서버 오류가 발생했습니다.\"}");
                    System.out.println("DEBUG: 기본 오류 응답 전송");
                }
            }
            return;
        } else if (pathInfo != null && pathInfo.startsWith("/course/")) {
            // 기존 코드 유지
            try {
                int courseId = Integer.parseInt(pathInfo.substring("/course/".length()));

                // 폼 데이터 가져오기
                String content = request.getParameter("content");
                int rating = Integer.parseInt(request.getParameter("rating"));

                // 세션에서 사용자 정보 가져오기
                HttpSession session = request.getSession(false);
                if (session == null || session.getAttribute("user") == null) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=evaluations/course/" + courseId);
                    return;
                }

                User user = (User) session.getAttribute("user");

                // 평가 객체 생성 및 저장
                Evaluation evaluation = new Evaluation();
                evaluation.setCourseId(courseId);
                evaluation.setComment(content);
                evaluation.setRating(rating);
                evaluation.setUserId(user.getId());

                boolean success = evaluationService.addEvaluation(evaluation);

                if (success) {
                    // 태그 업데이트
                    courseService.updateCourseTags(courseId);
                }

                // 강의평가 목록 페이지로 리다이렉트
                response.sendRedirect(request.getContextPath() + "/evaluations/course/" + courseId);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * Evaluation 객체를 JSON 객체로 변환
     */
    private JSONObject convertEvaluationToJson(Evaluation evaluation) {
        JSONObject jsonEvaluation = new JSONObject();
        jsonEvaluation.put("id", evaluation.getId());
        jsonEvaluation.put("courseId", evaluation.getCourseId());
        jsonEvaluation.put("userId", evaluation.getUserId());
        jsonEvaluation.put("rating", evaluation.getRating());
        jsonEvaluation.put("difficulty", evaluation.getDifficulty());
        jsonEvaluation.put("homework", evaluation.getHomework());
        jsonEvaluation.put("courseType", evaluation.getCourseType());
        jsonEvaluation.put("comment", evaluation.getComment());
        jsonEvaluation.put("date", evaluation.getDate().toString());

        // 강의 정보 추가
        try {
            jsonEvaluation.put("course", courseService.getCourseById(evaluation.getCourseId()).getName());
            jsonEvaluation.put("professor", courseService.getCourseById(evaluation.getCourseId()).getProfessor());
        } catch (Exception e) {
            // 강의 정보를 가져오지 못한 경우 무시
        }

        // 강의 평가 특성 추가
        if (evaluation.getFeatures() != null && !evaluation.getFeatures().isEmpty()) {
            JSONArray featuresArray = new JSONArray();
            for (String feature : evaluation.getFeatures()) {
                featuresArray.put(feature);
            }
            jsonEvaluation.put("features", featuresArray);
        }

        return jsonEvaluation;
    }

    /**
     * AJAX 요청인지 확인
     */
    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        return "XMLHttpRequest".equals(requestedWith);
    }
}
