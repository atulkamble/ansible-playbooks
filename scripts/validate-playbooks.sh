#!/bin/bash
# Ansible Playbook Validation Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PLAYBOOK_DIR="$PROJECT_ROOT/playbooks"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TOTAL_PLAYBOOKS=0
PASSED_PLAYBOOKS=0
FAILED_PLAYBOOKS=0

echo "======================================"
echo "Ansible Playbook Validation Script"
echo "======================================"
echo ""

# Check if ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}ERROR: ansible-playbook command not found${NC}"
    echo "Please install Ansible first:"
    echo "  - macOS: brew install ansible"
    echo "  - Linux: pip install ansible"
    exit 1
fi

echo -e "${GREEN}✓${NC} Ansible is installed"
ansible --version | head -n 1
echo ""

# Check if ansible-lint is installed
if command -v ansible-lint &> /dev/null; then
    LINT_AVAILABLE=true
    echo -e "${GREEN}✓${NC} ansible-lint is available"
else
    LINT_AVAILABLE=false
    echo -e "${YELLOW}⚠${NC} ansible-lint not found (optional but recommended)"
    echo "  Install with: pip install ansible-lint"
fi
echo ""

# Function to validate a single playbook
validate_playbook() {
    local playbook=$1
    local playbook_name=$(basename "$playbook")
    
    echo "----------------------------------------"
    echo "Validating: $playbook_name"
    echo "----------------------------------------"
    
    TOTAL_PLAYBOOKS=$((TOTAL_PLAYBOOKS + 1))
    local validation_passed=true
    
    # Syntax check
    echo -n "  Syntax check... "
    if ansible-playbook --syntax-check "$playbook" &> /tmp/ansible-syntax-check.log; then
        echo -e "${GREEN}PASSED${NC}"
    else
        echo -e "${RED}FAILED${NC}"
        cat /tmp/ansible-syntax-check.log
        validation_passed=false
    fi
    
    # Lint check (if available)
    if [ "$LINT_AVAILABLE" = true ]; then
        echo -n "  Lint check... "
        if ansible-lint "$playbook" &> /tmp/ansible-lint-check.log; then
            echo -e "${GREEN}PASSED${NC}"
        else
            echo -e "${YELLOW}WARNINGS${NC}"
            cat /tmp/ansible-lint-check.log | head -n 20
        fi
    fi
    
    # Dry run check
    echo -n "  Dry run check... "
    if ansible-playbook --check "$playbook" -i "$PROJECT_ROOT/inventory/hosts" &> /tmp/ansible-dryrun.log 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
    else
        # Some errors are acceptable in dry run (like connection errors)
        if grep -q "UNREACHABLE\|Authentication" /tmp/ansible-dryrun.log; then
            echo -e "${YELLOW}SKIPPED (No hosts available)${NC}"
        else
            echo -e "${YELLOW}WARNINGS${NC}"
            cat /tmp/ansible-dryrun.log | tail -n 10
        fi
    fi
    
    if [ "$validation_passed" = true ]; then
        PASSED_PLAYBOOKS=$((PASSED_PLAYBOOKS + 1))
        echo -e "${GREEN}✓ Overall: PASSED${NC}"
    else
        FAILED_PLAYBOOKS=$((FAILED_PLAYBOOKS + 1))
        echo -e "${RED}✗ Overall: FAILED${NC}"
    fi
    
    echo ""
}

# Find and validate all playbooks
echo "Searching for playbooks in: $PLAYBOOK_DIR"
echo ""

if [ ! -d "$PLAYBOOK_DIR" ]; then
    echo -e "${RED}ERROR: Playbook directory not found: $PLAYBOOK_DIR${NC}"
    exit 1
fi

# Validate playbooks by category
for category in basic intermediate advanced; do
    if [ -d "$PLAYBOOK_DIR/$category" ]; then
        echo "======================================"
        echo "Category: $(echo $category | tr '[:lower:]' '[:upper:]')"
        echo "======================================"
        echo ""
        
        for playbook in "$PLAYBOOK_DIR/$category"/*.yml; do
            if [ -f "$playbook" ]; then
                validate_playbook "$playbook"
            fi
        done
    fi
done

# Summary
echo "======================================"
echo "VALIDATION SUMMARY"
echo "======================================"
echo "Total playbooks: $TOTAL_PLAYBOOKS"
echo -e "${GREEN}Passed: $PASSED_PLAYBOOKS${NC}"
echo -e "${RED}Failed: $FAILED_PLAYBOOKS${NC}"
echo ""

if [ $FAILED_PLAYBOOKS -eq 0 ]; then
    echo -e "${GREEN}✓ All playbooks passed validation!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some playbooks failed validation${NC}"
    exit 1
fi
