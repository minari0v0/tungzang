<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>학식 메뉴 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        :root {
            --cafeteria-primary-color: #3b82f6;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --danger-color: #ef4444;
            --info-color: #06b6d4;
            --orange-color: #f97316;
        }

        .page-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem 1rem;
        }

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 2rem;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: 700;
            color: #1f2937;
            margin: 0;
        }

        .page-subtitle {
            color: #6b7280;
            margin: 0.5rem 0 0 0;
            font-size: 1.1rem;
        }

        .refresh-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.5rem;
            background: #7e22ce; /* 보라색으로 변경 */
            color: white;
            border: none;
            border-radius: 50px;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            text-decoration: none;
        }

        .refresh-btn:hover {
            background: #6b21a8; /* 진한 보라색으로 변경 */
            transform: translateY(-2px);
            box-shadow: var(--shadow-hover);
            color: white;
            text-decoration: none;
        }

        .status-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            color: #6b7280;
            flex-wrap: wrap;
        }

        .realtime-badge {
            background: var(--success-color);
            color: white;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .error-alert {
            background: #fef3cd;
            border: 1px solid #fde68a;
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }

        .error-alert .alert-content {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #92400e;
        }

        .weekend-alert {
            background: #dbeafe;
            border: 1px solid #93c5fd;
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }

        .weekend-alert .alert-content {
            color: #1e40af;
        }

        .weekend-alert .alert-title {
            font-weight: 600;
            margin-bottom: 0.25rem;
        }

        .cafeteria-card {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 0.75rem;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
            overflow: hidden;
            margin-bottom: 2rem;
        }

        .card-header-custom {
            padding: 1.5rem;
            border-bottom: 1px solid #e5e7eb;
        }

        .card-title-custom {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1.25rem;
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 0.5rem;
        }

        .card-description {
            color: #6b7280;
            font-size: 0.875rem;
            line-height: 1.5;
        }

        .description-item {
            display: flex;
            align-items: center;
            gap: 0.25rem;
            margin-bottom: 0.25rem;
        }

        .card-content-custom {
            padding: 1.5rem;
        }

        .menu-section-title {
            font-size: 1.125rem;
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 1rem;
        }

        .special-menu-header {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.75rem;
        }

        .special-badge {
            background: var(--orange-color);
            color: white;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .fixed-badge {
            background: transparent;
            color: #6b7280;
            border: 1px solid #d1d5db;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 0.75rem;
        }

        .menu-item-card {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 0.5rem;
            padding: 1rem;
            position: relative;
        }

        .menu-item-name {
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 0.5rem;
        }

        .menu-item-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .category-badge {
            background: transparent;
            color: #6b7280;
            border: 1px solid #d1d5db;
            padding: 0.125rem 0.375rem;
            border-radius: 0.25rem;
            font-size: 0.75rem;
        }

        .special-menu-badge {
            background: var(--orange-color);
            color: white;
            padding: 0.125rem 0.375rem;
            border-radius: 0.25rem;
            font-size: 0.625rem;
            font-weight: 500;
        }

        .no-menu-message {
            text-align: center;
            padding: 2rem;
            color: #6b7280;
        }

        .card-footer-custom {
            padding: 1.5rem;
            background: #f9fafb;
            border-top: 1px solid #e5e7eb;
            font-size: 0.875rem;
            color: #6b7280;
            line-height: 1.6;
        }

        .footer-item {
            margin-bottom: 0.25rem;
        }

        /* 다크모드 */
        .dark-mode .page-title {
            color: #f9fafb;
        }

        .dark-mode .page-subtitle {
            color: #9ca3af;
        }

        .dark-mode .cafeteria-card {
            background: #1f2937;
            border-color: #374151;
        }

        .dark-mode .card-header-custom {
            border-bottom-color: #374151;
        }

        .dark-mode .card-title-custom {
            color: #f9fafb;
        }

        .dark-mode .card-description {
            color: #9ca3af;
        }

        .dark-mode .menu-section-title {
            color: #f9fafb;
        }

        .dark-mode .menu-item-card {
            background: #374151;
            border-color: #4b5563;
        }

        .dark-mode .menu-item-name {
            color: #f9fafb;
        }

        .dark-mode .card-footer-custom {
            background: #374151;
            border-top-color: #4b5563;
        }

        .dark-mode .refresh-btn {
            background: var(--cafeteria-primary-color);
            color: white;
        }

        .dark-mode .refresh-btn:hover {
            background: var(--primary-dark);
            color: white;
        }

        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .page-title {
                font-size: 2rem;
            }

            .status-info {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.5rem;
            }

            .menu-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="page-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">안양대학교 학식 메뉴</h1>
            <p class="page-subtitle">오늘의 학식 메뉴를 확인하세요</p>
        </div>
        <a href="${pageContext.request.contextPath}/cafeteria" class="refresh-btn">
            <i class="bi bi-arrow-clockwise"></i>
            새로고침
        </a>
    </div>

    <div class="status-info">
        <div class="d-flex align-items-center gap-2">
            <i class="bi bi-clock"></i>
            <span>
                <% java.util.Date now = new java.util.Date(); %>
                마지막 업데이트: <%= new java.text.SimpleDateFormat("yyyy년 M월 d일 EEEE H시 m분 s초", java.util.Locale.KOREAN).format(now) %>
            </span>
        </div>
        <c:if test="${empty errorMessage}">
            <span class="realtime-badge">실시간 데이터</span>
        </c:if>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="error-alert">
            <div class="alert-content">
                <i class="bi bi-exclamation-triangle"></i>
                <span>${errorMessage}</span>
            </div>
        </div>
    </c:if>

    <%
        // 주말 여부 확인
        java.util.Calendar cal = java.util.Calendar.getInstance();
        boolean isWeekend = cal.get(java.util.Calendar.DAY_OF_WEEK) == java.util.Calendar.SATURDAY ||
                cal.get(java.util.Calendar.DAY_OF_WEEK) == java.util.Calendar.SUNDAY;
    %>

    <% if (isWeekend) { %>
    <div class="weekend-alert">
        <div class="alert-content">
            <div class="alert-title">
                <i class="bi bi-info-circle me-2"></i>주말 안내
            </div>
            <div>교내식당은 주말에 운영하지 않습니다. 다음 영업일은 월요일입니다.</div>
        </div>
    </div>
    <% } %>

    <!-- 간단한 더미 데이터로 대체 -->
    <div class="cafeteria-card">
        <div class="card-header-custom">
            <div class="card-title-custom">
                <i class="bi bi-cup-hot"></i>
                <c:choose>
                    <c:when test="${not empty cafeterias[0].name}">
                        ${cafeterias[0].name}
                    </c:when>
                    <c:otherwise>
                        학생회관 식당
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="card-description">
                <div class="description-item">
                    <i class="bi bi-geo-alt"></i>
                    <span>수리관 7층</span>
                </div>
                <div class="description-item">
                    <i class="bi bi-clock"></i>
                    <span>월 ~ 목 10:00 ~ 15:30(중식) / 16:30~18:30(석식)</span>
                </div>
                <div class="description-item ms-3">
                    <span>금요일 10:00 ~ 14:00(석식 없음)</span>
                </div>
                <div class="mt-2">교내식당은 신입생, 재학생 및 교직원에게 중식, 석식을 제공하고 있습니다.</div>
            </div>
        </div>

        <div class="card-content-custom">
            <h3 class="menu-section-title">오늘의 중식 메뉴</h3>

            <c:choose>
                <c:when test="${empty cafeterias}">
                    <div class="no-menu-message">
                        메뉴 정보를 불러올 수 없습니다.
                    </div>
                </c:when>
                <c:otherwise>
                    <c:set var="cafeteria" value="${cafeterias[0]}" />
                    <c:choose>
                        <c:when test="${empty cafeteria.meals.lunch}">
                            <div class="no-menu-message">
                                오늘은 중식을 운영하지 않습니다
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- 특별 메뉴 섹션 -->
                            <c:set var="hasSpecialMenu" value="false" />
                            <c:forEach var="item" items="${cafeteria.meals.lunch}">
                                <c:if test="${item.isSpecial}">
                                    <c:set var="hasSpecialMenu" value="true" />
                                </c:if>
                            </c:forEach>

                            <c:if test="${hasSpecialMenu}">
                                <div class="mb-4">
                                    <div class="special-menu-header">
                                        <span class="special-badge">${currentDayName} 한정</span>
                                        <span class="menu-section-title">오늘의 특별 메뉴</span>
                                    </div>
                                    <div class="menu-grid">
                                        <c:forEach var="item" items="${cafeteria.meals.lunch}">
                                            <c:if test="${item.isSpecial}">
                                                <div class="menu-item-card">
                                                    <div class="menu-item-name">${item.name}</div>
                                                    <div class="menu-item-footer">
                                                        <c:if test="${not empty item.category}">
                                                            <span class="category-badge">${item.category}</span>
                                                        </c:if>
                                                        <span class="special-menu-badge">특별메뉴</span>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>

                            <!-- 고정 메뉴 섹션 -->
                            <c:set var="hasRegularMenu" value="false" />
                            <c:forEach var="item" items="${cafeteria.meals.lunch}">
                                <c:if test="${item.isRegular}">
                                    <c:set var="hasRegularMenu" value="true" />
                                </c:if>
                            </c:forEach>

                            <c:if test="${hasRegularMenu}">
                                <div>
                                    <div class="special-menu-header">
                                        <span class="fixed-badge">항시 제공</span>
                                        <span class="menu-section-title">고정 메뉴</span>
                                    </div>
                                    <div class="menu-grid">
                                        <c:forEach var="item" items="${cafeteria.meals.lunch}">
                                            <c:if test="${item.isRegular}">
                                                <div class="menu-item-card">
                                                    <div class="menu-item-name">${item.name}</div>
                                                    <div class="menu-item-footer">
                                                        <c:if test="${not empty item.category}">
                                                            <span class="category-badge">${item.category}</span>
                                                        </c:if>
                                                        <div></div>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="card-footer-custom">
            <div class="footer-item">📍 위치: 안양대학교 캠퍼스 내 수리관 7층</div>
            <div class="footer-item">📊 데이터 출처: 안양대학교 공식 홈페이지</div>
            <div class="footer-item">🔄 메뉴는 식자재 수급 상황에 따라 변경될 수 있습니다</div>
            <div class="footer-item">⚠️ 알레르기가 있으신 분은 식당에 직접 문의해주세요</div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
</body>
</html>
