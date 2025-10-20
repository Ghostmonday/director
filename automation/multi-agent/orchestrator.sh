#!/bin/bash
# 🎯 MULTI-AGENT ORCHESTRATOR - Master Control System
# Coordinates Builder, Tester, and Reviewer agents for DirectorStudio reconstruction

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONTEXT_DIR="$REPO_ROOT/automation/multi-agent/context"
SCRIPTS_DIR="$REPO_ROOT/automation/multi-agent/scripts"
LOGS_DIR="$REPO_ROOT/automation/multi-agent/logs"

ROADMAP="$REPO_ROOT/EXECUTION_ROADMAP.md"
AGENT_STATE="$CONTEXT_DIR/agent-state.json"
TASK_QUEUE="$CONTEXT_DIR/task-queue.json"
RESULTS_LOG="$CONTEXT_DIR/results-log.json"
ORCHESTRATOR_LOG="$LOGS_DIR/orchestrator.log"

# Timeouts (in seconds)
BUILDER_TIMEOUT=7200  # 2 hours per task
TESTER_TIMEOUT=1800   # 30 minutes
REVIEWER_TIMEOUT=900  # 15 minutes

# Max retries before escalation
MAX_RETRIES=3

# ============================================================================
# INITIALIZATION
# ============================================================================

init_orchestrator() {
    log "INFO" "🚀 Initializing Multi-Agent Orchestrator"
    
    # Check required files and tools
    if [[ ! -f "$ROADMAP" ]]; then
        log "ERROR" "EXECUTION_ROADMAP.md not found at $ROADMAP"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log "ERROR" "jq not installed. Install with: brew install jq"
        exit 1
    fi
    
    if ! command -v python3 &> /dev/null; then
        log "ERROR" "python3 not installed"
        exit 1
    fi
    
    # Create directories
    mkdir -p "$CONTEXT_DIR" "$LOGS_DIR"
    
    # Initialize agent state
    cat > "$AGENT_STATE" << 'EOF'
{
  "orchestrator": {
    "status": "initializing",
    "current_stage": 1,
    "current_task": "1.1",
    "started_at": null,
    "last_heartbeat": null
  },
  "builder": {
    "status": "idle",
    "current_task": null,
    "started_at": null,
    "progress": 0,
    "last_output": null
  },
  "tester": {
    "status": "idle",
    "current_task": null,
    "started_at": null,
    "last_result": null
  },
  "reviewer": {
    "status": "idle",
    "current_task": null,
    "started_at": null,
    "last_decision": null
  }
}
EOF

    # Initialize task queue
    parse_roadmap_to_queue
    
    # Initialize results log
    echo '{"tasks": []}' > "$RESULTS_LOG"
    
    log "INFO" "✅ Orchestrator initialized"
}

# ============================================================================
# LOGGING
# ============================================================================

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [$level] $message" | tee -a "$ORCHESTRATOR_LOG"
}

# ============================================================================
# ATOMIC STATE UPDATES
# ============================================================================

update_agent_state() {
    # Simple update - no locking for speed
    jq "$1" "$AGENT_STATE" > "$AGENT_STATE.tmp" && mv "$AGENT_STATE.tmp" "$AGENT_STATE"
}

# ============================================================================
# ROADMAP PARSING
# ============================================================================

parse_roadmap_to_queue() {
    log "INFO" "📋 Parsing EXECUTION_ROADMAP.md into task queue"
    
    # Use separate Python script to parse roadmap
    python3 "$SCRIPTS_DIR/parse-roadmap.py" "$ROADMAP" > "$TASK_QUEUE"
    
    log "INFO" "✅ Task queue generated"
}

# ============================================================================
# TASK ASSIGNMENT
# ============================================================================

get_next_task() {
    # Simple - just get first pending task
    jq -r '.tasks[] | select(.status == "pending") | .id' "$TASK_QUEUE" | head -1
}

