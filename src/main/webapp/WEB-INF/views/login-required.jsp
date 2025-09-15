<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 필요 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login-modal.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        .login-required-container {
            min-height: calc(100vh - 300px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .login-required-content {
            max-width: 500px;
            width: 100%;
            text-align: center;
            padding: 3rem;
            background-color: var(--white);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
        }

        .login-required-icon {
            font-size: 3rem;
            margin-bottom: 1.5rem;
            color: var(--primary-color);
            display: inline-block;
            background: linear-gradient(135deg, rgba(126, 34, 206, 0.1) 0%, rgba(168, 85, 247, 0.1) 100%);
            width: 100px;
            height: 100px;
            line-height: 100px;
            border-radius: 50%;
        }

        .login-required-title {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 1rem;
            color: var(--text-color);
        }

        .login-required-message {
            font-size: 1.1rem;
            color: var(--text-light);
            margin-bottom: 2rem;
        }

        .login-required-actions {
            display: flex;
            justify-content: center;
            gap: 1rem;
        }

        .dark-mode .login-required-content {
            background-color: var(--dark-bg);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .dark-mode .login-required-title {
            color: #e2e8f0;
        }

        .dark-mode .login-required-message {
            color: #94a3b8;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="login-required-container">
    <div class="login-required-content">
        <div class="login-required-icon">
            <i class="bi bi-shield-lock"></i>
        </div>
        <h1 class="login-required-title">로그인이 필요합니다</h1>
        <p class="login-required-message">이 서비스를 이용하려면 로그인이 필요합니다.</p>
        <div class="login-required-actions">
            <a href="${pageContext.request.contextPath}/" class="btn btn-outline-secondary">
                <i class="bi bi-house me-2"></i> 홈으로
            </a>
            <a href="${pageContext.request.contextPath}/login.jsp?redirect=${redirectUrl}" class="btn btn-primary">
                <i class="bi bi-box-arrow-in-right me-2"></i> 로그인
            </a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script>
    // 다크 모드 상태 확인 및 적용
    document.addEventListener('DOMContentLoaded', function() {
        const darkMode = localStorage.getItem('darkMode');
        const prefersDarkScheme = window.matchMedia("(prefers-color-scheme: dark)");

        if (darkMode === 'enabled' || (darkMode === null && prefersDarkScheme.matches)) {
            document.body.classList.add('dark-mode');
        }
    });
</script>
<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
</body>
</html>
