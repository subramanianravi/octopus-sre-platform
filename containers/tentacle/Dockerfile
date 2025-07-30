FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY tentacles/ ./tentacles/
COPY brain/ ./brain/

RUN useradd -m -u 1000 octopus && chown -R octopus:octopus /app
USER octopus

EXPOSE 8080

CMD ["python", "-m", "tentacles.detection.anomaly_tentacle"]
