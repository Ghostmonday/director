#!/bin/bash
# 🏗️ BUILDER AGENT - Code Implementation
# Reads tasks from roadmap, extracts legacy code, implements features

set -euo pipefail

TASK_ID="$1"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CONTEXT_DIR="$REPO_ROOT/automation/multi-agent/context"
LOGS_DIR="$REPO_ROOT/automation/multi-agent/logs"
AGENT_STATE="$CONTEXT_DIR/agent-state.json"
ROADMAP="$REPO_ROOT/EXECUTION_ROADMAP.md"
LEGACY_CODE="$REPO_ROOT/LEGACY_CODEBASE_REFERENCE.txt"

LOG_FILE="$LOGS_DIR/builder-$TASK_ID.log"

# ============================================================================
# LOGGING
# ============================================================================

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [BUILDER] [$level] $message" | tee -a "$LOG_FILE"
}

# ============================================================================
# TASK EXTRACTION
# ============================================================================

get_task_details() {
    log "INFO" "📋 Extracting task $TASK_ID details from roadmap"
    
    # Use separate Python script to parse task details
    python3 "$(dirname "$0")/parse-task.py" "$ROADMAP" "$TASK_ID"
}

# Source task details (capture only variable assignments)
eval "$(get_task_details | grep -E '^[A-Z_]+=')"

log "INFO" "📝 Task: $TASK_NAME"
log "INFO" "📄 File: $FILE_NAME"

# ============================================================================
# LEGACY CODE EXTRACTION
# ============================================================================

extract_legacy_code() {
    if [[ -n "${LEGACY_START:-}" ]] && [[ -n "${LEGACY_END:-}" ]]; then
        log "INFO" "📚 Extracting legacy code lines $LEGACY_START-$LEGACY_END"
        
        sed -n "${LEGACY_START},${LEGACY_END}p" "$LEGACY_CODE" > "$CONTEXT_DIR/legacy-ref-$TASK_ID.swift"
        
        log "INFO" "✅ Legacy code extracted to context/legacy-ref-$TASK_ID.swift"
        
        # Show preview
        log "INFO" "Preview (first 10 lines):"
        head -n 10 "$CONTEXT_DIR/legacy-ref-$TASK_ID.swift" | tee -a "$LOG_FILE"
    else
        log "WARN" "⚠️  No legacy code references found for this task"
    fi
}

# ============================================================================
# STATE UPDATES
# ============================================================================

update_builder_progress() {
    # Simple progress update
    jq ".builder.progress = $1" "$AGENT_STATE" > "$AGENT_STATE.tmp" && mv "$AGENT_STATE.tmp" "$AGENT_STATE"
}

# ============================================================================
# CODE IMPLEMENTATION
# ============================================================================

implement_task() {
    log "INFO" "🏗️  Implementing task $TASK_ID"
    
    # Check API key
    if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
        log "ERROR" "❌ ANTHROPIC_API_KEY not set"
        mark_builder_failed "Missing API key"
        return 1
    fi
    
    # Update progress
    update_builder_progress 10
    
    # Create implementation prompt for AI
    cat > "$CONTEXT_DIR/builder-prompt-$TASK_ID.md" << EOF
# Task Implementation Request

## Task ID: $TASK_ID
## Task Name: $TASK_NAME
## Target File: $FILE_NAME

## Requirements
EOF

    # Add fidelity reminder if present
    if [[ "${FIDELITY:-false}" == "true" ]]; then
        cat >> "$CONTEXT_DIR/builder-prompt-$TASK_ID.md" << EOF

🎯 **FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

EOF
    fi

    # Add legacy code reference if available
    if [[ -f "$CONTEXT_DIR/legacy-ref-$TASK_ID.swift" ]]; then
        cat >> "$CONTEXT_DIR/builder-prompt-$TASK_ID.md" << EOF

## Legacy Code Reference
\`\`\`swift
$(cat "$CONTEXT_DIR/legacy-ref-$TASK_ID.swift")
\`\`\`

EOF
    fi

    # Add task-specific instructions from roadmap
    cat >> "$CONTEXT_DIR/builder-prompt-$TASK_ID.md" << EOF

## Instructions from Roadmap
Please implement this task following the guidelines in EXECUTION_ROADMAP.md.

Focus on:
1. Creating/updating the file: $FILE_NAME
2. Following the legacy code patterns (if provided)
3. Maintaining full fidelity with original implementation
4. Ensuring code compiles without errors
5. Adding proper error handling

## Output Requirements
- Create/update: $REPO_ROOT/$FILE_NAME
- Ensure code compiles
- Follow Swift best practices
- Add inline comments for complex logic
- Preserve all functionality from legacy code

## Ready for Implementation
Cursor/Claude: Please implement this task now.
EOF

    log "INFO" "📝 Implementation prompt ready at context/builder-prompt-$TASK_ID.md"
    
    # Update progress
    update_builder_progress 50
    
    # ========================================================================
    # AUTOMATED IMPLEMENTATION VIA CLAUDE API
    # ========================================================================
    
    # Read prompt content
    if [[ ! -f "$CONTEXT_DIR/builder-prompt-$TASK_ID.md" ]]; then
        log "ERROR" "❌ Prompt file not found"
        mark_builder_failed "Missing prompt"
        return 1
    fi
    
    local prompt_content=$(cat "$CONTEXT_DIR/builder-prompt-$TASK_ID.md")
    
    # Escape for JSON (properly)
    local escaped_prompt=$(echo "$prompt_content" | jq -Rs .)
    
    # Simple API call - no retry for speed
    log "INFO" "Calling Claude API..."
    
    local response=$(curl -s -X POST https://api.anthropic.com/v1/messages \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d '{
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 4000,
            "messages": [{"role": "user", "content": '"$escaped_prompt"'}]
        }')
    
    local code_content=$(echo "$response" | jq -r '.content[0].text' 2>/dev/null || echo "")
    
    if [[ -n "$code_content" ]] && [[ "$code_content" != "null" ]]; then
        # Extract code if in markdown
        if echo "$code_content" | grep -q '```swift'; then
            code_content=$(echo "$code_content" | sed -n '/```swift/,/```/p' | sed '1d;$d')
        fi
        
        # Write file
        echo "$code_content" > "$REPO_ROOT/$FILE_NAME"
        log "INFO" "✅ Code written to $FILE_NAME"
        
        # Mark complete
        touch "$CONTEXT_DIR/builder-complete-$TASK_ID.marker"
        return 0
    else
        log "ERROR" "❌ API call failed"
        mark_builder_failed "API failure"
        return 1
    fi
}

# ============================================================================
# COMPLETION
# ============================================================================

mark_builder_complete() {
    log "INFO" "✅ Builder completed task $TASK_ID"
    jq '.builder.status = "completed"' "$AGENT_STATE" > "$AGENT_STATE.tmp" && mv "$AGENT_STATE.tmp" "$AGENT_STATE"
    touch "$CONTEXT_DIR/builder-done-$TASK_ID.marker"
}

mark_builder_failed() {
    local reason="$1"
    log "ERROR" "❌ Builder failed task $TASK_ID: $reason"
    jq '.builder.status = "failed"' "$AGENT_STATE" > "$AGENT_STATE.tmp" && mv "$AGENT_STATE.tmp" "$AGENT_STATE"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    log "INFO" "🏗️  Builder Agent starting for task $TASK_ID"
    
    # Extract legacy code references
    extract_legacy_code
    
    # Implement task
    if implement_task; then
        mark_builder_complete
        exit 0
    else
        mark_builder_failed "Implementation failed"
        exit 1
    fi
}

main
