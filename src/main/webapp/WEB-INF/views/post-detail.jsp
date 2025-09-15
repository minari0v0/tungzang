<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${post.title} - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container py-5">
    <a href="${pageContext.request.contextPath}/community" class="btn-back mb-4 d-inline-flex align-items-center text-decoration-none">
        <i class="bi bi-arrow-left me-2"></i> 커뮤니티로 돌아가기
    </a>

    <div class="card border-0 shadow mb-4">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-start mb-3">
                <div>
                    <c:choose>
                        <c:when test="${post.likes >= 25}">
                            <span class="badge badge-hot mb-2">인기</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge badge-category mb-2">${post.category}</span>
                        </c:otherwise>
                    </c:choose>
                    <h2 class="card-title">${post.title}</h2>
                </div>
                <span class="badge bg-secondary">조회 ${post.views}</span>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div class="d-flex align-items-center">
                    <div class="avatar me-2">${post.authorName.charAt(0)}</div>
                    <div>
                        <div class="fw-bold">${post.authorName}</div>
                        <div class="post-meta"><fmt:formatDate value="${post.date}" pattern="yyyy-MM-dd HH:mm" /></div>
                    </div>
                </div>

                <c:if test="${sessionScope.user.id == post.userId}">
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/community/edit/${post.id}" class="btn btn-outline-primary btn-sm">
                            <i class="bi bi-pencil me-1"></i>수정
                        </a>
                        <button type="button" class="btn btn-outline-danger btn-sm" data-bs-toggle="modal" data-bs-target="#deleteModal">
                            <i class="bi bi-trash me-1"></i>삭제
                        </button>
                    </div>
                </c:if>
            </div>

            <div class="post-content mb-4">
                ${post.content}
            </div>

            <div class="post-actions d-flex flex-wrap gap-2">
                <button id="likeButton" class="btn btn-like ${userLiked ? 'active' : ''}" onclick="likePost(${post.id})">
                    <i class="bi bi-hand-thumbs-up me-1"></i> 좋아요 <span id="likeCount">${post.likes}</span>
                </button>
                <button class="btn btn-share" onclick="sharePost()">
                    <i class="bi bi-share me-1"></i> 공유
                </button>
                <button class="btn btn-report" data-bs-toggle="modal" data-bs-target="#reportModal">
                    <i class="bi bi-flag me-1"></i> 신고
                </button>
            </div>
        </div>
    </div>

    <!-- 댓글 섹션 -->
    <div class="card border-0 shadow">
        <div class="card-header bg-white">
            <h5 class="mb-0">
                <i class="bi bi-chat-dots me-2"></i>댓글 <span id="commentCount">${comments != null ? comments.size() : 0}</span>개
            </h5>
        </div>
        <div class="card-body">
            <!-- 댓글 작성 폼 -->
            <c:choose>
                <c:when test="${sessionScope.user != null}">
                    <form id="commentForm" class="mb-4">
                        <input type="hidden" id="postId" value="${post.id}">
                        <div class="mb-3">
                            <textarea class="form-control" id="commentContent" rows="3" placeholder="댓글을 작성하세요..." required></textarea>
                        </div>
                        <div class="d-flex justify-content-end">
                            <button type="button" class="btn btn-primary" onclick="submitComment()">
                                <i class="bi bi-send me-1"></i> 댓글 등록
                            </button>
                        </div>
                    </form>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-info mb-4">
                        <i class="bi bi-info-circle me-2"></i>
                        댓글을 작성하려면 <a href="${pageContext.request.contextPath}/login?redirect=community/post/${post.id}" class="alert-link">로그인</a>이 필요합니다.
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- 댓글 목록 -->
            <div id="commentList">
                <c:if test="${empty comments}">
                    <div class="text-center py-4 text-muted" id="noCommentsMessage">
                        <i class="bi bi-chat-square-text" style="font-size: 2rem;"></i>
                        <p class="mt-2">첫 번째 댓글을 작성해보세요!</p>
                    </div>
                </c:if>

                <c:if test="${not empty comments}">
                    <c:forEach var="comment" items="${comments}">
                        <div class="comment-item" id="comment-${comment.id}">
                            <div class="comment-meta">
                                <div class="d-flex align-items-center">
                                    <div class="avatar me-2">${comment.authorName.charAt(0)}</div>
                                    <div>
                                        <span class="comment-author">${comment.authorName}</span>
                                        <span class="comment-date ms-2"><fmt:formatDate value="${comment.date}" pattern="yyyy-MM-dd HH:mm" /></span>
                                    </div>
                                </div>
                                <c:if test="${sessionScope.user.id == comment.authorId}">
                                    <div class="dropdown">
                                        <button class="btn btn-sm text-muted" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                            <i class="bi bi-three-dots-vertical"></i>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end">
                                            <li>
                                                <button type="button" class="dropdown-item text-danger" onclick="deleteComment(${comment.id})">
                                                    <i class="bi bi-trash me-2"></i>삭제
                                                </button>
                                            </li>
                                        </ul>
                                    </div>
                                </c:if>
                            </div>
                            <div class="comment-content">${comment.content}</div>
                            <div class="comment-actions">
                                <button class="btn btn-sm btn-outline-secondary" onclick="replyToComment(${comment.id}, '${comment.authorName}')">
                                    <i class="bi bi-reply me-1"></i> 답글
                                </button>
                                <button class="btn btn-sm btn-outline-secondary" onclick="likeComment(${comment.id}, this)">
                                    <i class="bi bi-hand-thumbs-up me-1"></i> 좋아요 <span class="comment-like-count">${comment.likes}</span>
                                </button>
                                <button class="btn btn-sm btn-outline-danger" onclick="reportComment(${comment.id})">
                                    <i class="bi bi-flag"></i> 신고
                                </button>
                            </div>
                        </div>
                    </c:forEach>
                </c:if>
            </div>
        </div>
    </div>
