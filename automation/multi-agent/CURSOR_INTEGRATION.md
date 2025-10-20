# 🎯 CURSOR AGENT INTEGRATION - Builder Agent

## Overview
This document explains how Cursor AI agents interact with the multi-agent orchestration system.

---

## 🔄 Integration Flow

```
Orchestrator → Builder Agent → [CURSOR READS THIS] → Implements Code → Marks Complete
```

---

## 📋 What Cursor Should Do

### 1. **Watch for Implementation Prompts**
The Builder Agent creates files at:
```
automation/multi-agent/context/builder-prompt-{TASK_ID}.md
```

### 2. **Read the Prompt**
Each prompt contains:
- Task ID and name
- Target file to create/modify
- Legacy code reference (if applicable)
- Fidelity requirements
- Implementation instructions

### 3. **Implement the Task**
- Read the legacy code reference (if provided)
- Create or modify the target file
- Follow all fidelity requirements
- Ensure code compiles
- Add proper error handling

### 4. **Mark Completion**
When done, create a marker file:
```bash
touch automation/multi-agent/context/builder-complete-{TASK_ID}.marker
```

---

## 📝 Example Workflow

### Step 1: Builder Agent Creates Prompt
```markdown
# automation/multi-agent/context/builder-prompt-1.1.md

# Task Implementation Request

## Task ID: 1.1
## Task Name: Create PromptSegment Type
## Target File: DataModels.swift

## Requirements
🎯 **FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
...

## Legacy Code Reference
```swift
struct PromptSegment: Codable, Sendable {
    let text: String
    let pacing: PacingType
    ...
}
```

## Instructions from Roadmap
Create DataModels.swift with PromptSegment struct...
```

### Step 2: Cursor Reads and Implements
```swift
// Cursor creates: DataModels.swift
import Foundation

struct PromptSegment: Codable, Sendable {
    let text: String
    let pacing: PacingType
    let transition: TransitionType
    // ... full implementation
}

enum PacingType: String, Codable {
    case slow, medium, fast
}
...
```

### Step 3: Cursor Marks Complete
```bash
touch automation/multi-agent/context/builder-complete-1.1.marker
```

### Step 4: Orchestrator Continues
- Builder Agent detects completion
- Triggers Tester Agent
- Runs builds and tests
- Triggers Reviewer Agent
- Reviews code quality
- Creates PR if approved

---

## 🤖 Cursor Agent Configuration

### Option A: Manual Monitoring (Recommended for Testing)
```bash
# In one terminal - start orchestrator
cd ~/director
./automation/multi-agent/orchestrator.sh start

# In Cursor - watch for prompts
# When you see a new file in context/ folder:
# 1. Read the prompt
# 2. Implement the code
# 3. Run: touch automation/multi-agent/context/builder-complete-{TASK_ID}.marker
```

### Option B: Automated Monitoring (Advanced)
Create a Cursor rule that watches for prompt files:
```javascript
// .cursor/rules/watch-builder-prompts.js
const fs = require('fs');
const path = require('path');

const contextDir = path.join(__dirname, '../../automation/multi-agent/context');

fs.watch(contextDir, (eventType, filename) => {
    if (filename.startsWith('builder-prompt-') && filename.endsWith('.md')) {
        const taskId = filename.match(/builder-prompt-(.+)\.md/)[1];
        console.log(`New task detected: ${taskId}`);
        
        // Trigger Cursor AI to read prompt and implement
        // This would integrate with Cursor's Agent API
    }
});
```

---

## 🔍 Monitoring Progress

### Check Agent Status
```bash
cat automation/multi-agent/context/agent-state.json | jq
```

### View Current Task
```bash
jq -r '.builder.current_task' automation/multi-agent/context/agent-state.json
```

### Check Builder Progress
```bash
jq -r '.builder.progress' automation/multi-agent/context/agent-state.json
```

### View Logs
```bash
tail -f automation/multi-agent/logs/builder-*.log
```

---

## ⚠️ Important Notes

### 1. **Always Mark Completion**
Without the completion marker, Builder Agent will timeout after 2 hours.

### 2. **Follow Fidelity Requirements**
When a task has a FIDELITY REMINDER, you MUST:
- Copy structure from legacy code
- Preserve all properties and methods
- Keep edge case handling
- Don't simplify or skip features

### 3. **Compile Before Marking Complete**
Always ensure code compiles before marking complete:
```bash
swift build
# or
xcodebuild -scheme DirectorStudio build
```

### 4. **Legacy Code is Gospel**
When legacy code reference is provided, treat it as the authoritative implementation.
Modern improvements are fine, but functionality must match exactly.

---

## 🚨 Troubleshooting

### Problem: Builder Agent Times Out
**Solution:** Mark completion faster, or increase timeout in orchestrator.sh

### Problem: Tester Fails After Completion
**Solution:** Ensure code compiles before marking complete. Run local tests first.

### Problem: Reviewer Rejects Code
**Solution:** Check review report in `logs/review-{TASK_ID}.md` for specific issues.

### Problem: Can't Find Prompt File
**Solution:** Check that orchestrator is running and Builder Agent was triggered.

---

## 📊 Integration Status Tracking

The orchestrator maintains real-time status in `agent-state.json`:

```json
{
  "builder": {
    "status": "working",
    "current_task": "1.1",
    "started_at": "2025-10-20T00:00:00Z",
    "progress": 50,
    "last_output": null
  }
}
```

**Statuses:**
- `idle` - Waiting for work
- `working` - Implementing task
- `completed` - Task done successfully
- `failed` - Task failed

---

## 🎯 Success Criteria

For Builder Agent integration to work:
1. ✅ Cursor reads prompt files
2. ✅ Cursor implements code correctly
3. ✅ Cursor marks completion
4. ✅ Code compiles without errors
5. ✅ Code passes all tests
6. ✅ Code meets fidelity requirements

---

**Ready to integrate! Start the orchestrator and watch for prompt files.** 🚀
