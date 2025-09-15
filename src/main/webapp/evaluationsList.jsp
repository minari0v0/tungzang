<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>강의평가 목록 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <script>
        // contextPath를 전역 변수로 설정
        window.contextPath = "${pageContext.request.contextPath}";
    </script>
    <%!
        // 영어 태그를 한글로 변환하는 함수
        public String translateTag(String tag) {
            if (tag == null) return "";

            switch (tag.toLowerCase()) {
                // 강의 유형
                case "major": return "전공필수";
                case "majorelective": return "전공선택";
                case "general": return "교양필수";
                case "generalelective": return "교양선택";
                case "other": return "기타";
                case "unknown": return "기타";

                // 기타 영어 태그들
                case "teamproject": return "팀프로젝트";
                case "presentation": return "발표수업";
                case "discussion": return "토론수업";
                case "practice": return "실습위주";
                case "theory": return "이론위주";
                case "memorization": return "암기과목";
                case "midterm": return "중간고사";
                case "final": return "기말고사";
                case "quiz": return "퀴즈있음";
                case "assignment": return "과제많음";
                case "report": return "레포트";
                case "noexam": return "시험없음";
                case "openbook": return "오픈북";
                case "interesting": return "재미있는";
                case "useful": return "유익한";
                case "boring": return "지루한";
                case "strict": return "엄격한";
                case "free": return "자유로운";
                case "attendance": return "출석중요";

                default: return tag; // 매핑되지 않은 경우 원본 반환
            }
        }
    %>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container py-5">
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center mb-4">
        <div>
            <h1 class="mb-1">강의평가 목록</h1>
            <p class="text-muted">학생들이 작성한 다양한 강의평가를 확인해보세요</p>
        </div>
        <c:if test="${isLoggedIn}">
            <a href="${pageContext.request.contextPath}/evaluations/write" class="btn btn-primary evaluation-write-btn">
                <i class="bi bi-pencil-fill me-2"></i>강의평가 작성
            </a>
        </c:if>
        <c:if test="${!isLoggedIn}">
            <button onclick="openLoginModal('evaluations/write')" class="btn btn-primary evaluation-write-btn">
                <i class="bi bi-pencil-fill me-2"></i>강의평가 작성
            </button>
        </c:if>
    </div>

    <div class="card mb-4 evaluations-search-form">
        <div class="card-header">
            <h5 class="card-title mb-0">강의평가 검색</h5>
            <p class="card-text text-muted small">강의명, 교수명, 평가 내용으로 검색하세요</p>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/evaluationsList" method="get" class="row g-3">
                <div class="col-md-6">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="search" class="form-control" name="search" placeholder="강의명, 교수명 또는 평가 내용으로 검색..." value="${param.search}">
                    </div>
                </div>
                <div class="col-md-3">
                    <select class="form-select" name="filter">
                        <option value="all" ${param.filter == 'all' || empty param.filter ? 'selected' : ''}>전체 유형</option>
                        <option value="major" ${param.filter == 'major' ? 'selected' : ''}>전공</option>
                        <option value="general" ${param.filter == 'general' ? 'selected' : ''}>교양</option>
                        <option value="other" ${param.filter == 'other' ? 'selected' : ''}>기타</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <select class="form-select" name="sortBy">
                        <option value="recent" ${param.sortBy == 'recent' || empty param.sortBy ? 'selected' : ''}>최신순</option>
                        <option value="rating-high" ${param.sortBy == 'rating-high' ? 'selected' : ''}>평점 높은순</option>
                        <option value="rating-low" ${param.sortBy == 'rating-low' ? 'selected' : ''}>평점 낮은순</option>
                        <option value="likes" ${param.sortBy == 'likes' ? 'selected' : ''}>좋아요 많은순</option>
                    </select>
                </div>
                <div class="col-12">
                    <button type="submit" class="btn btn-primary">검색</button>
                    <a href="${pageContext.request.contextPath}/evaluationsList" class="btn btn-outline-secondary">초기화</a>
                </div>
            </form>
        </div>
    </div>

    <div class="row g-4 evaluations-grid">
        <c:if test="${empty evaluations}">
            <div class="col-12 empty-state">
                <i class="bi bi-chat-square-text fs-1 mb-3"></i>
                <h3 class="mb-3">등록된 강의평가가 없습니다</h3>
                <p class="mb-4">첫 번째 강의평가를 작성해보세요!</p>
                <c:if test="${isLoggedIn}">
                    <a href="${pageContext.request.contextPath}/evaluations/write" class="btn btn-primary">강의평가 작성하기</a>
                </c:if>
                <c:if test="${!isLoggedIn}">
                    <button onclick="openLoginModal('evaluations/write')" class="btn btn-primary">강의평가 작성하기</button>
                </c:if>
            </div>
        </c:if>

        <c:forEach var="evaluation" items="${evaluations}">
            <div class="col-md-6 col-lg-4">
                <div class="card h-100 course-card evaluation-card">
                    <div class="card-header">
                        <div class="d-flex justify-content-between align-items-start">
                            <div class="flex-grow-1">
                                <h5 class="card-title mb-1">${evaluation.courseName}</h5>
                                <p class="text-muted small mb-0">${evaluation.professor}</p>
                            </div>
                            <div class="rating-badge">
                                <i class="bi bi-star-fill text-warning me-1"></i>
                                <span class="fw-bold">${evaluation.rating}</span>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="d-flex align-items-center mb-2">
                            <div class="avatar me-2">
                                    ${evaluation.authorInitial}
                            </div>
                            <div>
                                <small class="text-muted">${evaluation.authorName}</small>
                                <br>
                                <small class="text-muted">${evaluation.semester}</small>
                            </div>
                        </div>

                        <h6 class="evaluation-title mb-2">${evaluation.title}</h6>

                        <div class="evaluation-content mb-3">
                            <c:choose>
                                <c:when test="${fn:length(evaluation.comment) > 100}">
                                    <p class="small text-muted mb-0">${fn:substring(evaluation.comment, 0, 100)}...</p>
                                </c:when>
                                <c:otherwise>
                                    <p class="small text-muted mb-0">${evaluation.comment}</p>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="d-flex flex-wrap gap-1 mb-3">
  <span class="badge course-tag">
    <c:choose>
        <c:when test="${evaluation.courseType == 'major'}">전공필수</c:when>
        <c:when test="${evaluation.courseType == 'majorElective'}">전공선택</c:when>
        <c:when test="${evaluation.courseType == 'general'}">교양필수</c:when>
        <c:when test="${evaluation.courseType == 'generalElective'}">교양선택</c:when>
        <c:when test="${evaluation.courseType == 'other'}">기타</c:when>
        <c:otherwise>${evaluation.courseType}</c:otherwise>
    </c:choose>
  </span>
                            <c:forEach var="feature" items="${evaluation.features}">
    <span class="badge course-tag">
      <c:choose>
          <c:when test="${feature == 'teamProject'}">팀프로젝트</c:when>
          <c:when test="${feature == 'presentation'}">발표수업</c:when>
          <c:when test="${feature == 'discussion'}">토론수업</c:when>
          <c:when test="${feature == 'practice'}">실습위주</c:when>
          <c:when test="${feature == 'theory'}">이론위주</c:when>
          <c:when test="${feature == 'memorization'}">암기과목</c:when>
          <c:when test="${feature == 'assignment'}">과제많음</c:when>
          <c:when test="${feature == 'report'}">레포트</c:when>
          <c:when test="${feature == 'noexam'}">시험없음</c:when>
          <c:when test="${feature == 'interesting'}">재미있는</c:when>
          <c:when test="${feature == 'useful'}">유익한</c:when>
          <c:when test="${feature == 'boring'}">지루한</c:when>
          <c:when test="${feature == 'strict'}">엄격한</c:when>
          <c:when test="${feature == 'attendance'}">출석중요</c:when>
          <c:otherwise>${feature}</c:otherwise>
      </c:choose>
    </span>
                            </c:forEach>
                        </div>

                        <div class="row text-center course-stats">
                            <div class="col-4">
                                <div class="stat-box">
                                    <p class="small text-muted mb-0">난이도</p>
                                    <p class="fw-bold mb-0">${evaluation.difficulty}</p>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="stat-box">
                                    <p class="small text-muted mb-0">과제량</p>
                                    <p class="fw-bold mb-0">${evaluation.homework}</p>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="stat-box">
                                    <p class="small text-muted mb-0">좋아요</p>
                                    <p class="fw-bold mb-0">${evaluation.likes}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer d-flex justify-content-between align-items-center">
                        <div class="d-flex align-items-center text-muted small">
                            <i class="bi bi-calendar me-1"></i>
                            <span>${evaluation.formattedDate}</span>
                        </div>
                        <div class="d-flex gap-2">
                            <button class="btn btn-sm btn-outline-primary like-btn" data-evaluation-id="${evaluation.id}">
                                <i class="bi bi-heart"></i>
                                <span class="like-count">${evaluation.likes}</span>
                            </button>
                            <a href="${pageContext.request.contextPath}/evaluations/course/${evaluation.courseId}" class="btn btn-sm btn-outline-primary view-btn">
                                상세보기
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <c:if test="${not empty evaluations}">
        <div class="d-flex justify-content-center mt-4">
            <nav aria-label="강의평가 목록 페이지네이션">
                <ul class="pagination">
                    <li class="page-item">
                        <a class="page-link" href="#" aria-label="이전">
                            <span aria-hidden="true">&laquo;</span>
                        </a>
                    </li>
                    <li class="page-item active"><a class="page-link" href="#">1</a></li>
                    <li class="page-item"><a class="page-link" href="#">2</a></li>
                    <li class="page-item"><a class="page-link" href="#">3</a></li>
                    <li class="page-item">
                        <a class="page-link" href="#" aria-label="다음">
                            <span aria-hidden="true">&raquo;</span>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>
