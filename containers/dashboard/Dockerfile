FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Create the directory
RUN mkdir -p /usr/share/nginx/html

# Use COPY with heredoc (modern Docker feature)
COPY <<HTML /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>🐙 Octopus SRE Platform</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background: #0D1B2A; color: #fff; }
        .container { max-width: 1200px; margin: 0 auto; padding: 40px; }
        .header { text-align: center; margin-bottom: 40px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 40px 0; }
        .stat-card { background: #1B263B; padding: 30px; border-radius: 12px; text-align: center; }
        .stat-value { font-size: 3em; font-weight: bold; color: #7ED321; margin-bottom: 10px; }
        .tentacles { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 15px; }
        .tentacle { background: #415A77; padding: 20px; border-radius: 8px; }
        .tentacle-name { font-weight: bold; color: #7ED321; margin-bottom: 10px; }
        .status-online { color: #7ED321; }
        .links { background: #2E5BBA; padding: 20px; border-radius: 8px; margin-top: 30px; }
        .links a { color: #7ED321; text-decoration: none; margin-right: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🐙 Octopus SRE Platform</h1>
            <p>Autonomous Site Reliability Engineering with Distributed AI Intelligence</p>
            <div class="status-online">🟢 System Operational</div>
        </div>
        
        <div class="stats">
            <div class="stat-card">
                <div class="stat-value">85%</div>
                <div>Autonomous Resolution Rate</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">8min</div>
                <div>Average MTTR</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">99.97%</div>
                <div>System Uptime</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">8</div>
                <div>Active Tentacles</div>
            </div>
        </div>
        
        <h2>🐙 Active Tentacles</h2>
        <div class="tentacles">
            <div class="tentacle">
                <div class="tentacle-name">🔍 Detection Tentacles (3)</div>
                <div>Real-time anomaly detection and pattern recognition</div>
            </div>
            <div class="tentacle">
                <div class="tentacle-name">🚨 Response Tentacles (2)</div>
                <div>Autonomous incident response and remediation</div>
            </div>
            <div class="tentacle">
                <div class="tentacle-name">📚 Learning Tentacles (1)</div>
                <div>Continuous improvement and adaptation</div>
            </div>
            <div class="tentacle">
                <div class="tentacle-name">🔒 Security Tentacles (1)</div>
                <div>Threat detection and automated defense</div>
            </div>
        </div>
        
        <div class="links">
            <h3>🔗 Quick Access</h3>
            <a href="http://localhost:8080">🧠 Brain API</a>
            <a href="http://localhost:9090">📈 Prometheus</a>
            <a href="http://localhost:3001">📊 Grafana</a>
            <a href="http://localhost:16686">🔍 Jaeger</a>
        </div>
    </div>
</body>
</html>
HTML

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=10s CMD curl -f http://localhost/ || exit 1
CMD ["nginx", "-g", "daemon off;"]
