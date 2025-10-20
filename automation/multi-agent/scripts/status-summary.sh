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
total=$(jq '.tasks | length' "$CONTEXT_DIR/task-queue.json")
pending=$(jq '[.tasks[] | select(.status == "pending")] | length' "$CONTEXT_DIR/task-queue.json")
in_progress=$(jq '[.tasks[] | select(.status == "in_progress")] | length' "$CONTEXT_DIR/task-queue.json")
completed=$(jq '[.tasks[] | select(.status == "completed")] | length' "$CONTEXT_DIR/results-log.json")

echo "  Total: $total tasks"
echo "  Completed: $completed"
echo "  In Progress: $in_progress"
echo "  Pending: $pending"
