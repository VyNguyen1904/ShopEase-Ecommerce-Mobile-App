FROM eclipse-temurin:21-jre
WORKDIR /app
COPY authentication-service/target/authentication-service-0.1.0.jar app.jar
EXPOSE 8088
ENTRYPOINT ["java", "-jar", "app.jar"]
ENV JAVA_TOOL_OPTIONS="-Xms128m -Xmx256m -XX:+UseSerialGC"
