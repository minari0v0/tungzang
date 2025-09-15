<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>안양대학교 학사 일정 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <style>
        /* 학사일정 전용 스타일 */
        :root {
            --success-color: #10b981; /* 녹색 정의 */
        }

        .academic-calendar-page {
            background-color: var(--background-light);
            min-height: 100vh;
            padding-top: 2rem;
            padding-bottom: 2rem;
        }

        .dark-mode .academic-calendar-page {
            background-color: var(--dark-bg);
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
            color: var(--text-color);
            margin: 0;
        }

        .page-subtitle {
            color: var(--text-light);
            margin: 0.5rem 0 0 0;
            font-size: 1.1rem;
        }

        .refresh-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.5rem;
            background: var(--primary-color); /* 보라색으로 복원 */
            color: white;
            border: none;
            border-radius: 50px;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            text-decoration: none;
        }

        .refresh-btn:hover {
            background: var(--primary-dark); /* 진한 보라색으로 복원 */
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
            color: var(--text-light);
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

        .important-events-card {
            border-left: 4px solid #ef4444;
            margin-bottom: 2rem;
        }

        .event-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1rem;
            background: #fef2f2;
            border-radius: 8px;
            margin-bottom: 0.75rem;
            transition: var(--transition);
        }

        .dark-mode .event-item {
            background: rgba(239, 68, 68, 0.1);
        }

        .event-item:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }

        .event-item:last-child {
            margin-bottom: 0;
        }

        .event-left {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .event-icon {
            width: 2rem;
            height: 2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--primary-color);
            color: white;
            border-radius: 50%;
            font-size: 1rem;
        }

        .event-info h3 {
            font-weight: 600;
            margin: 0 0 0.25rem 0;
            font-size: 1rem;
            color: var(--text-color);
        }

        .event-info p {
            font-size: 0.875rem;
            color: var(--text-light);
            margin: 0;
        }

        .upcoming-event {
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            margin-bottom: 1rem;
            background: var(--white);
            transition: var(--transition);
        }

        .dark-mode .upcoming-event {
            background: var(--dark-card-bg);
            border-color: rgba(255, 255, 255, 0.1);
        }

        .upcoming-event:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-hover);
        }

        .upcoming-event-content {
            padding: 1.25rem;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 1rem;
        }

        .upcoming-event-left {
            display: flex;
            align-items: flex-start;
            gap: 0.75rem;
            flex: 1;
        }

        .upcoming-event-icon {
            margin-top: 0.25rem;
            color: var(--primary-color);
            font-size: 1.25rem;
        }

        .upcoming-event-header {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.5rem;
            flex-wrap: wrap;
        }

        .upcoming-event-title {
            font-weight: 600;
            margin: 0;
            font-size: 1rem;
            color: var(--text-color);
        }

        .upcoming-event-date {
            font-size: 0.875rem;
            color: var(--text-light);
            margin-bottom: 0.5rem;
        }

        .upcoming-event-description {
            font-size: 0.875rem;
            color: var(--text-color);
            margin: 0;
            line-height: 1.5;
        }

        .category-grid {
            display: grid;
            gap: 1.5rem;
            grid-template-columns: 1fr;
        }

        @media (min-width: 768px) {
            .category-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (min-width: 1024px) {
            .category-grid {
                grid-template-columns: repeat(3, 1fr);
            }
        }

        .category-card {
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            background: var(--white);
            transition: var(--transition);
        }

        .dark-mode .category-card {
            background: var(--dark-card-bg);
            border-color: rgba(255, 255, 255, 0.1);
        }

        .category-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }

        .category-card-header {
            padding: 1rem 1rem 0.75rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .dark-mode .category-card-header {
            border-color: rgba(255, 255, 255, 0.1);
        }

        .category-card-title {
            font-size: 1.125rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin: 0;
            color: var(--text-color);
        }

        .category-card-content {
            padding: 1rem;
        }

        .category-event {
            margin-bottom: 0.75rem;
        }

        .category-event:last-child {
            margin-bottom: 0;
        }

        .category-event-title {
            font-weight: 500;
            font-size: 0.875rem;
            margin-bottom: 0.25rem;
            color: var(--text-color);
        }

        .category-event-date {
            font-size: 0.75rem;
            color: var(--text-light);
        }

        .more-events {
            font-size: 0.75rem;
            color: var(--text-light);
            margin-top: 0.5rem;
            font-style: italic;
        }

        .monthly-toggle {
            margin-top: 2rem;
        }

        .toggle-button {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            width: 100%;
            padding: 1rem 1.5rem;
            background: var(--white);
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            cursor: pointer;
            transition: var(--transition);
            font-size: 1rem;
            font-weight: 500;
            color: var(--text-color);
        }

        .dark-mode .toggle-button {
            background: var(--dark-card-bg);
            border-color: rgba(255, 255, 255, 0.1);
        }

        .toggle-button:hover {
            background: #f8f9fa;
            transform: translateY(-1px);
        }

        .dark-mode .toggle-button:hover {
            background: rgba(255, 255, 255, 0.05);
        }

        .toggle-content {
            display: none;
            padding: 1.5rem;
            border: 1px solid #e2e8f0;
            border-top: none;
            border-radius: 0 0 8px 8px;
            background: var(--white);
        }

        .dark-mode .toggle-content {
            background: var(--dark-card-bg);
            border-color: rgba(255, 255, 255, 0.1);
        }

        .toggle-content.show {
            display: block;
            animation: fadeIn 0.3s ease;
        }

        .month-section {
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            overflow: hidden;
            margin-bottom: 1rem;
        }

        .dark-mode .month-section {
            border-color: rgba(255, 255, 255, 0.1);
        }

        .month-header {
            background: #f8f9fa;
            padding: 0.75rem 1rem;
            font-weight: 600;
            border-bottom: 1px solid #e2e8f0;
            color: var(--text-color);
        }

        .dark-mode .month-header {
            background: var(--dark-bg);
            border-color: rgba(255, 255, 255, 0.1);
        }

        .month-events {
            padding: 1rem;
        }

        .month-event {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem;
            border-radius: 8px;
            margin-bottom: 0.5rem;
            transition: var(--transition);
        }

        .month-event:hover {
            background: #f8f9fa;
        }

        .dark-mode .month-event:hover {
            background: rgba(255, 255, 255, 0.05);
        }

        .month-event:last-child {
            margin-bottom: 0;
        }

        .month-event-info {
            flex: 1;
        }

        .month-event-title {
            font-weight: 500;
            font-size: 0.875rem;
            margin-bottom: 0.25rem;
            color: var(--text-color);
        }

        .month-event-date {
            font-size: 0.75rem;
            color: var(--text-light);
        }

        .data-source {
            font-size: 0.875rem;
            color: var(--text-light);
            line-height: 1.6;
        }

        .data-source p {
            margin-bottom: 0.5rem;
        }

        .data-source p:last-child {
            margin-bottom: 0;
        }

        .alert {
            background: #fff7ed;
            border: 1px solid #fed7aa;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }

        .dark-mode .alert {
            background: rgba(237, 137, 54, 0.1);
            border-color: rgba(237, 137, 54, 0.3);
        }

        .alert-content {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #ea580c;
        }

        .alert-text {
            font-size: 0.875rem;
        }

        .debug-info {
            font-size: 0.75rem;
            color: var(--text-light);
            margin-top: 0.5rem;
        }

        /* 다크모드에서 새로고침 버튼 색상 유지 */
        .dark-mode .refresh-btn {
            background: var(--primary-color);
            color: white;
        }

        .dark-mode .refresh-btn:hover {
            background: var(--primary-dark);
            color: white;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 반응형 */
        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .page-title {
                font-size: 2rem;
            }

            .upcoming-event-content {
                flex-direction: column;
                gap: 0.75rem;
            }

            .upcoming-event-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.25rem;
            }
        }

        /* 월별 탭 스타일 */
        .month-tabs {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-bottom: 2rem;
            padding: 1rem;
            background: #f8f9fa;
            border-radius: 8px;
        }

        .dark-mode .month-tabs {
            background: rgba(255, 255, 255, 0.05);
        }

        .month-tab {
            display: flex;
            align-items: center;
            gap: 0.25rem;
            padding: 0.5rem 1rem;
            background: var(--white);
            border: 1px solid #e2e8f0;
            border-radius: 20px;
            cursor: pointer;
            transition: var(--transition);
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--text-color);
            min-width: 60px;
            justify-content: center;
        }

        .dark-mode .month-tab {
            background: var(--dark-card-bg);
            border-color: rgba(255, 255, 255, 0.1);
        }

        .month-tab:hover:not(:disabled) {
            background: var(--primary-color);
            color: white;
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }

        .month-tab.active {
            background: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
        }

        .month-tab:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            background: #f1f5f9;
        }

        .dark-mode .month-tab:disabled {
            background: rgba(255, 255, 255, 0.02);
        }

        .month-count {
            background: rgba(255, 255, 255, 0.2);
            padding: 0.125rem 0.375rem;
            border-radius: 10px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .month-tab.active .month-count {
            background: rgba(255, 255, 255, 0.3);
        }

        .month-contents {
            min-height: 300px;
        }

        .month-content {
            display: none;
            animation: fadeIn 0.3s ease;
        }

        .month-content.active {
            display: block;
        }

        .month-header-info {
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .dark-mode .month-header-info {
            border-color: rgba(255, 255, 255, 0.1);
        }

        .month-header-info h3 {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--text-color);
            margin: 0;
        }

        .month-events-list {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .month-event-item {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            padding: 1.25rem;
            background: #f8f9fa;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            transition: var(--transition);
            gap: 1rem;
        }

        .dark-mode .month-event-item {
            background: rgba(255, 255, 255, 0.02);
            border-color: rgba(255, 255, 255, 0.1);
        }

        .month-event-item:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow);
            background: var(--white);
        }

        .dark-mode .month-event-item:hover {
            background: rgba(255, 255, 255, 0.05);
        }

        .month-event-left {
            display: flex;
            align-items: flex-start;
            gap: 1rem;
            flex: 1;
        }

        .month-event-icon {
            width: 2.5rem;
            height: 2.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--primary-color);
            color: white;
            border-radius: 50%;
            font-size: 1.125rem;
            flex-shrink: 0;
        }

        .month-event-details {
            flex: 1;
        }

        .month-event-title {
            font-size: 1.125rem;
            font-weight: 600;
            margin: 0 0 0.5rem 0;
            color: var(--text-color);
        }

        .month-event-date {
            font-size: 0.875rem;
            color: var(--primary-color);
            font-weight: 500;
            margin: 0 0 0.5rem 0;
        }

        .month-event-description {
            font-size: 0.875rem;
            color: var(--text-light);
            margin: 0;
            line-height: 1.5;
        }

        .month-event-badges {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            align-items: flex-end;
        }

        .empty-month {
            text-align: center;
            padding: 3rem 1rem;
            color: var(--text-light);
        }

        .empty-month i {
            font-size: 3rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }

        .empty-month h4 {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--text-color);
        }

        .empty-month p {
            margin: 0;
            font-size: 0.875rem;
        }

        /* 반응형 */
        @media (max-width: 768px) {
            .month-tabs {
                justify-content: center;
            }

            .month-tab {
                min-width: 50px;
                padding: 0.375rem 0.75rem;
                font-size: 0.8rem;
            }

            .month-event-item {
                flex-direction: column;
                gap: 1rem;
            }

            .month-event-badges {
                flex-direction: row;
                align-items: center;
                align-self: stretch;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="academic-calendar-page">
    <div class="container">
        <!-- 헤더 -->
        <div class="page-header">
            <div>
                <h1 class="page-title">안양대학교 학사 일정</h1>
                <p class="page-subtitle">중요한 학사 일정과 마감일을 확인하세요</p>
            </div>
            <a href="${pageContext.request.contextPath}/academic-calendar" class="refresh-btn">
                <i class="bi bi-arrow-clockwise"></i>
                새로고침
            </a>
        </div>

        <!-- 상태 -->
        <div class="status-info">
            <span>마지막 업데이트: ${lastUpdated}</span>
            <c:if test="${empty errorMessage}">
                <span class="realtime-badge">실시간 데이터</span>
            </c:if>
        </div>

        <!-- 오류 메시지 -->
        <c:if test="${not empty errorMessage}">
            <div class="alert">
                <div class="alert-content">
                    <i class="bi bi-exclamation-circle"></i>
                    <span class="alert-text">${errorMessage}</span>
                </div>
                <c:if test="${not empty debugInfo}">
                    <div class="debug-info">
                        디버그: ${debugInfo.foundEvents}개 일정 발견 (총 ${debugInfo.totalAttempts}개 시도)
                    </div>
                </c:if>
            </div>
        </c:if>

        <!-- 중요 일정 (다가오는 일정만) -->
        <c:set var="upcomingImportantEvents" value="${importantEvents.stream().filter(event -> event.daysUntil >= 0).limit(5).toList()}" />
        <c:if test="${not empty upcomingImportantEvents}">
            <div class="card important-events-card">
                <div class="card-header">
                    <h2 class="card-title">
                        <i class="bi bi-exclamation-triangle-fill text-danger"></i>
                        중요 일정
                    </h2>
                    <p class="card-description">놓치면 안 되는 중요한 일정들</p>
                </div>
                <div class="card-body">
                    <c:forEach var="event" items="${upcomingImportantEvents}">
                        <div class="event-item">
                            <div class="event-left">
                                <div class="event-icon">
                                    <i class="
                                        <c:choose>
                                            <c:when test="${event.category == 'exam'}">bi-book</c:when>
                                            <c:when test="${event.category == 'registration'}">bi-people</c:when>
                                            <c:when test="${event.category == 'vacation'}">bi-calendar</c:when>
                                            <c:when test="${event.category == 'event'}">bi-people</c:when>
                                            <c:when test="${event.category == 'deadline'}">bi-exclamation-triangle</c:when>
                                            <c:otherwise>bi-calendar</c:otherwise>
                                        </c:choose>
                                    "></i>
                                </div>
                                <div class="event-info">
                                    <h3>${event.title}</h3>
                                    <p>${event.dateRange}</p>
                                </div>
                            </div>
                            <span class="badge badge-destructive">
                                <c:choose>
                                    <c:when test="${event.daysUntil == 0}">D-Day</c:when>
                                    <c:when test="${event.daysUntil < 0}">D+${Math.abs(event.daysUntil)}</c:when>
                                    <c:otherwise>D-${event.daysUntil}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <!-- 다가오는 일정 (30일 이내) -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">
                    <i class="bi bi-calendar text-primary"></i>
                    다가오는 일정 (30일 이내)
                </h2>
                <p class="card-description">앞으로 한 달간의 학사 일정</p>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty upcomingEvents}">
                        <div class="empty-state">
                            <i class="bi bi-calendar-x"></i>
                            <h3>예정된 일정이 없습니다</h3>
                            <p>다가오는 30일 이내에 예정된 일정이 없습니다.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="event" items="${upcomingEvents}">
                            <div class="upcoming-event">
                                <div class="upcoming-event-content">
                                    <div class="upcoming-event-left">
                                        <i class="upcoming-event-icon
                                            <c:choose>
                                                <c:when test="${event.category == 'exam'}">bi-book</c:when>
                                                <c:when test="${event.category == 'registration'}">bi-people</c:when>
                                                <c:when test="${event.category == 'vacation'}">bi-calendar</c:when>
                                                <c:when test="${event.category == 'event'}">bi-people</c:when>
                                                <c:when test="${event.category == 'deadline'}">bi-exclamation-triangle</c:when>
                                                <c:otherwise>bi-calendar</c:otherwise>
                                            </c:choose>
                                        "></i>
                                        <div class="upcoming-event-info">
                                            <div class="upcoming-event-header">
                                                <h3 class="upcoming-event-title">${event.title}</h3>
                                                <span class="badge
                                                    <c:choose>
                                                        <c:when test="${event.category == 'exam'}">badge-exam</c:when>
                                                        <c:when test="${event.category == 'registration'}">badge-registration</c:when>
                                                        <c:when test="${event.category == 'vacation'}">badge-vacation</c:when>
                                                        <c:when test="${event.category == 'event'}">badge-event</c:when>
                                                        <c:when test="${event.category == 'deadline'}">badge-deadline</c:when>
                                                        <c:otherwise>badge-secondary</c:otherwise>
                                                    </c:choose>
                                                ">
                                                    <c:choose>
                                                        <c:when test="${event.category == 'exam'}">시험</c:when>
                                                        <c:when test="${event.category == 'registration'}">수강신청</c:when>
                                                        <c:when test="${event.category == 'vacation'}">방학</c:when>
                                                        <c:when test="${event.category == 'event'}">행사</c:when>
                                                        <c:when test="${event.category == 'deadline'}">마감</c:when>
                                                        <c:otherwise>기타</c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <c:if test="${event.isImportant}">
                                                    <span class="badge badge-destructive">중요</span>
                                                </c:if>
                                            </div>
                                            <p class="upcoming-event-date">${event.dateRange}</p>
                                            <p class="upcoming-event-description">${event.description}</p>
                                        </div>
                                    </div>
                                    <div>
                                        <span class="badge
                                            <c:choose>
                                                <c:when test="${event.daysUntil <= 7}">badge-destructive</c:when>
                                                <c:when test="${event.daysUntil <= 14}">badge-default</c:when>
                                                <c:otherwise>badge-secondary</c:otherwise>
                                            </c:choose>
                                        ">
                                            <c:choose>
                                                <c:when test="${event.daysUntil == 0}">D-Day</c:when>
                                                <c:when test="${event.daysUntil < 0}">D+${Math.abs(event.daysUntil)}</c:when>
                                                <c:otherwise>D-${event.daysUntil}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 카테고리별 일정 -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">카테고리별 일정</h2>
                <p class="card-description">모든 학사 일정을 카테고리별로 확인</p>
            </div>
            <div class="card-body">
                <div class="category-grid">
                    <c:forEach var="category" items="${['exam', 'deadline', 'event', 'vacation', 'registration']}">
                        <div class="category-card">
                            <div class="category-card-header">
                                <h3 class="category-card-title">
                                    <c:choose>
                                        <c:when test="${category == 'exam'}">
                                            <i class="bi bi-book"></i>
                                            시험
                                        </c:when>
                                        <c:when test="${category == 'registration'}">
                                            <i class="bi bi-people"></i>
                                            수강신청
                                        </c:when>
                                        <c:when test="${category == 'vacation'}">
                                            <i class="bi bi-calendar"></i>
                                            방학
                                        </c:when>
                                        <c:when test="${category == 'event'}">
                                            <i class="bi bi-people"></i>
                                            행사
                                        </c:when>
                                        <c:when test="${category == 'deadline'}">
                                            <i class="bi bi-exclamation-triangle"></i>
                                            마감
                                        </c:when>
                                    </c:choose>
                                </h3>
                            </div>
                            <div class="category-card-content">
                                <c:set var="categoryEvents" value="${allEvents.stream().filter(event -> event.category == category && event.daysUntil >= 0).limit(3).toList()}" />
                                <c:choose>
                                    <c:when test="${empty categoryEvents}">
                                        <div class="category-event">
                                            <div style="color: var(--text-light); font-size: 0.875rem;">예정된 일정이 없습니다</div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="event" items="${categoryEvents}">
                                            <div class="category-event">
                                                <div class="category-event-title">${event.title}</div>
                                                <div class="category-event-date">${event.dateRange}</div>
                                            </div>
                                        </c:forEach>
                                        <c:set var="totalCategoryEvents" value="${allEvents.stream().filter(event -> event.category == category && event.daysUntil >= 0).count()}" />
                                        <c:if test="${totalCategoryEvents > 3}">
                                            <div class="more-events">+${totalCategoryEvents - 3}개 더</div>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>

        <!-- 월별 정리 일정 (탭 형태) -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">월별 전체 일정 보기</h2>
                <p class="card-description">원하는 월을 선택하여 해당 월의 일정을 확인하세요</p>
            </div>
            <div class="card-body">
                <!-- 월별 탭 버튼들 -->
                <div class="month-tabs">
                    <c:forEach var="month" items="${[1,2,3,4,5,6,7,8,9,10,11,12]}">
                        <c:set var="monthEvents" value="${allEvents.stream().filter(event -> event.startDate.monthValue == month).toList()}" />
                        <button class="month-tab ${month == 6 ? 'active' : ''}"
                                data-month="${month}"
                            ${empty monthEvents ? 'disabled' : ''}>
                            <c:choose>
                                <c:when test="${month == 1}">1월</c:when>
                                <c:when test="${month == 2}">2월</c:when>
                                <c:when test="${month == 3}">3월</c:when>
                                <c:when test="${month == 4}">4월</c:when>
                                <c:when test="${month == 5}">5월</c:when>
                                <c:when test="${month == 6}">6월</c:when>
                                <c:when test="${month == 7}">7월</c:when>
                                <c:when test="${month == 8}">8월</c:when>
                                <c:when test="${month == 9}">9월</c:when>
                                <c:when test="${month == 10}">10월</c:when>
                                <c:when test="${month == 11}">11월</c:when>
                                <c:when test="${month == 12}">12월</c:when>
                            </c:choose>
                            <c:if test="${not empty monthEvents}">
                                <span class="month-count">${monthEvents.size()}</span>
                            </c:if>
                        </button>
                    </c:forEach>
                </div>

                <!-- 월별 일정 내용 -->
                <div class="month-contents">
                    <c:forEach var="month" items="${[1,2,3,4,5,6,7,8,9,10,11,12]}">
                        <c:set var="monthEvents" value="${allEvents.stream().filter(event -> event.startDate.monthValue == month).toList()}" />
                        <div class="month-content ${month == 6 ? 'active' : ''}" id="month-${month}">
                            <c:choose>
                                <c:when test="${empty monthEvents}">
                                    <div class="empty-month">
                                        <i class="bi bi-calendar-x"></i>
                                        <h4>
                                            <c:choose>
                                                <c:when test="${month == 1}">1월</c:when>
                                                <c:when test="${month == 2}">2월</c:when>
                                                <c:when test="${month == 3}">3월</c:when>
                                                <c:when test="${month == 4}">4월</c:when>
                                                <c:when test="${month == 5}">5월</c:when>
                                                <c:when test="${month == 6}">6월</c:when>
                                                <c:when test="${month == 7}">7월</c:when>
                                                <c:when test="${month == 8}">8월</c:when>
                                                <c:when test="${month == 9}">9월</c:when>
                                                <c:when test="${month == 10}">10월</c:when>
                                                <c:when test="${month == 11}">11월</c:when>
                                                <c:when test="${month == 12}">12월</c:when>
                                            </c:choose>
                                            에는 예정된 일정이 없습니다
                                        </h4>
                                        <p>해당 월에는 등록된 학사 일정이 없습니다.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="month-header-info">
                                        <h3>
                                            <c:choose>
                                                <c:when test="${month == 1}">1월</c:when>
                                                <c:when test="${month == 2}">2월</c:when>
                                                <c:when test="${month == 3}">3월</c:when>
                                                <c:when test="${month == 4}">4월</c:when>
                                                <c:when test="${month == 5}">5월</c:when>
                                                <c:when test="${month == 6}">6월</c:when>
                                                <c:when test="${month == 7}">7월</c:when>
                                                <c:when test="${month == 8}">8월</c:when>
                                                <c:when test="${month == 9}">9월</c:when>
                                                <c:when test="${month == 10}">10월</c:when>
                                                <c:when test="${month == 11}">11월</c:when>
                                                <c:when test="${month == 12}">12월</c:when>
                                            </c:choose>
                                            학사 일정 (${monthEvents.size()}개)
                                        </h3>
                                    </div>
                                    <div class="month-events-list">
                                        <c:forEach var="event" items="${monthEvents}">
                                            <div class="month-event-item">
                                                <div class="month-event-left">
                                                    <div class="month-event-icon">
                                                        <i class="
                                                    <c:choose>
                                                        <c:when test="${event.category == 'exam'}">bi-book</c:when>
                                                        <c:when test="${event.category == 'registration'}">bi-people</c:when>
                                                        <c:when test="${event.category == 'vacation'}">bi-calendar</c:when>
                                                        <c:when test="${event.category == 'event'}">bi-people</c:when>
                                                        <c:when test="${event.category == 'deadline'}">bi-exclamation-triangle</c:when>
                                                        <c:otherwise>bi-calendar</c:otherwise>
                                                    </c:choose>
                                                "></i>
                                                    </div>
                                                    <div class="month-event-details">
                                                        <h4 class="month-event-title">${event.title}</h4>
                                                        <p class="month-event-date">${event.dateRange}</p>
                                                        <p class="month-event-description">${event.description}</p>
                                                    </div>
                                                </div>
                                                <div class="month-event-badges">
                                            <span class="badge
                                                <c:choose>
                                                    <c:when test="${event.category == 'exam'}">badge-exam</c:when>
                                                    <c:when test="${event.category == 'registration'}">badge-registration</c:when>
                                                    <c:when test="${event.category == 'vacation'}">badge-vacation</c:when>
                                                    <c:when test="${event.category == 'event'}">badge-event</c:when>
                                                    <c:when test="${event.category == 'deadline'}">badge-deadline</c:when>
                                                    <c:otherwise>badge-secondary</c:otherwise>
                                                </c:choose>
                                            ">
                                                <c:choose>
                                                    <c:when test="${event.category == 'exam'}">시험</c:when>
                                                    <c:when test="${event.category == 'registration'}">수강신청</c:when>
                                                    <c:when test="${event.category == 'vacation'}">방학</c:when>
                                                    <c:when test="${event.category == 'event'}">행사</c:when>
                                                    <c:when test="${event.category == 'deadline'}">마감</c:when>
                                                    <c:otherwise>기타</c:otherwise>
                                                </c:choose>
                                            </span>
                                                    <c:if test="${event.isImportant}">
                                                        <span class="badge badge-destructive">중요</span>
                                                    </c:if>
                                                    <span class="badge
                                                <c:choose>
                                                    <c:when test="${event.daysUntil <= 7}">badge-destructive</c:when>
                                                    <c:when test="${event.daysUntil <= 14}">badge-default</c:when>
                                                    <c:otherwise>badge-secondary</c:otherwise>
                                                </c:choose>
                                            ">
                                                <c:choose>
                                                    <c:when test="${event.daysUntil == 0}">D-Day</c:when>
                                                    <c:when test="${event.daysUntil < 0}">D+${Math.abs(event.daysUntil)}</c:when>
                                                    <c:otherwise>D-${event.daysUntil}</c:otherwise>
                                                </c:choose>
                                            </span>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>

        <!-- 데이터 출처 -->
        <div class="card">
            <div class="card-body">
                <div class="data-source">
                    <p>📍 출처: 안양대학교 공식 홈페이지</p>
                    <p>📊 데이터: 실시간 학사일정 정보</p>
                    <p>🔄 일정은 학교 사정에 따라 변경될 수 있습니다</p>
                    <p>⚠️ 정확한 일정은 학교 공지사항을 확인해주세요</p>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        console.log('🚀 학사일정 페이지 로드 시작');

        // 월별 일정 표시 함수
        function showMonthEvents(month) {
            console.log('월별 탭 클릭:', month);

            // 모든 탭 비활성화
            const tabs = document.querySelectorAll('.month-tab');
            tabs.forEach(tab => tab.classList.remove('active'));

            // 모든 콘텐츠 숨기기
            const contents = document.querySelectorAll('.month-content');
            contents.forEach(content => content.classList.remove('active'));

            // 선택된 탭 활성화
            const selectedTab = document.querySelector('[data-month="' + month + '"]');
            if (selectedTab) {
                selectedTab.classList.add('active');
                console.log(month + '월 탭 활성화됨');
            }

            // 선택된 콘텐츠 표시
            const selectedContent = document.getElementById('month-' + month);
            if (selectedContent) {
                selectedContent.classList.add('active');
                console.log(month + '월 콘텐츠 표시됨');
            }
        }

        // 월별 탭 이벤트 리스너 추가
        const monthTabs = document.querySelectorAll('.month-tab:not([disabled])');
        console.log('활성화된 월별 탭 수:', monthTabs.length);

        monthTabs.forEach(function(tab) {
            tab.addEventListener('click', function(e) {
                e.preventDefault();
                const month = parseInt(this.getAttribute('data-month'));
                console.log('클릭된 월:', month);
                showMonthEvents(month);
            });
        });

        console.log('✅ 월별 탭 이벤트 리스너 설정 완료');

        console.log('✅ 학사일정 페이지 로드 완료');
    });
</script>
</body>
</html>
