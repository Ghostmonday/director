# 🤖 Multi-Agent Orchestration System

**Automated DirectorStudio reconstruction using coordinated AI agents**

---

## 📖 Overview

This system coordinates multiple AI agents to automatically rebuild DirectorStudio from the legacy codebase. It provides:

- **Autonomous task execution** - Agents work through 56 tasks automatically
- **Quality gates** - Build, test, and review validation at each step
- **Failure recovery** - Auto-retry with escalation to humans when needed
- **Progress tracking** - Real-time status monitoring
- **Parallel execution** - Multiple agents can work simultaneously

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────┐
│          ORCHESTRATOR (Master Control)           │
│  • Reads EXECUTION_ROADMAP.md                    │
│  • Assigns tasks to agents                       │
│  • Monitors timeouts and failures                │
│  • Escalates to humans when needed               │
└─────────────────┬────────────────────────────────┘
                  │
       ┌──────────┼──────────┐
       │          │          │
   ┌───▼───┐  ┌──▼───┐  ┌───▼────┐
   │Builder│  │Tester│  │Reviewer│
   │ Agent │  │Agent │  │ Agent  │
   └───┬───┘  └──┬───┘  └───┬────┘
       │         │          │
       └─────────┴──────────┘
                 │
     ┌───────────▼───────────┐
     │   SHARED CONTEXT      │
     │ • agent-state.json    │
     │ • task-queue.json     │
     │ • results-log.json    │
     └───────────────────────┘
```

---

## 🎯 Agents & Responsibilities

### 1. **Orchestrator** (Master Control)
**File:** `orchestrator.sh`

**Responsibilities:**
- Parses EXECUTION_ROADMAP.md into task queue
- Assigns tasks based on dependencies and priority
- Monitors agent health and timeouts
- Handles retries and escalations
- Generates completion reports

**Timeout:** N/A (runs until all tasks complete)

---

### 2. **Builder Agent** (Implementation)
**File:** `builder-agent.sh`

**Responsibilities:**
- Reads task requirements from roadmap
- Extracts legacy code references
- Creates implementation prompts for Cursor/Claude
- Waits for code completion
- Validates basic structure

**Timeout:** 2 hours per task  
**Max Retries:** 3

**Integration:** Works with Cursor AI to implement code

---

### 3. **Tester Agent** (Validation)
**File:** `tester-agent.sh`

**Responsibilities:**
- Validates file existence
- Runs Swift/Xcode builds
- Executes unit tests
- Checks validation checklists
- Reports pass/fail to orchestrator

**Timeout:** 30 minutes per task  
**Max Retries:** 2

---

### 4. **Reviewer Agent** (Quality Control)
**File:** `reviewer-agent.sh`

**Responsibilities:**
- Runs SwiftLint for code quality
- Checks fidelity vs legacy code
- Scans for security vulnerabilities
- Validates requirements met
- Approves or rejects implementation

**Timeout:** 15 minutes per task  
**Max Retries:** 1

---

## 📂 Directory Structure

```
automation/
├── multi-agent/
│   ├── orchestrator.sh          # Master control
│   ├── scripts/
│   │   ├── builder-agent.sh     # Code implementation
│   │   ├── tester-agent.sh      # Build & test validation
│   │   ├── reviewer-agent.sh    # Quality control
│   │   └── extract-legacy-code.sh  # Legacy code extractor
│   ├── context/                 # Shared state (created at runtime)
│   │   ├── agent-state.json     # Real-time agent status
│   │   ├── task-queue.json      # Parsed task queue
│   │   ├── results-log.json     # Completion history
│   │   ├── builder-prompt-*.md  # Implementation prompts
│   │   ├── legacy-ref-*.swift   # Extracted legacy code
│   │   └── *.marker             # Completion markers
│   └── logs/                    # Agent logs (created at runtime)
│       ├── orchestrator.log     # Master log
│       ├── builder-*.log        # Builder logs per task
│       ├── tester-*.log         # Test results per task
│       ├── reviewer-*.log       # Review logs per task
│       ├── review-*.md          # Review reports
│       └── escalation-*.md      # Human intervention requests
└── README.md                    # This file
```

---

## 🚀 Quick Start

### Prerequisites
```bash
# Required
- macOS or Linux
- Swift 5.9+
- Git
- jq (JSON processor)
- Python 3.8+

# Optional but recommended
- Xcode (for full builds)
- SwiftLint (for code quality checks)
- Cursor IDE (for AI code generation)
```

### Installation
```bash
cd ~/director

