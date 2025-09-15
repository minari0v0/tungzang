<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.minari.tungzang.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    String currentPath = request.getRequestURI();
    boolean isCampusLifeActive = currentPath.contains("/campus-life") ||
            currentPath.contains("/weather") ||
            currentPath.contains("/cafeteria") ||
            currentPath.contains("/academic-calendar");
%>
<!-- Bootstrap Icons 추가 (head 섹션에 이 링크가 없다면 추가해주세요) -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">

<!-- contextPath 전역 변수 설정 -->
<script>
    window.contextPath = "${pageContext.request.contextPath}";
</script>

<!-- "텅장수강러" 홈 링크 스타일 변경 -->
<style>
    .navbar-brand.fw-bold {
        background-color: rgba(126, 34, 206, 0.1);
        padding: 8px 15px;
        border-radius: 8px;
        transition: all 0.3s ease;
    }

    .navbar-brand.fw-bold:hover {
        background-color: rgba(126, 34, 206, 0.2);
        transform: translateY(-2px);
    }

    .dark-mode .navbar-brand.fw-bold {
        background-color: rgba(255, 255, 255, 0.1);
    }

    .dark-mode .navbar-brand.fw-bold:hover {
        background-color: rgba(255, 255, 255, 0.2);
    }

    /* 네비게이션 링크 active 상태 스타일 */
    .navbar-nav .nav-link.active,
    .navbar-nav .dropdown-toggle.active {
        background-color: rgba(126, 34, 206, 0.1) !important;
        color: var(--primary-color) !important;
        border-radius: 8px;
        font-weight: 600;
        transform: translateY(-1px);
        box-shadow: 0 2px 4px rgba(126, 34, 206, 0.2);
    }

    .dark-mode .navbar-nav .nav-link.active,
    .dark-mode .navbar-nav .dropdown-toggle.active {
        background-color: rgba(168, 85, 247, 0.2) !important;
        color: var(--primary-light) !important;
        box-shadow: 0 2px 4px rgba(168, 85, 247, 0.3);
    }

    .navbar-nav .nav-link {
        transition: all 0.3s ease;
        padding: 8px 16px;
        border-radius: 8px;
        margin: 0 4px;
    }

    .navbar-nav .nav-link:hover:not(.active) {
        background-color: rgba(126, 34, 206, 0.05);
        color: var(--primary-color);
        transform: translateY(-1px);
    }

    .dark-mode .navbar-nav .nav-link:hover:not(.active) {
        background-color: rgba(168, 85, 247, 0.1);
        color: var(--primary-light);
    }

    /* 드롭다운 토글 링크가 클릭 가능하도록 설정 */
    .navbar-nav .dropdown-toggle {
        pointer-events: auto;
    }

    .navbar-nav .dropdown-toggle::after {
        margin-left: 0.5rem;
    }

    /* 드롭다운 호버 효과 */

    /* 캠퍼스 생활 링크 컨테이너 스타일 */
    .nav-link-container {
        padding: 8px 16px;
        border-radius: 8px;
        margin: 0 4px;
        transition: all 0.3s ease;
        text-decoration: none;
    }

    .nav-link-container.active {
        background-color: rgba(126, 34, 206, 0.1) !important;
        color: var(--primary-color) !important;
        font-weight: 600;
        transform: translateY(-1px);
        box-shadow: 0 2px 4px rgba(126, 34, 206, 0.2);
    }

    .dark-mode .nav-link-container.active {
        background-color: rgba(168, 85, 247, 0.2) !important;
        color: var(--primary-light) !important;
        box-shadow: 0 2px 4px rgba(168, 85, 247, 0.3);
    }

    .nav-link-container:hover:not(.active) {
        background-color: rgba(126, 34, 206, 0.05);
        color: var(--primary-color);
        transform: translateY(-1px);
    }

    .dark-mode .nav-link-container:hover:not(.active) {
        background-color: rgba(168, 85, 247, 0.1);
        color: var(--primary-light);
    }

    .nav-link-text {
        color: inherit;
        text-decoration: none;
        padding: 0;
        margin: 0;
        background: none;
        border: none;
    }

    .nav-link-text:hover {
        color: inherit;
        text-decoration: none;
    }

    .dropdown-arrow-btn {
        background: none;
        border: none;
        color: inherit;
        padding: 0 0 0 8px;
        margin: 0;
        font-size: 0.8rem;
    }

    .dropdown-arrow-btn:hover {
        color: inherit;
    }

    .dropdown-arrow-btn:focus {
        outline: none;
        box-shadow: none;
    }
