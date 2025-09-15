package com.minari.tungzang.controller;

import com.minari.tungzang.model.Course;
import com.minari.tungzang.model.TimetableCourse;
import com.minari.tungzang.model.User;
import com.minari.tungzang.service.CourseService;
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
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/api/timetable/*")
public class TimetableApiServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(TimetableApiServlet.class.getName());
    private TimetableService timetableService;
    private CourseService courseService;

    @Override
    public void init() throws ServletException {
        super.init();
        timetableService = new TimetableService();
        courseService = new CourseService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\": \"로그인이 필요합니다.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // /api/timetable/courses 엔드포인트 처리
            if (pathInfo != null && pathInfo.equals("/courses")) {
                List<TimetableCourse> courses = timetableService.getTimetableCoursesByUserId(user.getId());
                JSONArray jsonCourses = new JSONArray();

                for (TimetableCourse course : courses) {
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

                    jsonCourses.put(jsonCourse);
                }

                out.print(jsonCourses.toString());
            }
            // /api/timetable/courses/{id} 엔드포인트 처리
            else if (pathInfo != null && pathInfo.startsWith("/courses/")) {
                int courseId = Integer.parseInt(pathInfo.substring("/courses/".length()));
                TimetableCourse course = timetableService.getTimetableCourseById(courseId);

                if (course != null && (course.getUserId() == user.getId() || user.isAdmin())) {
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

                    out.print(jsonCourse.toString());
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"시간표 강의를 찾을 수 없습니다.\"}");
                }
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"잘못된 API 경로입니다.\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "API 요청 처리 중 오류 발생", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\": \"로그인이 필요합니다.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // /api/timetable/courses 엔드포인트 처리
            if (pathInfo != null && pathInfo.equals("/courses")) {
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
                    // 시간표 강의 저장 성공
                    course.setId(courseId);
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
                    jsonCourse.put("success", true);

                    response.setStatus(HttpServletResponse.SC_CREATED);
                    out.print(jsonCourse.toString());
                } else {
                    // 시간표 강의 저장 실패
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"error\": \"시간표 강의 저장에 실패했습니다.\", \"success\": false}");
                }
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"잘못된 API 경로입니다.\", \"success\": false}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "API 요청 처리 중 오류 발생", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\", \"success\": false}");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\": \"로그인이 필요합니다.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // /api/timetable/courses/{id} 엔드포인트 처리
            if (pathInfo != null && pathInfo.startsWith("/courses/")) {
                int courseId = Integer.parseInt(pathInfo.substring("/courses/".length()));
                TimetableCourse existingCourse = timetableService.getTimetableCourseById(courseId);

                if (existingCourse == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"시간표 강의를 찾을 수 없습니다.\", \"success\": false}");
                    return;
                }

                if (existingCourse.getUserId() != user.getId() && !user.isAdmin()) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"error\": \"본인의 시간표 강의만 수정할 수 있습니다.\", \"success\": false}");
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
                    // 시간표 강의 업데이트 성공
                    JSONObject jsonCourse = new JSONObject();
                    jsonCourse.put("id", existingCourse.getId());
                    jsonCourse.put("userId", existingCourse.getUserId());
                    jsonCourse.put("name", existingCourse.getName());
                    jsonCourse.put("professor", existingCourse.getProfessor());
                    jsonCourse.put("day", existingCourse.getDay());
                    jsonCourse.put("startTime", existingCourse.getStartTime());
                    jsonCourse.put("endTime", existingCourse.getEndTime());
                    jsonCourse.put("location", existingCourse.getLocation());
                    jsonCourse.put("color", existingCourse.getColor());
                    jsonCourse.put("createdAt", existingCourse.getCreatedAt() != null ? existingCourse.getCreatedAt().toString() : null);
                    jsonCourse.put("updatedAt", existingCourse.getUpdatedAt() != null ? existingCourse.getUpdatedAt().toString() : null);
                    jsonCourse.put("success", true);

                    out.print(jsonCourse.toString());
                } else {
                    // 시간표 강의 업데이트 실패
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"error\": \"시간표 강의 업데이트에 실패했습니다.\", \"success\": false}");
                }
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"잘못된 API 경로입니다.\", \"success\": false}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "API 요청 처리 중 오류 발생", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\", \"success\": false}");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\": \"로그인이 필요합니다.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // /api/timetable/courses/{id} 엔드포인트 처리
            if (pathInfo != null && pathInfo.startsWith("/courses/")) {
                int courseId = Integer.parseInt(pathInfo.substring("/courses/".length()));
                TimetableCourse course = timetableService.getTimetableCourseById(courseId);

                if (course == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"시간표 강의를 찾을 수 없습니다.\", \"success\": false}");
                    return;
                }

                if (course.getUserId() != user.getId() && !user.isAdmin()) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"error\": \"본인의 시간표 강의만 삭제할 수 있습니다.\", \"success\": false}");
                    return;
                }

                // 시간표 강의 삭제
                boolean deleted = timetableService.deleteTimetableCourse(courseId);

                if (deleted) {
                    // 시간표 강의 삭제 성공
                    JSONObject result = new JSONObject();
                    result.put("success", true);
                    out.print(result.toString());
                } else {
                    // 시간표 강의 삭제 실패
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"error\": \"시간표 강의 삭제에 실패했습니다.\", \"success\": false}");
                }
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"잘못된 API 경로입니다.\", \"success\": false}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "API 요청 처리 중 오류 발생", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\", \"success\": false}");
        }
    }
}
