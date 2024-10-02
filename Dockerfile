# 베이스 이미지로 OpenJDK 17을 사용합니다.
FROM openjdk:17

# 작업 디렉토리를 /app으로 설정합니다.
WORKDIR /app

# 호스트의 SpringApp-0.0.1-SNAPSHOT.jar 파일을 현재 Docker 이미지의 /app 디렉토리로 복사합니다.
COPY SpringApp-0.0.1-SNAPSHOT.jar /app

# Docker 컨테이너가 시작될 때 실행할 명령어를 지정합니다.
CMD ["java", "-jar", "SpringApp-0.0.1-SNAPSHOT.jar"]
