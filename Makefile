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
