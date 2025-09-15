package com.minari.tungzang.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.minari.tungzang.model.User;
import com.minari.tungzang.util.DatabaseUtil;
import com.minari.tungzang.util.PasswordUtil;

public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public User getUserById(int userId) {
        User user = null;
        String sql = "SELECT * FROM users WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 조회 중 오류 발생: ID=" + userId, e);
        }

        return user;
    }

    public User getUserByUsername(String username) {
        User user = null;
        String sql = "SELECT * FROM users WHERE username = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = mapResultSetToUser(rs);
                    LOGGER.info("🔍 getUserByUsername 성공: " + username + ", 등급: " + user.getGrade());
                } else {
                    LOGGER.warning("🔍 getUserByUsername 실패: 사용자를 찾을 수 없음 - " + username);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자명으로 조회 중 오류 발생: " + username, e);
        }

        return user;
    }

    public User authenticate(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password");

                    if (PasswordUtil.verifyPassword(password, storedHash)) {
                        User user = mapResultSetToUser(rs);
                        LOGGER.info("사용자 인증 성공: ID=" + user.getId() + ", 이름=" + user.getName() + ", 등급: " + user.getGrade());
                        return user;
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 인증 중 오류 발생: " + username, e);
        }

        return null;
    }

    public boolean registerUser(User user, String password) {
        LOGGER.info("🔍 회원가입 시작: " + user.getUsername());

        // 🔍 새 사용자는 무조건 '새내기'로 시작
        String sql = "INSERT INTO users (username, name, email, department, student_id, password, created_at, updated_at, is_admin, grade) " +
                "VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW(), false, '새내기')";

        String hashedPassword = PasswordUtil.hashPassword(password);

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getName());
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getDepartment());
            pstmt.setString(5, user.getStudentId());
            pstmt.setString(6, hashedPassword);

            LOGGER.info("🔍 새 사용자 INSERT - 등급을 '새내기'로 고정 설정");
            int rowsAffected = pstmt.executeUpdate();

            if (rowsAffected > 0) {
                User registeredUser = getUserByUsername(user.getUsername());
                if (registeredUser != null) {
                    user.setId(registeredUser.getId());
                    LOGGER.info("✅ 새 사용자 등록 완료: ID=" + user.getId() + ", 등급=" + registeredUser.getGrade());

                    // ⚠️ 새 사용자는 등급 업데이트 호출하지 않음!
                    // updateUserGrade(user.getId()); // 새 사용자는 호출 안함!
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 등록 중 오류 발생", e);
        }

        return false;
    }

    public boolean updateUser(User user) {
        String sql = "UPDATE users SET name = ?, email = ?, department = ?, updated_at = NOW() WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, user.getName());
            pstmt.setString(2, user.getEmail());
            pstmt.setString(3, user.getDepartment());
            pstmt.setInt(4, user.getId());

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 정보 업데이트 중 오류 발생: ID=" + user.getId(), e);
            return false;
        }
    }

    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password = ?, updated_at = NOW() WHERE id = ?";

        String hashedPassword = PasswordUtil.hashPassword(newPassword);

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, hashedPassword);
            pstmt.setInt(2, userId);

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "비밀번호 업데이트 중 오류 발생: ID=" + userId, e);
            return false;
        }
    }

    public boolean verifyPassword(int userId, String password) {
        String sql = "SELECT password FROM users WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password");
                    return PasswordUtil.verifyPassword(password, storedHash);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "비밀번호 검증 중 오류 발생: ID=" + userId, e);
        }

        return false;
    }

    public boolean isUsernameTaken(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자명 중복 확인 중 오류 발생", e);
        }

        return false;
    }

    public boolean isEmailTaken(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "이메일 중복 확인 중 오류 발생", e);
        }

        return false;
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setName(rs.getString("name"));
        user.setEmail(rs.getString("email"));
        user.setDepartment(rs.getString("department"));
        user.setStudentId(rs.getString("student_id"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        user.setAdmin(rs.getBoolean("is_admin"));
        user.setPassword(rs.getString("password"));

        // grade 컬럼이 있으면 가져오기
        try {
            String grade = rs.getString("grade");
            user.setGrade(grade != null ? grade : "새내기");
        } catch (SQLException e) {
            // grade 컬럼이 없는 경우 기본값 설정
            user.setGrade("새내기");
        }

        return user;
    }

    public User getUserByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "이메일로 사용자 조회 중 오류 발생: " + email, e);
        }
        return null;
    }

    public boolean addUser(User user) {
        String sql = "INSERT INTO users (username, name, email, department, student_id, password, created_at, updated_at, is_admin, grade) " +
                "VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW(), ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getName());
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getDepartment());
            pstmt.setString(5, user.getStudentId());
            pstmt.setString(6, user.getPassword());
            pstmt.setBoolean(7, user.isAdmin());
            pstmt.setString(8, user.isAdmin() ? "마스터" : "새내기");

            int rowsAffected = pstmt.executeUpdate();

            if (rowsAffected > 0) {
                User addedUser = getUserByUsername(user.getUsername());
                if (addedUser != null) {
                    user.setId(addedUser.getId());
                    LOGGER.info("사용자 추가 성공: ID=" + user.getId() + ", 이름=" + user.getName() + ", 등급=" + addedUser.getGrade());
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 추가 중 오류 발생", e);
        }
        return false;
    }

    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 삭제 중 오류 발생: ID=" + userId, e);
            return false;
        }
    }

    public boolean userExists(int userId) {
        String sql = "SELECT COUNT(*) FROM users WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 존재 확인 중 오류 발생: ID=" + userId, e);
        }
        return false;
    }

    public int getUserCount() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "전체 사용자 수 조회 중 오류 발생", e);
        }
        return 0;
    }

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "모든 사용자 목록 조회 중 오류 발생", e);
        }

        return users;
    }

    // ✅ 기존 사용자 등급 업데이트 메서드 (새 사용자 제외)
    public boolean updateUserGrade(int userId) {
        LOGGER.info("🔍 updateUserGrade 호출됨: ID=" + userId);

        // 🔍 사용자가 새로 가입한 사용자인지 확인 (가입 후 1분 이내)
        if (isNewUser(userId)) {
            LOGGER.info("🔍 새 사용자이므로 등급 업데이트 건너뜀: ID=" + userId);
            return true; // 새 사용자는 등급 업데이트 안함
        }

        String sql = "CALL UpdateUserGrade(?)";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.executeUpdate();

            LOGGER.info("✅ 기존 사용자 등급 업데이트 완료: ID=" + userId);
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "사용자 등급 업데이트 중 오류 발생: ID=" + userId, e);
            return false;
        }
    }

    // 🔍 새 사용자인지 확인 (가입 후 1분 이내)
    private boolean isNewUser(int userId) {
        String sql = "SELECT TIMESTAMPDIFF(MINUTE, created_at, NOW()) as minutes_since_created FROM users WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int minutesSinceCreated = rs.getInt("minutes_since_created");
                    return minutesSinceCreated <= 1; // 1분 이내면 새 사용자
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "새 사용자 확인 중 오류 발생: ID=" + userId, e);
        }
        return false;
    }

    // ✅ 강제 등급 업데이트 (관리자용)
    public boolean forceUpdateUserGrade(int userId) {
        LOGGER.info("🔍 강제 등급 업데이트 호출됨: ID=" + userId);
        String sql = "CALL UpdateUserGrade(?)";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.executeUpdate();

            LOGGER.info("✅ 강제 등급 업데이트 완료: ID=" + userId);
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "강제 등급 업데이트 중 오류 발생: ID=" + userId, e);
            return false;
        }
    }

    public boolean setAdminGrade(int userId) {
        String sql = "UPDATE users SET grade = '마스터' WHERE id = ? AND is_admin = TRUE";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            int rowsAffected = pstmt.executeUpdate();

            if (rowsAffected > 0) {
                LOGGER.info("관리자 등급 설정 완료: ID=" + userId);
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "관리자 등급 설정 중 오류 발생: ID=" + userId, e);
        }
        return false;
    }

    public boolean updateAllAdminGrades() {
        String sql = "UPDATE users SET grade = '마스터' WHERE is_admin = TRUE";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int rowsAffected = pstmt.executeUpdate();
            LOGGER.info("모든 관리자 등급 업데이트 완료: " + rowsAffected + "명");
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "관리자 등급 일괄 업데이트 중 오류 발생", e);
        }
        return false;
    }

    // ✅ 기존 사용자들의 등급 재계산 (새 사용자 제외)
    public boolean recalculateAllUserGrades() {
        List<User> users = getAllUsers();
        int successCount = 0;

        for (User user : users) {
            if (user.isAdmin()) {
                if (setAdminGrade(user.getId())) {
                    successCount++;
                }
            } else if (!isNewUser(user.getId())) { // 새 사용자가 아닌 경우만
                if (updateUserGrade(user.getId())) {
                    successCount++;
                }
            } else {
                LOGGER.info("🔍 새 사용자 건너뜀: ID=" + user.getId());
                successCount++; // 새 사용자도 성공으로 카운트
            }
        }

        LOGGER.info("모든 사용자 등급 재계산 완료: " + successCount + "/" + users.size() + "명");
        return successCount == users.size();
    }
}