</div>

<!-- 게시글 삭제 확인 모달 -->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="deleteModalLabel">게시글 삭제</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p class="mb-0">정말로 이 게시글을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <form action="${pageContext.request.contextPath}/community/delete" method="post">
                    <input type="hidden" name="postId" value="${post.id}">
                    <button type="submit" class="btn btn-danger">삭제</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- 게시글 신고 모달 -->
<div class="modal fade" id="reportModal" tabindex="-1" aria-labelledby="reportModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="reportModalLabel">게시글 신고</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="reportForm">
                    <input type="hidden" id="reportPostId" value="${post.id}">
                    <div class="mb-3">
                        <label for="reportReason" class="form-label">신고 사유</label>
                        <select class="form-select" id="reportReason" required>
                            <option value="" selected disabled>신고 사유 선택</option>
                            <option value="spam">스팸</option>
                            <option value="inappropriate">부적절한 콘텐츠</option>
                            <option value="harassment">괴롭힘</option>
                            <option value="false_info">허위 정보</option>
                            <option value="other">기타</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="reportDetail" class="form-label">상세 내용</label>
                        <textarea class="form-control" id="reportDetail" rows="3" placeholder="신고 사유에 대한 상세 내용을 입력하세요..."></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-danger" onclick="submitReport()">신고하기</button>
            </div>
        </div>
    </div>
</div>

<!-- 로그인 필요 모달 -->
<div class="modal fade" id="loginRequiredModal" tabindex="-1" aria-labelledby="loginRequiredModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="loginRequiredModalLabel">로그인 필요</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p class="mb-0">이 기능을 사용하려면 로그인이 필요합니다.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <a href="${pageContext.request.contextPath}/login?redirect=community/post/${post.id}" class="btn btn-primary">로그인</a>
            </div>
        </div>
    </div>
</div>

<!-- 댓글 신고 모달 -->
<div class="modal fade" id="reportCommentModal" tabindex="-1" aria-labelledby="reportCommentModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="reportCommentModalLabel">댓글 신고</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="reportCommentId" value="">
                <div class="mb-3">
                    <label for="reportCommentReason" class="form-label">신고 사유</label>
                    <select class="form-select" id="reportCommentReason" required>
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
                <button type="button" class="btn btn-danger" onclick="submitCommentReport()">신고하기</button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>