# Make scripts executable
chmod +x automation/multi-agent/orchestrator.sh
chmod +x automation/multi-agent/scripts/*.sh

# Verify setup
./automation/multi-agent/orchestrator.sh status
```

---

## 🎮 Usage

### Start Full Automation
```bash
# Start the orchestrator
./automation/multi-agent/orchestrator.sh start

# This will:
# 1. Parse EXECUTION_ROADMAP.md
# 2. Create task queue (56 tasks)
# 3. Begin executing tasks in order
# 4. Monitor agent progress
# 5. Auto-retry on failures
# 6. Escalate to human if needed
```

### Monitor Progress
```bash
# View agent status
./automation/multi-agent/orchestrator.sh status

# Watch orchestrator log
tail -f automation/multi-agent/logs/orchestrator.log

# Check current task
jq -r '.builder.current_task' automation/multi-agent/context/agent-state.json

# View task queue
jq '.tasks[] | select(.status == "in_progress")' automation/multi-agent/context/task-queue.json
```

### Resume After Pause
```bash
# If orchestrator paused for human intervention
./automation/multi-agent/orchestrator.sh resume
```

---

## 🔄 Workflow Example

### Complete Task Lifecycle:

```
1. ORCHESTRATOR assigns Task 1.1 to Builder Agent
   Status: task-queue.json updated (status: "in_progress")
   
2. BUILDER AGENT starts
   - Reads task from EXECUTION_ROADMAP.md
   - Extracts legacy code (lines 1924-1979)
   - Creates builder-prompt-1.1.md
   - Waits for Cursor to implement
   
3. CURSOR (human or AI) implements
   - Reads builder-prompt-1.1.md
   - Creates DataModels.swift
   - Marks complete: builder-complete-1.1.marker
   
4. BUILDER AGENT completes
   Status: agent-state.json updated (builder: "completed")
   
5. ORCHESTRATOR triggers Tester Agent
   
6. TESTER AGENT validates
   - Checks file exists
   - Runs swift build
   - Runs unit tests
   - Validates checklist
   - Reports PASS
   
7. ORCHESTRATOR triggers Reviewer Agent
   
8. REVIEWER AGENT reviews
   - Runs SwiftLint
   - Checks fidelity
   - Validates security
   - Reports APPROVED
   
9. ORCHESTRATOR marks complete
   - Runs create-module-pr.sh
   - Updates results-log.json
   - Moves to next task (1.2)
```

---

## 🔧 Configuration

### Timeouts (in orchestrator.sh)
```bash
BUILDER_TIMEOUT=7200   # 2 hours
TESTER_TIMEOUT=1800    # 30 minutes
REVIEWER_TIMEOUT=900   # 15 minutes
```

### Max Retries
```bash
MAX_RETRIES=3  # Per task
```

### Modify these in `orchestrator.sh` if needed.

---

## 📊 Shared Context Files

### agent-state.json
Real-time status of all agents:
```json
{
  "orchestrator": {
    "status": "running",
    "current_stage": 1,
    "current_task": "1.1",
    "last_heartbeat": "2025-10-20T00:00:00Z"
  },
  "builder": {
    "status": "working",
    "current_task": "1.1",
    "started_at": "2025-10-20T00:00:00Z",
    "progress": 50
  },
  "tester": {...},
  "reviewer": {...}
}
```

### task-queue.json
Parsed task list with dependencies:
```json
{
  "tasks": [
    {
      "id": "1.1",
      "name": "Create PromptSegment Type",
      "file": "DataModels.swift",
      "priority": "CRITICAL",
      "status": "in_progress",
      "dependencies": [],
      "assigned_to": "builder",
      "attempts": 0
    },
    ...
  ]
}
```

### results-log.json
Historical completion records:
```json
{
  "tasks": [
    {
      "id": "1.1",
      "status": "completed",
      "completed_at": "2025-10-20T01:00:00Z",
      "builder_time": 1200,
      "tester_result": "passed",
      "reviewer_decision": "approved"
    },
    ...
  ]
}
```

---

## 🚨 Error Handling

### Builder Timeout
```
❌ Builder Agent exceeded 2 hour timeout

Actions taken:
1. Kill builder process
2. Increment retry count
3. If retries < 3: Retry task
4. If retries >= 3: Escalate to human
```

### Test Failure
```
❌ Tester Agent found build errors

Actions taken:
1. Log failure details
2. Reject task
3. Builder retries with fixes
```

### Review Rejection
```
❌ Reviewer Agent found quality issues

Actions taken:
1. Generate review report
2. List specific issues
3. Request changes from Builder
4. Retry implementation
```

### Human Escalation
```
🚨 HUMAN INTERVENTION REQUIRED

When:
- 3+ failed attempts
- Critical blocking error
- Security vulnerability found

Process:
1. Orchestrator pauses
2. Creates escalation-{TASK_ID}.md
3. Sends notification (if configured)
4. Waits for manual resolution
5. Resume with: ./orchestrator.sh resume
```

---

## 🎯 Integration with Cursor

See [CURSOR_INTEGRATION.md](CURSOR_INTEGRATION.md) for detailed instructions.

**Quick version:**
1. Orchestrator creates `builder-prompt-{TASK_ID}.md`
2. Cursor reads prompt and implements code
3. Cursor creates completion marker:
   ```bash
   touch automation/multi-agent/context/builder-complete-{TASK_ID}.marker
   ```
4. Orchestrator continues to testing

---

## 📈 Progress Tracking

### Real-time Status
```bash
# View JSON status
./automation/multi-agent/orchestrator.sh status

# Human-readable summary
./automation/multi-agent/scripts/status-summary.sh
```

### Stage Completion
The system tracks completion by stage:
- Stage 1 (Foundation): 9 tasks
- Stage 2 (Pipeline): 7 tasks
- Stage 3 (AI Service): 6 tasks
- Stage 4 (Persistence): 5 tasks
- Stage 5 (Credits): 7 tasks
- Stage 6 (Video): 10 tasks
- Stage 7 (App Shell): 6 tasks
- Stage 8 (Security): 2 tasks

**Total: 56 tasks**

---

## 🛠️ Utilities

### Extract Legacy Code
```bash
# Extract specific lines
./automation/multi-agent/scripts/extract-legacy-code.sh --lines 1924 1979

# Extract for specific task
./automation/multi-agent/scripts/extract-legacy-code.sh --task 1.1

# Save to file
./automation/multi-agent/scripts/extract-legacy-code.sh --task 1.1 --output PromptSegment.swift

# Preview before extracting
./automation/multi-agent/scripts/extract-legacy-code.sh --task 1.1 --preview
```

---

## 🔍 Troubleshooting

### Problem: Orchestrator won't start
**Solution:**
```bash
# Check for existing state
rm -rf automation/multi-agent/context
rm -rf automation/multi-agent/logs

# Restart fresh
./automation/multi-agent/orchestrator.sh start
```

### Problem: Builder stuck waiting for Cursor
**Solution:**
```bash
# Manually mark complete if code is ready
touch automation/multi-agent/context/builder-complete-{TASK_ID}.marker
```

### Problem: Tests failing repeatedly
**Solution:**
```bash
# Check test logs
cat automation/multi-agent/logs/tester-{TASK_ID}.log

# Fix issues manually
# Then resume
./automation/multi-agent/orchestrator.sh resume
```

### Problem: Want to skip a task
**Solution:**
```bash
# Manually mark task complete in task-queue.json
jq '(.tasks[] | select(.id == "1.5")) |= (.status = "completed")' \
   automation/multi-agent/context/task-queue.json > tmp.json
mv tmp.json automation/multi-agent/context/task-queue.json
```

---

## 📊 Performance Metrics

### Expected Timeline
```
Stage 1 (Foundation):     6-8 hours
Stage 2 (Pipeline):       5-7 hours
Stage 3 (AI Service):     4-6 hours
Stage 4 (Persistence):    3-5 hours
Stage 5 (Credits):        5-7 hours
Stage 6 (Video):          8-12 hours
Stage 7 (App Shell):      4-6 hours
Stage 8 (Security):       2-3 hours

TOTAL: 40-52 hours (estimated)
```

**With automation:**
- 80% tasks complete autonomously
- 20% require human review/fixes
- 3-5 human interventions expected

---

## 🎉 Success Metrics

### Task Completion
- [ ] All 56 tasks completed
- [ ] All builds pass
- [ ] All tests pass
- [ ] All reviews approved
- [ ] All PRs merged

### Quality Metrics
- [ ] Zero security vulnerabilities
- [ ] 100% fidelity with legacy code
- [ ] All edge cases handled
- [ ] Full test coverage

### Automation Metrics
- [ ] <5 human escalations
- [ ] 95%+ autonomous completion rate
- [ ] <5% retry rate

---

## 🔮 Future Enhancements

- [ ] Parallel agent execution (run multiple tasks simultaneously)
- [ ] Claude API integration (direct AI calls instead of Cursor)
- [ ] Cost tracking and estimation
- [ ] Telemetry and analytics
- [ ] Self-healing (auto-debug failures)
- [ ] Continuous deployment to TestFlight

---

## 📞 Support

**Issues?** Create escalation report:
```bash
cat automation/multi-agent/logs/escalation-*.md
```

**Questions?** Check logs:
```bash
ls -ltr automation/multi-agent/logs/
```

---

**Ready to rebuild DirectorStudio autonomously! 🚀**
