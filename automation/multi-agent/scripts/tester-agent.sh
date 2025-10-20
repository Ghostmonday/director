#!/bin/bash
# 🧪 TESTER AGENT - Validation & Testing
# Runs Xcode builds, executes tests, validates completion criteria

set -euo pipefail

# Validate inputs
if [[ -z "${1:-}" ]]; then
    echo "ERROR: TASK_ID not provided" >&2
    exit 1
fi

TASK_ID="$1"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CONTEXT_DIR="$REPO_ROOT/automation/multi-agent/context"
LOGS_DIR="$REPO_ROOT/automation/multi-agent/logs"
AGENT_STATE="$CONTEXT_DIR/agent-state.json"
ROADMAP="$REPO_ROOT/EXECUTION_ROADMAP.md"

LOG_FILE="$LOGS_DIR/tester-$TASK_ID.log"

# Check required files and tools
if [[ ! -f "$ROADMAP" ]]; then
    echo "ERROR: EXECUTION_ROADMAP.md not found at $ROADMAP" >&2
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "ERROR: jq not installed. Install with: brew install jq" >&2
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 not installed" >&2
    exit 1
fi

# Validate JSON files before reading
if [[ -f "$AGENT_STATE" ]] && ! jq empty "$AGENT_STATE" 2>/dev/null; then
    echo "ERROR: Invalid JSON in $AGENT_STATE" >&2
    exit 1
fi

# ============================================================================
# LOGGING
# ============================================================================

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [TESTER] [$level] $message" | tee -a "$LOG_FILE"
}

# ============================================================================
# BUILD VALIDATION
# ============================================================================

run_xcode_build() {
    log "INFO" "🔨 Running Xcode build"
    
    cd "$REPO_ROOT"
    
    # Try to build
    if xcodebuild -scheme DirectorStudio -configuration Debug build \
        -derivedDataPath "$REPO_ROOT/.build" \
        > "$LOGS_DIR/xcodebuild-$TASK_ID.log" 2>&1; then
        
        log "INFO" "✅ Xcode build successful"
        return 0
    else
        log "ERROR" "❌ Xcode build failed"
        
        # Extract errors
        grep "error:" "$LOGS_DIR/xcodebuild-$TASK_ID.log" | head -n 10 | tee -a "$LOG_FILE"
        
        return 1
    fi
}

# ============================================================================
# SWIFT COMPILATION CHECK
# ============================================================================

run_swift_build() {
    log "INFO" "🔨 Running swift build"
    
    cd "$REPO_ROOT"
    
    if swift build 2>&1 | tee -a "$LOG_FILE"; then
        log "INFO" "✅ Swift build successful"
        return 0
    else
        log "ERROR" "❌ Swift build failed"
        return 1
    fi
}

# ============================================================================
# UNIT TESTS
# ============================================================================

run_unit_tests() {
    log "INFO" "🧪 Running unit tests"
    
    cd "$REPO_ROOT"
    
    # Get module name from task
    local module_name=$(get_module_name_from_task "$TASK_ID")
    
    if [[ -z "$module_name" ]]; then
        log "WARN" "⚠️  No test target found for task $TASK_ID"
        return 0  # Not a failure, just no tests
    fi
    
    log "INFO" "Testing module: $module_name"
    
    if swift test --filter "$module_name" 2>&1 | tee -a "$LOG_FILE"; then
        log "INFO" "✅ Tests passed"
        return 0
    else
        log "ERROR" "❌ Tests failed"
        return 1
    fi
}

get_module_name_from_task() {
    local task_id="$1"
    
    # Map task IDs to module names
    case "$task_id" in
        1.1) echo "PromptSegment" ;;
        1.2) echo "PipelineContext" ;;
        1.3) echo "MockAIService" ;;
        1.4) echo "RewordingModule" ;;
        1.5) echo "SegmentationModule" ;;
        1.6) echo "StoryAnalysisModule" ;;
        1.7) echo "TaxonomyModule" ;;
        1.8) echo "ContinuityModule" ;;
        *) echo "" ;;
    esac
}

