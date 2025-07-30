#!/usr/bin/env python3
"""
Octopus Brain - Central Coordinator
Main entry point for the Octopus SRE Platform Brain
"""
import asyncio
import logging
import os
from datetime import datetime
from typing import Dict, List, Any
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("octopus.brain")

app = FastAPI(
    title="🧠 Octopus Brain",
    description="Central Coordinator for Octopus SRE Platform",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global state for demonstration
tentacle_registry = {}
incident_history = []
coordination_stats = {
    "total_coordinations": 0,
    "successful_coordinations": 0,
    "average_response_time_ms": 45,
    "autonomous_resolution_rate": 0.85
}

@app.get("/")
async def root():
    return {
        "message": "🧠 Octopus Brain Online",
        "status": "operational",
        "uptime": "99.97%",
        "active_tentacles": len(tentacle_registry),
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "component": "brain",
        "checks": {
            "api": "healthy",
            "memory": "healthy",
            "coordination": "healthy",
            "decision_engine": "healthy"
        },
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/tentacles/status")
async def tentacles_status():
    return {
        "total_tentacles": 8,
        "active_tentacles": len(tentacle_registry),
        "tentacle_types": [
            "detection", "response", "learning", "security",
            "capacity", "network", "data", "meta"
        ],
        "registry": tentacle_registry,
        "last_update": datetime.utcnow().isoformat()
    }

@app.post("/tentacles/register")
async def register_tentacle(tentacle_info: Dict[str, Any]):
    tentacle_id = tentacle_info.get("tentacle_id")
    if not tentacle_id:
        raise HTTPException(status_code=400, detail="tentacle_id required")
    
    tentacle_registry[tentacle_id] = {
        **tentacle_info,
        "registered_at": datetime.utcnow().isoformat(),
        "status": "active"
    }
    
    logger.info(f"🐙 Registered tentacle: {tentacle_id}")
    return {"status": "registered", "tentacle_id": tentacle_id}

@app.get("/coordination/status")
async def coordination_status():
    return {
        "coordination_active": True,
        "stats": coordination_stats,
        "recent_coordinations": len(incident_history),
        "last_coordination": incident_history[-1] if incident_history else None
    }

@app.post("/incidents")
async def submit_incident(incident: Dict[str, Any]):
    incident_id = f"inc_{len(incident_history) + 1:06d}"
    
    incident_record = {
        "incident_id": incident_id,
        "submitted_at": datetime.utcnow().isoformat(),
        "status": "processing",
        **incident
    }
    
    incident_history.append(incident_record)
    coordination_stats["total_coordinations"] += 1
    
    # Simulate autonomous processing
    await asyncio.sleep(0.1)  # Simulate processing time
    
    incident_record["status"] = "resolved"
    incident_record["resolved_at"] = datetime.utcnow().isoformat()
    incident_record["resolution_method"] = "autonomous"
    incident_record["mttr_seconds"] = 45
    
    coordination_stats["successful_coordinations"] += 1
    
    logger.info(f"🚨 Processed incident: {incident_id}")
    
    return incident_record

@app.get("/incidents/{incident_id}")
async def get_incident(incident_id: str):
    for incident in incident_history:
        if incident["incident_id"] == incident_id:
            return incident
    raise HTTPException(status_code=404, detail="Incident not found")

@app.get("/incidents")
async def list_incidents():
    return {
        "total_incidents": len(incident_history),
        "incidents": incident_history[-10:],  # Last 10 incidents
        "summary": {
            "resolved": len([i for i in incident_history if i.get("status") == "resolved"]),
            "processing": len([i for i in incident_history if i.get("status") == "processing"]),
            "autonomous_rate": coordination_stats["autonomous_resolution_rate"]
        }
    }

@app.get("/metrics")
async def get_metrics():
    return {
        "platform_metrics": {
            "uptime_percentage": 99.97,
            "mttr_minutes": 8,
            "autonomous_resolution_rate": 0.85,
            "total_incidents": len(incident_history),
            "tentacles_active": len(tentacle_registry)
        },
        "performance_metrics": {
            "average_response_time_ms": coordination_stats["average_response_time_ms"],
            "decisions_per_hour": 156,
            "learning_velocity": 0.92,
            "prediction_accuracy": 0.94
        }
    }

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    host = os.getenv("HOST", "0.0.0.0")
    
    logger.info(f"🧠 Starting Octopus Brain on {host}:{port}")
    uvicorn.run(app, host=host, port=port)
