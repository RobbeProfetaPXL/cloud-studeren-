#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

exec > >(tee -a /var/log/user-data.log)
exec 2>&1
echo "=== Starting backend deployment at $(date) ==="

# Install Docker and Git
apt-get update -y
apt-get install -y docker.io netcat-openbsd
systemctl enable --now docker
usermod -aG docker ubuntu

sleep 5

MONGO_URL="${mongo_url}"

DB_HOST="$(echo "$MONGO_URL" | sed -E 's#^mongodb://([^@]+@)?([^,/:]+).*#\2#')"
DB_PORT="$(echo "$MONGO_URL" | sed -nE 's#.*:([0-9]+).*#\1#p')"
DB_PORT="${DB_PORT:-27017}"
echo "Wachten op Mongo (${DB_HOST}:${DB_PORT})..."
for i in {1..40}; do
  if nc -z -w 2 "${DB_HOST}" "${DB_PORT}"; then 
    echo "Mongo is bereikbaar."
    break
  fi
  echo "Nog niet bereikbaar, retry $i..."
  sleep 3
done
# Build and run backend


docker pull robbeprofeta/todo-backend:latest
docker run -d --name backend --restart=unless-stopped -p 8080:3000 -e PORT=3000 -e MONGO_URL="$MONGO_URL" -e DB_URL="$MONGO_URL" robbeprofeta/todo-backend:latest