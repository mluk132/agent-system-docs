#!/bin/bash
# Start Mac worker

set -e

echo "🚀 Starting Mac Worker"
echo "======================"
echo ""

# Load environment
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Default configuration
BROKER_URL=${BROKER_URL:-"https://your-broker.fly.dev"}
CPU_LIMIT=${CPU_LIMIT:-40}
RAM_LIMIT=${RAM_LIMIT:-40}

echo "📊 Configuration:"
echo "   Broker: $BROKER_URL"
echo "   CPU Limit: $CPU_LIMIT%"
echo "   RAM Limit: $RAM_LIMIT%"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
pip3 install -q -r requirements.txt

# Start agent servers
echo "🤖 Starting agent servers..."
cd ../../
./agent-control.sh start-all
cd simple-broker-system/mac-worker

sleep 3

# Start worker
echo ""
echo "⚙️  Starting worker..."
python3 worker.py