<script>
    // 부트스트랩 모달 객체 초기화
    let reportModal;
    let loginRequiredModal;

    document.addEventListener('DOMContentLoaded', function() {
        reportModal = new bootstrap.Modal(document.getElementById('reportModal'));
        loginRequiredModal = new bootstrap.Modal(document.getElementById('loginRequiredModal'));
    });

    // 좋아요 기능
    function likePost(postId) {
        // 로그인 확인
        if (!isLoggedIn()) {
            loginRequiredModal.show();
            return;
        }

        // AJAX 요청으로 처리
        fetch('${pageContext.request.contextPath}/community/like', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'postId=' + postId
        })
            .then(response => {
                if (response.status === 401) {
                    // 인증되지 않은 사용자
                    loginRequiredModal.show();
                    throw new Error('로그인이 필요합니다.');
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    const likeButton = document.getElementById('likeButton');
                    const likeCount = document.getElementById('likeCount');

                    likeCount.textContent = data.likeCount;

                    if (data.liked) {
                        likeButton.classList.add('active');
                    } else {
                        likeButton.classList.remove('active');
                    }
                }
            })
            .catch(error => console.error('Error:', error));
    }

    // 댓글 작성 기능
    function submitComment() {
        // 로그인 확인
        if (!isLoggedIn()) {
            loginRequiredModal.show();
            return;
        }

        const postId = document.getElementById('postId').value;
        const content = document.getElementById('commentContent').value;

        if (!content.trim()) {
            alert('댓글 내용을 입력해주세요.');
            return;
        }

        // AJAX 요청으로 처리
        fetch('${pageContext.request.contextPath}/comments', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'postId=' + postId + '&content=' + encodeURIComponent(content)
        })
            .then(response => {
                if (response.status === 401) {
                    // 인증되지 않은 사용자
                    loginRequiredModal.show();
                    throw new Error('로그인이 필요합니다.');
                }
                return response.json();
            })
            .then(data => {
                // 댓글 목록에 새 댓글 추가
                addCommentToList(data);

                // 댓글 입력창 초기화
                document.getElementById('commentContent').value = '';

                // 댓글 수 업데이트
                updateCommentCount();
            })
            .catch(error => console.error('Error:', error));
    }

    // 댓글 목록에 새 댓글 추가
    function addCommentToList(comment) {
        // 댓글이 없다는 메시지 숨기기
        const noCommentsMessage = document.getElementById('noCommentsMessage');
        if (noCommentsMessage) {
            noCommentsMessage.style.display = 'none';
        }

        const commentList = document.getElementById('commentList');

        // 새 댓글 HTML 생성
        const commentItem = document.createElement('div');
        commentItem.className = 'comment-item';
        commentItem.id = 'comment-' + comment.id;

        // 댓글 작성 시간 포맷팅
        const date = new Date();
        const formattedDate = date.getFullYear() + '-' +
            String(date.getMonth() + 1).padStart(2, '0') + '-' +
            String(date.getDate()).padStart(2, '0') + ' ' +
            String(date.getHours()).padStart(2, '0') + ':' +
            String(date.getMinutes()).padStart(2, '0');

        commentItem.innerHTML = `
            <div class="comment-meta">
                <div class="d-flex align-items-center">
                    <div class="avatar me-2">${comment.authorName.charAt(0)}</div>
                    <div>
                        <span class="comment-author">${comment.authorName}</span>
                        <span class="comment-date ms-2">${formattedDate}</span>
                    </div>
                </div>
                <div class="dropdown">
                    <button class="btn btn-sm text-muted" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-three-dots-vertical"></i>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li>
                            <button type="button" class="dropdown-item text-danger" onclick="deleteComment(${comment.id})">
                                <i class="bi bi-trash me-2"></i>삭제
                            </button>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="comment-content">${comment.content}</div>
            <div class="comment-actions">
                <button class="btn btn-sm btn-outline-secondary" onclick="replyToComment(${comment.id}, '${comment.authorName}')">
                    <i class="bi bi-reply me-1"></i> 답글
                </button>
                <button class="btn btn-sm btn-outline-secondary" onclick="likeComment(${comment.id}, this)">
                    <i class="bi bi-hand-thumbs-up me-1"></i> 좋아요 <span class="comment-like-count">0</span>
                </button>
                <button class="btn btn-sm btn-outline-danger" onclick="reportComment(\${comment.id})">
                  <i class="bi bi-flag"></i> 신고
                </button>
            </div>
        `;

        // 댓글 목록에 추가
        commentList.appendChild(commentItem);
    }

    // 댓글 삭제 기능
    function deleteComment(commentId) {
        if (confirm('정말로 이 댓글을 삭제하시겠습니까?')) {
            // AJAX 요청으로 처리
            fetch('${pageContext.request.contextPath}/community/comment/delete', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'commentId=' + commentId + '&postId=' + ${post.id}
            })
                .then(response => {
                    if (response.ok) {
                        // 댓글 요소 삭제
                        const commentElement = document.getElementById('comment-' + commentId);
                        if (commentElement) {
                            commentElement.remove();
                        }

                        // 댓글 수 업데이트
                        updateCommentCount();

                        // 댓글이 없는 경우 메시지 표시
                        if (document.querySelectorAll('.comment-item').length === 0) {
                            const commentList = document.getElementById('commentList');
                            commentList.innerHTML = `
                            <div class="text-center py-4 text-muted" id="noCommentsMessage">
                                <i class="bi bi-chat-square-text" style="font-size: 2rem;"></i>
                                <p class="mt-2">첫 번째 댓글을 작성해보세요!</p>
                            </div>
                        `;
                        }
                    } else {
                        alert('댓글 삭제에 실패했습니다.');
                    }
                })
                .catch(error => console.error('Error:', error));
        }
    }

    // 댓글 좋아요 기능
    function likeComment(commentId, button) {
        // 로그인 확인
        if (!isLoggedIn()) {
            loginRequiredModal.show();
            return;
        }

        // AJAX 요청으로 처리
        fetch('${pageContext.request.contextPath}/comments/like', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'commentId=' + commentId
        })
            .then(response => {
                if (response.status === 401) {
                    // 인증되지 않은 사용자
                    loginRequiredModal.show();
                    throw new Error('로그인이 필요합니다.');
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    const likeCountElement = button.querySelector('.comment-like-count');
                    likeCountElement.textContent = data.likeCount;

                    if (data.liked) {
                        button.classList.add('active');
                    } else {
                        button.classList.remove('active');
                    }
                }
            })
            .catch(error => console.error('Error:', error));
    }

    // 공유 기능
    function sharePost() {
        // 현재 URL 복사
        const url = window.location.href;
        navigator.clipboard.writeText(url).then(() => {
            alert('게시글 링크가 클립보드에 복사되었습니다.');
        });
    }

    // 댓글 답글 기능
    function replyToComment(commentId, authorName) {
        // 로그인 확인
        if (!isLoggedIn()) {
            loginRequiredModal.show();
            return;
        }

        const commentContent = document.getElementById('commentContent');
        commentContent.value = '@' + authorName + ' ';
        commentContent.focus();

        // 댓글 영역으로 스크롤
        commentContent.scrollIntoView({ behavior: 'smooth' });
    }

    // 게시글 신고 기능
    function reportPost(postId) {
        // 로그인 확인
        if (!isLoggedIn()) {
            loginRequiredModal.show();
            return;
        }

        // 신고 모달 표시
        reportModal.show();
    }

    // 신고 제출
    function submitReport() {
        const postId = document.getElementById('reportPostId').value;
        const reason = document.getElementById('reportReason').value;
        const detail = document.getElementById('reportDetail').value;

        if (!reason) {
            alert('신고 사유를 선택해주세요.');
            return;
        }

        // AJAX 요청으로 처리
        fetch('${pageContext.request.contextPath}/community/report', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'postId=' + postId + '&reason=' + reason + '&detail=' + encodeURIComponent(detail)
        })
            .then(response => {
                if (response.status === 401) {
                    // 인증되지 않은 사용자
                    loginRequiredModal.show();
                    throw new Error('로그인이 필요합니다.');
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    alert('신고가 접수되었습니다. 관리자 검토 후 조치하겠습니다.');
                    reportModal.hide();
                } else {
                    alert('신고 접수에 실패했습니다. 다시 시도해주세요.');
                }
            })
            .catch(error => console.error('Error:', error));
    }

    // 댓글 수 업데이트
    function updateCommentCount() {
        const commentCount = document.querySelectorAll('.comment-item').length;
        document.getElementById('commentCount').textContent = commentCount;
    }

    // 로그인 상태 확인
    function isLoggedIn() {
        return ${sessionScope.user != null};
    }

    // 댓글 신고 기능
    function reportComment(commentId) {
        // 로그인 확인
        if (!isLoggedIn()) {
            loginRequiredModal.show();
            return;
        }

        // 신고 모달 표시
        const reportCommentModal = new bootstrap.Modal(document.getElementById('reportCommentModal'));
        document.getElementById('reportCommentId').value = commentId;
        reportCommentModal.show();
    }

    // 댓글 신고 제출
    function submitCommentReport() {
        const commentId = document.getElementById('reportCommentId').value;
        const reason = document.getElementById('reportCommentReason').value;

        if (!reason) {
            alert('신고 사유를 선택해주세요.');
            return;
        }

        // AJAX 요청으로 처리
        fetch('${pageContext.request.contextPath}/comments/report', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'commentId=' + commentId + '&reason=' + encodeURIComponent(reason)
        })
            .then(response => {
                if (response.status === 401) {
                    // 인증되지 않은 사용자
                    loginRequiredModal.show();
                    throw new Error('로그인이 필요합니다.');
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    alert('신고가 접수되었습니다. 관리자 검토 후 조치하겠습니다.');
                    const reportCommentModal = bootstrap.Modal.getInstance(document.getElementById('reportCommentModal'));
                    reportCommentModal.hide();
                } else {
                    alert(data.message || '신고 접수에 실패했습니다. 다시 시도해주세요.');
                }
            })
            .catch(error => console.error('Error:', error));
    }
</script>
</body>
</html>
