package com.minari.tungzang.service;

import com.minari.tungzang.dao.UserDAO;
import com.minari.tungzang.model.User;
import com.minari.tungzang.util.PasswordUtil;

import java.sql.SQLException;

public class UserService {
    private UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    public User login(String username, String password) throws SQLException {
        User user = userDAO.getUserByUsername(username);

        if (user != null && PasswordUtil.verifyPassword(password, user.getPassword())) {
            // 비밀번호는 세션에 저장하지 않기 위해 null로 설정
            user.setPassword(null);
            return user;
        }

        return null;
    }

    public boolean register(User user) throws SQLException {
        // 사용자명 중복 확인
        if (userDAO.getUserByUsername(user.getUsername()) != null) {
            return false;
        }

        // 이메일 중복 확인
        if (userDAO.getUserByEmail(user.getEmail()) != null) {
            return false;
        }

        // 비밀번호 해싱
        String hashedPassword = PasswordUtil.hashPassword(user.getPassword());
        user.setPassword(hashedPassword);

        return userDAO.addUser(user);
    }

    public User getUserById(int userId) throws SQLException {
        User user = userDAO.getUserById(userId);
        if (user != null) {
            // 비밀번호는 반환하지 않음
            user.setPassword(null);
        }
        return user;
    }

    public boolean updateUser(User user) throws SQLException {
        // 현재 사용자 정보 가져오기
        User currentUser = userDAO.getUserById(user.getId());
        if (currentUser == null) {
            return false;
        }

        // 사용자명 변경 시 중복 확인
        if (!currentUser.getUsername().equals(user.getUsername()) &&
                userDAO.getUserByUsername(user.getUsername()) != null) {
            return false;
        }

        // 이메일 변경 시 중복 확인
        if (!currentUser.getEmail().equals(user.getEmail()) &&
                userDAO.getUserByEmail(user.getEmail()) != null) {
            return false;
        }

        return userDAO.updateUser(user);
    }

    public boolean updatePassword(int userId, String currentPassword, String newPassword) throws SQLException {
        User user = userDAO.getUserById(userId);
        if (user == null) {
            return false;
        }

        // 현재 비밀번호 확인
        if (!PasswordUtil.verifyPassword(currentPassword, user.getPassword())) {
            return false;
        }

        // 평문 비밀번호를 DAO에 전달 (DAO에서 해싱)
        return userDAO.updatePassword(userId, newPassword);
    }

    public boolean deleteUser(int userId) throws SQLException {
        return userDAO.deleteUser(userId);
    }

    public User getUser(int userId) {
        return userDAO.getUserById(userId);
    }
}