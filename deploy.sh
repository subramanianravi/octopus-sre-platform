echo "🚀 Deploying Octopus platform..."

# Deploy in stages for proper startup order
echo "Starting infrastructure services..."
docker-compose up -d redis

echo "Starting brain..."
docker-compose up -d octopus-brain

echo "Waiting for brain to be ready..."
sleep 15

echo "Starting tentacles..."
docker-compose up -d detection-tentacles response-tentacles learning-tentacles security-tentacles

echo "Starting dashboard and monitoring..."
docker-compose up -d octopus-dashboard prometheus grafana jaeger

echo "✅ Platform deployment complete"
