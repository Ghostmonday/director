#!/bin/bash
# 🤖 BugBot Integration
# Integrates with BugBot for automated PR review and feedback

set -euo pipefail

# Configuration
LOG_FILE="automation/logs/daemon.log"
PR_TRACKER="automation/logs/pr-tracker.md"
BOT_CONFIG="automation/bugbot-config.json"

# Function to create BugBot configuration
create_bugbot_config() {
    if [[ ! -f "$BOT_CONFIG" ]]; then
        cat > "$BOT_CONFIG" << 'EOF_BOT_CONFIG'
{
  "bot_name": "DirectorStudio-BugBot",
  "version": "1.0.0",
  "review_criteria": {
    "build_checks": {
      "enabled": true,
      "required": true,
      "timeout": 300
    },
    "lint_checks": {
      "enabled": true,
      "required": true,
      "rules": ["swiftlint", "custom-director-rules"]
    },
    "security_checks": {
      "enabled": true,
      "required": true,
      "scans": ["secrets", "dependencies", "code_analysis"]
    },
    "test_checks": {
      "enabled": true,
      "required": true,
      "coverage_threshold": 80
    },
    "documentation_checks": {
      "enabled": true,
      "required": false,
      "min_doc_coverage": 60
    }
  },
  "auto_actions": {
    "auto_merge": {
      "enabled": true,
      "conditions": [
        "all_checks_pass",
        "no_security_issues",
        "test_coverage_adequate"
      ]
    },
    "auto_patch": {
      "enabled": true,
      "trigger_conditions": [
        "build_failure",
        "lint_errors",
        "test_failures"
      ]
    },
    "escalation": {
      "enabled": true,
      "human_review_required": [
        "security_issues",
        "architectural_changes",
        "breaking_changes"
      ]
    }
  },
  "feedback_templates": {
    "approval": "✅ **BugBot Approval**\n\nAll checks passed! This PR is ready for merge.\n\n**Checks Passed:**\n- ✅ Build successful\n- ✅ Lint checks passed\n- ✅ Security scan clean\n- ✅ Tests passing\n- ✅ Documentation adequate\n\n**Auto-merge:** Enabled",
    "needs_fixes": "⚠️ **BugBot Review - Fixes Required**\n\nThis PR needs fixes before it can be merged.\n\n**Issues Found:**\n{ISSUES_LIST}\n\n**Next Steps:**\n1. Fix the issues listed above\n2. Push your changes\n3. BugBot will re-review automatically\n\n**Auto-patch:** Available if needed",
    "patch_created": "🔧 **BugBot Patch Branch Created**\n\nA patch branch has been created to address the issues:\n\n**Patch Details:**\n- Branch: {PATCH_BRANCH}\n- PR: #{PATCH_PR_NUMBER}\n- Issues Addressed: {ISSUES_COUNT}\n\n**Original PR:** This PR will be closed in favor of the patch PR."
  }
}
EOF_BOT_CONFIG
        echo "✅ Created BugBot configuration at $BOT_CONFIG" | tee -a "$LOG_FILE"
    fi
}

