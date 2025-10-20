#!/bin/bash
#
# DirectorStudio Build Script
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

# Clean build
clean_build() {
    log_info "Cleaning build artifacts..."
    swift package clean
    log_success "Clean completed"
}

# Build project
build_project() {
    log_info "Building DirectorStudio..."
    
    if swift build; then
        log_success "Build successful!"
    else
        log_error "Build failed"
        exit 1
    fi
}

# Build with tests
build_with_tests() {
    log_info "Building DirectorStudio with tests..."
    
    if swift build --build-tests; then
        log_success "Build with tests successful!"
    else
        log_error "Build with tests failed"
        exit 1
    fi
}

# Run tests
run_tests() {
    log_info "Running tests..."
    
    if swift test; then
        log_success "All tests passed!"
    else
        log_error "Tests failed"
        exit 1
    fi
}

# Main function
main() {
    case "${1:-build}" in
        clean)
            clean_build
            ;;
        build)
            build_project
            ;;
        test)
            build_with_tests
            run_tests
            ;;
        all)
            clean_build
            build_with_tests
            run_tests
            ;;
        *)
            echo "Usage: $0 {clean|build|test|all}"
            exit 1
            ;;
    esac
}

main "$@"
