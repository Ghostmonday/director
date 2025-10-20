# 🤖 DirectorStudio Automation

## Overview

This directory contains automation scripts and workflows for post-module PR creation, BugBot review, and auto-merge functionality.

---

## 📁 Structure

```
automation/
├── scripts/
│   └── create-module-pr.sh    # Manual PR creation script
├── logs/
│   └── pr-tracker.md          # Auto-generated PR tracking log
└── README.md                  # This file
```

---

## 🚀 How It Works

### 1. Post-Module PR Creation

After validating a module locally, create an automated PR:

```bash
./automation/scripts/create-module-pr.sh <module-name>
```

**Example:**
```bash
./automation/scripts/create-module-pr.sh RewordingModule
```

**What happens:**
1. Creates branch: `pr/<module-name>-validation-<timestamp>`
2. Commits all changes with structured message
3. Pushes to GitHub
4. GitHub Actions automatically creates PR with labels:
   - `needs-bugbot-review`
   - `auto-pr`

---

### 2. BugBot Review (Automatic)

Once PR is created, GitHub Actions automatically:

1. **Runs Swift Build Check**
   - Ensures code compiles
   - Logs any build errors

2. **Runs SwiftLint (Static Analysis)**
   - Checks code style
   - Detects common issues
   - Reports errors and warnings

3. **Runs Custom BugBot Checks**
   - No hardcoded API keys
   - Minimal force unwraps
   - Public APIs documented
   - No print statements in production

4. **Generates Report**
   - Posts detailed report as PR comment
   - Updates PR labels based on results

---

### 3. Post-Review Logic

#### ✅ If BugBot Passes:
- PR labeled: `bugbot-approved`, `ready-to-merge`
- Auto-merge triggered with squash strategy
- Branch automatically deleted
- Log updated: `automation/logs/pr-tracker.md`

#### ❌ If BugBot Detects Issues:
- PR labeled: `bugbot-issues`, `needs-fixes`
- Patch branch created: `patch/<module-name>-bugfix-<timestamp>`
- Issue tagged for human intervention
- Log updated with failure status

---

## 📊 Status Tracking

All PR activity is logged to: **`automation/logs/pr-tracker.md`**

**Log format:**
```markdown
## [Module: RewordingModule]
- PR: #24 opened at 2025-10-20T22:55Z
- Branch: `pr/RewordingModule-validation-1729462500`
- BugBot: ✅ Passed
- Merged: ✅ Yes at 2025-10-20T23:10Z
```

---

## 🚨 Failsafe

If automation fails at any stage:
- GitHub Actions creates an issue: `❗ Automation failed at stage: <step>`
- Labels: `automation-failure`, `urgent`
- Includes link to failed workflow run
- **Manual action required**

---

## 🔧 Configuration

### GitHub Actions Workflow
Location: `.github/workflows/auto-pr-bugbot.yml`

**Triggers:**
- Push to `pr/**` branches
- Pull request opened/updated to `main`

**Permissions Required:**
- `contents: write` - For commits and merges
- `pull-requests: write` - For PR creation/updates
- `issues: write` - For failsafe alerts

---

## 🎯 Integration with Cheetah

### In CHEETAH_EXECUTION_CHECKLIST.md

After each module validation task, add:

```markdown
**🤖 AUTO-PR TRIGGER:**
Once validation is complete, run:
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch
- Trigger BugBot review
- Auto-merge if approved
- Log status to `automation/logs/pr-tracker.md`
```

---

## 📝 Example Workflow

### Step 1: Complete Module
```bash
# Validate module locally
swift build
swift test
```

### Step 2: Create PR
```bash
./automation/scripts/create-module-pr.sh RewordingModule
```

### Step 3: Automation Takes Over
- ✅ PR created automatically
- ✅ BugBot review triggered
- ✅ Results posted as comment
- ✅ Auto-merge if approved
- ✅ Status logged

### Step 4: Check Status
```bash
cat automation/logs/pr-tracker.md
```

---

## 🔍 BugBot Checks

### Build Check
- Runs `swift build`
- Fails if compilation errors

### SwiftLint
- Code style enforcement
- Common Swift issues
- Configurable rules

### Custom Checks
1. **API Key Security**
   - Scans for `sk-` patterns
   - Ensures no hardcoded secrets

2. **Force Unwraps**
   - Counts `!` usage
   - Warns if excessive

3. **Documentation**
   - Checks public API docs
   - Ensures `///` comments

4. **Logging**
   - Detects `print()` statements
   - Recommends proper logging

---

## 🛠️ Troubleshooting

### PR not created?
- Check branch name format: `pr/<name>-validation-<timestamp>`
- Ensure changes are committed
- Verify GitHub Actions enabled

### BugBot not running?
- Check PR has `needs-bugbot-review` label
- Verify workflow file exists
- Check GitHub Actions logs

### Auto-merge not working?
- Ensure PR has `bugbot-approved` label
- Check branch protection rules
- Verify merge permissions

---

## 📚 Additional Resources

- **GitHub Actions Docs:** https://docs.github.com/actions
- **SwiftLint:** https://github.com/realm/SwiftLint
- **PR Automation Best Practices:** [Internal Wiki]

---

**Last Updated:** October 20, 2025  
**Maintained By:** DirectorStudio Team

