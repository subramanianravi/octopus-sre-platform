#!/bin/bash
# Octopus Platform - Complete Cleanup & Fresh Deploy

set -e

echo "🧹 OCTOPUS PLATFORM CLEANUP & FRESH DEPLOY"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${CYAN}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Step 1: Complete Docker cleanup
print_status "🛑 Step 1: Stopping all Octopus containers..."

# Stop all containers forcefully
docker-compose down --remove-orphans || true
docker stop $(docker ps -q --filter "name=octopus") 2>/dev/null || true
docker stop $(docker ps -q --filter "name=prometheus") 2>/dev/null || true
docker stop $(docker ps -q --filter "name=grafana") 2>/dev/null || true
docker stop $(docker ps -q --filter "name=jaeger") 2>/dev/null || true
docker stop $(docker ps -q --filter "name=redis") 2>/dev/null || true
docker stop $(docker ps -q --filter "name=postgres") 2>/dev/null || true
docker stop $(docker ps -q --filter "name=qdrant") 2>/dev/null || true
docker stop $(docker ps -q --filter "name=kafka") 2>/dev/null || true

print_success "All containers stopped"

# Step 2: Remove containers
print_status "🗑️ Step 2: Removing containers..."

docker rm $(docker ps -aq --filter "name=octopus") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=prometheus") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=grafana") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=jaeger") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=redis") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=postgres") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=qdrant") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=kafka") 2>/dev/null || true

print_success "Containers removed"

# Step 3: Remove networks
print_status "🌐 Step 3: Cleaning up networks..."

# Remove project networks
docker network rm octopus-sre-platform_octopus_ocean 2>/dev/null || true
docker network rm octopus_ocean 2>/dev/null || true

# Clean up any dangling networks
docker network prune -f

print_success "Networks cleaned"

# Step 4: Remove volumes (optional - preserves data)
read -p "🗄️ Remove volumes (will delete all data)? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "🗑️ Step 4: Removing volumes..."
    docker volume rm $(docker volume ls -q --filter "name=octopus") 2>/dev/null || true
    docker volume prune -f
    print_success "Volumes removed"
else
    print_warning "Keeping existing volumes"
fi

# Step 5: Clean up images (optional)
read -p "🏗️ Remove and rebuild all images? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "🗑️ Step 5: Removing Octopus images..."
    docker rmi $(docker images -q --filter "reference=*octopus*") 2>/dev/null || true
    print_success "Images removed"
    REBUILD_IMAGES=true
else
    print_warning "Keeping existing images"
    REBUILD_IMAGES=false
fi

# Step 6: System cleanup
print_status "🧹 Step 6: Docker system cleanup..."
docker system prune -f
print_success "System cleaned"

echo ""
print_status "🚀 FRESH DEPLOYMENT STARTING..."
echo ""

# Step 7: Build images if requested
if [[ "$REBUILD_IMAGES" == "true" ]]; then
    print_status "🏗️ Step 7: Building fresh images..."
    docker-compose build --no-cache
    print_success "Images built"
fi

# Step 8: Create network first
print_status "🌐 Step 8: Creating network..."
docker network create octopus_ocean --driver bridge || true

# Step 9: Deploy in correct order
print_status "🚀 Step 9: Deploying platform in stages..."

# Stage 1: Infrastructure
print_status "📊 Starting infrastructure services..."
docker-compose up -d redis
sleep 5

# Stage 2: Brain (Core)
print_status "🧠 Starting Brain..."
docker-compose up -d octopus-brain
print_status "Waiting for brain to initialize..."
sleep 15

# Check brain health
print_status "🏥 Checking brain health..."
for i in {1..10}; do
    if curl -sf http://localhost:8080/health > /dev/null 2>&1; then
        print_success "Brain is healthy!"
        break
    else
        print_warning "Brain not ready yet, waiting... ($i/10)"
        sleep 3
    fi
done

# Stage 3: Tentacles
print_status "🐙 Starting tentacles..."
docker-compose up -d detection-tentacles response-tentacles learning-tentacles security-tentacles
sleep 10

# Stage 4: Dashboard and Monitoring
print_status "📊 Starting dashboard and monitoring..."
docker-compose up -d octopus-dashboard prometheus grafana jaeger
sleep 5

# Step 10: Verification
print_status "🔍 Step 10: Verifying deployment..."

echo ""
print_status "📊 DEPLOYMENT STATUS:"
echo ""

# Check container status
docker-compose ps

echo ""
print_status "🏥 HEALTH CHECKS:"

# Brain health
if curl -sf http://localhost:8080/health > /dev/null 2>&1; then
    print_success "Brain API (8080): Healthy"
else
    print_error "Brain API (8080): Not responding"
fi

# Dashboard health
if curl -sf http://localhost:3000 > /dev/null 2>&1; then
    print_success "Dashboard (3000): Healthy"
else
    print_error "Dashboard (3000): Not responding"
fi

# Prometheus health
if curl -sf http://localhost:9090 > /dev/null 2>&1; then
    print_success "Prometheus (9090): Healthy"
else
    print_error "Prometheus (9090): Not responding"
fi

# Grafana health
if curl -sf http://localhost:3001 > /dev/null 2>&1; then
    print_success "Grafana (3001): Healthy"
else
    print_error "Grafana (3001): Not responding"
fi

echo ""
print_status "🎉 DEPLOYMENT COMPLETE!"
echo ""
print_status "📊 ACCESS POINTS:"
echo "  🧠 Brain API:        http://localhost:8080"
echo "  🖥️ Dashboard:        http://localhost:3000"
echo "  📈 Prometheus:       http://localhost:9090"
echo "  📊 Grafana:          http://localhost:3001 (admin/octopus)"
echo "  🔍 Jaeger:           http://localhost:16686"
echo ""
print_status "🛠️ MANAGEMENT COMMANDS:"
echo "  make status    # Check platform status"
echo "  make logs      # View platform logs"
echo "  make test      # Run platform tests"
echo ""

# Test basic functionality
print_status "🧪 Running basic tests..."
if curl -s http://localhost:8080/tentacles/status > /dev/null; then
    print_success "Tentacle coordination working"
else
    print_warning "Tentacle coordination not ready yet"
fi

print_success "Fresh deployment completed successfully! 🐙"
