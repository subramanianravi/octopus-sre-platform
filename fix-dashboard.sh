#!/bin/bash
# Fix script for missing dashboard files

echo "🔧 Fixing Octopus Dashboard..."

# Create dashboard directory if it doesn't exist
mkdir -p dashboard

# Create package.json for React dashboard
cat > dashboard/package.json << 'EOF'
{
  "name": "octopus-dashboard",
  "version": "1.0.0",
  "description": "🐙 Octopus SRE Platform Dashboard",
  "main": "src/index.js",
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "axios": "^1.6.0",
    "recharts": "^2.8.0",
    "lucide-react": "^0.294.0"
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

# Create Dockerfile for dashboard
cat > dashboard/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the app
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=0 /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
EOF

# Create nginx config
cat > dashboard/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    server {
        listen 3000;
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
            try_files $uri $uri/ /index.html;
        }
    }
}
EOF

# Create React app structure
mkdir -p dashboard/src dashboard/public

# Create public/index.html
cat > dashboard/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="🐙 Octopus SRE Platform Dashboard" />
    <title>🐙 Octopus SRE Platform</title>
    <style>
      body {
        margin: 0;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
          'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
          sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
      }
    </style>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF

# Create src/index.js
cat > dashboard/src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# Create src/App.js
cat > dashboard/src/App.js << 'EOF'
import React, { useState, useEffect } from 'react';
import './App.css';
import { Activity, Brain, Zap, Shield, Database, Network, Eye, Cpu } from 'lucide-react';

const BRAIN_URL = process.env.REACT_APP_BRAIN_URL || 'http://localhost:8080';

