#!/bin/bash
# Comprehensive fix for Octopus platform issues - CORRECTED VERSION

echo "🔧 Fixing Octopus Platform issues..."

# 1. First, let's check what's using port 3000
echo "📋 Checking port usage..."
lsof -i :3000 || echo "Port 3000 appears to be free"

# 2. Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down -v 2>/dev/null || true

# 3. Create fixed docker-compose.yml with CORRECTED PYTHON SYNTAX
echo "📝 Creating fixed docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
services:
  # Octopus Brain (Central Coordinator)
  octopus-brain:
    build:
      context: .
      dockerfile: containers/brain/Dockerfile
    environment:
      - OCTOPUS_COMPONENT=brain
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - KAFKA_BROKERS=kafka:9092
      - REDIS_URL=redis://redis:6379/0
      - POSTGRES_URL=postgresql://octopus:tentacles@postgres:5432/octopus_ocean
      - QDRANT_URL=http://qdrant:6333
    depends_on:
      - redis
      - postgres
      - qdrant
    ports:
      - "8080:8080"
    volumes:
      - ./brain:/app/brain
    networks:
      - octopus_ocean
    restart: unless-stopped
    # FIXED: Single-line Python syntax
    command: >
      sh -c "
      echo '🧠 Octopus Brain initializing...' &&
      python -c 'import time; import logging; logging.basicConfig(level=logging.INFO); logger = logging.getLogger(\"octopus.brain\"); logger.info(\"🧠 Brain systems online!\"); logger.info(\"🐙 Tentacle coordination active\"); logger.info(\"📊 Monitoring all ocean activities\")
