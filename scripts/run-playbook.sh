#!/bin/bash
# Ansible Playbook Runner with Options

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
INVENTORY="${PROJECT_ROOT}/inventory/hosts"
CHECK_MODE=false
VERBOSE=""
EXTRA_VARS=""
TAGS=""
SKIP_TAGS=""

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] PLAYBOOK

Run Ansible playbooks with common options.

OPTIONS:
    -i, --inventory FILE    Inventory file (default: inventory/hosts)
    -c, --check            Run in check mode (dry run)
    -v, --verbose          Verbose output (-v, -vv, -vvv)
    -e, --extra-vars VARS  Set additional variables
    -t, --tags TAGS        Only run plays and tasks tagged with these values
    --skip-tags TAGS       Only run plays and tasks whose tags do not match
    -l, --limit HOSTS      Further limit selected hosts to an additional pattern
    -h, --help             Show this help message

EXAMPLES:
    # Run basic system update
    $(basename "$0") playbooks/basic/01-system-update.yml

    # Run in check mode (dry run)
    $(basename "$0") -c playbooks/basic/01-system-update.yml

    # Run with verbose output
    $(basename "$0") -vv playbooks/intermediate/01-apache-webserver.yml

    # Run with extra variables
    $(basename "$0") -e "domain_name=example.com" playbooks/intermediate/01-apache-webserver.yml

    # Run specific tags only
    $(basename "$0") -t configuration playbooks/advanced/03-monitoring-stack.yml

    # Run on specific hosts
    $(basename "$0") -l webservers playbooks/basic/01-system-update.yml

EOF
}

# Parse arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--inventory)
            INVENTORY="$2"
            shift 2
            ;;
        -c|--check)
            CHECK_MODE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -vv)
            VERBOSE="-vv"
            shift
            ;;
        -vvv)
            VERBOSE="-vvv"
            shift
            ;;
        -e|--extra-vars)
            EXTRA_VARS="--extra-vars $2"
            shift 2
            ;;
        -t|--tags)
            TAGS="--tags $2"
            shift 2
            ;;
        --skip-tags)
            SKIP_TAGS="--skip-tags $2"
            shift 2
            ;;
        -l|--limit)
            LIMIT="--limit $2"
            shift 2
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Restore positional parameters
set -- "${POSITIONAL_ARGS[@]}"

# Check if playbook is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}ERROR: No playbook specified${NC}"
    echo ""
    show_help
    exit 1
fi

PLAYBOOK="$1"

# Check if playbook exists
if [ ! -f "$PLAYBOOK" ]; then
    echo -e "${RED}ERROR: Playbook not found: $PLAYBOOK${NC}"
    exit 1
fi

# Check if inventory exists
if [ ! -f "$INVENTORY" ]; then
    echo -e "${YELLOW}WARNING: Inventory file not found: $INVENTORY${NC}"
fi

# Build ansible-playbook command
CMD="ansible-playbook"
CMD="$CMD -i $INVENTORY"
CMD="$CMD $VERBOSE"
CMD="$CMD $EXTRA_VARS"
CMD="$CMD $TAGS"
CMD="$CMD $SKIP_TAGS"
CMD="$CMD $LIMIT"

if [ "$CHECK_MODE" = true ]; then
    CMD="$CMD --check"
fi

CMD="$CMD $PLAYBOOK"

# Display information
echo -e "${BLUE}======================================"
echo "Ansible Playbook Runner"
echo -e "======================================${NC}"
echo "Playbook: $(basename $PLAYBOOK)"
echo "Inventory: $INVENTORY"
echo "Check Mode: $CHECK_MODE"
echo ""

# Run the playbook
echo -e "${GREEN}Running playbook...${NC}"
echo "Command: $CMD"
echo ""

eval $CMD
EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Playbook completed successfully${NC}"
else
    echo -e "${RED}✗ Playbook failed with exit code: $EXIT_CODE${NC}"
fi

exit $EXIT_CODE
