<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.minari.tungzang.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>텅장수강러 - 대학생활의 필수 파트너</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">

    <!-- CTA 섹션 전용 스타일 -->
    <style>
        .cta-section {
            background-color: var(--white);
            color: var(--text-color);
            transition: var(--transition);
        }

        .dark-mode .cta-section {
            background-color: var(--dark-bg);
            color: var(--text-color);
        }

        .cta-title {
            color: var(--text-color);
        }

        .cta-description {
            color: var(--text-light);
        }

        .cta-btn-primary {
            background: var(--gradient);
            color: white;
            border: none;
            transition: var(--transition);
        }

        .cta-btn-primary:hover {
            background: var(--gradient-hover);
            color: white;
            box-shadow: var(--shadow-hover);
            transform: translateY(-2px);
        }

        .cta-btn-outline {
            background: transparent;
            color: var(--primary-color);
            border: 2px solid var(--primary-color);
            transition: var(--transition);
        }

        .cta-btn-outline:hover {
            background: var(--primary-color);
            color: white;
            transform: translateY(-2px);
        }

        .dark-mode .cta-btn-outline {
            color: var(--primary-light);
            border-color: var(--primary-light);
        }

        .dark-mode .cta-btn-outline:hover {
            background: var(--primary-light);
            color: var(--dark-bg);
        }

        /* 최근 데이터 섹션 다크모드 배경색 */
        .bg-light {
            background-color: #f8f9fa !important;
        }

        .dark-mode .bg-light {
            background-color: #0f1729 !important;
        }
    </style>
</head>
<body>
<!-- 헤더 포함 -->
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<!-- 히어로 섹션 -->
<section class="hero-section">
    <div class="container text-center">
        <h1 class="hero-title">대학생활의 필수 파트너, <span class="highlight">텅장수강러</span></h1>
        <p class="hero-subtitle">강의 평가를 확인하고, 시간표를 관리하고, 다른 학생들과 소통하세요.<br>현명한 수강신청으로 대학생활을 더 즐겁게 만들어보세요.</p>
        <div class="hero-btn-container">
            <a href="${pageContext.request.contextPath}/timetable" class="hero-btn">시간표 관리</a>
            <a href="${pageContext.request.contextPath}/evaluations" class="hero-btn outline">강의 평가</a>
        </div>
    </div>
</section>

<!-- 서비스 섹션 -->
<section class="services-section">
    <div class="container">
        <h2 class="section-title">텅장수강러가 제공하는 서비스</h2>
        <div class="row g-4">
            <!-- 실시간 강의 평가 -->
            <div class="col-md-4">
                <div class="service-card">
                    <div class="service-icon">
                        <i class="bi bi-star"></i>
                    </div>
                    <h3 class="service-title">실시간 강의 평가</h3>
                    <p class="service-description">선배들의 생생한 강의 후기를 통해 강의의 질과 난이도를 미리 확인하세요.</p>
                    <a href="${pageContext.request.contextPath}/evaluationsList" class="service-link">
                        더 알아보기 <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
            </div>

            <!-- 시간표 관리 -->
            <div class="col-md-4">
                <div class="service-card">
                    <div class="service-icon">
                        <i class="bi bi-calendar3"></i>
                    </div>
                    <h3 class="service-title">시간표 관리</h3>
                    <p class="service-description">드래그 앤 드롭으로 간편하게 시간표를 만들고 관리하세요. 시간 충돌을 자동으로 감지합니다.</p>
                    <a href="${pageContext.request.contextPath}/timetable" class="service-link">
                        더 알아보기 <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
            </div>

            <!-- 학생 커뮤니티 -->
            <div class="col-md-4">
                <div class="service-card">
                    <div class="service-icon">
                        <i class="bi bi-chat-dots"></i>
                    </div>
                    <h3 class="service-title">학생 커뮤니티</h3>
                    <p class="service-description">같은 학교, 같은 전공의 학생들과 정보를 공유하고 소통하세요.</p>
                    <a href="${pageContext.request.contextPath}/community" class="service-link">
                        더 알아보기 <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- 최근 데이터 섹션 -->
