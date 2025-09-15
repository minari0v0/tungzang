<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>강의 선택 - 텅장수강러</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login-modal.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
</head>
<body>
<!-- 헤더 포함 -->
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container py-5">
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center mb-4">
        <div>
            <h1 class="mb-1">강의평가 작성</h1>
            <p class="text-muted">시간표에 등록된 강의 중 평가할 강의를 선택하세요.</p>
        </div>
        <a href="${pageContext.request.contextPath}/timetable" class="btn btn-outline-primary">
            <i class="bi bi-calendar-week me-2"></i>시간표로 돌아가기
        </a>
    </div>

    <!-- 검색 기능 -->
    <div class="search-container">
        <div class="input-group">
      <span class="input-group-text">
        <i class="bi bi-search"></i>
      </span>
            <input type="text" id="searchInput" class="form-control" placeholder="강의명 또는 교수명 검색...">
        </div>
    </div>

    <!-- 강의 목록 -->
    <div class="course-container">
        <c:forEach var="course" items="${courses}">
            <div class="course-item">
                <div class="card course-card">
                    <div class="card-body">
                        <h5 class="card-title" title="${course.name}">${course.name}</h5>
                        <h6 class="card-subtitle" title="${course.professor} 교수님">${course.professor} 교수님</h6>
                        <p class="card-text">
                            <span class="badge course-tag">${course.department}</span>
                        </p>
                    </div>
                    <div class="card-footer">
                        <a href="${pageContext.request.contextPath}/evaluations/course/${course.id}" class="btn btn-primary w-100">
                            <i class="bi bi-pencil-fill me-1"></i> 이 강의 평가하기
                        </a>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- 강의가 없을 경우 메시지 표시 -->
    <c:if test="${empty courses}">
        <div class="empty-state">
            <i class="bi bi-calendar-x fs-1 mb-3"></i>
            <h3 class="mb-3">시간표에 등록된 강의가 없습니다</h3>
            <p class="mb-4">시간표에 강의를 추가한 후 다시 시도해주세요.</p>
            <a href="${pageContext.request.contextPath}/timetable" class="btn btn-primary">
                <i class="bi bi-plus-circle me-1"></i> 시간표에 강의 추가하기
            </a>
        </div>
    </c:if>
</div>

<!-- 푸터 포함 -->
<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>

<!-- 검색 기능 스크립트 -->
<script>
    document.getElementById('searchInput').addEventListener('input', function() {
        const searchText = this.value.toLowerCase();
        const courseItems = document.querySelectorAll('.course-item');

        courseItems.forEach(function(item) {
            const title = item.querySelector('.card-title').textContent.toLowerCase();
            const professor = item.querySelector('.card-subtitle').textContent.toLowerCase();

            if (title.includes(searchText) || professor.includes(searchText)) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    });
</script>
</body>
</html>
