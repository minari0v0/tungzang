<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>캠퍼스 날씨 - 텅장수강러</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/modern-styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary-color: #7e22ce;
            --primary-hover: #6b21a8;
        }

        .weather-gradient {
            background: linear-gradient(135deg, #dbeafe 0%, #c7d2fe 100%);
        }

        .dark-mode .weather-gradient {
            background: linear-gradient(135deg, #1e3a8a 0%, #3730a3 100%);
        }

        .weather-icon {
            font-size: 3rem;
        }

        .weather-temp {
            font-size: 3rem;
            font-weight: bold;
        }

        .weather-advice-box-large {
            background: rgba(255, 255, 255, 0.7);
            border-radius: 0.75rem;
            padding: 1.5rem;
            border: 2px solid rgba(255, 255, 255, 0.3);
            backdrop-filter: blur(10px);
            max-width: 600px;
            margin: 0 auto 1.5rem auto;
        }

        .dark-mode .weather-advice-box-large {
            background: rgba(0, 0, 0, 0.3);
            border-color: rgba(255, 255, 255, 0.2);
        }

        .weather-advice-box {
            background: rgba(255, 255, 255, 0.5);
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 1rem;
        }

        .dark-mode .weather-advice-box {
            background: rgba(0, 0, 0, 0.2);
        }

        .weather-detail-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1rem;
        }

        @media (min-width: 768px) {
            .weather-detail-grid {
                grid-template-columns: repeat(4, 1fr);
            }
        }

        .weather-detail-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .forecast-card {
            text-align: center;
            padding: 1rem;
            border: 1px solid #e5e7eb;
            border-radius: 0.5rem;
        }

        .dark-mode .forecast-card {
            border-color: rgba(255, 255, 255, 0.1);
        }

        .forecast-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 1rem;
        }

        @media (min-width: 768px) {
            .forecast-grid {
                grid-template-columns: repeat(5, 1fr);
            }
        }

        /* 새로고침 버튼 스타일 - cafeteria.jsp와 동일하게 */
        .refresh-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.5rem;
            background: #7e22ce; /* 보라색으로 변경 */
            color: white;
            border: none;
            border-radius: 50px;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            text-decoration: none;
        }

        .refresh-btn:hover {
            background: #6b21a8; /* 진한 보라색으로 변경 */
            transform: translateY(-2px);
            box-shadow: var(--shadow-hover);
            color: white;
            text-decoration: none;
        }

        .realtime-badge {
            background-color: #10b981;
            color: white;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .estimated-badge {
            background-color: #f59e0b;
            color: white;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .error-card {
            border-color: #fed7aa;
            background-color: #fef3e2;
        }

        .dark-mode .error-card {
            border-color: #ea580c;
            background-color: rgba(234, 88, 12, 0.1);
        }

        .error-text {
            color: #ea580c;
        }

        .dark-mode .error-text {
            color: #fb923c;
        }

        .debug-section {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 0.375rem;
            padding: 1rem;
            margin-top: 1rem;
            font-family: 'Courier New', monospace;
            font-size: 0.875rem;
            max-height: 300px;
            overflow-y: auto;
        }

        .dark-mode .debug-section {
            background-color: #1f2937;
            border-color: #374151;
            color: #e5e7eb;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container py-4">
    <!-- 헤더 -->
    <div class="d-flex align-items-center justify-content-between mb-4">
        <div class="d-flex align-items-center">
            <a href="${pageContext.request.contextPath}/campus-life" class="btn btn-outline-secondary me-3">
                <i class="bi bi-arrow-left"></i>
            </a>
            <div>
                <h1 class="mb-1" style="font-size: 2.5rem;">안양대학교 캠퍼스 날씨</h1>
                <p class="text-muted mb-0">실시간 날씨 정보와 주간 예보</p>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/weather" class="refresh-btn">
            <i class="bi bi-arrow-clockwise"></i>
            새로고침
        </a>
    </div>

    <!-- 오류 메시지 -->
    <c:if test="${not empty errorMessage}">
        <div class="card error-card mb-4">
            <div class="card-body">
                <div class="d-flex align-items-center">
                    <i class="bi bi-exclamation-circle error-text me-2"></i>
                    <span class="error-text small">${errorMessage}</span>
                </div>
            </div>
        </div>
    </c:if>

    <c:if test="${not empty weather}">
        <div class="row g-4">
            <!-- 현재 날씨 -->
            <div class="col-12">
                <div class="card border-0 shadow-sm weather-gradient">
                    <div class="card-header bg-transparent border-0">
                        <h5 class="card-title d-flex align-items-center mb-0">
                            <c:choose>
                                <c:when test="${weather.current.condition == '맑음'}">
                                    <i class="bi bi-sun-fill text-warning weather-icon me-2"></i>
                                </c:when>
                                <c:when test="${weather.current.condition == '구름조금'}">
                                    <i class="bi bi-cloud-sun-fill text-secondary weather-icon me-2"></i>
                                </c:when>
                                <c:when test="${weather.current.condition == '구름많음'}">
                                    <i class="bi bi-cloud-fill text-secondary weather-icon me-2"></i>
                                </c:when>
                                <c:when test="${weather.current.condition == '흐림'}">
                                    <i class="bi bi-clouds-fill text-secondary weather-icon me-2"></i>
                                </c:when>
                                <c:when test="${weather.current.condition == '비'}">
                                    <i class="bi bi-cloud-rain-fill text-primary weather-icon me-2"></i>
                                </c:when>
                                <c:otherwise>
                                    <i class="bi bi-sun-fill text-warning weather-icon me-2"></i>
                                </c:otherwise>
                            </c:choose>
                            현재 날씨
                        </h5>
                        <p class="card-text small text-muted mb-0">
                            마지막 업데이트: <fmt:formatDate value="${lastUpdated}" pattern="HH:mm:ss" />
                            <c:choose>
                                <c:when test="${source == 'OpenWeatherMap API' && empty errorMessage}">
                                    <span class="badge realtime-badge ms-2">실시간 데이터</span>
                                </c:when>
                                <c:when test="${source == '시뮬레이션 데이터'}">
                                    <span class="badge estimated-badge ms-2">추정 데이터</span>
                                </c:when>
                            </c:choose>
                        </p>
                    </div>
                    <div class="card-body">
                        <!-- 첫 번째 행: 현재 날씨 정보 -->
                        <div class="d-flex align-items-center justify-content-center mb-4">
                            <div class="text-center">
                                <div class="weather-temp">${weather.current.temperature}°C</div>
                                <div class="fs-5 text-muted">${weather.current.condition}</div>
                                <div class="small text-muted">체감온도 ${weather.current.feelsLike}°C</div>
                            </div>
                        </div>

                        <!-- 두 번째 행: 날씨 조언 (가운데 정렬) -->
                        <div class="weather-advice-box-large text-center">
                            <p class="fs-5 fw-medium mb-2">${weather.advice}</p>
                            <p class="small text-muted mb-0">
                                현재 조건: ${weather.current.temperature}°C, ${weather.current.condition}
                            </p>
                        </div>

                        <!-- 세 번째 행: 날씨 상세 정보 -->
                        <div class="weather-detail-grid">
                            <div class="weather-detail-item">
                                <i class="bi bi-droplet-fill text-primary"></i>
                                <div>
                                    <div class="small text-muted">습도</div>
                                    <div class="fw-semibold">${weather.current.humidity}%</div>
                                </div>
                            </div>
                            <div class="weather-detail-item">
                                <i class="bi bi-wind text-success"></i>
                                <div>
                                    <div class="small text-muted">풍속</div>
                                    <div class="fw-semibold">
                                        <fmt:formatNumber value="${weather.current.windSpeed}" maxFractionDigits="1" /> m/s
                                    </div>
                                </div>
                            </div>
                            <div class="weather-detail-item">
                                <i class="bi bi-eye-fill" style="color: #8b5cf6;"></i>
                                <div>
                                    <div class="small text-muted">가시거리</div>
                                    <div class="fw-semibold">
                                        <fmt:formatNumber value="${weather.current.visibility}" maxFractionDigits="1" /> km
                                    </div>
                                </div>
                            </div>
                            <div class="weather-detail-item">
                                <i class="bi bi-thermometer-half text-danger"></i>
                                <div>
                                    <div class="small text-muted">체감온도</div>
                                    <div class="fw-semibold">${weather.current.feelsLike}°C</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 5일 예보 -->
            <div class="col-12">
                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-white border-0">
                        <h5 class="card-title mb-0">5일 예보</h5>
                        <p class="card-text small text-muted mb-0">향후 5일간의 날씨 예보 (OpenWeatherMap API 제공)</p>
                    </div>
                    <div class="card-body">
                        <div class="forecast-grid">
                            <c:forEach items="${weather.forecast}" var="day" begin="0" end="4">
                                <div class="forecast-card">
                                    <p class="fw-medium mb-2">${day.day}</p>
                                    <div class="fs-1 mb-2">${day.icon}</div>
                                    <p class="small text-muted mb-1">${day.condition}</p>
                                    <div class="small">
                                        <span class="fw-medium text-danger">${day.high}°</span>
                                        <span class="text-muted">/${day.low}°</span>
                                    </div>
                                    <c:if test="${day.isEstimated}">
                                        <span class="badge badge-outline mt-1" style="font-size: 0.7rem;">추정</span>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 데이터 출처 -->
            <div class="col-12">
                <div class="card border-0 shadow-sm">
                    <div class="card-body">
                        <div class="small text-muted">
                            <p class="mb-1">📍 위치: 안양대학교 (경기도 안양시)</p>
                            <p class="mb-0">📊 데이터 출처: openweathermap.org</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

    <!-- 날씨 데이터가 없는 경우 -->
    <c:if test="${empty weather}">
        <div class="text-center py-5">
            <i class="bi bi-cloud-slash display-1 text-muted mb-3"></i>
            <h3 class="text-muted">날씨 정보를 불러올 수 없습니다</h3>
            <p class="text-muted mb-4">잠시 후 다시 시도해주세요.</p>
            <a href="${pageContext.request.contextPath}/weather" class="refresh-btn">
                <i class="bi bi-arrow-clockwise"></i>
                다시 시도
            </a>
        </div>
    </c:if>

    <!-- 디버그 정보 (개발용) -->
    <c:if test="${not empty debugLogs}">
        <div class="mt-4">
            <button class="btn btn-outline-secondary btn-sm" type="button" data-bs-toggle="collapse" data-bs-target="#debugInfo">
                <i class="bi bi-bug me-1"></i>디버그 정보 보기
            </button>
            <div class="collapse mt-2" id="debugInfo">
                <div class="debug-section">
                    <h6>디버그 로그:</h6>
                    <c:forEach items="${debugLogs}" var="log">
                        <div>${log}</div>
                    </c:forEach>

                    <c:if test="${not empty weather}">
                        <hr>
                        <h6>날씨 데이터:</h6>
                        <div>현재 온도: ${weather.current.temperature}°C</div>
                        <div>날씨 상태: ${weather.current.condition}</div>
                        <div>습도: ${weather.current.humidity}%</div>
                        <div>풍속: ${weather.current.windSpeed} m/s</div>
                        <div>예보 개수: ${weather.forecast.size()}개</div>
                    </c:if>

                    <hr>
                    <h6>요청 정보:</h6>
                    <div>요청 시간: <fmt:formatDate value="${lastUpdated}" pattern="yyyy-MM-dd HH:mm:ss" /></div>
                    <div>데이터 소스: ${source}</div>
                    <c:if test="${not empty errorMessage}">
                        <div>오류 메시지: ${errorMessage}</div>
                    </c:if>
                </div>
            </div>
        </div>
    </c:if>

    <!-- 로딩 상태 (JavaScript로 제어) -->
    <div id="loading" class="text-center py-5" style="display: none;">
        <i class="bi bi-arrow-clockwise spin"></i>
        <p class="mt-2">날씨 정보를 불러오는 중...</p>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${pageContext.request.contextPath}/resources/js/bootstrap.bundle.min.js"></script>
<script>
    // 새로고침 버튼 클릭 시 로딩 표시
    document.querySelector('.refresh-btn').addEventListener('click', function() {
        document.getElementById('loading').style.display = 'block';
    });

    // 디버그 정보를 콘솔에도 출력
    <c:if test="${not empty debugLogs}">
    console.group('🌤️ 날씨 API 디버그 정보');
    <c:forEach items="${debugLogs}" var="log">
    console.log('${log}');
    </c:forEach>
    console.groupEnd();
    </c:if>

    <c:if test="${not empty errorMessage}">
    console.error('❌ 날씨 API 오류:', '${errorMessage}');
    </c:if>

    <c:if test="${not empty weather}">
    console.log('✅ 날씨 데이터 로드 성공:', {
        temperature: '${weather.current.temperature}°C',
        condition: '${weather.current.condition}',
        source: '${source}',
        forecastCount: ${weather.forecast.size()}
    });
    </c:if>
</script>
</body>
</html>
