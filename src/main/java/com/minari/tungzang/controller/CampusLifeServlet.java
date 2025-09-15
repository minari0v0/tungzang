package com.minari.tungzang.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {"/campus-life", "/weather", "/cafeteria", "/academic-calendar"})
public class CampusLifeServlet extends HttpServlet {

    private static final String WEATHER_API_KEY = "baa682e78fe08445bf2efe659601f4f6";
    private static final String WEATHER_API_URL = "https://api.openweathermap.org/data/2.5/weather?q=Anyang,KR&appid=" + WEATHER_API_KEY + "&units=metric&lang=kr";
    private static final String CAFETERIA_URL = "https://www.anyang.ac.kr/main/activities/school-cafeteria.do";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        switch (path) {
            case "/campus-life":
                handleCampusLife(request, response);
                break;
            case "/weather":
                handleWeather(request, response);
                break;
            case "/cafeteria":
                handleCafeteria(request, response);
                break;
            case "/academic-calendar":
                handleAcademicCalendar(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleCampusLife(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/campus-life.jsp").forward(request, response);
    }

    private void handleWeather(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<String> debugLogs = new ArrayList<>();
        Map<String, Object> weatherData = null;
        String errorMessage = null;
        String source = "OpenWeatherMap API";

        try {
            debugLogs.add("=== Weather API 시작 ===");
            weatherData = getAdvancedWeatherData(debugLogs);
            debugLogs.add("Weather API 호출 성공");
        } catch (Exception e) {
            debugLogs.add("Weather API 오류: " + e.getMessage());
            weatherData = generateRealisticWeatherData();
            source = "시뮬레이션 데이터";
            errorMessage = "실제 날씨 정보를 불러올 수 없어 시뮬레이션 데이터를 표시합니다.";
        }

        request.setAttribute("weather", weatherData);
        request.setAttribute("debugLogs", debugLogs);
        request.setAttribute("errorMessage", errorMessage);
        request.setAttribute("source", source);
        request.setAttribute("lastUpdated", new Date());
        request.getRequestDispatcher("/weather.jsp").forward(request, response);
    }

    private void handleCafeteria(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<String> debugLogs = new ArrayList<>();
        Map<String, Object> cafeteriaData = null;
        String errorMessage = null;

        try {
            debugLogs.add("=== 학식 메뉴 크롤링 시작 ===");
            cafeteriaData = getCafeteriaMenuFromWebsite(debugLogs);
            debugLogs.add("학식 메뉴 크롤링 완료");

            // 현재 날짜 및 요일 정보 설정
            LocalDate today = LocalDate.now();
            String[] dayNames = {"일", "월", "화", "수", "목", "금", "토"};
            String currentDayName = dayNames[today.getDayOfWeek().getValue() % 7];

            // 주말 여부 확인
            boolean isWeekend = today.getDayOfWeek().getValue() > 5; // 토요일(6) 또는 일요일(7)

            request.setAttribute("cafeterias", Collections.singletonList(cafeteriaData));
            request.setAttribute("currentDate", new Date());
            request.setAttribute("currentDayName", currentDayName);
            request.setAttribute("isWeekend", isWeekend);
            request.setAttribute("lastUpdated", new Date());

        } catch (Exception e) {
            debugLogs.add("학식 메뉴 크롤링 오류: " + e.getMessage());
            cafeteriaData = getDefaultCafeteriaData();
            errorMessage = "실제 학식 메뉴를 불러올 수 없어 시뮬레이션 데이터를 표시합니다.";

            request.setAttribute("cafeterias", Collections.singletonList(cafeteriaData));
            request.setAttribute("currentDate", new Date());
            request.setAttribute("currentDayName", LocalDate.now().getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.KOREAN));
            request.setAttribute("isWeekend", LocalDate.now().getDayOfWeek().getValue() > 5);
            request.setAttribute("error", errorMessage);
            request.setAttribute("lastUpdated", new Date());
        }

        request.setAttribute("debugLogs", debugLogs);
        request.getRequestDispatcher("/cafeteria.jsp").forward(request, response);
    }

    private void handleAcademicCalendar(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<String> debugLogs = new ArrayList<>();
        String errorMessage = null;
        Map<String, Object> debugInfo = new HashMap<>();

        try {
            debugLogs.add("=== 학사일정 AJAX 데이터 가져오기 ===");

            List<Map<String, Object>> allEvents = getAcademicCalendarEventsFromAjax(debugLogs);
            debugLogs.add("AJAX 호출 완료. 총 이벤트 수: " + allEvents.size());

            if (allEvents.isEmpty()) {
                debugLogs.add("⚠️ 경고: AJAX에서 가져온 이벤트가 0개입니다!");
                debugLogs.add("기본 데이터를 사용합니다.");
                allEvents = getDummyAcademicData();
                errorMessage = "실제 학사일정을 불러올 수 없어 시뮬레이션 데이터를 표시합니다.";
                debugInfo.put("foundEvents", 0);
                debugInfo.put("totalAttempts", 1);
            } else {
                debugInfo.put("foundEvents", allEvents.size());
                debugInfo.put("totalAttempts", 1);
            }

            // 중요 일정 필터링 (모든 일정)
            List<Map<String, Object>> importantEvents = filterImportantEvents(allEvents);
            debugLogs.add("중요 일정 필터링 결과: " + importantEvents.size() + "개");

            // 다가오는 일정 (30일 이내)
            List<Map<String, Object>> upcomingEvents = filterUpcomingEvents(allEvents, 30);
            debugLogs.add("다가오는 일정 필터링 결과 (30일 이내): " + upcomingEvents.size() + "개");

            // 카테고리별 일정
            Map<String, List<Map<String, Object>>> categorizedEvents = categorizeEvents(allEvents);
            debugLogs.add("카테고리별 분류 완료");

            request.setAttribute("allEvents", allEvents);
            request.setAttribute("importantEvents", importantEvents);
            request.setAttribute("upcomingEvents", upcomingEvents);
            request.setAttribute("categorizedEvents", categorizedEvents);
            request.setAttribute("lastUpdated", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy년 MM월 dd일 HH:mm")));

        } catch (Exception e) {
            debugLogs.add("❌ 학사일정 AJAX 호출 치명적 오류: " + e.getClass().getSimpleName() + " - " + e.getMessage());
            debugLogs.add("스택 트레이스: " + Arrays.toString(e.getStackTrace()));

            // 기본 데이터 설정
            List<Map<String, Object>> defaultEvents = getDummyAcademicData();
            request.setAttribute("allEvents", defaultEvents);
            request.setAttribute("importantEvents", filterImportantEvents(defaultEvents));
            request.setAttribute("upcomingEvents", filterUpcomingEvents(defaultEvents, 30));
            request.setAttribute("categorizedEvents", categorizeEvents(defaultEvents));
            request.setAttribute("lastUpdated", "AJAX 호출 실패 - " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm")));
            errorMessage = "학사일정을 불러오는데 실패했습니다: " + e.getMessage();
            debugInfo.put("error", e.getMessage());
        }

        request.setAttribute("debugLogs", debugLogs);
        request.setAttribute("errorMessage", errorMessage);
        request.setAttribute("debugInfo", debugInfo);
        request.getRequestDispatcher("/academic-calendar.jsp").forward(request, response);
    }

    private List<Map<String, Object>> getAcademicCalendarEventsFromAjax(List<String> debugLogs) throws IOException {
        List<Map<String, Object>> events = new ArrayList<>();
        LocalDate today = LocalDate.now();
        int currentYear = today.getYear();

        // Next.js와 동일한 AJAX URL 구성
        String ajaxUrl = String.format("https://www.anyang.ac.kr/main/academic/academic-schedule.do?mode=getNewCalendarData&start=%d&end=%d",
                currentYear, currentYear);
        debugLogs.add("AJAX URL: " + ajaxUrl);

        try {
            URL url = new URL(ajaxUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            // Next.js와 동일한 헤더 설정
            conn.setRequestMethod("GET");
            conn.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
            conn.setRequestProperty("Accept", "application/json, text/html, */*");
            conn.setRequestProperty("X-Requested-With", "XMLHttpRequest");
            conn.setRequestProperty("Referer", "https://www.anyang.ac.kr/main/academic/academic-schedule.do?mode=list02");
            conn.setRequestProperty("Accept-Language", "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7");
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(15000);

            int responseCode = conn.getResponseCode();
            debugLogs.add("HTTP 응답 코드: " + responseCode);

            if (responseCode != 200) {
                throw new IOException("HTTP " + responseCode + ": AJAX 데이터를 불러올 수 없습니다.");
            }

            // 응답 읽기
            StringBuilder responseText = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    responseText.append(line);
                }
            }

            debugLogs.add("응답 길이: " + responseText.length());
            debugLogs.add("응답 내용 (처음 1000자): " + responseText.substring(0, Math.min(1000, responseText.length())));

            // JSON 파싱
            ObjectMapper mapper = new ObjectMapper();
            JsonNode jsonData = mapper.readTree(responseText.toString());
            debugLogs.add("JSON 파싱 성공!");

            // JSON 구조 확인
            if (jsonData.isObject()) {
                Iterator<String> fieldNames = jsonData.fieldNames();
                List<String> keys = new ArrayList<>();
                while (fieldNames.hasNext()) {
                    keys.add(fieldNames.next());
                }
                debugLogs.add("JSON 구조: " + keys.toString());
            }

            // items 배열 확인
            JsonNode itemsNode = jsonData.get("items");
            if (itemsNode != null && itemsNode.isArray()) {
                debugLogs.add("일정 아이템 개수: " + itemsNode.size());

                // 각 아이템 처리
                for (JsonNode item : itemsNode) {
                    debugLogs.add("\n=== 아이템 처리 ===");

                    JsonNode articleTitleNode = item.get("articleTitle");
                    String articleTitle = articleTitleNode != null ? articleTitleNode.asText() : "";
                    debugLogs.add("articleTitle: " + articleTitle);

                    // articleText는 JSON 문자열이므로 다시 파싱
                    JsonNode articleTextNode = item.get("articleText");
                    if (articleTextNode != null && !articleTextNode.asText().isEmpty()) {
                        try {
                            JsonNode articleData = mapper.readTree(articleTextNode.asText());
                            debugLogs.add("articleText 파싱 성공!");

                            // 월별 키 확인
                            Iterator<String> monthFieldNames = articleData.fieldNames();
                            List<String> monthKeys = new ArrayList<>();
                            while (monthFieldNames.hasNext()) {
                                monthKeys.add(monthFieldNames.next());
                            }
                            debugLogs.add("월별 키: " + monthKeys.toString());

                            // 각 월별 데이터 처리
                            for (String monthKey : monthKeys) {
                                if (monthKey.matches("\\d+month")) {
                                    int month = Integer.parseInt(monthKey.replaceAll("month", ""));
                                    debugLogs.add("\n=== " + month + "월 일정 처리 ===");

                                    JsonNode monthEventsNode = articleData.get(monthKey);
                                    if (monthEventsNode != null && monthEventsNode.isArray()) {
                                        debugLogs.add(month + "월 일정 개수: " + monthEventsNode.size());

                                        // 각 일정 처리
                                        for (JsonNode eventNode : monthEventsNode) {
                                            JsonNode textNode = eventNode.get("text");
                                            JsonNode startDateNode = eventNode.get("startDate");
                                            JsonNode endDateNode = eventNode.get("endDate");

                                            if (textNode != null && startDateNode != null && endDateNode != null) {
                                                String title = textNode.asText();
                                                String startDateStr = startDateNode.asText();
                                                String endDateStr = endDateNode.asText();

                                                debugLogs.add("제목: " + title);
                                                debugLogs.add("시작일: " + startDateStr);
                                                debugLogs.add("종료일: " + endDateStr);

                                                try {
                                                    LocalDate startDate = LocalDate.parse(startDateStr.substring(0, 10));
                                                    LocalDate endDate = LocalDate.parse(endDateStr.substring(0, 10));

                                                    // 시작일과 종료일이 같은지 확인
                                                    boolean isSameDay = startDate.equals(endDate);

                                                    // 제목에 날짜 범위 정보 추가 (기간이 있는 경우)
                                                    String displayTitle = title;
                                                    if (!isSameDay) {
                                                        String startStr = startDate.getMonthValue() + "월 " + startDate.getDayOfMonth() + "일";
                                                        String endStr = endDate.getMonthValue() + "월 " + endDate.getDayOfMonth() + "일";
                                                        displayTitle = title + " (" + startStr + " ~ " + endStr + ")";
                                                    }

                                                    long daysUntil = java.time.temporal.ChronoUnit.DAYS.between(today, startDate);
                                                    long duration = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate) + 1;

                                                    // 이벤트 생성
                                                    Map<String, Object> event = new HashMap<>();
                                                    event.put("id", "cal-" + month + "-" + startDate.getDayOfMonth() + "-" + events.size());
                                                    event.put("title", displayTitle);
                                                    event.put("startDate", startDate);
                                                    event.put("endDate", endDate);
                                                    event.put("dateRange", isSameDay ?
                                                            startDate.getMonthValue() + "월 " + startDate.getDayOfMonth() + "일" :
                                                            startDate.getMonthValue() + "월 " + startDate.getDayOfMonth() + "일 ~ " +
                                                                    endDate.getMonthValue() + "월 " + endDate.getDayOfMonth() + "일");
                                                    event.put("description", title + (isSameDay ? "" : " (" + startDate + " ~ " + endDate + ")"));
                                                    event.put("category", categorizeEvent(title));
                                                    event.put("isImportant", isImportantEvent(title));
                                                    event.put("daysUntil", daysUntil);
                                                    event.put("duration", duration);

                                                    events.add(event);
                                                    debugLogs.add("✅ 이벤트 추가: " + displayTitle + " (" + startDate + (isSameDay ? "" : " ~ " + endDate) + ")");

                                                } catch (Exception dateParseError) {
                                                    debugLogs.add("날짜 파싱 오류: " + dateParseError.getMessage());
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                        } catch (Exception articleParseError) {
                            debugLogs.add("articleText 파싱 실패: " + articleParseError.getMessage());
                            debugLogs.add("원본 articleText: " + articleTextNode.asText().substring(0, Math.min(500, articleTextNode.asText().length())));
                        }
                    }
                }

            } else {
                debugLogs.add("items 배열을 찾을 수 없음. JSON 구조 확인 필요");
            }

            // 방학 기간 자동 계산 및 추가
            List<Map<String, Object>> vacationEvents = calculateVacationPeriods(events, debugLogs);
            events.addAll(vacationEvents);

            // 중복 제거 및 정렬
            Set<String> seen = new HashSet<>();
            List<Map<String, Object>> uniqueEvents = new ArrayList<>();
            for (Map<String, Object> event : events) {
                String key = event.get("title") + "|" + event.get("startDate");
                if (!seen.contains(key)) {
                    seen.add(key);
                    uniqueEvents.add(event);
                }
            }

            // 날짜순 정렬
            uniqueEvents.sort((a, b) -> {
                LocalDate dateA = (LocalDate) a.get("startDate");
                LocalDate dateB = (LocalDate) b.get("startDate");
                return dateA.compareTo(dateB);
            });

            debugLogs.add("\n=== 파싱 완료: 총 " + uniqueEvents.size() + "개 일정 발견 ===");
            for (int i = 0; i < Math.min(uniqueEvents.size(), 10); i++) {
                Map<String, Object> event = uniqueEvents.get(i);
                debugLogs.add((i + 1) + ". " + event.get("title") + " (" + event.get("startDate") + ") - " + event.get("category"));
            }

            return uniqueEvents;

        } catch (Exception e) {
            debugLogs.add("AJAX 호출 중 오류 발생: " + e.getMessage());
            throw new IOException("AJAX 데이터 가져오기 실패", e);
        }
    }

    private List<Map<String, Object>> calculateVacationPeriods(List<Map<String, Object>> events, List<String> debugLogs) {
        List<Map<String, Object>> vacationEvents = new ArrayList<>();
        LocalDate today = LocalDate.now();

        debugLogs.add("\n=== 방학 기간 자동 계산 ===");

        // 종강/개강 일정 찾기
        List<Map<String, Object>> semesterEvents = new ArrayList<>();
        for (Map<String, Object> event : events) {
            String title = ((String) event.get("title")).toLowerCase();
            if (title.contains("종강") || title.contains("개강")) {
                semesterEvents.add(event);
            }
        }

        debugLogs.add("종강/개강 일정 수: " + semesterEvents.size());

        // 1학기 종강 찾기
        Map<String, Object> firstSemesterEnd = null;
        for (Map<String, Object> event : semesterEvents) {
            String title = ((String) event.get("title")).toLowerCase();
            LocalDate eventDate = (LocalDate) event.get("startDate");
            int month = eventDate.getMonthValue();
            if (title.contains("종강") && (title.contains("1학기") || (month >= 6 && month <= 8))) {
                firstSemesterEnd = event;
                break;
            }
        }

        // 2학기 개강 찾기
        Map<String, Object> secondSemesterStart = null;
        for (Map<String, Object> event : semesterEvents) {
            String title = ((String) event.get("title")).toLowerCase();
            LocalDate eventDate = (LocalDate) event.get("startDate");
            int month = eventDate.getMonthValue();
            if (title.contains("개강") && (title.contains("2학기") || (month >= 8 && month <= 10))) {
                secondSemesterStart = event;
                break;
            }
        }

        // 여름방학 계산
        if (firstSemesterEnd != null && secondSemesterStart != null) {
            LocalDate summerVacationStart = ((LocalDate) firstSemesterEnd.get("startDate")).plusDays(1);
            LocalDate summerVacationEnd = ((LocalDate) secondSemesterStart.get("startDate")).minusDays(1);

            long daysUntil = java.time.temporal.ChronoUnit.DAYS.between(today, summerVacationStart);
            long duration = java.time.temporal.ChronoUnit.DAYS.between(summerVacationStart, summerVacationEnd) + 1;

            Map<String, Object> summerVacationEvent = new HashMap<>();
            summerVacationEvent.put("id", "vacation-summer-" + System.currentTimeMillis());
            summerVacationEvent.put("title", "여름방학 (" + summerVacationStart.getMonthValue() + "월 " + summerVacationStart.getDayOfMonth() + "일 ~ " +
                    summerVacationEnd.getMonthValue() + "월 " + summerVacationEnd.getDayOfMonth() + "일)");
            summerVacationEvent.put("startDate", summerVacationStart);
            summerVacationEvent.put("endDate", summerVacationEnd);
            summerVacationEvent.put("dateRange", summerVacationStart.getMonthValue() + "월 " + summerVacationStart.getDayOfMonth() + "일 ~ " +
                    summerVacationEnd.getMonthValue() + "월 " + summerVacationEnd.getDayOfMonth() + "일");
            summerVacationEvent.put("description", "여름방학 기간 (" + duration + "일간)");
            summerVacationEvent.put("category", "vacation");
            summerVacationEvent.put("isImportant", false);
            summerVacationEvent.put("daysUntil", daysUntil);
            summerVacationEvent.put("duration", duration);

            vacationEvents.add(summerVacationEvent);
            debugLogs.add("✅ 여름방학 추가: " + summerVacationStart + " ~ " + summerVacationEnd);
        }

        // 2학기 종강 찾기
        Map<String, Object> secondSemesterEnd = null;
        for (Map<String, Object> event : semesterEvents) {
            String title = ((String) event.get("title")).toLowerCase();
            LocalDate eventDate = (LocalDate) event.get("startDate");
            int month = eventDate.getMonthValue();
            if (title.contains("종강") && (title.contains("2학기") || month >= 12 || month <= 2)) {
                secondSemesterEnd = event;
                break;
            }
        }

        // 겨울방학 계산
        if (secondSemesterEnd != null) {
            LocalDate winterVacationStart = ((LocalDate) secondSemesterEnd.get("startDate")).plusDays(1);

            // 다음년도 1학기 개강일 추정 (보통 3월 첫째주)
            int nextYear = winterVacationStart.getYear() + 1;
            LocalDate estimatedNextSemesterStart = LocalDate.of(nextYear, 3, 2);

            // 다음년도 1학기 개강 일정이 있다면 사용
            Map<String, Object> nextFirstSemesterStart = null;
            for (Map<String, Object> event : semesterEvents) {
                String title = ((String) event.get("title")).toLowerCase();
                LocalDate eventDate = (LocalDate) event.get("startDate");
                if (title.contains("개강") && title.contains("1학기") && eventDate.getYear() == nextYear) {
                    nextFirstSemesterStart = event;
                    break;
                }
            }

            LocalDate winterVacationEnd = nextFirstSemesterStart != null ?
                    ((LocalDate) nextFirstSemesterStart.get("startDate")).minusDays(1) :
                    estimatedNextSemesterStart.minusDays(1);

            long daysUntil = java.time.temporal.ChronoUnit.DAYS.between(today, winterVacationStart);
            long duration = java.time.temporal.ChronoUnit.DAYS.between(winterVacationStart, winterVacationEnd) + 1;

            Map<String, Object> winterVacationEvent = new HashMap<>();
            winterVacationEvent.put("id", "vacation-winter-" + System.currentTimeMillis());
            winterVacationEvent.put("title", "겨울방학 (" + winterVacationStart.getMonthValue() + "월 " + winterVacationStart.getDayOfMonth() + "일 ~ " +
                    winterVacationEnd.getMonthValue() + "월 " + winterVacationEnd.getDayOfMonth() + "일)");
            winterVacationEvent.put("startDate", winterVacationStart);
            winterVacationEvent.put("endDate", winterVacationEnd);
            winterVacationEvent.put("dateRange", winterVacationStart.getMonthValue() + "월 " + winterVacationStart.getDayOfMonth() + "일 ~ " +
                    winterVacationEnd.getMonthValue() + "월 " + winterVacationEnd.getDayOfMonth() + "일");
            winterVacationEvent.put("description", "겨울방학 기간 (" + duration + "일간)" + (nextFirstSemesterStart == null ? " - 추정" : ""));
            winterVacationEvent.put("category", "vacation");
            winterVacationEvent.put("isImportant", false);
            winterVacationEvent.put("daysUntil", daysUntil);
            winterVacationEvent.put("duration", duration);

            vacationEvents.add(winterVacationEvent);
            debugLogs.add("✅ 겨울방학 추가: " + winterVacationStart + " ~ " + winterVacationEnd);
        }

        debugLogs.add("총 " + vacationEvents.size() + "개 방학 기간 추가됨");
        return vacationEvents;
    }

    private String categorizeEvent(String eventText) {
        String text = eventText.toLowerCase();

        if (text.contains("시험") || text.contains("고사") || text.contains("중간고사") || text.contains("기말고사")) {
            return "exam";
        }
        if (text.contains("수강신청") || text.contains("등록") || text.contains("신청")) {
            return "registration";
        }
        if (text.contains("방학") || text.contains("휴업") || text.contains("휴강")) {
            return "vacation";
        }
        if (text.contains("마감") || text.contains("제출") || text.contains("접수")) {
            return "deadline";
        }
        if (text.contains("개강") || text.contains("종강") || text.contains("입학") || text.contains("졸업") ||
                text.contains("행사") || text.contains("축제") || text.contains("설명회")) {
            return "event";
        }

        return "event";
    }

    private boolean isImportantEvent(String eventText) {
        String[] importantKeywords = {"시험", "고사", "중간고사", "기말고사", "수강신청", "등록", "마감", "제출", "개강", "종강", "졸업", "입학"};
        String text = eventText.toLowerCase();
        for (String keyword : importantKeywords) {
            if (text.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    private List<Map<String, Object>> filterImportantEvents(List<Map<String, Object>> allEvents) {
        List<Map<String, Object>> importantEvents = new ArrayList<>();
        for (Map<String, Object> event : allEvents) {
            if ((Boolean) event.get("isImportant")) {
                importantEvents.add(event);
            }
        }
        return importantEvents;
    }

    private List<Map<String, Object>> filterUpcomingEvents(List<Map<String, Object>> allEvents, int daysLimit) {
        LocalDate today = LocalDate.now();
        LocalDate limitDate = today.plusDays(daysLimit);

        List<Map<String, Object>> upcomingEvents = new ArrayList<>();
        for (Map<String, Object> event : allEvents) {
            LocalDate startDate = (LocalDate) event.get("startDate");
            if (!startDate.isBefore(today) && !startDate.isAfter(limitDate)) {
                upcomingEvents.add(event);
            }
        }
        return upcomingEvents;
    }

    private Map<String, List<Map<String, Object>>> categorizeEvents(List<Map<String, Object>> allEvents) {
        Map<String, List<Map<String, Object>>> categorized = new HashMap<>();

        categorized.put("exam", new ArrayList<>());
        categorized.put("vacation", new ArrayList<>());
        categorized.put("deadline", new ArrayList<>());
        categorized.put("event", new ArrayList<>());
        categorized.put("registration", new ArrayList<>());

        for (Map<String, Object> event : allEvents) {
            String category = (String) event.get("category");
            categorized.computeIfAbsent(category, k -> new ArrayList<>()).add(event);
        }

        return categorized;
    }

    private List<Map<String, Object>> getDummyAcademicData() {
        List<Map<String, Object>> events = new ArrayList<>();
        LocalDate today = LocalDate.now();

        Map<String, Object> event1 = new HashMap<>();
        event1.put("id", "event-1");
        event1.put("title", "2024학년도 1학기 기말고사");
        event1.put("startDate", today.plusDays(7));
        event1.put("endDate", today.plusDays(7));
        event1.put("dateRange", today.plusDays(7).getMonthValue() + "월 " + today.plusDays(7).getDayOfMonth() + "일");
        event1.put("description", "1학기 기말고사 기간");
        event1.put("category", "exam");
        event1.put("isImportant", true);
        event1.put("daysUntil", 7L);
        events.add(event1);

        Map<String, Object> event2 = new HashMap<>();
        event2.put("id", "event-2");
        event2.put("title", "여름학기 수강신청");
        event2.put("startDate", today.plusDays(14));
        event2.put("endDate", today.plusDays(14));
        event2.put("dateRange", today.plusDays(14).getMonthValue() + "월 " + today.plusDays(14).getDayOfMonth() + "일");
        event2.put("description", "여름학기 수강신청 기간");
        event2.put("category", "registration");
        event2.put("isImportant", true);
        event2.put("daysUntil", 14L);
        events.add(event2);

        Map<String, Object> event3 = new HashMap<>();
        event3.put("id", "event-3");
        event3.put("title", "여름방학 (7월 1일 ~ 8월 31일)");
        event3.put("startDate", today.plusDays(30));
        event3.put("endDate", today.plusDays(92));
        event3.put("dateRange", "7월 1일 ~ 8월 31일");
        event3.put("description", "여름방학 기간 (62일간)");
        event3.put("category", "vacation");
        event3.put("isImportant", false);
        event3.put("daysUntil", 30L);
        events.add(event3);

        Map<String, Object> event4 = new HashMap<>();
        event4.put("id", "event-4");
        event4.put("title", "2학기 수강신청");
        event4.put("startDate", today.plusDays(45));
        event4.put("endDate", today.plusDays(45));
        event4.put("dateRange", today.plusDays(45).getMonthValue() + "월 " + today.plusDays(45).getDayOfMonth() + "일");
        event4.put("description", "2024학년도 2학기 수강신청");
        event4.put("category", "registration");
        event4.put("isImportant", true);
        event4.put("daysUntil", 45L);
        events.add(event4);

        Map<String, Object> event5 = new HashMap<>();
        event5.put("id", "event-5");
        event5.put("title", "2학기 개강");
        event5.put("startDate", today.plusDays(60));
        event5.put("endDate", today.plusDays(60));
        event5.put("dateRange", today.plusDays(60).getMonthValue() + "월 " + today.plusDays(60).getDayOfMonth() + "일");
        event5.put("description", "2024학년도 2학기 개강");
        event5.put("category", "event");
        event5.put("isImportant", true);
        event5.put("daysUntil", 60L);
        events.add(event5);

        return events;
    }

    // 기타 메서드들 (날씨, 학식 등)
    private Map<String, Object> getWeatherData(List<String> debugLogs) throws IOException {
        URL url = new URL(WEATHER_API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        StringBuilder response;
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
            response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
        }

        JsonNode root = new ObjectMapper().readTree(response.toString());
        Map<String, Object> weatherData = new HashMap<>();
        weatherData.put("temperature", Math.round(root.path("main").path("temp").asDouble()));
        weatherData.put("description", root.path("weather").get(0).path("description").asText());
        weatherData.put("humidity", root.path("main").path("humidity").asInt());
        weatherData.put("windSpeed", root.path("wind").path("speed").asDouble());
        weatherData.put("feelsLike", Math.round(root.path("main").path("feels_like").asDouble()));
        String iconCode = root.path("weather").get(0).path("icon").asText();
        weatherData.put("icon", mapWeatherIcon(iconCode));
        weatherData.put("advice", getWeatherAdvice((double) weatherData.get("temperature"), (String) weatherData.get("description")));
        return weatherData;
    }

    private Map<String, Object> getCafeteriaMenuFromWebsite(List<String> debugLogs) throws IOException {
        String cafeteriaUrl = "https://www.anyang.ac.kr/main/activities/school-cafeteria.do";
        debugLogs.add("크롤링 URL: " + cafeteriaUrl);

        try {
            URL url = new URL(cafeteriaUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(15000);

            int responseCode = conn.getResponseCode();
            debugLogs.add("HTTP 응답 코드: " + responseCode);

            if (responseCode != 200) {
                throw new IOException("HTTP " + responseCode + ": 학식 메뉴 페이지를 불러올 수 없습니다.");
            }

            StringBuilder responseText = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    responseText.append(line);
                }
            }

            debugLogs.add("HTML 응답 길이: " + responseText.length());

            // Jsoup으로 HTML 파싱
            Document doc = Jsoup.parse(responseText.toString());
            Elements boardTables = doc.select(".board-table");
            debugLogs.add("board-table 개수: " + boardTables.size());

            // 현재 요일 확인
            LocalDate today = LocalDate.now();
            String[] dayNames = {"일", "월", "화", "수", "목", "금", "토"};
            String currentDay = dayNames[today.getDayOfWeek().getValue() % 7];
            debugLogs.add("오늘 요일: " + currentDay);

            // 요일별 메뉴와 고정 메뉴 파싱
            Map<String, List<Map<String, Object>>> weeklyMenus = new HashMap<>();
            List<Map<String, Object>> lunchRegularMenus = new ArrayList<>();
            List<Map<String, Object>> dinnerRegularMenus = new ArrayList<>();

            // 첫 번째 board-table: 요일 한정 메뉴
            if (boardTables.size() > 0) {
                Element weeklyTable = boardTables.get(0);
                debugLogs.add("요일별 메뉴 테이블 파싱 시작");

                Elements headers = weeklyTable.select("th");
                Map<String, Integer> dayColumns = new HashMap<>();

                for (int i = 0; i < headers.size(); i++) {
                    String headerText = headers.get(i).text().trim();
                    if (headerText.matches(".*(월|화|수|목|금|토|일).*")) {
                        String day = headerText.replaceAll(".*([월화수목금토일]).*", "$1");
                        dayColumns.put(day, i);
                        debugLogs.add("요일 컬럼 발견: " + day + " (컬럼 " + i + ")");
                    }
                }

                Elements rows = weeklyTable.select("tr");
                for (int rowIndex = 1; rowIndex < rows.size(); rowIndex++) { // 헤더 건너뛰기
                    Element row = rows.get(rowIndex);
                    Elements cells = row.select("td");

                    for (Map.Entry<String, Integer> entry : dayColumns.entrySet()) {
                        String day = entry.getKey();
                        int columnIndex = entry.getValue();

                        if (cells.size() > columnIndex) {
                            String menuText = cells.get(columnIndex).text().trim();
                            if (!menuText.isEmpty() && !menuText.equals("-") && !menuText.equals("식당메뉴")) {
                                String cleanMenuName = menuText.replaceAll("\\$[^)]*\\$", "").trim();

                                Map<String, Object> menuItem = new HashMap<>();
                                menuItem.put("name", cleanMenuName);
                                menuItem.put("isSpecial", true);

                                String category = categorizeFood(cleanMenuName);
                                if (category != null) {
                                    menuItem.put("category", category);
                                }

                                weeklyMenus.computeIfAbsent(day, k -> new ArrayList<>()).add(menuItem);
                                debugLogs.add(day + "요일 메뉴 추가: " + cleanMenuName);
                            }
                        }
                    }
                }
            }

            // 두 번째 board-table: 고정 메뉴
            if (boardTables.size() > 1) {
                Element regularTable = boardTables.get(1);
                debugLogs.add("고정 메뉴 테이블 파싱 시작");

                Elements cells = regularTable.select("td");
                for (Element cell : cells) {
                    String menuText = cell.text().trim();
                    if (!menuText.isEmpty() && !menuText.equals("-") && !menuText.equals("식당메뉴")) {
                        String cleanMenuName = menuText.replaceAll("\\$[^)]*\\$", "").trim();

                        Map<String, Object> menuItem = new HashMap<>();
                        menuItem.put("name", cleanMenuName);
                        menuItem.put("isRegular", true);

                        String category = categorizeFood(cleanMenuName);
                        if (category != null) {
                            menuItem.put("category", category);
                        }

                        // 중식 메뉴에 추가
                        lunchRegularMenus.add(menuItem);

                        // 석식 메뉴에도 추가 (조식 관련 메뉴 제외)
                        if (!menuText.toLowerCase().contains("조식")) {
                            Map<String, Object> dinnerItem = new HashMap<>(menuItem);
                            dinnerRegularMenus.add(dinnerItem);
                        }

                        debugLogs.add("고정 메뉴 추가: " + cleanMenuName);
                    }
                }
            }

            // 오늘의 메뉴 구성
            List<Map<String, Object>> todayLunchMenu = new ArrayList<>();
            List<Map<String, Object>> todayDinnerMenu = new ArrayList<>();

            // 오늘의 특별 메뉴 추가
            if (weeklyMenus.containsKey(currentDay)) {
                todayLunchMenu.addAll(weeklyMenus.get(currentDay));
            }

            // 고정 메뉴 추가
            todayLunchMenu.addAll(lunchRegularMenus);

            // 금요일이 아닌 경우에만 석식 제공
            if (today.getDayOfWeek().getValue() != 5) {
                todayDinnerMenu.addAll(dinnerRegularMenus);
            }

            // 운영 시간 정보
            Map<String, String> operatingHours = new HashMap<>();
            operatingHours.put("weekdays", "월 ~ 목 10:00 ~ 15:30(중식) / 16:30~18:30(석식)");
            operatingHours.put("friday", "금요일 10:00 ~ 14:00(석식 없음)");

            // 최종 데이터 구성
            Map<String, Object> cafeteriaInfo = new HashMap<>();
            cafeteriaInfo.put("name", "학생회관 식당");
            cafeteriaInfo.put("location", "수리관 7층");
            cafeteriaInfo.put("hours", operatingHours);
            cafeteriaInfo.put("description", "교내식당은 신입생, 재학생 및 교직원에게 중식, 석식을 제공하고 있습니다.");

            Map<String, List<Map<String, Object>>> meals = new HashMap<>();
            meals.put("lunch", todayLunchMenu);
            meals.put("dinner", todayDinnerMenu);
            cafeteriaInfo.put("meals", meals);

            debugLogs.add("✅ 크롤링 완료 - 중식: " + todayLunchMenu.size() + "개, 석식: " + todayDinnerMenu.size() + "개");

            return cafeteriaInfo;

        } catch (Exception e) {
            debugLogs.add("크롤링 중 오류: " + e.getMessage());
            throw new IOException("학식 메뉴 크롤링 실패", e);
        }
    }

    private String categorizeFood(String menuName) {
        String name = menuName.toLowerCase();

        // 확실한 한식
        if (name.contains("김치") || name.contains("된장") || name.contains("고추장") ||
                name.contains("비빔밥") || name.contains("불고기") || name.contains("갈비") ||
                name.contains("제육") || name.contains("순두부") || name.contains("삼겹살") ||
                name.contains("김치찌개") || name.contains("된장찌개") || name.contains("부대찌개") ||
                name.contains("콩나물") || name.contains("미역국") || name.contains("떡국") ||
                name.contains("냉면") || name.contains("잡채")) {
            return "한식";
        }

        // 확실한 일식
        if (name.contains("돈까스") || name.contains("가라아게") || name.contains("가츠") ||
                name.contains("우동") || name.contains("라멘") || name.contains("카레") ||
                name.contains("덮밥") || name.contains("규동") || name.contains("가츠동") ||
                name.contains("텐동") || name.contains("야키") || name.contains("테리야키") ||
                name.contains("스시") || name.contains("사시미") || name.contains("미소")) {
            return "일식";
        }

        // 확실한 중식
        if (name.contains("짜장") || name.contains("짬뽕") || name.contains("탕수육") ||
                name.contains("마파두부") || name.contains("깐풍기") || name.contains("양장피") ||
                name.contains("볶음면") || name.contains("유린기") || name.contains("팔보채") ||
                name.contains("춘장")) {
            return "중식";
        }

        // 확실한 양식
        if (name.contains("파스타") || name.contains("스파게티") || name.contains("피자") ||
                name.contains("스테이크") || name.contains("샐러드") || name.contains("리조또") ||
                name.contains("오믈렛") || name.contains("그라탕") || name.contains("크림") ||
                name.contains("토마토") || name.contains("치즈") || name.contains("버거") ||
                name.contains("샌드위치")) {
            return "양식";
        }

        // 애매한 경우는 null 반환 (카테고리 표시 안함)
        return null;
    }

    private Map<String, Object> getDefaultCafeteriaData() {
        LocalDate today = LocalDate.now();
        String[] dayNames = {"일", "월", "화", "수", "목", "금", "토"};
        String currentDay = dayNames[today.getDayOfWeek().getValue() % 7];

        List<Map<String, Object>> todaySpecialMenu = new ArrayList<>();
        if ("수".equals(currentDay)) {
            Map<String, Object> specialItem = new HashMap<>();
            specialItem.put("name", "가라아게마요덮밥");
            specialItem.put("category", "일식");
            specialItem.put("isSpecial", true);
            todaySpecialMenu.add(specialItem);
        }

        List<Map<String, Object>> regularMenu = new ArrayList<>();
        Map<String, Object> item1 = new HashMap<>();
        item1.put("name", "라면");
        item1.put("category", "한식");
        item1.put("isRegular", true);
        regularMenu.add(item1);

        Map<String, Object> item2 = new HashMap<>();
        item2.put("name", "김밥");
        item2.put("category", "한식");
        item2.put("isRegular", true);
        regularMenu.add(item2);

        Map<String, Object> item3 = new HashMap<>();
        item3.put("name", "돈까스");
        item3.put("category", "일식");
        item3.put("isRegular", true);
        regularMenu.add(item3);

        List<Map<String, Object>> lunchMenu = new ArrayList<>();
        lunchMenu.addAll(todaySpecialMenu);
        lunchMenu.addAll(regularMenu);

        List<Map<String, Object>> dinnerMenu = new ArrayList<>();
        if (today.getDayOfWeek().getValue() != 5) { // 금요일이 아닌 경우
            Map<String, Object> dinnerItem1 = new HashMap<>();
            dinnerItem1.put("name", "제육덮밥");
            dinnerItem1.put("category", "한식");
            dinnerItem1.put("isRegular", true);
            dinnerMenu.add(dinnerItem1);

            Map<String, Object> dinnerItem2 = new HashMap<>();
            dinnerItem2.put("name", "김치찌개");
            dinnerItem2.put("category", "한식");
            dinnerItem2.put("isRegular", true);
            dinnerMenu.add(dinnerItem2);
        }

        Map<String, String> operatingHours = new HashMap<>();
        operatingHours.put("weekdays", "월 ~ 목 10:00 ~ 15:30(중식) / 16:30~18:30(석식)");
        operatingHours.put("friday", "금요일 10:00 ~ 14:00(석식 없음)");

        Map<String, Object> cafeteriaInfo = new HashMap<>();
        cafeteriaInfo.put("name", "학생회관 식당");
        cafeteriaInfo.put("location", "수리관 7층");
        cafeteriaInfo.put("hours", operatingHours);
        cafeteriaInfo.put("description", "교내식당은 신입생, 재학생 및 교직원에게 중식, 석식을 제공하고 있습니다.");

        Map<String, List<Map<String, Object>>> meals = new HashMap<>();
        meals.put("lunch", lunchMenu);
        meals.put("dinner", dinnerMenu);
        cafeteriaInfo.put("meals", meals);

        return cafeteriaInfo;
    }

    private Map<String, Object> getDefaultWeatherData() {
        Map<String, Object> data = new HashMap<>();
        data.put("temperature", 22);
        data.put("description", "정보 없음");
        data.put("humidity", 65);
        data.put("windSpeed", 2.5);
        data.put("feelsLike", 24);
        data.put("icon", "bi-question-circle");
        data.put("advice", "날씨 정보를 가져올 수 없습니다.");
        return data;
    }

    private List<Map<String, Object>> getDefaultCafeteriaMenu() {
        List<Map<String, Object>> weeklyMenu = new ArrayList<>();
        LocalDate startOfWeek = LocalDate.now().with(java.time.DayOfWeek.MONDAY);
        for (int i = 0; i < 5; i++) {
            LocalDate currentDate = startOfWeek.plusDays(i);
            Map<String, Object> dayMenu = new HashMap<>();
            dayMenu.put("dayName", currentDate.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.KOREAN));
            dayMenu.put("date", currentDate.format(DateTimeFormatter.ofPattern("MM/dd")));
            dayMenu.put("isToday", currentDate.equals(LocalDate.now()));
            Map<String, List<String>> meals = new HashMap<>();
            meals.put("lunch", Arrays.asList("정보 없음"));
            meals.put("dinner", Arrays.asList("정보 없음"));
            dayMenu.put("meals", meals);
            weeklyMenu.add(dayMenu);
        }
        return weeklyMenu;
    }

    private String mapWeatherIcon(String iconCode) {
        if (iconCode == null) return "bi-question-circle";
        switch (iconCode.substring(0, 2)) {
            case "01":
                return "bi-sun-fill";
            case "02":
                return "bi-cloud-sun-fill";
            case "03":
                return "bi-cloud-fill";
            case "04":
                return "bi-clouds-fill";
            case "09":
                return "bi-cloud-rain-heavy-fill";
            case "10":
                return "bi-cloud-rain-fill";
            case "11":
                return "bi-cloud-lightning-rain-fill";
            case "13":
                return "bi-snow";
            case "50":
                return "bi-cloud-fog2-fill";
            default:
                return "bi-question-circle";
        }
    }

    private String getWeatherAdvice(double temp, String desc) {
        if (desc.contains("비")) return "우산을 꼭 챙기세요. ☔";
        if (desc.contains("눈")) return "길이 미끄러울 수 있으니 조심하세요. ❄️";
        if (temp > 28) return "매우 더운 날씨에요. 시원한 곳에 머무르세요. ☀️";
        if (temp < 5) return "날씨가 추워요. 따뜻하게 입으세요. 🧥";
        return "활동하기 좋은 날씨입니다! 😊";
    }

    private Map<String, Object> getAdvancedWeatherData(List<String> debugLogs) throws IOException {
        // 안양대학교 정확한 좌표
        double lat = 37.39055872088402;
        double lon = 126.91902430172887;

        String currentWeatherUrl = String.format(
                "https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=%s&units=metric&lang=kr",
                lat, lon, WEATHER_API_KEY
        );
        String forecastUrl = String.format(
                "https://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&appid=%s&units=metric&lang=kr",
                lat, lon, WEATHER_API_KEY
        );

        debugLogs.add("현재 날씨 URL: " + currentWeatherUrl);
        debugLogs.add("예보 URL: " + forecastUrl);

        try {
            // 현재 날씨 데이터 가져오기
            JsonNode currentData = fetchWeatherJson(currentWeatherUrl, debugLogs);
            JsonNode forecastData = fetchWeatherJson(forecastUrl, debugLogs);

            debugLogs.add("현재 날씨 데이터 키: " + String.join(", ", getJsonKeys(currentData)));
            debugLogs.add("예보 데이터 아이템 수: " + (forecastData.has("list") ? forecastData.get("list").size() : 0));

            // 데이터 검증
            if (!currentData.has("main") || !currentData.has("weather")) {
                throw new IOException("API 응답에 필수 날씨 데이터가 없습니다");
            }

            debugLogs.add("API 호출 성공! 데이터 파싱 시작");

            // 날씨 데이터 파싱
            return parseAdvancedWeatherData(currentData, forecastData, debugLogs);

        } catch (Exception e) {
            debugLogs.add("API 호출 중 오류: " + e.getMessage());
            throw new IOException("날씨 데이터 가져오기 실패", e);
        }
    }

    private JsonNode fetchWeatherJson(String urlString, List<String> debugLogs) throws IOException {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Accept", "application/json");
        conn.setRequestProperty("User-Agent", "Weather-App/1.0");
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(10000);

        int responseCode = conn.getResponseCode();
        debugLogs.add("HTTP 응답 코드: " + responseCode);

        if (responseCode != 200) {
            throw new IOException("HTTP " + responseCode + ": API 호출 실패");
        }

        StringBuilder response = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
        }

        return new ObjectMapper().readTree(response.toString());
    }

    private List<String> getJsonKeys(JsonNode node) {
        List<String> keys = new ArrayList<>();
        if (node.isObject()) {
            Iterator<String> fieldNames = node.fieldNames();
            while (fieldNames.hasNext()) {
                keys.add(fieldNames.next());
            }
        }
        return keys;
    }

    private Map<String, Object> parseAdvancedWeatherData(JsonNode currentData, JsonNode forecastData, List<String> debugLogs) {
        debugLogs.add("=== 날씨 데이터 파싱 시작 ===");

        try {
            // 현재 날씨 파싱
            Map<String, Object> current = new HashMap<>();
            current.put("temperature", (int) Math.round(currentData.get("main").get("temp").asDouble()));
            current.put("condition", getKoreanCondition(
                    currentData.get("weather").get(0).get("main").asText(),
                    currentData.get("weather").get(0).get("description").asText()
            ));
            current.put("humidity", currentData.get("main").get("humidity").asInt());
            current.put("windSpeed", currentData.has("wind") && currentData.get("wind").has("speed") ?
                    Math.round(currentData.get("wind").get("speed").asDouble() * 10.0) / 10.0 : 0.0);
            current.put("visibility", currentData.has("visibility") ?
                    Math.round(currentData.get("visibility").asDouble() / 100.0) / 10.0 : 10.0);
            current.put("feelsLike", (int) Math.round(currentData.get("main").get("feels_like").asDouble()));
            current.put("pressure", currentData.get("main").has("pressure") ?
                    currentData.get("main").get("pressure").asInt() : 1013);
            current.put("description", currentData.get("weather").get(0).get("description").asText());

            debugLogs.add("현재 날씨 파싱 완료: " + current.get("temperature") + "°C, " + current.get("condition"));

            // 예보 데이터 파싱
            List<Map<String, Object>> forecast = forecastData != null ?
                    generateRealForecast(forecastData, current, currentData, debugLogs) :
                    generateForecastFromCurrent(current, debugLogs);

            // 날씨 조언 생성
            String advice = getAdvancedWeatherAdvice(
                    (Integer) current.get("temperature"),
                    (String) current.get("condition")
            );

            Map<String, Object> result = new HashMap<>();
            result.put("current", current);
            result.put("forecast", forecast);
            result.put("advice", advice);

            return result;

        } catch (Exception parseError) {
            debugLogs.add("데이터 파싱 중 오류: " + parseError.getMessage());
            throw new RuntimeException("날씨 데이터 파싱 실패: " + parseError.getMessage(), parseError);
        }
    }

    private String getKoreanCondition(String main, String description) {
        Map<String, String> conditionMap = new HashMap<>();
        conditionMap.put("Clear", "맑음");
        conditionMap.put("Clouds", "구름많음");
        conditionMap.put("Rain", "비");
        conditionMap.put("Drizzle", "이슬비");
        conditionMap.put("Thunderstorm", "뇌우");
        conditionMap.put("Snow", "눈");
        conditionMap.put("Mist", "안개");
        conditionMap.put("Fog", "안개");
        conditionMap.put("Haze", "연무");

        if ("Clouds".equals(main)) {
            if (description != null) {
                if (description.contains("few")) return "구름조금";
                if (description.contains("scattered")) return "구름많음";
                if (description.contains("broken") || description.contains("overcast")) return "흐림";
            }
            return "구름많음";
        }

        String result = conditionMap.get(main);
        return result != null ? result : "맑음";
    }

    private List<Map<String, Object>> generateRealForecast(JsonNode forecastData, Map<String, Object> currentWeather, JsonNode currentData, List<String> debugLogs) {
        debugLogs.add("=== 실제 예보 데이터 파싱 ===");

        Map<String, List<JsonNode>> dailyData = new HashMap<>();

        // 예보 데이터를 날짜별로 그룹화
        if (forecastData.has("list")) {
            for (JsonNode item : forecastData.get("list")) {
                String date = item.get("dt_txt").asText().split(" ")[0];
                if (!dailyData.containsKey(date)) {
                    dailyData.put(date, new ArrayList<JsonNode>());
                }
                dailyData.get(date).add(item);
            }
        }

        List<String> dateKeys = new ArrayList<>(dailyData.keySet());
        debugLogs.add("날짜별 그룹화 결과: " + String.join(", ", dateKeys));

        List<Map<String, Object>> forecast = new ArrayList<>();
        LocalDate today = LocalDate.now();
        String todayStr = today.toString();

        // 5일 예보 생성
        for (int i = 0; i < 5; i++) {
            LocalDate targetDate = today.plusDays(i);
            String dateStr = targetDate.toString();

            List<JsonNode> dayData = dailyData.get(dateStr);
            if (dayData == null) {
                dayData = new ArrayList<>();
            }

            int high, low;
            String condition;

            if (!dayData.isEmpty()) {
                // 실제 예보 데이터 사용
                List<Double> temps = new ArrayList<>();
                for (JsonNode d : dayData) {
                    temps.add(d.get("main").get("temp").asDouble());
                }

                // 오늘 날짜인 경우 현재 날씨 데이터도 고려
                if (dateStr.equals(todayStr)) {
                    temps.add(currentData.get("main").get("temp").asDouble());
                    temps.add(currentData.get("main").get("temp_max").asDouble());
                    temps.add(currentData.get("main").get("temp_min").asDouble());
                }

                // Java 8 호환 방식으로 최대/최소값 계산
                double maxTemp = temps.get(0);
                double minTemp = temps.get(0);
                for (Double temp : temps) {
                    if (temp > maxTemp) maxTemp = temp;
                    if (temp < minTemp) minTemp = temp;
                }

                high = (int) Math.round(maxTemp);
                low = (int) Math.round(minTemp);

                // 날씨 조건 결정
                List<String> weatherConditions = new ArrayList<>();
                for (JsonNode d : dayData) {
                    weatherConditions.add(d.get("weather").get(0).get("main").asText());
                }

                if (dateStr.equals(todayStr)) {
                    weatherConditions.add(0, currentData.get("weather").get(0).get("main").asText());
                }

                // 우선순위 기반 날씨 조건 선택
                String[] priorityOrder = {"Thunderstorm", "Rain", "Drizzle", "Snow", "Clouds", "Clear", "Mist", "Fog", "Haze"};
                String selectedCondition = weatherConditions.get(0);

                for (String priority : priorityOrder) {
                    if (weatherConditions.contains(priority)) {
                        selectedCondition = priority;
                        break;
                    }
                }

                condition = getKoreanCondition(selectedCondition, "");

            } else {
                // 추정 데이터 사용
                high = 25;
                low = 15;
                condition = "맑음";
            }

            Map<String, Object> dayForecast = new HashMap<>();
            dayForecast.put("date", dateStr);
            dayForecast.put("day", i == 0 ? "오늘" : i == 1 ? "내일" :
                    new String[]{"일", "월", "화", "수", "목", "금", "토"}[targetDate.getDayOfWeek().getValue() % 7]);
            dayForecast.put("high", high);
            dayForecast.put("low", low);
            dayForecast.put("condition", condition);
            dayForecast.put("icon", getWeatherIcon(condition));
            dayForecast.put("isEstimated", dayData.isEmpty());

            forecast.add(dayForecast);
        }

        return forecast;
    }

    private List<Map<String, Object>> generateForecastFromCurrent(Map<String, Object> current, List<String> debugLogs) {
        List<Map<String, Object>> forecast = new ArrayList<>();
        LocalDate today = LocalDate.now();

        // 현재 계절에 맞는 온도 범위 설정
        int month = today.getMonthValue();
        int baseHigh, baseLow;

        if (month >= 6 && month <= 8) {
            baseHigh = 31;
            baseLow = 20; // 여름
        } else if (month >= 9 && month <= 11) {
            baseHigh = 20;
            baseLow = 10; // 가을
        } else if (month >= 12 || month <= 2) {
            baseHigh = 5;
            baseLow = -5; // 겨울
        } else {
            baseHigh = 18;
            baseLow = 8; // 봄
        }

        for (int i = 0; i < 5; i++) {
            LocalDate forecastDate = today.plusDays(i);

            // 날짜별 변동성
            double tempVariation = Math.sin((i * Math.PI) / 7) * 3 + (Math.random() * 4 - 2);

            int high = (int) Math.round(baseHigh + tempVariation);
            int low = (int) Math.round(baseLow + tempVariation);

            String[] conditions = {"맑음", "구름조금", "구름많음", "흐림"};
            String dayCondition = i == 0 ? (String) current.get("condition") :
                    conditions[(int) (Math.random() * conditions.length)];

            Map<String, Object> dayForecast = new HashMap<>();
            dayForecast.put("date", forecastDate.toString());
            dayForecast.put("day", i == 0 ? "오늘" : i == 1 ? "내일" :
                    new String[]{"일", "월", "화", "수", "목", "금", "토"}[forecastDate.getDayOfWeek().getValue() % 7]);
            dayForecast.put("high", high);
            dayForecast.put("low", low);
            dayForecast.put("condition", dayCondition);
            dayForecast.put("icon", getWeatherIcon(dayCondition));
            dayForecast.put("isEstimated", true);

            forecast.add(dayForecast);
        }

        return forecast;
    }

    private String getWeatherIcon(String condition) {
        Map<String, String> iconMap = new HashMap<>();
        iconMap.put("맑음", "☀️");
        iconMap.put("구름조금", "🌤️");
        iconMap.put("구름많음", "⛅");
        iconMap.put("흐림", "☁️");
        iconMap.put("비", "🌧️");
        iconMap.put("이슬비", "🌦️");
        iconMap.put("뇌우", "⛈️");
        iconMap.put("눈", "❄️");
        iconMap.put("안개", "🌫️");
        iconMap.put("연무", "🌫️");
        String result = iconMap.get(condition);
        return result != null ? result : "☀️";
    }

    private String getAdvancedWeatherAdvice(int temp, String condition) {
        if (temp < 0) return "매우 추워요! 두꺼운 패딩과 목도리를 챙기세요 🧥";
        if (temp < 5) return "춥습니다. 따뜻한 옷차림을 하세요 🧥";
        if (temp < 10) return "쌀쌀해요. 겉옷을 챙기세요 🧥";
        if (temp > 30) return "매우 더워요! 시원한 옷차림과 충분한 수분 섭취하세요 ☀️";
        if (temp > 25) return "더워요! 가벼운 옷차림을 추천해요 👕";

        if (condition.contains("비")) return "우산을 챙기세요! ☔";
        if (condition.contains("뇌우")) return "우산과 함께 안전에 주의하세요! ⛈️";
        if (condition.contains("눈")) return "미끄러지지 않도록 조심하세요! ❄️";
        if (condition.contains("안개")) return "시야가 흐려요. 이동 시 주의하세요 🌫️";

        if (temp >= 18 && temp <= 25 && ("맑음".equals(condition) || "구름조금".equals(condition))) {
            return "날씨가 좋네요! 캠퍼스 산책하기 좋은 날이에요 😊";
        }

        return "적당한 옷차림으로 하루를 시작하세요! 😊";
    }

    private Map<String, Object> generateRealisticWeatherData() {
        LocalDate now = LocalDate.now();
        int month = now.getMonthValue();
        int hour = LocalTime.now().getHour();

        // 계절별 기본 온도 설정
        int baseTemp = 20, highTemp = 31, lowTemp = 20;

        if (month >= 12 || month <= 2) {
            baseTemp = 0;
            highTemp = 5;
            lowTemp = -5; // 겨울
        } else if (month >= 3 && month <= 5) {
            baseTemp = 15;
            highTemp = 20;
            lowTemp = 10; // 봄
        } else if (month >= 9 && month <= 11) {
            baseTemp = 15;
            highTemp = 20;
            lowTemp = 10; // 가을
        }

        // 시간대별 온도 조정
        double hourFactor = hour < 6 ? 0.2 : hour < 12 ? 0.6 : hour < 18 ? 1.0 : 0.7;
        int currentTemp = (int) Math.round(lowTemp + (highTemp - lowTemp) * hourFactor);

        String[] conditions = {"맑음", "구름조금", "구름많음"};
        String condition = conditions[(int) (Math.random() * conditions.length)];

        Map<String, Object> current = new HashMap<>();
        current.put("temperature", currentTemp);
        current.put("condition", condition);
        current.put("humidity", 50 + (int) (Math.random() * 30));
        current.put("windSpeed", Math.round((1 + Math.random() * 3) * 10.0) / 10.0);
        current.put("visibility", Math.round((8 + Math.random() * 4) * 10.0) / 10.0);
        current.put("feelsLike", currentTemp + (int) (Math.random() * 4) - 2);
        current.put("pressure", 1013 + (int) (Math.random() * 20) - 10);
        current.put("description", condition);

        List<Map<String, Object>> forecast = generateForecastFromCurrent(current, new ArrayList<String>());

        Map<String, Object> result = new HashMap<>();
        result.put("current", current);
        result.put("forecast", forecast);
        result.put("advice", getAdvancedWeatherAdvice(currentTemp, condition));

        return result;
    }
}
