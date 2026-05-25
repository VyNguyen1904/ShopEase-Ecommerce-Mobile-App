FROM eclipse-temurin:21-jre
WORKDIR /app
COPY order-service/target/order-service-0.1.0.jar app.jar
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "app.jar"]
