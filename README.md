# 텅장수강러

💸 텅 빈 통장 속 한 줄기 빛, 대학생을 위한 스마트한 수강 생활 도우미 '텅장수강러'입니다.

'텅장수강러'는 대학생들의 성공적인 수강신청과 즐거운 학교생활을 돕기 위해 만들어진 웹 애플리케이션입니다. 시간표 관리, 강의 평가, 커뮤니티 등 다채로운 기능을 통해 더 나은 대학 생활을 경험해 보세요.

## ✨ 주요 기능

- **📅 스마트 시간표 관리**: 직관적인 드래그 앤 드롭 인터페이스로 시간표를 손쉽게 구성하고 수정할 수 있습니다. 복잡한 시간표, 이제는 깔끔하게 관리하며 최적의 동선을 계획해보세요.

- **⭐ 집단지성 강의 평가**: 별점, 과제량, 난이도 등 상세한 항목으로 강의를 평가하고 공유합니다. 수강신청 전, 선배들의 생생한 후기를 참고하여 후회 없는 선택을 할 수 있도록 돕습니다.

- **👨‍👩‍👧‍👦 활발한 커뮤니티**: 자유게시판, 정보 공유, 스터디 모집 등 다양한 목적의 소통 공간을 제공합니다. 학교 생활의 꿀팁부터 진지한 학업 고민까지 함께 나누어보세요.

- **🏆 활동 기반 랭킹 시스템**: 강의 평가, 게시글 작성 등 커뮤니티 활동에 따라 등급과 뱃지가 부여됩니다. 소소한 성취감을 느끼며 즐겁게 활동할 수 있습니다.

- **📊 관리자 대시보드**: 사용자, 콘텐츠, 활동 현황을 시각적인 차트로 제공하여 효율적인 사이트 관리를 지원합니다. (관리자에게만 노출되는 기능입니다.)

---

## 🛠️ 기술 스택

### Backend
- Java 8
- Servlet / JSP
- MySQL 8.0
- Maven

### Frontend
- HTML / CSS / JavaScript
- Bootstrap 5
- jQuery
- Chart.js

### ETC
- jbcrypt (비밀번호 암호화)
- Gson / Jackson (JSON 처리)
- Jsoup (웹 크롤링)

---

## 🚀 시작하기

### 1. 사전 요구사항

- JDK 1.8 이상
- Maven 3.6 이상
- MySQL 8.0 이상
- Apache Tomcat 9.0 이상 (또는 다른 서블릿 컨테이너)

### 2. 설치 및 실행

1. **프로젝트 클론**
   ```bash
   git clone https://github.com/your-username/tungzang.git
   ```

2. **데이터베이스 설정**
   - MySQL에 접속하여 `tungzang` 데이터베이스를 생성합니다.
     ```sql
     CREATE DATABASE tungzang CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
     ```
   - `src/main/resources/database.sql` 스크립트를 실행하여 테이블과 초기 데이터를 생성합니다.

3. **데이터베이스 연결 정보 수정**
   - `src/main/java/com/minari/tungzang/util/DatabaseUtil.java` 파일에서 본인의 DB 연결 정보를 수정해야 합니다. (실제 프로젝트에서는 설정 파일을 분리하는 것이 좋습니다.)

4. **프로젝트 빌드**
   - 프로젝트 루트 디렉토리에서 Maven을 사용하여 빌드합니다.
     ```bash
     mvn clean install
     ```

5. **서버에 배포**
   - 생성된 `target/tungzang.war` 파일을 Apache Tomcat의 `webapps` 디렉토리에 배포합니다.
   - Tomcat을 실행하고 `http://localhost:8080/tungzang` 에 접속합니다.

---

## 📁 프로젝트 구조

```
.
├── pom.xml
└── src
    ├── main
    │   ├── java/com/minari/tungzang
    │   │   ├── controller (서블릿 컨트롤러)
    │   │   ├── dao (데이터베이스 접근 객체)
    │   │   ├── model (데이터 모델)
    │   │   ├── service (비즈니스 로직)
    │   │   └── util (유틸리티 클래스)
    │   ├── resources
    │   │   └── database.sql (DB 스키마)
    │   └── webapp
    │       ├── WEB-INF
    │       │   └── views (JSP 뷰 파일)
    │       ├── resources (CSS, JS, 이미지)
    │       └── *.jsp (메인 페이지)
    └── test
```
