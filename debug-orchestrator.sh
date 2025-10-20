#!/bin/bash
# Debug script to test orchestrator functions

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTEXT_DIR="$REPO_ROOT/automation/multi-agent/context"
SCRIPTS_DIR="$REPO_ROOT/automation/multi-agent/scripts"
LOGS_DIR="$REPO_ROOT/automation/multi-agent/logs"

ROADMAP="$REPO_ROOT/EXECUTION_ROADMAP.md"
AGENT_STATE="$CONTEXT_DIR/agent-state.json"
TASK_QUEUE="$CONTEXT_DIR/task-queue.json"
RESULTS_LOG="$CONTEXT_DIR/results-log.json"

echo "=== DEBUGGING ORCHESTRATOR ==="
echo "REPO_ROOT: $REPO_ROOT"
echo "TASK_QUEUE: $TASK_QUEUE"
echo "RESULTS_LOG: $RESULTS_LOG"
echo ""

echo "=== TASK QUEUE CONTENT ==="
cat "$TASK_QUEUE" | head -20
echo ""

echo "=== RESULTS LOG CONTENT ==="
cat "$RESULTS_LOG"
echo ""

echo "=== TESTING get_next_task FUNCTION ==="
get_next_task() {
    python3 << PYTHON_SCRIPT
import json

with open("$TASK_QUEUE", 'r') as f:
    queue = json.load(f)

with open("$RESULTS_LOG", 'r') as f:
    results = json.load(f)

completed_tasks = [t['id'] for t in results['tasks'] if t['status'] == 'completed']
print(f"Completed tasks: {completed_tasks}")

for task in queue['tasks']:
    if task['status'] != 'pending':
        continue
    
    print(f"Checking task {task['id']}: dependencies {task['dependencies']}")
    # Check dependencies
    deps_met = all(dep in completed_tasks for dep in task['dependencies'])
    print(f"  Dependencies met: {deps_met}")
    
    if deps_met:
        print(f"Next task: {task['id']}")
        break
PYTHON_SCRIPT
}

next_task=$(get_next_task)
echo "Result: '$next_task'"
echo "Length: ${#next_task}"

if [[ -z "$next_task" ]]; then
    echo "❌ No task found - this is the problem!"
else
    echo "✅ Task found: $next_task"
fi
