#!/bin/bash
# Fix port 3000 conflict for Octopus Dashboard

echo "🔍 Checking what's using port 3000..."

# Check what's using port 3000
echo "📊 Current port 3000 usage:"
lsof -i :3000 || netstat -tulpn | grep :3000 || echo "No process details found"

echo ""
echo "🛠️ SOLUTION OPTIONS:"
echo "==================="
echo ""

# Option 1: Kill the process using port 3000
echo "1️⃣ OPTION 1: Stop process using port 3000"
echo "   sudo lsof -ti:3000 | xargs kill -9"
echo ""

# Option 2: Change dashboard port
echo "2️⃣ OPTION 2: Change dashboard port to 3002"
echo ""

read -p "Choose option [1/2]: " choice

case $choice in
    1)
        echo "🛑 Stopping process on port 3000..."
        sudo lsof -ti:3000 | xargs kill -9 2>/dev/null || echo "No process to kill"
        echo "✅ Port 3000 freed"
        
        echo "🚀 Restarting dashboard..."
        docker-compose up -d octopus-dashboard
        
        sleep 5
        if curl -sf http://localhost:3000 > /dev/null 2>&1; then
            echo "✅ Dashboard now running on http://localhost:3000"
        else
            echo "❌ Dashboard still not responding"
        fi
        ;;
        
    2)
        echo "🔧 Changing dashboard port to 3002..."
        
        # Backup current docker-compose.yml
        cp docker-compose.yml docker-compose.yml.backup
        
        # Change port from 3000 to 3002
        sed -i.bak 's/"3000:80"/"3002:80"/' docker-compose.yml
        
        echo "✅ Port changed to 3002 in docker-compose.yml"
        
        # Restart dashboard with new port
        docker-compose up -d octopus-dashboard
        
        sleep 5
        if curl -sf http://localhost:3002 > /dev/null 2>&1; then
            echo "✅ Dashboard now running on http://localhost:3002"
        else
            echo "❌ Dashboard still not responding on port 3002"
        fi
        ;;
        
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "🎉 OCTOPUS PLATFORM STATUS:"
echo "=========================="

# Show full status
docker-compose ps

echo ""
echo "📊 ACCESS POINTS:"
if [[ $choice == "2" ]]; then
    echo "  🖥️ Dashboard:        http://localhost:3002"
else
    echo "  🖥️ Dashboard:        http://localhost:3000"
fi
echo "  🧠 Brain API:        http://localhost:8080"
echo "  📈 Prometheus:       http://localhost:9090"
echo "  📊 Grafana:          http://localhost:3001"
echo "  🔍 Jaeger:           http://localhost:16686"

echo ""
echo "🧪 Quick test - Brain API:"
curl -s http://localhost:8080 | head -3

echo ""
echo "🐙 Tentacle Status:"
curl -s http://localhost:8080/tentacles/status | grep -E '"total_tentacles"|"active_tentacles"' || echo "Tentacles starting up..."

echo ""
echo "✅ Octopus SRE Platform is LIVE! 🐙"
