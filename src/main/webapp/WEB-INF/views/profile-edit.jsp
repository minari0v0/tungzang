<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>프로필 수정 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <style>
        .profile-edit-container {
            min-height: 100vh;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            padding: 2rem 0;
        }

        .dark-mode .profile-edit-container {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
        }

        .profile-edit-card {
            background: white;
            border-radius: 1.5rem;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            max-width: 800px;
            margin: 0 auto;
        }

        .dark-mode .profile-edit-card {
            background: #1e293b;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .profile-edit-header {
            background: linear-gradient(135deg, #7e22ce 0%, #a855f7 100%);
            color: white;
            padding: 2rem;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .profile-edit-header::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: radial-gradient(circle at 30% 20%, rgba(255, 255, 255, 0.2) 0%, transparent 50%);
            pointer-events: none;
        }

        .profile-edit-header h2 {
            margin: 0;
            font-weight: 700;
            font-size: 2rem;
            position: relative;
            z-index: 2;
        }

        .profile-edit-header p {
            margin: 0.5rem 0 0;
            opacity: 0.9;
            position: relative;
            z-index: 2;
        }

        .profile-edit-body {
            padding: 2.5rem;
        }

        .form-section {
            margin-bottom: 2rem;
        }

        .form-section-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .dark-mode .form-section-title {
            color: #e2e8f0;
        }

        .form-section-title i {
            color: #7e22ce;
            font-size: 1.1rem;
        }

        .form-group-modern {
            margin-bottom: 1.5rem;
        }

        .form-label-modern {
            font-weight: 600;
            color: #374151;
            margin-bottom: 0.5rem;
            display: block;
        }

        .dark-mode .form-label-modern {
            color: #e5e7eb;
        }

        .form-control-modern {
            width: 100%;
            padding: 0.875rem 1rem;
            border: 2px solid #e5e7eb;
            border-radius: 0.75rem;
            font-size: 1rem;
            transition: all 0.2s ease;
            background: #ffffff;
        }

        .dark-mode .form-control-modern {
            background: #374151;
            border-color: #4b5563;
            color: #e5e7eb;
        }

        .form-control-modern:focus {
            outline: none;
            border-color: #7e22ce;
            box-shadow: 0 0 0 3px rgba(126, 34, 206, 0.1);
        }

        .form-control-modern:disabled {
            background: #f9fafb;
            color: #6b7280;
            cursor: not-allowed;
        }

        .dark-mode .form-control-modern:disabled {
            background: #1f2937;
            color: #9ca3af;
        }

        .form-text-modern {
            font-size: 0.875rem;
            color: #6b7280;
            margin-top: 0.25rem;
        }

        .dark-mode .form-text-modern {
            color: #9ca3af;
        }

        .btn-group-modern {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
        }

        .btn-modern {
            padding: 0.875rem 2rem;
            border-radius: 50px;
            font-weight: 600;
            font-size: 1rem;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-primary-modern {
            background: linear-gradient(135deg, #7e22ce, #a855f7);
            color: white;
        }

        .btn-primary-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(126, 34, 206, 0.3);
        }

        .btn-secondary-modern {
            background: #6b7280;
            color: white;
        }

        .btn-secondary-modern:hover {
            background: #4b5563;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(107, 114, 128, 0.3);
        }

        .alert-modern {
            padding: 1rem 1.5rem;
            border-radius: 0.75rem;
            margin-bottom: 1.5rem;
            border: none;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .alert-danger-modern {
            background: rgba(239, 68, 68, 0.1);
            color: #dc2626;
            border-left: 4px solid #dc2626;
        }

        .alert-success-modern {
            background: rgba(34, 197, 94, 0.1);
            color: #16a34a;
            border-left: 4px solid #16a34a;
        }

        .dark-mode .alert-danger-modern {
            background: rgba(239, 68, 68, 0.2);
            color: #fca5a5;
        }

        .dark-mode .alert-success-modern {
            background: rgba(34, 197, 94, 0.2);
            color: #86efac;
        }

        .breadcrumb-modern {
            background: transparent;
            padding: 0;
            margin-bottom: 2rem;
        }

        .breadcrumb-modern .breadcrumb-item {
            color: #6b7280;
        }

        .breadcrumb-modern .breadcrumb-item.active {
            color: #7e22ce;
            font-weight: 600;
        }

        .breadcrumb-modern .breadcrumb-item a {
            color: #6b7280;
            text-decoration: none;
            transition: color 0.2s ease;
        }

        .breadcrumb-modern .breadcrumb-item a:hover {
            color: #7e22ce;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item {
            color: #9ca3af;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item.active {
            color: #a855f7;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item a {
            color: #9ca3af;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item a:hover {
            color: #a855f7;
        }

        @media (max-width: 768px) {
            .profile-edit-container {
                padding: 1rem;
            }

            .profile-edit-body {
                padding: 1.5rem;
            }

            .btn-group-modern {
                flex-direction: column;
            }

            .btn-modern {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="profile-edit-container">
    <div class="container">
        <!-- 브레드크럼 -->
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb breadcrumb-modern">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/mypage">
                        <i class="bi bi-house"></i> 마이페이지
                    </a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">프로필 수정</li>
            </ol>
        </nav>

        <div class="profile-edit-card">
            <!-- 헤더 -->
            <div class="profile-edit-header">
                <h2><i class="bi bi-person-gear me-2"></i>프로필 수정</h2>
                <p>개인정보를 안전하게 관리하고 업데이트하세요</p>
            </div>

            <!-- 본문 -->
            <div class="profile-edit-body">
                <!-- 오류 메시지 표시 -->
                <c:if test="${not empty error}">
                    <div class="alert-modern alert-danger-modern">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                            ${error}
                    </div>
                </c:if>

                <!-- 성공 메시지 표시 -->
                <c:if test="${not empty param.success}">
                    <div class="alert-modern alert-success-modern">
                        <i class="bi bi-check-circle-fill"></i>
                        프로필이 성공적으로 업데이트되었습니다.
                    </div>
                </c:if>

                <!-- 프로필 수정 폼 -->
                <form action="${pageContext.request.contextPath}/mypage/profile" method="post">
                    <!-- 계정 정보 섹션 -->
                    <div class="form-section">
                        <div class="form-section-title">
                            <i class="bi bi-person-circle"></i>
                            계정 정보
                        </div>

                        <div class="form-group-modern">
                            <label for="username" class="form-label-modern">사용자명</label>
                            <input type="text" class="form-control-modern" id="username" value="${user.username}" disabled>
                            <div class="form-text-modern">
                                <i class="bi bi-info-circle"></i>
                                사용자명은 변경할 수 없습니다.
                            </div>
                        </div>

                        <div class="form-group-modern">
                            <label for="name" class="form-label-modern">이름 *</label>
                            <input type="text" class="form-control-modern" id="name" name="name" value="${user.name}" required>
                        </div>

                        <div class="form-group-modern">
                            <label for="email" class="form-label-modern">이메일 *</label>
                            <input type="email" class="form-control-modern" id="email" name="email" value="${user.email}" required>
                        </div>
                    </div>

                    <!-- 학적 정보 섹션 -->
                    <div class="form-section">
                        <div class="form-section-title">
                            <i class="bi bi-mortarboard"></i>
                            학적 정보
                        </div>

                        <div class="form-group-modern">
                            <label for="department" class="form-label-modern">학과</label>
                            <select class="form-control searchable-select" id="department" name="department">
                                <option value="" ${empty user.department ? 'selected' : ''}>선택하세요</option>

                                <!-- 인문대학 -->
                                <optgroup label="인문대학">
                                    <option value="국어국문학과" ${user.department == '국어국문학과' ? 'selected' : ''}>국어국문학과</option>
                                    <option value="영어영문학과" ${user.department == '영어영문학과' ? 'selected' : ''}>영어영문학과</option>
                                    <option value="불어불문학과" ${user.department == '불어불문학과' ? 'selected' : ''}>불어불문학과</option>
                                    <option value="독어독문학과" ${user.department == '독어독문학과' ? 'selected' : ''}>독어독문학과</option>
                                    <option value="중어중문학과" ${user.department == '중어중문학과' ? 'selected' : ''}>중어중문학과</option>
                                    <option value="일어일문학과" ${user.department == '일어일문학과' ? 'selected' : ''}>일어일문학과</option>
                                    <option value="러시아어문학과" ${user.department == '러시아어문학과' ? 'selected' : ''}>러시아어문학과</option>
                                    <option value="스페인어문학과" ${user.department == '스페인어문학과' ? 'selected' : ''}>스페인어문학과</option>
                                    <option value="철학과" ${user.department == '철학과' ? 'selected' : ''}>철학과</option>
                                    <option value="사학과" ${user.department == '사학과' ? 'selected' : ''}>사학과</option>
                                    <option value="문헌정보학과" ${user.department == '문헌정보학과' ? 'selected' : ''}>문헌정보학과</option>
                                    <option value="언어학과" ${user.department == '언어학과' ? 'selected' : ''}>언어학과</option>
                                </optgroup>

                                <!-- 사회과학대학 -->
                                <optgroup label="사회과학대학">
                                    <option value="정치외교학과" ${user.department == '정치외교학과' ? 'selected' : ''}>정치외교학과</option>
                                    <option value="행정학과" ${user.department == '행정학과' ? 'selected' : ''}>행정학과</option>
                                    <option value="사회학과" ${user.department == '사회학과' ? 'selected' : ''}>사회학과</option>
                                    <option value="심리학과" ${user.department == '심리학과' ? 'selected' : ''}>심리학과</option>
                                    <option value="지리학과" ${user.department == '지리학과' ? 'selected' : ''}>지리학과</option>
                                    <option value="미디어커뮤니케이션학과" ${user.department == '미디어커뮤니케이션학과' ? 'selected' : ''}>미디어커뮤니케이션학과</option>
                                    <option value="사회복지학과" ${user.department == '사회복지학과' ? 'selected' : ''}>사회복지학과</option>
                                    <option value="국제관계학과" ${user.department == '국제관계학과' ? 'selected' : ''}>국제관계학과</option>
                                </optgroup>

                                <!-- 자연과학대학 -->
                                <optgroup label="자연과학대학">
                                    <option value="수학과" ${user.department == '수학과' ? 'selected' : ''}>수학과</option>
                                    <option value="물리학과" ${user.department == '물리학과' ? 'selected' : ''}>물리학과</option>
                                    <option value="화학과" ${user.department == '화학과' ? 'selected' : ''}>화학과</option>
                                    <option value="생물학과" ${user.department == '생물학과' ? 'selected' : ''}>생물학과</option>
                                    <option value="지구환경과학과" ${user.department == '지구환경과학과' ? 'selected' : ''}>지구환경과학과</option>
                                    <option value="천문우주학과" ${user.department == '천문우주학과' ? 'selected' : ''}>천문우주학과</option>
                                    <option value="통계학과" ${user.department == '통계학과' ? 'selected' : ''}>통계학과</option>
                                    <option value="생명과학과" ${user.department == '생명과학과' ? 'selected' : ''}>생명과학과</option>
                                </optgroup>

                                <!-- 공과대학 -->
                                <optgroup label="공과대학">
                                    <option value="기계공학과" ${user.department == '기계공학과' ? 'selected' : ''}>기계공학과</option>
                                    <option value="항공우주공학과" ${user.department == '항공우주공학과' ? 'selected' : ''}>항공우주공학과</option>
                                    <option value="조선해양공학과" ${user.department == '조선해양공학과' ? 'selected' : ''}>조선해양공학과</option>
                                    <option value="전기공학과" ${user.department == '전기공학과' ? 'selected' : ''}>전기공학과</option>
                                    <option value="컴퓨터공학과" ${user.department == '컴퓨터공학과' ? 'selected' : ''}>컴퓨터공학과</option>
                                    <option value="소프트웨어학과" ${user.department == '소프트웨어학과' ? 'selected' : ''}>소프트웨어학과</option>
                                    <option value="AI학과" ${user.department == 'AI학과' ? 'selected' : ''}>AI학과</option>
                                    <option value="화학공학과" ${user.department == '화학공학과' ? 'selected' : ''}>화학공학과</option>
                                    <option value="건축학과" ${user.department == '건축학과' ? 'selected' : ''}>건축학과</option>
                                    <option value="토목공학과" ${user.department == '토목공학과' ? 'selected' : ''}>토목공학과</option>
                                    <option value="산업공학과" ${user.department == '산업공학과' ? 'selected' : ''}>산업공학과</option>
                                    <option value="재료공학과" ${user.department == '재료공학과' ? 'selected' : ''}>재료공학과</option>
                                    <option value="환경공학과" ${user.department == '환경공학과' ? 'selected' : ''}>환경공학과</option>
                                    <option value="원자력공학과" ${user.department == '원자력공학과' ? 'selected' : ''}>원자력공학과</option>
                                </optgroup>

                                <!-- 경영대학 -->
                                <optgroup label="경영대학">
                                    <option value="경영학과" ${user.department == '경영학과' ? 'selected' : ''}>경영학과</option>
                                    <option value="회계학과" ${user.department == '회계학과' ? 'selected' : ''}>회계학과</option>
                                    <option value="경제학과" ${user.department == '경제학과' ? 'selected' : ''}>경제학과</option>
                                    <option value="국제통상학과" ${user.department == '국제통상학과' ? 'selected' : ''}>국제통상학과</option>
                                    <option value="금융학과" ${user.department == '금융학과' ? 'selected' : ''}>금융학과</option>
                                    <option value="마케팅학과" ${user.department == '마케팅학과' ? 'selected' : ''}>마케팅학과</option>
                                </optgroup>

                                <!-- 법과대학 -->
                                <optgroup label="법과대학">
                                    <option value="법학과" ${user.department == '법학과' ? 'selected' : ''}>법학과</option>
                                    <option value="국제법무학과" ${user.department == '국제법무학과' ? 'selected' : ''}>국제법무학과</option>
                                </optgroup>

                                <!-- 의과대학 -->
                                <optgroup label="의과대학">
                                    <option value="의학과" ${user.department == '의학과' ? 'selected' : ''}>의학과</option>
                                    <option value="간호학과" ${user.department == '간호학과' ? 'selected' : ''}>간호학과</option>
                                    <option value="치의학과" ${user.department == '치의학과' ? 'selected' : ''}>치의학과</option>
                                    <option value="약학과" ${user.department == '약학과' ? 'selected' : ''}>약학과</option>
                                    <option value="한의학과" ${user.department == '한의학과' ? 'selected' : ''}>한의학과</option>
                                    <option value="수의학과" ${user.department == '수의학과' ? 'selected' : ''}>수의학과</option>
                                </optgroup>

                                <!-- 교육대학 -->
                                <optgroup label="교육대학">
                                    <option value="교육학과" ${user.department == '교육학과' ? 'selected' : ''}>교육학과</option>
                                    <option value="국어교육과" ${user.department == '국어교육과' ? 'selected' : ''}>국어교육과</option>
                                    <option value="영어교육과" ${user.department == '영어교육과' ? 'selected' : ''}>영어교육과</option>
                                    <option value="수학교육과" ${user.department == '수학교육과' ? 'selected' : ''}>수학교육과</option>
                                    <option value="과학교육과" ${user.department == '과학교육과' ? 'selected' : ''}>과학교육과</option>
                                    <option value="사회교육과" ${user.department == '사회교육과' ? 'selected' : ''}>사회교육과</option>
                                    <option value="체육교육과" ${user.department == '체육교육과' ? 'selected' : ''}>체육교육과</option>
                                    <option value="음악교육과" ${user.department == '음악교육과' ? 'selected' : ''}>음악교육과</option>
                                    <option value="미술교육과" ${user.department == '미술교육과' ? 'selected' : ''}>미술교육과</option>
                                    <option value="유아교육과" ${user.department == '유아교육과' ? 'selected' : ''}>유아교육과</option>
                                    <option value="특수교육과" ${user.department == '특수교육과' ? 'selected' : ''}>특수교육과</option>
                                </optgroup>

                                <!-- 예술대학 -->
                                <optgroup label="예술대학">
                                    <option value="음악학과" ${user.department == '음악학과' ? 'selected' : ''}>음악학과</option>
                                    <option value="미술학과" ${user.department == '미술학과' ? 'selected' : ''}>미술학과</option>
                                    <option value="디자인학과" ${user.department == '디자인학과' ? 'selected' : ''}>디자인학과</option>
                                    <option value="연극영화학과" ${user.department == '연극영화학과' ? 'selected' : ''}>연극영화학과</option>
                                    <option value="무용학과" ${user.department == '무용학과' ? 'selected' : ''}>무용학과</option>
                                    <option value="조형예술학과" ${user.department == '조형예술학과' ? 'selected' : ''}>조형예술학과</option>
                                    <option value="시각디자인학과" ${user.department == '시각디자인학과' ? 'selected' : ''}>시각디자인학과</option>
                                    <option value="산업디자인학과" ${user.department == '산업디자인학과' ? 'selected' : ''}>산업디자인학과</option>
                                </optgroup>

                                <!-- 농업생명과학대학 -->
                                <optgroup label="농업생명과학대학">
                                    <option value="농학과" ${user.department == '농학과' ? 'selected' : ''}>농학과</option>
                                    <option value="원예학과" ${user.department == '원예학과' ? 'selected' : ''}>원예학과</option>
                                    <option value="축산학과" ${user.department == '축산학과' ? 'selected' : ''}>축산학과</option>
                                    <option value="식품공학과" ${user.department == '식품공학과' ? 'selected' : ''}>식품공학과</option>
                                    <option value="산림학과" ${user.department == '산림학과' ? 'selected' : ''}>산림학과</option>
                                    <option value="농업경제학과" ${user.department == '농업경제학과' ? 'selected' : ''}>농업경제학과</option>
                                    <option value="바이오시스템공학과" ${user.department == '바이오시스템공학과' ? 'selected' : ''}>바이오시스템공학과</option>
                                </optgroup>

                                <!-- 생활과학대학 -->
                                <optgroup label="생활과학대학">
                                    <option value="가정교육과" ${user.department == '가정교육과' ? 'selected' : ''}>가정교육과</option>
                                    <option value="식품영양학과" ${user.department == '식품영양학과' ? 'selected' : ''}>식품영양학과</option>
                                    <option value="의류학과" ${user.department == '의류학과' ? 'selected' : ''}>의류학과</option>
                                    <option value="아동가족학과" ${user.department == '아동가족학과' ? 'selected' : ''}>아동가족학과</option>
                                    <option value="소비자학과" ${user.department == '소비자학과' ? 'selected' : ''}>소비자학과</option>
                                </optgroup>

                                <!-- 기타 -->
                                <optgroup label="기타">
                                    <option value="자유전공학부" ${user.department == '자유전공학부' ? 'selected' : ''}>자유전공학부</option>
                                    <option value="글로벌학부" ${user.department == '글로벌학부' ? 'selected' : ''}>글로벌학부</option>
                                    <option value="기타" ${user.department == '기타' ? 'selected' : ''}>기타</option>
                                </optgroup>
                            </select>
                            <div class="form-text-modern">
                                <i class="bi bi-search"></i>
                                학과명을 검색하거나 목록에서 선택하세요
                            </div>
                        </div>

                        <div class="form-group-modern">
                            <label for="studentId" class="form-label-modern">학번</label>
                            <input type="text" class="form-control-modern" id="studentId" name="studentId" value="${user.studentId}" placeholder="예: 2020123456">
                            <div class="form-text-modern">
                                <i class="bi bi-shield-check"></i>
                                학번은 다른 사용자에게 공개되지 않습니다.
                            </div>
                        </div>
                    </div>

                    <!-- 버튼 그룹 -->
                    <div class="btn-group-modern">
                        <button type="submit" class="btn-modern btn-primary-modern">
                            <i class="bi bi-check-lg"></i>
                            저장하기
                        </button>
                        <a href="${pageContext.request.contextPath}/mypage" class="btn-modern btn-secondary-modern">
                            <i class="bi bi-arrow-left"></i>
                            취소
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>
<script>
    $(document).ready(function() {
        // 폼 유효성 검사
        $('form').on('submit', function(e) {
            const name = $('#name').val().trim();
            const email = $('#email').val().trim();

            if (!name) {
                e.preventDefault();
                alert('이름을 입력해주세요.');
                $('#name').focus();
                return false;
            }

            if (!email) {
                e.preventDefault();
                alert('이메일을 입력해주세요.');
                $('#email').focus();
                return false;
            }

            // 이메일 형식 검사
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                e.preventDefault();
                alert('올바른 이메일 형식을 입력해주세요.');
                $('#email').focus();
                return false;
            }
        });

        // 입력 필드 포커스 효과
        $('.form-control-modern').on('focus', function() {
            $(this).parent().addClass('focused');
        }).on('blur', function() {
            $(this).parent().removeClass('focused');
        });

        // 다크 모드 상태 확인 및 적용
        const darkMode = localStorage.getItem('darkMode');
        const prefersDarkScheme = window.matchMedia("(prefers-color-scheme: dark)");

        if (darkMode === 'enabled' || (darkMode === null && prefersDarkScheme.matches)) {
            document.body.classList.add('dark-mode');
        }
    });
</script>
</body>
</html>
