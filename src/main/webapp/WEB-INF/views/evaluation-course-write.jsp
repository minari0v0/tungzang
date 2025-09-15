<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>강의 평가 작성 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login-modal.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <style>
        /* 별점 스타일 */
        .star-rating {
            display: flex;
            flex-direction: row-reverse;
            justify-content: flex-end;
        }
        .star-rating input {
            display: none;
        }
        .star-rating label {
            cursor: pointer;
            width: 30px;
            height: 30px;
            margin: 0 2px;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' width='30' height='30' viewBox='0 0 24 24' fill='none' stroke='%23d1d5db' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolygon points='12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2'%3e%3c/polygon%3e%3c/svg%3e");
            background-repeat: no-repeat;
            transition: all 0.2s ease;
        }
        .star-rating input:checked ~ label,
        .star-rating input:hover ~ label {
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' width='30' height='30' viewBox='0 0 24 24' fill='%23fbbf24' stroke='%23fbbf24' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolygon points='12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2'%3e%3c/polygon%3e%3c/svg%3e");
        }

        /* 슬라이더 스타일 */
        .custom-range {
            -webkit-appearance: none;
            width: 100%;
            height: 8px;
            border-radius: 5px;
            background: #e2e8f0;
            outline: none;
        }
        .custom-range::-webkit-slider-thumb {
            -webkit-appearance: none;
            appearance: none;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: #3b82f6;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .custom-range::-webkit-slider-thumb:hover {
            background: #2563eb;
            transform: scale(1.1);
        }
        .range-value {
            display: inline-block;
            position: relative;
            width: 60px;
            color: #fff;
            line-height: 20px;
            text-align: center;
            border-radius: 3px;
            background: #3b82f6;
            padding: 5px 10px;
            margin-left: 10px;
        }

        /* 특성 태그 스타일 */
        .feature-tag {
            display: inline-block;
            background-color: #f3f4f6;
            border: 1px solid #e5e7eb;
            border-radius: 9999px;
            padding: 8px 16px;
            margin: 5px;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .feature-tag.selected {
            background-color: #3b82f6;
            color: white;
            border-color: #3b82f6;
        }

        /* 토글 스위치 스타일 */
        .toggle-switch {
            position: relative;
            display: inline-block;
            width: 60px;
            height: 34px;
        }
        .toggle-switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }
        .toggle-slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            transition: .4s;
            border-radius: 34px;
        }
        .toggle-slider:before {
            position: absolute;
            content: "";
            height: 26px;
            width: 26px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }
        input:checked + .toggle-slider {
            background-color: #3b82f6;
        }
        input:checked + .toggle-slider:before {
            transform: translateX(26px);
        }

        /* 카드 스타일 */
        .evaluation-card {
            border-radius: 16px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            transition: all 0.3s ease;
        }
        .evaluation-card:hover {
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        /* 버튼 스타일 */
        .btn-submit {
            background-color: #3b82f6;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        .btn-submit:hover {
            background-color: #2563eb;
            transform: translateY(-2px);
        }
        .btn-cancel {
            background-color: #f3f4f6;
            color: #4b5563;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 12px 24px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        .btn-cancel:hover {
            background-color: #e5e7eb;
        }

        /* 텍스트 영역 스타일 */
        .comment-textarea {
            border-radius: 8px;
            border: 1px solid #e5e7eb;
            padding: 12px;
            transition: all 0.3s ease;
        }
        .comment-textarea:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3);
        }

        /* 애니메이션 효과 */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .animate-fade-in {
            animation: fadeIn 0.5s ease-out forwards;
        }

        /* 섹션 구분 */
        .evaluation-section {
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 1px solid #e5e7eb;
        }
        .evaluation-section:last-child {
            border-bottom: none;
        }

        /* 강의 유형 카드 스타일 개선 */
        .course-type-card {
            cursor: pointer;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        .course-type-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }
        .course-type-card.selected {
            border-color: #3b82f6;
            background-color: #ebf5ff;
        }
        .course-type-card.selected .card-body {
            position: relative;
        }
        .course-type-card.selected .card-body:after {
            content: "✓";
            position: absolute;
            top: 10px;
            right: 10px;
            width: 24px;
            height: 24px;
            background-color: #3b82f6;
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }

        /* 결과 모달 스타일 */
        .result-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        .result-modal-content {
            background-color: white;
            border-radius: 16px;
            padding: 30px;
            width: 90%;
            max-width: 400px;
            text-align: center;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
            transform: translateY(20px);
            opacity: 0;
            transition: all 0.3s ease;
        }
        .result-modal.show {
            display: flex;
        }
        .result-modal.show .result-modal-content {
            transform: translateY(0);
            opacity: 1;
        }
        .result-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }
        .result-icon.success {
            background-color: #ecfdf5;
            color: #10b981;
        }
        .result-icon.error {
            background-color: #fef2f2;
            color: #ef4444;
        }
        .result-icon i {
            font-size: 40px;
        }
        .result-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .result-message {
            color: #6b7280;
            margin-bottom: 20px;
        }
        .result-button {
            background-color: #3b82f6;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .result-button:hover {
            background-color: #2563eb;
        }
    </style>
