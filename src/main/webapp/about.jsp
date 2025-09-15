<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>텅장수강러 - 소개</title>
  <!-- 부트스트랩 CSS -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
  <!-- 부트스트랩 아이콘 -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
  <!-- 기본 스타일시트 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
  <!-- 정적 페이지 스타일시트 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/staticstyle.css">
  <!-- 소개 페이지 스타일시트 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/about.css">
</head>
<body>
<!-- 헤더 포함 -->
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="about-container">
  <!-- 히어로 섹션 -->
  <div class="hero-section" id="hero">
    <div class="hero-background">
      <img src="${pageContext.request.contextPath}/resources/images/paper.jpg" alt="authentic garden">
    </div>
    <div class="hero-content">
      <h1 class="hero-title">텅장수강러</h1>
      <p class="hero-subtitle">시간표, 평가, 정보까지. 수강신청 전에 딱 이거 하나</p>
      <a href="#features" class="hero-button">더 알아보기</a>
    </div>
    <div class="scroll-indicator">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 5v14M5 12l7 7 7-7" />
      </svg>
    </div>
  </div>

  <!-- 특징 섹션 -->
  <div id="features" class="features-section">
    <div class="container">
      <h2 class="section-title">텅장수강러가 제공하는 서비스</h2>

      <div class="features-grid">
        <div class="feature-card" id="feature1">
          <div class="feature-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" />
              <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" />
            </svg>
          </div>
          <h3 class="feature-title">실시간 강의 평가</h3>
          <p class="feature-description">
            선배들의 생생한 강의 후기를 통해 수강신청 전에 강의의 질과 난이도를 미리 확인하세요. 텅장수강러는 정직한 리뷰만을 제공합니다.
          </p>
        </div>

        <div class="feature-card" id="feature2">
          <div class="feature-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
              <line x1="16" y1="2" x2="16" y2="6" />
              <line x1="8" y1="2" x2="8" y2="6" />
              <line x1="3" y1="10" x2="21" y2="10" />
            </svg>
          </div>
          <h3 class="feature-title">시간표 관리</h3>
          <p class="feature-description">
            드래그 앤 드롭으로 간편하게 시간표를 만들고 관리하세요. 시간 충돌을 자동으로 감지하고, 최적의 시간표 조합을 추천해 드립니다.
          </p>
        </div>

        <div class="feature-card" id="feature3">
          <div class="feature-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
              <circle cx="9" cy="7" r="4" />
              <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
              <path d="M16 3.13a4 4 0 0 1 0 7.75" />
            </svg>
          </div>
          <h3 class="feature-title">학생 커뮤니티</h3>
          <p class="feature-description">
            같은 학교, 같은 전공의 학생들과 정보를 공유하고 소통하세요. 강의 정보부터 학교생활 꿀팁까지 다양한 이야기가 오갑니다.
          </p>
        </div>
      </div>

      <div class="cta-section">
        <h2 class="cta-title">텅장수강러와 함께 현명한 대학생활을 시작하세요</h2>
        <p class="cta-description">
          이미 10,000명 이상의 학생들이 텅장수강러와 함께하고 있습니다. 지금 바로 가입하고 모든 기능을 무료로 이용해보세요.
        </p>
        <a href="${pageContext.request.contextPath}/register.jsp" class="cta-button">지금 시작하기</a>
      </div>
    </div>
  </div>

  <!-- 스토리 섹션 -->
  <div class="story-section">
    <div class="container">
      <h2 class="section-title">텅장수강러의 스토리</h2>

      <div class="story-content">
        <p>
          텅장수강러는 실제 대학생활에서 겪은 불편함에서 출발한 JSP 기반 웹 프로젝트입니다.
          강의평가와 시간표 관리를 따로따로 하는 것이 불편했던 경험에서 출발해,
          강의 평가, 시간표 구성, 커뮤니티를 한 곳에서 할 수 있는 서비스를 구현했습니다.
        </p>
        <p>
          ‘텅장수강러’라는 이름은 수강신청 장바구니가 텅 빈 순간부터 시작되는 고민을 표현한 말로,
          수강 정보를 함께 채워나가는 도우미가 되고 싶다는 의미를 담고 있습니다.
        </p>
        <p>
          이 프로젝트는 상업적 목적이 아닌, 학생 개발자가 직접 느낀 필요를 바탕으로
          기말 대체 과제로 제작되었으며, 실용성과 공감 중심의 기능 설계를 목표로 했습니다.
        </p>
      </div>
    </div>
  </div>
</div>

<!-- 푸터 포함 -->
<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<!-- jQuery 먼저 로드 -->
<script src="${pageContext.request.contextPath}/resources/js/jquery-3.6.0.min.js"></script>
<!-- 부트스트랩 JS -->
<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<!-- 페이지 스크립트 -->
<script src="${pageContext.request.contextPath}/resources/js/about.js"></script>
</body>
</html>