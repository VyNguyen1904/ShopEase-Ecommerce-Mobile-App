FROM eclipse-temurin:21-jre
WORKDIR /app
COPY cart-service/target/cart-service-0.1.0.jar app.jar
EXPOSE 8084
ENTRYPOINT ["java", "-jar", "app.jar"]
