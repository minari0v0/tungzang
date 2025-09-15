package com.minari.tungzang.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class Post {
    private int id;
    private String title;
    private String content;
    private String category;
    private int authorId;
    private int likes;
    private int commentCount;
    private int views;
    private boolean isHot;
    private boolean isReported; // 신고 여부 필드 추가
    private Timestamp date;
    private Timestamp updatedAt;

    // 추가 필드 (조인 시 사용)
    private String authorName;
    private String authorUsername;

    public Post() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public int getAuthorId() {
        return authorId;
    }

    public void setAuthorId(int authorId) {
        this.authorId = authorId;
    }

    public int getLikes() {
        return likes;
    }

    public void setLikes(int likes) {
        this.likes = likes;
    }

    public int getCommentCount() {
        return commentCount;
    }

    public void setCommentCount(int commentCount) {
        this.commentCount = commentCount;
    }

    public int getViews() {
        return views;
    }

    public void setViews(int views) {
        this.views = views;
    }

    // viewCount 속성 추가 (views 필드와 매핑)
    public int getViewCount() {
        return views;
    }

    public void setViewCount(int viewCount) {
        this.views = viewCount;
    }

    public boolean isHot() {
        return isHot;
    }

    public void setHot(boolean hot) {
        isHot = hot;
    }

    // 신고 여부 getter/setter 추가
    public boolean isReported() {
        return isReported;
    }

    public void setReported(boolean reported) {
        isReported = reported;
    }

    public Timestamp getDate() {
        return date;
    }

    public void setDate(Timestamp date) {
        this.date = date;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }

    public String getAuthorUsername() {
        return authorUsername;
    }

    public void setAuthorUsername(String authorUsername) {
        this.authorUsername = authorUsername;
    }

    public int getUserId() {
        return authorId;
    }

    public String getFormattedDate() {
        if (date == null) {
            return "";
        }
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(date);
    }

    @Override
    public String toString() {
        return "Post{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", category='" + category + '\'' +
                ", authorId=" + authorId +
                ", likes=" + likes +
                ", commentCount=" + commentCount +
                ", views=" + views +
                ", isHot=" + isHot +
                ", isReported=" + isReported +
                ", date=" + date +
                '}';
    }
}
