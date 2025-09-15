<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>강의 평가 상세 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login-modal.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
    <style>
        .evaluation-options-btn {
            background: none;
            border: none;
            color: #6c757d;
            cursor: pointer;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
        }

        .evaluation-options-btn:hover {
            background-color: rgba(0, 0, 0, 0.05);
            color: #495057;
        }

        .dropdown-menu {
            min-width: 8rem;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        }

        .dropdown-item.delete {
            color: #dc3545;
        }

        .dropdown-item.delete:hover {
            background-color: #f8d7da;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container py-5">
    <div class="mb-4">
        <a href="${pageContext.request.contextPath}/evaluations" class="btn-back">
            <i class="bi bi-arrow-left"></i> 강의 평가 목록으로
        </a>
    </div>

    <div class="card mb-4">
        <div class="card-header">
            <div class="d-flex justify-content-between align-items-start">
                <h2 class="card-title mb-0">${course.name}</h2>
                <div class="rating-badge">
                    <i class="bi bi-star-fill text-warning me-1"></i>
                    <span class="fw-bold fs-4">${course.rating}</span>
                </div>
            </div>
            <p class="text-muted">${course.professor} 교수님 · ${course.department}</p>
        </div>
        <div class="card-body">
            <div class="row mb-4">
                <div class="col-md-8">
                    <h4 class="mb-3">강의 정보</h4>
                    <div class="d-flex flex-wrap gap-2 mb-3">
                        <c:forEach var="tag" items="${course.tags}">
                            <span class="badge course-tag">${tag}</span>
                        </c:forEach>
                    </div>
                    <p>${course.name} 강의에 대한 상세 정보입니다.</p>
                </div>
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="mb-3">강의 통계</h5>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span>난이도</span>
                                    <span class="fw-bold">${course.difficulty}</span>
                                </div>
                                <div class="progress">
                                    <div class="progress-bar bg-primary" role="progressbar" style="width: ${course.difficulty * 20}%" aria-valuenow="${course.difficulty * 20}" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span>과제량</span>
                                    <span class="fw-bold">${course.homework}</span>
                                </div>
                                <div class="progress">
                                    <div class="progress-bar bg-primary" role="progressbar" style="width: ${course.homework * 20}%" aria-valuenow="${course.homework * 20}" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span>시험 횟수</span>
                                    <span class="fw-bold">${course.examCount}회</span>
                                </div>
                            </div>
                            <div>
                                <div class="d-flex justify-content-between mb-1">
                                    <span>평가 수</span>
                                    <span class="fw-bold">${course.evaluationCount}개</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4>강의 평가</h4>
                <a href="${pageContext.request.contextPath}/evaluations/write/${course.id}" class="btn btn-primary">
                    <i class="bi bi-pencil-fill me-1"></i> 평가 작성하기
                </a>
            </div>

            <c:if test="${empty evaluations}">
                <div class="empty-state">
                    <i class="bi bi-chat-square-text fs-1 mb-3"></i>
                    <h3 class="mb-3">아직 작성된 평가가 없습니다</h3>
                    <p class="mb-4">첫 번째 평가를 작성해보세요!</p>
                    <a href="${pageContext.request.contextPath}/evaluations/write/${course.id}" class="btn btn-primary">
                        <i class="bi bi-pencil-fill me-1"></i> 평가 작성하기
                    </a>
                </div>
            </c:if>

            <div id="evaluation-list">
                <c:forEach var="evaluation" items="${evaluations}" varStatus="status">
                    <div class="card mb-3" id="evaluation-${evaluation.id}">
                        <div class="card-body">
                            <div class="d-flex justify-content-between mb-2">
                                <div class="d-flex align-items-center">
                                    <div class="avatar me-2">${evaluation.authorInitial}</div>
                                    <div>
                                        <div class="fw-bold">${evaluation.authorName}</div>
                                        <div class="text-muted small">${evaluation.semester}</div>
                                    </div>
                                </div>
                                <div class="d-flex align-items-center">
                                    <div class="me-2">
                                        <i class="bi bi-star-fill text-warning me-1"></i>
                                        <span class="fw-bold">${evaluation.rating}</span>
                                    </div>

                                    <!-- 햄버거 메뉴 (옵션) 버튼 추가 -->
                                    <c:if test="${user != null && user.id == evaluation.userId}">
                                        <div class="dropdown">
                                            <button class="evaluation-options-btn" type="button" id="options-${evaluation.id}" data-bs-toggle="dropdown" aria-expanded="false">
                                                <i class="bi bi-three-dots-vertical"></i>
                                            </button>
                                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="options-${evaluation.id}">
                                                <li>
                                                    <button class="dropdown-item delete"
                                                            onclick="deleteEvaluation(${evaluation.id}, ${course.id})">
                                                        <i class="bi bi-trash me-2"></i>삭제하기
                                                    </button>
                                                </li>
                                            </ul>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                            <div class="mb-3">
                                <h5>${evaluation.title}</h5>
                                <p>${evaluation.content}</p>
                            </div>
                            <div class="d-flex flex-wrap gap-2 mb-3">
                                <span class="badge course-tag">난이도: ${evaluation.difficulty}</span>
                                <span class="badge course-tag">과제: ${evaluation.homework}</span>
                                <span class="badge course-tag">성적:
                  <c:choose>
                      <c:when test="${evaluation.grading == 0}">A+</c:when>
                      <c:when test="${evaluation.grading == 1}">A</c:when>
                      <c:when test="${evaluation.grading == 2}">B+</c:when>
                      <c:when test="${evaluation.grading == 3}">B</c:when>
                      <c:when test="${evaluation.grading == 4}">C+</c:when>
                      <c:when test="${evaluation.grading == 5}">C</c:when>
                      <c:when test="${evaluation.grading == 6}">D</c:when>
                      <c:when test="${evaluation.grading == 7}">F</c:when>
                      <c:otherwise>-</c:otherwise>
                  </c:choose>
                </span>
                            </div>
                            <div class="d-flex justify-content-between">
                                <div class="text-muted small">
                                    <fmt:formatDate value="${evaluation.date}" pattern="yyyy-MM-dd" />
                                </div>
                                <div>
                                    <button class="btn btn-sm btn-outline-primary me-1 ${evaluation.liked ? 'active' : ''}" onclick="likeEvaluation(${evaluation.id})">
                                        <i class="bi bi-hand-thumbs-up"></i> 도움됨 ${evaluation.likes}
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger ${evaluation.reported ? 'active' : ''}" onclick="reportEvaluation(${evaluation.id})">
                                        <i class="bi bi-flag"></i> 신고
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- 페이지네이션 -->
            <c:if test="${not empty evaluations}">
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center">
                        <c:if test="${currentPage > 1}">
                            <li class="page-item">
                                <a class="page-link" href="${pageContext.request.contextPath}/evaluations/course/${course.id}?page=${currentPage - 1}" aria-label="Previous">
                                    <span aria-hidden="true">&laquo;</span>
                                </a>
                            </li>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/evaluations/course/${course.id}?page=${i}">${i}</a>
                            </li>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <li class="page-item">
                                <a class="page-link" href="${pageContext.request.contextPath}/evaluations/course/${course.id}?page=${currentPage + 1}" aria-label="Next">
                                    <span aria-hidden="true">&raquo;</span>
                                </a>
                            </li>
                        </c:if>
                    </ul>
                </nav>
            </c:if>
        </div>
    </div>
</div>

<!-- 삭제 확인 모달 -->
<div class="modal fade" id="deleteConfirmModal" tabindex="-1" aria-labelledby="deleteConfirmModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="deleteConfirmModalLabel">평가 삭제 확인</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                정말로 이 강의 평가를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-danger" id="confirmDeleteBtn">삭제</button>
            </div>
        </div>
    </div>
</div>

<!-- 평가 신고 모달 -->
<div class="modal fade" id="reportEvaluationModal" tabindex="-1" aria-labelledby="reportEvaluationModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="reportEvaluationModalLabel">강의평가 신고</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="reportEvaluationId" value="">
                <div class="mb-3">
                    <label for="reportEvaluationReason" class="form-label">신고 사유</label>
                    <select class="form-select" id="reportEvaluationReason" required>
                        <option value="" selected disabled>신고 사유 선택</option>
                        <option value="spam">스팸</option>
                        <option value="inappropriate">부적절한 콘텐츠</option>
                        <option value="harassment">괴롭힘</option>
                        <option value="false_info">허위 정보</option>
                        <option value="other">기타</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-danger" onclick="submitEvaluationReport()">신고하기</button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>

<script>
    function likeEvaluation(id) {
        // 좋아요 기능 구현
        alert('평가에 도움됨을 표시했습니다.');
    }

    function reportEvaluation(id) {
        // 로그인 확인
        if (!${user != null}) {
            alert('신고하려면 로그인이 필요합니다.');
            window.location.href = '${pageContext.request.contextPath}/login?redirect=evaluations/course/${course.id}';
            return;
        }

        // 신고 모달 표시
        const reportModal = new bootstrap.Modal(document.getElementById('reportEvaluationModal'));
        document.getElementById('reportEvaluationId').value = id;
        reportModal.show();
    }

    function submitEvaluationReport() {
        const evaluationId = document.getElementById('reportEvaluationId').value;
        const reason = document.getElementById('reportEvaluationReason').value;

        if (!reason) {
            alert('신고 사유를 선택해주세요.');
            return;
        }

        // AJAX 요청으로 처리
        fetch('${pageContext.request.contextPath}/evaluations/report/' + evaluationId, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'reason=' + encodeURIComponent(reason)
        })
            .then(response => {
                if (response.status === 401) {
                    alert('로그인이 필요합니다.');
                    return;
                }
                return response.json();
            })
            .then(data => {
                if (data && data.success) {
                    alert('신고가 접수되었습니다. 관리자 검토 후 조치하겠습니다.');
                    const reportModal = bootstrap.Modal.getInstance(document.getElementById('reportEvaluationModal'));
                    reportModal.hide();
                } else {
                    alert(data && data.message ? data.message : '신고 접수에 실패했습니다. 다시 시도해주세요.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('신고 처리 중 오류가 발생했습니다.');
            });
    }

    // 평가 삭제 기능
    let currentEvaluationId = null;
    let currentCourseId = null;

    function deleteEvaluation(evaluationId, courseId) {
        currentEvaluationId = evaluationId;
        currentCourseId = courseId;

        // 삭제 확인 모달 표시
        const deleteModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
        deleteModal.show();
    }

    // 삭제 확인 버튼 클릭 이벤트
    document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
        if (currentEvaluationId) {
            // AJAX 요청으로 평가 삭제
            fetch('${pageContext.request.contextPath}/evaluations/delete/' + currentEvaluationId, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('서버 응답 오류: ' + response.status);
                    }
                    return response.json();
                })
                .then(data => {
                    // 모달 닫기
                    const deleteModal = bootstrap.Modal.getInstance(document.getElementById('deleteConfirmModal'));
                    deleteModal.hide();

                    if (data.success) {
                        // 성공적으로 삭제된 경우 UI에서 해당 평가 제거
                        const evaluationElement = document.getElementById('evaluation-' + currentEvaluationId);
                        if (evaluationElement) {
                            evaluationElement.remove();
                        }

                        // 평가 개수 업데이트
                        const evaluationCountElement = document.querySelector('h4');
                        if (evaluationCountElement) {
                            const currentCount = parseInt(evaluationCountElement.innerText.match(/\d+/)[0]) - 1;
                            evaluationCountElement.innerText = '강의 평가 (' + currentCount + ')';
                        }

                        // 알림 표시
                        alert('평가가 성공적으로 삭제되었습니다.');

                        // 평가가 없는 경우 메시지 표시
                        const evaluationList = document.getElementById('evaluation-list');
                        if (evaluationList.children.length === 0) {
                            evaluationList.innerHTML = `
              <div class="empty-state">
                <i class="bi bi-chat-square-text fs-1 mb-3"></i>
                <h3 class="mb-3">아직 작성된 평가가 없습니다</h3>
                <p class="mb-4">첫 번째 평가를 작성해보세요!</p>
                <a href="${pageContext.request.contextPath}/evaluations/write/${course.id}" class="btn btn-primary">
                  <i class="bi bi-pencil-fill me-1"></i> 평가 작성하기
                </a>
              </div>
            `;
                        }
                    } else {
                        // 삭제 실패 시 오류 메시지 표시
                        alert('평가 삭제에 실패했습니다: ' + (data.message || '알 수 없는 오류가 발생했습니다.'));
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('평가 삭제 중 오류가 발생했습니다. 다시 시도해주세요.');
                });
        }
    });
</script>
</body>
</html>
