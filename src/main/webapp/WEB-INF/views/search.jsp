<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.minari.tungzang.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>

<%
    // 검색어 파라미터 가져오기
    String query = request.getParameter("query");

    // 사용자 정보 가져오기
    User user = (User) session.getAttribute("user");

    // 검색 결과 (실제로는 DB에서 가져와야 함)
    // 여기서는 예시 데이터만 생성
    List<Map<String, Object>> courseResults = new ArrayList<>();
    List<Map<String, Object>> evaluationResults = new ArrayList<>();
    List<Map<String, Object>> postResults = new ArrayList<>();

    if (query != null && !query.trim().isEmpty()) {
        // 강의 검색 결과 예시
        for (int i = 1; i <= 3; i++) {
            Map<String, Object> course = new HashMap<>();
            course.put("id", i);
            course.put("name", "자료구조와 알고리즘 " + i);
            course.put("professor", "김교수");
            course.put("department", "컴퓨터공학과");
            course.put("rating", 4.5);
            course.put("tags", new String[]{"꿀강의", "학점좋음", "과제많음"});
            courseResults.add(course);
        }

        // 강의평가 검색 결과 예시
        for (int i = 1; i <= 2; i++) {
            Map<String, Object> evaluation = new HashMap<>();
            evaluation.put("id", i);
            evaluation.put("courseName", "프로그래밍 기초 " + i);
            evaluation.put("professor", "이교수");
            evaluation.put("rating", 4.0);
            evaluation.put("content", "이 강의는 매우 유익했습니다. 교수님의 설명이 명확하고 이해하기 쉬웠습니다.");
            evaluation.put("semester", "2023년 1학기");
            evaluation.put("likes", 15);
            evaluation.put("author", "학생" + i);
            evaluation.put("date", "2023-06-15");
            evaluationResults.add(evaluation);
        }

        // 게시글 검색 결과 예시
        for (int i = 1; i <= 4; i++) {
            Map<String, Object> post = new HashMap<>();
            post.put("id", i);
            post.put("title", "시험 정보 공유합니다 " + i);
            post.put("content", "이번 중간고사 범위는 1장부터 5장까지입니다. 특히 3장이 중요하다고 하네요.");
            post.put("category", "정보공유");
            post.put("author", "익명" + i);
            post.put("date", "2023-06-20");
            post.put("views", 120);
            post.put("comments", 8);
            post.put("likes", 25);
            postResults.add(post);
        }
    }

    // 전체 결과 수
    int totalResults = courseResults.size() + evaluationResults.size() + postResults.size();

    // 최근 검색어 예시 (실제로는 세션이나 DB에서 가져와야 함)
    String[] recentSearches = {"자료구조", "알고리즘", "프로그래밍", "데이터베이스"};

    // 인기 검색어 예시 (실제로는 DB에서 가져와야 함)
    String[] popularSearches = {"기초프로그래밍", "자바", "파이썬", "웹개발", "인공지능"};
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>검색 결과 - 텅장수강러</title>

    <!-- 부트스트랩 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">

    <!-- 부트스트랩 아이콘 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">

    <!-- 커스텀 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login-modal.css">

    <!-- 검색 페이지 전용 스타일 -->
    <style>
        /* 검색 결과 컨테이너 */
        .search-results-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem 1rem;
        }

        /* 검색 입력 필드 */
        .search-input-container {
            position: relative;
            margin-bottom: 2rem;
        }

        .search-input {
            width: 100%;
            padding: 1rem 1rem 1rem 3rem;
            border-radius: 0.5rem;
            border: 1px solid #e2e8f0;
            font-size: 1.125rem;
            transition: all 0.2s ease;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(126, 34, 206, 0.1);
        }

        .search-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: #6c757d;
            font-size: 1.25rem;
        }

        .search-button {
            position: absolute;
            right: 0.5rem;
            top: 50%;
            transform: translateY(-50%);
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 0.375rem;
            padding: 0.5rem 1rem;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .search-button:hover {
            background-color: var(--primary-dark);
        }

        /* 검색 결과 탭 */
        .search-tabs {
            display: flex;
            border-bottom: 1px solid #e2e8f0;
            margin-bottom: 1.5rem;
            overflow-x: auto;
            white-space: nowrap;
        }

        .search-tab {
            padding: 0.75rem 1.5rem;
            font-weight: 500;
            color: #6c757d;
            cursor: pointer;
            transition: all 0.2s ease;
            border-bottom: 2px solid transparent;
        }

        .search-tab.active {
            color: var(--primary-color);
            border-bottom-color: var(--primary-color);
        }

        .search-tab:hover:not(.active) {
            color: var(--primary-dark);
            border-bottom-color: #e2e8f0;
        }

        /* 검색 결과 항목 */
        .search-result-item {
            padding: 1.25rem;
            border-radius: 0.5rem;
            transition: all 0.2s ease;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: flex-start;
        }

        .search-result-item:hover {
            background-color: #f8fafc;
        }

        .dark-mode .search-result-item:hover {
            background-color: #1e293b;
        }

        .result-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            flex-shrink: 0;
        }

        .result-icon.course {
            background-color: #e9f5ff;
            color: #0284c7;
        }

        .result-icon.evaluation {
            background-color: #fef3c7;
            color: #d97706;
        }

        .result-icon.post {
            background-color: #e0f2fe;
            color: #0ea5e9;
        }

        .result-content {
            flex: 1;
        }

        .result-title {
            font-weight: 600;
            font-size: 1.125rem;
            margin-bottom: 0.5rem;
            color: var(--text-color);
            text-decoration: none;
            display: block;
        }

        .result-title:hover {
            color: var(--primary-color);
        }

        .result-meta {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 0.5rem;
            color: #6c757d;
            font-size: 0.875rem;
        }

        .result-meta-item {
            display: flex;
            align-items: center;
        }

        .result-meta-item i {
            margin-right: 0.25rem;
        }

        .result-description {
            color: #6c757d;
            margin-bottom: 0.75rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .result-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
        }

        .result-tag {
            background-color: #f1f5f9;
            color: #64748b;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .dark-mode .result-tag {
            background-color: #334155;
            color: #cbd5e1;
        }

        .rating-badge {
            background-color: #fef3c7;
            color: #d97706;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-weight: 500;
            font-size: 0.875rem;
            display: flex;
            align-items: center;
            margin-left: auto;
        }

        .rating-badge i {
            color: #f59e0b;
            margin-right: 0.25rem;
        }

        .dark-mode .rating-badge {
            background-color: rgba(245, 158, 11, 0.2);
            color: #fbbf24;
        }

        /* 검색 제안 */
        .search-suggestions {
            margin-top: 2rem;
        }

        .suggestions-title {
            font-size: 1.125rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: var(--text-color);
        }

        .suggestions-list {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
        }

        .suggestion-item {
            background-color: #f1f5f9;
            color: #64748b;
            padding: 0.5rem 1rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .suggestion-item:hover {
            background-color: #e2e8f0;
            color: #334155;
        }

        .dark-mode .suggestion-item {
            background-color: #334155;
            color: #cbd5e1;
        }

        .dark-mode .suggestion-item:hover {
            background-color: #475569;
            color: #f1f5f9;
        }

        /* 검색 결과 없음 */
        .no-results {
            text-align: center;
            padding: 3rem 1rem;
            background-color: #f8fafc;
            border-radius: 0.5rem;
            margin: 2rem 0;
        }

        .dark-mode .no-results {
            background-color: #1e293b;
        }

        .no-results i {
            font-size: 3rem;
            color: #cbd5e1;
            margin-bottom: 1.5rem;
        }

        .dark-mode .no-results i {
            color: #475569;
        }

        .no-results h3 {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: var(--text-color);
        }

        .no-results p {
            color: #6c757d;
            margin-bottom: 1.5rem;
            max-width: 500px;
            margin-left: auto;
            margin-right: auto;
        }

        /* 로딩 상태 */
        .loading-state {
            text-align: center;
            padding: 3rem 1rem;
        }

        .spinner {
            width: 3rem;
            height: 3rem;
            border: 0.25rem solid rgba(126, 34, 206, 0.1);
            border-radius: 50%;
            border-top-color: var(--primary-color);
            animation: spin 1s linear infinite;
            margin: 0 auto 1.5rem;
        }

        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }

        /* 섹션 헤더 */
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .section-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-color);
        }

        .section-link {
            color: var(--primary-color);
            font-weight: 500;
            text-decoration: none;
            display: flex;
            align-items: center;
        }

        .section-link:hover {
            text-decoration: underline;
        }

        .section-link i {
            margin-left: 0.25rem;
        }

        /* 별점 표시 */
        .star-rating {
            display: flex;
            align-items: center;
        }

        .star-rating i {
            color: #f59e0b;
            font-size: 0.875rem;
        }

        /* 반응형 */
        @media (max-width: 768px) {
            .search-tabs {
                padding-bottom: 0.5rem;
            }

            .search-tab {
                padding: 0.75rem 1rem;
            }

            .result-meta {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.5rem;
            }

            .rating-badge {
                margin-left: 0;
                margin-top: 0.5rem;
            }
        }
    </style>
