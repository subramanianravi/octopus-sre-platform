.PHONY: help setup clean test lint build run deploy-local deploy-aws deploy-gcp

# Help target
help:
	@echo "🐙 Octopus SRE Platform - Available Commands"
	@echo "=========================================="
	@echo ""
	@echo "🛠️  Development:"
	@echo "  setup           Setup development environment"
	@echo "  run             Start platform locally"
	@echo "  test            Run all tests"
	@echo "  lint            Run code linting"
	@echo "  clean           Clean up environment"
	@echo ""
	@echo "☁️  Deployment:"
	@echo "  deploy-local    Deploy locally"
	@echo "  deploy-aws      Deploy to AWS EKS"
	@echo "  deploy-gcp      Deploy to GCP GKE"

# Development setup
setup:
	@echo "🛠️ Setting up Octopus development environment..."
	python3 -m venv venv
	./venv/bin/pip install --upgrade pip
	./venv/bin/pip install -r requirements.txt
	./venv/bin/pip install -r requirements-dev.txt
	@echo "✅ Setup complete!"

# Testing
test:
	@echo "🧪 Running Octopus test suite..."
	./venv/bin/pytest tests/ -v --cov=brain --cov=tentacles --cov-report=html

# Code quality
lint:
	@echo "🔍 Running code quality checks..."
	./venv/bin/flake8 brain/ tentacles/ services/
	./venv/bin/black brain/ tentacles/ services/ --check
	./venv/bin/mypy brain/ tentacles/ services/

# Local development
run:
	@echo "🚀 Starting Octopus platform locally..."
	docker-compose up --build

# Cloud deployments
deploy-aws:
	@echo "☁️ Deploying to AWS EKS..."
	./scripts/deployment/deploy-aws-eks.sh

deploy-gcp:
	@echo "☁️ Deploying to GCP GKE..."
	./scripts/deployment/deploy-gcp-gke.sh

# Cleanup
clean:
	@echo "🧹 Cleaning up Octopus environment..."
	docker-compose down -v || true
	docker system prune -f || true
	rm -rf venv/ || true

# First-time setup
first-time-setup: setup
	@echo "🎉 First-time setup complete!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Copy .env.example to .env"
	@echo "2. Add your OpenAI API key to .env"
	@echo "3. Run 'make run' to start the platform"
