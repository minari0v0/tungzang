<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 로그인 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        body, html {
            height: 100%;
            margin: 0;
            overflow: hidden;
        }

        .admin-login-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f8f9fa;
            position: relative;
        }

        .dark-mode .admin-login-container {
            background-color: #0f172a;
        }

        /* Background pattern */
        .admin-login-container::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-image:
                    radial-gradient(circle at 25% 25%, rgba(126, 34, 206, 0.05) 1%, transparent 5%),
                    radial-gradient(circle at 75% 75%, rgba(126, 34, 206, 0.05) 1%, transparent 5%);
            background-size: 60px 60px;
            opacity: 0.8;
            z-index: 0;
        }

        .dark-mode .admin-login-container::before {
            background-image:
                    radial-gradient(circle at 25% 25%, rgba(168, 85, 247, 0.05) 1%, transparent 5%),
                    radial-gradient(circle at 75% 75%, rgba(168, 85, 247, 0.05) 1%, transparent 5%);
        }

        .admin-login-card {
            width: 100%;
            max-width: 420px;
            background-color: #fff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            overflow: hidden;
            position: relative;
            z-index: 1;
            border: 1px solid rgba(0, 0, 0, 0.05);
        }

        .dark-mode .admin-login-card {
            background-color: #1e293b;
            color: #e2e8f0;
            border-color: rgba(255, 255, 255, 0.05);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        .admin-login-header {
            padding: 30px 0;
            text-align: center;
            position: relative;
        }

        .admin-login-header::after {
            content: "";
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 60px;
            height: 4px;
            background: linear-gradient(90deg, #a855f7, #7e22ce);
            border-radius: 2px;
        }

        .admin-login-icon {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, #a855f7, #7e22ce);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px;
            color: white;
            font-size: 28px;
            box-shadow: 0 5px 15px rgba(126, 34, 206, 0.3);
        }

        .admin-login-title {
            margin-bottom: 5px;
            font-weight: 700;
            font-size: 1.5rem;
            color: #1e293b;
        }

        .dark-mode .admin-login-title {
            color: #e2e8f0;
        }

        .admin-login-subtitle {
            color: #64748b;
            margin-bottom: 0;
            font-size: 0.9rem;
        }

        .dark-mode .admin-login-subtitle {
            color: #94a3b8;
        }

        .admin-login-body {
            padding: 30px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #334155;
            font-size: 0.9rem;
        }

        .dark-mode .form-label {
            color: #cbd5e1;
        }

        .input-group {
            position: relative;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            transition: all 0.2s ease;
        }

        .dark-mode .input-group {
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        .input-group:focus-within {
            box-shadow: 0 0 0 2px rgba(126, 34, 206, 0.3);
        }

        .input-group-text {
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            border-right: none;
            color: #64748b;
            padding-left: 15px;
        }

        .dark-mode .input-group-text {
            background-color: #0f172a;
            border-color: #334155;
            color: #94a3b8;
        }

        .form-control {
            border: 1px solid #e2e8f0;
            border-left: none;
            padding: 12px 15px;
            font-size: 0.95rem;
            background-color: #f8fafc;
            color: #334155;
            transition: all 0.2s ease;
        }

        .dark-mode .form-control {
            background-color: #0f172a;
            border-color: #334155;
            color: #e2e8f0;
        }

        .form-control:focus {
            outline: none;
            box-shadow: none;
            border-color: #e2e8f0;
            background-color: #fff;
        }

        .dark-mode .form-control:focus {
            border-color: #334155;
            background-color: #1e293b;
        }

        .admin-login-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #a855f7, #7e22ce);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            margin-top: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 10px rgba(126, 34, 206, 0.2);
        }

        .admin-login-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(126, 34, 206, 0.3);
        }

        .admin-login-btn:active {
            transform: translateY(0);
            box-shadow: 0 2px 5px rgba(126, 34, 206, 0.2);
        }

        .admin-back-link {
            display: inline-flex;
            align-items: center;
            margin-top: 25px;
            color: #64748b;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .admin-back-link i {
            margin-right: 6px;
            transition: transform 0.2s ease;
        }

        .admin-back-link:hover {
            color: #7e22ce;
        }

        .admin-back-link:hover i {
            transform: translateX(-3px);
        }

        .dark-mode .admin-back-link {
            color: #94a3b8;
        }

        .dark-mode .admin-back-link:hover {
            color: #a855f7;
        }

        .alert-danger {
            background-color: #fee2e2;
            border: none;
            color: #b91c1c;
            border-radius: 8px;
            padding: 12px 15px;
            margin-bottom: 20px;
            font-size: 0.9rem;
        }

        .dark-mode .alert-danger {
            background-color: rgba(185, 28, 28, 0.2);
            color: #fca5a5;
        }
    </style>
</head>
<body>
<div class="admin-login-container">
    <div class="admin-login-card">
        <div class="admin-login-header">
            <div class="admin-login-icon">
                <i class="bi bi-shield-lock"></i>
            </div>
            <h3 class="admin-login-title">관리자 로그인</h3>
            <p class="admin-login-subtitle">대시보드에 접근하려면 인증이 필요합니다</p>
        </div>
        <div class="admin-login-body">
            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger" role="alert">
                <i class="bi bi-exclamation-circle me-2"></i>
                <%= request.getAttribute("error") %>
            </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/admin/auth" method="post">
                <div class="form-group">
                    <label for="username" class="form-label">관리자 아이디</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-person-badge"></i></span>
                        <input type="text" class="form-control" id="username" name="username" placeholder="관리자 아이디 입력" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password" class="form-label">비밀번호</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-key"></i></span>
                        <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호 입력" required>
                    </div>
                </div>

                <button type="submit" class="admin-login-btn">로그인</button>
            </form>

            <div style="text-align: center;">
                <a href="${pageContext.request.contextPath}/" class="admin-back-link">
                    <i class="bi bi-arrow-left"></i> 메인 페이지로 돌아가기
                </a>
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
</script>
</body>
</html>
