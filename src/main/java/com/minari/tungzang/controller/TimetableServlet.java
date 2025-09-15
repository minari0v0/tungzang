package com.minari.tungzang.controller;

import com.minari.tungzang.model.TimetableCourse;
import com.minari.tungzang.model.User;
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
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(urlPatterns = {"/timetable", "/timetable/*"})
public class TimetableServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(TimetableServlet.class.getName());
    private TimetableService timetableService;

    @Override
    public void init() throws ServletException {
        super.init();
        timetableService = new TimetableService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        String acceptHeader = request.getHeader("Accept");
        boolean isApiRequest = acceptHeader != null && acceptHeader.contains("application/json");

        LOGGER.info("시간표 요청: " + request.getRequestURI() + ", Accept: " + acceptHeader + ", API요청: " + isApiRequest);

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            LOGGER.info("로그인되지 않은 사용자의 시간표 접근 시도");

            if (isApiRequest) {
                // AJAX 요청인 경우 JSON 응답
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                PrintWriter out = response.getWriter();
                out.print("{\"error\": \"로그인이 필요합니다.\", \"loginRequired\": true}");
                return;
            } else {
                // 일반 페이지 요청인 경우 - 시간표 페이지를 보여주되 로그인 필요 플래그 설정
                LOGGER.info("로그인 필요 플래그와 함께 시간표 페이지 표시");

                request.setAttribute("loginRequired", true);

                // 색상 목록 설정 (빈 시간표를 위해)
                List<String> colors = Arrays.asList(
                        "#4f46e5", "#ef4444", "#f97316", "#eab308", "#22c55e",
                        "#06b6d4", "#8b5cf6", "#ec4899", "#6b7280", "#0ea5e9"
                );
                request.setAttribute("colors", colors);
                request.setAttribute("courses", new ArrayList<TimetableCourse>());

                response.setContentType("text/html");
                request.getRequestDispatcher("/timetable.jsp").forward(request, response);
                return;
            }
        }

        // 로그인된 사용자 처리
        User user = (User) session.getAttribute("user");
        String userIdParam = request.getParameter("userId");

        LOGGER.info("로그인된 사용자의 시간표 요청: " + user.getId());

        try {
            // 시간표 페이지 요청 처리 (HTML)
            if (request.getServletPath().equals("/timetable") && (pathInfo == null || pathInfo.equals("/")) && !isApiRequest) {
                LOGGER.info("HTML 시간표 페이지 요청 처리");

                // 색상 목록 설정
                List<String> colors = Arrays.asList(
                        "#4f46e5", "#ef4444", "#f97316", "#eab308", "#22c55e",
                        "#06b6d4", "#8b5cf6", "#ec4899", "#6b7280", "#0ea5e9"
                );
                request.setAttribute("colors", colors);

                // 사용자의 시간표 강의 목록 조회
                List<TimetableCourse> courses = timetableService.getTimetableCoursesByUserId(user.getId());
                request.setAttribute("courses", courses);
                request.setAttribute("loginRequired", false);

                LOGGER.info("시간표 강의 수: " + courses.size());

                // 응답 타입을 HTML로 설정
                response.setContentType("text/html");
                request.getRequestDispatcher("/timetable.jsp").forward(request, response);
                return;
            }

            // API 요청 처리 (JSON)
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();

            // 특정 ID의 시간표 강의 상세 조회
            if (pathInfo != null && !pathInfo.equals("/")) {
                int courseId = Integer.parseInt(pathInfo.substring(1));
                TimetableCourse course = timetableService.getTimetableCourseById(courseId);

                if (course != null) {
                    // 본인의 시간표 강의만 조회 가능 (관리자는 모든 시간표 강의 조회 가능)
                    if (course.getUserId() == user.getId() || user.isAdmin()) {
                        JSONObject jsonCourse = convertTimetableCourseToJson(course);
                        out.print(jsonCourse.toString());
                    } else {
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        out.print("{\"error\": \"본인의 시간표 강의만 조회할 수 있습니다.\"}");
                    }
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"시간표 강의를 찾을 수 없습니다.\"}");
                }
            }
            // 특정 사용자의 시간표 강의 목록 조회
            else if (userIdParam != null && !userIdParam.isEmpty()) {
                int userId = Integer.parseInt(userIdParam);

                // 본인의 시간표 강의만 조회 가능 (관리자는 모든 시간표 강의 조회 가능)
                if (userId == user.getId() || user.isAdmin()) {
                    List<TimetableCourse> courses = timetableService.getTimetableCoursesByUserId(userId);
                    JSONArray jsonCourses = new JSONArray();
                    for (TimetableCourse course : courses) {
                        jsonCourses.put(convertTimetableCourseToJson(course));
                    }
                    out.print(jsonCourses.toString());
                } else {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"error\": \"본인의 시간표 강의만 조회할 수 있습니다.\"}");
                }
            }
            // 현재 로그인한 사용자의 시간표 강의 목록 조회 (API 요청)
            else {
                List<TimetableCourse> courses = timetableService.getTimetableCoursesByUserId(user.getId());
                JSONArray jsonCourses = new JSONArray();
                for (TimetableCourse course : courses) {
                    jsonCourses.put(convertTimetableCourseToJson(course));
                }
                out.print(jsonCourses.toString());
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "잘못된 요청 형식", e);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\": \"잘못된 요청 형식입니다.\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "시간표 조회 중 오류 발생", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\": \"로그인이 필요합니다.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");

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
            String day = jsonData.getString("day");
            int startTime = jsonData.getInt("startTime");
            int endTime = jsonData.getInt("endTime");
            String location = jsonData.getString("location");
            String color = jsonData.getString("color");

            // 시간표 강의 객체 생성
            TimetableCourse course = new TimetableCourse();
            course.setUserId(user.getId());
            course.setName(name);
            course.setProfessor(professor);
            course.setDay(day);
            course.setStartTime(startTime);
            course.setEndTime(endTime);
            course.setLocation(location);
            course.setColor(color);

            // 시간표 강의 저장
            int courseId = timetableService.addTimetableCourse(course);

            if (courseId > 0) {
                course.setId(courseId);
                JSONObject jsonCourse = convertTimetableCourseToJson(course);
                response.setStatus(HttpServletResponse.SC_CREATED);
                out.print(jsonCourse.toString());
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"시간표 강의 저장에 실패했습니다.\"}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\": \"로그인이 필요합니다.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (pathInfo == null || pathInfo.equals("/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"시간표 강의 ID가 필요합니다.\"}");
            return;
        }

        try {
            int courseId = Integer.parseInt(pathInfo.substring(1));
            TimetableCourse existingCourse = timetableService.getTimetableCourseById(courseId);

            if (existingCourse == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"시간표 강의를 찾을 수 없습니다.\"}");
                return;
            }

            if (existingCourse.getUserId() != user.getId()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"error\": \"본인의 시간표 강의만 수정할 수 있습니다.\"}");
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
            if (jsonData.has("day")) {
                existingCourse.setDay(jsonData.getString("day"));
            }
            if (jsonData.has("startTime")) {
                existingCourse.setStartTime(jsonData.getInt("startTime"));
            }
            if (jsonData.has("endTime")) {
                existingCourse.setEndTime(jsonData.getInt("endTime"));
            }
            if (jsonData.has("location")) {
                existingCourse.setLocation(jsonData.getString("location"));
            }
            if (jsonData.has("color")) {
                existingCourse.setColor(jsonData.getString("color"));
            }

            // 시간표 강의 업데이트
            boolean updated = timetableService.updateTimetableCourse(existingCourse);

            if (updated) {
                JSONObject jsonCourse = convertTimetableCourseToJson(existingCourse);
                out.print(jsonCourse.toString());
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"시간표 강의 업데이트에 실패했습니다.\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"잘못된 요청 형식입니다.\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\": \"로그인이 필요합니다.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (pathInfo == null || pathInfo.equals("/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"시간표 강의 ID가 필요합니다.\"}");
            return;
        }

        try {
            int courseId = Integer.parseInt(pathInfo.substring(1));
            TimetableCourse course = timetableService.getTimetableCourseById(courseId);

            if (course == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"시간표 강의를 찾을 수 없습니다.\"}");
                return;
            }

            if (course.getUserId() != user.getId()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"error\": \"본인의 시간표 강의만 삭제할 수 있습니다.\"}");
                return;
            }

            boolean deleted = timetableService.deleteTimetableCourse(courseId);

            if (deleted) {
                response.setStatus(HttpServletResponse.SC_NO_CONTENT);
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\": \"시간표 강의 삭제에 실패했습니다.\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"잘못된 요청 형식입니다.\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    private JSONObject convertTimetableCourseToJson(TimetableCourse course) {
        JSONObject jsonCourse = new JSONObject();
        jsonCourse.put("id", course.getId());
        jsonCourse.put("userId", course.getUserId());
        jsonCourse.put("name", course.getName());
        jsonCourse.put("professor", course.getProfessor());
        jsonCourse.put("day", course.getDay());
        jsonCourse.put("startTime", course.getStartTime());
        jsonCourse.put("endTime", course.getEndTime());
        jsonCourse.put("location", course.getLocation());
        jsonCourse.put("color", course.getColor());
        jsonCourse.put("createdAt", course.getCreatedAt() != null ? course.getCreatedAt().toString() : null);
        jsonCourse.put("updatedAt", course.getUpdatedAt() != null ? course.getUpdatedAt().toString() : null);

        return jsonCourse;
    }
}