assign_task_to_builder() {
    local task_id="$1"
    
    log "INFO" "📤 Assigning task $task_id to Builder Agent"
    
    # Update agent state atomically
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    update_agent_state ".builder.status = \"working\" | .builder.current_task = \"$task_id\" | .builder.started_at = \"$current_time\""
    
    # Update task queue atomically
    local lock_file="$TASK_QUEUE.lock"
    local max_wait=30
    local waited=0
    
    while [[ -f "$lock_file" ]] && [[ $waited -lt $max_wait ]]; do
        sleep 0.1
        waited=$((waited + 1))
    done
    
    if [[ $waited -lt $max_wait ]]; then
        touch "$lock_file"
        if jq --arg task "$task_id" \
               '(.tasks[] | select(.id == $task)) |= (.status = "in_progress" | .assigned_to = "builder")' \
               "$TASK_QUEUE" > "$TASK_QUEUE.tmp" && mv "$TASK_QUEUE.tmp" "$TASK_QUEUE"; then
            rm -f "$lock_file"
        else
            log "ERROR" "Failed to update task queue"
            rm -f "$lock_file" "$TASK_QUEUE.tmp"
            return 1
        fi
    fi
    
    # Trigger builder agent
    "$SCRIPTS_DIR/builder-agent.sh" "$task_id" &
    local builder_pid=$!
    
    echo "$builder_pid" > "$CONTEXT_DIR/builder.pid"
    
    log "INFO" "✅ Builder Agent started (PID: $builder_pid)"
}

# ============================================================================
# MONITORING
# ============================================================================

monitor_agents() {
    log "INFO" "👁️  Monitoring agent health"
    
    local builder_status=$(jq -r '.builder.status' "$AGENT_STATE")
    local tester_status=$(jq -r '.tester.status' "$AGENT_STATE")
    local reviewer_status=$(jq -r '.reviewer.status' "$AGENT_STATE")
    
    # Check builder timeout
    if [[ "$builder_status" == "working" ]]; then
        local builder_start=$(jq -r '.builder.started_at' "$AGENT_STATE")
        local elapsed=$(( $(date +%s) - $(date -d "$builder_start" +%s) ))
        
        if [[ $elapsed -gt $BUILDER_TIMEOUT ]]; then
            log "WARN" "⚠️  Builder Agent timeout (${elapsed}s > ${BUILDER_TIMEOUT}s)"
            handle_builder_timeout
        fi
    fi
    
    # Check tester timeout
    if [[ "$tester_status" == "testing" ]]; then
        local tester_start=$(jq -r '.tester.started_at' "$AGENT_STATE")
        local elapsed=$(( $(date +%s) - $(date -d "$tester_start" +%s) ))
        
        if [[ $elapsed -gt $TESTER_TIMEOUT ]]; then
            log "WARN" "⚠️  Tester Agent timeout"
            handle_tester_timeout
        fi
    fi
}

handle_builder_timeout() {
    log "ERROR" "❌ Builder Agent exceeded timeout - killing process"
    
    local task_id=$(jq -r '.builder.current_task' "$AGENT_STATE")
    
    # Kill builder process
    if [[ -f "$CONTEXT_DIR/builder.pid" ]]; then
        local pid=$(cat "$CONTEXT_DIR/builder.pid")
        kill -9 "$pid" 2>/dev/null || true
        rm "$CONTEXT_DIR/builder.pid"
    fi
    
    # Increment retry count
    local attempts=$(jq --arg task "$task_id" \
                        '(.tasks[] | select(.id == $task)).attempts' \
                        "$TASK_QUEUE")
    
    attempts=$((attempts + 1))
    
    if [[ $attempts -ge $MAX_RETRIES ]]; then
        log "ERROR" "🚨 Task $task_id exceeded max retries - escalating to human"
        escalate_to_human "$task_id" "Builder timeout after $MAX_RETRIES attempts"
    else
        log "INFO" "🔄 Retrying task $task_id (attempt $attempts/$MAX_RETRIES)"
        
        # Update task queue
        jq --arg task "$task_id" \
           --argjson attempts "$attempts" \
           '(.tasks[] | select(.id == $task)) |= (.status = "pending" | .attempts = $attempts | .assigned_to = null)' \
           "$TASK_QUEUE" > "$TASK_QUEUE.tmp" && mv "$TASK_QUEUE.tmp" "$TASK_QUEUE"
        
        # Reset builder state
        update_agent_state '.builder.status = "idle" | .builder.current_task = null'
    fi
}

handle_tester_timeout() {
    log "ERROR" "❌ Tester Agent timeout - marking test as failed"
    
    # Kill tester
    if [[ -f "$CONTEXT_DIR/tester.pid" ]]; then
        kill -9 "$(cat "$CONTEXT_DIR/tester.pid")" 2>/dev/null || true
        rm "$CONTEXT_DIR/tester.pid"
    fi
    
    # Report failure
    local task_id=$(jq -r '.tester.current_task' "$AGENT_STATE")
    if [[ "$task_id" != "null" ]] && [[ -n "$task_id" ]]; then
        handle_test_failure "$task_id"
    fi
}

