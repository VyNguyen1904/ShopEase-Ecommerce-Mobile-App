FROM eclipse-temurin:21-jre
WORKDIR /app
COPY product-service/target/product-service-0.1.0.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
