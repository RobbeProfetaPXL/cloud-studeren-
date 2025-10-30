#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

exec > >(tee -a /var/log/user-data.log)
exec 2>&1
echo "=== Starting frontend deployment at $(date) ==="

# Install Docker
apt-get update -y
apt-get install -y docker.io git
systemctl enable --now docker
usermod -aG docker ubuntu

# Clone repository
echo "Cloning repository..."
rm -rf /opt/app
git clone --depth=1 https://github.com/RobbeProfetaPXL/todoapp-clouddeploy-RobbeProfetaPXL.git/opt/app

# Build frontend with PUBLIC backend URL
echo "Building frontend with API URL: http://${backend_ip}:8080"
cd /opt/app/frontend
docker build --build-arg APIURL=http://${backend_ip}:8080 -t frontend:latest .
docker run -d --name frontend --restart=unless-stopped -p 80:80 frontend:latest

echo "Frontend is running on port 80"
echo "Frontend configured to connect to: http://${backend_ip}:8080"
echo "=== Frontend deployment completed at $(date) ==="