</head>
<body>
<!-- 헤더 포함 -->
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container py-5 animate-fade-in">
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center mb-4">
        <div>
            <h1 class="mb-1">강의평가 작성</h1>
            <p class="text-muted">${course.name} - ${course.professor} 교수님</p>
        </div>
        <a href="${pageContext.request.contextPath}/evaluations/course/${course.id}" class="btn btn-outline-primary">
            <i class="bi bi-arrow-left me-2"></i>강의 상세로 돌아가기
        </a>
    </div>

    <div class="card evaluation-card mb-4">
        <div class="card-header">
            <div class="d-flex justify-content-between align-items-center">
                <h2 class="card-title mb-0">${course.name}</h2>
                <div class="rating-badge">
                    <i class="bi bi-star-fill text-warning me-1"></i>
                    <span class="fw-bold">${course.rating}</span>
                </div>
            </div>
            <p class="text-muted">${course.professor} 교수님 · ${course.department}</p>
        </div>
        <div class="card-body">
            <form id="evaluationForm" method="post" action="${pageContext.request.contextPath}/evaluations/submit">
                <input type="hidden" name="courseId" value="${course.id}">

                <!-- 평점 선택 -->
                <div class="evaluation-section">
                    <label class="form-label fw-bold mb-3">이 강의는 어땠나요?</label>
                    <div class="star-rating mb-2">
                        <input type="radio" id="rating5" name="rating" value="5" required>
                        <label for="rating5" title="5점"></label>
                        <input type="radio" id="rating4" name="rating" value="4">
                        <label for="rating4" title="4점"></label>
                        <input type="radio" id="rating3" name="rating" value="3">
                        <label for="rating3" title="3점"></label>
                        <input type="radio" id="rating2" name="rating" value="2">
                        <label for="rating2" title="2점"></label>
                        <input type="radio" id="rating1" name="rating" value="1">
                        <label for="rating1" title="1점"></label>
                    </div>
                    <div class="rating-text text-muted">별점을 선택해주세요</div>
                </div>

                <!-- 난이도 선택 -->
                <div class="evaluation-section">
                    <label class="form-label fw-bold mb-3">강의 난이도는 어떤가요?</label>
                    <div class="d-flex align-items-center">
                        <input type="range" class="custom-range" id="difficultyRange" min="1" max="5" step="1" value="3">
                        <span class="range-value ms-3" id="difficultyValue">3</span>
                        <input type="hidden" name="difficulty" id="difficulty" value="3">
                    </div>
                    <div class="d-flex justify-content-between mt-2">
                        <span class="text-muted">매우 쉬움</span>
                        <span class="text-muted">매우 어려움</span>
                    </div>
                </div>

                <!-- 과제량 선택 -->
                <div class="evaluation-section">
                    <label class="form-label fw-bold mb-3">과제는 얼마나 많았나요?</label>
                    <div class="d-flex align-items-center">
                        <input type="range" class="custom-range" id="homeworkRange" min="1" max="5" step="1" value="3">
                        <span class="range-value ms-3" id="homeworkValue">3</span>
                        <input type="hidden" name="homework" id="homework" value="3">
                    </div>
                    <div class="d-flex justify-content-between mt-2">
                        <span class="text-muted">매우 적음</span>
                        <span class="text-muted">매우 많음</span>
                    </div>
                </div>

                <!-- 강의 유형 선택 -->
                <div class="evaluation-section">
                    <label class="form-label fw-bold mb-3">이 강의는 어떤 유형인가요?</label>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <div class="card h-100 course-type-card" data-value="major">
                                <div class="card-body text-center py-4">
                                    <i class="bi bi-book fs-1 mb-3"></i>
                                    <h5>전공 필수</h5>
                                    <p class="text-muted small">전공에 필수적인 과목</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <div class="card h-100 course-type-card" data-value="majorElective">
                                <div class="card-body text-center py-4">
                                    <i class="bi bi-journal-text fs-1 mb-3"></i>
                                    <h5>전공 선택</h5>
                                    <p class="text-muted small">전공 관련 선택 과목</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <div class="card h-100 course-type-card" data-value="general">
                                <div class="card-body text-center py-4">
                                    <i class="bi bi-globe fs-1 mb-3"></i>
                                    <h5>교양</h5>
                                    <p class="text-muted small">일반 교양 과목</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <div class="card h-100 course-type-card" data-value="liberal">
                                <div class="card-body text-center py-4">
                                    <i class="bi bi-palette fs-1 mb-3"></i>
                                    <h5>자유 선택</h5>
                                    <p class="text-muted small">자유롭게 선택한 과목</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <input type="hidden" id="courseType" name="courseType" required>
                </div>

                <!-- 강의 특성 선택 -->
                <div class="evaluation-section">
                    <label class="form-label fw-bold mb-3">이 강의의 특성은 무엇인가요? (여러 개 선택 가능)</label>
                    <div class="feature-tags">
                        <span class="feature-tag" data-value="팀 프로젝트">팀 프로젝트</span>
                        <span class="feature-tag" data-value="출석 중요">출석 중요</span>
                        <span class="feature-tag" data-value="과제 많음">과제 많음</span>
                        <span class="feature-tag" data-value="시험 비중 높음">시험 비중 높음</span>
                        <span class="feature-tag" data-value="실습 위주">실습 위주</span>
                        <span class="feature-tag" data-value="이론 위주">이론 위주</span>
                        <span class="feature-tag" data-value="발표 많음">발표 많음</span>
                        <span class="feature-tag" data-value="토론 많음">토론 많음</span>
                        <span class="feature-tag" data-value="학점 잘 줌">학점 잘 줌</span>
                    </div>
                    <div id="selectedFeatures"></div>
                </div>

                <!-- 팀 프로젝트 여부 -->
                <div class="evaluation-section">
                    <label class="form-label fw-bold mb-3">팀 프로젝트가 있나요?</label>
                    <div class="d-flex align-items-center">
                        <label class="toggle-switch me-3">
                            <input type="checkbox" id="teamProjectToggle">
                            <span class="toggle-slider"></span>
                        </label>
                        <span id="teamProjectStatus">없음</span>
                        <input type="hidden" name="teamProject" id="teamProject" value="false">
                    </div>
                </div>

                <!-- 평가 내용 -->
                <div class="evaluation-section">
                    <label for="comment" class="form-label fw-bold mb-3">강의에 대한 솔직한 평가를 작성해주세요</label>
                    <textarea class="form-control comment-textarea" id="comment" name="comment" rows="6"
                              placeholder="이 강의의 장점과 단점, 수강 팁 등을 자유롭게 작성해주세요. (최소 20자 이상)"
                              required minlength="20"></textarea>
                    <div class="d-flex justify-content-between mt-2">
                        <div class="form-text">
                            <span id="charCount">0</span>/1000자
                        </div>
                        <div class="form-text" id="charCountStatus"></div>
                    </div>
                </div>

                <!-- 제출 버튼 -->
                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                    <button type="button" class="btn btn-cancel me-md-2" onclick="history.back()">취소</button>
                    <button type="submit" class="btn btn-submit">평가 제출</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 결과 모달 -->