# ============================================================================
# AGENT COORDINATION
# ============================================================================

wait_for_builder() {
    local task_id="$1"
    
    log "INFO" "⏳ Waiting for Builder to complete task $task_id"
    
    while true; do
        # Check for completion marker
        if [[ -f "$CONTEXT_DIR/builder-complete-$task_id.marker" ]]; then
            log "INFO" "✅ Builder completed task $task_id"
            return 0
        fi
        
        # Check agent state for failure
        local status=$(jq -r '.builder.status' "$AGENT_STATE")
        if [[ "$status" == "failed" ]]; then
            log "ERROR" "❌ Builder failed task $task_id"
            return 1
        fi
        
        sleep 10
    done
}

trigger_tester() {
    local task_id="$1"
    
    log "INFO" "🧪 Triggering Tester Agent for task $task_id"
    
    # Update tester state atomically
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    update_agent_state ".tester.status = \"testing\" | .tester.current_task = \"$task_id\" | .tester.started_at = \"$current_time\""
    
    # Run tester
    "$SCRIPTS_DIR/tester-agent.sh" "$task_id" &
    echo $! > "$CONTEXT_DIR/tester.pid"
}

wait_for_tester() {
    local task_id="$1"
    
    log "INFO" "⏳ Waiting for Tester to complete task $task_id"
    
    while true; do
        # Check for completion marker
        if [[ -f "$CONTEXT_DIR/tester-complete-$task_id.marker" ]]; then
            log "INFO" "✅ Tester completed task $task_id"
            return 0
        fi
        
        # Check agent state for failure
        local status=$(jq -r '.tester.status' "$AGENT_STATE")
        if [[ "$status" == "failed" ]]; then
            log "ERROR" "❌ Tester failed task $task_id"
            return 1
        fi
        
        sleep 10
    done
}

trigger_reviewer() {
    local task_id="$1"
    
    log "INFO" "👁️  Triggering Reviewer Agent for task $task_id"
    
    # Update reviewer state atomically
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    update_agent_state ".reviewer.status = \"reviewing\" | .reviewer.current_task = \"$task_id\" | .reviewer.started_at = \"$current_time\""
    
    # Run reviewer
    "$SCRIPTS_DIR/reviewer-agent.sh" "$task_id" &
    echo $! > "$CONTEXT_DIR/reviewer.pid"
}

wait_for_reviewer() {
    local task_id="$1"
    
    log "INFO" "⏳ Waiting for Reviewer to complete task $task_id"
    
    while true; do
        # Check for completion marker
        if [[ -f "$CONTEXT_DIR/reviewer-complete-$task_id.marker" ]]; then
            log "INFO" "✅ Reviewer completed task $task_id"
            return 0
        fi
        
        # Check agent state for failure
        local status=$(jq -r '.reviewer.status' "$AGENT_STATE")
        if [[ "$status" == "failed" ]]; then
            log "ERROR" "❌ Reviewer failed task $task_id"
            return 1
        fi
        
        sleep 10
    done
}

# ============================================================================
# TASK COMPLETION
# ============================================================================

mark_task_complete() {
    local task_id="$1"
    
    log "INFO" "✅ Task $task_id completed successfully"
    
    # Add to results log
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local lock_file="$RESULTS_LOG.lock"
    local max_wait=30
    local waited=0
    
    while [[ -f "$lock_file" ]] && [[ $waited -lt $max_wait ]]; do
        sleep 0.1
        waited=$((waited + 1))
    done
    
    if [[ $waited -lt $max_wait ]]; then
        touch "$lock_file"
        if jq --arg task "$task_id" --arg time "$current_time" \
               '.tasks += [{"id": $task, "status": "completed", "completed_at": $time}]' \
               "$RESULTS_LOG" > "$RESULTS_LOG.tmp" && mv "$RESULTS_LOG.tmp" "$RESULTS_LOG"; then
            rm -f "$lock_file"
        else
            log "ERROR" "Failed to update results log"
            rm -f "$lock_file" "$RESULTS_LOG.tmp"
        fi
    fi
}

