<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>계정 설정 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <style>
        .account-settings-container {
            min-height: 100vh;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            padding: 2rem 0;
        }

        .dark-mode .account-settings-container {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
        }

        .settings-card {
            background: white;
            border-radius: 1.5rem;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            max-width: 800px;
            margin: 0 auto;
        }

        .dark-mode .settings-card {
            background: #1e293b;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .settings-header {
            background: linear-gradient(135deg, #7c3aed 0%, #8b5cf6 100%);
            color: white;
            padding: 2rem;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .settings-header::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: radial-gradient(circle at 30% 20%, rgba(255, 255, 255, 0.2) 0%, transparent 50%);
            pointer-events: none;
        }

        .settings-header h2 {
            margin: 0;
            font-weight: 700;
            font-size: 2rem;
            position: relative;
            z-index: 2;
        }

        .settings-header p {
            margin: 0.5rem 0 0;
            opacity: 0.9;
            position: relative;
            z-index: 2;
        }

        .settings-body {
            padding: 2.5rem;
        }

        .settings-section {
            margin-bottom: 3rem;
            padding: 2rem;
            border: 2px solid #f1f5f9;
            border-radius: 1rem;
            transition: all 0.3s ease;
        }

        .settings-section:hover {
            border-color: #e2e8f0;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }

        .dark-mode .settings-section {
            border-color: #334155;
            background: rgba(51, 65, 85, 0.3);
        }

        .dark-mode .settings-section:hover {
            border-color: #475569;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .dark-mode .section-title {
            color: #e2e8f0;
        }

        .section-description {
            color: #64748b;
            margin-bottom: 2rem;
            font-size: 1rem;
            line-height: 1.6;
        }

        .dark-mode .section-description {
            color: #94a3b8;
        }

        .password-section .section-title {
            color: #7e22ce;
        }

        .password-section .section-title i {
            color: #7e22ce;
        }

        .danger-section {
            border-color: #fecaca;
            background: rgba(254, 202, 202, 0.1);
        }

        .danger-section .section-title {
            color: #dc2626;
        }

        .danger-section .section-title i {
            color: #dc2626;
        }

        .dark-mode .danger-section {
            border-color: #7f1d1d;
            background: rgba(127, 29, 29, 0.2);
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

        .form-text-modern {
            font-size: 0.875rem;
            color: #6b7280;
            margin-top: 0.25rem;
        }

        .dark-mode .form-text-modern {
            color: #9ca3af;
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

        .alert-warning-modern {
            background: rgba(245, 158, 11, 0.1);
            color: #d97706;
            border-left: 4px solid #d97706;
        }

        .dark-mode .alert-danger-modern {
            background: rgba(239, 68, 68, 0.2);
            color: #fca5a5;
        }

        .dark-mode .alert-success-modern {
            background: rgba(34, 197, 94, 0.2);
            color: #86efac;
        }

        .dark-mode .alert-warning-modern {
            background: rgba(245, 158, 11, 0.2);
            color: #fcd34d;
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
            color: #7c3aed;
            font-weight: 600;
        }

        .breadcrumb-modern .breadcrumb-item a {
            color: #6b7280;
            text-decoration: none;
            transition: color 0.2s ease;
        }

        .breadcrumb-modern .breadcrumb-item a:hover {
            color: #7c3aed;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item {
            color: #9ca3af;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item.active {
            color: #8b5cf6;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item a {
            color: #9ca3af;
        }

        .dark-mode .breadcrumb-modern .breadcrumb-item a:hover {
            color: #8b5cf6;
        }

        .password-strength {
            margin-top: 0.5rem;
        }

        .strength-bar {
            height: 4px;
            background: #e5e7eb;
            border-radius: 2px;
            overflow: hidden;
            margin-bottom: 0.5rem;
        }

        .strength-fill {
            height: 100%;
            transition: all 0.3s ease;
            border-radius: 2px;
        }

        .strength-weak { background: #ef4444; width: 25%; }
        .strength-fair { background: #f59e0b; width: 50%; }
        .strength-good { background: #10b981; width: 75%; }
        .strength-strong { background: #059669; width: 100%; }

        .strength-text {
            font-size: 0.75rem;
            font-weight: 500;
        }

        .text-weak { color: #ef4444; }
        .text-fair { color: #f59e0b; }
        .text-good { color: #10b981; }
        .text-strong { color: #059669; }

        .danger-zone {
            background: rgba(254, 202, 202, 0.1);
            border: 2px dashed #fca5a5;
            border-radius: 1rem;
            padding: 2rem;
            text-align: center;
        }

        .dark-mode .danger-zone {
            background: rgba(127, 29, 29, 0.2);
            border-color: #7f1d1d;
        }

        .danger-zone h4 {
            color: #dc2626;
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .dark-mode .danger-zone h4 {
            color: #fca5a5;
        }

        .danger-zone p {
            color: #7f1d1d;
            margin-bottom: 2rem;
            line-height: 1.6;
        }

        .dark-mode .danger-zone p {
            color: #fca5a5;
        }

        @media (max-width: 768px) {
            .account-settings-container {
                padding: 1rem;
            }

            .settings-body {
                padding: 1.5rem;
            }

            .settings-section {
                padding: 1.5rem;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="account-settings-container">
    <div class="container">
        <!-- 브레드크럼 -->
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb breadcrumb-modern">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/mypage">
                        <i class="bi bi-house"></i> 마이페이지
                    </a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">계정 설정</li>
            </ol>
        </nav>

        <div class="settings-card">
            <!-- 헤더 -->
            <div class="settings-header">
                <h2><i class="bi bi-gear me-2"></i>계정 설정</h2>
                <p>비밀번호 변경 및 계정 관리를 안전하게 수행하세요</p>
            </div>

            <!-- 본문 -->
            <div class="settings-body">
                <%-- 성공/오류 메시지 표시 --%>
                <c:if test="${not empty error}">
                    <div class="alert-modern alert-danger-modern">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                            ${error}
                    </div>
                </c:if>

                <c:if test="${not empty param.success}">
                    <div class="alert-modern alert-success-modern">
                        <i class="bi bi-check-circle-fill"></i>
                        <c:choose>
                            <c:when test="${param.success eq 'password_changed'}">
                                비밀번호가 성공적으로 변경되었습니다.
                            </c:when>
                            <c:when test="${param.success eq 'profile_updated'}">
                                프로필이 성공적으로 업데이트되었습니다.
                            </c:when>
                            <c:otherwise>
                                작업이 성공적으로 완료되었습니다.
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <!-- 비밀번호 변경 섹션 -->
                <div class="settings-section password-section">
                    <div class="section-title">
                        <i class="bi bi-shield-lock"></i>
                        비밀번호 변경
                    </div>
                    <div class="section-description">
                        계정 보안을 위해 정기적으로 비밀번호를 변경하는 것을 권장합니다.
                    </div>

                    <form action="${pageContext.request.contextPath}/mypage/change-password" method="post" id="passwordForm">
                        <div class="form-group-modern">
                            <label for="currentPassword" class="form-label-modern">현재 비밀번호 *</label>
                            <input type="password" class="form-control-modern" id="currentPassword" name="currentPassword" required>
                        </div>

                        <div class="form-group-modern">
                            <label for="newPassword" class="form-label-modern">새 비밀번호 *</label>
                            <input type="password" class="form-control-modern" id="newPassword" name="newPassword" required>
                            <div class="form-text-modern">
                                <i class="bi bi-info-circle"></i>
                                8자 이상, 영문, 숫자, 특수문자를 포함해주세요.
                            </div>
                            <div class="password-strength" id="passwordStrength" style="display: none;">
                                <div class="strength-bar">
                                    <div class="strength-fill" id="strengthFill"></div>
                                </div>
                                <div class="strength-text" id="strengthText"></div>
                            </div>
                        </div>

                        <div class="form-group-modern">
                            <label for="confirmPassword" class="form-label-modern">새 비밀번호 확인 *</label>
                            <input type="password" class="form-control-modern" id="confirmPassword" name="confirmPassword" required>
                            <div class="form-text-modern" id="passwordMatch"></div>
                        </div>

                        <button type="submit" class="btn-modern btn-primary-modern">
                            <i class="bi bi-check-lg"></i>
                            비밀번호 변경
                        </button>
                    </form>
                </div>

                <!-- 회원탈퇴 섹션 -->
                <div class="settings-section danger-section">
                    <div class="section-title">
                        <i class="bi bi-exclamation-triangle"></i>
                        위험 구역
                    </div>
                    <div class="section-description">
                        아래 작업들은 되돌릴 수 없습니다. 신중하게 결정해주세요.
                    </div>

                    <div class="danger-zone">
                        <h4><i class="bi bi-person-x me-2"></i>회원탈퇴</h4>
                        <p>
                            계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다.<br>
                            작성한 강의평가, 게시글, 댓글, 시간표 등 모든 정보가 사라집니다.
                        </p>
                        <button type="button" class="btn-modern btn-danger-modern" onclick="showDeleteModal()">
                            <i class="bi bi-trash"></i>
                            계정 삭제
                        </button>
                    </div>
                </div>

                <!-- 뒤로가기 버튼 -->
                <div class="text-center">
                    <a href="${pageContext.request.contextPath}/mypage" class="btn-modern btn-secondary-modern">
                        <i class="bi bi-arrow-left"></i>
                        마이페이지로 돌아가기
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 회원탈퇴 확인 모달 -->
<div class="modal fade" id="deleteAccountModal" tabindex="-1" aria-labelledby="deleteAccountModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title" id="deleteAccountModalLabel">
                    <i class="bi bi-exclamation-triangle me-2"></i>계정 삭제 확인
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="alert alert-danger">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <strong>경고:</strong> 이 작업은 되돌릴 수 없습니다!
                </div>
                <p>정말로 계정을 삭제하시겠습니까?</p>
                <p class="text-muted">삭제되는 데이터:</p>
                <ul class="text-muted">
                    <li>프로필 정보</li>
                    <li>작성한 강의평가</li>
                    <li>작성한 게시글 및 댓글</li>
                    <li>시간표 정보</li>
                    <li>획득한 배지</li>
                </ul>

                <form id="deleteAccountForm" action="${pageContext.request.contextPath}/mypage/delete-account" method="post">
                    <div class="form-group-modern">
                        <label for="deletePassword" class="form-label-modern">비밀번호 확인 *</label>
                        <input type="password" class="form-control-modern" id="deletePassword" name="password" required
                               placeholder="계정 삭제를 위해 비밀번호를 입력하세요">
                    </div>

                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="confirmDelete" required>
                        <label class="form-check-label text-danger fw-bold" for="confirmDelete">
                            위 내용을 모두 확인했으며, 계정 삭제에 동의합니다.
                        </label>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-danger" onclick="deleteAccount()">
                    <i class="bi bi-trash"></i> 계정 삭제
                </button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/jquery-3.6.0.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script>
    $(document).ready(function() {
        // 비밀번호 강도 체크
        $('#newPassword').on('input', function() {
            const password = $(this).val();
            const strengthContainer = $('#passwordStrength');
            const strengthFill = $('#strengthFill');
            const strengthText = $('#strengthText');

            if (password.length === 0) {
                strengthContainer.hide();
                return;
            }

            strengthContainer.show();

            let strength = 0;
            let strengthLabel = '';
            let strengthClass = '';

            // 길이 체크
            if (password.length >= 8) strength++;

            // 영문 체크
            if (/[a-zA-Z]/.test(password)) strength++;

            // 숫자 체크
            if (/\d/.test(password)) strength++;

            // 특수문자 체크
            if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) strength++;

            switch (strength) {
                case 1:
                    strengthLabel = '매우 약함';
                    strengthClass = 'strength-weak text-weak';
                    break;
                case 2:
                    strengthLabel = '약함';
                    strengthClass = 'strength-fair text-fair';
                    break;
                case 3:
                    strengthLabel = '보통';
                    strengthClass = 'strength-good text-good';
                    break;
                case 4:
                    strengthLabel = '강함';
                    strengthClass = 'strength-strong text-strong';
                    break;
                default:
                    strengthLabel = '매우 약함';
                    strengthClass = 'strength-weak text-weak';
            }

            strengthFill.removeClass().addClass('strength-fill ' + strengthClass.split(' ')[0]);
            strengthText.removeClass().addClass('strength-text ' + strengthClass.split(' ')[1]).text(strengthLabel);
        });

        // 비밀번호 확인 체크
        $('#confirmPassword').on('input', function() {
            const newPassword = $('#newPassword').val();
            const confirmPassword = $(this).val();
            const matchText = $('#passwordMatch');

            if (confirmPassword.length === 0) {
                matchText.text('');
                return;
            }

            if (newPassword === confirmPassword) {
                matchText.html('<i class="bi bi-check-circle text-success"></i> 비밀번호가 일치합니다.').removeClass('text-danger').addClass('text-success');
            } else {
                matchText.html('<i class="bi bi-x-circle text-danger"></i> 비밀번호가 일치하지 않습니다.').removeClass('text-success').addClass('text-danger');
            }
        });

        // 비밀번호 변경 폼 유효성 검사
        $('#passwordForm').on('submit', function(e) {
            const currentPassword = $('#currentPassword').val().trim();
            const newPassword = $('#newPassword').val().trim();
            const confirmPassword = $('#confirmPassword').val().trim();

            if (!currentPassword) {
                e.preventDefault();
                alert('현재 비밀번호를 입력해주세요.');
                $('#currentPassword').focus();
                return false;
            }

            if (!newPassword) {
                e.preventDefault();
                alert('새 비밀번호를 입력해주세요.');
                $('#newPassword').focus();
                return false;
            }

            if (newPassword.length < 8) {
                e.preventDefault();
                alert('새 비밀번호는 8자 이상이어야 합니다.');
                $('#newPassword').focus();
                return false;
            }

            if (newPassword !== confirmPassword) {
                e.preventDefault();
                alert('새 비밀번호와 확인 비밀번호가 일치하지 않습니다.');
                $('#confirmPassword').focus();
                return false;
            }

            if (currentPassword === newPassword) {
                e.preventDefault();
                alert('현재 비밀번호와 새 비밀번호가 같습니다. 다른 비밀번호를 입력해주세요.');
                $('#newPassword').focus();
                return false;
            }
        });
    });

    // 회원탈퇴 모달 표시
    function showDeleteModal() {
        const modal = new bootstrap.Modal(document.getElementById('deleteAccountModal'));
        modal.show();
    }

    // 계정 삭제 실행
    function deleteAccount() {
        const password = $('#deletePassword').val().trim();
        const confirmed = $('#confirmDelete').is(':checked');

        if (!password) {
            alert('비밀번호를 입력해주세요.');
            $('#deletePassword').focus();
            return;
        }

        if (!confirmed) {
            alert('계정 삭제에 동의해주세요.');
            $('#confirmDelete').focus();
            return;
        }

        if (confirm('정말로 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) {
            $('#deleteAccountForm').submit();
        }
    }
</script>
</body>
</html>
