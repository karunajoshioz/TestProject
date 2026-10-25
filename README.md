# Spring Boot PostgreSQL Docker Demo

Simple production-oriented starter using Java 21, Spring Boot, Gradle, PostgreSQL, Flyway, Actuator and Docker Compose.

## Run

```bash
cp .env.example .env
docker compose up --build
```

Health: `http://localhost:8080/actuator/health`

API: `http://localhost:8080/api/v1/customers`

Example:

```bash
curl -X POST http://localhost:8080/api/v1/customers \
  -H 'Content-Type: application/json' \
  -d '{"name":"Karuna Joshi","email":"karuna@example.com"}'
```

For real production deployments, inject database credentials from your platform secret manager rather than committing them to source control.