</style>

<nav class="navbar navbar-expand-lg navbar-light modern-header">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">텅장수강러</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link login-required <%= request.getRequestURI().contains("/timetable") ? "active" : "" %>"
                       href="${pageContext.request.contextPath}/timetable" data-redirect="timetable">시간표</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <%= request.getRequestURI().contains("/evaluation") ? "active" : "" %>"
                       href="${pageContext.request.contextPath}/evaluationsList">강의평가</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <%= request.getRequestURI().contains("/community") ? "active" : "" %>"
                       href="${pageContext.request.contextPath}/community">커뮤니티</a>
                </li>
                <li class="nav-item dropdown">
                    <div class="nav-link-container d-flex align-items-center <%= isCampusLifeActive ? "active" : "" %>">
                        <a class="nav-link-text" href="${pageContext.request.contextPath}/campus-life">
                            캠퍼스 생활
                        </a>
                        <button class="dropdown-arrow-btn"
                                aria-expanded="false"
                                id="campusLifeDropdown">
                            <i class="bi bi-chevron-down"></i>
                        </button>
                    </div>
                    <ul class="dropdown-menu" aria-labelledby="campusLifeDropdown">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/weather">
                            <i class="bi bi-cloud-sun me-2"></i>캠퍼스 날씨</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/cafeteria">
                            <i class="bi bi-cup-hot me-2"></i>학식 메뉴</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/academic-calendar">
                            <i class="bi bi-calendar-event me-2"></i>학사 일정</a></li>
                    </ul>
                </li>
                <li class="nav-item">
                    <a class="nav-link login-required <%= request.getRequestURI().contains("/badges") ? "active" : "" %>"
                       href="${pageContext.request.contextPath}/badges" data-redirect="badges">
                        <i class="bi bi-trophy me-1"></i>배지 컬렉션
                    </a>
                </li>
            </ul>
            <div class="d-flex align-items-center">
                <div class="nav-buttons">
                    <form class="d-flex search-form" action="${pageContext.request.contextPath}/search" method="get">
                        <input class="form-control" type="search" placeholder="강의 검색" aria-label="Search" name="query">
                        <button class="btn" type="button" id="searchToggle">
                            <i class="bi bi-search icon-center"></i>
                        </button>
                    </form>

                    <!-- 다크 모드 토글 버튼 추가 -->
                    <button id="darkModeToggle" type="button" aria-label="다크 모드 전환">
                        <i class="bi bi-moon icon-center"></i>
                    </button>
                </div>

                <% if(user != null) { %>
                <!-- 로그인된 경우 -->
                <div class="dropdown ms-2">
                    <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                        <%= user.getName() %>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/mypage">
                            <i class="bi bi-person me-2"></i>마이페이지</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/settings">
                            <i class="bi bi-gear me-2"></i>계정 설정</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/timetable">
                            <i class="bi bi-calendar3 me-2"></i>내 시간표</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">
                            <i class="bi bi-box-arrow-right me-2"></i>로그아웃</a></li>
                    </ul>
                </div>
                <% } else { %>
                <!-- 로그인되지 않은 경우 -->
                <a href="${pageContext.request.contextPath}/login.jsp" class="btn-login ms-2">로그인</a>
                <% } %>
            </div>
        </div>
    </div>
