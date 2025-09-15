package com.minari.tungzang.util;

import com.minari.tungzang.model.Evaluation;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 강의 평가 데이터를 분석하여 태그를 자동으로 생성하는 유틸리티 클래스
 */
public class TagAnalyzer {

    // 키워드 기반 태그 매핑
    private static final Map<String, String> KEYWORD_TAGS = new HashMap<>();
    static {
        // 강의 방식 관련 키워드
        KEYWORD_TAGS.put("팀프로젝트", "팀프로젝트");
        KEYWORD_TAGS.put("팀플", "팀프로젝트");
        KEYWORD_TAGS.put("발표", "발표수업");
        KEYWORD_TAGS.put("토론", "토론수업");
        KEYWORD_TAGS.put("실습", "실습위주");
        KEYWORD_TAGS.put("이론", "이론위주");
        KEYWORD_TAGS.put("암기", "암기과목");

        // 평가 방식 관련 키워드
        KEYWORD_TAGS.put("중간고사", "중간고사");
        KEYWORD_TAGS.put("기말고사", "기말고사");
        KEYWORD_TAGS.put("퀴즈", "퀴즈있음");
        KEYWORD_TAGS.put("과제", "과제많음");
        KEYWORD_TAGS.put("레포트", "레포트");
        KEYWORD_TAGS.put("시험없", "시험없음");
        KEYWORD_TAGS.put("오픈북", "오픈북");

        // 수업 분위기 관련 키워드
        KEYWORD_TAGS.put("재미있", "재미있는");
        KEYWORD_TAGS.put("유익", "유익한");
        KEYWORD_TAGS.put("졸리", "졸린수업");
        KEYWORD_TAGS.put("지루", "지루한");
        KEYWORD_TAGS.put("엄격", "엄격한");
        KEYWORD_TAGS.put("자유", "자유로운");
        KEYWORD_TAGS.put("출석", "출석중요");
    }

    // 강의 유형 매핑 (영어 -> 한글)
    private static final Map<String, String> COURSE_TYPE_MAPPING = new HashMap<>();
    static {
        COURSE_TYPE_MAPPING.put("major", "전공필수");
        COURSE_TYPE_MAPPING.put("majorElective", "전공선택");
        COURSE_TYPE_MAPPING.put("general", "교양필수");
        COURSE_TYPE_MAPPING.put("generalElective", "교양선택");
        COURSE_TYPE_MAPPING.put("other", "기타");
        COURSE_TYPE_MAPPING.put("unknown", "기타");
    }

    // 정규식 패턴 기반 태그 매핑
    private static final Map<Pattern, String> PATTERN_TAGS = new HashMap<>();
    static {
        PATTERN_TAGS.put(Pattern.compile("과제\\s*많"), "과제많음");
        PATTERN_TAGS.put(Pattern.compile("과제\\s*없"), "과제없음");
        PATTERN_TAGS.put(Pattern.compile("시험\\s*없"), "시험없음");
        PATTERN_TAGS.put(Pattern.compile("출석\\s*(중요|필수|꼭|반드시)"), "출석중요");
        PATTERN_TAGS.put(Pattern.compile("(학점|성적)\\s*(잘|좋게|후하게)\\s*(줌|주심|주는)"), "학점좋음");
        PATTERN_TAGS.put(Pattern.compile("(학점|성적)\\s*(짜게|깐깐|까다롭게)\\s*(줌|주심|주는)"), "학점깐깐");
    }

    /**
     * 강의 평가 목록을 분석하여 태그를 생성합니다.
     *
     * @param evaluations 강의 평가 목록
     * @return 생성된 태그 목록
     */
    public static List<String> analyzeTags(List<Evaluation> evaluations) {
        if (evaluations == null || evaluations.isEmpty()) {
            return new ArrayList<>();
        }

        // 태그 빈도수 맵
        Map<String, Integer> tagFrequency = new HashMap<>();

        // 각 평가 분석
        for (Evaluation evaluation : evaluations) {
            // 1. 평가 내용 분석
            analyzeComment(evaluation.getComment(), tagFrequency);

            // 2. 특성(features) 분석
            analyzeFeatures(evaluation.getFeatures(), tagFrequency);

            // 3. 강의 유형 분석 (새로 추가)
            analyzeCourseType(evaluation.getCourseType(), tagFrequency);

            // 4. 수치 데이터 분석
            analyzeRating(evaluation.getRating(), tagFrequency);
            analyzeDifficulty(evaluation.getDifficulty(), tagFrequency);
            analyzeHomework(evaluation.getHomework(), tagFrequency);
        }

        // 빈도수 기준으로 상위 태그 선택 (최대 8개)
        return selectTopTags(tagFrequency, 8);
    }

