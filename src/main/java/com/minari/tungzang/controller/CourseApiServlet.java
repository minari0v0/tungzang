package com.minari.tungzang.controller;

import com.minari.tungzang.model.Course;
import com.minari.tungzang.service.CourseService;
import com.minari.tungzang.util.JsonUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/courses/*")
public class CourseApiServlet extends HttpServlet {

    private CourseService courseService;

    @Override
    public void init() throws ServletException {
        super.init();
        courseService = new CourseService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String pathInfo = request.getPathInfo();
        PrintWriter out = response.getWriter();

        // 강의 존재 여부 확인 API
        if (request.getRequestURI().contains("/api/courses/check")) {
            String name = request.getParameter("name");
            String professor = request.getParameter("professor");

            if (name == null || professor == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"강의명과 교수명이 필요합니다.\"}");
                return;
            }

            // 강의 검색
            List<Course> courses = courseService.searchCourses(name);
            boolean exists = false;

            for (Course course : courses) {
                if (course.getName().equals(name) && course.getProfessor().equals(professor)) {
                    exists = true;
                    break;
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("exists", exists);

            out.print(JsonUtil.toJson(result));
            return;
        }

        // 기타 API 엔드포인트 처리...

        out.print("{\"error\": \"잘못된 요청입니다.\"}");
    }
}
