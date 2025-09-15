<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 대시보드 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .admin-container {
            display: flex;
            min-height: 100vh;
        }

        .admin-sidebar {
            width: 280px;
            background-color: #1e293b;
            color: #e2e8f0;
            padding: 20px;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
        }

        .admin-content {
            flex: 1;
            margin-left: 280px;
            padding: 20px;
        }

        .admin-logo {
            display: flex;
            align-items: center;
            font-size: 1.5rem;
            font-weight: 700;
            color: #e2e8f0;
            margin-bottom: 30px;
            text-decoration: none;
        }

        .admin-logo i {
            margin-right: 10px;
            color: #818cf8;
        }

        .admin-nav {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .admin-nav-item {
            margin-bottom: 5px;
        }

        .admin-nav-link {
            display: flex;
            align-items: center;
            padding: 12px 15px;
            color: #94a3b8;
            text-decoration: none;
            border-radius: 6px;
            transition: all 0.2s ease;
        }

        .admin-nav-link:hover, .admin-nav-link.active {
            background-color: #2d3748;
            color: #e2e8f0;
        }

        .admin-nav-link i {
            margin-right: 10px;
            font-size: 1.1rem;
        }

        .admin-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .admin-title {
            font-size: 1.8rem;
            font-weight: 700;
            margin: 0;
        }

        .admin-card {
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            padding: 20px;
            margin-bottom: 20px;
            height: 100%;
        }

        .dark-mode .admin-card {
            background-color: #1e293b;
            color: #e2e8f0;
        }

        .admin-card-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
        }

        .admin-card-title i {
            margin-right: 10px;
            color: #6366f1;
        }

        .dark-mode .admin-card-title i {
            color: #818cf8;
        }

        .admin-stat {
            display: flex;
            align-items: center;
            padding: 15px;
            border-radius: 8px;
            background-color: #f8fafc;
        }

        .dark-mode .admin-stat {
            background-color: #2d3748;
        }

        .admin-stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
            font-size: 1.5rem;
        }

        .admin-stat-info {
            flex: 1;
        }

        .admin-stat-value {
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0;
        }

        .admin-stat-label {
            color: #64748b;
            margin: 0;
        }

        .dark-mode .admin-stat-label {
            color: #94a3b8;
        }

        .admin-chart-container {
            position: relative;
            height: 300px;
            margin-top: 15px;
        }

        .admin-table {
            width: 100%;
        }

        .admin-table th {
            background-color: #f8fafc;
            color: #475569;
            font-weight: 600;
        }

        .dark-mode .admin-table th {
            background-color: #2d3748;
            color: #e2e8f0;
        }

        .admin-table td, .admin-table th {
            padding: 12px 15px;
            border-bottom: 1px solid #e2e8f0;
        }

        .dark-mode .admin-table td, .dark-mode .admin-table th {
            border-bottom: 1px solid #2d3748;
        }

        .admin-badge {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .admin-badge-success {
            background-color: #dcfce7;
            color: #166534;
        }

        .admin-badge-warning {
            background-color: #fef3c7;
            color: #92400e;
        }

        .admin-badge-danger {
            background-color: #fee2e2;
            color: #b91c1c;
        }

        .dark-mode .admin-badge-success {
            background-color: rgba(22, 101, 52, 0.2);
            color: #86efac;
        }

        .dark-mode .admin-badge-warning {
            background-color: rgba(146, 64, 14, 0.2);
            color: #fcd34d;
        }

        .dark-mode .admin-badge-danger {
            background-color: rgba(185, 28, 28, 0.2);
            color: #fca5a5;
        }

        .admin-btn {
            padding: 8px 16px;
            border-radius: 6px;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .admin-btn-primary {
            background-color: #6366f1;
            color: white;
            border: none;
        }

        .admin-btn-primary:hover {
            background-color: #4f46e5;
        }

        .admin-btn-outline {
            background-color: transparent;
            color: #6366f1;
            border: 1px solid #6366f1;
        }

        .admin-btn-outline:hover {
            background-color: #6366f1;
            color: white;
        }

        .dark-mode .admin-btn-outline {
            color: #818cf8;
            border-color: #818cf8;
        }

        .dark-mode .admin-btn-outline:hover {
            background-color: #818cf8;
            color: #1e293b;
        }

        .admin-user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #6366f1;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            margin-right: 10px;
        }

        .admin-user-info {
            display: flex;
            align-items: center;
        }

        .admin-tab-content {
            display: none;
        }

        .admin-tab-content.active {
            display: block;
        }

        .admin-password-form {
            max-width: 500px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f8fafc;
            border-radius: 10px;
        }

        .dark-mode .admin-password-form {
            background-color: #2d3748;
        }
    </style>
</head>
<body>
<div class="admin-container">
    <!-- 사이드바 -->
    <div class="admin-sidebar">
        <a href="${pageContext.request.contextPath}/" class="admin-logo">
            <i class="bi bi-shield-lock"></i>
            <span>텅장수강러 관리자</span>
        </a>

        <ul class="admin-nav">
            <li class="admin-nav-item">
                <a href="#dashboard" class="admin-nav-link" data-tab="dashboard">
                    <i class="bi bi-speedometer2"></i>
                    <span>대시보드</span>
                </a>
            </li>
            <li class="admin-nav-item">
                <a href="#users" class="admin-nav-link" data-tab="users">
                    <i class="bi bi-people"></i>
                    <span>사용자 관리</span>
                </a>
            </li>
            <li class="admin-nav-item">
                <a href="#reports" class="admin-nav-link" data-tab="reports">
                    <i class="bi bi-flag"></i>
                    <span>신고 관리</span>
                </a>
            </li>
            <li class="admin-nav-item">
                <a href="#password" class="admin-nav-link" data-tab="password">
                    <i class="bi bi-key"></i>
                    <span>비밀번호 변경</span>
                </a>
            </li>
            <li class="admin-nav-item">
                <a href="${pageContext.request.contextPath}/admin/logout" class="admin-nav-link">
                    <i class="bi bi-box-arrow-right"></i>
                    <span>로그아웃</span>
                </a>
            </li>
        </ul>
    </div>

    <!-- 메인 콘텐츠 -->
    <div class="admin-content">
        <!-- 대시보드 탭 -->
        <div id="dashboard" class="admin-tab-content">
            <div class="admin-header">
                <h1 class="admin-title">대시보드</h1>
                <div>
                    <button class="admin-btn admin-btn-outline" id="refreshStats">
                        <i class="bi bi-arrow-clockwise me-1"></i> 새로고침
                    </button>
                </div>
            </div>

            <!-- 통계 카드 -->
            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <div class="admin-card">
                        <div class="admin-stat">
                            <div class="admin-stat-icon" style="background-color: rgba(99, 102, 241, 0.1); color: #6366f1;">
                                <i class="bi bi-people"></i>
                            </div>
                            <div class="admin-stat-info">
                                <h3 class="admin-stat-value">${userCount}</h3>
                                <p class="admin-stat-label">총 사용자</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="admin-card">
                        <div class="admin-stat">
                            <div class="admin-stat-icon" style="background-color: rgba(16, 185, 129, 0.1); color: #10b981;">
                                <i class="bi bi-book"></i>
                            </div>
                            <div class="admin-stat-info">
                                <h3 class="admin-stat-value">${courseCount}</h3>
                                <p class="admin-stat-label">등록된 강의</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="admin-card">
                        <div class="admin-stat">
                            <div class="admin-stat-icon" style="background-color: rgba(245, 158, 11, 0.1); color: #f59e0b;">
                                <i class="bi bi-star"></i>
                            </div>
                            <div class="admin-stat-info">
                                <h3 class="admin-stat-value">${evaluationCount}</h3>
                                <p class="admin-stat-label">강의 평가</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="admin-card">
                        <div class="admin-stat">
                            <div class="admin-stat-icon" style="background-color: rgba(239, 68, 68, 0.1); color: #ef4444;">
                                <i class="bi bi-chat-left-text"></i>
                            </div>
                            <div class="admin-stat-info">
                                <h3 class="admin-stat-value">${postCount}</h3>
                                <p class="admin-stat-label">커뮤니티 게시글</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 차트 -->
            <div class="row g-4 mb-4">
                <div class="col-md-8">
                    <div class="admin-card">
                        <h3 class="admin-card-title">
                            <i class="bi bi-graph-up"></i>
                            <span>월별 사용자 활동</span>
                        </h3>
                        <div class="admin-chart-container">
                            <canvas id="userActivityChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="admin-card">
                        <h3 class="admin-card-title">
                            <i class="bi bi-pie-chart"></i>
                            <span>학과별 사용자 분포</span>
                        </h3>
                        <div class="admin-chart-container">
                            <canvas id="departmentChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 최근 활동 -->
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="admin-card">
                        <h3 class="admin-card-title">
                            <i class="bi bi-clock-history"></i>
                            <span>최근 강의 평가</span>
                        </h3>
                        <div class="table-responsive">
                            <table class="admin-table">
                                <thead>
                                <tr>
                                    <th>강의명</th>
                                    <th>평점</th>
                                    <th>작성자</th>
                                    <th>날짜</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="evaluation" items="${recentEvaluations}">
                                    <tr>
                                        <td>${evaluation.courseName}</td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <span class="me-2">${evaluation.rating}</span>
                                                <i class="bi bi-star-fill text-warning"></i>
                                            </div>
                                        </td>
                                        <td>${evaluation.userName}</td>
                                        <td>${evaluation.formattedDate}</td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="admin-card">
                        <h3 class="admin-card-title">
                            <i class="bi bi-chat-dots"></i>
                            <span>최근 게시글</span>
                        </h3>
                        <div class="table-responsive">
                            <table class="admin-table">
                                <thead>
                                <tr>
                                    <th>제목</th>
                                    <th>카테고리</th>
                                    <th>작성자</th>
                                    <th>날짜</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="post" items="${recentPosts}">
                                    <tr>
                                        <td>${post.title}</td>
                                        <td>
                                            <span class="admin-badge admin-badge-success">${post.category}</span>
                                        </td>
                                        <td>${post.authorName}</td>
                                        <td>${post.formattedDate}</td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 사용자 관리 탭 -->
        <div id="users" class="admin-tab-content">
            <div class="admin-header">
                <h1 class="admin-title">사용자 관리</h1>
                <div>
                    <button class="admin-btn admin-btn-primary" data-bs-toggle="modal" data-bs-target="#addUserModal">
                        <i class="bi bi-person-plus me-1"></i> 사용자 추가
                    </button>
                </div>
            </div>

            <div class="admin-card">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h3 class="admin-card-title mb-0">
                        <i class="bi bi-people"></i>
                        <span>사용자 목록</span>
                    </h3>
                    <div class="input-group" style="max-width: 300px;">
                        <input type="text" class="form-control" placeholder="사용자 검색..." id="userSearchInput">
                        <button class="btn btn-outline-secondary" type="button" id="userSearchBtn">
                            <i class="bi bi-search"></i>
                        </button>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="admin-table" id="usersTable">
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>사용자명</th>
                            <th>이메일</th>
                            <th>학과</th>
                            <th>가입일</th>
                            <th>상태</th>
                            <th>관리</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="user" items="${users}">
                            <tr>
                                <td>${user.id}</td>
                                <td>
                                    <div class="admin-user-info">
                                        <div class="admin-user-avatar">${user.name.charAt(0)}</div>
                                        <div>
                                            <div>${user.name}</div>
                                            <div class="text-muted small">${user.username}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>${user.email}</td>
                                <td>${user.department}</td>
                                <td>${user.formattedCreatedAt}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${user.isAdmin}">
                                            <span class="admin-badge admin-badge-warning">관리자</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="admin-badge admin-badge-success">일반</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="d-flex gap-2">
                                        <button class="btn btn-sm btn-outline-primary edit-user-btn" data-user-id="${user.id}">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <button class="btn btn-sm btn-outline-danger delete-user-btn" data-user-id="${user.id}">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- 신고 관리 탭 -->
        <div id="reports" class="admin-tab-content">
            <div class="admin-header">
                <h1 class="admin-title">신고 관리</h1>
            </div>

            <div class="admin-card">
                <h3 class="admin-card-title">
                    <i class="bi bi-flag"></i>
                    <span>신고된 콘텐츠</span>
                </h3>

                <ul class="nav nav-tabs mb-4">
                    <li class="nav-item">
                        <a class="nav-link active" data-bs-toggle="tab" href="#reportedPosts">게시글</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-bs-toggle="tab" href="#reportedComments">댓글</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" data-bs-toggle="tab" href="#reportedEvaluations">강의평가</a>
                    </li>
                </ul>

                <div class="tab-content">
                    <div class="tab-pane fade show active" id="reportedPosts">
                        <div class="table-responsive">
                            <table class="admin-table">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>제목</th>
                                    <th>작성자</th>
                                    <th>카테고리</th>
                                    <th>작성일</th>
                                    <th>관리</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="post" items="${reportedPosts}">
                                    <tr>
                                        <td>${post.id}</td>
                                        <td>${post.title}</td>
                                        <td>${post.authorName}</td>
                                        <td>
                                            <span class="admin-badge admin-badge-success">${post.category}</span>
                                        </td>
                                        <td>${post.formattedDate}</td>
                                        <td>
                                            <div class="d-flex gap-2">
                                                <button class="btn btn-sm btn-outline-primary view-post-btn" data-post-id="${post.id}">
                                                    <i class="bi bi-eye"></i>
                                                </button>
                                                <button class="btn btn-sm btn-outline-danger delete-post-btn" data-post-id="${post.id}">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                                <button class="btn btn-sm btn-outline-success ignore-post-report-btn" data-post-id="${post.id}">
                                                    <i class="bi bi-check-lg"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="reportedComments">
                        <div class="table-responsive">
                            <table class="admin-table">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>내용</th>
                                    <th>게시글</th>
                                    <th>작성자</th>
                                    <th>작성일</th>
                                    <th>관리</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="comment" items="${reportedComments}">
                                    <tr>
                                        <td>${comment.id}</td>
                                        <td>${fn:substring(comment.content, 0, 50)}${fn:length(comment.content) > 50 ? '...' : ''}</td>
                                        <td>${comment.postTitle}</td>
                                        <td>${comment.authorName}</td>
                                        <td>${comment.formattedDate}</td>
                                        <td>
                                            <div class="d-flex gap-2">
                                                <button class="btn btn-sm btn-outline-primary view-comment-btn" data-comment-id="${comment.id}">
                                                    <i class="bi bi-eye"></i>
                                                </button>
                                                <button class="btn btn-sm btn-outline-danger delete-comment-btn" data-comment-id="${comment.id}">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                                <button class="btn btn-sm btn-outline-success ignore-comment-report-btn" data-comment-id="${comment.id}">
                                                    <i class="bi bi-check-lg"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="reportedEvaluations">
                        <div class="table-responsive">
                            <table class="admin-table">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>강의명</th>
                                    <th>내용</th>
                                    <th>작성자</th>
                                    <th>평점</th>
                                    <th>관리</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="evaluation" items="${reportedEvaluations}">
                                    <tr>
                                        <td>${evaluation.id}</td>
                                        <td>${evaluation.courseName} (${evaluation.professor})</td>
                                        <td>${fn:substring(evaluation.comment, 0, 50)}${fn:length(evaluation.comment) > 50 ? '...' : ''}</td>
                                        <td>${evaluation.userName}</td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <span class="me-2">${evaluation.rating}</span>
                                                <i class="bi bi-star-fill text-warning"></i>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="d-flex gap-2">
                                                <button class="btn btn-sm btn-outline-primary view-evaluation-btn"
                                                        data-evaluation-id="${evaluation.id}"
                                                        data-course-id="${evaluation.courseId}">
                                                    <i class="bi bi-eye"></i>
                                                </button>
                                                <button class="btn btn-sm btn-outline-danger delete-evaluation-btn" data-evaluation-id="${evaluation.id}">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                                <button class="btn btn-sm btn-outline-success ignore-evaluation-report-btn" data-evaluation-id="${evaluation.id}">
                                                    <i class="bi bi-check-lg"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 비밀번호 변경 탭 -->
        <div id="password" class="admin-tab-content">
            <div class="admin-header">
                <h1 class="admin-title">비밀번호 변경</h1>
            </div>

            <div class="admin-card">
                <h3 class="admin-card-title">
                    <i class="bi bi-key"></i>
                    <span>관리자 비밀번호 변경</span>
                </h3>

                <div class="admin-password-form">
                    <% if (request.getAttribute("passwordError") != null) { %>
                    <div class="alert alert-danger" role="alert">
                        <%= request.getAttribute("passwordError") %>
                    </div>
                    <% } %>

                    <% if (request.getAttribute("passwordSuccess") != null) { %>
                    <div class="alert alert-success" role="alert">
                        <%= request.getAttribute("passwordSuccess") %>
                    </div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/admin/change-password" method="post" id="passwordChangeForm">
                        <div class="mb-3">
                            <label for="currentPassword" class="form-label">현재 비밀번호</label>
                            <input type="password" class="form-control" id="currentPassword" name="currentPassword" required>
                        </div>

                        <div class="mb-3">
                            <label for="newPassword" class="form-label">새 비밀번호</label>
                            <input type="password" class="form-control" id="newPassword" name="newPassword" required>
                            <div class="form-text">비밀번호는 최소 8자 이상이어야 하며, 문자, 숫자, 특수문자를 포함해야 합니다.</div>
                        </div>

                        <div class="mb-4">
                            <label for="confirmPassword" class="form-label">비밀번호 확인</label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                        </div>

                        <div class="d-grid">
                            <button type="submit" class="admin-btn admin-btn-primary">비밀번호 변경</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 사용자 추가 모달 -->
<div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addUserModalLabel">사용자 추가</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="addUserForm">
                    <div class="mb-3">
                        <label for="addUsername" class="form-label">아이디</label>
                        <input type="text" class="form-control" id="addUsername" name="username" required>
                    </div>
                    <div class="mb-3">
                        <label for="addName" class="form-label">이름</label>
                        <input type="text" class="form-control" id="addName" name="name" required>
                    </div>
                    <div class="mb-3">
                        <label for="addEmail" class="form-label">이메일</label>
                        <input type="email" class="form-control" id="addEmail" name="email" required>
                    </div>
                    <div class="mb-3">
                        <label for="addDepartment" class="form-label">학과</label>
                        <input type="text" class="form-control" id="addDepartment" name="department">
                    </div>
                    <div class="mb-3">
                        <label for="addStudentId" class="form-label">학번</label>
                        <input type="text" class="form-control" id="addStudentId" name="studentId">
                    </div>
                    <div class="mb-3">
                        <label for="addPassword" class="form-label">비밀번호</label>
                        <input type="password" class="form-control" id="addPassword" name="password" required>
                    </div>
                    <div class="mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="addIsAdmin" name="isAdmin">
                        <label class="form-check-label" for="addIsAdmin">관리자 권한 부여</label>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" id="addUserSubmit">추가</button>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script>
    // JSP에서 contextPath를 JavaScript 변수로 전달
    const contextPath = '${pageContext.request.contextPath}';

    document.addEventListener('DOMContentLoaded', function() {
        // 다크 모드 상태 확인 및 적용
        const darkMode = localStorage.getItem('darkMode');
        const prefersDarkScheme = window.matchMedia("(prefers-color-scheme: dark)");

        if (darkMode === 'enabled' || (darkMode === null && prefersDarkScheme.matches)) {
            document.body.classList.add('dark-mode');
        }

        // 현재 활성화된 탭 가져오기 (localStorage에서)
        const activeTab = localStorage.getItem('adminActiveTab') || 'dashboard';

        // 탭 활성화 함수
        function activateTab(tabId) {
            // 모든 탭 링크에서 active 클래스 제거
            document.querySelectorAll('.admin-nav-link[data-tab]').forEach(link => {
                link.classList.remove('active');
            });

            // 모든 탭 콘텐츠에서 active 클래스 제거
            document.querySelectorAll('.admin-tab-content').forEach(content => {
                content.classList.remove('active');
            });

            // 선택한 탭 링크와 콘텐츠에 active 클래스 추가
            const tabLink = document.querySelector(`.admin-nav-link[data-tab="${tabId}"]`);
            if (tabLink) tabLink.classList.add('active');

            const tabContent = document.getElementById(tabId);
            if (tabContent) tabContent.classList.add('active');

            // localStorage에 현재 탭 저장
            localStorage.setItem('adminActiveTab', tabId);
        }

        // 페이지 로드 시 저장된 탭 활성화
        activateTab(activeTab);

        // 탭 전환 기능
        const tabLinks = document.querySelectorAll('.admin-nav-link[data-tab]');
        tabLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                const tabId = this.getAttribute('data-tab');
                activateTab(tabId);
            });
        });

        // 비밀번호 변경 폼 유효성 검사
        const passwordChangeForm = document.getElementById('passwordChangeForm');
        if (passwordChangeForm) {
            passwordChangeForm.addEventListener('submit', function(e) {
                const newPassword = document.getElementById('newPassword').value;
                const confirmPassword = document.getElementById('confirmPassword').value;

                if (newPassword !== confirmPassword) {
                    e.preventDefault();
                    alert('새 비밀번호와 확인 비밀번호가 일치하지 않습니다.');
                    return;
                }

                // 비밀번호 복잡성 검사
                const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/;
                if (!passwordRegex.test(newPassword)) {
                    e.preventDefault();
                    alert('비밀번호는 최소 8자 이상이어야 하며, 문자, 숫자, 특수문자를 포함해야 합니다.');
                    return;
                }
            });
        }

        // 차트 초기화
        initCharts();

        // 사용자 검색 기능
        const userSearchInput = document.getElementById('userSearchInput');
        const userSearchBtn = document.getElementById('userSearchBtn');

        if (userSearchBtn) {
            userSearchBtn.addEventListener('click', function() {
                const searchTerm = userSearchInput.value.toLowerCase();
                const rows = document.querySelectorAll('#usersTable tbody tr');

                rows.forEach(row => {
                    const text = row.textContent.toLowerCase();
                    if (text.includes(searchTerm)) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            });
        }

        // 사용자 추가 기능
        const addUserSubmit = document.getElementById('addUserSubmit');
        if (addUserSubmit) {
            addUserSubmit.addEventListener('click', function() {
                const form = document.getElementById('addUserForm');
                const formData = new FormData(form);

                fetch(contextPath + '/admin/users/add', {
                    method: 'POST',
                    body: formData
                })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            alert('사용자가 성공적으로 추가되었습니다.');
                            window.location.reload();
                        } else {
                            alert('사용자 추가에 실패했습니다: ' + data.message);
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        alert('사용자 추가 중 오류가 발생했습니다.');
                    });
            });
        }

        // 사용자 삭제 기능
        const deleteUserBtns = document.querySelectorAll('.delete-user-btn');
        deleteUserBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const userId = this.getAttribute('data-user-id');

                if (confirm('정말로 이 사용자를 삭제하시겠습니까?')) {
                    fetch(contextPath + '/admin/users/delete/' + userId, {
                        method: 'POST'
                    })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                alert('사용자가 성공적으로 삭제되었습니다.');
                                window.location.reload();
                            } else {
                                alert('사용자 삭제에 실패했습니다: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('사용자 삭제 중 오류가 발생했습니다.');
                        });
                }
            });
        });

        // 게시글 관련 버튼 이벤트 처리
        const deletePostBtns = document.querySelectorAll('.delete-post-btn');
        deletePostBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const postId = this.getAttribute('data-post-id');
                console.log('삭제할 게시글 ID:', postId); // 디버그용
                console.log('구성된 URL:', contextPath + '/admin/reports/delete-post/' + postId); // 디버그용

                if (confirm('정말로 이 게시글을 삭제하시겠습니까?')) {
                    fetch(contextPath + '/admin/reports/delete-post/' + postId, {
                        method: 'POST'
                    })
                        .then(response => {
                            console.log('응답 상태:', response.status); // 디버그용
                            return response.json();
                        })
                        .then(data => {
                            if (data.success) {
                                alert('게시글이 성공적으로 삭제되었습니다.');
                                window.location.reload();
                            } else {
                                alert('게시글 삭제에 실패했습니다: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('게시글 삭제 중 오류가 발생했습니다.');
                        });
                }
            });
        });

        const ignorePostReportBtns = document.querySelectorAll('.ignore-post-report-btn');
        ignorePostReportBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const postId = this.getAttribute('data-post-id');
                console.log('무시할 게시글 ID:', postId); // 디버그용
                console.log('구성된 URL:', contextPath + '/admin/reports/ignore-post/' + postId); // 디버그용

                if (confirm('이 게시글에 대한 신고를 무시하시겠습니까?')) {
                    fetch(contextPath + '/admin/reports/ignore-post/' + postId, {
                        method: 'POST'
                    })
                        .then(response => {
                            console.log('응답 상태:', response.status); // 디버그용
                            return response.json();
                        })
                        .then(data => {
                            if (data.success) {
                                alert('게시글 신고가 무시되었습니다.');
                                window.location.reload();
                            } else {
                                alert('게시글 신고 무시에 실패했습니다: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('게시글 신고 무시 중 오류가 발생했습니다.');
                        });
                }
            });
        });

        // 댓글 관련 버튼 이벤트 처리
        const deleteCommentBtns = document.querySelectorAll('.delete-comment-btn');
        deleteCommentBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const commentId = this.getAttribute('data-comment-id');
                console.log('삭제할 댓글 ID:', commentId); // 디버그용
                console.log('구성된 URL:', contextPath + '/admin/reports/delete-comment/' + commentId); // 디버그용

                if (confirm('정말로 이 댓글을 삭제하시겠습니까?')) {
                    fetch(contextPath + '/admin/reports/delete-comment/' + commentId, {
                        method: 'POST'
                    })
                        .then(response => {
                            console.log('응답 상태:', response.status); // 디버그용
                            return response.json();
                        })
                        .then(data => {
                            if (data.success) {
                                alert('댓글이 성공적으로 삭제되었습니다.');
                                window.location.reload();
                            } else {
                                alert('댓글 삭제에 실패했습니다: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('댓글 삭제 중 오류가 발생했습니다.');
                        });
                }
            });
        });

        const ignoreCommentReportBtns = document.querySelectorAll('.ignore-comment-report-btn');
        ignoreCommentReportBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const commentId = this.getAttribute('data-comment-id');
                console.log('무시할 댓글 ID:', commentId); // 디버그용
                console.log('구성된 URL:', contextPath + '/admin/reports/ignore-comment/' + commentId); // 디버그용

                if (confirm('이 댓글에 대한 신고를 무시하시겠습니까?')) {
                    fetch(contextPath + '/admin/reports/ignore-comment/' + commentId, {
                        method: 'POST'
                    })
                        .then(response => {
                            console.log('응답 상태:', response.status); // 디버그용
                            return response.json();
                        })
                        .then(data => {
                            if (data.success) {
                                alert('댓글 신고가 무시되었습니다.');
                                window.location.reload();
                            } else {
                                alert('댓글 신고 무시에 실패했습니다: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('댓글 신고 무시 중 오류가 발생했습니다.');
                        });
                }
            });
        });

        // 강의평가 관련 버튼 이벤트 처리
        const deleteEvaluationBtns = document.querySelectorAll('.delete-evaluation-btn');
        deleteEvaluationBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const evaluationId = this.getAttribute('data-evaluation-id');
                console.log('삭제할 강의평가 ID:', evaluationId); // 디버그용
                console.log('구성된 URL:', contextPath + '/admin/reports/delete-evaluation/' + evaluationId); // 디버그용

                if (confirm('정말로 이 강의평가를 삭제하시겠습니까?')) {
                    fetch(contextPath + '/admin/reports/delete-evaluation/' + evaluationId, {
                        method: 'POST'
                    })
                        .then(response => {
                            console.log('응답 상태:', response.status); // 디버그용
                            return response.json();
                        })
                        .then(data => {
                            if (data.success) {
                                alert('강의평가가 성공적으로 삭제되었습니다.');
                                window.location.reload();
                            } else {
                                alert('강의평가 삭제에 실패했습니다: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('강의평가 삭제 중 오류가 발생했습니다.');
                        });
                }
            });
        });

        const ignoreEvaluationReportBtns = document.querySelectorAll('.ignore-evaluation-report-btn');
        ignoreEvaluationReportBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const evaluationId = this.getAttribute('data-evaluation-id');
                console.log('무시할 강의평가 ID:', evaluationId); // 디버그용
                console.log('구성된 URL:', contextPath + '/admin/reports/ignore-evaluation/' + evaluationId); // 디버그용

                if (confirm('이 강의평가에 대한 신고를 무시하시겠습니까?')) {
                    fetch(contextPath + '/admin/reports/ignore-evaluation/' + evaluationId, {
                        method: 'POST'
                    })
                        .then(response => {
                            console.log('응답 상태:', response.status); // 디버그용
                            return response.json();
                        })
                        .then(data => {
                            if (data.success) {
                                alert('강의평가 신고가 무시되었습니다.');
                                window.location.reload();
                            } else {
                                alert('강의평가 신고 무시에 실패했습니다: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('강의평가 신고 무시 중 오류가 발생했습니다.');
                        });
                }
            });
        });

        // 게시글 보기 버튼 이벤트 처리
        const viewPostBtns = document.querySelectorAll('.view-post-btn');
        viewPostBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const postId = this.getAttribute('data-post-id');
                console.log('보기할 게시글 ID:', postId); // 디버그용
                window.open(contextPath + '/community/post/' + postId, '_blank');
            });
        });

        // 댓글 보기 버튼 이벤트 처리
        const viewCommentBtns = document.querySelectorAll('.view-comment-btn');
        viewCommentBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const commentId = this.getAttribute('data-comment-id');
                console.log('보기할 댓글 ID:', commentId); // 디버그용
                // 댓글의 경우 해당 게시글로 이동하고 댓글 위치로 스크롤
                // 실제 구현에서는 댓글이 속한 게시글 ID를 가져와야 합니다
                alert('댓글 상세보기 기능은 추후 구현 예정입니다.');
            });
        });

        // 강의평가 보기 버튼 이벤트 처리
        const viewEvaluationBtns = document.querySelectorAll('.view-evaluation-btn');
        viewEvaluationBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const evaluationId = this.getAttribute('data-evaluation-id');
                const courseId = this.getAttribute('data-course-id');
                console.log('보기할 강의평가 ID:', evaluationId); // 디버그용
                console.log('강의 ID:', courseId); // 디버그용

                // 강의 ID로 URL 구성 (강의평가 ID가 아닌)
                if (courseId) {
                    window.open(contextPath + '/evaluations/detail/' + courseId, '_blank');
                } else {
                    alert('강의 정보를 찾을 수 없습니다.');
                }
            });
        });
    });

    // 차트 초기화 함수
    function initCharts() {
        // 월별 사용자 활동 차트
        const userActivityCtx = document.getElementById('userActivityChart');
        if (userActivityCtx) {
            const userActivityChart = new Chart(userActivityCtx, {
                type: 'line',
                data: {
                    labels: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
                    datasets: [
                        {
                            label: '강의 평가',
                            data: [65, 59, 80, 81, 56, 55, 40, 45, 60, 70, 85, 90],
                            borderColor: '#6366f1',
                            backgroundColor: 'rgba(99, 102, 241, 0.1)',
                            tension: 0.3,
                            fill: true
                        },
                        {
                            label: '게시글',
                            data: [28, 48, 40, 19, 86, 27, 90, 85, 70, 60, 65, 75],
                            borderColor: '#10b981',
                            backgroundColor: 'rgba(16, 185, 129, 0.1)',
                            tension: 0.3,
                            fill: true
                        },
                        {
                            label: '댓글',
                            data: [42, 35, 60, 65, 45, 50, 70, 75, 55, 40, 50, 60],
                            borderColor: '#f59e0b',
                            backgroundColor: 'rgba(245, 158, 11, 0.1)',
                            tension: 0.3,
                            fill: true
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        tooltip: {
                            mode: 'index',
                            intersect: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        }

        // 학과별 사용자 분포 차트
        const departmentCtx = document.getElementById('departmentChart');
        if (departmentCtx) {
            const departmentChart = new Chart(departmentCtx, {
                type: 'doughnut',
                data: {
                    labels: ['컴퓨터공학과', '경영학과', '심리학과', '전자공학과', '수학과', '기타'],
                    datasets: [{
                        data: [30, 20, 15, 12, 10, 13],
                        backgroundColor: [
                            '#6366f1',
                            '#10b981',
                            '#f59e0b',
                            '#ef4444',
                            '#8b5cf6',
                            '#64748b'
                        ],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                        }
                    },
                    cutout: '70%'
                }
            });
        }
    }
</script>
</body>
</html>
