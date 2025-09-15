package com.minari.tungzang.service;

import com.minari.tungzang.dao.CommentDAO;
import com.minari.tungzang.dao.EvaluationDAO;
import com.minari.tungzang.dao.PostDAO;
import com.minari.tungzang.dao.TimetableDAO;
import com.minari.tungzang.model.Badge;
import com.minari.tungzang.model.User;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

public class BadgeService {
    private static final Logger LOGGER = Logger.getLogger(BadgeService.class.getName());

    private EvaluationDAO evaluationDAO;
    private PostDAO postDAO;
    private CommentDAO commentDAO;
    private TimetableDAO timetableDAO;

    public BadgeService() {
        LOGGER.info("🔍 BadgeService 생성자 호출됨");
        this.evaluationDAO = new EvaluationDAO();
        this.postDAO = new PostDAO();
        this.commentDAO = new CommentDAO();
        this.timetableDAO = new TimetableDAO();
    }

    public List<Badge> getUserBadges(User user) {
        LOGGER.info("🔍 BadgeService.getUserBadges 호출됨: 사용자 ID=" + user.getId());
        List<Badge> badges = new ArrayList<>();

        try {
            int userId = user.getId();
            boolean isAdmin = user.isAdmin(); // "admin".equals(user.getRole()) 대신

            LOGGER.info("🔍 사용자 정보: ID=" + userId + ", 관리자=" + isAdmin);

            // 사용자 활동 데이터 조회 (관리자가 아닌 경우에만)
            int evaluationCount = isAdmin ? 999 : evaluationDAO.getUserEvaluationCount(userId);
            int postCount = isAdmin ? 999 : postDAO.getUserPostCount(userId);
            int commentCount = isAdmin ? 999 : commentDAO.getUserCommentCount(userId);
            int timetableCount = isAdmin ? 999 : timetableDAO.getUserTimetableCount(userId);

            LOGGER.info("🔍 활동 수: 평가=" + evaluationCount + ", 게시글=" + postCount + ", 댓글=" + commentCount + ", 시간표=" + timetableCount);

            // 강의평가 배지
            badges.add(createBadge(1, "강의평가 입문자", "첫 강의평가를 작성했어요!", "evaluation", "common", 1, isAdmin || evaluationCount >= 1, "bi-star"));
            badges.add(createBadge(2, "강의평가 초보자", "5개의 강의평가를 작성했어요!", "evaluation", "common", 5, isAdmin || evaluationCount >= 5, "bi-star-half"));
            badges.add(createBadge(3, "강의평가 중급자", "10개의 강의평가를 작성했어요!", "evaluation", "rare", 10, isAdmin || evaluationCount >= 10, "bi-star-fill"));
            badges.add(createBadge(4, "강의평가 고급자", "20개의 강의평가를 작성했어요!", "evaluation", "epic", 20, isAdmin || evaluationCount >= 20, "bi-stars"));
            badges.add(createBadge(5, "강의평가 마스터", "50개의 강의평가를 작성했어요!", "evaluation", "legendary", 50, isAdmin || evaluationCount >= 50, "bi-award"));

            // 커뮤니티 배지 - 게시글
            badges.add(createBadge(6, "게시글 작성자", "첫 게시글을 작성했어요!", "community", "common", 1, isAdmin || postCount >= 1, "bi-pencil"));
            badges.add(createBadge(7, "활발한 작성자", "5개의 게시글을 작성했어요!", "community", "common", 5, isAdmin || postCount >= 5, "bi-pencil-square"));
            badges.add(createBadge(8, "인기 작성자", "10개의 게시글을 작성했어요!", "community", "rare", 10, isAdmin || postCount >= 10, "bi-file-earmark-text"));
            badges.add(createBadge(9, "열정적인 작성자", "20개의 게시글을 작성했어요!", "community", "epic", 20, isAdmin || postCount >= 20, "bi-journal-text"));
            badges.add(createBadge(10, "커뮤니티 스타", "50개의 게시글을 작성했어요!", "community", "legendary", 50, isAdmin || postCount >= 50, "bi-trophy"));

            // 커뮤니티 배지 - 댓글
            badges.add(createBadge(11, "댓글 작성자", "첫 댓글을 작성했어요!", "community", "common", 1, isAdmin || commentCount >= 1, "bi-chat"));
            badges.add(createBadge(12, "활발한 댓글러", "10개의 댓글을 작성했어요!", "community", "common", 10, isAdmin || commentCount >= 10, "bi-chat-dots"));
            badges.add(createBadge(13, "소통왕", "30개의 댓글을 작성했어요!", "community", "rare", 30, isAdmin || commentCount >= 30, "bi-chat-square-text"));
            badges.add(createBadge(14, "댓글 마스터", "50개의 댓글을 작성했어요!", "community", "epic", 50, isAdmin || commentCount >= 50, "bi-chat-heart"));
            badges.add(createBadge(15, "소통의 달인", "100개의 댓글을 작성했어요!", "community", "legendary", 100, isAdmin || commentCount >= 100, "bi-chat-square-heart"));

            // 시간표 배지
            badges.add(createBadge(16, "시간표 작성자", "첫 시간표를 등록했어요!", "timetable", "common", 1, isAdmin || timetableCount >= 1, "bi-calendar"));
            badges.add(createBadge(17, "시간표 관리자", "5개의 강의를 시간표에 등록했어요!", "timetable", "common", 5, isAdmin || timetableCount >= 5, "bi-calendar-check"));
            badges.add(createBadge(18, "시간표 마스터", "10개의 강의를 시간표에 등록했어요!", "timetable", "rare", 10, isAdmin || timetableCount >= 10, "bi-calendar-week"));
            badges.add(createBadge(19, "완벽한 계획가", "15개의 강의를 시간표에 등록했어요!", "timetable", "epic", 15, isAdmin || timetableCount >= 15, "bi-calendar-heart"));
            badges.add(createBadge(20, "시간 관리의 달인", "20개의 강의를 시간표에 등록했어요!", "timetable", "legendary", 20, isAdmin || timetableCount >= 20, "bi-calendar-star"));

            // 종합 배지
            int totalActivities = evaluationCount + postCount + commentCount + timetableCount;
            LOGGER.info("🔍 총 활동 수: " + totalActivities);

            badges.add(createBadge(21, "텅장수강러 새내기", "텅장수강러에 오신 것을 환영합니다!", "overall", "common", 1, isAdmin || totalActivities >= 1, "bi-emoji-smile"));
            badges.add(createBadge(22, "텅장수강러 초급자", "10개의 활동을 완료했어요!", "overall", "common", 10, isAdmin || totalActivities >= 10, "bi-emoji-laughing"));
            badges.add(createBadge(23, "텅장수강러 중급자", "30개의 활동을 완료했어요!", "overall", "rare", 30, isAdmin || totalActivities >= 30, "bi-emoji-sunglasses"));
            badges.add(createBadge(24, "텅장수강러 고급자", "50개의 활동을 완료했어요!", "overall", "epic", 50, isAdmin || totalActivities >= 50, "bi-emoji-heart-eyes"));
            badges.add(createBadge(25, "텅장수강러 마스터", "100개의 활동을 완료했어요!", "overall", "legendary", 100, isAdmin || totalActivities >= 100, "bi-emoji-star-eyes"));

            // 관리자 전용 특별 배지
            if (isAdmin) {
                badges.add(createBadge(26, "시스템 관리자", "텅장수강러의 모든 것을 관리하는 최고 관리자입니다!", "admin", "admin", 1, true, "bi-shield-fill-check"));
                badges.add(createBadge(27, "데이터베이스 마스터", "모든 데이터를 완벽하게 관리합니다!", "admin", "admin", 1, true, "bi-server"));
                badges.add(createBadge(28, "커뮤니티 수호자", "건전한 커뮤니티 문화를 만들어갑니다!", "admin", "admin", 1, true, "bi-shield-heart"));
                badges.add(createBadge(29, "혁신의 리더", "새로운 기능과 서비스를 개발합니다!", "admin", "admin", 1, true, "bi-lightbulb"));
                badges.add(createBadge(30, "텅장수강러의 신", "모든 권한과 책임을 가진 최고 관리자!", "admin", "admin", 1, true, "bi-crown"));
            }

        } catch (Exception e) {
            LOGGER.severe("Badge information retrieval error: " + e.getMessage());
            e.printStackTrace();
        }

        return badges;
    }

