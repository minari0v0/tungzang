package com.minari.tungzang.controller;

import com.minari.tungzang.model.Course;
import com.minari.tungzang.model.Evaluation;
import com.minari.tungzang.model.Post;
import com.minari.tungzang.service.CourseService;
import com.minari.tungzang.service.EvaluationService;
import com.minari.tungzang.service.PostService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("")
public class IndexServlet extends HttpServlet {

    private CourseService courseService;
    private EvaluationService evaluationService;
    private PostService postService;

    @Override
    public void init() throws ServletException {
        super.init();
        courseService = new CourseService();
        evaluationService = new EvaluationService();
        postService = new PostService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 인기 강의 목록 가져오기
        List<Course> popularCourses = courseService.getPopularCourses(4);

        // 최근 강의평가 목록 가져오기
        List<Evaluation> recentEvaluations = evaluationService.getRecentEvaluations(3);

        // 인기 게시글 목록 가져오기
        List<Post> hotPosts = postService.getHotPosts(4);

        request.setAttribute("popularCourses", popularCourses);
        request.setAttribute("recentEvaluations", recentEvaluations);
        request.setAttribute("hotPosts", hotPosts);

        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}