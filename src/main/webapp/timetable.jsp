<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>시간표 - 텅장수강러</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login-modal.css">
  <style>
    /* 시간표 스타일 개선 */
    .timetable-container {
      position: relative;
      overflow: visible;
      margin-top: 20px;
      min-height: 720px; /* 시간표 최소 높이 설정 */
    }

    .timetable {
      border-radius: 10px;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
      border-collapse: separate;
      border-spacing: 0;
      border: none;
      width: 100%;
      table-layout: fixed;
    }

    .timetable th, .timetable td {
      border: 1px solid #e5e7eb;
      padding: 10px;
      text-align: center;
    }

    .timetable thead th {
      background-color: #f9fafb;
      font-weight: 600;
      color: #4b5563;
      border-bottom: 2px solid #e5e7eb;
    }

    .time-header {
      background-color: #f9fafb;
      font-weight: 600;
    }

    .time-cell {
      background-color: #f9fafb;
      font-weight: 500;
      color: #6b7280;
    }

    .day-cell {
      height: 60px;
      vertical-align: top;
      transition: background-color 0.2s;
    }

    .course-item {
      color: white;
      padding: 8px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      overflow: hidden;
      z-index: 10;
      transition: transform 0.2s, box-shadow 0.2s;
      cursor: pointer;
      font-size: 0.9rem;
      position: absolute;
      width: auto;
      box-sizing: border-box;
      font-weight: 500;
    }

    .course-item:hover {
      transform: scale(1.02);
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
      z-index: 20;
    }

    .course-item.dragging {
      opacity: 0.8;
      z-index: 100;
    }

    .color-option {
      display: inline-block;
      border-radius: 50%;
      cursor: pointer;
      transition: transform 0.2s;
      border: 2px solid transparent;
    }

    .color-option:hover {
      transform: scale(1.2);
    }

    input[type="radio"]:checked + .color-option {
      border: 2px solid #000;
    }

    /* 카드 스타일 개선 */
    .card {
      border-radius: 10px;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
      transition: transform 0.2s, box-shadow 0.2s;
    }

    /* 모달 스타일 개선 */
    .modal-content {
      border-radius: 10px;
      border: none;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
    }

    .modal-header {
      border-bottom: 1px solid #e5e7eb;
      padding: 15px 20px;
    }

    .modal-body {
      padding: 20px;
    }

    .modal-footer {
      border-top: 1px solid #e5e7eb;
      padding: 15px 20px;
    }

    .nav-tabs .nav-link {
      border: none;
      color: #6b7280;
      padding: 10px 15px;
      font-weight: 500;
    }

    .nav-tabs .nav-link.active {
      color: #4f46e5;
      border-bottom: 2px solid #4f46e5;
      background-color: transparent;
    }

    /* 강의 카드 클릭 가능하게 */
    .course-card {
      cursor: pointer;
    }

    /* 강의 평가 스타일 */
    .evaluation-item {
      border-radius: 8px;
      border: 1px solid #e5e7eb;
      padding: 15px;
      margin-bottom: 15px;
    }

    .evaluation-rating {
      font-size: 1.2rem;
      font-weight: 600;
    }

    .evaluation-meta {
      color: #6b7280;
      font-size: 0.9rem;
    }

    .evaluation-content {
      margin-top: 10px;
      margin-bottom: 10px;
    }

    .evaluation-features {
      display: flex;
      flex-wrap: wrap;
      gap: 5px;
      margin-top: 10px;
    }

    .evaluation-feature {
      background-color: #f3f4f6;
      color: #4b5563;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 0.8rem;
    }

    /* 반응형 시간표 스타일 */
    @media (max-width: 992px) {
      .timetable th, .timetable td {
        padding: 8px 5px;
      }

      .course-item {
        font-size: 0.85rem;
        padding: 6px;
      }
    }

    @media (max-width: 768px) {
      .timetable th, .timetable td {
        padding: 6px 3px;
      }

      .course-item {
        font-size: 0.8rem;
        padding: 4px;
      }

      .course-item div:not(:first-child) {
        display: none; /* 모바일에서는 강의명만 표시 */
      }
    }

    @media (max-width: 576px) {
      .timetable th, .timetable td {
        padding: 4px 2px;
      }

      .course-item {
        font-size: 0.75rem;
        padding: 3px;
        border-radius: 4px;
      }

      .time-cell {
        font-size: 0.8rem;
      }

      .timetable thead th {
        font-size: 0.85rem;
      }
    }

    /* 다크 모드 지원 */
    .dark-mode .timetable th,
    .dark-mode .timetable td {
      border-color: #4a5568;
    }

    .dark-mode .timetable thead th,
    .dark-mode .time-header,
    .dark-mode .time-cell {
      background-color: var(--dark-bg-lighter);
      color: #e2e8f0;
    }

    .dark-mode .day-cell {
      background-color: var(--dark-card-bg);
    }

    .dark-mode .course-item {
      color: #f9fafb; /* 다크모드에서는 밝은 색상 유지 */
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
    }

    .dark-mode .course-item:hover {
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.4);
    }
  </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<main class="container py-5">
  <div class="row mb-4">
    <div class="col">
      <h1 class="mb-2">내 시간표</h1>
      <p class="text-muted">강의 시간표를 관리하고 강의 평가를 확인하세요</p>
    </div>
    <div class="col-auto d-flex align-items-center">
      <button id="addCourseBtn" class="btn btn-primary">
        <i class="bi bi-plus-lg me-1"></i> 강의 추가
      </button>
    </div>
  </div>

  <div class="card mb-4 timetable-card">
    <div class="card-header bg-white">
      <ul class="nav nav-tabs card-header-tabs" id="timetableTabs" role="tablist">
        <li class="nav-item" role="presentation">
          <button class="nav-link active" id="timetable-tab" data-bs-toggle="tab" data-bs-target="#timetable-view" type="button" role="tab" aria-controls="timetable-view" aria-selected="true">시간표 보기</button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" id="list-tab" data-bs-toggle="tab" data-bs-target="#list-view" type="button" role="tab" aria-controls="list-view" aria-selected="false">목록 보기</button>
        </li>
      </ul>
    </div>
    <div class="card-body">
      <div class="tab-content" id="timetableTabContent">
        <!-- 시간표 보기 탭 -->
        <div class="tab-pane fade show active" id="timetable-view" role="tabpanel" aria-labelledby="timetable-tab">
          <div class="timetable-container">
            <table class="table table-bordered timetable" id="timetableGrid">
              <thead>
              <tr>
                <th class="time-header" style="width: 10%">시간</th>
                <th style="width: 15%">월요일</th>
                <th style="width: 15%">화요일</th>
                <th style="width: 15%">수요일</th>
                <th style="width: 15%">목요일</th>
                <th style="width: 15%">금요일</th>
              </tr>
              </thead>
              <tbody>
              <c:forEach var="hour" begin="9" end="20">
                <tr data-hour="${hour}">
                  <td class="time-cell">${hour}:00</td>
                  <td class="day-cell" data-day="월" data-hour="${hour}"></td>
                  <td class="day-cell" data-day="화" data-hour="${hour}"></td>
                  <td class="day-cell" data-day="수" data-hour="${hour}"></td>
                  <td class="day-cell" data-day="목" data-hour="${hour}"></td>
                  <td class="day-cell" data-day="금" data-hour="${hour}"></td>
                </tr>
              </c:forEach>
              </tbody>
            </table>
          </div>
        </div>

        <!-- 목록 보기 탭 -->
        <div class="tab-pane fade" id="list-view" role="tabpanel" aria-labelledby="list-tab">
          <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
            <c:forEach var="course" items="${courses}">
              <div class="col">
                <div class="card h-100 course-card" data-course-id="${course.id}">
                  <div class="card-header d-flex justify-content-between align-items-center" style="background-color: ${course.color}; color: white;">
                    <h5 class="card-title mb-0 text-white">${course.name}</h5>
                    <div class="dropdown">
                      <button class="btn btn-sm text-white" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-three-dots-vertical"></i>
                      </button>
                      <ul class="dropdown-menu dropdown-menu-end">
                        <li><button class="dropdown-item edit-course" data-course-id="${course.id}">수정</button></li>
                        <li><button class="dropdown-item text-danger delete-course" data-course-id="${course.id}">삭제</button></li>
                      </ul>
                    </div>
                  </div>
                  <div class="card-body">
                    <div class="mb-2">
                      <i class="bi bi-person-fill me-2"></i> ${course.professor}
                    </div>
                    <div class="mb-2">
                      <i class="bi bi-calendar-date me-2"></i> ${course.day}요일
                    </div>
                    <div class="mb-2">
                      <i class="bi bi-clock me-2"></i> ${course.startTime}:00 - ${course.endTime}:00
                    </div>
                    <div>
                      <i class="bi bi-geo-alt-fill me-2"></i> ${course.location}
                    </div>
                  </div>
                </div>
              </div>
            </c:forEach>

            <c:if test="${empty courses}">
              <div class="col-12 text-center py-5">
                <div class="mb-3">
                  <i class="bi bi-calendar3 text-muted" style="font-size: 3rem;"></i>
                </div>
                <h4>등록된 강의가 없습니다</h4>
                <p class="text-muted">강의 추가 버튼을 클릭하여 시간표를 만들어보세요</p>
              </div>
            </c:if>
          </div>
        </div>
      </div>
    </div>
  </div>
