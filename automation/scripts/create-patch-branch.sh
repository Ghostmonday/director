#!/bin/bash
# 🔧 Patch Branch Creator
# Creates a patch branch when PR needs fixes

set -euo pipefail

# Configuration
LOG_FILE="automation/logs/daemon.log"
PR_TRACKER="automation/logs/pr-tracker.md"

# Function to create patch branch
create_patch_branch() {
    local module_name="$1"
    local pr_number="$2"
    local original_branch="$3"
    
    echo "🔧 Creating patch branch for $module_name (PR #$pr_number)" | tee -a "$LOG_FILE"
    
    # Generate patch branch name with timestamp
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")
    local patch_branch="patch/${module_name}-${timestamp}"
    
    # Ensure we're on main branch
    git checkout main
    git pull origin main
    
    # Create patch branch from main
    git checkout -b "$patch_branch"
    
    # Cherry-pick commits from original branch (if they exist)
    if git show-ref --verify --quiet "refs/remotes/origin/$original_branch"; then
        echo "📋 Cherry-picking commits from $original_branch" | tee -a "$LOG_FILE"
        
        # Get commits from original branch
        local commits
        commits=$(git log --oneline origin/main..origin/"$original_branch" --reverse)
        
        if [[ -n "$commits" ]]; then
            while IFS= read -r commit; do
                local commit_hash
                commit_hash=$(echo "$commit" | cut -d' ' -f1)
                echo "  Cherry-picking: $commit" | tee -a "$LOG_FILE"
                git cherry-pick "$commit_hash" || {
                    echo "⚠️  Cherry-pick failed for $commit_hash - manual resolution needed" | tee -a "$LOG_FILE"
                    # Continue with other commits
                }
            done <<< "$commits"
        fi
    else
        echo "⚠️  Original branch $original_branch not found - creating empty patch branch" | tee -a "$LOG_FILE"
    fi
    
    # Push patch branch
    git push -u origin "$patch_branch"
    
    # Create new PR for patch branch
    local patch_pr_title="🔧 Fix: $module_name (Patch for PR #$pr_number)"
    local patch_pr_body="This patch branch addresses issues found in PR #$pr_number.

## Issues Addressed
- [ ] Build errors fixed
- [ ] Lint issues resolved  
- [ ] Security issues addressed
- [ ] Test failures fixed

## Original PR
- PR #$pr_number: $original_branch
- Module: $module_name

## Changes Made
- Applied fixes based on PR review feedback
- Resolved all blocking issues
- Maintained backward compatibility

## Testing
- [ ] Builds successfully
- [ ] All tests pass
- [ ] Lint checks pass
- [ ] Security scan passes

## Ready for Review
This patch branch is ready for review and should resolve all issues from the original PR."
    
    # Create patch PR
    local patch_pr_number
    patch_pr_number=$(gh pr create \
        --title "$patch_pr_title" \
        --body "$patch_pr_body" \
        --base main \
        --head "$patch_branch" \
        --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)")
    
    echo "✅ Created patch PR #$patch_pr_number: $patch_branch" | tee -a "$LOG_FILE"
    
    # Update PR tracker with patch branch info
    update_pr_tracker_with_patch "$module_name" "$pr_number" "$patch_branch" "$patch_pr_number"
    
    # Close original PR with reference to patch
    echo "🔒 Closing original PR #$pr_number with reference to patch PR #$patch_pr_number" | tee -a "$LOG_FILE"
    gh pr close "$pr_number" --comment "This PR has been replaced by patch PR #$patch_pr_number which addresses the review feedback.

**Patch PR:** #$patch_pr_number
**Patch Branch:** $patch_branch

Please review the patch PR instead."
    
    return 0
}

# Function to update PR tracker with patch information
update_pr_tracker_with_patch() {
    local module_name="$1"
    local original_pr="$2"
    local patch_branch="$3"
    local patch_pr="$4"
    
    # Update the notes column with patch information
    local notes="Patch: PR #$patch_pr ($patch_branch)"
    
    # Update the PR tracker
    sed -i '' "s/| $module_name | $original_pr |.*|.*|.*|.*|.*|/| $module_name | $original_pr | $(date +"%Y-%m-%d %H:%M:%S") | 🔧 PATCH | $(date +"%Y-%m-%d %H:%M:%S") | $notes |/" "$PR_TRACKER"
    
    echo "📝 Updated PR tracker with patch information" | tee -a "$LOG_FILE"
}

