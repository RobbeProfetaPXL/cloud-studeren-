#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

exec > >(tee -a /var/log/user-data.log)
exec 2>&1
echo "=== Starting frontend deployment at $(date) ==="

# Install Docker
apt-get update -y
apt-get install -y docker.io
systemctl enable --now docker
usermod -aG docker ubuntu

# Build frontend with PUBLIC backend URL
docker pull robbeprofeta/todo-frontend:latest
docker build --build-arg APIURL=http://${backend_ip}:8080 -t robbeprofeta/todo-frontend:latest .
docker run -d --name frontend --restart=unless-stopped -p 80:80 robbeprofeta/todo-frontend:latest

echo "Frontend is running on port 80"
echo "Frontend configured to connect to: http://${backend_ip}:8080"
echo "=== Frontend deployment completed at $(date) ==="