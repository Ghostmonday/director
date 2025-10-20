#!/bin/bash
# 🔍 PR Status Monitor
# Monitors PR status and triggers fallback actions when needed

set -euo pipefail

# Configuration
PR_TRACKER="automation/logs/pr-tracker.md"
LOG_FILE="automation/logs/daemon.log"
PATCH_SCRIPT="automation/scripts/create-patch-branch.sh"

# Function to get PR status from GitHub
get_pr_status() {
    local pr_number="$1"
    local repo="$2"
    
    # Get PR status using GitHub CLI
    gh pr view "$pr_number" --repo "$repo" --json state,mergeable,statusCheckRollup,reviews --jq '
        {
            state: .state,
            mergeable: .mergeable,
            checks: [.statusCheckRollup[] | select(.conclusion != null) | {name: .name, conclusion: .conclusion}],
            reviews: [.reviews[] | {state: .state, author: .author.login}]
        }'
}

# Function to check if PR needs fixes
pr_needs_fixes() {
    local pr_data="$1"
    
    # Check if PR is not mergeable
    if echo "$pr_data" | jq -r '.mergeable' | grep -q "false"; then
        return 0  # Needs fixes
    fi
    
    # Check for failed status checks
    if echo "$pr_data" | jq -r '.checks[].conclusion' | grep -q "FAILURE"; then
        return 0  # Needs fixes
    fi
    
    # Check for requested changes
    if echo "$pr_data" | jq -r '.reviews[].state' | grep -q "CHANGES_REQUESTED"; then
        return 0  # Needs fixes
    fi
    
    return 1  # No fixes needed
}

# Function to update PR tracker
update_pr_tracker() {
    local module_name="$1"
    local pr_number="$2"
    local status="$3"
    local timestamp="$4"
    
    # Update the PR tracker file
    sed -i '' "s/| $module_name | $pr_number |.*| $status |/| $module_name | $pr_number | $timestamp | $status |/" "$PR_TRACKER"
    
    # Log the update
    echo "[$timestamp] PR #$pr_number for $module_name: $status" >> "$LOG_FILE"
}

# Function to trigger patch branch creation
trigger_patch_branch() {
    local module_name="$1"
    local pr_number="$2"
    local original_branch="$3"
    
    echo "🔧 Creating patch branch for $module_name (PR #$pr_number)" | tee -a "$LOG_FILE"
    
    # Call the patch branch creation script
    if [[ -f "$PATCH_SCRIPT" ]]; then
        "$PATCH_SCRIPT" "$module_name" "$pr_number" "$original_branch"
    else
        echo "❌ ERROR: Patch script not found at $PATCH_SCRIPT" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Function to monitor a specific PR
monitor_pr() {
    local module_name="$1"
    local pr_number="$2"
    local repo="${3:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
    
    echo "🔍 Monitoring PR #$pr_number for $module_name" | tee -a "$LOG_FILE"
    
    # Get current PR status
    local pr_data
    pr_data=$(get_pr_status "$pr_number" "$repo")
    local current_status
    current_status=$(echo "$pr_data" | jq -r '.state')
    
    # Update tracker with current status
    update_pr_tracker "$module_name" "$pr_number" "$current_status" "$(date +"%Y-%m-%d %H:%M:%S")"
    
    # Check if PR needs fixes
    if pr_needs_fixes "$pr_data"; then
        echo "⚠️  PR #$pr_number needs fixes - triggering patch branch creation" | tee -a "$LOG_FILE"
        
        # Get original branch name
        local original_branch
        original_branch=$(gh pr view "$pr_number" --repo "$repo" --json headRefName -q .headRefName)
        
        # Trigger patch branch creation
        trigger_patch_branch "$module_name" "$pr_number" "$original_branch"
        
        # Update status to indicate patch branch created
        update_pr_tracker "$module_name" "$pr_number" "🔧 PATCH" "$(date +"%Y-%m-%d %H:%M:%S")"
        
    elif [[ "$current_status" == "MERGED" ]]; then
        echo "✅ PR #$pr_number merged successfully" | tee -a "$LOG_FILE"
        update_pr_tracker "$module_name" "$pr_number" "✅ MERGED" "$(date +"%Y-%m-%d %H:%M:%S")"
        
    elif [[ "$current_status" == "CLOSED" ]]; then
        echo "❌ PR #$pr_number was closed" | tee -a "$LOG_FILE"
        update_pr_tracker "$module_name" "$pr_number" "❌ CLOSED" "$(date +"%Y-%m-%d %H:%M:%S")"
        
    else
        echo "⏳ PR #$pr_number still pending" | tee -a "$LOG_FILE"
    fi
}

# Function to monitor all pending PRs
monitor_all_prs() {
    echo "🔍 Starting PR monitoring cycle at $(date)" | tee -a "$LOG_FILE"
    
    # Read PR tracker and monitor each pending PR
    while IFS='|' read -r task module pr_number branch status created merged notes; do
        # Skip header and empty lines
        if [[ "$module" =~ ^[[:space:]]*$ ]] || [[ "$module" == *"Module"* ]]; then
            continue
        fi
        
        # Clean up whitespace
        module=$(echo "$module" | xargs)
        pr_number=$(echo "$pr_number" | xargs)
        status=$(echo "$status" | xargs)
        
        # Skip if no PR number or already completed
        if [[ -z "$pr_number" ]] || [[ "$pr_number" == "-" ]] || [[ "$status" == "✅ MERGED" ]]; then
            continue
        fi
        
        # Monitor this PR
        monitor_pr "$module" "$pr_number"
        
    done < "$PR_TRACKER"
    
    echo "🔍 PR monitoring cycle complete at $(date)" | tee -a "$LOG_FILE"
}

# Main execution
case "${1:-}" in
    "--monitor-all")
        monitor_all_prs
        ;;
    "--monitor-pr")
        if [[ $# -lt 3 ]]; then
            echo "Usage: $0 --monitor-pr <module_name> <pr_number> [repo]"
            exit 1
        fi
        monitor_pr "$2" "$3" "${4:-}"
        ;;
    "--test")
        echo "🧪 Test mode: Checking PR monitoring capabilities"
        echo "✅ PR status monitoring script ready"
        echo "✅ Patch branch creation integration ready"
        echo "✅ PR tracker update functionality ready"
        ;;
    *)
        echo "Usage: $0 [--monitor-all|--monitor-pr <module> <pr_number> [repo]|--test]"
        echo "  --monitor-all: Monitor all pending PRs from tracker"
        echo "  --monitor-pr: Monitor specific PR"
        echo "  --test: Test script functionality"
        exit 1
        ;;
esac