    /**
     * 평가 내용을 분석하여 태그를 추출합니다.
     */
    private static void analyzeComment(String comment, Map<String, Integer> tagFrequency) {
        if (comment == null || comment.isEmpty()) {
            return;
        }

        // 소문자로 변환하여 분석
        String lowerComment = comment.toLowerCase();

        // 1. 키워드 기반 분석
        for (Map.Entry<String, String> entry : KEYWORD_TAGS.entrySet()) {
            if (lowerComment.contains(entry.getKey())) {
                incrementTagFrequency(tagFrequency, entry.getValue());
            }
        }

        // 2. 정규식 패턴 기반 분석
        for (Map.Entry<Pattern, String> entry : PATTERN_TAGS.entrySet()) {
            Matcher matcher = entry.getKey().matcher(lowerComment);
            if (matcher.find()) {
                incrementTagFrequency(tagFrequency, entry.getValue());
            }
        }
    }

    /**
     * 특성(features) 목록을 분석하여 태그를 추출합니다.
     */
    private static void analyzeFeatures(List<String> features, Map<String, Integer> tagFrequency) {
        if (features == null || features.isEmpty()) {
            return;
        }

        for (String feature : features) {
            incrementTagFrequency(tagFrequency, feature);
        }
    }

    /**
     * 평점을 분석하여 태그를 추출합니다.
     */
    private static void analyzeRating(int rating, Map<String, Integer> tagFrequency) {
        if (rating >= 4) {
            incrementTagFrequency(tagFrequency, "추천강의");
        } else if (rating <= 2) {
            incrementTagFrequency(tagFrequency, "비추천");
        }
    }

    /**
     * 난이도를 분석하여 태그를 추출합니다.
     */
    private static void analyzeDifficulty(int difficulty, Map<String, Integer> tagFrequency) {
        if (difficulty >= 4) {
            incrementTagFrequency(tagFrequency, "어려움");
        } else if (difficulty <= 2) {
            incrementTagFrequency(tagFrequency, "쉬움");
        }
    }

    /**
     * 과제량을 분석하여 태그를 추출합니다.
     */
    private static void analyzeHomework(int homework, Map<String, Integer> tagFrequency) {
        if (homework >= 4) {
            incrementTagFrequency(tagFrequency, "과제많음");
        } else if (homework <= 2) {
            incrementTagFrequency(tagFrequency, "과제적음");
        }
    }

    /**
     * 태그 빈도수를 증가시킵니다.
     */
    private static void incrementTagFrequency(Map<String, Integer> tagFrequency, String tag) {
        tagFrequency.put(tag, tagFrequency.getOrDefault(tag, 0) + 1);
    }

    /**
     * 빈도수 기준으로 상위 태그를 선택합니다.
     */
    private static List<String> selectTopTags(Map<String, Integer> tagFrequency, int limit) {
        // 빈도수 기준으로 정렬
        List<Map.Entry<String, Integer>> sortedEntries = new ArrayList<>(tagFrequency.entrySet());
        sortedEntries.sort((e1, e2) -> e2.getValue().compareTo(e1.getValue()));

        // 상위 태그 선택
        List<String> topTags = new ArrayList<>();
        int count = 0;
        for (Map.Entry<String, Integer> entry : sortedEntries) {
            if (count >= limit) {
                break;
            }
            topTags.add(entry.getKey());
            count++;
        }

        return topTags;
    }

    /**
     * 강의 유형을 분석하여 한글 태그를 추출합니다.
     */
    private static void analyzeCourseType(String courseType, Map<String, Integer> tagFrequency) {
        if (courseType == null || courseType.isEmpty()) {
            return;
        }

        String koreanType = COURSE_TYPE_MAPPING.get(courseType);
        if (koreanType != null) {
            incrementTagFrequency(tagFrequency, koreanType);
        }
    }
}
