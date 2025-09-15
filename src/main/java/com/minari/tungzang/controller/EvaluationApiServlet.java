package com.minari.tungzang.controller;

import com.minari.tungzang.model.Course;
import com.minari.tungzang.model.Evaluation;
import com.minari.tungzang.service.CourseService;
import com.minari.tungzang.service.EvaluationService;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/api/evaluations")
public class EvaluationApiServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(EvaluationApiServlet.class.getName());
    private EvaluationService evaluationService;
    private CourseService courseService;

    @Override
    public void init() throws ServletException {
        super.init();
        evaluationService = new EvaluationService();
        courseService = new CourseService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String courseName = request.getParameter("course");
        String professor = request.getParameter("professor");
        PrintWriter out = response.getWriter();

        if (courseName == null || professor == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            JSONObject error = new JSONObject();
            error.put("error", "강의명과 교수명이 필요합니다.");
            out.print(error.toString());
            return;
        }

        try {
            // 1. 강의명과 교수명으로 강의 검색
            List<Course> courses = evaluationService.searchCourses(courseName);
            Course targetCourse = null;

            // 정확히 일치하는 강의 찾기
            for (Course course : courses) {
                if (course.getName().equals(courseName) && course.getProfessor().equals(professor)) {
                    targetCourse = course;
                    break;
                }
            }

            if (targetCourse == null) {
                // 강의를 찾을 수 없는 경우 - 메시지 변경
                JSONObject result = new JSONObject();
                result.put("exists", false);
                result.put("message", "아직 해당 강의에 대한 평가가 없습니다. 첫 번째 평가를 작성해보세요!");
                result.put("evaluations", new JSONArray());
                out.print(result.toString());
                return;
            }

            // 2. 찾은 강의의 ID로 평가 목록 조회
            List<Evaluation> evaluations = evaluationService.getEvaluationsByCourse(targetCourse.getId());

            JSONArray jsonEvaluations = new JSONArray();
            for (Evaluation eval : evaluations) {
                JSONObject jsonEval = new JSONObject();
                jsonEval.put("id", eval.getId());
                jsonEval.put("userId", eval.getUserId());
                jsonEval.put("userName", eval.getUserName());
                jsonEval.put("courseId", eval.getCourseId());
                jsonEval.put("courseName", eval.getCourseName());
                jsonEval.put("professor", eval.getProfessor());
                jsonEval.put("rating", eval.getRating());
                jsonEval.put("difficulty", eval.getDifficulty());
                jsonEval.put("homework", eval.getHomework());
                jsonEval.put("courseType", eval.getCourseType());

                // features 리스트를 JSON 배열로 변환
                JSONArray featuresArray = new JSONArray();
                for (String feature : eval.getFeatures()) {
                    featuresArray.put(feature);
                }
                jsonEval.put("features", featuresArray);

                jsonEval.put("comment", eval.getComment());
                jsonEval.put("date", eval.getDate().toString());

                if (eval.getUpdatedAt() != null) {
                    jsonEval.put("updatedAt", eval.getUpdatedAt().toString());
                }

                jsonEvaluations.put(jsonEval);
            }

            JSONObject result = new JSONObject();
            result.put("exists", true);
            result.put("course", targetCourse.getName());
            result.put("professor", targetCourse.getProfessor());
            result.put("evaluationCount", evaluations.size());
            result.put("evaluations", jsonEvaluations);

            out.print(result.toString());

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "강의 평가 조회 중 오류 발생", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject error = new JSONObject();
            error.put("error", "서버 오류가 발생했습니다.");
            out.print(error.toString());
        }
    }
}
