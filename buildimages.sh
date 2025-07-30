echo "🐳 Building Docker images in correct order..."

# 1. Build Brain first (core coordinator)
echo "🧠 Building Brain image..."
make build-brain

# 2. Build Tentacles (depend on brain)
echo "🐙 Building Tentacle images..."
make build-tentacles

# 3. Build Dashboard (frontend)
echo "🖥️ Building Dashboard image..."
make build-dashboard

# 4. Build monitoring (infrastructure)
echo "📊 Pulling monitoring images..."
docker-compose pull prometheus grafana jaeger

echo "✅ All images built successfully"