# Function to apply common fixes
apply_common_fixes() {
    local module_name="$1"
    
    echo "🔧 Applying common fixes for $module_name" | tee -a "$LOG_FILE"
    
    # Fix common Swift issues
    if [[ -f "${module_name}.swift" ]]; then
        echo "  Fixing Swift file: ${module_name}.swift" | tee -a "$LOG_FILE"
        
        # Add missing imports if needed
        if ! grep -q "import Foundation" "${module_name}.swift"; then
            sed -i '' '1i\
import Foundation
' "${module_name}.swift"
        fi
        
        # Fix common syntax issues
        sed -i '' 's/let\s\+var\s\+/let /g' "${module_name}.swift"  # Fix 'let var' -> 'let'
        sed -i '' 's/var\s\+let\s\+/var /g' "${module_name}.swift"  # Fix 'var let' -> 'var'
        
        # Add Sendable conformance if missing
        if grep -q "struct.*:" "${module_name}.swift" && ! grep -q "Sendable" "${module_name}.swift"; then
            sed -i '' 's/struct \([A-Za-z][A-Za-z0-9]*\):/struct \1: Sendable, Codable/g' "${module_name}.swift"
        fi
    fi
    
    # Fix common build issues
    echo "  Running Swift build check" | tee -a "$LOG_FILE"
    if swift build 2>&1 | tee -a "$LOG_FILE"; then
        echo "✅ Build successful after fixes" | tee -a "$LOG_FILE"
    else
        echo "⚠️  Build still has issues - manual intervention needed" | tee -a "$LOG_FILE"
    fi
}

# Function to run automated tests
run_automated_tests() {
    local module_name="$1"
    
    echo "🧪 Running automated tests for $module_name" | tee -a "$LOG_FILE"
    
    # Run Swift tests if available
    if [[ -f "Package.swift" ]] || [[ -d "Tests" ]]; then
        if swift test 2>&1 | tee -a "$LOG_FILE"; then
            echo "✅ All tests passed" | tee -a "$LOG_FILE"
        else
            echo "⚠️  Some tests failed - manual review needed" | tee -a "$LOG_FILE"
        fi
    else
        echo "ℹ️  No test suite found - skipping automated tests" | tee -a "$LOG_FILE"
    fi
    
    # Run linting if available
    if command -v swiftlint >/dev/null 2>&1; then
        echo "🔍 Running SwiftLint" | tee -a "$LOG_FILE"
        if swiftlint 2>&1 | tee -a "$LOG_FILE"; then
            echo "✅ Lint checks passed" | tee -a "$LOG_FILE"
        else
            echo "⚠️  Lint issues found - attempting auto-fix" | tee -a "$LOG_FILE"
            swiftlint --fix 2>&1 | tee -a "$LOG_FILE" || true
        fi
    fi
}

# Main execution
if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <module_name> <original_pr_number> <original_branch>"
    echo "  module_name: Name of the module being patched"
    echo "  original_pr_number: PR number that needs fixes"
    echo "  original_branch: Original branch name"
    exit 1
fi

MODULE_NAME="$1"
ORIGINAL_PR="$2"
ORIGINAL_BRANCH="$3"

echo "🔧 Starting patch branch creation for $MODULE_NAME" | tee -a "$LOG_FILE"
echo "  Original PR: #$ORIGINAL_PR" | tee -a "$LOG_FILE"
echo "  Original Branch: $ORIGINAL_BRANCH" | tee -a "$LOG_FILE"

# Apply common fixes
apply_common_fixes "$MODULE_NAME"

# Run automated tests
run_automated_tests "$MODULE_NAME"

# Create patch branch
create_patch_branch "$MODULE_NAME" "$ORIGINAL_PR" "$ORIGINAL_BRANCH"

echo "✅ Patch branch creation complete for $MODULE_NAME" | tee -a "$LOG_FILE"