</main>

<!-- 강의 추가 모달 -->
<div class="modal fade" id="addCourseModal" tabindex="-1" aria-labelledby="addCourseModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="addCourseModalLabel">강의 추가</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form id="addCourseForm">
          <div class="mb-3">
            <label for="name" class="form-label">강의명</label>
            <input type="text" class="form-control" id="name" name="name" required>
          </div>
          <div class="mb-3">
            <label for="professor" class="form-label">교수명</label>
            <input type="text" class="form-control" id="professor" name="professor" required>
          </div>
          <div class="row mb-3">
            <div class="col-md-6">
              <label for="day" class="form-label">요일</label>
              <select class="form-select" id="day" name="day" required>
                <option value="" selected disabled>요일 선택</option>
                <option value="월">월요일</option>
                <option value="화">화요일</option>
                <option value="수">수요일</option>
                <option value="목">목요일</option>
                <option value="금">금요일</option>
              </select>
            </div>
            <div class="col-md-6">
              <label for="location" class="form-label">강의실</label>
              <input type="text" class="form-control" id="location" name="location" required>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-6">
              <label for="startTime" class="form-label">시작 시간</label>
              <select class="form-select" id="startTime" name="startTime" required>
                <option value="" selected disabled>시작 시간</option>
                <c:forEach var="hour" begin="9" end="20">
                  <option value="${hour}">${hour}:00</option>
                </c:forEach>
              </select>
            </div>
            <div class="col-md-6">
              <label for="endTime" class="form-label">종료 시간</label>
              <select class="form-select" id="endTime" name="endTime" required>
                <option value="" selected disabled>종료 시간</option>
                <c:forEach var="hour" begin="9" end="20">
                  <option value="${hour}">${hour}:00</option>
                </c:forEach>
              </select>
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label">색상</label>
            <div class="d-flex flex-wrap gap-2">
              <!-- 코랄 레드 (기본 선택) -->
              <div class="form-check">
                <input class="form-check-input visually-hidden" type="radio" name="color" id="color-FF5252" value="#FF5252" checked>
                <label class="form-check-label color-option" for="color-FF5252" data-color="#FF5252" style="background-color: #FF5252; width: 30px; height: 30px; border-radius: 50%; cursor: pointer; border: 2px solid #000"></label>
              </div>
              <!-- 딥 퍼플 -->
              <div class="form-check">
                <input class="form-check-input visually-hidden" type="radio" name="color" id="color-7C4DFF" value="#7C4DFF">
                <label class="form-check-label color-option" for="color-7C4DFF" data-color="#7C4DFF" style="background-color: #7C4DFF; width: 30px; height: 30px; border-radius: 50%; cursor: pointer; border: 2px solid transparent"></label>
              </div>
              <!-- 로얄 블루 -->
              <div class="form-check">
                <input class="form-check-input visually-hidden" type="radio" name="color" id="color-1976D2" value="#1976D2">
                <label class="form-check-label color-option" for="color-1976D2" data-color="#1976D2" style="background-color: #1976D2; width: 30px; height: 30px; border-radius: 50%; cursor: pointer; border: 2px solid transparent"></label>
              </div>
              <!-- 에메랄드 그린 -->
              <div class="form-check">
                <input class="form-check-input visually-hidden" type="radio" name="color" id="color-00BFA5" value="#00BFA5">
                <label class="form-check-label color-option" for="color-00BFA5" data-color="#00BFA5" style="background-color: #00BFA5; width: 30px; height: 30px; border-radius: 50%; cursor: pointer; border: 2px solid transparent"></label>
              </div>
              <!-- 앰버 옐로우 -->
              <div class="form-check">
                <input class="form-check-input visually-hidden" type="radio" name="color" id="color-FFC107" value="#FFC107">
                <label class="form-check-label color-option" for="color-FFC107" data-color="#FFC107" style="background-color: #FFC107; width: 30px; height: 30px; border-radius: 50%; cursor: pointer; border: 2px solid transparent"></label>
              </div>
              <!-- 핫 핑크 -->
              <div class="form-check">
                <input class="form-check-input visually-hidden" type="radio" name="color" id="color-FF4081" value="#FF4081">
                <label class="form-check-label color-option" for="color-FF4081" data-color="#FF4081" style="background-color: #FF4081; width: 30px; height: 30px; border-radius: 50%; cursor: pointer; border: 2px solid transparent"></label>
              </div>
              <!-- 딥 오렌지 -->
              <!-- 딥 오렌지를 라임 그린으로 변경 -->
              <div class="form-check">
                <input class="form-check-input visually-hidden" type="radio" name="color" id="color-8BC34A" value="#8BC34A">
                <label class="form-check-label color-option" for="color-8BC34A" data-color="#8BC34A" style="background-color: #8BC34A; width: 30px; height: 30px; border-radius: 50%; cursor: pointer; border: 2px solid transparent"></label>
              </div>
              <!-- 틸 블루 -->
              <div class="form-check">
                <input class="form-check-input visually-hidden" type="radio" name="color" id="color-00796B" value="#00796B">
                <label class="form-check-label color-option" for="color-00796B" data-color="#00796B" style="background-color: #00796B; width: 30px; height: 30px; border-radius: 50%; cursor: pointer; border: 2px solid transparent"></label>
              </div>
              <!-- 인디고 -->
              <div class="form-check">
                <input class="form-check-input visually-hidden" type="radio" name="color" id="color-3F51B5" value="#3F51B5">
                <label class="form-check-label color-option" for="color-3F51B5" data-color="#3F51B5" style="background-color: #3F51B5; width: 30px; height: 30px; border-radius: 50%; cursor: pointer; border: 2px solid transparent"></label>
              </div>
              <!-- 브라운 -->
              <div class="form-check">
                <input class="form-check-input visually-hidden" type="radio" name="color" id="color-795548" value="#795548">
                <label class="form-check-label color-option" for="color-795548" data-color="#795548" style="background-color: #795548; width: 30px; height: 30px; border-radius: 50%; cursor: pointer; border: 2px solid transparent"></label>
              </div>
            </div>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
        <button type="button" class="btn btn-primary" id="saveCourseBtn">추가</button>
      </div>
    </div>
  </div>
