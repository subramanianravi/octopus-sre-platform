#!/usr/bin/env python3
"""
Octopus Tentacle Launcher
Starts and manages individual tentacle instances
"""
import asyncio
import logging
import os
import httpx
from datetime import datetime
from typing import Dict, Any
from fastapi import FastAPI
import uvicorn

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("octopus.tentacle")

app = FastAPI(title="🐙 Octopus Tentacle")

# Tentacle configuration
TENTACLE_TYPE = os.getenv("TENTACLE_TYPE", "generic")
BRAIN_URL = os.getenv("BRAIN_URL", "http://octopus-brain:8080")
TENTACLE_ID = f"{TENTACLE_TYPE}-{os.getpid()}"

# Tentacle capabilities mapping
CAPABILITIES = {
    "detection": [
        "anomaly_detection",
        "pattern_recognition", 
        "predictive_analysis",
        "real_time_monitoring"
    ],
    "response": [
        "incident_response",
        "auto_remediation",
        "rollback_management",
        "impact_assessment"
    ],
    "learning": [
        "pattern_extraction",
        "model_improvement",
        "knowledge_synthesis",
        "performance_optimization"
    ],
    "security": [
        "threat_detection",
        "automated_defense",
        "compliance_monitoring",
        "vulnerability_assessment"
    ],
    "capacity": [
        "auto_scaling",
        "resource_optimization",
        "cost_analysis",
        "performance_tuning"
    ],
    "network": [
        "connectivity_monitoring",
        "traffic_optimization",
        "latency_analysis",
        "routing_decisions"
    ],
    "data": [
        "data_correlation",
        "analytics",
        "quality_monitoring",
        "pipeline_optimization"
    ],
    "meta": [
        "system_optimization",
        "health_monitoring",
        "coordination_efficiency",
        "resource_allocation"
    ]
}

# Tentacle state
tentacle_state = {
    "intelligence_level": 85.0,
    "tasks_processed": 0,
    "last_activity": datetime.utcnow(),
    "status": "initializing"
}

async def register_with_brain():
    """Register this tentacle with the brain"""
    try:
        async with httpx.AsyncClient() as client:
            registration_data = {
                "tentacle_id": TENTACLE_ID,
                "tentacle_type": TENTACLE_TYPE,
                "capabilities": CAPABILITIES.get(TENTACLE_TYPE, ["generic_processing"]),
                "intelligence_level": tentacle_state["intelligence_level"],
                "status": "active"
            }
            
            response = await client.post(
                f"{BRAIN_URL}/tentacles/register",
                json=registration_data,
                timeout=10.0
            )
            
            if response.status_code == 200:
                logger.info(f"🧠 Successfully registered with brain: {TENTACLE_ID}")
                tentacle_state["status"] = "active"
                return True
            else:
                logger.warning(f"Failed to register with brain: {response.status_code}")
                return False
                
    except Exception as e:
        logger.error(f"Error registering with brain: {e}")
        return False

@app.on_event("startup")
async def startup_event():
    """Tentacle startup sequence"""
    logger.info(f"🐙 Starting {TENTACLE_TYPE.title()} Tentacle: {TENTACLE_ID}")
    
    # Wait a bit for brain to be ready
    await asyncio.sleep(2)
    
    # Register with brain
    await register_with_brain()
    
    # Start background tasks
    asyncio.create_task(heartbeat_task())

async def heartbeat_task():
    """Send periodic heartbeat to brain"""
    while True:
        try:
            tentacle_state["last_activity"] = datetime.utcnow()
            await asyncio.sleep(30)  # Heartbeat every 30 seconds
        except Exception as e:
            logger.error(f"Heartbeat error: {e}")
            await asyncio.sleep(5)

@app.get("/")
async def root():
    return {
        "message": f"🐙 {TENTACLE_TYPE.title()} Tentacle Online",
        "status": tentacle_state["status"],
        "tentacle_id": TENTACLE_ID,
        "tentacle_type": TENTACLE_TYPE,
        "intelligence_level": tentacle_state["intelligence_level"],
        "tasks_processed": tentacle_state["tasks_processed"],
        "last_activity": tentacle_state["last_activity"].isoformat()
    }

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "component": "tentacle",
        "tentacle_type": TENTACLE_TYPE,
        "tentacle_id": TENTACLE_ID
    }

@app.get("/capabilities")
async def capabilities():
    return {
        "tentacle_type": TENTACLE_TYPE,
        "tentacle_id": TENTACLE_ID,
        "capabilities": CAPABILITIES.get(TENTACLE_TYPE, ["generic_processing"]),
        "intelligence_level": tentacle_state["intelligence_level"],
        "specialization_score": 90.0
    }

@app.post("/tasks")
async def process_task(task_data: Dict[str, Any]):
    """Process a task assigned by the brain"""
    task_id = task_data.get("task_id", f"task_{tentacle_state['tasks_processed'] + 1}")
    
    logger.info(f"🎯 Processing task: {task_id}")
    
    # Simulate task processing
    await asyncio.sleep(0.5)  # Simulate processing time
    
    tentacle_state["tasks_processed"] += 1
    tentacle_state["last_activity"] = datetime.utcnow()
    
    result = {
        "task_id": task_id,
        "tentacle_id": TENTACLE_ID,
        "status": "completed",
        "result": f"Task processed by {TENTACLE_TYPE} tentacle",
        "processing_time_ms": 500,
        "confidence": 0.92,
        "timestamp": datetime.utcnow().isoformat()
    }
    
    return result

@app.get("/status")
async def get_status():
    return {
        "tentacle_id": TENTACLE_ID,
        "tentacle_type": TENTACLE_TYPE,
        "state": tentacle_state,
        "brain_connection": BRAIN_URL,
        "capabilities": CAPABILITIES.get(TENTACLE_TYPE, [])
    }

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    host = os.getenv("HOST", "0.0.0.0")
    
    logger.info(f"🐙 Starting {TENTACLE_TYPE.title()} Tentacle on {host}:{port}")
    uvicorn.run(app, host=host, port=port)