    private Badge createBadge(int id, String name, String description, String category, String rarity, int requiredCount, boolean earned, String iconClass) {
        Badge badge = new Badge();
        badge.setId(id);
        badge.setName(name);
        badge.setDescription(description);
        badge.setCategory(category);
        badge.setRarity(rarity);
        badge.setRequiredCount(requiredCount);
        badge.setEarned(earned);
        badge.setIconClass(iconClass);
        return badge;
    }

    public String getUserGrade(List<Badge> badges, User user) {
        LOGGER.info("🔍 BadgeService.getUserGrade 호출됨 (User 포함): 사용자 ID=" + user.getId());

        // 관리자인 경우 특별 등급 반환
        if (user.isAdmin()) {
            LOGGER.info("🔍 관리자 등급 반환: 관리자");
            return "관리자";
        }

        int earnedCount = getEarnedBadgeCount(badges);
        LOGGER.info("🔍 획득한 배지 수: " + earnedCount);

        String grade;
        if (earnedCount >= 20) {
            grade = "마스터";
        } else if (earnedCount >= 15) {
            grade = "전문가";
        } else if (earnedCount >= 10) {
            grade = "숙련자";
        } else if (earnedCount >= 5) {
            grade = "초급자";
        } else {
            grade = "새내기";
        }

        LOGGER.info("🔍 계산된 등급: " + grade);
        return grade;
    }

