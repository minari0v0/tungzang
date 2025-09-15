<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
</head>
<body>
<div class="auth-container">
    <!-- 왼쪽 사이드바 -->
    <div class="auth-sidebar">
        <a href="${pageContext.request.contextPath}/" class="back-home">
            <i class="bi bi-arrow-left"></i> 홈으로
        </a>
        <div class="auth-sidebar-content">
            <a href="${pageContext.request.contextPath}/" class="auth-logo">
                <i class="bi bi-house"></i> 텅장수강러
            </a>
            <h1 class="auth-title">텅장수강러와 함께 현명한 대학생활을 시작하세요</h1>
            <p class="auth-description">강의 평가를 확인하고, 시간표를 관리하고, 다른 학생들과 소통하세요.</p>

            <div class="auth-benefits">
                <div class="auth-benefit-item">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>실시간 강의 평가 열람 및 작성</span>
                </div>
                <div class="auth-benefit-item">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>시간표 저장 및 공유</span>
                </div>
                <div class="auth-benefit-item">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>커뮤니티 게시글 작성 및 댓글</span>
                </div>
                <div class="auth-benefit-item">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>학기별 강의 추천 받기</span>
                </div>
            </div>
        </div>
    </div>

    <!-- 오른쪽 로그인 폼 -->
    <div class="auth-form-container">
        <div class="auth-form-wrapper">
            <h2 class="auth-form-title">로그인</h2>
            <p class="auth-form-subtitle">텅장수강러 계정에 로그인하여 다양한 기능을 이용하세요</p>

            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger" role="alert">
                <%= request.getAttribute("error") %>
            </div>
            <% } %>

            <% if (request.getAttribute("message") != null) { %>
            <div class="alert alert-success" role="alert">
                <%= request.getAttribute("message") %>
            </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/auth/login" method="post">
                <%
                    String redirect = request.getParameter("redirect");
                    if (redirect != null && !redirect.isEmpty()) {
                %>
                <input type="hidden" name="redirect" value="<%= redirect %>">
                <% } %>

                <div class="form-group">
                    <label for="username" class="form-label">아이디</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-person"></i></span>
                        <input type="text" class="form-control" id="username" name="username" placeholder="아이디를 입력하세요" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password" class="form-label">비밀번호</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-lock"></i></span>
                        <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호를 입력하세요" required>
                    </div>
                </div>

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="rememberMe" name="rememberMe">
                        <label class="form-check-label" for="rememberMe">로그인 상태 유지</label>
                    </div>
                    <div class="forgot-password">
                        <a href="${pageContext.request.contextPath}/forgot-password.jsp">비밀번호 찾기</a>
                    </div>
                </div>

                <button type="submit" class="auth-btn">로그인</button>
            </form>

            <div class="auth-footer">
                <p>계정이 없으신가요? <a href="${pageContext.request.contextPath}/register.jsp">회원가입</a></p>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script>
    // 다크 모드 상태 확인 및 적용
    document.addEventListener('DOMContentLoaded', function() {
        const darkMode = localStorage.getItem('darkMode');
        const prefersDarkScheme = window.matchMedia("(prefers-color-scheme: dark)");

        if (darkMode === 'enabled' || (darkMode === null && prefersDarkScheme.matches)) {
            document.body.classList.add('dark-mode');
        }
    });

    // contextPath 설정
    var contextPath = "${pageContext.request.contextPath}";
</script>
<script src="${pageContext.request.contextPath}/resources/js/admin-access.js"></script>
</body>
</html>
