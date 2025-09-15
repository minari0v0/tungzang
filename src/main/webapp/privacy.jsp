<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>텅장수강러 - 개인정보처리방침</title>
    <!-- 부트스트랩 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <!-- 부트스트랩 아이콘 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <!-- 기본 스타일시트 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <!-- 정적 페이지 스타일시트 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/staticstyle.css">
</head>
<body>
<!-- 헤더 포함 -->
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="privacy-container">
    <div class="container">
        <h1 class="page-title">개인정보 처리방침</h1>

        <div class="privacy-content">
            <p>
                텅장수강러(이하 ‘저희 서비스’)는 학생들이 개발한 사이트지만, 여러분의 개인정보는 진지하게 다루고 있습니다.<br>
                관련 법령(개인정보보호법, 정보통신망법 등)을 준수하며, 개인정보와 관련된 불편이나 문의가 있을 경우 신속히 대응할 수 있도록 아래와 같은 방침을 마련했습니다.
            </p>

            <h2>제 1 조 (개인정보의 처리 목적)</h2>
            <p>
                저희는 서비스 제공에 꼭 필요한 최소한의 개인정보만을 처리하며, 다음의 목적으로만 사용합니다.
                만약 사용 목적이 바뀌게 될 경우 별도로 알리고 동의를 구하겠습니다.
            </p>
            <ol>
                <li>
                    <strong>회원 가입 및 관리</strong>
                    <p>
                        가입 의사 확인, 본인 확인, 회원제 서비스 제공, 부정 이용 방지, 알림 발송 등을 위해 개인정보를 사용합니다.
                    </p>
                </li>
                <li>
                    <strong>서비스 제공</strong>
                    <p>강의 평가, 시간표 저장, 커뮤니티 활동 등 서비스를 운영하고 개선하기 위한 정보만을 사용합니다.</p>
                </li>
                <li>
                    <strong>통계 및 서비스 개선</strong>
                    <p>
                        이용자들이 어떤 기능을 많이 사용하는지 파악해 더 나은 기능을 제공하는 데 참고합니다. 광고성 정보는 보내지 않습니다.
                    </p>
                </li>
            </ol>

            <h2>제 2 조 (개인정보 보유 기간)</h2>
            <p>
                수집한 개인정보는 아래 기준에 따라 보관됩니다. 보유 기간이 지나면 안전하게 삭제됩니다.
            </p>
            <ul>
                <li>
                    <strong>회원 가입 및 관리: 회원 탈퇴 시까지</strong>
                    <p>단, 아래의 경우에는 관련 내용이 끝날 때까지 보관할 수 있습니다.</p>
                    <ul>
                        <li>법령 위반으로 인해 조사 중인 경우: 조사 종료 시까지</li>
                        <li>서비스 사용 중 발생한 문제(예: 미정산 내역): 해결 시까지</li>
                    </ul>
                </li>
                <li>
                    <strong>서비스 이용 기록: 서비스 제공 완료 시까지</strong>
                    <p>법령에 따라 일정 기간 보관해야 하는 정보는 다음과 같습니다.</p>
                    <ul>
                        <li>
                            전자상거래법에 따른 보관
                            <ul>
                                <li>표시·광고 관련 기록: 6개월</li>
                                <li>계약·결제·서비스 제공 기록: 5년</li>
                                <li>소비자 불만/분쟁처리 기록: 3년</li>
                            </ul>
                        </li>
                        <li>
                            통신비밀보호법에 따른 보관
                            <ul>
                                <li>접속 로그, IP 정보 등: 3개월</li>
                            </ul>
                        </li>
                    </ul>
                </li>
            </ul>

            <p class="terms-footer" style="margin-top: 50px; padding-top: 20px; border-top: 1px solid #ccc; font-style: italic; color: #555; font-size: 0.95em;">
                텅장수강러 개인정보처리방침<br>
                이 개인정보처리방첨은 2025년 6월 3일부터 적용됩니다.<br>
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
</body>
</html>