    // 기존 getUserGrade 메서드 오버로드 (하위 호환성)
    public String getUserGrade(List<Badge> badges) {
        LOGGER.info("🔍 BadgeService.getUserGrade 호출됨 (User 없음)");

        int earnedCount = getEarnedBadgeCount(badges);
        LOGGER.info("🔍 획득한 배지 수: " + earnedCount);

        String grade;
        if (earnedCount >= 20) {
            grade = "마스터";
        } else if (earnedCount >= 15) {
            grade = "전문가";
        } else if (earnedCount >= 10) {
            grade = "숙련자";
        } else if (earnedCount >= 5) {
            grade = "초급자";
        } else {
            grade = "새내기";
        }

        LOGGER.info("🔍 계산된 등급: " + grade);
        return grade;
    }

    public int getEarnedBadgeCount(List<Badge> badges) {
        int count = 0;
        for (Badge badge : badges) {
            if (badge.isEarned()) {
                count++;
            }
        }
        LOGGER.info("🔍 배지 획득 수 계산: " + count + "개");
        return count;
    }

    public Map<String, Integer> getUserActivityCounts(User user) {
        LOGGER.info("🔍 BadgeService.getUserActivityCounts 호출됨: 사용자 ID=" + user.getId());

        Map<String, Integer> counts = new HashMap<>();
        int userId = user.getId();
        boolean isAdmin = user.isAdmin(); // "admin".equals(user.getRole()) 대신

        try {
            if (isAdmin) {
                LOGGER.info("🔍 관리자 활동 수 설정");
                // 관리자는 모든 활동을 최대치로 설정
                counts.put("evaluation", 999);
                counts.put("post", 999);
                counts.put("comment", 999);
                counts.put("timetable", 999);
                counts.put("community", 1998); // post + comment
                counts.put("overall", 3996); // 모든 활동의 합
                counts.put("admin", 999); // 관리자 전용 카테고리
            } else {
                LOGGER.info("🔍 일반 사용자 활동 수 조회");
                // 일반 사용자는 실제 활동 수 조회
                counts.put("evaluation", evaluationDAO.getUserEvaluationCount(userId));
                counts.put("post", postDAO.getUserPostCount(userId));
                counts.put("comment", commentDAO.getUserCommentCount(userId));
                counts.put("timetable", timetableDAO.getUserTimetableCount(userId));

                // 커뮤니티 활동은 게시글과 댓글의 합
                counts.put("community", counts.get("post") + counts.get("comment"));

                // 종합 활동은 모든 활동의 합
                counts.put("overall", counts.get("evaluation") + counts.get("community") + counts.get("timetable"));

                // 일반 사용자는 관리자 활동 없음
                counts.put("admin", 0);

                LOGGER.info("🔍 활동 수 결과: " + counts.toString());
            }
        } catch (Exception e) {
            LOGGER.severe("Error retrieving user activity counts: " + e.getMessage());
            e.printStackTrace();
        }

        return counts;
    }
}
