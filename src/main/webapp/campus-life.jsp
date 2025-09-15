<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠퍼스 생활 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">

    <style>
        .page-container {
            padding: 4rem 0;
            min-height: calc(100vh - 200px);
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: 700;
            color: #1a1a1a; /* 어두운 색상으로 명확하게 설정 */
            margin-bottom: 1rem;
        }

        .page-subtitle {
            font-size: 1.125rem;
            color: #6b7280;
            max-width: 32rem;
            margin: 0 auto 3rem auto;
            line-height: 1.6;
        }

        .service-card {
            border: 1px solid #e5e7eb;
            border-radius: 0.75rem;
            background-color: #ffffff; /* 명확하게 흰색 배경 설정 */
            transition: all 0.3s ease;
            height: 100%;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
        }

        .service-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 25px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            border-color: #d1d5db;
        }

        .card-body-custom {
            padding: 2rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            height: 100%;
        }

        .icon-wrapper {
            width: 3rem;
            height: 3rem;
            border-radius: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.5rem;
        }

        .icon-wrapper i {
            font-size: 1.5rem;
            color: white;
        }

        .card-title {
            font-size: 1.125rem;
            font-weight: 600;
            color: #1a1a1a; /* 어두운 색상으로 명확하게 설정 */
            margin-bottom: 1rem;
        }

        .service-card .text-muted {
            color: #6b7280 !important;
            font-size: 0.875rem;
            line-height: 1.5;
            margin-bottom: 1.5rem;
            flex-grow: 1;
        }

        .btn-detail {
            font-size: 0.875rem;
            font-weight: 500;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            text-decoration: none;
            transition: all 0.2s ease;
            border-width: 1px;
        }

        .btn-outline-primary:hover {
            background-color: #0d6efd;
            border-color: #0d6efd;
            color: white;
        }

        .btn-outline-success:hover {
            background-color: #198754;
            border-color: #198754;
            color: white;
        }

        .btn-outline-warning:hover {
            background-color: #ffc107;
            border-color: #ffc107;
            color: #000;
        }

        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .page-container {
                padding: 2rem 0;
            }

            .page-title {
                font-size: 2rem;
            }

            .page-subtitle {
                font-size: 1rem;
                margin-bottom: 2rem;
            }

            .card-body-custom {
                padding: 1.5rem;
            }
        }

        /* 다크모드 대응 - 브라우저/OS 설정에 따라 자동 적용 */
        @media (prefers-color-scheme: dark) {
            body.dark-mode .service-card {
                background-color: #1f2937;
                border-color: #374151;
            }

            body.dark-mode .page-title {
                color: #f9fafb;
            }

            body.dark-mode .card-title {
                color: #f9fafb;
            }

            body.dark-mode .service-card:hover {
                border-color: #4b5563;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container page-container">
    <div class="text-center mb-5">
        <h1 class="page-title">캠퍼스 생활 정보</h1>
        <p class="page-subtitle">캠퍼스에서의 일상을 더욱 편리하게 만들어주는 다양한 정보들을 확인하세요</p>
    </div>

    <div class="row g-4 justify-content-center">
        <div class="col-md-6 col-lg-4">
            <div class="service-card text-center">
                <div class="card-body-custom">
                    <div class="icon-wrapper" style="background-color: #3b82f6;">
                        <i class="bi bi-cloud-sun-fill"></i>
                    </div>
                    <h5 class="card-title">캠퍼스 날씨</h5>
                    <p class="text-muted my-3">실시간 날씨 정보와 주간 예보를 확인하고 하루를 계획하세요</p>
                    <a href="${pageContext.request.contextPath}/weather" class="btn btn-outline-primary btn-detail">날씨 보기</a>
                </div>
            </div>
        </div>
        <div class="col-md-6 col-lg-4">
            <div class="service-card text-center">
                <div class="card-body-custom">
                    <div class="icon-wrapper" style="background-color: #f97316;">
                        <i class="bi bi-egg-fried"></i>
                    </div>
                    <h5 class="card-title">학식 메뉴</h5>
                    <p class="text-muted my-3">오늘의 학식 메뉴와 가격 정보를 미리 확인해보세요</p>
                    <a href="${pageContext.request.contextPath}/cafeteria" class="btn btn-outline-success btn-detail">메뉴 보기</a>
                </div>
            </div>
        </div>
        <div class="col-md-6 col-lg-4">
            <div class="service-card text-center">
                <div class="card-body-custom">
                    <div class="icon-wrapper" style="background-color: #8b5cf6;">
                        <i class="bi bi-calendar-check-fill"></i>
                    </div>
                    <h5 class="card-title">학사 일정</h5>
                    <p class="text-muted my-3">중요한 학사 일정과 마감일을 놓치지 마세요</p>
                    <a href="${pageContext.request.contextPath}/academic-calendar" class="btn btn-outline-warning btn-detail">일정 보기</a>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
</body>
</html>
