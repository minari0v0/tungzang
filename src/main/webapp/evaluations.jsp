<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>강의 목록 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login-modal.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container py-5">
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center mb-4">
        <div>
            <h1 class="mb-1">강의 목록</h1>
            <p class="text-muted">모든 강의에 대한 평가를 확인해보세요</p>
        </div>
        <a href="${pageContext.request.contextPath}/evaluations/write" class="btn btn-primary evaluation-write-btn">
            <i class="bi bi-pencil-fill me-2"></i>강의평가 작성
        </a>
    </div>

    <div class="card mb-4 evaluations-search-form">
        <div class="card-header">
            <h5 class="card-title mb-0">강의 검색</h5>
            <p class="card-text text-muted small">강의명, 교수명, 학과 등으로 검색하세요</p>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/evaluations" method="get" class="row g-3">
                <div class="col-md-6">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="search" class="form-control" name="search" placeholder="강의명 또는 교수명으로 검색..." value="${param.search}">
                    </div>
                </div>
                <div class="col-md-3">
                    <select class="form-select" name="department">
                        <option value="all" ${param.department == 'all' || empty param.department ? 'selected' : ''}>전체 학과</option>
                        <option value="cs" ${param.department == 'cs' ? 'selected' : ''}>컴퓨터공학과</option>
                        <option value="business" ${param.department == 'business' ? 'selected' : ''}>경영학과</option>
                        <option value="psychology" ${param.department == 'psychology' ? 'selected' : ''}>심리학과</option>
                        <option value="electronics" ${param.department == 'electronics' ? 'selected' : ''}>전자공학과</option>
                        <option value="math" ${param.department == 'math' ? 'selected' : ''}>수학과</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <select class="form-select" name="sortBy">
                        <option value="recent" ${param.sortBy == 'recent' || empty param.sortBy ? 'selected' : ''}>최신순</option>
                        <option value="rating-high" ${param.sortBy == 'rating-high' ? 'selected' : ''}>평점 높은순</option>
                        <option value="rating-low" ${param.sortBy == 'rating-low' ? 'selected' : ''}>평점 낮은순</option>
                        <option value="reviews" ${param.sortBy == 'reviews' ? 'selected' : ''}>리뷰 많은순</option>
                    </select>
                </div>
                <div class="col-12">
                    <button type="submit" class="btn btn-primary">검색</button>
                    <a href="${pageContext.request.contextPath}/evaluations" class="btn btn-outline-secondary">초기화</a>
                </div>
            </form>
        </div>
    </div>

    <ul class="nav nav-tabs evaluations-tabs mb-4">
        <li class="nav-item">
            <a class="nav-link ${param.filter == 'all' || empty param.filter ? 'active' : ''}" href="${pageContext.request.contextPath}/evaluations?filter=all">전체 강의</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.filter == 'major' ? 'active' : ''}" href="${pageContext.request.contextPath}/evaluations?filter=major">전공 강의</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.filter == 'general' ? 'active' : ''}" href="${pageContext.request.contextPath}/evaluations?filter=general">교양 강의</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.filter == 'other' ? 'active' : ''}" href="${pageContext.request.contextPath}/evaluations?filter=other">기타 강의</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.filter == 'popular' ? 'active' : ''}" href="${pageContext.request.contextPath}/evaluations?filter=popular">인기 강의</a>
        </li>
    </ul>

    <div class="row g-4 evaluations-grid">
        <c:if test="${empty courses}">
            <div class="col-12 empty-state">
                <i class="bi bi-search fs-1 mb-3"></i>
                <h3 class="mb-3">검색 결과가 없습니다</h3>
                <p class="mb-4">검색어나 필터를 변경해보세요</p>
                <a href="${pageContext.request.contextPath}/evaluations" class="btn btn-outline-primary">필터 초기화</a>
            </div>
        </c:if>

        <c:forEach var="course" items="${courses}">
            <div class="col-md-6 col-lg-4">
                <div class="card h-100 course-card">
                    <div class="card-header">
                        <div class="d-flex justify-content-between align-items-start">
                            <h5 class="card-title mb-0">${course.name}</h5>
                            <div class="rating-badge">
                                <i class="bi bi-star-fill text-warning me-1"></i>
                                <span class="fw-bold">${course.rating}</span>
                            </div>
                        </div>
                        <p class="text-muted small">${course.professor} · ${course.department}</p>
                    </div>
                    <div class="card-body">
                        <div class="d-flex flex-wrap gap-1 mb-3 course-tags">
                            <c:forEach var="tag" items="${course.tags}">
                                <span class="badge course-tag">${tag}</span>
                            </c:forEach>
                        </div>
                        <div class="row text-center course-stats">
                            <div class="col-4">
                                <div class="stat-box">
                                    <p class="small text-muted mb-0">난이도</p>
                                    <p class="fw-bold mb-0">${course.difficulty}</p>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="stat-box">
                                    <p class="small text-muted mb-0">과제</p>
                                    <p class="fw-bold mb-0">${course.homework}</p>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="stat-box">
                                    <p class="small text-muted mb-0">시험</p>
                                    <p class="fw-bold mb-0">${course.examCount}회</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer d-flex justify-content-between align-items-center">
                        <div class="d-flex align-items-center text-muted small">
                            <i class="bi bi-chat me-1"></i>
                            <span>평가 ${course.evaluationCount}개</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/evaluations/course/${course.id}" class="btn btn-sm btn-outline-primary view-btn">평가 보기</a>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>
<script>
    // 스크롤 위치 저장 및 복원 기능
    document.addEventListener('DOMContentLoaded', function() {
        // 페이지 로드 시 저장된 스크롤 위치로 이동
        const savedScrollPosition = sessionStorage.getItem('evaluationsScrollPosition');
        if (savedScrollPosition) {
            window.scrollTo(0, parseInt(savedScrollPosition));
        }

        // 검색 폼 제출 시 현재 스크롤 위치 저장
        const searchForm = document.querySelector('.evaluations-search-form form');
        if (searchForm) {
            searchForm.addEventListener('submit', function() {
                sessionStorage.setItem('evaluationsScrollPosition', window.scrollY);
            });
        }

        // 탭 클릭 시 현재 스크롤 위치 저장
        const tabLinks = document.querySelectorAll('.evaluations-tabs .nav-link');
        tabLinks.forEach(link => {
            link.addEventListener('click', function() {
                sessionStorage.setItem('evaluationsScrollPosition', window.scrollY);
            });
        });

        // 정렬 변경 시 현재 스크롤 위치 저장
        const sortSelect = document.querySelector('select[name="sortBy"]');
        if (sortSelect) {
            sortSelect.addEventListener('change', function() {
                sessionStorage.setItem('evaluationsScrollPosition', window.scrollY);
                this.form.submit();
            });
        }

        // 학과 필터 변경 시 현재 스크롤 위치 저장
        const departmentSelect = document.querySelector('select[name="department"]');
        if (departmentSelect) {
            departmentSelect.addEventListener('change', function() {
                sessionStorage.setItem('evaluationsScrollPosition', window.scrollY);
                this.form.submit();
            });
        }
    });
</script>
</body>
</html>