</div>

<!-- 강의 상세/수정 모달 -->
<div class="modal fade" id="courseDetailModal" tabindex="-1" aria-labelledby="courseDetailModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="courseDetailModalLabel">강의 정보</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <ul class="nav nav-tabs mb-3" id="courseDetailTabs" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" id="course-info-tab" data-bs-toggle="tab" data-bs-target="#course-info" type="button" role="tab" aria-controls="course-info" aria-selected="true">강의 정보</button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="course-evaluation-tab" data-bs-toggle="tab" data-bs-target="#course-evaluation" type="button" role="tab" aria-controls="course-evaluation" aria-selected="false">강의 평가</button>
          </li>
        </ul>
        <div class="tab-content" id="courseDetailTabContent">
          <!-- 강의 정보 탭 -->
          <div class="tab-pane fade show active" id="course-info" role="tabpanel" aria-labelledby="course-info-tab">
            <form id="editCourseForm">
              <input type="hidden" id="editCourseId" name="id">
              <div class="mb-3">
                <label for="editName" class="form-label">강의명</label>
                <input type="text" class="form-control" id="editName" name="name" required>
              </div>
              <div class="mb-3">
                <label for="editProfessor" class="form-label">교수명</label>
                <input type="text" class="form-control" id="editProfessor" name="professor" required>
              </div>
              <div class="row mb-3">
                <div class="col-md-6">
                  <label for="editDay" class="form-label">요일</label>
                  <select class="form-select" id="editDay" name="day" required>
                    <option value="월">월요일</option>
                    <option value="화">화요일</option>
                    <option value="수">수요일</option>
                    <option value="목">목요일</option>
                    <option value="금">금요일</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label for="editLocation" class="form-label">강의실</label>
                  <input type="text" class="form-control" id="editLocation" name="location" required>
                </div>
              </div>
              <div class="row mb-3">
                <div class="col-md-6">
                  <label for="editStartTime" class="form-label">시작 시간</label>
                  <select class="form-select" id="editStartTime" name="startTime" required>
                    <c:forEach var="hour" begin="9" end="20">
                      <option value="${hour}">${hour}:00</option>
                    </c:forEach>
                  </select>
                </div>
                <div class="col-md-6">
                  <label for="editEndTime" class="form-label">종료 시간</label>
                  <select class="form-select" id="editEndTime" name="endTime" required>
                    <c:forEach var="hour" begin="9" end="20">
                      <option value="${hour}">${hour}:00</option>
                    </c:forEach>
                  </select>
                </div>
              </div>
              <div class="mb-3">
                <label class="form-label">색상</label>
                <div class="d-flex flex-wrap gap-2">
                  <!-- 코랄 레드 -->
                  <div class="form-check">
                    <input class="form-check-input visually-hidden" type="radio" name="editColor" id="editColor-FF5252" value="#FF5252">
                    <label class="form-check-label color-option" for="editColor-FF5252" style="background-color: #FF5252; width: 30px; height: 30px; border-radius: 50%; cursor: pointer;"></label>
                  </div>
                  <!-- 딥 퍼플 -->
                  <div class="form-check">
                    <input class="form-check-input visually-hidden" type="radio" name="editColor" id="editColor-7C4DFF" value="#7C4DFF">
                    <label class="form-check-label color-option" for="editColor-7C4DFF" style="background-color: #7C4DFF; width: 30px; height: 30px; border-radius: 50%; cursor: pointer;"></label>
                  </div>
                  <!-- 로얄 블루 -->
                  <div class="form-check">
                    <input class="form-check-input visually-hidden" type="radio" name="editColor" id="editColor-1976D2" value="#1976D2">
                    <label class="form-check-label color-option" for="editColor-1976D2" style="background-color: #1976D2; width: 30px; height: 30px; border-radius: 50%; cursor: pointer;"></label>
                  </div>
                  <!-- 에메랄드 그린 -->
                  <div class="form-check">
                    <input class="form-check-input visually-hidden" type="radio" name="editColor" id="editColor-00BFA5" value="#00BFA5">
                    <label class="form-check-label color-option" for="editColor-00BFA5" style="background-color: #00BFA5; width: 30px; height: 30px; border-radius: 50%; cursor: pointer;"></label>
                  </div>
                  <!-- 앰버 옐로우 -->
                  <div class="form-check">
                    <input class="form-check-input visually-hidden" type="radio" name="editColor" id="editColor-FFC107" value="#FFC107">
                    <label class="form-check-label color-option" for="editColor-FFC107" style="background-color: #FFC107; width: 30px; height: 30px; border-radius: 50%; cursor: pointer;"></label>
                  </div>
                  <!-- 핫 핑크 -->
                  <div class="form-check">
                    <input class="form-check-input visually-hidden" type="radio" name="editColor" id="editColor-FF4081" value="#FF4081">
                    <label class="form-check-label color-option" for="editColor-FF4081" style="background-color: #FF4081; width: 30px; height: 30px; border-radius: 50%; cursor: pointer;"></label>
                  </div>
                  <!-- 딥 오렌지 -->
                  <!-- 라임 그린 -->
                  <div class="form-check">
                    <input class="form-check-input visually-hidden" type="radio" name="editColor" id="editColor-8BC34A" value="#8BC34A">
                    <label class="form-check-label color-option" for="editColor-8BC34A" style="background-color: #8BC34A; width: 30px; height: 30px; border-radius: 50%; cursor: pointer;"></label>
                  </div>
                  <!-- 틸 블루 -->
                  <div class="form-check">
                    <input class="form-check-input visually-hidden" type="radio" name="editColor" id="editColor-00796B" value="#00796B">
                    <label class="form-check-label color-option" for="editColor-00796B" style="background-color: #00796B; width: 30px; height: 30px; border-radius: 50%; cursor: pointer;"></label>
                  </div>
                  <!-- 인디고 -->
                  <div class="form-check">
                    <input class="form-check-input visually-hidden" type="radio" name="editColor" id="editColor-3F51B5" value="#3F51B5">
                    <label class="form-check-label color-option" for="editColor-3F51B5" style="background-color: #3F51B5; width: 30px; height: 30px; border-radius: 50%; cursor: pointer;"></label>
                  </div>
                  <!-- 브라운 -->
                  <div class="form-check">
                    <input class="form-check-input visually-hidden" type="radio" name="editColor" id="editColor-795548" value="#795548">
                    <label class="form-check-label color-option" for="editColor-795548" style="background-color: #795548; width: 30px; height: 30px; border-radius: 50%; cursor: pointer;"></label>
                  </div>
                </div>
              </div>
            </form>
          </div>
          <!-- 강의 평가 탭 -->
          <div class="tab-pane fade" id="course-evaluation" role="tabpanel" aria-labelledby="course-evaluation-tab">
            <div id="courseEvaluations">
              <div class="text-center py-4">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Loading...</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-danger me-auto" id="deleteCourseBtn">삭제</button>
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
        <button type="button" class="btn btn-primary" id="updateCourseBtn">저장</button>
      </div>
    </div>
  </div>
