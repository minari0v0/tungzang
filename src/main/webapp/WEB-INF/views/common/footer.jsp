<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<footer class="modern-footer">
  <div class="container">
    <div class="row g-4">
      <div class="col-md-3">
        <h5>텅장수강러</h5>
        <p class="text-muted small">학생들을 위한 강의 평가 및 시간표 관리 플랫폼</p>
        <div class="social-links d-flex mt-3">
          <a href="#">
            <i class="bi bi-facebook"></i>
          </a>
          <a href="#">
            <i class="bi bi-twitter"></i>
          </a>
          <a href="#">
            <i class="bi bi-instagram"></i>
          </a>
          <a href="#">
            <i class="bi bi-youtube"></i>
          </a>
        </div>
      </div>
      <div class="col-md-3">
        <h5>바로가기</h5>
        <ul class="list-unstyled">
          <li><a href="${pageContext.request.contextPath}/timetable.jsp"><i class="bi bi-calendar3 me-2"></i>시간표</a></li>
          <li><a href="${pageContext.request.contextPath}/evaluations.jsp"><i class="bi bi-star me-2"></i>강의평가</a></li>
          <li><a href="${pageContext.request.contextPath}/community"><i class="bi bi-chat-dots me-2"></i>커뮤니티</a></li>
        </ul>
      </div>
      <div class="col-md-3">
        <h5>계정</h5>
        <ul class="list-unstyled">
          <c:choose>
            <c:when test="${empty sessionScope.user}">
              <!-- 로그인하지 않은 경우 -->
              <li><a href="${pageContext.request.contextPath}/login.jsp"><i class="bi bi-box-arrow-in-right me-2"></i>로그인</a></li>
              <li><a href="${pageContext.request.contextPath}/register.jsp"><i class="bi bi-person-plus me-2"></i>회원가입</a></li>
            </c:when>
            <c:otherwise>
              <!-- 로그인한 경우 -->
              <li><a href="${pageContext.request.contextPath}/mypage"><i class="bi bi-person me-2"></i>마이페이지</a></li>
              <li><a href="${pageContext.request.contextPath}/mypage/profile"><i class="bi bi-gear me-2"></i>내 정보 수정</a></li>
              <li><a href="${pageContext.request.contextPath}/mypage/password"><i class="bi bi-shield-lock me-2"></i>비밀번호 변경</a></li>
              <li><a href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>로그아웃</a></li>
            </c:otherwise>
          </c:choose>
        </ul>
      </div>
      <div class="col-md-3">
        <h5>정보</h5>
        <ul class="list-unstyled">
          <li><a href="${pageContext.request.contextPath}/about.jsp"><i class="bi bi-info-circle me-2"></i>소개</a></li>
          <li><a href="${pageContext.request.contextPath}/terms.jsp"><i class="bi bi-file-text me-2"></i>이용약관</a></li>
          <li><a href="${pageContext.request.contextPath}/privacy.jsp"><i class="bi bi-shield me-2"></i>개인정보처리방침</a></li>
        </ul>
      </div>
    </div>
    <div class="copyright">
      <p>&copy; <%= new java.util.Date().getYear() + 1900 %> 텅장수강러. All rights reserved.</p>
    </div>
  </div>
</footer>
