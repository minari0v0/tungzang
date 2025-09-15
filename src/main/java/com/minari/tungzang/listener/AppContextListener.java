package com.minari.tungzang.listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebListener
public class AppContextListener implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(AppContextListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("🔍 텅장수강러 애플리케이션이 시작되었습니다.");

        // 🔍 앱 시작 시 등급 관련 작업이 있는지 확인
        LOGGER.info("🔍 AppContextListener.contextInitialized() 시작");
        LOGGER.info("🔍 등급 업데이트 관련 코드 실행 여부 확인 중...");

        // ⚠️ 여기서 등급 관련 초기화 코드가 있다면 주석처리하고 로그 추가
        // 예를 들어, 다음과 같은 코드가 있을 수 있음:
        // - UserDAO userDAO = new UserDAO();
        // - userDAO.recalculateAllUserGrades();
        // - userDAO.updateAllAdminGrades();
        // - BadgeService.updateAllUserGrades();

        try {
            // 🔍 혹시 숨어있는 등급 업데이트 코드가 있는지 확인
            // 만약 아래와 같은 코드가 있다면 주석처리:

            // UserDAO userDAO = new UserDAO();
            // LOGGER.info("🚨 발견! AppContextListener에서 UserDAO 생성");
            // userDAO.recalculateAllUserGrades();
            // LOGGER.info("🚨 발견! AppContextListener에서 recalculateAllUserGrades 호출");

            LOGGER.info("🔍 AppContextListener에서 등급 관련 코드 실행 없음 - 정상");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "🚨 AppContextListener 초기화 중 오류 발생", e);
        }

        LOGGER.info("🔍 AppContextListener.contextInitialized() 완료");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("🔍 텅장수강러 애플리케이션 종료 시작");

        // MySQL JDBC 드라이버 정리
        try {
            // AbandonedConnectionCleanupThread 종료
            AbandonedConnectionCleanupThread.checkedShutdown();

            // 등록된 JDBC 드라이버들 해제
            Enumeration<Driver> drivers = DriverManager.getDrivers();
            while (drivers.hasMoreElements()) {
                Driver driver = drivers.nextElement();
                try {
                    DriverManager.deregisterDriver(driver);
                    LOGGER.info("JDBC 드라이버 해제: " + driver);
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "JDBC 드라이버 해제 실패: " + e.getMessage(), e);
                }
            }

            LOGGER.info("MySQL 정리 작업 완료");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "MySQL 정리 중 오류: " + e.getMessage(), e);
        }

        LOGGER.info("🔍 텅장수강러 애플리케이션이 종료되었습니다.");
    }
}
