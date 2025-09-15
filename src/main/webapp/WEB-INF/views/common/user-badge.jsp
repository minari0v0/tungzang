<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 사용법: <jsp:include page="/WEB-INF/views/common/user-badge.jsp"><jsp:param name="grade" value="${user.grade}" /></jsp:include> -->

<c:set var="grade" value="${param.grade}" />
<c:if test="${not empty grade}">
    <span class="user-badge tier-${grade}" title="${grade}">
        <c:choose>
            <c:when test="${grade == '새내기'}">
                <i class="bi bi-shield"></i>
            </c:when>
            <c:when test="${grade == '초급자'}">
                <i class="bi bi-shield-fill"></i>
            </c:when>
            <c:when test="${grade == '숙련자'}">
                <i class="bi bi-star"></i>
            </c:when>
            <c:when test="${grade == '전문가'}">
                <i class="bi bi-star-fill"></i>
            </c:when>
            <c:when test="${grade == '마스터'}">
                <i class="bi bi-trophy-fill"></i>
            </c:when>
            <c:otherwise>
                <i class="bi bi-person"></i>
            </c:otherwise>
        </c:choose>
    </span>
</c:if>

<style>
    .user-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 20px;
        height: 20px;
        border-radius: 50%;
        font-size: 0.75rem;
        margin-left: 0.5rem;
        vertical-align: middle;
    }

    .user-badge.tier-새내기 {
        background: linear-gradient(135deg, #6e6e6e, #9e9e9e);
        color: white;
    }

    .user-badge.tier-초급자 {
        background: linear-gradient(135deg, #cd7f32, #e9967a);
        color: white;
    }

    .user-badge.tier-숙련자 {
        background: linear-gradient(135deg, #c0c0c0, #e0e0e0);
        color: #333;
    }

    .user-badge.tier-전문가 {
        background: linear-gradient(135deg, #ffd700, #ffeaa7);
        color: #333;
        animation: goldGlow 2s infinite;
    }

    .user-badge.tier-마스터 {
        background: linear-gradient(135deg, #9d4db3, #a29bfe);
        color: white;
        animation: masterGlow 2s infinite;
    }

    @keyframes goldGlow {
        0%, 100% { box-shadow: 0 0 5px rgba(255, 215, 0, 0.5); }
        50% { box-shadow: 0 0 10px rgba(255, 215, 0, 0.8); }
    }

    @keyframes masterGlow {
        0%, 100% { box-shadow: 0 0 5px rgba(157, 77, 179, 0.5); }
        50% { box-shadow: 0 0 10px rgba(157, 77, 179, 0.8); }
    }
</style>
