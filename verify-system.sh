#!/bin/bash
# Verify Agent System Installation
# Run this to check everything is properly installed

set -e

echo "🔍 Agent System Verification"
echo "============================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

check_file() {
    local file=$1
    local desc=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅${NC} $desc"
    else
        echo -e "${RED}❌${NC} $desc - NOT FOUND: $file"
        ((ERRORS++))
    fi
}

check_executable() {
    local file=$1
    local desc=$2
    
    if [ -x "$file" ]; then
        echo -e "${GREEN}✅${NC} $desc"
    else
        echo -e "${YELLOW}⚠️${NC} $desc - NOT EXECUTABLE: $file"
        ((WARNINGS++))
    fi
}

echo "1. Checking Template Files"
echo "──────────────────────────"
check_file "templates/agent-server.py" "Template agent-server.py"
check_file "templates/README.md" "Template README"
echo ""

echo "2. Checking Project Deployments"
echo "────────────────────────────────"
check_file "diaperstops.com/agent-server.py" "diaperstops agent-server.py"
check_file "diaperstops.com/start-agent-server.sh" "diaperstops startup script"
check_file "diaperstops.com/.agent-task.sh" "diaperstops task handler"

check_file "reno-app/agent-server.py" "reno-app agent-server.py"
check_file "reno-app/start-agent-server.sh" "reno-app startup script"
check_file "reno-app/.agent-task.sh" "reno-app task handler"

check_file "ClimateWardrobe/agent-server.py" "ClimateWardrobe agent-server.py"
check_file "ClimateWardrobe/start-agent-server.sh" "ClimateWardrobe startup script"
check_file "ClimateWardrobe/.agent-task.sh" "ClimateWardrobe task handler"

check_file "translator/agent-server.py" "translator agent-server.py"
check_file "translator/start-agent-server.sh" "translator startup script"
check_file "translator/.agent-task.sh" "translator task handler"

check_file "android-app-template/agent-server.py" "android-app-template agent-server.py"
check_file "android-app-template/start-agent-server.sh" "android-app-template startup script"
check_file "android-app-template/.agent-task.sh" "android-app-template task handler"
echo ""

echo "3. Checking Master Control"
echo "──────────────────────────"
check_file "agent-control.sh" "Master control script"
check_executable "agent-control.sh" "Master control executable"
echo ""

echo "4. Checking Documentation"
echo "─────────────────────────"
check_file "START_HERE.md" "START_HERE guide"
check_file "AGENT_QUICK_REF.md" "Quick reference"
check_file "AGENT_SERVERS_GUIDE.md" "Complete guide"
check_file "AGENT_SYSTEM_DEPLOYED.md" "Deployment details"
check_file "CLOUD_LOCAL_INTEGRATION.md" "Integration guide"
check_file "COMPLETE_AGENT_SYSTEM.md" "Final summary"
check_file "SYSTEM_DIAGRAM.txt" "System diagram"
echo ""

echo "5. Checking Executables"
echo "───────────────────────"
check_executable "diaperstops.com/start-agent-server.sh" "diaperstops startup"
check_executable "reno-app/start-agent-server.sh" "reno-app startup"
check_executable "ClimateWardrobe/start-agent-server.sh" "ClimateWardrobe startup"
check_executable "translator/start-agent-server.sh" "translator startup"
check_executable "android-app-template/start-agent-server.sh" "android-app-template startup"
echo ""

echo "6. Checking Dependencies"
echo "────────────────────────"
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✅${NC} Python 3 installed"
else
    echo -e "${RED}❌${NC} Python 3 NOT FOUND"
    ((ERRORS++))
fi

if python3 -c "import psutil" 2>/dev/null; then
    echo -e "${GREEN}✅${NC} psutil installed"
else
    echo -e "${YELLOW}⚠️${NC} psutil NOT FOUND (run: pip3 install psutil)"
    ((WARNINGS++))
fi

if command -v kiro &> /dev/null; then
    echo -e "${GREEN}✅${NC} Kiro installed"
else
    echo -e "${YELLOW}⚠️${NC} Kiro NOT FOUND in PATH"
    ((WARNINGS++))
fi

if command -v curl &> /dev/null; then
    echo -e "${GREEN}✅${NC} curl installed"
else
    echo -e "${RED}❌${NC} curl NOT FOUND"
    ((ERRORS++))
fi

if command -v jq &> /dev/null; then
    echo -e "${GREEN}✅${NC} jq installed"
else
    echo -e "${YELLOW}⚠️${NC} jq NOT FOUND (optional, for pretty JSON)"
    ((WARNINGS++))
fi
echo ""

echo "7. Checking Port Availability"
echo "──────────────────────────────"
for port in 8001 8002 8003 8004 8005; do
    if lsof -i:$port &> /dev/null; then
        echo -e "${YELLOW}⚠️${NC} Port $port is in use"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✅${NC} Port $port available"
    fi
done
echo ""

echo "════════════════════════════════"
echo "Summary"
echo "════════════════════════════════"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 Perfect! Everything is installed correctly.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Start all servers: ./agent-control.sh start-all"
    echo "  2. Check status: ./agent-control.sh status"
    echo "  3. Test one: ./agent-control.sh test diaperstops"
    echo ""
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Installation complete with $WARNINGS warnings.${NC}"
    echo ""
    echo "You can proceed, but consider fixing the warnings."
    echo ""
else
    echo -e "${RED}❌ Installation incomplete: $ERRORS errors, $WARNINGS warnings.${NC}"
    echo ""
    echo "Please fix the errors before proceeding."
    echo ""
    exit 1
fi

echo "Documentation:"
echo "  Start here: START_HERE.md"
echo "  Quick ref:  AGENT_QUICK_REF.md"
echo "  Full guide: AGENT_SERVERS_GUIDE.md"
echo ""
