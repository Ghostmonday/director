#!/bin/bash
# 🚀 MULTI-AGENT SYSTEM INSTALLER
# Sets up the complete multi-agent orchestration system

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MULTI_AGENT_DIR="$REPO_ROOT/automation/multi-agent"
SCRIPTS_DIR="$MULTI_AGENT_DIR/scripts"
CONTEXT_DIR="$MULTI_AGENT_DIR/context"
LOGS_DIR="$MULTI_AGENT_DIR/logs"

echo "🚀 Installing Multi-Agent Orchestration System"
echo "================================================"

# ============================================================================
# CREATE DIRECTORY STRUCTURE
# ============================================================================

echo ""
echo "📁 Creating directory structure..."

mkdir -p "$SCRIPTS_DIR"
mkdir -p "$CONTEXT_DIR"
mkdir -p "$LOGS_DIR"

echo "✅ Directories created"

# ============================================================================
# COPY SCRIPTS
# ============================================================================

echo ""
echo "📝 Installing scripts..."

# Main orchestrator
if [[ -f "$REPO_ROOT/automation/multi-agent/orchestrator.sh" ]]; then
    echo "  ✅ orchestrator.sh already in place"
else
    echo "  ⚠️  orchestrator.sh not found - download from outputs"
fi

# Agent scripts
for script in builder-agent.sh tester-agent.sh reviewer-agent.sh extract-legacy-code.sh; do
    if [[ -f "$SCRIPTS_DIR/$script" ]]; then
        echo "  ✅ $script already in place"
    else
        echo "  ⚠️  $script not found - download from outputs"
    fi
done

echo "✅ Scripts check complete"

# ============================================================================
# SET PERMISSIONS
# ============================================================================

echo ""
echo "🔐 Setting executable permissions..."

chmod +x "$MULTI_AGENT_DIR/orchestrator.sh" 2>/dev/null || echo "  ⚠️  orchestrator.sh not found"
chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null || echo "  ⚠️  No scripts found in scripts/"

echo "✅ Permissions set"

# ============================================================================
# CHECK DEPENDENCIES
# ============================================================================

echo ""
echo "🔍 Checking dependencies..."

check_dependency() {
    local cmd="$1"
    local name="$2"
    local required="$3"
    
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -n 1 || echo "unknown")
        echo "  ✅ $name: $version"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            echo "  ❌ $name: NOT FOUND (REQUIRED)"
            return 1
        else
            echo "  ⚠️  $name: NOT FOUND (OPTIONAL)"
            return 0
        fi
    fi
}

all_deps_met=true

# Required dependencies
check_dependency "bash" "Bash" "true" || all_deps_met=false
check_dependency "jq" "jq (JSON processor)" "true" || all_deps_met=false
check_dependency "python3" "Python 3" "true" || all_deps_met=false
check_dependency "swift" "Swift" "true" || all_deps_met=false
check_dependency "git" "Git" "true" || all_deps_met=false

# Optional dependencies
check_dependency "xcodebuild" "Xcode" "false"
check_dependency "swiftlint" "SwiftLint" "false"

if [[ "$all_deps_met" == "false" ]]; then
    echo ""
    echo "❌ Missing required dependencies"
    echo ""
    echo "Install missing dependencies:"
    echo "  macOS: brew install jq"
    echo "  Linux: apt-get install jq python3"
    exit 1
fi

echo "✅ All required dependencies met"

# ============================================================================
# VERIFY FILES
# ============================================================================

echo ""
echo "📋 Verifying required files..."

check_file() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        echo "  ✅ $description"
        return 0
    else
        echo "  ❌ $description: NOT FOUND"
        return 1
    fi
}

all_files_present=true

check_file "$REPO_ROOT/EXECUTION_ROADMAP.md" "Task roadmap" || all_files_present=false
check_file "$REPO_ROOT/LEGACY_CODEBASE_REFERENCE.txt" "Legacy code reference" || all_files_present=false

if [[ "$all_files_present" == "false" ]]; then
    echo ""
    echo "❌ Missing required files"
    exit 1
fi

echo "✅ All required files present"

# ============================================================================
# INITIALIZE STATE
# ============================================================================

echo ""
echo "🔄 Initializing system state..."

