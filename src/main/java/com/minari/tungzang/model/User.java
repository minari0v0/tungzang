package com.minari.tungzang.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class User {
    private int id;
    private String username;
    private String password;
    private String name;
    private String email;
    private String department;
    private String studentId;
    private boolean isAdmin;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    // v34에서 추가된 필드
    private Timestamp joinDate;
    private String bio;
    // 날짜 포맷팅을 위한 필드
    private String formattedCreatedAt;
    // 사용자 등급 필드 추가
    private String grade;

    public User() {
    }

    public User(int id, String username, String password, String name, String email, String department, String studentId, boolean isAdmin, Timestamp createdAt, Timestamp updatedAt, String grade) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.name = name;
        this.email = email;
        this.department = department;
        this.studentId = studentId;
        this.isAdmin = isAdmin;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.grade = grade;
        formatCreatedAt();
    }

    // 회원가입용 생성자
    public User(String username, String password, String name, String email, String department, String studentId) {
        this.username = username;
        this.password = password;
        this.name = name;
        this.email = email;
        this.department = department;
        this.studentId = studentId;
        this.isAdmin = false;
        this.grade = "새내기"; // 기본 등급 설정
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public boolean isAdmin() {
        return isAdmin;
    }

    // JSP EL에서 사용하기 위한 추가 getter
    public boolean getIsAdmin() {
        return isAdmin;
    }

    public void setAdmin(boolean admin) {
        isAdmin = admin;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
        formatCreatedAt();
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    // v34에서 추가된 getter/setter 메서드
    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public Timestamp getJoinDate() {
        return joinDate;
    }

    public void setJoinDate(Timestamp joinDate) {
        this.joinDate = joinDate;
    }

    // 날짜 포맷팅 관련 메서드
    public String getFormattedCreatedAt() {
        return formattedCreatedAt;
    }

    public void setFormattedCreatedAt(String formattedCreatedAt) {
        this.formattedCreatedAt = formattedCreatedAt;
    }

    private void formatCreatedAt() {
        if (this.createdAt != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            this.formattedCreatedAt = sdf.format(this.createdAt);
        }
    }

    // 등급 관련 getter/setter 메서드
    public String getGrade() {
        return grade;
    }

    public void setGrade(String grade) {
        this.grade = grade;
    }

    // 등급별 아이콘 반환 메서드
    public String getGradeIcon() {
        if (grade == null) return "👶";

        switch (grade) {
            case "마스터": return "👑";
            case "전문가": return "⭐";
            case "숙련자": return "🔥";
            case "초급자": return "📚";
            case "새내기":
            default: return "👶";
        }
    }

    // 등급별 색상 반환 메서드
    public String getGradeColor() {
        if (grade == null) return "#6b7280";

        switch (grade) {
            case "마스터": return "#8b5cf6";
            case "전문가": return "#f59e0b";
            case "숙련자": return "#ef4444";
            case "초급자": return "#3b82f6";
            case "새내기":
            default: return "#6b7280";
        }
    }

    // 등급이 특별 등급인지 확인 (전문가, 마스터)
    public boolean isSpecialGrade() {
        return "전문가".equals(grade) || "마스터".equals(grade);
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", department='" + department + '\'' +
                ", studentId='" + studentId + '\'' +
                ", isAdmin=" + isAdmin +
                ", grade='" + grade + '\'' +
                '}';
    }
}
