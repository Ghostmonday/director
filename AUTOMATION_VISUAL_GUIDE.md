# 🤖 GitHub + BugBot Automation - Visual Guide

## 🔄 Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    MODULE DEVELOPMENT                            │
│  Cheetah completes module → Local validation → All tests pass   │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   TRIGGER AUTOMATION                             │
│  $ ./automation/scripts/create-module-pr.sh <ModuleName>        │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              GITHUB ACTIONS: CREATE PR                           │
│  • Creates PR to main with BugBot labels                        │
│  • Logs to automation/logs/pr-tracker.md                        │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              BUGBOT REVIEW (3 CHECKS)                            │
│  ✅ Swift Build  →  ✅ SwiftLint  →  ✅ Security               │
└────────────────────────┬────────────────────────────────────────┘
                         │
                ┌────────┴────────┐
                │                 │
                ▼                 ▼
    ┌───────────────────┐   ┌───────────────────┐
    │   ✅ PASS         │   │   ❌ FAIL         │
    │   Auto-merge      │   │   Patch branch    │
    └───────────────────┘   └───────────────────┘
```

## 🎯 Quick Start

```bash
# After module validation:
./automation/scripts/create-module-pr.sh RewordingModule

# Check status:
cat automation/logs/pr-tracker.md

# View PRs:
open https://github.com/Ghostmonday/director/pulls
```

## 📊 What Gets Checked

| Check | What | Severity |
|-------|------|----------|
| Build | `swift build` | ❌ Blocking |
| SwiftLint | Code style | ⚠️ Warning |
| API Keys | No hardcoded secrets | ❌ Blocking |
| Force Unwraps | Minimal `!` usage | ⚠️ Warning |
| Docs | Public APIs documented | ⚠️ Warning |
| Logging | No `print()` statements | ⚠️ Warning |

## ✅ Success Flow

1. **PR Created** → `pr/ModuleName-validation-<timestamp>`
2. **BugBot Runs** → All checks pass ✅
3. **Auto-Merge** → Squash merge to main
4. **Branch Deleted** → Cleanup automatic
5. **Log Updated** → Status tracked

## ❌ Failure Flow

1. **PR Created** → `pr/ModuleName-validation-<timestamp>`
2. **BugBot Runs** → Issues detected ❌
3. **Patch Branch** → `patch/ModuleName-bugfix-<timestamp>`
4. **Human Notified** → Manual fixes needed
5. **Log Updated** → Status tracked

## 🚨 Failsafe

If automation fails:
- ✅ GitHub issue created automatically
- ✅ Labels: `automation-failure`, `urgent`
- ✅ Includes workflow logs
- ✅ Manual action required

---

**Ready to use! 🚀**

