FROM eclipse-temurin:21-jre
WORKDIR /app
COPY search-service/target/search-service-0.1.0.jar app.jar
EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.jar"]
