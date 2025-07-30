"""
Tests for Octopus Brain
"""

import pytest
import asyncio
from brain.coordinator.octopus_brain import OctopusBrain

class TestOctopusBrain:
    
    @pytest.fixture
    def brain(self):
        return OctopusBrain()
    
    @pytest.mark.asyncio
    async def test_brain_initialization(self, brain):
        """Test brain initialization"""
        await brain.initialize_brain()
        assert brain.brain_id == "octopus-brain-001"
    
    @pytest.mark.asyncio
    async def test_tentacle_coordination(self, brain):
        """Test tentacle coordination"""
        situation = {
            "type": "test_incident",
            "severity": "medium"
        }
        
        result = await brain.coordinate_tentacles(situation)
        
        assert result["success"] == True
        assert "coordination_id" in result
