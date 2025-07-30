# Octopus SRE Platform - Build & Deployment Makefile
.PHONY: help setup build deploy start stop restart status logs clean test

# Configuration
REGISTRY ?= octopus
VERSION ?= latest
ENVIRONMENT ?= development
COMPOSE_FILE ?= docker-compose.yml

# Colors
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
NC := \033[0m

help:
	@echo "$(CYAN)🐙 Octopus SRE Platform Commands$(NC)"
	@echo "$(CYAN)================================$(NC)"
	@echo ""
	@echo "$(GREEN)🚀 Quick Start:$(NC)"
	@echo "  make setup      Setup environment and dependencies"
	@echo "  make deploy     Build and deploy complete platform"
	@echo "  make start      Start platform (after build)"
	@echo ""
	@echo "$(GREEN)🛠️  Build Commands:$(NC)"
	@echo "  make build      Build all Docker images"
	@echo "  make build-brain        Build brain image only"
	@echo "  make build-tentacles    Build tentacle images only"
	@echo "  make build-dashboard    Build dashboard image only"
	@echo ""
	@echo "$(GREEN)📊 Management Commands:$(NC)"
	@echo "  make status     Show platform status"
	@echo "  make logs       View platform logs"
	@echo "  make health     Check service health"
	@echo "  make scale      Scale tentacles"
	@echo "  make test       Run tests"
	@echo ""
	@echo "$(GREEN)🧹 Maintenance Commands:$(NC)"
	@echo "  make clean      Clean up containers and volumes"
	@echo "  make reset      Full reset and rebuild"
	@echo "  make update     Update to latest images"

setup:
	@echo "$(CYAN)🛠️ Setting up Octopus environment...$(NC)"
	@if [ ! -f ".env" ]; then cp .env.example .env; echo "$(YELLOW)📝 Created .env - please add your API keys$(NC)"; fi
	@echo "$(GREEN)✅ Environment setup complete$(NC)"

build:
	@echo "$(CYAN)🐳 Building all Octopus images...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build --parallel
	@echo "$(GREEN)✅ All images built successfully$(NC)"

build-brain:
	@echo "$(CYAN)🧠 Building Brain image...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build octopus-brain
	@echo "$(GREEN)✅ Brain image built$(NC)"

build-tentacles:
	@echo "$(CYAN)🐙 Building Tentacle images...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build detection-tentacles response-tentacles learning-tentacles security-tentacles
	@echo "$(GREEN)✅ Tentacle images built$(NC)"

build-dashboard:
	@echo "$(CYAN)🖥️ Building Dashboard image...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build octopus-dashboard
	@echo "$(GREEN)✅ Dashboard image built$(NC)"

deploy: setup build start health
	@echo ""
	@echo "$(GREEN)🎉 Octopus platform deployed successfully!$(NC)"
	@echo ""
	@echo "$(GREEN)📊 Access Points:$(NC)"
	@echo "  🧠 Brain API:        http://localhost:8080"
	@echo "  🖥️ Dashboard:        http://localhost:3000"
	@echo "  📈 Prometheus:       http://localhost:9090"
	@echo "  📊 Grafana:          http://localhost:3001 (admin/octopus)"
	@echo "  🔍 Jaeger:           http://localhost:16686"
	@echo ""
	@echo "$(YELLOW)💡 Next Steps:$(NC)"
	@echo "  1. Check status:     make status"
	@echo "  2. View logs:        make logs"
	@echo "  3. Run tests:        make test"
	@echo "  4. Scale tentacles:  make scale"

start:
	@echo "$(CYAN)🚀 Starting Octopus platform...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d
	@sleep 5
	@echo "$(GREEN)✅ Platform started$(NC)"

stop:
	@echo "$(CYAN)🛑 Stopping Octopus platform...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✅ Platform stopped$(NC)"

restart:
	@echo "$(CYAN)🔄 Restarting Octopus platform...$(NC)"
	docker-compose -f $(COMPOSE_FILE) restart
	@sleep 5
	@make health
	@echo "$(GREEN)✅ Platform restarted$(NC)"

status:
	@echo "$(CYAN)📊 Octopus Platform Status$(NC)"
	@echo "$(CYAN)========================$(NC)"
	@docker-compose -f $(COMPOSE_FILE) ps
	@echo ""
	@echo "$(GREEN)🐙 Container Health:$(NC)"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep octopus || echo "No Octopus containers running"

logs:
	@echo "$(CYAN)📋 Octopus Platform Logs$(NC)"
	@echo "$(CYAN)========================$(NC)"
	docker-compose -f $(COMPOSE_FILE) logs -f --tail=50

health:
	@echo "$(CYAN)🏥 Health Check$(NC)"
	@echo "$(CYAN)===============$(NC)"
	@if curl -sf http://localhost:8080/health > /dev/null 2>&1; then \
		echo "$(GREEN)✅ Brain: Healthy$(NC)"; \
	else \
		echo "$(RED)❌ Brain: Unhealthy$(NC)"; \
	fi
	@if curl -sf http://localhost:3000 > /dev/null 2>&1; then \
		echo "$(GREEN)✅ Dashboard: Healthy$(NC)"; \
	else \
		echo "$(RED)❌ Dashboard: Unhealthy$(NC)"; \
	fi
	@if curl -sf http://localhost:9090 > /dev/null 2>&1; then \
		echo "$(GREEN)✅ Prometheus: Healthy$(NC)"; \
	else \
		echo "$(RED)❌ Prometheus: Unhealthy$(NC)"; \
	fi

scale:
	@echo "$(CYAN)📈 Scaling tentacles...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d --scale detection-tentacles=5 --scale response-tentacles=3
	@echo "$(GREEN)✅ Tentacles scaled$(NC)"

test:
	@echo "$(CYAN)🧪 Running platform tests...$(NC)"
	@echo "Testing brain health..."
	@curl -sf http://localhost:8080/health > /dev/null && echo "$(GREEN)✅ Brain health test passed$(NC)" || echo "$(RED)❌ Brain health test failed$(NC)"
	@echo "Testing tentacle registration..."
	@curl -sf http://localhost:8080/tentacles/status > /dev/null && echo "$(GREEN)✅ Tentacle registration test passed$(NC)" || echo "$(RED)❌ Tentacle registration test failed$(NC)"
	@echo "Testing incident submission..."
	@curl -X POST http://localhost:8080/incidents -H "Content-Type: application/json" -d '{"type":"test","severity":"low"}' > /dev/null 2>&1 && echo "$(GREEN)✅ Incident submission test passed$(NC)" || echo "$(RED)❌ Incident submission test failed$(NC)"

clean:
	@echo "$(CYAN)🧹 Cleaning up...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down -v --remove-orphans
	docker system prune -f
	@echo "$(GREEN)✅ Cleanup complete$(NC)"

reset: clean
	@echo "$(CYAN)🔄 Full reset...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build --no-cache
	@make deploy
	@echo "$(GREEN)✅ Reset complete$(NC)"

update:
	@echo "$(CYAN)🔄 Updating platform...$(NC)"
	docker-compose -f $(COMPOSE_FILE) pull
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✅ Platform updated$(NC)"
