#!/usr/bin/env bash
# Restore drill — prove the nightly dump is actually restorable.
# Run from the repo root with a fresh backup.sql.gz (download from R2 or a local dump).
#
# Usage:
#   ./infrastructure/restore-drill.sh path/to/backup.sql.gz
#
# Requires: docker, gunzip, psql, pnpm. Uses port 5433 so it does not clash with local Postgres.

set -euo pipefail

BACKUP="${1:?Usage: $0 path/to/backup.sql.gz}"
if [[ ! -f "$BACKUP" ]]; then
  echo "Backup file not found: $BACKUP" >&2
  exit 1
fi

docker rm -f restore-test >/dev/null 2>&1 || true
docker run -d --name restore-test \
  -e POSTGRES_PASSWORD=test \
  -p 5433:5432 \
  postgis/postgis:16-3.4

echo "Waiting for Postgres on :5433..."
for _ in $(seq 1 30); do
  if docker exec restore-test pg_isready -U postgres >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

gunzip -c "$BACKUP" | PGPASSWORD=test psql -h localhost -p 5433 -U postgres -v ON_ERROR_STOP=1

echo "Running API e2e against the restored database..."
DATABASE_URL="postgresql://postgres:test@localhost:5433/postgres" \
  pnpm --filter api test:e2e

docker rm -f restore-test
echo "Restore drill passed."