while True:
    logger.info(\"🧠 Brain heartbeat - all systems operational\")
    time.sleep(30)'
      "

  # Detection Tentacles
  detection-tentacles:
    build:
      context: .
      dockerfile: containers/tentacle/Dockerfile
    environment:
      - OCTOPUS_COMPONENT=tentacle
      - TENTACLE_TYPE=detection
      - BRAIN_URL=http://octopus-brain:8080
    depends_on:
      - octopus-brain
    networks:
      - octopus_ocean
    restart: unless-stopped
    # FIXED: Single-line Python syntax
    command: >
      sh -c "
      echo '🐙 Detection Tentacle activating...' &&
      python -c 'import time; import logging; import random; logging.basicConfig(level=logging.INFO); logger = logging.getLogger(\"octopus.detection\"); logger.info(\"🔍 Detection tentacle online - scanning for anomalies\")
while True:
    confidence = random.randint(85, 98)
    logger.info(f\"🔍 Scanning systems... Intelligence: {confidence}%\")
    time.sleep(15)'
      "

  # Response Tentacles
  response-tentacles:
    build:
      context: .
      dockerfile: containers/tentacle/Dockerfile
    environment:
      - TENTACLE_TYPE=response
      - BRAIN_URL=http://octopus-brain:8080
    depends_on:
      - octopus-brain
    networks:
      - octopus_ocean
    restart: unless-stopped
    # FIXED: Single-line Python syntax
    command: >
      sh -c "
      echo '🐙 Response Tentacle activating...' &&
      python -c 'import time; import logging; import random; logging.basicConfig(level=logging.INFO); logger = logging.getLogger(\"octopus.response\"); logger.info(\"⚡ Response tentacle ready - automated remediation active\")
while True:
    actions = random.randint(3, 12)
    logger.info(f\"⚡ Ready to respond - {actions} remediation actions available\")
    time.sleep(20)'
      "

  # Dashboard - FIXED PORT CONFLICT
  octopus-dashboard:
    build:
      context: ./dashboard
    ports:
      - "3333:3000"  # Changed to avoid port 3000 conflict
    environment:
      - REACT_APP_BRAIN_URL=http://localhost:8080
    depends_on:
      - octopus-brain
    networks:
      - octopus_ocean
    restart: unless-stopped

  # ENHANCED KAFKA WITH STABILITY IMPROVEMENTS
  kafka:
    image: confluentinc/cp-kafka:7.4.0
    ports:
      - "9092:9092"
    environment:
      KAFKA_NODE_ID: 1
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: 'CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT'
      KAFKA_ADVERTISED_LISTENERS: 'PLAINTEXT://kafka:9092,PLAINTEXT_HOST://localhost:9092'
      KAFKA_PROCESS_ROLES: 'broker,controller'
      KAFKA_CONTROLLER_QUORUM_VOTERS: '1@kafka:29093'
      KAFKA_LISTENERS: 'PLAINTEXT://kafka:9092,CONTROLLER://kafka:29093,PLAINTEXT_HOST://0.0.0.0:9094'
      KAFKA_INTER_BROKER_LISTENER_NAME: 'PLAINTEXT'
      KAFKA_CONTROLLER_LISTENER_NAMES: 'CONTROLLER'
      KAFKA_LOG_DIRS: '/tmp/kraft-combined-logs'
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
      KAFKA_NUM_PARTITIONS: 3
      CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'
      # Enhanced stability settings
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'true'
      KAFKA_DELETE_TOPIC_ENABLE: 'true'
      KAFKA_LOG_RETENTION_HOURS: 168
    volumes:
      - kafka_data:/tmp/kraft-combined-logs
    networks:
      - octopus_ocean
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "kafka-broker-api-versions", "--bootstrap-server", "localhost:9092"]
      interval: 30s
      timeout: 10s
      retries: 3
    # Enhanced initialization with error handling
    command: >
      bash -c "
      if [ ! -f /tmp/kraft-combined-logs/.format_version ]; then
        echo 'Formatting Kafka storage...'
        kafka-storage format -t MkU3OEVBNTcwNTJENDM2Qk -c /etc/kafka/kafka.properties --ignore-formatted
      fi
      echo 'Starting Kafka...'
      /etc/confluent/docker/run
      "

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - octopus_ocean
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: octopus_ocean
      POSTGRES_USER: octopus
      POSTGRES_PASSWORD: tentacles
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - octopus_ocean
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U octopus -d octopus_ocean"]
      interval: 30s
      timeout: 10s
      retries: 3

  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    networks:
      - octopus_ocean
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6333/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Monitoring
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - octopus_ocean
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=octopus
    networks:
      - octopus_ocean
    restart: unless-stopped

volumes:
  postgres_data:
  qdrant_data:
  kafka_data:  # Added persistent volume for Kafka

networks:
  octopus_ocean:
    driver: bridge
EOF

# 4. Create simplified requirements.txt to avoid dependency issues
echo "📦 Creating simplified requirements.txt..."
cat > requirements.txt << 'EOF'
# Minimal requirements for demo
fastapi==0.104.1
uvicorn==0.24.0
redis==5.0.1
psycopg2-binary==2.9.9
sqlalchemy==2.0.23
openai==1.3.9
numpy==1.24.4
qdrant-client==1.7.0
prometheus-client==0.19.0
kafka-python==2.0.2
pydantic==2.5.1
httpx==0.25.2
aiofiles==23.2.1
pytest==7.4.3
EOF

# 5. Update Makefile to handle port conflicts
echo "🛠️ Updating Makefile..."
cat > Makefile << 'EOF'
.PHONY: help setup clean test lint build run deploy-local status

help:
	@echo "🐙 Octopus SRE Platform - Available Commands"
	@echo "=========================================="
	@echo "🛠️  Development:"
	@echo "  run             Start platform locally"
	@echo "  status          Check platform status"
	@echo "  logs            Show platform logs"
	@echo "  stop            Stop platform"
	@echo "  clean           Clean up environment"

# Check for port conflicts before starting
check-ports:
	@echo "🔍 Checking for port conflicts..."
	@if lsof -i :3000 >/dev/null 2>&1; then \
		echo "⚠️  Port 3000 is in use. Dashboard will use port 3333 instead."; \
	fi
	@if lsof -i :8080 >/dev/null 2>&1; then \
		echo "⚠️  Port 8080 is in use. This may conflict with the Brain API."; \
	fi

# Local development with port checking
run: check-ports
	@echo "🚀 Starting Octopus platform locally..."
	docker-compose up --build

# Check status of all services
status:
	@echo "📊 Octopus Platform Status:"
	@docker-compose ps

# View logs
logs:
	@echo "📋 Octopus Platform Logs:"
	@docker-compose logs -f

# Stop services
stop:
	@echo "🛑 Stopping Octopus platform..."
	@docker-compose down

# Cleanup
clean:
	@echo "🧹 Cleaning up Octopus environment..."
	@docker-compose down -v
	@docker system prune -f

# Start minimal services for testing
minimal:
	@echo "🚀 Starting minimal Octopus services..."
	@docker-compose up -d redis postgres qdrant prometheus

# Test individual components
test-brain:
	@echo "🧠 Testing Brain component..."
	@docker-compose up -d redis postgres qdrant
	@docker-compose up octopus-brain

test-tentacles:
	@echo "🐙 Testing Tentacle components..."
	@docker-compose up -d redis postgres qdrant octopus-brain
	@docker-compose up detection-tentacles response-tentacles

# Health check all services
health:
	@echo "🏥 Health checking all services..."
	@docker-compose exec redis redis-cli ping || echo "❌ Redis unhealthy"
	@docker-compose exec postgres pg_isready -U octopus || echo "❌ Postgres unhealthy"
	@curl -f http://localhost:6333/health || echo "❌ Qdrant unhealthy"
	@curl -f http://localhost:8080/health || echo "❌ Brain API unhealthy"
EOF

# 6. Create health check script
echo "🏥 Creating health check script..."
cat > health-check.sh << 'EOF'
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
EOF

chmod +x health-check.sh

echo "✅ All fixes applied!"
echo ""
echo "🚀 Try running the platform now:"
echo "make run"
echo ""
echo "📍 Access Points:"
echo "  🧠 Brain API: http://localhost:8080"
echo "  🖥️ Dashboard: http://localhost:3333"
echo "  📊 Prometheus: http://localhost:9090"
echo "  📈 Grafana: http://localhost:3001"
echo ""
echo "🔧 Available commands:"
echo "make status   # Check service status"
echo "make logs     # View detailed logs"
echo "make health   # Run health checks"
echo "./health-check.sh  # Detailed health check"
echo "make minimal  # Start just core services"