<div class="result-modal" id="resultModal">
    <div class="result-modal-content">
        <div class="result-icon" id="resultIcon">
            <i class="bi" id="resultIconClass"></i>
        </div>
        <h3 class="result-title" id="resultTitle"></h3>
        <p class="result-message" id="resultMessage"></p>
        <button class="result-button" id="resultButton">확인</button>
    </div>
</div>

<!-- 푸터 포함 -->
<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // 별점 선택 시 텍스트 변경
        const ratingLabels = {
            1: '별로예요 😞',
            2: '그저 그래요 😐',
            3: '괜찮아요 🙂',
            4: '좋아요 😊',
            5: '최고예요! 🤩'
        };

        document.querySelectorAll('input[name="rating"]').forEach(input => {
            input.addEventListener('change', function() {
                document.querySelector('.rating-text').textContent = ratingLabels[this.value];
            });
        });

        // 난이도 슬라이더
        const difficultyRange = document.getElementById('difficultyRange');
        const difficultyValue = document.getElementById('difficultyValue');
        const difficulty = document.getElementById('difficulty');

        difficultyRange.addEventListener('input', function() {
            difficultyValue.textContent = this.value;
            difficulty.value = this.value;
        });

        // 과제량 슬라이더
        const homeworkRange = document.getElementById('homeworkRange');
        const homeworkValue = document.getElementById('homeworkValue');
        const homework = document.getElementById('homework');

        homeworkRange.addEventListener('input', function() {
            homeworkValue.textContent = this.value;
            homework.value = this.value;
        });

        // 강의 유형 선택 - 시각적 피드백 개선
        const courseTypeCards = document.querySelectorAll('.course-type-card');
        const courseTypeInput = document.getElementById('courseType');

        courseTypeCards.forEach(card => {
            card.addEventListener('click', function() {
                // 이전에 선택된 카드의 선택 상태 제거
                courseTypeCards.forEach(c => c.classList.remove('selected'));

                // 현재 카드 선택 상태로 변경
                this.classList.add('selected');

                // hidden input 값 설정
                courseTypeInput.value = this.dataset.value;
                console.log('강의 유형 선택됨:', courseTypeInput.value); // 로깅 추가
            });
        });

        // 강의 특성 태그 선택
        const featureTags = document.querySelectorAll('.feature-tag');
        const selectedFeatures = document.getElementById('selectedFeatures');

        featureTags.forEach(tag => {
            tag.addEventListener('click', function() {
                this.classList.toggle('selected');
                updateSelectedFeatures();
            });
        });

        function updateSelectedFeatures() {
            // 기존 hidden input 제거
            const existingInputs = selectedFeatures.querySelectorAll('input');
            existingInputs.forEach(input => input.remove());

            // 선택된 태그에 대한 hidden input 추가
            const selectedTags = document.querySelectorAll('.feature-tag.selected');
            selectedTags.forEach(tag => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'features';
                input.value = tag.dataset.value;
                selectedFeatures.appendChild(input);
            });
        }

        // 팀 프로젝트 토글
        const teamProjectToggle = document.getElementById('teamProjectToggle');
        const teamProjectStatus = document.getElementById('teamProjectStatus');
        const teamProject = document.getElementById('teamProject');

        teamProjectToggle.addEventListener('change', function() {
            if (this.checked) {
                teamProjectStatus.textContent = '있음';
                teamProject.value = 'true';
            } else {
                teamProjectStatus.textContent = '없음';
                teamProject.value = 'false';
            }
        });

        // 글자 수 카운트 기능
        const commentTextarea = document.getElementById('comment');
        const charCount = document.getElementById('charCount');
        const charCountStatus = document.getElementById('charCountStatus');

        commentTextarea.addEventListener('input', function() {
            const count = this.value.length;
            charCount.textContent = count;

            if (count < 20) {
                charCountStatus.textContent = '최소 20자 이상 작성해주세요';
                charCountStatus.className = 'form-text text-danger';
            } else if (count > 900) {
                charCountStatus.textContent = '거의 다 작성했어요!';
                charCountStatus.className = 'form-text text-warning';
            } else {
                charCountStatus.textContent = '좋은 평가를 작성 중이에요!';
                charCountStatus.className = 'form-text text-success';
            }

            if (count > 1000) {
                this.value = this.value.substring(0, 1000);
                charCount.textContent = 1000;
            }
        });

        // 결과 모달 관련 함수
        const resultModal = document.getElementById('resultModal');
        const resultIcon = document.getElementById('resultIcon');
        const resultIconClass = document.getElementById('resultIconClass');
        const resultTitle = document.getElementById('resultTitle');
        const resultMessage = document.getElementById('resultMessage');
        const resultButton = document.getElementById('resultButton');

        function showResultModal(success, message) {
            if (success) {
                resultIcon.className = 'result-icon success';
                resultIconClass.className = 'bi bi-check-lg';
                resultTitle.textContent = '평가가 작성되었습니다!';
                resultMessage.textContent = message || '소중한 평가를 남겨주셔서 감사합니다.';
            } else {
                resultIcon.className = 'result-icon error';
                resultIconClass.className = 'bi bi-x-lg';
                resultTitle.textContent = '작성에 실패했습니다';
                resultMessage.textContent = message || '잠시 후 다시 시도해주세요.';
            }

            resultModal.classList.add('show');
        }

        resultButton.addEventListener('click', function() {
            resultModal.classList.remove('show');

            // 성공 시에만 강의 상세 페이지로 이동
            if (resultIcon.classList.contains('success')) {
                window.location.href = '${pageContext.request.contextPath}/evaluations/course/${course.id}';
            }
        });

        // 폼 제출 처리
        document.getElementById('evaluationForm').addEventListener('submit', function(e) {
            e.preventDefault(); // 기본 제출 동작 방지

            // 유효성 검사
            let isValid = true;

            // 강의 평가 내용 검사
            const commentTextarea = document.getElementById('comment');
            const comment = commentTextarea.value;
            if (comment.length < 20) {
                isValid = false;
                showResultModal(false, '강의 평가 내용은 최소 20자 이상 작성해주세요.');
                commentTextarea.focus();
                return;
            }

            // 강의 유형 선택 검사 - 추가 로깅
            if (!courseTypeInput.value) {
                console.log('강의 유형이 선택되지 않음');
                isValid = false;
                showResultModal(false, '강의 유형을 선택해주세요.');
                return;
            } else {
                console.log('선택된 강의 유형:', courseTypeInput.value);
            }

            // 별점 선택 검사
            const ratingInputs = document.querySelectorAll('input[name="rating"]:checked');
            if (ratingInputs.length === 0) {
                isValid = false;
                showResultModal(false, '별점을 선택해주세요.');
                return;
            }

            if (!isValid) {
                return;
            }

            // 폼 데이터 로깅
            const formData = new FormData(this);
            console.log('폼 데이터:');
            for (let pair of formData.entries()) {
                console.log(pair[0] + ': ' + pair[1]);
            }

            // 일반 폼 제출 방식으로 변경
            this.method = 'post';
            this.action = '${pageContext.request.contextPath}/evaluations/submit';
            this.submit();
        });

        // URL 파라미터 확인
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('success')) {
            showResultModal(true, '평가가 성공적으로 작성되었습니다!');
        } else if (urlParams.has('error')) {
            showResultModal(false, '평가 작성에 실패했습니다. 다시 시도해주세요.');
        }
    });
</script>
</body>
</html>