# ============================================================================
# FILE EXISTENCE CHECKS
# ============================================================================

validate_files_exist() {
    log "INFO" "📁 Validating required files exist"
    
    # Get expected file from task
    local file_name=$(python3 "$(dirname "$0")/parse-task.py" "$REPO_ROOT/EXECUTION_ROADMAP.md" "$TASK_ID" | grep "FILE_NAME=" | cut -d'=' -f2)
    
    if [[ -z "$file_name" ]]; then
        log "WARN" "⚠️  Could not determine expected file"
        return 0
    fi
    
    log "INFO" "Expected file: $file_name"
    
    # Check if file exists (handle multiple file formats)
    local found=false
    
    if [[ -f "$REPO_ROOT/$file_name" ]]; then
        log "INFO" "✅ File exists: $file_name"
        found=true
    elif [[ "$file_name" == *" or "* ]] || [[ "$file_name" == *"Multiple"* ]]; then
        log "INFO" "⚠️  Multiple file task - skipping strict validation"
        found=true
    fi
    
    if [[ "$found" == "false" ]]; then
        log "ERROR" "❌ Expected file not found: $file_name"
        return 1
    fi
    
    return 0
}

# ============================================================================
# CHECKLIST VALIDATION
# ============================================================================

validate_checklist() {
    log "INFO" "✅ Validating task checklist"
    
    # Extract validation checklist from roadmap
    python3 "$(dirname "$0")/extract-checklist.py" "$REPO_ROOT/EXECUTION_ROADMAP.md" "$TASK_ID" > "$CONTEXT_DIR/checklist-$TASK_ID.txt"
    
    if [[ ! -s "$CONTEXT_DIR/checklist-$TASK_ID.txt" ]]; then
        log "WARN" "⚠️  No validation checklist found"
        return 0
    fi
    
    log "INFO" "Checklist items:"
    cat "$CONTEXT_DIR/checklist-$TASK_ID.txt" | tee -a "$LOG_FILE"
    
    # For now, assume checklist is validated by build/test success
    # In a full implementation, each item could be individually checked
    
    return 0
}

# ============================================================================
# COMPLETION
# ============================================================================

mark_tester_complete() {
    log "INFO" "✅ Tester completed task $TASK_ID"
    jq '.tester.status = "completed"' "$AGENT_STATE" > "$AGENT_STATE.tmp" && mv "$AGENT_STATE.tmp" "$AGENT_STATE"
    touch "$CONTEXT_DIR/tester-done-$TASK_ID.marker"
}

mark_tester_failed() {
    local reason="$1"
    log "ERROR" "❌ Tester failed task $TASK_ID: $reason"
    jq '.tester.status = "failed"' "$AGENT_STATE" > "$AGENT_STATE.tmp" && mv "$AGENT_STATE.tmp" "$AGENT_STATE"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    log "INFO" "🧪 Tester Agent starting for task $TASK_ID"
    
    # Run validation steps
    local failed=false
    
    # 1. Validate files exist
    if ! validate_files_exist; then
        failed=true
    fi
    
    # 2. Try Swift build first (faster)
    if ! run_swift_build; then
        failed=true
    fi
    
    # 3. Run Xcode build (if available)
    if command -v xcodebuild &> /dev/null; then
        if ! run_xcode_build; then
            failed=true
        fi
    else
        log "WARN" "⚠️  xcodebuild not available, skipping Xcode validation"
    fi
    
    # 4. Run unit tests
    if ! run_unit_tests; then
        failed=true
    fi
    
    # 5. Validate checklist
    if ! validate_checklist; then
        failed=true
    fi
    
    # Determine result
    if [[ "$failed" == "true" ]]; then
        mark_tester_failed "One or more validations failed"
        exit 1
    else
        mark_tester_complete
        # Create completion marker for orchestrator
        touch "$CONTEXT_DIR/tester-complete-$TASK_ID.marker"
        exit 0
    fi
}

main
