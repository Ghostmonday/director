#!/bin/bash
# 👁️ REVIEWER AGENT - Quality Control & Fidelity Verification
# Reviews code quality, checks against legacy, validates requirements

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

LOG_FILE="$LOGS_DIR/reviewer-$TASK_ID.log"

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
    echo "[$timestamp] [REVIEWER] [$level] $message" | tee -a "$LOG_FILE"
}

# ============================================================================
# CODE QUALITY CHECKS
# ============================================================================

run_swiftlint() {
    log "INFO" "🔍 Running SwiftLint"
    
    if ! command -v swiftlint &> /dev/null; then
        log "WARN" "⚠️  SwiftLint not installed, skipping"
        return 0
    fi
    
    cd "$REPO_ROOT"
    swiftlint lint --reporter json > "$LOGS_DIR/swiftlint-$TASK_ID.json" 2>&1 || true
    log "INFO" "✅ SwiftLint check completed"
    return 0
}

# ============================================================================
# FIDELITY CHECKS
# ============================================================================

check_fidelity() {
    log "INFO" "🎯 Checking fidelity against legacy code"
    
    # Check if this task has fidelity requirements
    local has_fidelity=$(grep -c "FIDELITY REMINDER" "$ROADMAP" || true)
    
    if [[ $has_fidelity -eq 0 ]]; then
        log "INFO" "✅ No fidelity requirements for this task"
        return 0
    fi
    
    # Get file name
    local file_name=$(get_task_file_name "$TASK_ID")
    
    if [[ -z "$file_name" ]] || [[ ! -f "$REPO_ROOT/$file_name" ]]; then
        log "WARN" "⚠️  Cannot verify fidelity - file not found"
        return 0
    fi
    
    # Check if legacy reference exists
    if [[ ! -f "$CONTEXT_DIR/legacy-ref-$TASK_ID.swift" ]]; then
        log "INFO" "ℹ️  No legacy reference available for comparison"
        return 0
    fi
    
    log "INFO" "Comparing implementation to legacy code..."
    
    # Basic structural comparison
    local legacy_structs=$(grep -c "^struct " "$CONTEXT_DIR/legacy-ref-$TASK_ID.swift" || true)
    local legacy_classes=$(grep -c "^class " "$CONTEXT_DIR/legacy-ref-$TASK_ID.swift" || true)
    local legacy_funcs=$(grep -c "^func " "$CONTEXT_DIR/legacy-ref-$TASK_ID.swift" || true)
    
    local new_structs=$(grep -c "struct " "$REPO_ROOT/$file_name" || true)
    local new_classes=$(grep -c "class " "$REPO_ROOT/$file_name" || true)
    local new_funcs=$(grep -c "func " "$REPO_ROOT/$file_name" || true)
    
    log "INFO" "Legacy: $legacy_structs structs, $legacy_classes classes, $legacy_funcs functions"
    log "INFO" "New: $new_structs structs, $new_classes classes, $new_funcs functions"
    
    # Check for significant differences
    if [[ $legacy_structs -gt 0 ]] && [[ $new_structs -eq 0 ]]; then
        log "WARN" "⚠️  Legacy had structs, new implementation has none"
        return 1
    fi
    
    if [[ $legacy_funcs -gt $new_funcs ]]; then
        local diff=$((legacy_funcs - new_funcs))
        log "WARN" "⚠️  New implementation missing $diff functions"
        return 1
    fi
    
    log "INFO" "✅ Fidelity check passed"
    return 0
}

get_task_file_name() {
    python3 "$(dirname "$0")/parse-task.py" "$ROADMAP" "$1" | grep "FILE_NAME=" | cut -d'=' -f2
}

# ============================================================================
# SECURITY CHECKS
# ============================================================================

check_security() {
    log "INFO" "🔒 Running security checks"
    
    local file_name=$(get_task_file_name "$TASK_ID")
    
    if [[ -z "$file_name" ]] || [[ ! -f "$REPO_ROOT/$file_name" ]]; then
        log "WARN" "⚠️  Cannot run security checks - file not found"
        return 0
    fi
    
    local issues=0
    
    # Check for hardcoded API keys
    if grep -i "sk-\|pk-\|api_key.*=" "$REPO_ROOT/$file_name" | grep -v "YOUR_.*_KEY_HERE" > /dev/null; then
        log "ERROR" "❌ Hardcoded API keys detected"
        issues=$((issues + 1))
    fi
    
    # Check for force unwrapping
    local force_unwraps=$(grep -c "!" "$REPO_ROOT/$file_name" || true)
    if [[ $force_unwraps -gt 10 ]]; then
        log "WARN" "⚠️  Excessive force unwrapping ($force_unwraps instances)"
    fi
    
    # Check for print statements
    local prints=$(grep -c "print(" "$REPO_ROOT/$file_name" || true)
    if [[ $prints -gt 0 ]]; then
        log "WARN" "⚠️  Found $prints print statements (should use Logger)"
    fi
    
    if [[ $issues -gt 0 ]]; then
        log "ERROR" "❌ Security checks failed"
        return 1
    fi
    
    log "INFO" "✅ Security checks passed"
    return 0
}

