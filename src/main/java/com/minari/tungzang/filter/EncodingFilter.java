package com.minari.tungzang.filter;

import java.io.IOException;
import java.util.logging.Logger;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Filter to set UTF-8 encoding for all requests and responses
 */
@WebFilter("/*")
public class EncodingFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(EncodingFilter.class.getName());
    private String encoding;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        encoding = filterConfig.getInitParameter("encoding");
        if (encoding == null) {
            encoding = "UTF-8";
        }
        LOGGER.info("EncodingFilter initialized with encoding: " + encoding);
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();

        // Set request encoding
        if (httpRequest.getCharacterEncoding() == null) {
            httpRequest.setCharacterEncoding(encoding);
        }

        // Set response encoding
        httpResponse.setCharacterEncoding(encoding);

        // 정적 리소스에 대한 올바른 Content-Type 설정
        if (requestURI.endsWith(".css")) {
            httpResponse.setContentType("text/css; charset=" + encoding);
        } else if (requestURI.endsWith(".js")) {
            httpResponse.setContentType("application/javascript; charset=" + encoding);
        } else if (requestURI.endsWith(".jpg") || requestURI.endsWith(".jpeg")) {
            httpResponse.setContentType("image/jpeg");
        } else if (requestURI.endsWith(".png")) {
            httpResponse.setContentType("image/png");
        } else if (requestURI.endsWith(".ico")) {
            httpResponse.setContentType("image/x-icon");
        } else if (requestURI.contains("/resources/")) {
            // resources 폴더의 파일들은 Content-Type을 설정하지 않고 서버가 자동으로 처리하도록 함
            // Content-Type을 설정하지 않음
        } else if (!requestURI.contains("/resources/") && !requestURI.endsWith(".css") && !requestURI.endsWith(".js") && !requestURI.endsWith(".png") && !requestURI.endsWith(".jpg") && !requestURI.endsWith(".ico")) {
            // HTML 페이지나 JSP에만 text/html Content-Type 설정
            httpResponse.setContentType("text/html; charset=" + encoding);
        }

        // Pass request to next filter or servlet
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Clean up resources if needed
        LOGGER.info("EncodingFilter destroyed");
    }
}
