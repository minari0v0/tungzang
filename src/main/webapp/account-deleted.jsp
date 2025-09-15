<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>계정 삭제 완료 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <style>
        .deleted-container {
            min-height: 100vh;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .dark-mode .deleted-container {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
        }

        .deleted-card {
            background: white;
            border-radius: 1.5rem;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            padding: 3rem;
            text-align: center;
            max-width: 500px;
            width: 100%;
        }

        .dark-mode .deleted-card {
            background: #1e293b;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .deleted-icon {
            font-size: 4rem;
            color: #10b981;
            margin-bottom: 2rem;
        }

        .deleted-title {
            font-size: 2rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 1rem;
        }

        .dark-mode .deleted-title {
            color: #e2e8f0;
        }

        .deleted-message {
            color: #64748b;
            margin-bottom: 2rem;
            line-height: 1.6;
        }

        .dark-mode .deleted-message {
            color: #94a3b8;
        }

        .btn-home {
            background: linear-gradient(135deg, #3b82f6, #8b5cf6);
            color: white;
            border: none;
            padding: 0.875rem 2rem;
            border-radius: 50px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.3s ease;
        }

        .btn-home:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(59, 130, 246, 0.3);
            color: white;
        }
    </style>
</head>
<body>
<div class="deleted-container">
    <div class="deleted-card">
        <i class="bi bi-check-circle deleted-icon"></i>
        <h1 class="deleted-title">계정이 삭제되었습니다</h1>
        <p class="deleted-message">
            계정과 관련된 모든 데이터가 안전하게 삭제되었습니다.<br>
            그동안 텅장수강러를 이용해주셔서 감사했습니다.
        </p>
        <a href="${pageContext.request.contextPath}/" class="btn-home">
            <i class="bi bi-house"></i>
            홈으로 돌아가기
        </a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/resources/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
</body>
</html>
