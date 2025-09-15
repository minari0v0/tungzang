<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
</head>
<body>
<div class="auth-container">
    <!-- 왼쪽 사이드바 -->
    <div class="auth-sidebar">
        <a href="${pageContext.request.contextPath}/" class="back-home">
            <i class="bi bi-arrow-left"></i> 홈으로
        </a>
        <div class="auth-sidebar-content">
            <a href="${pageContext.request.contextPath}/" class="auth-logo">
                <i class="bi bi-house"></i> 텅장수강러
            </a>
            <h1 class="auth-title">텅장수강러 커뮤니티에 가입하세요</h1>
            <p class="auth-description">회원가입 후 모든 기능을 무료로 이용할 수 있습니다.</p>

            <div class="auth-benefits">
                <div class="auth-benefit-item">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>모든 강의 평가 열람 및 작성</span>
                </div>
                <div class="auth-benefit-item">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>시간표 저장 및 공유</span>
                </div>
                <div class="auth-benefit-item">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>커뮤니티 게시글 작성 및 댓글</span>
                </div>
                <div class="auth-benefit-item">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>학기별 강의 추천 받기</span>
                </div>
            </div>
        </div>
    </div>

    <!-- 오른쪽 회원가입 폼 -->
    <div class="auth-form-container">
        <div class="auth-form-wrapper">
            <h2 class="auth-form-title">회원가입</h2>
            <p class="auth-form-subtitle">텅장수강러 계정을 만들어 다양한 기능을 이용하세요</p>

            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                        ${error}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/auth/register" method="post" id="registerForm" class="compact-form">
                <div class="form-group">
                    <label for="name" class="form-label">이름</label>
                    <input type="text" class="form-control" id="name" name="name" required>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="username" class="form-label">아이디</label>
                            <input type="text" class="form-control" id="username" name="username" required>
                            <div class="form-text small">영문, 숫자 조합 4-20자</div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="email" class="form-label">이메일</label>
                            <input type="email" class="form-control" id="email" name="email" required>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="department" class="form-label">학과</label>
                            <select class="form-control searchable-select" id="department" name="department" required>
                                <option value="" selected disabled>학과 선택</option>

                                <!-- 인문대학 -->
                                <option value="국어국문학과" data-group="인문대학">국어국문학과</option>
                                <option value="영어영문학과" data-group="인문대학">영어영문학과</option>
                                <option value="불어불문학과" data-group="인문대학">불어불문학과</option>
                                <option value="독어독문학과" data-group="인문대학">독어독문학과</option>
                                <option value="중어중문학과" data-group="인문대학">중어중문학과</option>
                                <option value="일어일문학과" data-group="인문대학">일어일문학과</option>
                                <option value="서어서문학과" data-group="인문대학">서어서문학과</option>
                                <option value="언어학과" data-group="인문대학">언어학과</option>
                                <option value="국사학과" data-group="인문대학">국사학과</option>
                                <option value="동양사학과" data-group="인문대학">동양사학과</option>
                                <option value="서양사학과" data-group="인문대학">서양사학과</option>
                                <option value="고고학과" data-group="인문대학">고고학과</option>
                                <option value="철학과" data-group="인문대학">철학과</option>
                                <option value="종교학과" data-group="인문대학">종교학과</option>
                                <option value="미학과" data-group="인문대학">미학과</option>

                                <!-- 사회과학대학 -->
                                <option value="정치외교학과" data-group="사회과학대학">정치외교학과</option>
                                <option value="경제학과" data-group="사회과학대학">경제학과</option>
                                <option value="사회학과" data-group="사회과학대학">사회학과</option>
                                <option value="인류학과" data-group="사회과학대학">인류학과</option>
                                <option value="심리학과" data-group="사회과학대학">심리학과</option>
                                <option value="지리학과" data-group="사회과학대학">지리학과</option>
                                <option value="사회복지학과" data-group="사회과학대학">사회복지학과</option>
                                <option value="언론정보학과" data-group="사회과학대학">언론정보학과</option>

                                <!-- 경영대학 -->
                                <option value="경영학과" data-group="경영대학">경영학과</option>
                                <option value="회계학과" data-group="경영대학">회계학과</option>
                                <option value="국제경영학과" data-group="경영대학">국제경영학과</option>
                                <option value="경영정보학과" data-group="경영대학">경영정보학과</option>

                                <!-- 공과대학 -->
                                <option value="기계공학과" data-group="공과대학">기계공학과</option>
                                <option value="항공우주공학과" data-group="공과대학">항공우주공학과</option>
                                <option value="조선해양공학과" data-group="공과대학">조선해양공학과</option>
                                <option value="전기공학과" data-group="공과대학">전기공학과</option>
                                <option value="컴퓨터공학과" data-group="공과대학">컴퓨터공학과</option>
                                <option value="소프트웨어학과" data-group="공과대학">소프트웨어학과</option>
                                <option value="AI학과" data-group="공과대학">AI학과</option>
                                <option value="화학공학과" data-group="공과대학">화학공학과</option>
                                <option value="재료공학과" data-group="공과대학">재료공학과</option>
                                <option value="건축공학과" data-group="공과대학">건축공학과</option>
                                <option value="토목공학과" data-group="공과대학">토목공학과</option>
                                <option value="산업공학과" data-group="공과대학">산업공학과</option>
                                <option value="전자공학과" data-group="공과대학">전자공학과</option>
                                <option value="정보통신공학과" data-group="공과대학">정보통신공학과</option>

                                <!-- 자연과학대학 -->
                                <option value="수학과" data-group="자연과학대학">수학과</option>
                                <option value="통계학과" data-group="자연과학대학">통계학과</option>
                                <option value="물리학과" data-group="자연과학대학">물리학과</option>
                                <option value="화학과" data-group="자연과학대학">화학과</option>
                                <option value="생물학과" data-group="자연과학대학">생물학과</option>
                                <option value="지구환경과학과" data-group="자연과학대학">지구환경과학과</option>
                                <option value="천문학과" data-group="자연과학대학">천문학과</option>
                                <option value="대기과학과" data-group="자연과학대학">대기과학과</option>

                                <!-- 의과대학 -->
                                <option value="의학과" data-group="의과대학">의학과</option>
                                <option value="간호학과" data-group="의과대학">간호학과</option>

                                <!-- 생활과학대학 -->
                                <option value="소비자학과" data-group="생활과학대학">소비자학과</option>
                                <option value="식품영양학과" data-group="생활과학대학">식품영양학과</option>
                                <option value="의류학과" data-group="생활과학대학">의류학과</option>
                                <option value="아동가족학과" data-group="생활과학대학">아동가족학과</option>

                                <!-- 예술대학 -->
                                <option value="음악학과" data-group="예술대학">음악학과</option>
                                <option value="작곡과" data-group="예술대학">작곡과</option>
                                <option value="성악과" data-group="예술대학">성악과</option>
                                <option value="기악과" data-group="예술대학">기악과</option>
                                <option value="국악과" data-group="예술대학">국악과</option>
                                <option value="미술학과" data-group="예술대학">미술학과</option>
                                <option value="디자인학과" data-group="예술대학">디자인학과</option>
                                <option value="무용학과" data-group="예술대학">무용학과</option>
                                <option value="연극영화학과" data-group="예술대학">연극영화학과</option>

                                <!-- 사범대학 -->
                                <option value="교육학과" data-group="사범대학">교육학과</option>
                                <option value="국어교육과" data-group="사범대학">국어교육과</option>
                                <option value="영어교육과" data-group="사범대학">영어교육과</option>
                                <option value="수학교육과" data-group="사범대학">수학교육과</option>
                                <option value="물리교육과" data-group="사범대학">물리교육과</option>
                                <option value="화학교육과" data-group="사범대학">화학교육과</option>
                                <option value="생물교육과" data-group="사범대학">생물교육과</option>
                                <option value="지구과학교육과" data-group="사범대학">지구과학교육과</option>
                                <option value="체육교육과" data-group="사범대학">체육교육과</option>

                                <!-- 농업생명과학대학 -->
                                <option value="농경제사회학과" data-group="농업생명과학대학">농경제사회학과</option>
                                <option value="식물생산과학과" data-group="농업생명과학대학">식물생산과학과</option>
                                <option value="산림과학과" data-group="농업생명과학대학">산림과학과</option>
                                <option value="응용생물화학과" data-group="농업생명과학대학">응용생물화학과</option>
                                <option value="조경학과" data-group="농업생명과학대학">조경학과</option>
                                <option value="농산업교육과" data-group="농업생명과학대학">농산업교육과</option>

                                <!-- 수의과대학 -->
                                <option value="수의학과" data-group="수의과대학">수의학과</option>

                                <!-- 약학대학 -->
                                <option value="약학과" data-group="약학대학">약학과</option>

                                <!-- 기타 -->
                                <option value="자유전공학과" data-group="기타">자유전공학과</option>
                                <option value="융합과학기술학과" data-group="기타">융합과학기술학과</option>
                                <option value="국제학과" data-group="기타">국제학과</option>
                                <option value="기타" data-group="기타">기타</option>
                            </select>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="studentId" class="form-label">학번</label>
                            <input type="text" class="form-control" id="studentId" name="studentId" required>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="password" class="form-label">비밀번호</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                            <div class="form-text small">영문, 숫자, 특수문자 조합 8자 이상</div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="confirmPassword" class="form-label">비밀번호 확인</label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                        </div>
                    </div>
                </div>

                <div class="form-check mb-3">
                    <input class="form-check-input" type="checkbox" id="agreeTerms" name="agreeTerms" required>
                    <label class="form-check-label" for="agreeTerms">
                        <a href="${pageContext.request.contextPath}/terms.jsp" target="_blank">이용약관</a>과
                        <a href="${pageContext.request.contextPath}/privacy.jsp" target="_blank">개인정보처리방침</a>에 동의합니다.
                    </label>
                </div>

                <button type="submit" class="auth-btn">회원가입</button>
            </form>

            <div class="auth-footer">
                <p>이미 계정이 있으신가요? <a href="${pageContext.request.contextPath}/login.jsp">로그인</a></p>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>
<script>
    document.getElementById('registerForm').addEventListener('submit', function(event) {
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        if (password !== confirmPassword) {
            event.preventDefault();
            alert('비밀번호가 일치하지 않습니다.');
        }
    });

    // 다크 모드 상태 확인 및 적용
    document.addEventListener('DOMContentLoaded', function() {
        const darkMode = localStorage.getItem('darkMode');
        const prefersDarkScheme = window.matchMedia("(prefers-color-scheme: dark)");

        if (darkMode === 'enabled' || (darkMode === null && prefersDarkScheme.matches)) {
            document.body.classList.add('dark-mode');
        }
    });
</script>
</body>
</html>
