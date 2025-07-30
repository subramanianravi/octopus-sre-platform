# Octopus Brain - Central Coordinator Dockerfile
FROM python:3.11-slim AS base

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV OCTOPUS_HOME=/app
ENV OCTOPUS_COMPONENT=brain

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $OCTOPUS_HOME

# Copy requirements first for better caching
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy brain source code
COPY brain/ ./brain/
COPY services/ ./services/
COPY ocean/config/ ./ocean/config/

# Create octopus user for security
RUN useradd -m -u 1000 octopus && \
    chown -R octopus:octopus $OCTOPUS_HOME && \
    mkdir -p /app/data /app/logs && \
    chown -R octopus:octopus /app/data /app/logs

USER octopus

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose ports
EXPOSE 8080 8081

CMD ["python", "-m", "brain.main"]
