#!/bin/bash
# 🤖 Stage Validation Daemon
# Monitors PR tracker and generates stage completion markers

set -euo pipefail

# Configuration
PR_TRACKER="automation/logs/pr-tracker.md"
STAGE_PROGRESS="automation/logs/stage-progress.md"
CHECKLIST="CHEETAH_EXECUTION_CHECKLIST_OPTIMIZED.md"
LOG_FILE="automation/logs/daemon.log"

# Stage definitions - module names per stage
STAGE_1_MODULES=("PromptSegment" "PipelineContext" "MockAIService" "RewordingModule" "RewordingUI")
STAGE_2_MODULES=("PipelineOrchestrator" "PipelineConfig" "PipelineManager" "PipelineProgressView")
STAGE_3_MODULES=("SecretsConfiguration" "AIService" "ImageGenerationService" "AIServiceSettingsView")
STAGE_4_MODULES=("ProjectStore" "ProjectManager" "ProjectListView" "ProjectDetailView")
STAGE_5_MODULES=("CreditsService" "StoreKitService" "CreditsStoreView" "PurchaseFlowView")

# Function to check if module is validated
check_module_validated() {
    local module_name="$1"
    
    # Check PR tracker for successful validation
    if grep -q "\[Module: $module_name\].*✅.*Merged: ✅" "$PR_TRACKER"; then
        return 0  # Validated
    fi
    
    # Check for manual validation markers
    if grep -q "✅.*$module_name.*validated" "$PR_TRACKER"; then
        return 0  # Validated
    fi
    
    return 1  # Not validated
}

# Function to check stage completion
check_stage_completion() {
    local stage_num="$1"
    shift
    local modules=("$@")
    
    for module in "${modules[@]}"; do
        if ! check_module_validated "$module"; then
            return 1  # Stage incomplete
        fi
    done
    
    return 0  # Stage complete
}

# Function to generate stage completion marker
generate_stage_complete() {
    local stage_num="$1"
    local stage_file="STAGE_${stage_num}_COMPLETE.md"
    
    if [[ -f "$stage_file" ]]; then
        echo "⚠️  $stage_file already exists - skipping generation"
        return 0
    fi
    
    cat > "$stage_file" << EOF_STAGE
# ✅ STAGE $stage_num COMPLETE

**Auto-generated stage completion marker**

---

## Completion Details
- **Stage:** $stage_num
- **Status:** ✅ All tasks validated
- **Generated:** $(date +"%Y-%m-%dT%H:%M:%SZ")
- **Daemon:** stage-validation-daemon.sh

---

## Validated Modules
$(for module in "${modules[@]}"; do echo "- ✅ $module"; done)

---

## Next Steps
Proceed to Stage $((stage_num + 1)) in CHEETAH_EXECUTION_CHECKLIST_OPTIMIZED.md

---

**This file is auto-generated. Manual edits may be overwritten.**
EOF_STAGE
    
    echo "✅ Generated $stage_file"
}

# Function to log stage progress
log_stage_progress() {
    local stage_num="$1"
    local status="$2"
    
    # Remove existing entry if any
    sed -i '' "/## Stage $stage_num Status/d" "$STAGE_PROGRESS" 2>/dev/null || true
    sed -i '' "/- Status:.*/d" "$STAGE_PROGRESS" 2>/dev/null || true
    
    # Append new entry
    echo "" >> "$STAGE_PROGRESS"
    echo "## Stage $stage_num Status" >> "$STAGE_PROGRESS"
    echo "- Status: $status" >> "$STAGE_PROGRESS"
    echo "- Last Checked: $(date +"%Y-%m-%dT%H:%M:%SZ")" >> "$STAGE_PROGRESS"
    echo "- Modules: ${#modules[@]} total" >> "$STAGE_PROGRESS"
    
    # Count completed modules
    local completed=0
    for module in "${modules[@]}"; do
        if check_module_validated "$module"; then
            completed=$((completed + 1))
            echo "  - ✅ $module" >> "$STAGE_PROGRESS"
        else
            echo "  - ⏳ $module" >> "$STAGE_PROGRESS"
        fi
    done
    
    echo "- Progress: $completed/${#modules[@]} modules validated" >> "$STAGE_PROGRESS"
}

# Main daemon function
run_daemon() {
    echo "🤖 Stage Validation Daemon starting at $(date)" | tee -a "$LOG_FILE"
    
    # Check each stage
    for stage_num in {1..5}; do
        local var_name="STAGE_${stage_num}_MODULES[@]"
        local modules=("${!var_name}")
        
        if check_stage_completion "$stage_num" "${modules[@]}"; then
            if [[ ! -f "STAGE_${stage_num}_COMPLETE.md" ]]; then
                echo "🎉 Stage $stage_num → COMPLETE" | tee -a "$LOG_FILE"
                generate_stage_complete "$stage_num" "${modules[@]}"
                log_stage_progress "$stage_num" "✅ Completed"
            else
                echo "ℹ️  Stage $stage_num already complete" | tee -a "$LOG_FILE"
                log_stage_progress "$stage_num" "✅ Completed"
            fi
        else
            echo "⏳ Stage $stage_num → IN PROGRESS" | tee -a "$LOG_FILE"
            log_stage_progress "$stage_num" "🔄 In Progress"
        fi
    done
    
    echo "🤖 Daemon cycle complete at $(date)" | tee -a "$LOG_FILE"
    echo "---" | tee -a "$LOG_FILE"
}

# Execution modes
case "${1:-}" in
    "--once")
        run_daemon
        ;;
    "--continuous")
        while true; do
            run_daemon
            sleep 3600  # Run hourly
        done
        ;;
    "--test")
        echo "🧪 Test mode: Checking stage completion"
        for stage_num in {1..5}; do
            var_name="STAGE_${stage_num}_MODULES[@]"
            modules=("${!var_name}")
            if check_stage_completion "$stage_num" "${modules[@]}"; then
                echo "✅ Stage $stage_num: COMPLETE"
            else
                echo "⏳ Stage $stage_num: IN PROGRESS"
            fi
        done
        ;;
    *)
        echo "Usage: $0 [--once|--continuous|--test]"
        echo "  --once: Run one check and exit"
        echo "  --continuous: Run hourly (daemon mode)"
        echo "  --test: Test stage completion without generating files"
        exit 1
        ;;
esac