</head>
<body>
<!-- 헤더 포함 -->
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="search-results-container">
    <!-- 검색 입력 필드 -->
    <div class="search-input-container">
        <i class="bi bi-search search-icon"></i>
        <form action="${pageContext.request.contextPath}/search" method="get">
            <input type="text" class="search-input" name="query" placeholder="강의, 교수, 키워드 검색" value="<%= query != null ? query : "" %>" autofocus>
            <button type="submit" class="search-button">검색</button>
        </form>
    </div>

    <% if (query != null && !query.trim().isEmpty()) { %>
    <!-- 검색 결과가 있는 경우 -->
    <% if (totalResults > 0) { %>
    <!-- 검색 결과 요약 -->
    <div class="mb-4">
        <h2 class="h4 mb-2">"<%= query %>" 검색 결과</h2>
        <p class="text-muted">총 <%= totalResults %>개의 결과를 찾았습니다.</p>
    </div>

    <!-- 검색 결과 탭 -->
    <div class="search-tabs">
        <div class="search-tab active" data-tab="all">전체 (<%= totalResults %>)</div>
        <div class="search-tab" data-tab="courses">강의 (<%= courseResults.size() %>)</div>
        <div class="search-tab" data-tab="evaluations">평가 (<%= evaluationResults.size() %>)</div>
        <div class="search-tab" data-tab="posts">게시글 (<%= postResults.size() %>)</div>
    </div>

    <!-- 전체 탭 내용 -->
    <div class="tab-content active" id="tab-all">
        <!-- 강의 섹션 -->
        <% if (!courseResults.isEmpty()) { %>
        <div class="section-header">
            <h3 class="section-title">강의</h3>
            <a href="#" class="section-link" onclick="switchTab('courses')">더보기 <i class="bi bi-chevron-right"></i></a>
        </div>

        <div class="search-results">
            <% for (int i = 0; i < Math.min(2, courseResults.size()); i++) { %>
            <% Map<String, Object> course = courseResults.get(i); %>
            <div class="search-result-item">
                <div class="result-icon course">
                    <i class="bi bi-book"></i>
                </div>
                <div class="result-content">
                    <a href="${pageContext.request.contextPath}/courses/<%= course.get("id") %>" class="result-title"><%= course.get("name") %></a>
                    <div class="result-meta">
                        <div class="result-meta-item">
                            <i class="bi bi-person"></i>
                            <%= course.get("professor") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-building"></i>
                            <%= course.get("department") %>
                        </div>
                    </div>
                    <div class="result-tags">
                        <% String[] tags = (String[]) course.get("tags"); %>
                        <% for (String tag : tags) { %>
                        <span class="result-tag"><%= tag %></span>
                        <% } %>
                    </div>
                </div>
                <div class="rating-badge">
                    <i class="bi bi-star-fill"></i>
                    <%= course.get("rating") %>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>

        <!-- 강의평가 섹션 -->
        <% if (!evaluationResults.isEmpty()) { %>
        <div class="section-header mt-4">
            <h3 class="section-title">강의평가</h3>
            <a href="#" class="section-link" onclick="switchTab('evaluations')">더보기 <i class="bi bi-chevron-right"></i></a>
        </div>

        <div class="search-results">
            <% for (int i = 0; i < Math.min(2, evaluationResults.size()); i++) { %>
            <% Map<String, Object> evaluation = evaluationResults.get(i); %>
            <div class="search-result-item">
                <div class="result-icon evaluation">
                    <i class="bi bi-star"></i>
                </div>
                <div class="result-content">
                    <a href="${pageContext.request.contextPath}/evaluations/<%= evaluation.get("id") %>" class="result-title"><%= evaluation.get("courseName") %></a>
                    <div class="result-meta">
                        <div class="result-meta-item">
                            <i class="bi bi-person"></i>
                            <%= evaluation.get("professor") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-calendar3"></i>
                            <%= evaluation.get("semester") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-hand-thumbs-up"></i>
                            <%= evaluation.get("likes") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-person-circle"></i>
                            <%= evaluation.get("author") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-clock"></i>
                            <%= evaluation.get("date") %>
                        </div>
                    </div>
                    <p class="result-description"><%= evaluation.get("content") %></p>
                    <div class="star-rating">
                        <% double rating = (double) evaluation.get("rating"); %>
                        <% for (int j = 1; j <= 5; j++) { %>
                        <% if (j <= rating) { %>
                        <i class="bi bi-star-fill"></i>
                        <% } else if (j - 0.5 <= rating) { %>
                        <i class="bi bi-star-half"></i>
                        <% } else { %>
                        <i class="bi bi-star"></i>
                        <% } %>
                        <% } %>
                        <span class="ms-1"><%= rating %></span>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>

        <!-- 게시글 섹션 -->
        <% if (!postResults.isEmpty()) { %>
        <div class="section-header mt-4">
            <h3 class="section-title">게시글</h3>
            <a href="#" class="section-link" onclick="switchTab('posts')">더보기 <i class="bi bi-chevron-right"></i></a>
        </div>

        <div class="search-results">
            <% for (int i = 0; i < Math.min(2, postResults.size()); i++) { %>
            <% Map<String, Object> post = postResults.get(i); %>
            <div class="search-result-item">
                <div class="result-icon post">
                    <i class="bi bi-chat-dots"></i>
                </div>
                <div class="result-content">
                    <a href="${pageContext.request.contextPath}/community/post/<%= post.get("id") %>" class="result-title"><%= post.get("title") %></a>
                    <div class="result-meta">
                        <div class="result-meta-item">
                            <i class="bi bi-tag"></i>
                            <%= post.get("category") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-eye"></i>
                            <%= post.get("views") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-chat"></i>
                            <%= post.get("comments") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-hand-thumbs-up"></i>
                            <%= post.get("likes") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-person-circle"></i>
                            <%= post.get("author") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-clock"></i>
                            <%= post.get("date") %>
                        </div>
                    </div>
                    <p class="result-description"><%= post.get("content") %></p>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <!-- 강의 탭 내용 -->
    <div class="tab-content" id="tab-courses">
        <div class="search-results">
            <% if (courseResults.isEmpty()) { %>
            <div class="no-results">
                <i class="bi bi-search"></i>
                <h3>강의 검색 결과가 없습니다</h3>
                <p>다른 검색어로 시도해보세요.</p>
            </div>
            <% } else { %>
            <% for (Map<String, Object> course : courseResults) { %>
            <div class="search-result-item">
                <div class="result-icon course">
                    <i class="bi bi-book"></i>
                </div>
                <div class="result-content">
                    <a href="${pageContext.request.contextPath}/courses/<%= course.get("id") %>" class="result-title"><%= course.get("name") %></a>
                    <div class="result-meta">
                        <div class="result-meta-item">
                            <i class="bi bi-person"></i>
                            <%= course.get("professor") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-building"></i>
                            <%= course.get("department") %>
                        </div>
                    </div>
                    <div class="result-tags">
                        <% String[] tags = (String[]) course.get("tags"); %>
                        <% for (String tag : tags) { %>
                        <span class="result-tag"><%= tag %></span>
                        <% } %>
                    </div>
                </div>
                <div class="rating-badge">
                    <i class="bi bi-star-fill"></i>
                    <%= course.get("rating") %>
                </div>
            </div>
            <% } %>
            <% } %>
        </div>
    </div>

    <!-- 강의평가 탭 내용 -->
    <div class="tab-content" id="tab-evaluations">
        <div class="search-results">
            <% if (evaluationResults.isEmpty()) { %>
            <div class="no-results">
                <i class="bi bi-search"></i>
                <h3>강의평가 검색 결과가 없습니다</h3>
                <p>다른 검색어로 시도해보세요.</p>
            </div>
            <% } else { %>
            <% for (Map<String, Object> evaluation : evaluationResults) { %>
            <div class="search-result-item">
                <div class="result-icon evaluation">
                    <i class="bi bi-star"></i>
                </div>
                <div class="result-content">
                    <a href="${pageContext.request.contextPath}/evaluations/<%= evaluation.get("id") %>" class="result-title"><%= evaluation.get("courseName") %></a>
                    <div class="result-meta">
                        <div class="result-meta-item">
                            <i class="bi bi-person"></i>
                            <%= evaluation.get("professor") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-calendar3"></i>
                            <%= evaluation.get("semester") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-hand-thumbs-up"></i>
                            <%= evaluation.get("likes") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-person-circle"></i>
                            <%= evaluation.get("author") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-clock"></i>
                            <%= evaluation.get("date") %>
                        </div>
                    </div>
                    <p class="result-description"><%= evaluation.get("content") %></p>
                    <div class="star-rating">
                        <% double rating = (double) evaluation.get("rating"); %>
                        <% for (int j = 1; j <= 5; j++) { %>
                        <% if (j <= rating) { %>
                        <i class="bi bi-star-fill"></i>
                        <% } else if (j - 0.5 <= rating) { %>
                        <i class="bi bi-star-half"></i>
                        <% } else { %>
                        <i class="bi bi-star"></i>
                        <% } %>
                        <% } %>
                        <span class="ms-1"><%= rating %></span>
                    </div>
                </div>
            </div>
            <% } %>
            <% } %>
        </div>
    </div>

    <!-- 게시글 탭 내용 -->
    <div class="tab-content" id="tab-posts">
        <div class="search-results">
            <% if (postResults.isEmpty()) { %>
            <div class="no-results">
                <i class="bi bi-search"></i>
                <h3>게시글 검색 결과가 없습니다</h3>
                <p>다른 검색어로 시도해보세요.</p>
            </div>
            <% } else { %>
            <% for (Map<String, Object> post : postResults) { %>
            <div class="search-result-item">
                <div class="result-icon post">
                    <i class="bi bi-chat-dots"></i>
                </div>
                <div class="result-content">
                    <a href="${pageContext.request.contextPath}/community/post/<%= post.get("id") %>" class="result-title"><%= post.get("title") %></a>
                    <div class="result-meta">
                        <div class="result-meta-item">
                            <i class="bi bi-tag"></i>
                            <%= post.get("category") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-eye"></i>
                            <%= post.get("views") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-chat"></i>
                            <%= post.get("comments") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-hand-thumbs-up"></i>
                            <%= post.get("likes") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-person-circle"></i>
                            <%= post.get("author") %>
                        </div>
                        <div class="result-meta-item">
                            <i class="bi bi-clock"></i>
                            <%= post.get("date") %>
                        </div>
                    </div>
                    <p class="result-description"><%= post.get("content") %></p>
                </div>
            </div>
            <% } %>
            <% } %>
        </div>
    </div>
    <% } else { %>
    <!-- 검색 결과가 없는 경우 -->
    <div class="no-results">
        <i class="bi bi-search"></i>
        <h3>"<%= query %>"에 대한 검색 결과가 없습니다</h3>
        <p>다른 검색어로 시도하거나 철자를 확인해보세요.</p>
    </div>

    <!-- 검색 제안 -->
    <div class="search-suggestions">
        <h3 class="suggestions-title">인기 검색어</h3>
        <div class="suggestions-list">
            <% for (String suggestion : popularSearches) { %>
            <a href="${pageContext.request.contextPath}/search?query=<%= suggestion %>" class="suggestion-item"><%= suggestion %></a>
            <% } %>
        </div>
    </div>
    <% } %>
    <% } else { %>
    <!-- 검색어가 없는 경우 -->
    <div class="row">
        <div class="col-md-6">
            <!-- 최근 검색어 -->
            <div class="search-suggestions">
                <h3 class="suggestions-title">최근 검색어</h3>
                <div class="suggestions-list">
                    <% for (String search : recentSearches) { %>
                    <a href="${pageContext.request.contextPath}/search?query=<%= search %>" class="suggestion-item"><%= search %></a>
                    <% } %>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <!-- 인기 검색어 -->
            <div class="search-suggestions">
                <h3 class="suggestions-title">인기 검색어</h3>
                <div class="suggestions-list">
                    <% for (String suggestion : popularSearches) { %>
                    <a href="${pageContext.request.contextPath}/search?query=<%= suggestion %>" class="suggestion-item"><%= suggestion %></a>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
    <% } %>
</div>

<!-- 푸터 포함 -->
<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<!-- 부트스트랩 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

<!-- 커스텀 JS -->
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>

<!-- 검색 페이지 전용 스크립트 -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // 탭 전환 기능
        const tabs = document.querySelectorAll('.search-tab');
        const tabContents = document.querySelectorAll('.tab-content');

        tabs.forEach(tab => {
            tab.addEventListener('click', function() {
                const tabId = this.getAttribute('data-tab');
                switchTab(tabId);
            });
        });

        // 전역 함수로 탭 전환 함수 노출
        window.switchTab = function(tabId) {
            // 모든 탭 비활성화
            tabs.forEach(tab => {
                tab.classList.remove('active');
            });

            // 모든 탭 내용 숨기기
            tabContents.forEach(content => {
                content.classList.remove('active');
            });

            // 선택한 탭 활성화
            document.querySelector(`.search-tab[data-tab="${tabId}"]`).classList.add('active');

            // 선택한 탭 내용 표시
            document.getElementById(`tab-${tabId}`).classList.add('active');
        };

        // 검색어 입력 필드 포커스 시 전체 선택
        const searchInput = document.querySelector('.search-input');
        if (searchInput) {
            searchInput.addEventListener('focus', function() {
                this.select();
            });
        }
    });
</script>
</body>
</html>