# Create initial agent state
cat > "$CONTEXT_DIR/agent-state.json" << 'EOF'
{
  "orchestrator": {
    "status": "not_started",
    "current_stage": null,
    "current_task": null,
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

echo "✅ agent-state.json created"

# Create empty results log
echo '{"tasks": []}' > "$CONTEXT_DIR/results-log.json"
echo "✅ results-log.json created"

# Create empty task queue (will be populated by orchestrator)
echo '{"tasks": []}' > "$CONTEXT_DIR/task-queue.json"
echo "✅ task-queue.json created"

echo "✅ System state initialized"

# ============================================================================
# CREATE HELPER SCRIPTS
# ============================================================================

echo ""
echo "🛠️  Creating helper utilities..."

# Status summary script
cat > "$SCRIPTS_DIR/status-summary.sh" << 'EOF'
#!/bin/bash
# Quick status summary

CONTEXT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../context" && pwd)"

echo "🤖 Multi-Agent System Status"
echo "============================="
echo ""

# Orchestrator status
echo "ORCHESTRATOR:"
jq -r '"  Status: " + .orchestrator.status' "$CONTEXT_DIR/agent-state.json"
jq -r '"  Current Task: " + (.orchestrator.current_task // "None")' "$CONTEXT_DIR/agent-state.json"
echo ""

# Builder status
echo "BUILDER:"
jq -r '"  Status: " + .builder.status' "$CONTEXT_DIR/agent-state.json"
jq -r '"  Task: " + (.builder.current_task // "None")' "$CONTEXT_DIR/agent-state.json"
jq -r '"  Progress: " + (.builder.progress | tostring) + "%"' "$CONTEXT_DIR/agent-state.json"
echo ""

# Tester status
echo "TESTER:"
jq -r '"  Status: " + .tester.status' "$CONTEXT_DIR/agent-state.json"
jq -r '"  Task: " + (.tester.current_task // "None")' "$CONTEXT_DIR/agent-state.json"
echo ""

# Reviewer status
echo "REVIEWER:"
jq -r '"  Status: " + .reviewer.status' "$CONTEXT_DIR/agent-state.json"
jq -r '"  Task: " + (.reviewer.current_task // "None")' "$CONTEXT_DIR/agent-state.json"
echo ""

# Task queue summary
echo "TASK QUEUE:"
local total=$(jq '.tasks | length' "$CONTEXT_DIR/task-queue.json")
local pending=$(jq '[.tasks[] | select(.status == "pending")] | length' "$CONTEXT_DIR/task-queue.json")
local in_progress=$(jq '[.tasks[] | select(.status == "in_progress")] | length' "$CONTEXT_DIR/task-queue.json")
local completed=$(jq '[.tasks[] | select(.status == "completed")] | length' "$CONTEXT_DIR/results-log.json")

echo "  Total: $total tasks"
echo "  Completed: $completed"
echo "  In Progress: $in_progress"
echo "  Pending: $pending"
EOF

chmod +x "$SCRIPTS_DIR/status-summary.sh"
echo "✅ status-summary.sh created"

# ============================================================================
# FINAL CHECKS
# ============================================================================

echo ""
echo "🔍 Running final checks..."

# Test jq installation
if jq --version &> /dev/null; then
    echo "  ✅ jq working"
else
    echo "  ❌ jq not working"
    all_deps_met=false
fi

# Test Python JSON module
if python3 -c "import json" 2>/dev/null; then
    echo "  ✅ Python JSON module available"
else
    echo "  ❌ Python JSON module not available"
    all_deps_met=false
fi

# Check Swift
if swift --version &> /dev/null; then
    echo "  ✅ Swift compiler available"
else
    echo "  ⚠️  Swift compiler not available"
fi

echo "✅ Final checks complete"

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "================================================"
echo "✅ Installation Complete!"
echo "================================================"
echo ""
echo "📁 Installation Directory:"
echo "   $MULTI_AGENT_DIR"
echo ""
echo "📝 Next Steps:"
echo ""
echo "1. Review the documentation:"
echo "   cat $MULTI_AGENT_DIR/README.md"
echo ""
echo "2. Check Cursor integration:"
echo "   cat $MULTI_AGENT_DIR/CURSOR_INTEGRATION.md"
echo ""
echo "3. Test the system:"
echo "   $MULTI_AGENT_DIR/orchestrator.sh status"
echo ""
echo "4. Start automation:"
echo "   $MULTI_AGENT_DIR/orchestrator.sh start"
echo ""
echo "📊 Monitor progress:"
echo "   $SCRIPTS_DIR/status-summary.sh"
echo ""
echo "📜 View logs:"
echo "   tail -f $LOGS_DIR/orchestrator.log"
echo ""
echo "================================================"
echo "🚀 Ready to rebuild DirectorStudio!"
echo "================================================"