</div>

<!-- 강의 정보 모달 (읽기 전용) -->
<div class="modal fade" id="courseInfoModal" tabindex="-1" aria-labelledby="courseInfoModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="courseInfoModalLabel">강의 정보</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <ul class="nav nav-tabs mb-3" id="courseInfoTabs" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" id="info-tab" data-bs-toggle="tab" data-bs-target="#info-view" type="button" role="tab" aria-controls="info-view" aria-selected="true">강의 정보</button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="evaluation-tab" data-bs-toggle="tab" data-bs-target="#evaluation-view" type="button" role="tab" aria-controls="evaluation-view" aria-selected="false">강의 평가</button>
          </li>
        </ul>
        <div class="tab-content" id="courseInfoTabContent">
          <!-- 강의 정보 탭 -->
          <div class="tab-pane fade show active" id="info-view" role="tabpanel" aria-labelledby="info-tab">
            <div class="mb-3">
              <h5 id="infoCourseName" class="mb-1"></h5>
              <div id="infoCourseColor" class="rounded" style="height: 5px; margin-bottom: 15px;"></div>
            </div>
            <div class="row mb-3">
              <div class="col-md-6">
                <div class="mb-2">
                  <i class="bi bi-person-fill me-2"></i> <span id="infoProfessor"></span>
                </div>
                <div class="mb-2">
                  <i class="bi bi-calendar-date me-2"></i> <span id="infoDay"></span>요일
                </div>
              </div>
              <div class="col-md-6">
                <div class="mb-2">
                  <i class="bi bi-clock me-2"></i> <span id="infoTime"></span>
                </div>
                <div>
                  <i class="bi bi-geo-alt-fill me-2"></i> <span id="infoLocation"></span>
                </div>
              </div>
            </div>
          </div>
          <!-- 강의 평가 탭 -->
          <div class="tab-pane fade" id="evaluation-view" role="tabpanel" aria-labelledby="evaluation-tab">
            <div id="infoEvaluations">
              <div class="text-center py-4">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Loading...</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
        <button type="button" class="btn btn-primary" id="editCourseBtn">수정</button>
      </div>
    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/script.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/timetable.js"></script>

