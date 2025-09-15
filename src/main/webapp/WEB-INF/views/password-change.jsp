<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>비밀번호 변경 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <style>
        .password-change-container {
            min-height: 100vh;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            padding: 2rem 0;
        }

        .dark-mode .password-change-container {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
        }

        .password-change-card {
            background: white;
            border-radius: 1.5rem;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            max-width: 600px;
            margin: 0 auto;
        }

        .dark-mode .password-change-card {
            background: #1e293b;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .password-change-header {
            background: linear-gradient(135deg, #dc2626 0%, #ef4444 100%);
            color: white;
            padding: 2rem;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .password-change-header::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: radial-gradient(circle at 30% 20%, rgba(255, 255, 255, 0.2) 0%, transparent 50%);
            pointer-events: none;
        }

        .password-change-header h2 {
            margin: 0;
            font-weight: 700;
            font-size: 2rem;
            position: relative;
            z-index: 2;
        }

        .password-change-header p {
            margin: 0.5rem 0 0;
            opacity: 0.9;
            position: relative;
            z-index: 2;
        }

        .password-change-body {
            padding: 2.5rem;
        }

        .security-notice {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            border: 1px solid #f59e0b;
            border-radius: 0.75rem;
            padding: 1rem 1.5rem;
            margin-bottom: 2rem;
            display: flex;
            align-items: flex-start;
            gap: 0.75rem;
        }

        .dark-mode .security-notice {
            background: linear-gradient(135deg, rgba(245, 158, 11, 0.2) 0%, rgba(251, 191, 36, 0.2) 100%);
            border-color: rgba(245, 158, 11, 0.3);
            color: #fbbf24;
        }

        .security-notice i {
            color: #f59e0b;
            font-size: 1.25rem;
            margin-top: 0.125rem;
        }

        .security-notice-content h6 {
            margin: 0 0 0.5rem;
            font-weight: 600;
            color: #92400e;
        }

        .dark-mode .security-notice-content h6 {
            color: #fbbf24;
        }

        .security-notice-content ul {
            margin: 0;
            padding-left: 1rem;
            color: #92400e;
        }

        .dark-mode .security-notice-content ul {
            color: #fbbf24;
        }

        .security-notice-content li {
            font-size: 0.875rem;
            margin-bottom: 0.25rem;
        }

        .form-group-modern {
            margin-bottom: 1.5rem;
            position: relative;
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

        .password-input-wrapper {
            position: relative;
        }

        .form-control-modern {
            width: 100%;
            padding: 0.875rem 3rem 0.875rem 1rem;
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
            border-color: #dc2626;
            box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.1);
        }

        .password-toggle {
            position: absolute;
            right: 1rem;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #6b7280;
            cursor: pointer;
            padding: 0.25rem;
            border-radius: 0.25rem;
            transition: color 0.2s ease;
        }

        .password-toggle:hover {
            color: #374151;
        }

        .dark-mode .password-toggle {
            color: #9ca3af;
        }

        .dark-mode .password-toggle:hover {
            color: #e5e7eb;
        }

        .password-strength {
            margin-top: 0.5rem;
        }

        .password-strength-bar {
            height: 4px;
            background: #e5e7eb;
            border-radius: 2px;
            overflow: hidden;
            margin-bottom: 0.5rem;
        }

        .password-strength-fill {
            height: 100%;
            transition: all 0.3s ease;
            border-radius: 2px;
        }

        .password-strength-text {
            font-size: 0.75rem;
            font-weight: 500;
        }

        .strength-weak {
            background: #ef4444;
            color: #ef4444;
        }

        .strength-medium {
            background: #f59e0b;
            color: #f59e0b;
        }

        .strength-strong {
            background: #10b981;
            color: #10b981;
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

        .btn-danger-modern {
            background: linear-gradient(135deg, #dc2626, #ef4444);
            color: white;
        }

        .btn-danger-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(220, 38, 38, 0.3);
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
            color: #dc2626;
            font-weight: 600;
        }

        .breadcrumb-modern .breadcrumb-item a {
            color: #6b7280;
            text-decoration: none;
            transition: color 0.2s ease;
        }

        .breadcrumb-modern .breadcrumb-item a:hover {
            color: #dc2626;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item {
            color: #9ca3af;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item.active {
            color: #ef4444;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item a {
            color: #9ca3af;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item a:hover {
            color: #ef4444;
        }

        @media (max-width: 768px) {
            .password-change-container {
                padding: 1rem;
            }

            .password-change-body {
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

<div class="password-change-container">
    <div class="container">
        <!-- 브레드크럼 -->
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb breadcrumb-modern">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/mypage">
                        <i class="bi bi-house"></i> 마이페이지
                    </a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">비밀번호 변경</li>
            </ol>
        </nav>

        <div class="password-change-card">
            <!-- 헤더 -->
            <div class="password-change-header">
                <h2><i class="bi bi-shield-lock me-2"></i>비밀번호 변경</h2>
                <p>계정 보안을 위해 정기적으로 비밀번호를 변경해주세요</p>
            </div>

            <!-- 본문 -->
            <div class="password-change-body">
                <!-- 보안 안내 -->
                <div class="security-notice">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                    <div class="security-notice-content">
                        <h6>안전한 비밀번호 가이드</h6>
                        <ul>
                            <li>8자 이상의 영문, 숫자, 특수문자 조합</li>
                            <li>개인정보(이름, 생년월일 등) 사용 금지</li>
                            <li>다른 사이트와 동일한 비밀번호 사용 금지</li>
                        </ul>
                    </div>
                </div>

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
                        비밀번호가 성공적으로 변경되었습니다.
                    </div>
                </c:if>

                <!-- 비밀번호 변경 폼 -->
                <form action="${pageContext.request.contextPath}/mypage/password" method="post" id="passwordForm">
                    <div class="form-group-modern">
                        <label for="currentPassword" class="form-label-modern">현재 비밀번호 *</label>
                        <div class="password-input-wrapper">
                            <input type="password" class="form-control-modern" id="currentPassword" name="currentPassword" required>
                            <button type="button" class="password-toggle" onclick="togglePassword('currentPassword')">
                                <i class="bi bi-eye" id="currentPasswordIcon"></i>
                            </button>
                        </div>
                    </div>

                    <div class="form-group-modern">
                        <label for="newPassword" class="form-label-modern">새 비밀번호 *</label>
                        <div class="password-input-wrapper">
                            <input type="password" class="form-control-modern" id="newPassword" name="newPassword" required>
                            <button type="button" class="password-toggle" onclick="togglePassword('newPassword')">
                                <i class="bi bi-eye" id="newPasswordIcon"></i>
                            </button>
                        </div>
                        <div class="password-strength" id="passwordStrength" style="display: none;">
                            <div class="password-strength-bar">
                                <div class="password-strength-fill" id="strengthBar"></div>
                            </div>
                            <div class="password-strength-text" id="strengthText"></div>
                        </div>
                        <div class="form-text-modern">
                            <i class="bi bi-info-circle"></i>
                            8자 이상의 영문, 숫자, 특수문자 조합을 사용하세요.
                        </div>
                    </div>

                    <div class="form-group-modern">
                        <label for="confirmPassword" class="form-label-modern">새 비밀번호 확인 *</label>
                        <div class="password-input-wrapper">
                            <input type="password" class="form-control-modern" id="confirmPassword" name="confirmPassword" required>
                            <button type="button" class="password-toggle" onclick="togglePassword('confirmPassword')">
                                <i class="bi bi-eye" id="confirmPasswordIcon"></i>
                            </button>
                        </div>
                        <div class="form-text-modern" id="passwordMatch"></div>
                    </div>

                    <!-- 버튼 그룹 -->
                    <div class="btn-group-modern">
                        <button type="submit" class="btn-modern btn-danger-modern" id="submitBtn">
                            <i class="bi bi-shield-check"></i>
                            비밀번호 변경
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
<script>
    function togglePassword(fieldId) {
        const field = document.getElementById(fieldId);
        const icon = document.getElementById(fieldId + 'Icon');

        if (field.type === 'password') {
            field.type = 'text';
            icon.className = 'bi bi-eye-slash';
        } else {
            field.type = 'password';
            icon.className = 'bi bi-eye';
        }
    }

    function checkPasswordStrength(password) {
        let strength = 0;
        let text = '';
        let className = '';

        if (password.length >= 8) strength++;
        if (/[a-z]/.test(password)) strength++;
        if (/[A-Z]/.test(password)) strength++;
        if (/[0-9]/.test(password)) strength++;
        if (/[^A-Za-z0-9]/.test(password)) strength++;

        if (strength < 3) {
            text = '약함';
            className = 'strength-weak';
        } else if (strength < 4) {
            text = '보통';
            className = 'strength-medium';
        } else {
            text = '강함';
            className = 'strength-strong';
        }

        return { strength: (strength / 5) * 100, text, className };
    }

    $(document).ready(function() {
        const newPasswordField = $('#newPassword');
        const confirmPasswordField = $('#confirmPassword');
        const passwordStrength = $('#passwordStrength');
        const strengthBar = $('#strengthBar');
        const strengthText = $('#strengthText');
        const passwordMatch = $('#passwordMatch');
        const submitBtn = $('#submitBtn');

        // 새 비밀번호 강도 체크
        newPasswordField.on('input', function() {
            const password = $(this).val();

            if (password.length > 0) {
                passwordStrength.show();
                const result = checkPasswordStrength(password);

                strengthBar.css('width', result.strength + '%');
                strengthBar.removeClass('strength-weak strength-medium strength-strong');
                strengthBar.addClass(result.className);

                strengthText.text(result.text);
                strengthText.removeClass('strength-weak strength-medium strength-strong');
                strengthText.addClass(result.className);
            } else {
                passwordStrength.hide();
            }

            checkPasswordMatch();
        });

        // 비밀번호 확인 체크
        confirmPasswordField.on('input', checkPasswordMatch);

        function checkPasswordMatch() {
            const newPassword = newPasswordField.val();
            const confirmPassword = confirmPasswordField.val();

            if (confirmPassword.length > 0) {
                if (newPassword === confirmPassword) {
                    passwordMatch.html('<i class="bi bi-check-circle text-success"></i> 비밀번호가 일치합니다.');
                    passwordMatch.removeClass('text-danger').addClass('text-success');
                    submitBtn.prop('disabled', false);
                } else {
                    passwordMatch.html('<i class="bi bi-x-circle text-danger"></i> 비밀번호가 일치하지 않습니다.');
                    passwordMatch.removeClass('text-success').addClass('text-danger');
                    submitBtn.prop('disabled', true);
                }
            } else {
                passwordMatch.text('');
                submitBtn.prop('disabled', false);
            }
        }

        // 폼 제출 시 유효성 검사
        $('#passwordForm').on('submit', function(e) {
            const currentPassword = $('#currentPassword').val().trim();
            const newPassword = $('#newPassword').val().trim();
            const confirmPassword = $('#confirmPassword').val().trim();

            if (!currentPassword || !newPassword || !confirmPassword) {
                e.preventDefault();
                alert('모든 필드를 입력해주세요.');
                return false;
            }

            if (newPassword !== confirmPassword) {
                e.preventDefault();
                alert('새 비밀번호와 확인 비밀번호가 일치하지 않습니다.');
                return false;
            }

            if (newPassword.length < 8) {
                e.preventDefault();
                alert('새 비밀번호는 8자 이상이어야 합니다.');
                return false;
            }
        });
    });
</script>
</body>
</html>
