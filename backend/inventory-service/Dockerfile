FROM eclipse-temurin:21-jre
WORKDIR /app
COPY inventory-service/target/inventory-service-0.1.0.jar app.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "app.jar"]
ENV JAVA_TOOL_OPTIONS="-Xms128m -Xmx256m -XX:+UseSerialGC"
