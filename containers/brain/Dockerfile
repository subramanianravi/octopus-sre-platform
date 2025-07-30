FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY brain/ ./brain/
COPY tentacles/ ./tentacles/
COPY services/ ./services/

# Create non-root user
RUN useradd -m -u 1000 octopus && chown -R octopus:octopus /app
USER octopus

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080

CMD ["python", "-m", "brain.coordinator.octopus_brain"]