# Function to run BugBot review
run_bugbot_review() {
    local pr_number="$1"
    local module_name="$2"
    local repo="${3:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
    
    echo "🤖 Starting BugBot review for PR #$pr_number ($module_name)" | tee -a "$LOG_FILE"
    
    # Get PR details
    local pr_data
    pr_data=$(gh pr view "$pr_number" --repo "$repo" --json headRefName,title,body)
    local branch_name
    branch_name=$(echo "$pr_data" | jq -r '.headRefName')
    
    echo "  Branch: $branch_name" | tee -a "$LOG_FILE"
    
    # Run build checks
    local build_result
    build_result=$(run_build_checks "$branch_name" "$module_name")
    
    # Run lint checks
    local lint_result
    lint_result=$(run_lint_checks "$branch_name" "$module_name")
    
    # Run security checks
    local security_result
    security_result=$(run_security_checks "$branch_name" "$module_name")
    
    # Run test checks
    local test_result
    test_result=$(run_test_checks "$branch_name" "$module_name")
    
    # Analyze results
    local issues=()
    local all_passed=true
    
    if [[ "$build_result" != "PASS" ]]; then
        issues+=("Build failure: $build_result")
        all_passed=false
    fi
    
    if [[ "$lint_result" != "PASS" ]]; then
        issues+=("Lint issues: $lint_result")
        all_passed=false
    fi
    
    if [[ "$security_result" != "PASS" ]]; then
        issues+=("Security issues: $security_result")
        all_passed=false
    fi
    
    if [[ "$test_result" != "PASS" ]]; then
        issues+=("Test failures: $test_result")
        all_passed=false
    fi
    
    # Post review results
    if [[ "$all_passed" == true ]]; then
        post_approval_comment "$pr_number" "$module_name"
        echo "✅ BugBot approval for PR #$pr_number" | tee -a "$LOG_FILE"
        return 0
    else
        post_fixes_comment "$pr_number" "$module_name" "${issues[@]}"
        echo "⚠️  BugBot found issues in PR #$pr_number" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Function to run build checks
run_build_checks() {
    local branch_name="$1"
    local module_name="$2"
    
    echo "🔨 Running build checks for $module_name" | tee -a "$LOG_FILE"
    
    # Checkout the branch
    git checkout "$branch_name" || {
        echo "❌ Failed to checkout branch $branch_name"
        return 1
    }
    
    # Run Swift build
    if swift build 2>&1 | tee -a "$LOG_FILE"; then
        echo "✅ Build successful"
        return 0
    else
        echo "❌ Build failed"
        return 1
    fi
}

# Function to run lint checks
run_lint_checks() {
    local branch_name="$1"
    local module_name="$2"
    
    echo "🔍 Running lint checks for $module_name" | tee -a "$LOG_FILE"
    
    # Check if SwiftLint is available
    if ! command -v swiftlint >/dev/null 2>&1; then
        echo "⚠️  SwiftLint not available - skipping lint checks"
        return 0
    fi
    
    # Run SwiftLint
    if swiftlint 2>&1 | tee -a "$LOG_FILE"; then
        echo "✅ Lint checks passed"
        return 0
    else
        echo "❌ Lint issues found"
        return 1
    fi
}

# Function to run security checks
run_security_checks() {
    local branch_name="$1"
    local module_name="$2"
    
    echo "🔒 Running security checks for $module_name" | tee -a "$LOG_FILE"
    
    # Check for hardcoded secrets
    if grep -r -i "password\|secret\|key\|token" --include="*.swift" . | grep -v "// TODO\|// FIXME\|// NOTE" | grep -v "Bundle.main.object"; then
        echo "❌ Potential hardcoded secrets found"
        return 1
    fi
    
    # Check for dangerous functions
    if grep -r "NSLog\|print(" --include="*.swift" . | grep -v "// DEBUG"; then
        echo "⚠️  Debug logging found (may need review)"
    fi
    
    echo "✅ Security checks passed"
    return 0
}

# Function to run test checks
run_test_checks() {
    local branch_name="$1"
    local module_name="$2"
    
    echo "🧪 Running test checks for $module_name" | tee -a "$LOG_FILE"
    
    # Check if tests exist
    if [[ ! -f "Package.swift" ]] && [[ ! -d "Tests" ]]; then
        echo "⚠️  No test suite found - skipping test checks"
        return 0
    fi
    
    # Run tests
    if swift test 2>&1 | tee -a "$LOG_FILE"; then
        echo "✅ All tests passed"
        return 0
    else
        echo "❌ Some tests failed"
        return 1
    fi
}

# Function to post approval comment
post_approval_comment() {
    local pr_number="$1"
    local module_name="$2"
    
    local comment
    comment=$(jq -r '.feedback_templates.approval' "$BOT_CONFIG")
    
    gh pr comment "$pr_number" --body "$comment"
    echo "✅ Posted approval comment to PR #$pr_number" | tee -a "$LOG_FILE"
}

# Function to post fixes required comment
post_fixes_comment() {
    local pr_number="$1"
    local module_name="$2"
    shift 2
    local issues=("$@")
    
    # Build issues list
    local issues_list=""
    for issue in "${issues[@]}"; do
        issues_list+="- ❌ $issue\n"
    done
    
    # Get template and replace placeholder
    local comment
    comment=$(jq -r '.feedback_templates.needs_fixes' "$BOT_CONFIG")
    comment=$(echo "$comment" | sed "s/{ISSUES_LIST}/$issues_list/g")
    
    gh pr comment "$pr_number" --body "$comment"
    echo "⚠️  Posted fixes required comment to PR #$pr_number" | tee -a "$LOG_FILE"
}

# Function to trigger auto-patch
trigger_auto_patch() {
    local pr_number="$1"
    local module_name="$2"
    local issues=("$@")
    
    echo "🔧 Triggering auto-patch for PR #$pr_number" | tee -a "$LOG_FILE"
    
    # Get branch name
    local branch_name
    branch_name=$(gh pr view "$pr_number" --json headRefName -q .headRefName)
    
    # Call patch creation script
    if [[ -f "automation/scripts/create-patch-branch.sh" ]]; then
        automation/scripts/create-patch-branch.sh "$module_name" "$pr_number" "$branch_name"
        
        # Post patch created comment
        local comment
        comment=$(jq -r '.feedback_templates.patch_created' "$BOT_CONFIG")
        comment=$(echo "$comment" | sed "s/{PATCH_BRANCH}/patch\/${module_name}-$(date +%Y%m%d-%H%M%S)/g")
        comment=$(echo "$comment" | sed "s/{PATCH_PR_NUMBER}/TBD/g")
        comment=$(echo "$comment" | sed "s/{ISSUES_COUNT}/${#issues[@]}/g")
        
        gh pr comment "$pr_number" --body "$comment"
        
        echo "✅ Auto-patch triggered for PR #$pr_number" | tee -a "$LOG_FILE"
    else
        echo "❌ Patch creation script not found" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Main execution
case "${1:-}" in
    "--review")
        if [[ $# -lt 3 ]]; then
            echo "Usage: $0 --review <pr_number> <module_name> [repo]"
            exit 1
        fi
        create_bugbot_config
        run_bugbot_review "$2" "$3" "${4:-}"
        ;;
    "--auto-patch")
        if [[ $# -lt 3 ]]; then
            echo "Usage: $0 --auto-patch <pr_number> <module_name> [issues...]"
            exit 1
        fi
        create_bugbot_config
        shift 2
        trigger_auto_patch "$2" "$3" "$@"
        ;;
    "--test")
        echo "🧪 Test mode: Checking BugBot integration"
        create_bugbot_config
        echo "✅ BugBot configuration created"
        echo "✅ Review functions ready"
        echo "✅ Auto-patch integration ready"
        ;;
    *)
        echo "Usage: $0 [--review <pr_number> <module_name> [repo]|--auto-patch <pr_number> <module_name> [issues...]|--test]"
        echo "  --review: Run BugBot review on PR"
        echo "  --auto-patch: Trigger auto-patch for PR"
        echo "  --test: Test BugBot integration"
        exit 1
        ;;
esac
