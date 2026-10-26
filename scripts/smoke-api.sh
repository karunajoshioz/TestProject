#!/usr/bin/env bash
# Smoke-test the customers REST API.
#
# Usage:
#   ./scripts/smoke-api.sh                         # defaults to http://localhost:8080
#   BASE_URL=http://20.x.x.x ./scripts/smoke-api.sh
#   ./scripts/smoke-api.sh http://localhost:8081   # docker-compose mapped port
#
# Get BASE_URL from AKS (dev LoadBalancer):
#   kubectl -n app-dev get svc customers -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# Or port-forward:
#   kubectl -n app-dev port-forward svc/customers 8080:80
#   BASE_URL=http://localhost:8080 ./scripts/smoke-api.sh
set -euo pipefail

BASE_URL="${1:-${BASE_URL:-http://localhost:8080}}"
BASE_URL="${BASE_URL%/}"

echo "Using BASE_URL=${BASE_URL}"
echo

json() { python3 -c 'import json,sys; print(json.dumps(json.load(sys.stdin), indent=2))' 2>/dev/null || cat; }

echo "=== GET /actuator/health/liveness ==="
curl -fsS "${BASE_URL}/actuator/health/liveness" | json
echo

echo "=== GET /actuator/health/readiness ==="
curl -fsS "${BASE_URL}/actuator/health/readiness" | json
echo

echo "=== GET /api/v1/customers/hello ==="
curl -fsS "${BASE_URL}/api/v1/customers/hello"
echo
echo

UNIQUE=$(date +%s)
EMAIL="smoke.${UNIQUE}@example.com"

echo "=== POST /api/v1/customers ==="
CREATE=$(curl -fsS -X POST "${BASE_URL}/api/v1/customers" \
  -H 'Content-Type: application/json' \
  -d "{\"name\":\"Smoke Test\",\"email\":\"${EMAIL}\"}")
echo "$CREATE" | json
ID=$(python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])' <<<"$CREATE")
echo "Created id=${ID}"
echo

echo "=== GET /api/v1/customers/${ID} ==="
curl -fsS "${BASE_URL}/api/v1/customers/${ID}" | json
echo

echo "=== GET /api/v1/customers ==="
curl -fsS "${BASE_URL}/api/v1/customers" | json
echo

echo "=== PUT /api/v1/customers/${ID} ==="
curl -fsS -X PUT "${BASE_URL}/api/v1/customers/${ID}" \
  -H 'Content-Type: application/json' \
  -d "{\"name\":\"Smoke Updated\",\"email\":\"${EMAIL}\"}" | json
echo

echo "=== DELETE /api/v1/customers/${ID} ==="
CODE=$(curl -sS -o /dev/null -w '%{http_code}' -X DELETE "${BASE_URL}/api/v1/customers/${ID}")
echo "HTTP ${CODE} (expect 204)"
test "$CODE" = "204"

echo
echo "ALL SMOKE TESTS PASSED against ${BASE_URL}"
