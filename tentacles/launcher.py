#!/usr/bin/env python3
"""
Octopus SRE Platform Launcher
"""
import os
import sys
from pathlib import Path

def main():
    print("🐙 Starting Octopus SRE Platform...")
    print(f"Python version: {sys.version}")
    print(f"Working directory: {os.getcwd()}")
    
    # Add your application startup logic here
    print("✅ Octopus Platform ready!")
    
    # Keep the container running
    import time
    while True:
        print("❤️ Octopus heartbeat...")
        time.sleep(30)

if __name__ == "__main__":
    main()
