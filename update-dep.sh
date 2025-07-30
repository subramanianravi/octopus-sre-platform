# Backup existing requirements.txt if it exists
if [ -f "requirements.txt" ]; then
    cp requirements.txt requirements.txt.backup
    echo "" >> requirements.txt
    echo "# ===============================================" >> requirements.txt
    echo "# 🐙 Octopus SRE Platform Dependencies" >> requirements.txt
    echo "# ===============================================" >> requirements.txt
else
    echo "# Octopus SRE Platform - Python Dependencies" > requirements.txt
fi

# Add Octopus dependencies
cat >> requirements.txt << 'EOF'

# Core Framework
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
pydantic-settings==2.1.0

# AI/ML Libraries
openai==1.3.8
anthropic==0.7.8
numpy==1.24.3
pandas==2.0.3
scikit-learn==1.3.0
tensorflow==2.13.0

# Async and Concurrency
aiofiles==23.2.1
aioredis==2.0.1
asyncpg==0.29.0

# Data Processing
kafka-python==2.0.2
redis==5.0.1
sqlalchemy[asyncio]==2.0.23

# Monitoring and Observability
prometheus-client==0.19.0
structlog==23.2.0
opentelemetry-api==1.21.0

# Security
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4

# HTTP and API
httpx==0.25.2
requests==2.31.0

# Configuration
python-dotenv==1.0.0
pyyaml==6.0.1

# Development
pytest==7.4.3
black==23.11.0
flake8==6.1.0
mypy==1.7.1
EOF

echo "✅ Dependencies updated"
