<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>배지 컬렉션 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/badge-collection.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
</head>
<body class="${user.admin ? 'admin-user' : ''}">
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container py-4">
    <!-- Header Section -->
    <div class="badge-collection-header tier-${user.admin ? '관리자' : userGrade}" id="badgeHeader">
        <div class="container">
            <div class="text-center">
                <h1 class="display-4 mb-3 fw-bold">🏆 배지 컬렉션</h1>
                <div class="grade-badge tier-${user.admin ? '관리자' : userGrade}">
                    <i class="bi ${user.admin ? 'bi-shield-fill-check' : 'bi-award'}"></i>
                    <span>${user.admin ? '관리자' : userGrade}</span>
                </div>

                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number">${earnedCount}</div>
                        <div class="stat-label">획득한 배지</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${totalCount - earnedCount}</div>
                        <div class="stat-label">미획득 배지</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${completionPercentage}%</div>
                        <div class="stat-label">달성률</div>
                    </div>
                </div>

                <c:if test="${nextGradeInfo != null}">
                    <div class="progress-info">
                        <div class="icon">
                            <i class="bi bi-target"></i>
                        </div>
                        <div>
                            <div class="fw-semibold">다음 등급까지</div>
                            <div class="opacity-75">${nextGradeInfo.remaining}개 배지 더 필요</div>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Category Tabs -->
    <div class="category-tabs">
        <button class="category-tab active" data-category="all">
            <i class="bi bi-collection me-2"></i>전체
        </button>
        <button class="category-tab" data-category="evaluation">
            <i class="bi bi-star me-2"></i>강의평가
        </button>
        <button class="category-tab" data-category="community">
            <i class="bi bi-chat-dots me-2"></i>커뮤니티
        </button>
        <button class="category-tab" data-category="timetable">
            <i class="bi bi-calendar3 me-2"></i>시간표
        </button>
        <button class="category-tab" data-category="overall">
            <i class="bi bi-trophy me-2"></i>종합
        </button>
        <c:if test="${user.admin}">
            <button class="category-tab" data-category="admin">
                <i class="bi bi-shield-fill me-2"></i>관리자
            </button>
        </c:if>
    </div>

    <!-- Badge Content -->
    <div class="tab-content">
        <!-- All Badges -->
        <div class="tab-pane active" id="all">
            <c:choose>
                <c:when test="${not empty allBadges}">
                    <!-- 획득한 배지 섹션 -->
                    <div class="badge-section">
                        <h2 class="section-title">
                            <i class="bi bi-check-circle-fill text-success me-2"></i>획득한 배지
                        </h2>
                        <div class="badge-grid">
                            <c:forEach var="badge" items="${allBadges}">
                                <c:if test="${badge.earned}">
                                    <div class="badge-card earned">
                                        <div class="badge-icon">
                                            <c:choose>
                                                <c:when test="${badge.category == 'evaluation'}">
                                                    <i class="bi bi-star-fill"></i>
                                                </c:when>
                                                <c:when test="${badge.category == 'community'}">
                                                    <i class="bi bi-chat-heart-fill"></i>
                                                </c:when>
                                                <c:when test="${badge.category == 'timetable'}">
                                                    <i class="bi bi-calendar-check-fill"></i>
                                                </c:when>
                                                <c:when test="${badge.category == 'admin'}">
                                                    <i class="${badge.iconClass}"></i>
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="bi bi-trophy-fill"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <h3 class="badge-title">${badge.name}</h3>
                                        <p class="badge-description">${badge.description}</p>
                                        <div class="earned-date">
                                            <i class="bi bi-calendar-check me-1"></i>
                                            <c:if test="${badge.category == 'admin'}">
                                                관리자 권한으로 획득
                                            </c:if>
                                        </div>
                                    </div>
                                </c:if>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- 진행 중인 배지 섹션 -->
                    <div class="badge-section">
                        <h2 class="section-title">
                            <i class="bi bi-hourglass-split text-warning me-2"></i>진행 중인 배지
                        </h2>
                        <div class="badge-grid">
                            <c:forEach var="badge" items="${allBadges}">
                                <c:if test="${!badge.earned}">
                                    <c:set var="currentCount" value="${userCounts[badge.category] != null ? userCounts[badge.category] : 0}" />
                                    <c:set var="progressPercent" value="${badge.requiredCount > 0 ? (currentCount * 100) / badge.requiredCount : 0}" />
                                    <c:if test="${progressPercent > 0 && progressPercent < 100}">
                                        <div class="badge-card in-progress">
                                            <div class="badge-icon">
                                                <c:choose>
                                                    <c:when test="${badge.category == 'evaluation'}">
                                                        <i class="bi bi-star-fill"></i>
                                                    </c:when>
                                                    <c:when test="${badge.category == 'community'}">
                                                        <i class="bi bi-chat-heart-fill"></i>
                                                    </c:when>
                                                    <c:when test="${badge.category == 'timetable'}">
                                                        <i class="bi bi-calendar-check-fill"></i>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="bi bi-trophy-fill"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <h3 class="badge-title">${badge.name}</h3>
                                            <p class="badge-description">${badge.description}</p>
                                            <div class="progress-container">
                                                <div class="progress-bar-wrapper">
                                                    <div class="progress-bar-fill" style="width: ${progressPercent}%"></div>
                                                </div>
                                                <div class="progress-text">
                                                        ${currentCount} / ${badge.requiredCount}
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>
                                </c:if>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- 미진행 배지 섹션 -->
                    <div class="badge-section">
                        <h2 class="section-title">
                            <i class="bi bi-lock me-2 text-muted"></i>미진행 배지
                        </h2>
                        <div class="badge-grid">
                            <c:forEach var="badge" items="${allBadges}">
                                <c:if test="${!badge.earned}">
                                    <c:set var="currentCount" value="${userCounts[badge.category] != null ? userCounts[badge.category] : 0}" />
                                    <c:set var="progressPercent" value="${badge.requiredCount > 0 ? (currentCount * 100) / badge.requiredCount : 0}" />
                                    <c:if test="${progressPercent == 0}">
                                        <div class="badge-card">
                                            <div class="badge-icon">
                                                <c:choose>
                                                    <c:when test="${badge.category == 'evaluation'}">
                                                        <i class="bi bi-star-fill"></i>
                                                    </c:when>
                                                    <c:when test="${badge.category == 'community'}">
                                                        <i class="bi bi-chat-heart-fill"></i>
                                                    </c:when>
                                                    <c:when test="${badge.category == 'timetable'}">
                                                        <i class="bi bi-calendar-check-fill"></i>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="bi bi-trophy-fill"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <h3 class="badge-title">${badge.name}</h3>
                                            <p class="badge-description">${badge.description}</p>
                                            <div class="progress-container">
                                                <div class="progress-bar-wrapper">
                                                    <div class="progress-bar-fill" style="width: 0%"></div>
                                                </div>
                                                <div class="progress-text">
                                                    0 / ${badge.requiredCount}
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>
                                </c:if>
                            </c:forEach>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <div class="empty-state-icon">
                            <i class="bi bi-collection"></i>
                        </div>
                        <h3>배지가 없습니다</h3>
                        <p>아직 등록된 배지가 없어요. 곧 다양한 배지가 추가될 예정입니다!</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Category Badges -->
        <c:forEach var="categoryEntry" items="${badgesByCategory}">
            <div class="tab-pane" id="${categoryEntry.key}">
                <c:choose>
                    <c:when test="${not empty categoryEntry.value}">
                        <!-- 획득한 배지 섹션 -->
                        <div class="badge-section">
                            <h2 class="section-title">
                                <i class="bi bi-check-circle-fill text-success me-2"></i>획득한 배지
                            </h2>
                            <div class="badge-grid">
                                <c:forEach var="badge" items="${categoryEntry.value}">
                                    <c:if test="${badge.earned}">
                                        <div class="badge-card earned">
                                            <div class="badge-icon">
                                                <c:choose>
                                                    <c:when test="${badge.category == 'evaluation'}">
                                                        <i class="bi bi-star-fill"></i>
                                                    </c:when>
                                                    <c:when test="${badge.category == 'community'}">
                                                        <i class="bi bi-chat-heart-fill"></i>
                                                    </c:when>
                                                    <c:when test="${badge.category == 'timetable'}">
                                                        <i class="bi bi-calendar-check-fill"></i>
                                                    </c:when>
                                                    <c:when test="${badge.category == 'admin'}">
                                                        <i class="${badge.iconClass}"></i>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="bi bi-trophy-fill"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <h3 class="badge-title">${badge.name}</h3>
                                            <p class="badge-description">${badge.description}</p>
                                            <div class="earned-date">
                                                <i class="bi bi-calendar-check me-1"></i>
                                                <c:if test="${badge.category == 'admin'}">
                                                    관리자 권한으로 획득
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </div>

                        <!-- 진행 중인 배지 섹션 -->
                        <div class="badge-section">
                            <h2 class="section-title">
                                <i class="bi bi-hourglass-split text-warning me-2"></i>진행 중인 배지
                            </h2>
                            <div class="badge-grid">
                                <c:forEach var="badge" items="${categoryEntry.value}">
                                    <c:if test="${!badge.earned}">
                                        <c:set var="currentCount" value="${userCounts[badge.category] != null ? userCounts[badge.category] : 0}" />
                                        <c:set var="progressPercent" value="${badge.requiredCount > 0 ? (currentCount * 100) / badge.requiredCount : 0}" />
                                        <c:if test="${progressPercent > 0 && progressPercent < 100}">
                                            <div class="badge-card in-progress">
                                                <div class="badge-icon">
                                                    <c:choose>
                                                        <c:when test="${badge.category == 'evaluation'}">
                                                            <i class="bi bi-star-fill"></i>
                                                        </c:when>
                                                        <c:when test="${badge.category == 'community'}">
                                                            <i class="bi bi-chat-heart-fill"></i>
                                                        </c:when>
                                                        <c:when test="${badge.category == 'timetable'}">
                                                            <i class="bi bi-calendar-check-fill"></i>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="bi bi-trophy-fill"></i>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <h3 class="badge-title">${badge.name}</h3>
                                                <p class="badge-description">${badge.description}</p>
                                                <div class="progress-container">
                                                    <div class="progress-bar-wrapper">
                                                        <div class="progress-bar-fill" style="width: ${progressPercent}%"></div>
                                                    </div>
                                                    <div class="progress-text">
                                                            ${currentCount} / ${badge.requiredCount}
                                                    </div>
                                                </div>
                                            </div>
                                        </c:if>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </div>

                        <!-- 미진행 배지 섹션 -->
                        <div class="badge-section">
                            <h2 class="section-title">
                                <i class="bi bi-lock me-2 text-muted"></i>미진행 배지
                            </h2>
                            <div class="badge-grid">
                                <c:forEach var="badge" items="${categoryEntry.value}">
                                    <c:if test="${!badge.earned}">
                                        <c:set var="currentCount" value="${userCounts[badge.category] != null ? userCounts[badge.category] : 0}" />
                                        <c:set var="progressPercent" value="${badge.requiredCount > 0 ? (currentCount * 100) / badge.requiredCount : 0}" />
                                        <c:if test="${progressPercent == 0}">
                                            <div class="badge-card">
                                                <div class="badge-icon">
                                                    <c:choose>
                                                        <c:when test="${badge.category == 'evaluation'}">
                                                            <i class="bi bi-star-fill"></i>
                                                        </c:when>
                                                        <c:when test="${badge.category == 'community'}">
                                                            <i class="bi bi-chat-heart-fill"></i>
                                                        </c:when>
                                                        <c:when test="${badge.category == 'timetable'}">
                                                            <i class="bi bi-calendar-check-fill"></i>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="bi bi-trophy-fill"></i>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <h3 class="badge-title">${badge.name}</h3>
                                                <p class="badge-description">${badge.description}</p>
                                                <div class="progress-container">
                                                    <div class="progress-bar-wrapper">
                                                        <div class="progress-bar-fill" style="width: 0%"></div>
                                                    </div>
                                                    <div class="progress-text">
                                                        0 / ${badge.requiredCount}
                                                    </div>
                                                </div>
                                            </div>
                                        </c:if>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <div class="empty-state-icon">
                                <i class="bi bi-collection"></i>
                            </div>
                            <h3>이 카테고리에는 배지가 없습니다</h3>
                            <p>다른 카테고리를 확인해보세요!</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:forEach>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>
