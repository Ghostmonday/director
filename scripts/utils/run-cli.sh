#!/bin/bash
#
# DirectorStudio CLI Runner
#

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Run CLI with arguments
run_cli() {
    log_info "Running DirectorStudio CLI..."
    
    if swift run DirectorStudioCLI "$@"; then
        log_success "CLI execution completed successfully!"
    else
        log_error "CLI execution failed"
        exit 1
    fi
}

# Main function
main() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 [CLI arguments]"
        echo "Example: $0 --input \"Your story text\" --output output.mp4"
        exit 1
    fi
    
    run_cli "$@"
}

main "$@"
