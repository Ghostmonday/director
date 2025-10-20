#!/bin/bash
# 🧪 Regression Auto-Tester for DirectorStudio

set -e

# Configuration
TEST_MATRIX_LOG="automation/logs/test-matrix.md"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Module mapping function
get_module_for_file() {
    case "$1" in
        "core.swift") echo "CoreModule" ;;
        "rewording.swift") echo "RewordingModule" ;;
        "storyanalysis.swift") echo "StoryAnalysisModule" ;;
        "segmentation.swift") echo "SegmentationModule" ;;
        "taxonomy.swift") echo "TaxonomyModule" ;;
        "continuity.swift") echo "ContinuityModule" ;;
        *) echo "UnknownModule" ;;
    esac
}

# Test target mapping function
get_test_target() {
    case "$1" in
        "CoreModule") echo "CoreModuleTests" ;;
        "RewordingModule") echo "RewordingModuleTests" ;;
        "StoryAnalysisModule") echo "StoryAnalysisModuleTests" ;;
        "SegmentationModule") echo "SegmentationModuleTests" ;;
        "TaxonomyModule") echo "TaxonomyModuleTests" ;;
        "ContinuityModule") echo "ContinuityModuleTests" ;;
        *) echo "$1" ;;
    esac
}

# Logging function
log_result() {
    local module="$1"
    local status="$2"
    local details="${3:-}"
    
    echo "## Test Result: $module" >> "$TEST_MATRIX_LOG"
    echo "- **Status:** $status" >> "$TEST_MATRIX_LOG"
    echo "- **Timestamp:** $TIMESTAMP" >> "$TEST_MATRIX_LOG"
    if [[ -n "$details" ]]; then
        echo "- **Details:**" >> "$TEST_MATRIX_LOG"
        echo '```' >> "$TEST_MATRIX_LOG"
        echo "$details" >> "$TEST_MATRIX_LOG"
        echo '```' >> "$TEST_MATRIX_LOG"
    fi
    echo "" >> "$TEST_MATRIX_LOG"
}

# Get changed files
get_changed_files() {
    git diff --name-only main...HEAD | grep '\.swift$' || true
}

# Determine module for a file (wrapper)
get_module_for_file_path() {
    local file="$1"
    local filename=$(basename "$file")
    get_module_for_file "$filename"
}

# Run tests for a specific module
run_module_tests() {
    local module="$1"
    local test_target=$(get_test_target "$module")
    
    echo "🧪 Testing $module (Target: $test_target)"
    
    # Capture test output
    local test_output
    if ! test_output=$(swift test --filter "$test_target" 2>&1); then
        log_result "$module" "❌ Failed" "$test_output"
        return 1
    else
        log_result "$module" "✅ Passed" "$test_output"
        return 0
    fi
}

# Main function
main() {
    # Prepare test matrix log
    echo "# 🧪 Test Matrix Log" > "$TEST_MATRIX_LOG"
    echo "" >> "$TEST_MATRIX_LOG"
    echo "**Regression Test Run**" >> "$TEST_MATRIX_LOG"
    echo "- **Timestamp:** $TIMESTAMP" >> "$TEST_MATRIX_LOG"
    echo "- **Mode:** $*" >> "$TEST_MATRIX_LOG"
    echo "" >> "$TEST_MATRIX_LOG"
    
    # Parse arguments
    local test_all=false
    local test_changed=false
    local specific_module=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                test_all=true
                ;;
            --changed)
                test_changed=true
                ;;
            --module)
                shift
                specific_module="$1"
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
        shift
    done
    
    # Determine test scope
    local modules_to_test=()
    
    if [[ "$specific_module" ]]; then
        modules_to_test=("$specific_module")
    elif [[ "$test_all" == true ]]; then
        modules_to_test=("CoreModule" "RewordingModule" "StoryAnalysisModule" "SegmentationModule" "TaxonomyModule" "ContinuityModule")
    elif [[ "$test_changed" == true ]]; then
        changed_files=$(get_changed_files)
        if [[ -z "$changed_files" ]]; then
            echo "🟡 No changed Swift files detected."
            exit 0
        fi
        
        # Get unique modules from changed files
        modules_to_test=()
        for file in $changed_files; do
            module=$(get_module_for_file_path "$file")
            # Check if module already in list
            found=false
            for existing in "${modules_to_test[@]}"; do
                if [[ "$existing" == "$module" ]]; then
                    found=true
                    break
                fi
            done
            if [[ "$found" == false ]]; then
                modules_to_test=("${modules_to_test[@]}" "$module")
            fi
        done
    else
        echo "Usage: $0 [--all|--changed|--module <ModuleName>]"
        exit 1
    fi
    
    # Run tests
    local failed=0
    for module in "${modules_to_test[@]}"; do
        if ! run_module_tests "$module"; then
            failed=$((failed + 1))
        fi
    done
    
    # Final summary
    echo "" >> "$TEST_MATRIX_LOG"
    echo "## Test Summary" >> "$TEST_MATRIX_LOG"
    echo "- **Total Modules Tested:** ${#modules_to_test[@]}" >> "$TEST_MATRIX_LOG"
    echo "- **Failed Modules:** $failed" >> "$TEST_MATRIX_LOG"
    
    # Exit with error if any tests failed
    if [[ $failed -gt 0 ]]; then
        echo "❌ $failed module(s) failed testing"
        exit 1
    fi
    
    echo "✅ All tests passed successfully"
}

# Run the main function with all arguments
main "$@"
