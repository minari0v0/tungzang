<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>마이페이지 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/badge-collection.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <style>
        .mypage-container {
            min-height: 100vh;
            background: #ffffff;
            padding: 2rem 0;
        }

        .dark-mode .mypage-container {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #1a1a2e 100%);
        }

        .mypage-layout {
            display: grid;
            grid-template-columns: 400px 1fr;
            gap: 2rem;
            max-width: 1400px;
            margin: 0 auto;
        }

        /* 프로필 사이드바 */
        .profile-sidebar {
            position: sticky;
            top: 2rem;
            height: fit-content;
        }

        .profile-card {
            background: linear-gradient(to bottom right, #dbeafe, #e9d5ff) !important;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 1.5rem;
            padding: 2rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            text-align: center;
            color: #1e293b;
            position: relative;
            overflow: hidden;
        }

        .dark-mode .profile-card {
            background: linear-gradient(to bottom right, #1e3a8a, #581c87) !important;
            border-color: rgba(168, 85, 247, 0.2);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            color: #e2e8f0;
        }

        .profile-avatar {
            width: 120px !important;
            height: 120px !important;
            background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 50%, #ec4899 100%) !important;
            border-radius: 50% !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            font-size: 3rem !important;
            font-weight: 800 !important;
            color: white !important;
            margin: 0 auto 1.5rem !important;
            box-shadow: 0 15px 35px rgba(59, 130, 246, 0.4) !important;
            border: 4px solid rgba(255, 255, 255, 0.8) !important;
        }

        .user-name {
            font-size: 1.75rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            color: #1e293b;
        }

        .dark-mode .user-name {
            color: #e2e8f0;
        }

        .user-username {
            font-size: 1rem;
            color: #64748b;
            margin-bottom: 1rem;
        }

        .dark-mode .user-username {
            color: #94a3b8;
        }

        /* 티어별 배지 색상 - badge-collection.css 참고 */
        .user-grade-badge {
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.875rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 1.5rem;
            display: inline-block;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .user-grade-badge.tier-새내기 {
            background: linear-gradient(135deg, #6e6e6e, #9e9e9e);
            color: white;
        }

        .user-grade-badge.tier-초급자 {
            background: linear-gradient(135deg, #cd7f32, #e9967a);
            color: white;
        }

        .user-grade-badge.tier-숙련자 {
            background: linear-gradient(135deg, #c0c0c0, #e0e0e0);
            color: #333;
        }

        .user-grade-badge.tier-전문가 {
            background: linear-gradient(135deg, #ffd700, #ffeaa7);
            color: #333;
            animation: goldPulse 2s infinite;
        }

        .user-grade-badge.tier-마스터 {
            background: linear-gradient(135deg, #9d4db3, #a29bfe);
            color: white;
            animation: masterGlow 2s infinite;
        }

        @keyframes goldPulse {
            0%, 100% { box-shadow: 0 4px 12px rgba(255, 215, 0, 0.3); }
            50% { box-shadow: 0 8px 20px rgba(255, 215, 0, 0.5); }
        }

        @keyframes masterGlow {
            0%, 100% { box-shadow: 0 4px 12px rgba(157, 77, 179, 0.4); }
            50% { box-shadow: 0 8px 20px rgba(157, 77, 179, 0.6); }
        }

        /* 사용자 정보 카드 */
        .user-info {
            background: transparent !important;
            border: none !important;
            padding: 0 !important;
            margin: 1.5rem 0 !important;
            box-shadow: none !important;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .info-item {
            display: flex !important;
            align-items: center !important;
            justify-content: space-between !important;
            padding: 0.75rem 1rem !important;
            background: #ffffff !important;
            border: 1px solid rgba(0, 0, 0, 0.1) !important;
            border-radius: 0.5rem !important;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05) !important;
            gap: 0 !important;
        }

        .dark-mode .info-item {
            background: rgba(15, 23, 42, 0.7) !important;
            border-color: rgba(168, 85, 247, 0.2) !important;
        }

        .info-label {
            color: #6b7280 !important;
            font-weight: 500 !important;
            font-size: 0.875rem !important;
            display: flex !important;
            align-items: center !important;
        }

        .info-value {
            color: #1f2937 !important;
            font-weight: 600 !important;
            font-size: 0.875rem !important;
        }

        .dark-mode .info-label {
            color: #9ca3af !important;
        }

        .dark-mode .info-value {
            color: #e5e7eb !important;
        }

        .info-dot {
            display: none !important;
        }

        /* 색상 단추 스타일 */
        .color-dot {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            margin-right: 8px;
            vertical-align: middle;
        }

        .color-dot.bg-blue {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
            box-shadow: 0 2px 4px rgba(59, 130, 246, 0.3);
        }

        .color-dot.bg-green {
            background: linear-gradient(135deg, #10b981, #059669);
            box-shadow: 0 2px 4px rgba(16, 185, 129, 0.3);
        }

        .color-dot.bg-purple {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
            box-shadow: 0 2px 4px rgba(139, 92, 246, 0.3);
        }

        .color-dot.bg-orange {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            box-shadow: 0 2px 4px rgba(245, 158, 11, 0.3);
        }

        .dark-mode .color-dot.bg-blue {
            background: linear-gradient(135deg, #60a5fa, #3b82f6);
        }

        .dark-mode .color-dot.bg-green {
            background: linear-gradient(135deg, #34d399, #10b981);
        }

        .dark-mode .color-dot.bg-purple {
            background: linear-gradient(135deg, #a78bfa, #8b5cf6);
        }

        .dark-mode .color-dot.bg-orange {
            background: linear-gradient(135deg, #fbbf24, #f59e0b);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 0.75rem;
            margin-bottom: 1.5rem;
        }

        .stat-card {
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 0.75rem;
            padding: 0.75rem;
            text-align: center;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }

        .stat-card.stat-blue {
            background: #eff6ff !important;
        }

        .stat-card.stat-green {
            background: #f0fdf4 !important;
        }

        .stat-card.stat-purple {
            background: #faf5ff !important;
        }

        .stat-card.stat-orange {
            background: #fffbeb !important;
            position: relative;
            overflow: hidden;
        }

        .stat-card.stat-orange::before {
            display: none;
        }

        .dark-mode .stat-card {
            background: rgba(15, 23, 42, 0.7) !important;
            border-color: rgba(168, 85, 247, 0.2) !important;
        }

        .stat-card:hover {
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
            transform: translateY(-2px);
        }

        .stats-grid .stat-card.stat-blue .stat-number {
            color: #1d4ed8 !important;
            -webkit-text-fill-color: unset !important;
        }

        .stats-grid .stat-card.stat-green .stat-number {
            color: #15803d !important;
            -webkit-text-fill-color: unset !important;
        }

        .stats-grid .stat-card.stat-purple .stat-number {
            color: #6d28d9 !important;
            -webkit-text-fill-color: unset !important;
        }

        .stats-grid .stat-card.stat-orange .stat-number {
            color: #b45309 !important;
            -webkit-text-fill-color: unset !important;
        }

        .stats-grid .stat-card.stat-blue .stat-label {
            color: #2563eb !important;
        }

        .stats-grid .stat-card.stat-green .stat-label {
            color: #16a34a !important;
        }

        .stats-grid .stat-card.stat-purple .stat-label {
            color: #7c3aed !important;
        }

        .stats-grid .stat-card.stat-orange .stat-label {
            color: #d97706 !important;
        }

        .stats-grid .stat-card .stat-label {
            color: inherit !important;
        }

        .stat-number {
            font-size: 1.5rem;
            font-weight: 800;
            margin-bottom: 0.25rem;
        }

        .stat-label {
            font-size: 0.75rem;
            font-weight: 500;
        }

        .dark-mode .stats-grid .stat-card .stat-number {
            color: #e2e8f0 !important;
        }

        .dark-mode .stats-grid .stat-card .stat-label {
            color: #94a3b8 !important;
        }

        .btn-modern {
            background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 50%, #ec4899 100%) !important;
            border: none !important;
            color: white !important;
            padding: 0.75rem 1.5rem !important;
            border-radius: 50px !important;
            font-weight: 600 !important;
            transition: all 0.3s ease !important;
            text-decoration: none !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 0.5rem !important;
            width: 100% !important;
            justify-content: center !important;
            box-shadow: 0 8px 20px rgba(59, 130, 246, 0.4) !important;
        }

        .btn-modern:hover {
            background: linear-gradient(135deg, #2563eb 0%, #7c3aed 50%, #be185d 100%) !important;
            box-shadow: 0 12px 30px rgba(37, 99, 235, 0.5) !important;
            color: white !important;
            transform: translateY(-2px) !important;
        }

        /* 메인 콘텐츠 */
        .main-content {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(99, 102, 241, 0.1);
            border-radius: 1.5rem;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(99, 102, 241, 0.1);
        }

        .dark-mode .main-content {
            background: rgba(30, 41, 59, 0.9);
            border-color: rgba(168, 85, 247, 0.2);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .nav-tabs-modern {
            border: none;
            background: rgba(248, 250, 252, 0.8);
            padding: 1rem;
            margin: 0;
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }

        .dark-mode .nav-tabs-modern {
            background: rgba(51, 65, 85, 0.8);
        }

        .nav-tabs-modern .nav-link {
            border: none;
            border-radius: 0.75rem;
            padding: 0.75rem 1.25rem;
            color: #64748b;
            font-weight: 500;
            transition: all 0.2s ease;
            margin: 0;
            background: transparent;
        }

        .nav-tabs-modern .nav-link:hover {
            background: rgba(99, 102, 241, 0.1);
            color: #6366f1;
        }

        .nav-tabs-modern .nav-link.active {
            background: linear-gradient(135deg, #6366f1, #8b5cf6);
            color: white;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
        }

        .dark-mode .nav-tabs-modern .nav-link {
            color: #94a3b8;
        }

        .dark-mode .nav-tabs-modern .nav-link:hover {
            background: rgba(168, 85, 247, 0.1);
            color: #a855f7;
        }

        .tab-content-modern {
            padding: 2rem;
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #64748b;
        }

        .dark-mode .empty-state {
            color: #94a3b8;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1.5rem;
            opacity: 0.5;
            color: #6366f1;
        }

        .empty-state h4 {
            font-weight: 600;
            margin-bottom: 1rem;
            color: #1e293b;
        }

        .dark-mode .empty-state h4 {
            color: #e2e8f0;
        }

        .empty-state p {
            margin-bottom: 2rem;
        }

        .activity-item {
            padding: 1.5rem;
            border-bottom: 1px solid rgba(99, 102, 241, 0.1);
            transition: all 0.2s ease;
        }

        .dark-mode .activity-item {
            border-bottom: 1px solid rgba(168, 85, 247, 0.1);
        }

        .activity-item:hover {
            background: rgba(99, 102, 241, 0.02);
        }

        .dark-mode .activity-item:hover {
            background: rgba(168, 85, 247, 0.05);
        }

        .activity-item:last-child {
            border-bottom: none;
        }

        .activity-title {
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: #1e293b;
        }

        .dark-mode .activity-title {
            color: #e2e8f0;
        }

        .activity-meta {
            color: #64748b;
            font-size: 0.875rem;
            margin-bottom: 0.5rem;
        }

        .dark-mode .activity-meta {
            color: #94a3b8;
        }

        .activity-actions {
            display: flex;
            gap: 0.5rem;
            margin-top: 1rem;
        }

        .btn-sm-modern {
            padding: 0.375rem 1rem;
            border-radius: 50px;
            font-size: 0.875rem;
            font-weight: 500;
            border: 1px solid;
            transition: all 0.2s ease;
            text-decoration: none;
        }

        .btn-outline-primary-modern {
            color: #6366f1;
            border-color: #6366f1;
            background: transparent;
        }

        .btn-outline-primary-modern:hover {
            background: #6366f1;
            color: white;
        }

        .btn-outline-danger-modern {
            color: #dc2626;
            border-color: #dc2626;
            background: transparent;
        }

        .btn-outline-danger-modern:hover {
            background: #dc2626;
            color: white;
        }

        .star-rating {
            display: flex;
            gap: 0.125rem;
        }

        .star {
            color: #e5e7eb;
            font-size: 1rem;
        }

        .star.filled {
            color: #fbbf24;
        }

        .badge-modern {
            padding: 0.375rem 0.75rem;
            border-radius: 50px;
            font-size: 0.75rem;
            font-weight: 500;
            background: rgba(99, 102, 241, 0.1);
            color: #6366f1;
        }

        .dark-mode .badge-modern {
            background: rgba(168, 85, 247, 0.1);
            color: #a855f7;
        }

        /* 시간표 관련 스타일 수정 */
        .timetable-container {
            overflow-x: auto;
            margin: 1rem 0;
            position: relative; /* 추가: 절대 위치 지정을 위한 기준점 */
        }

        .timetable {
            min-width: 600px;
            border-collapse: collapse;
            table-layout: fixed;
            position: relative; /* 추가: 절대 위치 지정을 위한 기준점 */
        }

        .timetable th,
        .timetable td {
            border: 1px solid rgba(99, 102, 241, 0.1);
            padding: 0;
            text-align: center;
            vertical-align: top;
            height: 50px;
            position: relative;
            overflow: visible; /* 변경: 내용이 넘쳐도 보이게 함 */
        }

        .timetable th:first-child,
        .timetable td:first-child {
            width: 80px;
        }

        .dark-mode .timetable th,
        .dark-mode .timetable td {
            border-color: rgba(168, 85, 247, 0.1);
        }

        .timetable th {
            background: rgba(99, 102, 241, 0.05);
            font-weight: 600;
            color: #1e293b;
            height: 40px;
        }

        .dark-mode .timetable th {
            background: rgba(168, 85, 247, 0.1);
            color: #e2e8f0;
        }

        .time-cell {
            background: rgba(99, 102, 241, 0.05) !important;
            font-weight: 600;
            font-size: 0.875rem;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .dark-mode .time-cell {
            background: rgba(168, 85, 247, 0.1) !important;
        }

        /* 강의 블록 스타일 수정 */
        .course-block {
            position: absolute;
            left: 2px;
            right: 2px;
            border-radius: 6px;
            color: white;
            font-size: 0.8rem;
            padding: 6px;
            text-align: center;
            display: flex;
            flex-direction: column;
            justify-content: center;
            overflow: hidden;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
            z-index: 10;
        }

        .course-block-name {
            font-weight: 700;
            font-size: 0.8rem;
            margin-bottom: 3px;
            line-height: 1.1;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .course-block-professor {
            font-size: 0.7rem;
            opacity: 0.9;
            line-height: 1;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .course-block-location {
            font-size: 0.65rem;
            opacity: 0.8;
            line-height: 1;
            margin-top: 2px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        /* 강의 목록 스타일 */
        .course-list-container {
            margin-bottom: 2rem;
        }

        .course-item {
            background: #ffffff;
            border: 1px solid rgba(99, 102, 241, 0.1);
            border-radius: 0.75rem;
            padding: 1.5rem;
            margin-bottom: 1rem;
            transition: all 0.2s ease;
        }

        .dark-mode .course-item {
            background: rgba(30, 41, 59, 0.7);
            border-color: rgba(168, 85, 247, 0.2);
        }

        .course-item:hover {
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.1);
            transform: translateY(-1px);
        }

        .course-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.75rem;
        }

        .course-title {
            font-size: 1.125rem;
            font-weight: 600;
            margin: 0;
            color: #1e293b;
        }

        .dark-mode .course-title {
            color: #e2e8f0;
        }

        .course-time {
            background: rgba(99, 102, 241, 0.1);
            color: #6366f1;
            padding: 0.25rem 0.75rem;
            border-radius: 50px;
            font-size: 0.875rem;
            font-weight: 500;
        }

        .dark-mode .course-time {
            background: rgba(168, 85, 247, 0.1);
            color: #a855f7;
        }

        .course-details {
            display: flex;
            gap: 1.5rem;
            color: #64748b;
            font-size: 0.875rem;
        }

        .dark-mode .course-details {
            color: #94a3b8;
        }

        .course-professor,
        .course-location {
            display: flex;
            align-items: center;
            gap: 0.375rem;
        }

        /* 시간표 그리드 스타일 수정 */
        .timetable-grid-container {
            border-top: 1px solid rgba(99, 102, 241, 0.1);
            padding-top: 1.5rem;
        }

        .dark-mode .timetable-grid-container {
            border-top-color: rgba(168, 85, 247, 0.1);
        }

        /* 시간표 헤더 스타일 수정 */
        .timetable-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .timetable-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin: 0;
            color: #1e293b;
        }

        .dark-mode .timetable-title {
            color: #e2e8f0;
        }

        /* 시간표 관리 버튼 스타일 수정 */
        .timetable-btn {
            background-color: #9d4edd; /* #7e22ce보다 연한 보라색 */
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-weight: 500;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            box-shadow: 0 2px 8px rgba(157, 78, 221, 0.3);
        }

        .timetable-btn:hover {
            background-color: #8c2dc0; /* 호버 시 약간 더 진한 색상 */
            box-shadow: 0 4px 12px rgba(157, 78, 221, 0.4);
            transform: translateY(-1px);
            color: white;
        }
        /* 계정 설정 버튼 스타일 추가 */
        .account-settings-btn {
            background: linear-gradient(135deg, #4b5563 0%, #6b7280 100%);
            color: white;
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            box-shadow: 0 4px 12px rgba(75, 85, 99, 0.3);
            margin-top: 0.75rem;
            width: 100%;
            justify-content: center;
        }

        .account-settings-btn:hover {
            background: linear-gradient(135deg, #374151 0%, #4b5563 100%);
            justify-content: center;
        }

        .account-settings-btn:hover {
            background: linear-gradient(135deg, #374151 0%, #4b5563 100%);
            box-shadow: 0 8px 20px rgba(75, 85, 99, 0.4);
            transform: translateY(-2px);
            color: white;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="mypage-container">
    <div class="container-fluid">
        <!-- 성공 메시지 표시 -->
        <c:if test="${not empty param.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle me-2"></i>
                <c:choose>
                    <c:when test="${param.success eq 'profile'}">
                        프로필이 성공적으로 업데이트되었습니다.
                    </c:when>
                    <c:when test="${param.success eq 'password'}">
                        비밀번호가 성공적으로 변경되었습니다.
                    </c:when>
                </c:choose>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <div class="mypage-layout">
            <!-- 프로필 사이드바 -->
            <div class="profile-sidebar">
                <div class="profile-card">
                    <div class="profile-avatar">
                        ${user.name.charAt(0)}
                    </div>
                    <div class="user-name">${user.name}</div>
                    <div class="user-username">@${user.username}</div>
                    <div class="user-grade-badge tier-${userGrade}">${userGrade}</div>

                    <!-- 사용자 정보 카드 -->
                    <div class="user-info">
                        <div class="info-item">
                            <span class="info-label">
                                <span class="color-dot bg-blue"></span>
                                학과
                            </span>
                            <span class="info-value">${user.department}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">
                                <span class="color-dot bg-green"></span>
                                학번
                            </span>
                            <span class="info-value">${user.studentId}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">
                                <span class="color-dot bg-purple"></span>
                                가입일
                            </span>
                            <span class="info-value"><fmt:formatDate value="${user.createdAt}" pattern="yyyy년 MM월" /></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">
                                <span class="color-dot bg-orange"></span>
                                이메일
                            </span>
                            <span class="info-value">${user.email}</span>
                        </div>
                    </div>

                    <div class="stats-grid">
                        <div class="stat-card stat-blue">
                            <div class="stat-number">${fn:length(userPosts)}</div>
                            <div class="stat-label">게시글</div>
                        </div>
                        <div class="stat-card stat-green">
                            <div class="stat-number">${fn:length(userComments)}</div>
                            <div class="stat-label">댓글</div>
                        </div>
                        <div class="stat-card stat-purple">
                            <div class="stat-number">${fn:length(userEvaluations)}</div>
                            <div class="stat-label">강의평가</div>
                        </div>
                        <div class="stat-card stat-orange">
                            <div class="stat-number">${earnedBadgeCount}/${totalBadgeCount}</div>
                            <div class="stat-label">배지</div>
                        </div>
                    </div>

                    <a href="${pageContext.request.contextPath}/mypage/profile" class="btn-modern">
                        <i class="bi bi-pencil"></i>
                        프로필 수정
                    </a>

                    <!-- 계정 설정 버튼 추가 -->
                    <a href="${pageContext.request.contextPath}/mypage/settings" class="account-settings-btn">
                        <i class="bi bi-gear"></i>
                        계정 설정
                    </a>
                </div>
            </div>

            <!-- 메인 콘텐츠 -->
            <div class="main-content">
                <!-- 탭 네비게이션 -->
                <ul class="nav nav-tabs-modern" id="myTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="evaluations-tab" data-bs-toggle="tab" data-bs-target="#evaluations" type="button" role="tab" aria-controls="evaluations" aria-selected="true">
                            <i class="bi bi-star me-2"></i>내 강의평가
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="posts-tab" data-bs-toggle="tab" data-bs-target="#posts" type="button" role="tab" aria-controls="posts" aria-selected="false">
                            <i class="bi bi-file-text me-2"></i>내 게시글
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="comments-tab" data-bs-toggle="tab" data-bs-target="#comments" type="button" role="tab" aria-controls="comments" aria-selected="false">
                            <i class="bi bi-chat-dots me-2"></i>내 댓글
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="timetable-tab" data-bs-toggle="tab" data-bs-target="#timetable" type="button" role="tab" aria-controls="timetable" aria-selected="false">
                            <i class="bi bi-calendar3 me-2"></i>내 시간표
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="badges-tab" data-bs-toggle="tab" data-bs-target="#badges" type="button" role="tab" aria-controls="badges" aria-selected="false">
                            <i class="bi bi-award me-2"></i>내 배지
                        </button>
                    </li>
                </ul>

                <div class="tab-content tab-content-modern" id="myTabContent">
                    <!-- 내 강의평가 탭 -->
                    <div class="tab-pane fade show active" id="evaluations" role="tabpanel" aria-labelledby="evaluations-tab">
                        <c:choose>
                            <c:when test="${empty userEvaluations}">
                                <div class="empty-state">
                                    <i class="bi bi-star"></i>
                                    <h4>작성한 강의평가가 없습니다</h4>
                                    <p>첫 강의평가를 작성하고 다른 학생들에게 도움을 주세요!</p>
                                    <a href="${pageContext.request.contextPath}/evaluations/write" class="btn-modern">
                                        <i class="bi bi-plus-circle"></i>
                                        강의평가 작성하기
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="evaluation" items="${userEvaluations}">
                                    <div class="activity-item">
                                        <div class="activity-title">${evaluation.courseName}</div>
                                        <div class="activity-meta">
                                            <span class="badge-modern">${evaluation.professor}</span>
                                            <span class="ms-3">
                                                <div class="star-rating d-inline-flex">
                                                    <c:forEach begin="1" end="5" var="i">
                                                        <span class="star ${i <= evaluation.rating ? 'filled' : ''}">★</span>
                                                    </c:forEach>
                                                </div>
                                            </span>
                                            <span class="ms-3"><fmt:formatDate value="${evaluation.date}" pattern="yyyy-MM-dd" /></span>
                                        </div>
                                        <p class="mb-2">${evaluation.comment}</p>
                                        <div class="activity-actions">
                                            <a href="${pageContext.request.contextPath}/evaluations/course/${evaluation.courseId}" class="btn-sm-modern btn-outline-primary-modern">
                                                <i class="bi bi-eye"></i> 보기
                                            </a>
                                            <button type="button" class="btn-sm-modern btn-outline-danger-modern"
                                                    onclick="confirmDelete('${pageContext.request.contextPath}/evaluations/delete?evaluationId=${evaluation.id}')">
                                                <i class="bi bi-trash"></i> 삭제
                                            </button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- 내 게시글 탭 -->
                    <div class="tab-pane fade" id="posts" role="tabpanel" aria-labelledby="posts-tab">
                        <c:choose>
                            <c:when test="${empty userPosts}">
                                <div class="empty-state">
                                    <i class="bi bi-file-text"></i>
                                    <h4>작성한 게시글이 없습니다</h4>
                                    <p>커뮤니티에서 다른 학생들과 소통해보세요!</p>
                                    <a href="${pageContext.request.contextPath}/community/write" class="btn-modern">
                                        <i class="bi bi-plus-circle"></i>
                                        게시글 작성하기
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="post" items="${userPosts}">
                                    <div class="activity-item">
                                        <div class="activity-title">
                                            <a href="${pageContext.request.contextPath}/community/post/${post.id}" class="text-decoration-none">${post.title}</a>
                                        </div>
                                        <div class="activity-meta">
                                            <span class="badge-modern">${post.category}</span>
                                            <span class="ms-3"><i class="bi bi-eye"></i> ${post.viewCount}</span>
                                            <span class="ms-3"><i class="bi bi-chat"></i> ${post.commentCount}</span>
                                            <span class="ms-3"><fmt:formatDate value="${post.date}" pattern="yyyy-MM-dd" /></span>
                                        </div>
                                        <div class="activity-actions">
                                            <a href="${pageContext.request.contextPath}/community/edit/${post.id}" class="btn-sm-modern btn-outline-primary-modern">
                                                <i class="bi bi-pencil"></i> 수정
                                            </a>
                                            <button type="button" class="btn-sm-modern btn-outline-danger-modern"
                                                    onclick="confirmDelete('${pageContext.request.contextPath}/community/delete?postId=${post.id}')">
                                                <i class="bi bi-trash"></i> 삭제
                                            </button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- 내 댓글 탭 -->
                    <div class="tab-pane fade" id="comments" role="tabpanel" aria-labelledby="comments-tab">
                        <c:choose>
                            <c:when test="${empty userComments}">
                                <div class="empty-state">
                                    <i class="bi bi-chat-dots"></i>
                                    <h4>작성한 댓글이 없습니다</h4>
                                    <p>게시글에 댓글을 남겨 다른 학생들과 소통해보세요!</p>
                                    <a href="${pageContext.request.contextPath}/community" class="btn-modern">
                                        <i class="bi bi-chat-dots"></i>
                                        커뮤니티 가기
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="comment" items="${userComments}">
                                    <div class="activity-item">
                                        <div class="activity-title">
                                            <a href="${pageContext.request.contextPath}/community/post/${comment.postId}" class="text-decoration-none">${comment.postTitle}</a>
                                        </div>
                                        <div class="activity-meta">
                                            <fmt:formatDate value="${comment.date}" pattern="yyyy-MM-dd HH:mm" />
                                        </div>
                                        <p class="mb-2">${comment.content}</p>
                                        <div class="activity-actions">
                                            <button type="button" class="btn-sm-modern btn-outline-danger-modern"
                                                    onclick="confirmDelete('${pageContext.request.contextPath}/community/comment/delete?commentId=${comment.id}&postId=${comment.postId}')">
                                                <i class="bi bi-trash"></i> 삭제
                                            </button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- 내 시간표 탭 -->
                    <div class="tab-pane fade" id="timetable" role="tabpanel" aria-labelledby="timetable-tab">
                        <c:choose>
                            <c:when test="${fn:length(userTimetable) == 0}">
                                <div class="empty-state">
                                    <i class="bi bi-calendar3"></i>
                                    <h4>등록된 시간표가 없습니다</h4>
                                    <p>시간표를 등록하고 체계적으로 학습 계획을 세워보세요!</p>
                                    <a href="${pageContext.request.contextPath}/timetable" class="btn-modern">
                                        <i class="bi bi-plus-circle"></i>
                                        시간표 관리하기
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="timetable-header">
                                    <h5 class="timetable-title">내 시간표</h5>
                                    <a href="${pageContext.request.contextPath}/timetable" class="btn timetable-btn">
                                        <i class="bi bi-pencil"></i>
                                        시간표 관리
                                    </a>
                                </div>

                                <!-- 시간표 강의 목록 -->
                                <div class="course-list-container">
                                    <c:forEach var="course" items="${userTimetable}">
                                        <div class="course-item" style="border-left: 4px solid ${course.color};">
                                            <div class="course-header">
                                                <h6 class="course-title">${course.name}</h6>
                                                <span class="course-time">${course.day} ${course.startTime}:00-${course.endTime}:00</span>
                                            </div>
                                            <div class="course-details">
                                                <span class="course-professor">
                                                    <i class="bi bi-person"></i> ${course.professor}
                                                </span>
                                                <c:if test="${not empty course.location}">
                                                    <span class="course-location">
                                                        <i class="bi bi-geo-alt"></i> ${course.location}
                                                    </span>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- 시간표 그리드 -->
                                <div class="timetable-grid-container mt-4">
                                    <h6 class="mb-3">주간 시간표</h6>
                                    <div class="timetable-container">
                                        <!-- 시간표 테이블 -->
                                        <table class="table timetable">
                                            <thead>
                                            <tr>
                                                <th>시간</th>
                                                <th>월</th>
                                                <th>화</th>
                                                <th>수</th>
                                                <th>목</th>
                                                <th>금</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <c:forEach begin="9" end="18" var="hour">
                                                <tr>
                                                    <td class="time-cell">${hour}:00</td>
                                                    <c:forEach items="월,화,수,목,금" var="day" varStatus="dayStatus">
                                                        <td class="timetable-cell" data-day="${day}" data-hour="${hour}"></td>
                                                    </c:forEach>
                                                </tr>
                                            </c:forEach>
                                            </tbody>
                                        </table>

                                        <!-- 강의 블록들 (절대 위치로 배치) -->
                                        <c:forEach var="course" items="${userTimetable}">
                                            <c:set var="dayIndex" value="0" />
                                            <c:choose>
                                                <c:when test="${course.day eq '월'}"><c:set var="dayIndex" value="0" /></c:when>
                                                <c:when test="${course.day eq '화'}"><c:set var="dayIndex" value="1" /></c:when>
                                                <c:when test="${course.day eq '수'}"><c:set var="dayIndex" value="2" /></c:when>
                                                <c:when test="${course.day eq '목'}"><c:set var="dayIndex" value="3" /></c:when>
                                                <c:when test="${course.day eq '금'}"><c:set var="dayIndex" value="4" /></c:when>
                                            </c:choose>

                                            <c:set var="hourIndex" value="${course.startTime - 9}" />
                                            <c:set var="duration" value="${course.endTime - course.startTime}" />
                                            <c:set var="top" value="${hourIndex * 50 + 41}" /> <!-- 41px은 헤더 높이 -->
                                            <c:set var="left" value="${80 + dayIndex * 104}" /> <!-- 80px은 시간 컬럼, 104px은 대략적인 요일 컬럼 너비 -->
                                            <c:set var="height" value="${duration * 50 - 2}" /> <!-- 50px은 셀 높이, -2는 경계선 조정 -->

                                            <div class="course-block"
                                                 style="top: ${top}px;
                                                         left: ${left}px;
                                                         width: 104px;
                                                         height: ${height}px;
                                                         background-color: ${course.color};"
                                                 data-day-index="${dayIndex}">
                                                <div class="course-block-name">${course.name}</div>
                                                <div class="course-block-professor">${course.professor}</div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- 내 배지 탭 -->
                    <div class="tab-pane fade" id="badges" role="tabpanel" aria-labelledby="badges-tab">
                        <div class="row g-3">
                            <c:forEach var="badge" items="${userBadges}">
                                <div class="col-md-6 col-lg-4">
                                    <div class="badge-card ${badge.earned ? 'earned' : ''}">
                                        <div class="badge-icon">
                                            <i class="bi ${badge.iconClass}"></i>
                                        </div>
                                        <div class="badge-title">${badge.name}</div>
                                        <div class="badge-description">${badge.description}</div>
                                        <c:if test="${!badge.earned}">
                                            <div class="progress-container">
                                                <div class="progress-bar-wrapper">
                                                    <div class="progress-bar-fill" style="width: ${(activityCounts[badge.category] * 100 / badge.requiredCount) > 100 ? 100 : (activityCounts[badge.category] * 100 / badge.requiredCount)}%"></div>
                                                </div>
                                                <div class="progress-text">${activityCounts[badge.category]}/${badge.requiredCount}</div>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script>
    // 삭제 확인 함수
    function confirmDelete(url) {
        if (confirm('정말로 삭제하시겠습니까?')) {
            window.location.href = url;
        }
    }

    // 시간표 강의 블록 위치 및 크기 동적 조정
    document.addEventListener("DOMContentLoaded", function() {
        // 시간표 탭이 활성화될 때 강의 블록 위치 조정
        const timetableTab = document.getElementById("timetable-tab");
        if (timetableTab) {
            timetableTab.addEventListener("click", function() {
                setTimeout(adjustCourseBlocks, 100);
            });
        }

        // 창 크기 변경 시 강의 블록 위치 조정
        window.addEventListener("resize", function() {
            if (document.querySelector("#timetable.show.active")) {
                adjustCourseBlocks();
            }
        });

        // 페이지 로드 시 시간표 탭이 활성화되어 있으면 강의 블록 위치 조정
        if (document.querySelector("#timetable.show.active")) {
            setTimeout(adjustCourseBlocks, 100);
        }

        // 강의 블록 위치 및 크기 조정 함수
        function adjustCourseBlocks() {
            const timetable = document.querySelector(".timetable");
            if (!timetable) return;

            const headerCells = timetable.querySelectorAll("th:not(:first-child)");
            if (headerCells.length === 0) return;

            const timeColWidth = timetable.querySelector("th:first-child").offsetWidth;
            const dayCellWidth = headerCells[0].offsetWidth;

            const courseBlocks = document.querySelectorAll(".course-block");

            courseBlocks.forEach(function(block) {
                const dayIndex = parseInt(block.getAttribute("data-day-index") || 0);
                block.style.width = (dayCellWidth - 4) + "px"; // 4px는 경계선 조정
                block.style.left = (timeColWidth + dayIndex * dayCellWidth + 2) + "px"; // 2px는 경계선 조정
            });
        }

        // 배지 탭이 활성화될 때 정렬 실행
        const badgesTab = document.getElementById('badges-tab');
        if (badgesTab) {
            badgesTab.addEventListener('click', function() {
                setTimeout(sortBadges, 100); // 탭 전환 후 정렬
            });
        }

        // 페이지 로드 시에도 정렬 (배지 탭이 기본 활성화된 경우)
        if (document.querySelector('#badges.show.active')) {
            sortBadges();
        }
    });

    // 배지 정렬 함수
    function sortBadges() {
        const badgesContainer = document.querySelector('#badges .row');
        if (!badgesContainer) return;

        const badgeCards = Array.from(badgesContainer.children);

        // 배지를 3그룹으로 분류
        const earnedBadges = [];
        const inProgressBadges = [];
        const notStartedBadges = [];

        badgeCards.forEach(card => {
            const badgeCard = card.querySelector('.badge-card');
            const progressBar = card.querySelector('.progress-bar-fill');

            if (badgeCard.classList.contains('earned')) {
                earnedBadges.push(card);
            } else if (progressBar && parseInt(progressBar.style.width) > 0) {
                inProgressBadges.push(card);
            } else {
                notStartedBadges.push(card);
            }
        });

        // 진행률 순으로 정렬 (진행중인 배지)
        inProgressBadges.sort((a, b) => {
            const progressA = parseInt(a.querySelector('.progress-bar-fill').style.width) || 0;
            const progressB = parseInt(b.querySelector('.progress-bar-fill').style.width) || 0;
            return progressB - progressA;
        });

        // 컨테이너 비우고 정렬된 순서로 다시 추가
        badgesContainer.innerHTML = '';

        [...earnedBadges, ...inProgressBadges, ...notStartedBadges].forEach(card => {
            badgesContainer.appendChild(card);
        });
    }

    // 배지 진행도 계산 및 적용
    $(document).ready(function() {
        const badgeCard = $('.stat-card.stat-orange');
        const badgeText = badgeCard.find('.stat-number').text();

        if (badgeText.includes('/')) {
            const [current, total] = badgeText.split('/').map(Number);
            const progress = Math.min((current / total) * 100, 100);

            // CSS로 진행도 적용
            badgeCard.css({
                'background': `linear-gradient(90deg, #fed7aa ${progress}%, #fffbeb ${progress}%) !important`
            });
        }
    });
</script>
</body>
</html>
