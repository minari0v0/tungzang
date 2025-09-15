package com.minari.tungzang.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class Evaluation {
    private int id; // UUID
    private int courseId;
    private int userId;
    private String userName;
    private String courseName;
    private String professor;
    private int rating;
    private int difficulty;
    private int homework;
    private String courseType;
    private List<String> features;
    private String comment;
    private Timestamp date;
    private Timestamp updatedAt;
    private String authorInitial;
    private String authorName;
    private String semester;
    private String title;
    private String content;
    private int grading;
    private boolean liked;
    private boolean reported;
    private int likes;
    private String formattedDate; // 추가된 필드

    public Evaluation() {
        this.features = new ArrayList<>();
    }

    public Evaluation(int id, int courseId, int userId, String userName, String courseName, String professor,
                      int rating, int difficulty, int homework, String courseType,
                      List<String> features, String comment, Timestamp date, Timestamp updatedAt) {
        this.id = id;
        this.courseId = courseId;
        this.userId = userId;
        this.userName = userName;
        this.courseName = courseName;
        this.professor = professor;
        this.rating = rating;
        this.difficulty = difficulty;
        this.homework = homework;
        this.courseType = courseType;
        this.features = features;
        this.comment = comment;
        this.date = date;
        this.updatedAt = updatedAt;

        // 날짜 포맷팅
        if (date != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            this.formattedDate = sdf.format(date);
        }
    }

    // 평가 작성용 생성자
    public Evaluation(int courseId, int userId, int rating, int difficulty,
                      int homework, String courseType, String comment) {
        this.courseId = courseId;
        this.userId = userId;
        this.rating = rating;
        this.difficulty = difficulty;
        this.homework = homework;
        this.courseType = courseType;
        this.comment = comment;
        this.features = new ArrayList<>();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public String getProfessor() {
        return professor;
    }

    public void setProfessor(String professor) {
        this.professor = professor;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public int getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(int difficulty) {
        this.difficulty = difficulty;
    }

    public int getHomework() {
        return homework;
    }

    public void setHomework(int homework) {
        this.homework = homework;
    }

    public String getCourseType() {
        return courseType;
    }

    public void setCourseType(String courseType) {
        this.courseType = courseType;
    }

    public List<String> getFeatures() {
        return features;
    }

    public void setFeatures(List<String> features) {
        this.features = features;
    }

    public void addFeature(String feature) {
        if (this.features == null) {
            this.features = new ArrayList<>();
        }
        this.features.add(feature);
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Timestamp getDate() {
        return date;
    }

    public void setDate(Timestamp date) {
        this.date = date;
        // 날짜가 설정될 때 formattedDate도 업데이트
        if (date != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            this.formattedDate = sdf.format(date);
        }
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getAuthorInitial() {
        return authorInitial;
    }

    public void setAuthorInitial(String authorInitial) {
        this.authorInitial = authorInitial;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }

    public String getSemester() {
        return semester;
    }

    public void setSemester(String semester) {
        this.semester = semester;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getGrading() {
        return grading;
    }

    public void setGrading(int grading) {
        this.grading = grading;
    }

    public boolean isLiked() {
        return liked;
    }

    public void setLiked(boolean liked) {
        this.liked = liked;
    }

    public boolean isReported() {
        return reported;
    }

    public void setReported(boolean reported) {
        this.reported = reported;
    }

    public int getLikes() {
        return likes;
    }

    public void setLikes(int likes) {
        this.likes = likes;
    }

    // formattedDate 게터 추가
    public String getFormattedDate() {
        if (formattedDate == null && date != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            formattedDate = sdf.format(date);
        }
        return formattedDate;
    }

    // formattedDate 세터 추가
    public void setFormattedDate(String formattedDate) {
        this.formattedDate = formattedDate;
    }

    @Override
    public String toString() {
        return "Evaluation{" +
                "id='" + id + '\'' +
                ", courseId='" + courseId + '\'' +
                ", userId='" + userId + '\'' +
                ", rating=" + rating +
                ", difficulty=" + difficulty +
                ", homework=" + homework +
                ", courseType='" + courseType + '\'' +
                ", comment='" + comment + '\'' +
                '}';
    }
}