<script>
    // 강의평가 목록 페이지 전용 스크립트
    document.addEventListener('DOMContentLoaded', function() {
        // 좋아요 버튼 클릭 이벤트
        const likeButtons = document.querySelectorAll('.like-btn');
        likeButtons.forEach(button => {
            button.addEventListener('click', function() {
                const evaluationId = this.getAttribute('data-evaluation-id');
                const likeCountSpan = this.querySelector('.like-count');
                const heartIcon = this.querySelector('i');

                // 로그인 확인
                <c:if test="${!isLoggedIn}">
                openLoginModal('evaluationsList');
                return;
                </c:if>

                // 좋아요 토글 (실제 구현 시 서버와 통신)
                const currentCount = parseInt(likeCountSpan.textContent);
                const isLiked = heartIcon.classList.contains('bi-heart-fill');

                if (isLiked) {
                    heartIcon.classList.remove('bi-heart-fill');
                    heartIcon.classList.add('bi-heart');
                    likeCountSpan.textContent = currentCount - 1;
                    this.classList.remove('btn-primary');
                    this.classList.add('btn-outline-primary');
                } else {
                    heartIcon.classList.remove('bi-heart');
                    heartIcon.classList.add('bi-heart-fill');
                    likeCountSpan.textContent = currentCount + 1;
                    this.classList.remove('btn-outline-primary');
                    this.classList.add('btn-primary');
                }
            });
        });

        // 정렬 변경 시 자동 제출
        const sortSelect = document.querySelector('select[name="sortBy"]');
        if (sortSelect) {
            sortSelect.addEventListener('change', function() {
                this.form.submit();
            });
        }

        // 필터 변경 시 자동 제출
        const filterSelect = document.querySelector('select[name="filter"]');
        if (filterSelect) {
            filterSelect.addEventListener('change', function() {
                this.form.submit();
            });
        }
    });
</script>
</body>
</html>