function App() {
  const [tentacles, setTentacles] = useState([]);
  const [systemStatus, setSystemStatus] = useState('initializing');
  const [incidents, setIncidents] = useState([]);

  // Mock data for demo
  useEffect(() => {
    const mockTentacles = [
      { id: 'detection-001', type: 'Detection', status: 'active', intelligence: 95, icon: Eye, workload: 73 },
      { id: 'response-001', type: 'Response', status: 'active', intelligence: 89, icon: Zap, workload: 45 },
      { id: 'learning-001', type: 'Learning', status: 'active', intelligence: 92, icon: Brain, workload: 67 },
      { id: 'security-001', type: 'Security', status: 'active', intelligence: 88, icon: Shield, workload: 23 },
      { id: 'capacity-001', type: 'Capacity', status: 'active', intelligence: 85, icon: Activity, workload: 56 },
      { id: 'network-001', type: 'Network', status: 'active', intelligence: 90, icon: Network, workload: 34 },
      { id: 'data-001', type: 'Data', status: 'active', intelligence: 87, icon: Database, workload: 78 },
      { id: 'meta-001', type: 'Meta', status: 'active', intelligence: 93, icon: Cpu, workload: 42 }
    ];

    setTentacles(mockTentacles);
    setSystemStatus('operational');

    const mockIncidents = [
      { id: 1, type: 'CPU Spike', severity: 'medium', status: 'resolving', tentacle: 'Detection' },
      { id: 2, type: 'Memory Leak', severity: 'high', status: 'resolved', tentacle: 'Response' },
      { id: 3, type: 'Network Latency', severity: 'low', status: 'monitoring', tentacle: 'Network' }
    ];

    setIncidents(mockIncidents);
  }, []);

  const getSeverityColor = (severity) => {
    switch (severity) {
      case 'high': return 'text-red-400';
      case 'medium': return 'text-yellow-400';
      case 'low': return 'text-green-400';
      default: return 'text-gray-400';
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'text-green-400';
      case 'inactive': return 'text-red-400';
      case 'warning': return 'text-yellow-400';
      default: return 'text-gray-400';
    }
  };

  return (
    <div className="App">
      <header className="header">
        <div className="header-content">
          <h1>🐙 Octopus SRE Platform</h1>
          <div className="system-status">
            <span className={`status-indicator ${systemStatus === 'operational' ? 'operational' : 'warning'}`}>
              {systemStatus.toUpperCase()}
            </span>
          </div>
        </div>
      </header>

      <main className="main-content">
        <div className="dashboard-grid">
          {/* Tentacles Overview */}
          <div className="card">
            <h2>🐙 Tentacle Status</h2>
            <div className="tentacles-grid">
              {tentacles.map((tentacle) => {
                const IconComponent = tentacle.icon;
                return (
                  <div key={tentacle.id} className="tentacle-card">
                    <div className="tentacle-header">
                      <IconComponent size={20} />
                      <span className="tentacle-name">{tentacle.type}</span>
                      <span className={`tentacle-status ${getStatusColor(tentacle.status)}`}>
                        ●
                      </span>
                    </div>
                    <div className="tentacle-metrics">
                      <div className="metric">
                        <span>Intelligence:</span>
                        <span>{tentacle.intelligence}%</span>
                      </div>
                      <div className="metric">
                        <span>Workload:</span>
                        <span>{tentacle.workload}%</span>
                      </div>
                    </div>
                    <div className="workload-bar">
                      <div 
                        className="workload-progress" 
                        style={{ width: `${tentacle.workload}%` }}
                      ></div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Recent Incidents */}
          <div className="card">
            <h2>🚨 Recent Incidents</h2>
            <div className="incidents-list">
              {incidents.map((incident) => (
                <div key={incident.id} className="incident-item">
                  <div className="incident-info">
                    <span className="incident-type">{incident.type}</span>
                    <span className={`incident-severity ${getSeverityColor(incident.severity)}`}>
                      {incident.severity.toUpperCase()}
                    </span>
                  </div>
                  <div className="incident-details">
                    <span className="incident-tentacle">Handled by: {incident.tentacle}</span>
                    <span className={`incident-status ${getStatusColor(incident.status)}`}>
                      {incident.status}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* System Metrics */}
          <div className="card">
            <h2>📊 System Metrics</h2>
            <div className="metrics-grid">
              <div className="metric-card">
                <h3>Uptime</h3>
                <span className="metric-value">99.97%</span>
              </div>
              <div className="metric-card">
                <h3>MTTR</h3>
                <span className="metric-value">8 min</span>
              </div>
              <div className="metric-card">
                <h3>Incidents Resolved</h3>
                <span className="metric-value">85%</span>
              </div>
              <div className="metric-card">
                <h3>Active Tentacles</h3>
                <span className="metric-value">{tentacles.filter(t => t.status === 'active').length}</span>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;
EOF

# Create src/App.css
cat > dashboard/src/App.css << 'EOF'
.App {
  color: white;
  min-height: 100vh;
}

.header {
  background: rgba(0, 0, 0, 0.2);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding: 1rem 2rem;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1200px;
  margin: 0 auto;
}

.header h1 {
  margin: 0;
  font-size: 1.8rem;
  font-weight: bold;
}

.system-status {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.status-indicator {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: bold;
}

.status-indicator.operational {
  background: rgba(34, 197, 94, 0.2);
  color: #22c55e;
  border: 1px solid #22c55e;
}

.status-indicator.warning {
  background: rgba(251, 191, 36, 0.2);
  color: #fbbf24;
  border: 1px solid #fbbf24;
}

.main-content {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 2rem;
  grid-template-rows: auto auto;
}

.card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  padding: 1.5rem;
}

.card h2 {
  margin: 0 0 1.5rem 0;
  font-size: 1.3rem;
  font-weight: 600;
}

.tentacles-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.tentacle-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  padding: 1rem;
}

.tentacle-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.tentacle-name {
  font-weight: 500;
  flex: 1;
}

.tentacle-status {
  font-size: 1.2rem;
}

.tentacle-metrics {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  margin-bottom: 0.75rem;
  font-size: 0.9rem;
}

.metric {
  display: flex;
  justify-content: space-between;
}

.workload-bar {
  height: 4px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 2px;
  overflow: hidden;
}

.workload-progress {
  height: 100%;
  background: linear-gradient(90deg, #22c55e, #3b82f6);
  transition: width 0.3s ease;
}

.incidents-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.incident-item {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  padding: 1rem;
}

.incident-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.incident-type {
  font-weight: 500;
}

.incident-severity {
  font-size: 0.8rem;
  font-weight: bold;
}

.incident-details {
  display: flex;
  justify-content: space-between;
  font-size: 0.9rem;
  opacity: 0.8;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.metric-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  padding: 1rem;
  text-align: center;
}

.metric-card h3 {
  margin: 0 0 0.5rem 0;
  font-size: 0.9rem;
  opacity: 0.8;
}

.metric-value {
  font-size: 1.5rem;
  font-weight: bold;
  color: #22c55e;
}

.text-red-400 { color: #f87171; }
.text-yellow-400 { color: #fbbf24; }
.text-green-400 { color: #4ade80; }
.text-gray-400 { color: #9ca3af; }

/* Responsive design */
@media (max-width: 768px) {
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
  
  .tentacles-grid {
    grid-template-columns: 1fr;
  }
  
  .metrics-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .header {
    padding: 1rem;
  }
  
  .main-content {
    padding: 1rem;
  }
}
EOF

echo "✅ Dashboard files created!"
echo ""
echo "🚀 Now try running again:"
echo "make run"
