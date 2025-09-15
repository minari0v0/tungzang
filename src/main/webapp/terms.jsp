<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>텅장수강러 - 이용약관</title>
    <!-- 부트스트랩 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <!-- 부트스트랩 아이콘 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <!-- 기본 스타일시트 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <!-- 정적 페이지 스타일시트 -->
    <!-- 소개 페이지 스타일시트 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/staticstyle.css">
</head>
<body>
<!-- 헤더 포함 -->
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="terms-container">
    <div class="container">
        <h1 class="page-title">이용약관</h1>

        <div class="terms-content">
            <h2>1. 이 약관은 왜 있는 거예요?</h2>
            <p>
                이 약관은 텅장수강러를 사용하는 분들이 서로 불편함 없이 잘 사용할 수 있도록 만든 약속이에요. <br>
                법적인 문서라기보단, 서비스 이용 시 참고할 수 있는 안내문에 가까운 내용이에요.
            </p>

            <div style="margin-top: 40px;"></div>

            <h2>2. 텅장수강러는 어떤 서비스인가요?</h2>
            <p>
                이 사이트는 대학생들이 강의평가를 쉽게 찾고, 시간표를 만들고, 서로 정보를 나눌 수 있도록 만든 학생 프로젝트예요. <br>
                아직 완벽하진 않지만, 편하게 써주세요!
            </p>

            <div style="margin-top: 40px;"></div>

            <h2>3. 회원 가입할 때 주의할 점은?</h2>
            <p>
                - 욕설이나 비방 목적의 닉네임은 삼가주세요. <br>
                - 다른 사람인 척하거나 거짓 정보를 입력하면 계정이 삭제될 수 있어요. <br>
                - 만 14세 미만은 가입이 어려워요.
            </p>

            <div style="margin-top: 40px;"></div>

            <h2>4. 게시물에 대해서는?</h2>
            <p>
                강의 평가나 글을 쓸 때는 서로 배려해 주세요. <br>
                허위 정보, 욕설, 광고, 도배 등은 삭제될 수 있어요. <br>
                삭제 요청이 들어오면 관리자가 확인하고 조치할 수 있습니다.
            </p>

            <div style="margin-top: 40px;"></div>

            <h2>5. 언제든 서비스가 바뀔 수 있나요?</h2>
            <p>
                네, 서비스는 개발 중이기 때문에 기능이 추가되거나 없어질 수 있어요. <br>
                중요한 변경이 있을 경우 공지사항에 올릴게요.
            </p>

            <div style="margin-top: 40px;"></div>

            <h2>6. 문의나 제안은 어떻게 하나요?</h2>
            <p>
                개선 의견이나 오류 제보는 언제든지 환영이에요! <br>
                사이트 내 문의하기 또는 메일로 알려주세요.
            </p>

            <p class="terms-footer" style="text-align: center; color: #888; margin-top: 40px; font-size: 0.95em;">
                텅장수강러 이용약관<br>
                최종 수정일: 2025년 6월 3일
            </p>

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