get_module_name() {
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
        *) echo "UnknownModule" ;;
    esac
}

handle_review_rejection() {
    local task_id="$1"
    
    log "WARN" "⚠️  Task $task_id rejected by reviewer - checking retry count"
    
    # Get attempt count
    local attempts=$(jq --arg task "$task_id" \
                        '(.tasks[] | select(.id == $task)).attempts' \
                        "$TASK_QUEUE" 2>/dev/null || echo "0")
    
    attempts=$((attempts + 1))
    
    if [[ $attempts -ge $MAX_RETRIES ]]; then
        log "ERROR" "🚨 Task $task_id exceeded max retries - escalating to human"
        escalate_to_human "$task_id" "Reviewer rejection after $MAX_RETRIES attempts"
    else
        log "INFO" "🔄 Retrying task $task_id (attempt $attempts/$MAX_RETRIES)"
        
        # Update task queue
        local lock_file="$TASK_QUEUE.lock"
        local max_wait=30
        local waited=0
        
        while [[ -f "$lock_file" ]] && [[ $waited -lt $max_wait ]]; do
            sleep 0.1
            waited=$((waited + 1))
        done
        
        if [[ $waited -lt $max_wait ]]; then
            touch "$lock_file"
            if jq --arg task "$task_id" --argjson attempts "$attempts" \
                   '(.tasks[] | select(.id == $task)) |= (.status = "pending" | .attempts = $attempts | .assigned_to = null)' \
                   "$TASK_QUEUE" > "$TASK_QUEUE.tmp" && mv "$TASK_QUEUE.tmp" "$TASK_QUEUE"; then
                rm -f "$lock_file"
            else
                log "ERROR" "Failed to update task queue for retry"
                rm -f "$lock_file" "$TASK_QUEUE.tmp"
            fi
        fi
        
        # Reset reviewer state
        update_agent_state '.reviewer.status = "idle" | .reviewer.current_task = null'
    fi
}

handle_test_failure() {
    local task_id="$1"
    
    log "WARN" "⚠️  Task $task_id failed tests - checking retry count"
    
    # Get attempt count
    local attempts=$(jq --arg task "$task_id" \
                        '(.tasks[] | select(.id == $task)).attempts' \
                        "$TASK_QUEUE" 2>/dev/null || echo "0")
    
    attempts=$((attempts + 1))
    
    if [[ $attempts -ge $MAX_RETRIES ]]; then
        log "ERROR" "🚨 Task $task_id exceeded max retries - escalating to human"
        escalate_to_human "$task_id" "Test failure after $MAX_RETRIES attempts"
    else
        log "INFO" "🔄 Retrying task $task_id (attempt $attempts/$MAX_RETRIES)"
        
        # Update task queue
        local lock_file="$TASK_QUEUE.lock"
        local max_wait=30
        local waited=0
        
        while [[ -f "$lock_file" ]] && [[ $waited -lt $max_wait ]]; do
            sleep 0.1
            waited=$((waited + 1))
        done
        
        if [[ $waited -lt $max_wait ]]; then
            touch "$lock_file"
            if jq --arg task "$task_id" --argjson attempts "$attempts" \
                   '(.tasks[] | select(.id == $task)) |= (.status = "pending" | .attempts = $attempts | .assigned_to = null)' \
                   "$TASK_QUEUE" > "$TASK_QUEUE.tmp" && mv "$TASK_QUEUE.tmp" "$TASK_QUEUE"; then
                rm -f "$lock_file"
            else
                log "ERROR" "Failed to update task queue for retry"
                rm -f "$lock_file" "$TASK_QUEUE.tmp"
            fi
        fi
        
        # Reset tester state
        update_agent_state '.tester.status = "idle" | .tester.current_task = null'
    fi
}

generate_completion_report() {
    log "INFO" "📊 Generating completion report"
    
    local report_file="$LOGS_DIR/completion-report.md"
    
    cat > "$report_file" << EOF
# 🎉 DirectorStudio Reconstruction Complete

**Completed:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Summary
All tasks in the execution roadmap have been completed successfully.

## Task Results
EOF
    
    # Add task results
    if [[ -f "$RESULTS_LOG" ]]; then
        jq -r '.tasks[] | "- [x] \(.id): Completed at \(.completed_at)"' "$RESULTS_LOG" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

## Next Steps
1. Review completed modules
2. Run integration tests
3. Deploy to staging
4. Create release PR

## Logs
- Orchestrator: $ORCHESTRATOR_LOG
- Builder: $LOGS_DIR/builder-*.log
- Tester: $LOGS_DIR/tester-*.log
- Reviewer: $LOGS_DIR/reviewer-*.log

EOF
    
    log "INFO" "📄 Completion report generated: $report_file"
}

