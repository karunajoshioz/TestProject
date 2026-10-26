# =============================================================================
# Multi-stage Dockerfile for Spring Boot 4.1+ on Azure Kubernetes Service (AKS)
# Uses jarmode=tools (layertools was removed in Boot 4.1).
# =============================================================================

# ----- Build stage -----
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /workspace

# Copy Gradle wrapper and build files first for better layer caching
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./
RUN chmod +x gradlew

# Download dependencies (cached unless build files change)
RUN ./gradlew dependencies --no-daemon || true

# Copy source and build the layered bootJar
COPY src src
RUN ./gradlew bootJar --no-daemon -x test

# Extract layers with Spring Boot 4.1+ tools jarmode (exclude *-plain.jar).
# Rename to application.jar so the extracted application layer has a stable name.
RUN JAR="$(ls build/libs/*.jar | grep -v 'plain' | head -n 1)" \
    && cp "${JAR}" application.jar \
    && java -Djarmode=tools -jar application.jar extract --layers --destination /extracted

# ----- Runtime stage -----
FROM eclipse-temurin:21-jre-jammy AS runtime

# curl used by Docker HEALTHCHECK (K8s still uses Actuator probes)
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid app app
WORKDIR /app

# Copy layers in order of least → most frequently changing
COPY --from=build --chown=10001:10001 /extracted/dependencies/ ./
COPY --from=build --chown=10001:10001 /extracted/spring-boot-loader/ ./
COPY --from=build --chown=10001:10001 /extracted/snapshot-dependencies/ ./
COPY --from=build --chown=10001:10001 /extracted/application/ ./

# Numeric UID required for Kubernetes runAsNonRoot
USER 10001

EXPOSE 8080

# JVM flags tuned for containers (use container memory limits)
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"
# Profile is set per environment by AKS ConfigMap (dev | sit | prod); default for local docker compose
ENV SPRING_PROFILES_ACTIVE=local

# K8s uses Actuator probes; Docker HEALTHCHECK is a local convenience
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8080/actuator/health/liveness >/dev/null || exit 1

# Boot 4.1 tools extract layout: run the thin application.jar from the application layer
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar application.jar"]
