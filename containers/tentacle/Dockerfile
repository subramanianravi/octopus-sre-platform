# Octopus Tentacles - AI Agents Dockerfile
FROM python:3.11-slim AS base

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV OCTOPUS_HOME=/app
ENV OCTOPUS_COMPONENT=tentacle

# Install system dependencies including ML libraries
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    libpq-dev \
    libhdf5-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $OCTOPUS_HOME

# Copy requirements
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy tentacle source code
COPY tentacles/ ./tentacles/
COPY services/ ./services/
COPY ocean/config/ ./ocean/config/

# Create directory structure for different tentacle types
RUN mkdir -p \
    ./data/models \
    ./data/cache \
    ./logs

# Create octopus user
RUN useradd -m -u 1000 octopus && \
    chown -R octopus:octopus $OCTOPUS_HOME

USER octopus

# Health check for tentacles
HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose ports
EXPOSE 8080

CMD ["python", "-m", "tentacles.launcher"]
