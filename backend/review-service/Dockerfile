FROM eclipse-temurin:21-jre
WORKDIR /app
COPY review-service/target/review-service-0.1.0.jar app.jar
EXPOSE 8089
ENTRYPOINT ["java", "-jar", "app.jar"]
