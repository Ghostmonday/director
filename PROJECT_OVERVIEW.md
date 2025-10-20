# 🚀 DirectorStudio Reconstruction - START HERE

> **Cheetah:** This is your primary instruction document. Everything you need is here.

---

## 📖 Quick Context

You're rebuilding a dismantled video production pipeline. The legacy codebase (31,787 lines in `xxx.txt`) was modularized, but critical infrastructure was left behind.

**Current Status:**
- ✅ **6 Core Modules** - All validated and functional
- ⚠️ **Missing Infrastructure** - Pipeline orchestration, AI service, persistence, UI

**Your Job:**
Integrate the missing pieces from `xxx.txt` into the modern modular architecture.

---

## 📚 How to Use This Repo

### Files You'll Work With:

1. **`CHEETAH_EXECUTION_CHECKLIST.md`** ← Your task-by-task checklist (START HERE)
2. **`xxx.txt`** ← Legacy codebase (reference for implementations)
3. **`core.swift`** ← Core hub (you'll extend this)
4. **`rewording.swift`, `segmentation.swift`, etc.** ← Modules (you'll update these)

### Files for Reference Only:

- `RECONSTRUCTION_PLAN.md` - Deep technical analysis
- `EXECUTIVE_SUMMARY.md` - High-level overview
- `ARCHITECTURE_MAP.md` - Visual diagrams
- `STRATEGIC_ENHANCEMENTS_SUMMARY.md` - Telemetry, monetization, localization, accessibility

---

## 🎯 Your Workflow

### Step 1: Read the Checklist
Open `CHEETAH_EXECUTION_CHECKLIST.md` and start with **Stage 1, Task 1.1**.

### Step 2: Reference Legacy Code
For each task, the checklist tells you exactly which lines to read from `xxx.txt`.

**Example:**
```
Task 1.1: Create PromptSegment Type
📚 Reference Legacy Code:
- Read `xxx.txt` lines 1924-1979 for exact definition
```

### Step 3: Implement with Fidelity
Every task has a **🎯 FIDELITY REMINDER**:
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

### Step 4: Validate After Each Module
Every task has a **Validation** checklist:
```
Validation:
- [ ] File compiles without errors
- [ ] Can instantiate module
- [ ] Can call validate()
```

Run these checks before moving to the next task.

---

## 🚨 CRITICAL PATH (Do These First)

1. ✅ **Task 1.1** - Create PromptSegment (BLOCKING)
2. ✅ **Task 1.2** - Create PipelineContext (BLOCKING)
3. ✅ **Task 1.3** - Create MockAIService (BLOCKING)
4. ✅ **Task 1.4-1.8** - Update all 6 modules
5. ✅ **Task 1.9** - Validate Stage 1
6. **Task 2.2** - Create PipelineOrchestrator
7. **Task 3.2** - Create AIService
8. **Task 3.1** - Create KeychainService

**Everything else can be done in parallel or later.**

---

## 📊 What You're Building

### Current Architecture (Exists):
```
DirectorStudioCore
├── RewordingModule (7 transformation types)
├── SegmentationModule (intelligent pacing)
├── StoryAnalysisModule (8-phase analysis)
├── TaxonomyModule (cinematic enrichment)
├── ContinuityModule (validation & tracking)
└── PackagingModule (final assembly)
```

### Missing Infrastructure (Your Job):
```
PipelineOrchestrator ← Executes modules end-to-end
├── PipelineConfiguration ← Module settings & presets
├── AIService ← Real API calls (DeepSeek)
├── KeychainService ← Secure API key storage
├── PersistenceController ← CoreData for projects
├── CreditsService ← Monetization system
└── UI Layer ← SwiftUI views
```

---

## ⏱️ Execution Strategy

- **No Time Estimates:** Work is structured around functional completion, not time
- **Stop Markers:** "🛑 STOP FOR USER TESTING" after each module/feature
- **User Testing Required:** Build and test in Xcode after each stop marker
- **Iterative Validation:** Ensures quality at every step, not just at the end
- **Strategic Enhancements:** Telemetry, monetization, localization, accessibility integrated throughout

---

## 🎯 Success Criteria

When you're done, the system should:
- ✅ Compile without errors
- ✅ Execute all 6 modules end-to-end
- ✅ Make real AI API calls (DeepSeek for text, Pollo for video)
- ✅ Save/load projects from CoreData
- ✅ Handle credits and purchases with dynamic pricing
- ✅ Generate and assemble video clips from prompts
- ✅ Have a functional SwiftUI interface with onboarding
- ✅ Track telemetry (opt-in, privacy-first)
- ✅ Support localization scaffolding (6 languages)
- ✅ Meet accessibility standards (WCAG 2.1)
- ✅ Pass comprehensive security audit

---

## 🚀 Ready to Start?

1. Open `CHEETAH_EXECUTION_CHECKLIST.md`
2. Start with **Stage 1, Task 1.1**
3. Reference `xxx.txt` for implementations
4. Validate after each module
5. Move to the next task

**Let's rebuild this thing! 🔥**

