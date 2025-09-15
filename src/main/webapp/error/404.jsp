<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>페이지를 찾을 수 없습니다 - 텅장수강러</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <!-- 구글 폰트 Noto Sans KR 추가 -->
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="error-page-container">
    <div class="error-content">
        <div class="error-icon">
            <i class="bi bi-exclamation-circle"></i>
        </div>
        <h1 class="error-code">404</h1>
        <h2 class="error-title">페이지를 찾을 수 없습니다</h2>
        <p class="error-message">요청하신 페이지가 존재하지 않거나 이동되었을 수 있습니다.</p>
        <div class="error-actions">
            <a href="${pageContext.request.contextPath}/" class="error-btn primary">
                <i class="bi bi-house-door"></i> 홈으로 돌아가기
            </a>
            <a href="javascript:history.back()" class="error-btn secondary">
                <i class="bi bi-arrow-left"></i> 이전 페이지로
            </a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
</body>
</html>