</nav>

<!-- 다크 모드 토글 스크립트 -->
<script>
    // 다크 모드 토글 기능
    document.addEventListener('DOMContentLoaded', function() {
        const darkModeToggle = document.getElementById('darkModeToggle');
        const icon = darkModeToggle.querySelector('i');

        // 다크 모드 상태 확인 및 적용
        function applyDarkMode() {
            const darkMode = localStorage.getItem('darkMode');
            const prefersDarkScheme = window.matchMedia("(prefers-color-scheme: dark)");

            if (darkMode === 'enabled' || (darkMode === null && prefersDarkScheme.matches)) {
                document.body.classList.add('dark-mode');
                icon.classList.remove('bi-moon');
                icon.classList.add('bi-sun');
                icon.classList.add('icon-center');
            } else {
                document.body.classList.remove('dark-mode');
                icon.classList.remove('bi-sun');
                icon.classList.add('bi-moon');
                icon.classList.add('icon-center');
            }
        }

        // 초기 다크 모드 상태 적용
        applyDarkMode();

        // 다크 모드 토글 버튼 클릭 이벤트
        darkModeToggle.addEventListener('click', function() {
            if (document.body.classList.contains('dark-mode')) {
                document.body.classList.remove('dark-mode');
                localStorage.setItem('darkMode', 'disabled');
                icon.classList.remove('bi-sun');
                icon.classList.add('bi-moon');
            } else {
                document.body.classList.add('dark-mode');
                localStorage.setItem('darkMode', 'enabled');
                icon.classList.remove('bi-moon');
                icon.classList.add('bi-sun');
            }
            icon.classList.add('icon-center');
        });

        // 검색 토글 기능
        const searchToggle = document.getElementById('searchToggle');
        const searchForm = document.querySelector('.search-form');
        const searchInput = searchForm.querySelector('.form-control');

        searchToggle.addEventListener('click', function() {
            searchForm.classList.toggle('active');
            if (searchForm.classList.contains('active')) {
                searchInput.focus();
            }
        });

        // 검색 입력 필드 외부 클릭 시 닫기
        document.addEventListener('click', function(event) {
            if (!searchForm.contains(event.target) && searchForm.classList.contains('active')) {
                searchForm.classList.remove('active');
            }
        });

        // 검색 폼 제출 처리
        searchForm.addEventListener('submit', function(event) {
            if (!searchForm.classList.contains('active') || searchInput.value.trim() === '') {
                event.preventDefault();
                searchForm.classList.add('active');
                searchInput.focus();
            }
        });

        // 캠퍼스 생활 드롭다운 수동 제어
        const campusLifeDropdown = document.getElementById('campusLifeDropdown');
        const dropdownMenu = document.querySelector('ul[aria-labelledby="campusLifeDropdown"]');

        console.log('캠퍼스 생활 버튼:', campusLifeDropdown);
        console.log('드롭다운 메뉴:', dropdownMenu);

        if (campusLifeDropdown && dropdownMenu) {
            campusLifeDropdown.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();

                console.log('화살표 클릭됨!');

                // 드롭다운 토글
                if (dropdownMenu.classList.contains('show')) {
                    dropdownMenu.classList.remove('show');
                    this.setAttribute('aria-expanded', 'false');
                    console.log('드롭다운 닫힘');
                } else {
                    dropdownMenu.classList.add('show');
                    this.setAttribute('aria-expanded', 'true');
                    console.log('드롭다운 열림');
                }
            });

            // 외부 클릭 시 드롭다운 닫기
            document.addEventListener('click', function(e) {
                if (!campusLifeDropdown.contains(e.target) && !dropdownMenu.contains(e.target)) {
                    dropdownMenu.classList.remove('show');
                    campusLifeDropdown.setAttribute('aria-expanded', 'false');
                }
            });
        } else {
            console.log('드롭다운 요소를 찾을 수 없습니다.');
        }
    });
</script>
