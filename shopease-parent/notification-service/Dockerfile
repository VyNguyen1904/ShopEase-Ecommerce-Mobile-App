FROM eclipse-temurin:21-jre
WORKDIR /app
COPY notification-service/target/notification-service-0.1.0.jar app.jar
EXPOSE 8087
ENTRYPOINT ["java", "-jar", "app.jar"]
