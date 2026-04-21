#!/bin/bash
# Master Agent Server Control Script
# Manage all project agent servers from one place

set -e

# Project configurations
declare -A PROJECTS=(
    ["diaperstops"]="projects/diaperstops.com:8001"
    ["reno-app"]="projects/reno-app:8002"
    ["climate"]="projects/ClimateWardrobe:8003"
    ["translator"]="projects/translator:8004"
    ["android"]="projects/android-app-template:8005"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    echo "🤖 Agent Server Control"
    echo "======================="
    echo ""
    echo "Usage: $0 <command> [project]"
    echo ""
    echo "Commands:"
    echo "  start <project>   - Start agent server for a project"
    echo "  stop <project>    - Stop agent server for a project"
    echo "  restart <project> - Restart agent server for a project"
    echo "  status [project]  - Show status of agent servers"
    echo "  start-all         - Start all agent servers"
    echo "  stop-all          - Stop all agent servers"
    echo "  test <project>    - Test agent server API"
    echo "  list              - List all projects"
    echo ""
    echo "Projects:"
    for proj in "${!PROJECTS[@]}"; do
        IFS=':' read -r path port <<< "${PROJECTS[$proj]}"
        echo "  $proj (port $port)"
    done
    echo ""
}

get_pid() {
    local port=$1
    lsof -ti:$port 2>/dev/null || echo ""
}

is_running() {
    local port=$1
    local pid=$(get_pid $port)
    [ -n "$pid" ]
}

start_server() {
    local project=$1
    
    if [ -z "${PROJECTS[$project]}" ]; then
        echo -e "${RED}❌ Unknown project: $project${NC}"
        echo "Run '$0 list' to see available projects"
        exit 1
    fi
    
    IFS=':' read -r path port <<< "${PROJECTS[$project]}"
    
    if is_running $port; then
        echo -e "${YELLOW}⚠️  Agent server already running on port $port${NC}"
        return
    fi
    
    echo -e "${BLUE}🚀 Starting $project agent server (port $port)...${NC}"
    
    cd "$path"
    nohup ./start-agent-server.sh > agent-server.log 2>&1 &
    cd - > /dev/null
    
    sleep 2
    
    if is_running $port; then
        echo -e "${GREEN}✅ Started successfully${NC}"
    else
        echo -e "${RED}❌ Failed to start${NC}"
        echo "Check log: $path/agent-server.log"
    fi
}

stop_server() {
    local project=$1
    
    if [ -z "${PROJECTS[$project]}" ]; then
        echo -e "${RED}❌ Unknown project: $project${NC}"
        exit 1
    fi
    
    IFS=':' read -r path port <<< "${PROJECTS[$project]}"
    
    local pid=$(get_pid $port)
    
    if [ -z "$pid" ]; then
        echo -e "${YELLOW}⚠️  Agent server not running on port $port${NC}"
        return
    fi
    
    echo -e "${BLUE}🛑 Stopping $project agent server (PID $pid)...${NC}"
    
    # Try graceful shutdown first
    curl -s -X POST http://localhost:$port/stop-all > /dev/null 2>&1 || true
    sleep 1
    
    # Force kill if still running
    if is_running $port; then
        kill $pid 2>/dev/null || true
        sleep 1
    fi
    
    if ! is_running $port; then
        echo -e "${GREEN}✅ Stopped successfully${NC}"
    else
        echo -e "${RED}❌ Failed to stop (trying force kill)${NC}"
        kill -9 $pid 2>/dev/null || true
    fi
}

show_status() {
    local project=$1
    
    echo "🤖 Agent Server Status"
    echo "======================"
    echo ""
    
    if [ -n "$project" ]; then
        if [ -z "${PROJECTS[$project]}" ]; then
            echo -e "${RED}❌ Unknown project: $project${NC}"
            exit 1
        fi
        
        IFS=':' read -r path port <<< "${PROJECTS[$project]}"
        
        if is_running $port; then
            local pid=$(get_pid $port)
            echo -e "${GREEN}✅ $project${NC} (port $port, PID $pid)"
            
            # Try to get server info
            local info=$(curl -s http://localhost:$port/ 2>/dev/null || echo "")
            if [ -n "$info" ]; then
                echo "$info" | jq '.' 2>/dev/null || echo "$info"
            fi
        else
            echo -e "${RED}❌ $project${NC} (port $port) - Not running"
        fi
    else
        for proj in "${!PROJECTS[@]}"; do
            IFS=':' read -r path port <<< "${PROJECTS[$proj]}"
            
            if is_running $port; then
                local pid=$(get_pid $port)
                echo -e "${GREEN}✅ $proj${NC} (port $port, PID $pid)"
            else
                echo -e "${RED}❌ $proj${NC} (port $port) - Not running"
            fi
        done
    fi
    echo ""
}

test_server() {
    local project=$1
    
    if [ -z "${PROJECTS[$project]}" ]; then
        echo -e "${RED}❌ Unknown project: $project${NC}"
        exit 1
    fi
    
    IFS=':' read -r path port <<< "${PROJECTS[$project]}"
    
    if ! is_running $port; then
        echo -e "${RED}❌ Agent server not running on port $port${NC}"
        echo "Start it with: $0 start $project"
        exit 1
    fi
    
    echo -e "${BLUE}🧪 Testing $project agent server...${NC}"
    echo ""
    
    echo "1. Server info:"
    curl -s http://localhost:$port/ | jq '.' || echo "Failed"
    echo ""
    
    echo "2. Process list:"
    curl -s http://localhost:$port/processes | jq '.' || echo "Failed"
    echo ""
    
    echo "3. Test task execution:"
    curl -s -X POST http://localhost:$port/execute \
        -H "Content-Type: application/json" \
        -d '{"task":"echo Hello from agent test"}' | jq '.' || echo "Failed"
    echo ""
}

start_all() {
    echo -e "${BLUE}🚀 Starting all agent servers...${NC}"
    echo ""
    
    for proj in "${!PROJECTS[@]}"; do
        start_server $proj
        echo ""
    done
    
    echo ""
    show_status
}

stop_all() {
    echo -e "${BLUE}🛑 Stopping all agent servers...${NC}"
    echo ""
    
    for proj in "${!PROJECTS[@]}"; do
        stop_server $proj
        echo ""
    done
}

list_projects() {
    echo "📋 Available Projects"
    echo "===================="
    echo ""
    
    for proj in "${!PROJECTS[@]}"; do
        IFS=':' read -r path port <<< "${PROJECTS[$proj]}"
        echo "  $proj"
        echo "    Path: $path"
        echo "    Port: $port"
        echo "    API:  http://localhost:$port"
        echo ""
    done
}

# Main command handler
case "${1:-}" in
    start)
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Project name required${NC}"
            show_help
            exit 1
        fi
        start_server "$2"
        ;;
    stop)
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Project name required${NC}"
            show_help
            exit 1
        fi
        stop_server "$2"
        ;;
    restart)
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Project name required${NC}"
            show_help
            exit 1
        fi
        stop_server "$2"
        sleep 1
        start_server "$2"
        ;;
    status)
        show_status "$2"
        ;;
    test)
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Project name required${NC}"
            show_help
            exit 1
        fi
        test_server "$2"
        ;;
    start-all)
        start_all
        ;;
    stop-all)
        stop_all
        ;;
    list)
        list_projects
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac
