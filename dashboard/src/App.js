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
