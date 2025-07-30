#!/bin/bash
# Local deployment script

set -e

echo "🐙 Starting Octopus Local Deployment..."

# Check prerequisites
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed."
    exit 1
fi

# Start the platform
docker-compose up -d --build

echo "⏳ Waiting for services to start..."
sleep 30

# Health checks
echo "🔍 Performing health checks..."
curl -f http://localhost:8080/health || echo "⚠️ Brain not ready yet"

echo "✅ Octopus Platform deployed locally!"
echo "🌊 Access Points:"
echo "  🧠 Brain API: http://localhost:8080"
echo "  🖥️ Dashboard: http://localhost:3000"
echo "  📊 Prometheus: http://localhost:9090"
echo "  📈 Grafana: http://localhost:3001"
