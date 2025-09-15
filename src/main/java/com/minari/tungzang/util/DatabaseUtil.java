package com.minari.tungzang.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseUtil {
    private static final String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";

    // 환경 변수에서 DB 정보 가져오기
    private static final String DB_HOST = System.getenv("DB_HOST") != null ? System.getenv("DB_HOST") : "localhost";
    private static final String DB_NAME = System.getenv("DB_NAME") != null ? System.getenv("DB_NAME") : "tungzang";
    private static final String DB_USER = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root";
    private static final String DB_PASSWORD = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "1234";

    private static final String DB_URL = "jdbc:mysql://" + DB_HOST + "/" + DB_NAME + "?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8";

    static {
        try {
            Class.forName(JDBC_DRIVER);
            System.out.println("DEBUG: JDBC 드라이버 로드 성공: " + JDBC_DRIVER);
            System.out.println("DEBUG: 데이터베이스 연결 정보:");
            System.out.println("DEBUG: DB_HOST: " + DB_HOST);
            System.out.println("DEBUG: DB_NAME: " + DB_NAME);
            System.out.println("DEBUG: DB_USER: " + DB_USER);
            System.out.println("DEBUG: DB_URL: " + DB_URL);
        } catch (ClassNotFoundException e) {
            System.err.println("ERROR: JDBC 드라이버 로드 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("DEBUG: 데이터베이스 연결 성공");
            return conn;
        } catch (SQLException e) {
            System.err.println("ERROR: 데이터베이스 연결 실패: " + e.getMessage());
            System.err.println("SQL 상태: " + e.getSQLState());
            System.err.println("오류 코드: " + e.getErrorCode());
            e.printStackTrace();
            throw e;
        }
    }

    public static void close(AutoCloseable... resources) {
        for (AutoCloseable resource : resources) {
            if (resource != null) {
                try {
                    resource.close();
                    System.out.println("DEBUG: 리소스 닫기 성공");
                } catch (Exception e) {
                    System.err.println("ERROR: 리소스 닫기 실패: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }
    }
}
