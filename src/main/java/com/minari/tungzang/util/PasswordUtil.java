package com.minari.tungzang.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordUtil {

    private static final int SALT_LENGTH = 16;
    private static final int ITERATIONS = 10000;
    private static final String ALGORITHM = "SHA-256";

    public static String hashPassword(String password) {
        try {
            // 솔트 생성
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[SALT_LENGTH];
            random.nextBytes(salt);

            // 비밀번호 해싱
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            md.reset();
            md.update(salt);

            byte[] hash = md.digest(password.getBytes());

            // 추가 해싱 반복
            for (int i = 0; i < ITERATIONS; i++) {
                md.reset();
                hash = md.digest(hash);
            }

            // 솔트와 해시를 Base64로 인코딩하여 저장
            String saltBase64 = Base64.getEncoder().encodeToString(salt);
            String hashBase64 = Base64.getEncoder().encodeToString(hash);

            return saltBase64 + ":" + hashBase64;
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("비밀번호 해싱 중 오류가 발생했습니다.", e);
        }
    }

    public static boolean verifyPassword(String password, String storedHash) {
        try {
            // 저장된 솔트와 해시 분리
            String[] parts = storedHash.split(":");
            if (parts.length != 2) {
                return false;
            }

            byte[] salt = Base64.getDecoder().decode(parts[0]);
            byte[] hash = Base64.getDecoder().decode(parts[1]);

            // 입력된 비밀번호 해싱
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            md.reset();
            md.update(salt);

            byte[] inputHash = md.digest(password.getBytes());

            // 추가 해싱 반복
            for (int i = 0; i < ITERATIONS; i++) {
                md.reset();
                inputHash = md.digest(inputHash);
            }

            // 해시 비교
            int diff = hash.length ^ inputHash.length;
            for (int i = 0; i < hash.length && i < inputHash.length; i++) {
                diff |= hash[i] ^ inputHash[i];
            }

            return diff == 0;
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("비밀번호 검증 중 오류가 발생했습니다.", e);
        }
    }
}