# ============================================================================
# ESCALATION
# ============================================================================

escalate_to_human() {
    local task_id="$1"
    local reason="$2"
    
    log "ERROR" "🚨 ESCALATING TO HUMAN: Task $task_id - $reason"
    
    # Create escalation report
    cat > "$LOGS_DIR/escalation-$task_id.md" << EOF
# 🚨 HUMAN INTERVENTION REQUIRED

## Task: $task_id
**Reason:** $reason
**Timestamp:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Context
$(jq -r --arg task "$task_id" '.builder' "$AGENT_STATE")

## Recommended Actions
1. Review builder logs: $LOGS_DIR/builder-$task_id.log
2. Check test results: $LOGS_DIR/tester-$task_id.log
3. Manually fix issue
4. Run: ./automation/multi-agent/scripts/resume-after-manual-fix.sh $task_id

## Pause Orchestrator
The orchestrator has paused. Resume with:
./automation/multi-agent/orchestrator.sh --resume
EOF
    
    # Pause orchestrator
    update_agent_state '.orchestrator.status = "paused"'
    
    # Send notification (if configured)
    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"Task $task_id needs human intervention\" with title \"DirectorStudio Orchestrator\""
    fi
    
    exit 1
}

# ============================================================================
# MAIN EXECUTION LOOP
# ============================================================================

main_loop() {
    log "INFO" "🔄 Starting main orchestration loop"
    
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    update_agent_state ".orchestrator.status = \"running\" | .orchestrator.started_at = \"$current_time\""
    
    while true; do
        # Update heartbeat
        local heartbeat_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        update_agent_state ".orchestrator.last_heartbeat = \"$heartbeat_time\""
        
        # Check if paused
        local status=$(jq -r '.orchestrator.status' "$AGENT_STATE")
        if [[ "$status" == "paused" ]]; then
            log "INFO" "⏸️  Orchestrator paused - waiting for resume"
            sleep 30
            continue
        fi
        
        # Monitor agent health
        monitor_agents
        
        # Get next task
        local next_task=$(get_next_task)
        
        if [[ -z "$next_task" ]]; then
            # Check if all tasks completed
            local pending_count=$(jq '[.tasks[] | select(.status == "pending")] | length' "$TASK_QUEUE")
            
            if [[ "$pending_count" -eq 0 ]]; then
                log "INFO" "🎉 ALL TASKS COMPLETED!"
                generate_completion_report
                exit 0
            fi
            
            log "INFO" "⏳ No tasks ready - waiting for dependencies"
            sleep 30
            continue
        fi
        
        # Assign task to builder
        assign_task_to_builder "$next_task"
        
        # Wait for builder to complete
        if wait_for_builder "$next_task"; then
            # Trigger tester
            trigger_tester "$next_task"
            
            # Wait for tester
            if wait_for_tester "$next_task"; then
                # Trigger reviewer
                trigger_reviewer "$next_task"
                
                # Wait for reviewer
                if wait_for_reviewer "$next_task"; then
                    # Mark task complete
                    mark_task_complete "$next_task"
                    
                    # Trigger PR automation
                    "$REPO_ROOT/automation/scripts/create-module-pr.sh" \
                        "$(get_module_name "$next_task")"
                else
                    # Reviewer rejected - retry or escalate
                    handle_review_rejection "$next_task"
                fi
            else
                # Tests failed - retry or escalate
                handle_test_failure "$next_task"
            fi
        else
            # Build failed - handled by monitor_agents
            continue
        fi
        
        sleep 5
    done
}

# ============================================================================
# ENTRYPOINT
# ============================================================================

case "${1:-start}" in
    start)
        init_orchestrator
        main_loop
        ;;
    resume)
        log "INFO" "▶️  Resuming orchestrator"
        update_agent_state '.orchestrator.status = "running"'
        main_loop
        ;;
    status)
        cat "$AGENT_STATE" | jq
        ;;
    *)
        echo "Usage: $0 {start|resume|status}"
        exit 1
        ;;
esac
