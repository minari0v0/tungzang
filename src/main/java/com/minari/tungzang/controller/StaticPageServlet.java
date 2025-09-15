package com.minari.tungzang.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "StaticPageServlet", urlPatterns = {"/about", "/terms", "/privacy"})
public class StaticPageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/about":
                request.getRequestDispatcher("/about.jsp").forward(request, response);
                break;
            case "/terms":
                request.getRequestDispatcher("/terms.jsp").forward(request, response);
                break;
            case "/privacy":
                request.getRequestDispatcher("/privacy.jsp").forward(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                break;
        }
    }
}