<script>
    // 간단한 탭 전환 스크립트
    document.querySelectorAll('.category-tab').forEach(tab => {
        tab.addEventListener('click', function() {
            // 모든 탭 비활성화
            document.querySelectorAll('.category-tab').forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));

            // 클릭된 탭 활성화
            this.classList.add('active');
            const category = this.dataset.category;
            document.getElementById(category).classList.add('active');
        });
    });

    // 마우스 따라다니는 빛 효과 - 포켓몬 카드 스타일
    const badgeHeader = document.getElementById('badgeHeader');
    if (badgeHeader) {
        badgeHeader.addEventListener('mousemove', function(e) {
            const rect = this.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            // CSS 변수로 마우스 위치 전달
            this.style.setProperty('--mouse-x', x + 'px');
            this.style.setProperty('--mouse-y', y + 'px');
        });

        badgeHeader.addEventListener('mouseleave', function() {
            // 마우스가 벗어나면 중앙으로 리셋
            this.style.setProperty('--mouse-x', '50%');
            this.style.setProperty('--mouse-y', '50%');
        });
    }

    // 다크모드 감지
    const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
            if (mutation.attributeName === 'class') {
                // 다크모드 변경 시 추가 처리가 필요하면 여기에
            }
        });
    });

    observer.observe(document.body, { attributes: true });
</script>
</body>
</html>
