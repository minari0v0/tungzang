package com.minari.tungzang.controller;

import com.minari.tungzang.model.Course;
import com.minari.tungzang.model.User;
import com.minari.tungzang.service.CourseService;
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
import java.util.stream.Collectors;

@WebServlet("/courses/*")
public class CourseServlet extends HttpServlet {

    private CourseService courseService;

    @Override
    public void init() throws ServletException {
        super.init();
        courseService = new CourseService();
    }

    /**
     * GET 요청 처리
     * - /courses: 모든 강의 목록 조회
     * - /courses?department=X: 특정 학과의 강의 목록 조회
     * - /courses?type=X: 특정 유형의 강의 목록 조회
     * - /courses?search=X: 강의 검색
     * - /courses/popular: 인기 강의 목록 조회
     * - /courses/X: ID가 X인 강의 상세 조회
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        String departmentParam = request.getParameter("department");
        String typeParam = request.getParameter("type");
        String searchParam = request.getParameter("search");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // 인기 강의 목록 조회
            if (pathInfo != null && pathInfo.equals("/popular")) {
                int limit = 10;
                try {
                    String limitParam = request.getParameter("limit");
                    if (limitParam != null && !limitParam.isEmpty()) {
                        limit = Integer.parseInt(limitParam);
                    }
                } catch (NumberFormatException e) {
                    // 기본값 사용
                }

                List<Course> courses = courseService.getPopularCourses(limit);
                JSONArray jsonCourses = new JSONArray();
                for (Course course : courses) {
                    jsonCourses.put(convertCourseToJson(course));
                }

                out.print(jsonCourses.toString());
            }
            // 특정 ID의 강의 상세 조회
            else if (pathInfo != null && !pathInfo.equals("/")) {
                int courseId = Integer.parseInt(pathInfo.substring(1));
                Course course = courseService.getCourseById(courseId);

                if (course != null) {
                    JSONObject jsonCourse = convertCourseToJson(course);
                    out.print(jsonCourse.toString());
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"강의를 찾을 수 없습니다.\"}");
                }
            }
            // 강의 검색
            else if (searchParam != null && !searchParam.isEmpty()) {
                List<Course> courses = courseService.searchCourses(searchParam);
                JSONArray jsonCourses = new JSONArray();
                for (Course course : courses) {
                    jsonCourses.put(convertCourseToJson(course));
                }

                out.print(jsonCourses.toString());
            }
            // 특정 학과의 강의 목록 조회
            else if (departmentParam != null && !departmentParam.isEmpty()) {
                List<Course> courses = courseService.getCoursesByDepartment(departmentParam);
                JSONArray jsonCourses = new JSONArray();
                for (Course course : courses) {
                    jsonCourses.put(convertCourseToJson(course));
                }

                out.print(jsonCourses.toString());
            }
            // 특정 유형의 강의 목록 조회
            else if (typeParam != null && !typeParam.isEmpty()) {
                List<Course> courses = courseService.getCoursesByType(typeParam);
                JSONArray jsonCourses = new JSONArray();
                for (Course course : courses) {
                    jsonCourses.put(convertCourseToJson(course));
                }

                out.print(jsonCourses.toString());
            }
            // 모든 강의 목록 조회
            else {
                List<Course> courses = courseService.getAllCourses();
                JSONArray jsonCourses = new JSONArray();
                for (Course course : courses) {
                    jsonCourses.put(convertCourseToJson(course));
                }

                out.print(jsonCourses.toString());
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
     * - /courses: 새로운 강의 추가
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
        if (!user.isAdmin()) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().print("{\"error\": \"관리자 권한이 필요합니다.\"}");
            return;
        }

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
            String name = jsonData.getString("name");
            String professor = jsonData.getString("professor");
            String department = jsonData.getString("department");
            String departmentId = jsonData.getString("departmentId");
            String type = jsonData.getString("type");
            int examCount = jsonData.getInt("examCount");

            // 강의 객체 생성
            Course course = new Course();
            course.setName(name);
            course.setProfessor(professor);
            course.setDepartment(department);
            course.setDepartmentId(departmentId);
            course.setType(type);
            course.setExamCount(examCount);

            // 강의 태그 처리 (있는 경우)
            if (jsonData.has("tags") && !jsonData.isNull("tags")) {
                JSONArray tagsArray = jsonData.getJSONArray("tags");
                String[] tags = new String[tagsArray.length()];
                for (int i = 0; i < tagsArray.length(); i++) {
                    tags[i] = tagsArray.getString(i);
                }
                course.setTags(tags);
            }

            // 강의 저장
            int courseId = courseService.addCourse(course);

            if (courseId > 0) {
                // 강의 저장 성공
                course.setId(courseId);
                JSONObject jsonCourse = convertCourseToJson(course);
                response.setStatus(HttpServletResponse.SC_CREATED);
                out.print(jsonCourse.toString());
            } else {
                // 강의 저장 실패
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"강의 저장에 실패했습니다.\"}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * PUT 요청 처리
     * - /courses/X: ID가 X인 강의 수정
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
        if (!user.isAdmin()) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().print("{\"error\": \"관리자 권한이 필요합니다.\"}");
            return;
        }

        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (pathInfo == null || pathInfo.equals("/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"강의 ID가 필요합니다.\"}");
            return;
        }

        try {
            int courseId = Integer.parseInt(pathInfo.substring(1));
            Course existingCourse = courseService.getCourseById(courseId);

            if (existingCourse == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"강의를 찾을 수 없습니다.\"}");
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
            if (jsonData.has("name")) {
                existingCourse.setName(jsonData.getString("name"));
            }
            if (jsonData.has("professor")) {
                existingCourse.setProfessor(jsonData.getString("professor"));
            }
            if (jsonData.has("department")) {
                existingCourse.setDepartment(jsonData.getString("department"));
            }
            if (jsonData.has("departmentId")) {
                existingCourse.setDepartmentId(jsonData.getString("departmentId"));
            }
            if (jsonData.has("type")) {
                existingCourse.setType(jsonData.getString("type"));
            }
            if (jsonData.has("examCount")) {
                existingCourse.setExamCount(jsonData.getInt("examCount"));
            }

            // 강의 태그 처리 (있는 경우)
            if (jsonData.has("tags") && !jsonData.isNull("tags")) {
                JSONArray tagsArray = jsonData.getJSONArray("tags");
                String[] tags = new String[tagsArray.length()];
                for (int i = 0; i < tagsArray.length(); i++) {
                    tags[i] = tagsArray.getString(i);
                }
                existingCourse.setTags(tags);
            }

            // 강의 업데이트
            boolean updated = courseService.updateCourse(existingCourse);

            if (updated) {
                // 강의 업데이트 성공
                JSONObject jsonCourse = convertCourseToJson(existingCourse);
                out.print(jsonCourse.toString());
            } else {
                // 강의 업데이트 실패
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"강의 업데이트에 실패했습니다.\"}");
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
     * - /courses/X: ID가 X인 강의 삭제
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
        if (!user.isAdmin()) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().print("{\"error\": \"관리자 권한이 필요합니다.\"}");
            return;
        }

        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (pathInfo == null || pathInfo.equals("/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"강의 ID가 필요합니다.\"}");
            return;
        }

        try {
            int courseId = Integer.parseInt(pathInfo.substring(1));
            Course course = courseService.getCourseById(courseId);

            if (course == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"강의를 찾을 수 없습니다.\"}");
                return;
            }

            // 강의 삭제
            boolean deleted = courseService.deleteCourse(courseId);

            if (deleted) {
                // 강의 삭제 성공
                response.setStatus(HttpServletResponse.SC_NO_CONTENT);
            } else {
                // 강의 삭제 실패
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"강의 삭제에 실패했습니다.\"}");
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
     * Course 객체를 JSON 객체로 변환
     */
    private JSONObject convertCourseToJson(Course course) {
        JSONObject jsonCourse = new JSONObject();
        jsonCourse.put("id", course.getId());
        jsonCourse.put("name", course.getName());
        jsonCourse.put("professor", course.getProfessor());
        jsonCourse.put("department", course.getDepartment());
        jsonCourse.put("departmentId", course.getDepartmentId());
        jsonCourse.put("type", course.getType());
        jsonCourse.put("rating", course.getRating());
        jsonCourse.put("evaluationCount", course.getEvaluationCount());
        jsonCourse.put("difficulty", course.getDifficulty());
        jsonCourse.put("homework", course.getHomework());
        jsonCourse.put("teamProject", course.isTeamProject());
        jsonCourse.put("examCount", course.getExamCount());
        jsonCourse.put("isPopular", course.isPopular());

        // 강의 태그 추가
        if (course.getTags() != null && course.getTags().length > 0) {
            JSONArray tagsArray = new JSONArray();
            for (String tag : course.getTags()) {
                tagsArray.put(tag);
            }
            jsonCourse.put("tags", tagsArray);
        }

        return jsonCourse;
    }
}