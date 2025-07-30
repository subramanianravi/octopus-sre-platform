#!/bin/bash
echo "🏥 Octopus Platform Health Check"
echo "================================"

check_service() {
    local service=$1
    local check_cmd=$2
    local port=$3
    
    echo -n "🔍 Checking $service... "
    if eval "$check_cmd" >/dev/null 2>&1; then
        echo "✅ Healthy"
        return 0
    else
        echo "❌ Unhealthy"
        return 1
    fi
}

# Check if containers are running
echo "📊 Container Status:"
docker-compose ps

echo ""
echo "🔍 Service Health Checks:"

# Check Redis
check_service "Redis" "docker-compose exec -T redis redis-cli ping" "6379"

# Check PostgreSQL
check_service "PostgreSQL" "docker-compose exec -T postgres pg_isready -U octopus" "5432"

# Check Qdrant
check_service "Qdrant" "curl -f http://localhost:6333/health" "6333"

# Check Kafka
check_service "Kafka" "docker-compose exec -T kafka kafka-broker-api-versions --bootstrap-server localhost:9092" "9092"

# Check Brain API
check_service "Brain API" "curl -f http://localhost:8080/health" "8080"

# Check Dashboard
check_service "Dashboard" "curl -f http://localhost:3333" "3333"

# Check Prometheus
check_service "Prometheus" "curl -f http://localhost:9090/-/healthy" "9090"

# Check Grafana
check_service "Grafana" "curl -f http://localhost:3001/api/health" "3001"

echo ""
echo "🐙 Octopus Platform Health Check Complete!"
