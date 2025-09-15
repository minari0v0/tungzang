<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>커뮤니티 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login-modal.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="mb-1">커뮤니티</h1>
            <p class="text-muted">다른 학생들과 정보를 공유하고 소통하세요</p>
        </div>
        <c:choose>
            <c:when test="${sessionScope.user != null}">
                <a href="${pageContext.request.contextPath}/community/write" class="btn btn-primary btn-write">
                    <i class="bi bi-pencil-fill me-2"></i>글 작성하기
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/login?redirect=community/write" class="btn btn-primary btn-write">
                    <i class="bi bi-pencil-fill me-2"></i>글 작성하기
                </a>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- 카테고리 탭 -->
    <ul class="nav nav-tabs mb-4">
        <li class="nav-item">
            <a class="nav-link ${category == null || category == 'all' ? 'active' : ''}" href="${pageContext.request.contextPath}/community">전체</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${category == 'notice' ? 'active' : ''}" href="${pageContext.request.contextPath}/community?category=notice">공지사항</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${category == 'free' ? 'active' : ''}" href="${pageContext.request.contextPath}/community?category=free">자유게시판</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${category == 'question' ? 'active' : ''}" href="${pageContext.request.contextPath}/community?category=question">질문게시판</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${category == 'info' ? 'active' : ''}" href="${pageContext.request.contextPath}/community?category=info">정보공유</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${category == 'study' ? 'active' : ''}" href="${pageContext.request.contextPath}/community?category=study">스터디</a>
        </li>
    </ul>

    <!-- 검색 폼 -->
    <div class="row mb-4">
        <div class="col-md-6">
            <form action="${pageContext.request.contextPath}/community" method="get" class="search-form">
                <i class="bi bi-search"></i>
                <input type="text" name="keyword" class="form-control search-input" placeholder="검색어를 입력하세요" value="${param.keyword}">
                <input type="hidden" name="category" value="${category}">
            </form>
        </div>
    </div>

    <!-- 게시글 목록 -->
    <div class="card mb-4">
        <div class="card-body">
            <c:if test="${empty posts}">
                <div class="text-center py-5">
                    <i class="bi bi-clipboard-x" style="font-size: 3rem; color: #d1d5db;"></i>
                    <p class="mt-3 text-muted">게시글이 없습니다.</p>
                </div>
            </c:if>

            <c:forEach var="post" items="${posts}" varStatus="status">
                <div class="post-item ${status.index > 0 ? 'border-top pt-4 mt-4' : ''}">
                    <div class="d-flex align-items-center mb-2">
                        <c:choose>
                            <c:when test="${post.likes >= 25}">
                                <span class="badge badge-hot me-2">인기</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-category me-2">${post.category}</span>
                            </c:otherwise>
                        </c:choose>
                        <span class="post-meta">${post.authorName} · <fmt:formatDate value="${post.date}" pattern="yyyy-MM-dd" /></span>
                    </div>

                    <h5 class="mb-2">
                        <a href="${pageContext.request.contextPath}/community/post/${post.id}" class="post-title">
                                ${post.title}
                            <c:if test="${post.commentCount > 0}">
                                <span class="text-primary">[${post.commentCount}]</span>
                            </c:if>
                        </a>
                    </h5>

                    <p class="text-muted mb-3 text-truncate">${post.content}</p>

                    <div class="post-stats">
                        <span><i class="bi bi-hand-thumbs-up"></i>${post.likes}</span>
                        <span><i class="bi bi-chat-dots"></i>${post.commentCount}</span>
                        <span><i class="bi bi-eye"></i>${post.views}</span>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- 페이지네이션 -->
    <nav aria-label="Page navigation">
        <ul class="pagination justify-content-center">
            <c:if test="${currentPage > 1}">
                <li class="page-item">
                    <a class="page-link" href="${pageContext.request.contextPath}/community?page=${currentPage - 1}${not empty category ? '&category='.concat(category) : ''}${not empty param.keyword ? '&keyword='.concat(param.keyword) : ''}" aria-label="Previous">
                        <span aria-hidden="true">&laquo;</span>
                    </a>
                </li>
            </c:if>

            <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${currentPage == i ? 'active' : ''}">
                    <a class="page-link" href="${pageContext.request.contextPath}/community?page=${i}${not empty category ? '&category='.concat(category) : ''}${not empty param.keyword ? '&keyword='.concat(param.keyword) : ''}">${i}</a>
                </li>
            </c:forEach>

            <c:if test="${currentPage < totalPages}">
                <li class="page-item">
                    <a class="page-link" href="${pageContext.request.contextPath}/community?page=${currentPage + 1}${not empty category ? '&category='.concat(category) : ''}${not empty param.keyword ? '&keyword='.concat(param.keyword) : ''}" aria-label="Next">
                        <span aria-hidden="true">&raquo;</span>
                    </a>
                </li>
            </c:if>
        </ul>
    </nav>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>
</body>
</html>