<!-- 강의 데이터를 JavaScript 변수로 전달 -->
<script id="coursesData" type="application/json">
    <c:out value="[" escapeXml="false" />
    <c:forEach var="course" items="${courses}" varStatus="status">
  {
  "id": ${course.id},
  "name": "${course.name}",
  "professor": "${course.professor}",
  "day": "${course.day}",
  "startTime": ${course.startTime},
  "endTime": ${course.endTime},
  "location": "${course.location}",
  "color": "${course.color}"
  }<c:if test="${!status.last}">,</c:if>
</c:forEach>
    <c:out value="]" escapeXml="false" />
</script>

<script>
  // 브라우저 크기 변경 시 시간표 업데이트
  window.addEventListener('resize', function() {
    // 기존 강의 요소 제거
    const courseItems = document.querySelectorAll('.course-item');
    courseItems.forEach(item => item.remove());

    // 시간표 다시 그리기
    placeCourses();
  });

  // 로그인 확인 모달 표시 함수
  function showLoginConfirmModal() {
    // 모달 HTML 생성
    var modalHtml = `
          <div class="modal fade" id="loginConfirmModal" tabindex="-1" aria-labelledby="loginConfirmModalLabel" aria-hidden="true">
              <div class="modal-dialog">
                  <div class="modal-content">
                      <div class="modal-header">
                          <h5 class="modal-title" id="loginConfirmModalLabel">로그인 필요</h5>
                          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                      </div>
                      <div class="modal-body">
                          <p>시간표 서비스를 이용하려면 로그인이 필요합니다. 로그인 하시겠습니까?</p>
                          <p class="text-muted small mt-2">아니오를 선택하면 메인페이지로 이동됩니다.</p>
                      </div>
                      <div class="modal-footer">
                          <button type="button" class="btn btn-secondary" id="noLoginBtn">아니오</button>
                          <button type="button" class="btn btn-primary" id="goToLoginBtn">예</button>
                      </div>
                  </div>
              </div>
          </div>
      `;

    // 모달 HTML을 body에 추가
    document.body.insertAdjacentHTML('beforeend', modalHtml);

    // 모달 인스턴스 생성 및 표시
    var loginConfirmModal = new bootstrap.Modal(document.getElementById('loginConfirmModal'));
    loginConfirmModal.show();

    // "예" 버튼 클릭 이벤트 처리
    document.getElementById('goToLoginBtn').addEventListener('click', function() {
      window.location.href = "${pageContext.request.contextPath}/login.jsp?redirect=timetable";
    });

    // "아니오" 버튼 클릭 이벤트 처리
    document.getElementById('noLoginBtn').addEventListener('click', function() {
      window.location.href = "${pageContext.request.contextPath}/";
    });

    // 모달 닫기 버튼(X) 클릭 이벤트 처리
    document.querySelector('#loginConfirmModal .btn-close').addEventListener('click', function() {
      window.location.href = "${pageContext.request.contextPath}/";
    });
  }

  // 로그인 필요 상태 확인 및 모달 표시
  document.addEventListener('DOMContentLoaded', function() {
    var loginRequired = false;
    <c:if test="${loginRequired != null && loginRequired}">
    loginRequired = true;
    </c:if>

    if (loginRequired) {
      // 로그인 확인 모달 표시
      showLoginConfirmModal();
    }
  });
</script>
</body>
</html>