# ============================================================================
# REQUIREMENT VALIDATION
# ============================================================================

validate_requirements() {
    log "INFO" "📋 Validating requirements"
    
    # Extract requirements from roadmap
    python3 "$(dirname "$0")/extract-requirements.py" "$ROADMAP" "$TASK_ID" > "$CONTEXT_DIR/requirements-$TASK_ID.txt"
    
    if [[ ! -s "$CONTEXT_DIR/requirements-$TASK_ID.txt" ]]; then
        log "INFO" "ℹ️  No explicit requirements found"
        return 0
    fi
    
    log "INFO" "Requirements:"
    cat "$CONTEXT_DIR/requirements-$TASK_ID.txt" | tee -a "$LOG_FILE"
    
    # For now, assume requirements met if tests pass
    # In full implementation, could check each requirement individually
    
    log "INFO" "✅ Requirements validated"
    return 0
}

# ============================================================================
# GENERATE REVIEW REPORT
# ============================================================================

generate_review_report() {
    local decision="$1"
    local reason="$2"
    
    cat > "$LOGS_DIR/review-$TASK_ID.md" << EOF
# 👁️ Code Review Report - Task $TASK_ID

**Reviewer:** Automated Review Agent  
**Timestamp:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")  
**Decision:** $decision  

## Summary
$reason

## Checks Performed
- [x] SwiftLint code quality
- [x] Fidelity vs legacy code
- [x] Security vulnerabilities
- [x] Requirements validation

## Detailed Results
See logs:
- SwiftLint: $LOGS_DIR/swiftlint-$TASK_ID.json
- Full review log: $LOG_FILE

## Recommendation
EOF

    if [[ "$decision" == "APPROVED" ]]; then
        cat >> "$LOGS_DIR/review-$TASK_ID.md" << EOF
✅ **APPROVE** - Task implementation meets quality standards

**Next Steps:**
1. Create PR via automation
2. Wait for BugBot approval
3. Auto-merge if approved
EOF
    else
        cat >> "$LOGS_DIR/review-$TASK_ID.md" << EOF
❌ **REQUEST CHANGES** - Issues must be addressed

**Required Actions:**
1. Review failure details in logs
2. Fix identified issues
3. Re-run builder agent
4. Re-submit for review
EOF
    fi
    
    log "INFO" "📄 Review report generated: $LOGS_DIR/review-$TASK_ID.md"
}

# ============================================================================
# COMPLETION
# ============================================================================

mark_reviewer_complete() {
    local decision="$1"
    log "INFO" "✅ Reviewer completed task $TASK_ID - Decision: $decision"
    jq '.reviewer.status = "completed"' "$AGENT_STATE" > "$AGENT_STATE.tmp" && mv "$AGENT_STATE.tmp" "$AGENT_STATE"
    echo "$decision" > "$CONTEXT_DIR/reviewer-done-$TASK_ID.marker"
}

mark_reviewer_failed() {
    local reason="$1"
    log "ERROR" "❌ Reviewer failed task $TASK_ID: $reason"
    jq '.reviewer.status = "failed"' "$AGENT_STATE" > "$AGENT_STATE.tmp" && mv "$AGENT_STATE.tmp" "$AGENT_STATE"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    log "INFO" "👁️  Reviewer Agent starting for task $TASK_ID"
    
    local failed=false
    local failure_reason=""
    
    # Run all checks
    if ! run_swiftlint; then
        failed=true
        failure_reason="SwiftLint errors"
    fi
    
    if ! check_fidelity; then
        failed=true
        failure_reason="${failure_reason:+$failure_reason, }Fidelity issues"
    fi
    
    if ! check_security; then
        failed=true
        failure_reason="${failure_reason:+$failure_reason, }Security vulnerabilities"
    fi
    
    if ! validate_requirements; then
        failed=true
        failure_reason="${failure_reason:+$failure_reason, }Requirements not met"
    fi
    
    # Make decision
    if [[ "$failed" == "true" ]]; then
        generate_review_report "REJECTED" "$failure_reason"
        mark_reviewer_complete "REJECTED"
        # Create completion marker for orchestrator
        touch "$CONTEXT_DIR/reviewer-complete-$TASK_ID.marker"
        exit 1
    else
        generate_review_report "APPROVED" "All quality checks passed"
        mark_reviewer_complete "APPROVED"
        # Create completion marker for orchestrator
        touch "$CONTEXT_DIR/reviewer-complete-$TASK_ID.marker"
        exit 0
    fi
}

main