<section class="py-5 bg-light">
    <div class="container">
        <div class="row g-4">
            <!-- 최근 강의 평가 -->
            <div class="col-md-4">
                <div class="card h-100">
                    <div class="card-header-purple card-header-evaluation">
                        <h5>최근 강의 평가</h5>
                    </div>
                    <div class="card-body card-body-custom">
                        <c:if test="${empty recentEvaluations}">
                            <p class="text-center text-muted">등록된 강의 평가가 없습니다.</p>
                        </c:if>
                        <c:forEach var="evaluation" items="${recentEvaluations}">
                            <div class="border-bottom pb-3 mb-3">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <div>
                                        <h6 class="mb-0">${evaluation.courseName}</h6>
                                        <p class="text-muted small">${evaluation.professor}</p>
                                    </div>
                                    <span class="badge bg-primary">${evaluation.rating}.0점</span>
                                </div>
                                <p class="small mb-2 text-truncate">${evaluation.comment}</p>
                                <div class="d-flex justify-content-between align-items-center small text-muted">
                                    <span>${evaluation.userName}</span>
                                    <span>${evaluation.date}</span>
                                </div>
                            </div>
                        </c:forEach>
                        <a href="${pageContext.request.contextPath}/evaluationsList" class="service-link mt-3">
                            더 보기 <i class="bi bi-arrow-right"></i>
                        </a>
                    </div>
                </div>
            </div>

            <!-- 인기 강의 -->
            <div class="col-md-4">
                <div class="card h-100">
                    <div class="card-header-purple card-header-popular">
                        <h5>인기 강의</h5>
                    </div>
                    <div class="card-body card-body-custom">
                        <c:if test="${empty popularCourses}">
                            <p class="text-center text-muted">등록된 강의가 없습니다.</p>
                        </c:if>
                        <c:forEach var="course" items="${popularCourses}">
                            <div class="d-flex justify-content-between align-items-center p-2 border-bottom">
                                <div>
                                    <h6 class="mb-0">${course.name}</h6>
                                    <p class="text-muted small mb-0">${course.professor} · ${course.department}</p>
                                </div>
                                <div class="d-flex align-items-center">
                                    <i class="bi bi-star-fill text-warning me-1"></i>
                                    <span class="fw-bold">${course.rating}</span>
                                    <span class="text-muted small ms-1">(${course.evaluationCount})</span>
                                </div>
                            </div>
                        </c:forEach>
                        <a href="${pageContext.request.contextPath}/evaluations" class="service-link mt-3">
                            모든 강의 보기 <i class="bi bi-arrow-right"></i>
                        </a>
                    </div>
                </div>
            </div>

            <!-- 인기 게시글 -->
            <div class="col-md-4">
                <div class="card h-100">
                    <div class="card-header-purple card-header-posts">
                        <h5>인기 게시글</h5>
                    </div>
                    <div class="card-body card-body-custom">
                        <c:if test="${empty hotPosts}">
                            <p class="text-center text-muted">등록된 게시글이 없습니다.</p>
                        </c:if>
                        <c:forEach var="post" items="${hotPosts}">
                            <div class="border-bottom pb-3 mb-3">
                                <div class="d-flex align-items-center gap-2 mb-1">
                                    <span class="badge bg-primary">${post.category}</span>
                                    <span class="text-muted small">${post.authorName}</span>
                                </div>
                                <h6 class="mb-2 text-truncate">
                                    <a href="${pageContext.request.contextPath}/community/post/${post.id}" class="text-decoration-none">${post.title}</a>
                                </h6>
                                <div class="d-flex align-items-center text-muted small gap-3">
                                    <div class="d-flex align-items-center">
                                        <i class="bi bi-hand-thumbs-up me-1"></i>
                                        <span>${post.likes}</span>
                                    </div>
                                    <div class="d-flex align-items-center">
                                        <i class="bi bi-chat me-1"></i>
                                        <span>${post.commentCount}</span>
                                    </div>
                                    <span>${post.date}</span>
                                </div>
                            </div>
                        </c:forEach>
                        <a href="${pageContext.request.contextPath}/community" class="service-link mt-3">
                            커뮤니티 방문 <i class="bi bi-arrow-right"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Call to Action 섹션 -->
<section class="py-5 cta-section">
    <div class="container py-4 text-center">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <%
                    User user = (User) session.getAttribute("user");
                %>
                <% if (user == null) { %>
                <!-- 로그인하지 않은 사용자 -->
                <h2 class="cta-title mb-4 fw-bold">텅장수강러와 함께 현명한 대학생활을 시작하세요</h2>
                <p class="cta-description mb-4 fs-5">
                    수강신청 고민은 이제 그만! 선배들의 생생한 후기와 함께<br>
                    완벽한 시간표를 만들어보세요. 지금 가입하고 대학생활의 새로운 차원을 경험하세요!
                </p>
                <a href="${pageContext.request.contextPath}/register.jsp" class="btn cta-btn-primary btn-lg px-5 py-3 fw-bold">
                    <i class="bi bi-rocket-takeoff me-2"></i>지금 시작하기
                </a>
                <% } else { %>
                <!-- 로그인한 사용자 -->
                <h2 class="cta-title mb-4 fw-bold">이미 회원님은 텅장수강러들과 함께 대학 여정에 빠져들었습니다!</h2>
                <p class="cta-description mb-4 fs-5">
                    🎉 환영합니다, <%= user.getName() %>님! 텅장수강러의 일원이 되신 것을 축하합니다!<br>
                    오늘도 꿀강의 찾기와 시간표 완성에 도전해보세요. 학점은 올리고 스트레스는 내리는 마법이 시작됩니다! ✨
                </p>
                <div class="d-flex gap-3 justify-content-center flex-wrap">
                    <a href="${pageContext.request.contextPath}/timetable" class="btn cta-btn-primary btn-lg px-4 py-3 fw-bold">
                        <i class="bi bi-calendar-check me-2"></i>내 시간표 보기
                    </a>
                    <a href="${pageContext.request.contextPath}/evaluationsList" class="btn cta-btn-outline btn-lg px-4 py-3 fw-bold">
                        <i class="bi bi-star me-2"></i>강의평가 작성하기
                    </a>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</section>

<!-- 푸터 포함 -->
<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
</body>
</html>
