<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시글 작성 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <style>
        .card {
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        .btn-back {
            display: flex;
            align-items: center;
            gap: 5px;
            margin-bottom: 20px;
            color: #4b5563;
            text-decoration: none;
        }
        .btn-back:hover {
            color: #4f46e5;
        }
        .form-control:focus, .form-select:focus {
            border-color: #4f46e5;
            box-shadow: 0 0 0 0.25rem rgba(79, 70, 229, 0.25);
        }
        .btn-submit {
            background-color: #4f46e5;
            border-color: #4f46e5;
        }
        .btn-submit:hover {
            background-color: #4338ca;
            border-color: #4338ca;
        }
        .form-label {
            font-weight: 500;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container py-5">
    <a href="${pageContext.request.contextPath}/community" class="btn-back">
        <i class="bi bi-arrow-left"></i> 커뮤니티로 돌아가기
    </a>

    <div class="card">
        <div class="card-header bg-white">
            <h2 class="card-title h5 mb-0">게시글 작성</h2>
        </div>
        <div class="card-body">
            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/community/write" method="post">
                <div class="mb-3">
                    <label for="category" class="form-label">카테고리</label>
                    <select class="form-select" id="category" name="category" required>
                        <option value="" selected disabled>카테고리 선택</option>
                        <option value="notice">공지사항</option>
                        <option value="free">자유게시판</option>
                        <option value="question">질문게시판</option>
                        <option value="info">정보공유</option>
                        <option value="study">스터디</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label for="title" class="form-label">제목</label>
                    <input type="text" class="form-control" id="title" name="title" placeholder="제목을 입력하세요" required>
                </div>
                <div class="mb-3">
                    <label for="content" class="form-label">내용</label>
                    <textarea class="form-control" id="content" name="content" rows="15" placeholder="내용을 입력하세요" required></textarea>
                </div>
                <div class="d-flex justify-content-between">
                    <a href="${pageContext.request.contextPath}/community" class="btn btn-secondary">취소</a>
                    <button type="submit" class="btn btn-primary btn-submit">등록</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>
</body>
</html>
