#!/bin/bash
# List all available Ansible playbooks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PLAYBOOK_DIR="$PROJECT_ROOT/playbooks"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}======================================"
echo "Available Ansible Playbooks"
echo -e "======================================${NC}"
echo ""

list_playbooks() {
    local category=$1
    local category_upper=$(echo $category | tr '[:lower:]' '[:upper:]')
    
    if [ -d "$PLAYBOOK_DIR/$category" ]; then
        echo -e "${GREEN}$category_upper PLAYBOOKS:${NC}"
        echo ""
        
        for playbook in "$PLAYBOOK_DIR/$category"/*.yml; do
            if [ -f "$playbook" ]; then
                local name=$(basename "$playbook" .yml)
                local description=$(grep -m 1 "name:" "$playbook" | sed 's/.*name: //' | sed 's/^[ \t]*//')
                
                echo -e "  ${YELLOW}$name${NC}"
                echo -e "    Description: $description"
                echo -e "    Path: playbooks/$category/$(basename $playbook)"
                echo -e "    Run: ./scripts/run-playbook.sh playbooks/$category/$(basename $playbook)"
                echo ""
            fi
        done
    fi
}

# List playbooks by category
list_playbooks "basic"
list_playbooks "intermediate"
list_playbooks "advanced"

echo -e "${BLUE}======================================"
echo "Quick Start Commands"
echo -e "======================================${NC}"
echo ""
echo "1. Validate all playbooks:"
echo "   ./scripts/validate-playbooks.sh"
echo ""
echo "2. Run a playbook (dry run):"
echo "   ./scripts/run-playbook.sh -c playbooks/basic/01-system-update.yml"
echo ""
echo "3. Run a playbook (actual):"
echo "   ./scripts/run-playbook.sh playbooks/basic/01-system-update.yml"
echo ""
echo "4. Get help:"
echo "   ./scripts/run-playbook.sh --help"
echo ""
