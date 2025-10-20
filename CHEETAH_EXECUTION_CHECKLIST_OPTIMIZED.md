# Cheetah Execution Checklist - v2.1 (Audit-Enhanced)

## 📚 IMPORTANT: Reference Legacy Code

**Before starting any task, read the relevant sections from `xxx.txt`**

The legacy codebase (31,787 lines) contains:
- ✅ Working implementations to reference
- ✅ Exact type definitions
- ✅ Proven patterns and logic
- ✅ Edge cases and error handling

**Key sections to reference:**
- Lines 1924-1979: `PromptSegment` definition
- Lines 4373-4620: `PipelineModule` protocol and types
- Lines 3088-3242: `PipelineConfig` implementation
- Lines 3722-4372: `PipelineManager` orchestration logic
- Lines 9152-9273: `DeepSeekService` AI implementation

**Don't reinvent - reference and adapt the working code!**

---

## 🎯 OPTIMIZATION FEATURES FOR AI AGENTS

### 🧠 **Low-Cost Model Optimizations**
- **Explicit Instructions:** All tasks have clear, unambiguous requirements
- **Reference Anchors:** Line numbers provided for exact code locations
- **Fidelity Reminders:** Prevents simplification or feature loss
- **Validation Checklists:** Binary yes/no validation steps
- **Module Names:** Consistent naming for automation scripts

### 🤖 **Automation Integration**
- **AUTO-PR Triggers:** Every module task includes script execution
- **Module Names:** Explicit for script parameter passing
- **BugBot Integration:** Automated quality gates
- **Sequential Flow:** Clear dependencies and blocking tasks

### 🎨 **UI/UX Compliance Framework**
- **Responsive Design:** All iPhone sizes (iPhone SE to iPhone 15 Pro Max)
- **Accessibility:** VoiceOver, Dynamic Type, High Contrast
- **iPadOS Compatibility:** Adaptive layouts where feasible
- **Apple HIG:** Human Interface Guidelines adherence

---

## 🚀 STAGE 1: FOUNDATION (CRITICAL - START HERE)

### Task 1.1: Create PromptSegment Type ⚠️ BLOCKING
**File:** `DataModels.swift`
**Priority:** 🔴 CRITICAL
**Module Name:** `PromptSegment`
**Estimated Complexity:** Low
**Dependencies:** None

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**📚 Reference Legacy Code:**
- Read `xxx.txt` lines 1924-1979 for exact `PromptSegment` definition
- Read `xxx.txt` lines 5089-5589 for usage examples in modules

```swift
// Create new file: DataModels.swift
// Add PromptSegment struct (copy from legacy lines 1924-1979)
// Add PacingType enum
// Add TransitionType enum
// Ensure Sendable + Codable conformance
```

**Validation Checklist:**
- [ ] File compiles without errors
- [ ] Run `swift test --filter PromptSegment`
- [ ] Types are Sendable (for concurrency)
- [ ] Types are Codable (for persistence)
- [ ] Enums have all cases from legacy code
- [ ] Struct matches legacy definition exactly

# AUTO-SYNC STEP
git fetch origin main && git merge origin/main --no-edit

**🤖 AUTO-PR TRIGGER:**
```bash
./automation/scripts/create-module-pr.sh PromptSegment
```
This will automatically create PR branch, trigger BugBot review, and handle merge.

**⏸️ WAIT for BugBot approval before proceeding**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, test in Xcode:
- [ ] Build project successfully
- [ ] Run compilation checks
- [ ] Verify no type errors
- [ ] Confirm module is ready for next task

---

### Task 1.2: Create PipelineContext ⚠️ BLOCKING
**File:** `PipelineTypes.swift` (new)
**Priority:** 🔴 CRITICAL
**Module Name:** `PipelineContext`
**Estimated Complexity:** Low
**Dependencies:** Task 1.1 complete

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**📚 Reference Legacy Code:**
- Read `xxx.txt` lines 4432-4456 for exact `PipelineContext` definition
- Read `xxx.txt` lines 4458-4523 for `PipelineError` enum

```swift
// Create PipelineTypes.swift
// Add PipelineContext struct (copy from legacy lines 4432-4456)
// Add PipelineError enum (copy from legacy lines 4458-4523)
// Ensure Sendable conformance for async operations
```

**Validation Checklist:**
- [ ] File compiles without errors
- [ ] Run `swift test --filter PipelineContext`
- [ ] PipelineContext matches legacy structure
- [ ] PipelineError enum complete
- [ ] Sendable conformance added
- [ ] Can be imported by other modules

# AUTO-SYNC STEP
git fetch origin main && git merge origin/main --no-edit

**🤖 AUTO-PR TRIGGER:**
```bash
./automation/scripts/create-module-pr.sh PipelineContext
```

**⏸️ WAIT for BugBot approval**

**🛑 STOP FOR USER TESTING:**
- [ ] Build project successfully
- [ ] Verify PipelineContext instantiation
- [ ] Confirm error types work

---

### Task 1.3: Create MockAIService ⚠️ BLOCKING
**File:** `MockServices.swift` (new)
**Priority:** 🔴 CRITICAL
**Module Name:** `MockAIService`
**Estimated Complexity:** Medium
**Dependencies:** Task 1.2 complete

**🎯 FIDELITY REMINDER:**
- Create mock service for testing without real API calls
- Match AIServiceProtocol interface
- Provide deterministic responses for validation
- Don't implement real API logic here

**Implementation:**
```swift
// Create MockServices.swift
// Implement AIServiceProtocol with mock responses
// Return predefined test data
// Enable/disable via configuration
```

**Validation Checklist:**
- [ ] Implements AIServiceProtocol correctly
- [ ] Run `swift test --filter MockAIService`
- [ ] Returns consistent mock responses
- [ ] Can be toggled on/off
- [ ] No real API calls made

# AUTO-SYNC STEP
git fetch origin main && git merge origin/main --no-edit

**🤖 AUTO-PR TRIGGER:**
```bash
./automation/scripts/create-module-pr.sh MockAIService
```

**⏸️ WAIT for BugBot approval**

**🛑 STOP FOR USER TESTING:**
- [ ] Build project successfully
- [ ] Test mock service instantiation
- [ ] Verify mock responses work

---

### Task 1.4: Update Rewording Module ⚠️ BLOCKING
**File:** `rewording.swift`
**Priority:** 🔴 CRITICAL
**Module Name:** `RewordingModule`
**Estimated Complexity:** Medium
**Dependencies:** Tasks 1.1-1.3 complete

**🎯 FIDELITY REMINDER:**
- Reference legacy RewordingModule implementation
- Maintain all 7 transformation types
- Preserve validation logic
- Update for new architecture

**📚 Reference Legacy Code:**
- Search `xxx.txt` for RewordingModule implementation
- Look for transformation types and validation

**Implementation:**
```swift
// Update RewordingModule to conform to new ModuleProtocol
// Maintain all 7 transformation types from legacy
// Update validation logic
// Integrate with MockAIService for testing
```

**Validation Checklist:**
- [ ] All 7 transformation types preserved
- [ ] Run `swift test --filter RewordingModule`
- [ ] Validation logic works
- [ ] Integrates with MockAIService
- [ ] Can execute rewording operations

# AUTO-SYNC STEP
git fetch origin main && git merge origin/main --no-edit

**🤖 AUTO-PR TRIGGER:**
```bash
./automation/scripts/create-module-pr.sh RewordingModule
```

**⏸️ WAIT for BugBot approval**

**🛑 STOP FOR USER TESTING:**
- [ ] Build project successfully
- [ ] Test rewording with mock service
- [ ] Verify all 7 transformation types work

---

### Task 1.5: Build Rewording UI + VALIDATE UX
**File:** `RewordingView.swift` (new)
**Priority:** 🔴 CRITICAL
**Module Name:** `RewordingUI`
**Estimated Complexity:** High
**Dependencies:** Task 1.4 complete

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**📚 Reference Legacy Code:**
- Look for existing UI patterns in legacy codebase
- Adapt for SwiftUI architecture

**UI Requirements:**
```swift
// Create RewordingView.swift with:
// - Text input field (multiline)
// - Transformation type picker (7 options)
// - Preview of reworded text
// - Execute button
// - Loading state
// - Error handling display
```

**🎨 UX/UI Compliance:**
- [ ] **Responsive:** Works on all iPhone sizes (SE to 15 Pro Max)
- [ ] **Accessibility:** VoiceOver labels, Dynamic Type support
- [ ] **Contrast:** High contrast ratios (4.5:1 minimum)
- [ ] **HIG:** Apple Human Interface Guidelines followed
- [ ] **iPadOS:** Adaptive layout (if feasible)
- [ ] **Navigation:** Proper tab/stack navigation

**Validation Checklist:**
- [ ] UI compiles without errors
- [ ] Can instantiate RewordingView
- [ ] All controls functional
- [ ] Loading states work
- [ ] Error states handled
- [ ] Accessibility Inspector passes
- [ ] Dark Mode verified
- [ ] VoiceOver labels accurate
- [ ] **RUN IN XCODE:** Build and run, test full flow

# AUTO-SYNC STEP
git fetch origin main && git merge origin/main --no-edit

**🤖 AUTO-PR TRIGGER:**
```bash
./automation/scripts/create-module-pr.sh RewordingUI
```

**⏸️ WAIT for BugBot approval**

**🛑 STOP FOR USER TESTING:**
- [ ] Build and run in Xcode
- [ ] Test on multiple device sizes
- [ ] Verify VoiceOver works
- [ ] Check Dynamic Type scaling
- [ ] Confirm responsive layout

---

## 📋 CRITICAL PATH (UPDATED FOR OPTIMIZATION)

**START HERE - Execute in this exact order:**

1. ✅ **Task 1.1:** Create PromptSegment Type (Foundation)
2. ✅ **Task 1.2:** Create PipelineContext (Foundation)
3. ✅ **Task 1.3:** Create MockAIService (Testing)
4. ✅ **Task 1.4:** Update Rewording Module (Core Logic)
5. ✅ **Task 1.5:** Build Rewording UI + VALIDATE UX (UI/UX)

**After Stage 1:**
6. **Task 2.2:** Create PipelineOrchestrator
7. **Task 3.2:** Create AIService
8. **Task 3.1:** Create Secrets Configuration
9. **Task 3.2a:** Create ImageGenerationService

**Everything else can be done in parallel or later.**

---

## ✅ STAGE COMPLETION MARKER
File: STAGE_1_COMPLETE.md
- Auto-generated when all tasks in this stage are validated.
- Used by Cheetah to confirm build progression.

# AUTO-GENERATE STAGE_1_COMPLETE.md after all validation checkboxes are ✅

## 🎯 LOW-COST MODEL OPTIMIZATIONS

### 🧠 **For Budget Models (Claude Haiku, DeepSeek):**

1. **Explicit Line References:**
   - Every task provides exact line numbers to read
   - No searching required - direct copying

2. **Fidelity Anchors:**
   - "Don't simplify" reminders prevent feature loss
   - "Maintain 100%" prevents hallucinations

3. **Validation Checklists:**
   - Binary yes/no questions
   - No ambiguous requirements

4. **Module Name Consistency:**
   - Clear naming prevents confusion
   - Automation scripts use these names

5. **Sequential Dependencies:**
   - Blocking tasks clearly marked
   - No parallel execution ambiguity

### 🚨 **Hallucination Prevention:**

1. **Legacy Code Anchoring:**
   - All tasks reference specific line numbers
   - "Copy from legacy" instructions

2. **Validation Gates:**
   - Each task has explicit validation steps
   - BugBot catches implementation errors

3. **UI/UX Templates:**
   - Specific component requirements listed
   - Accessibility checklist provided

---

## 🚀 EXECUTION GUIDELINES FOR AI AGENTS

### 🤖 **Cheetah Execution Protocol:**

1. **Read Task Completely** - Don't skip sections
2. **Reference Legacy Code** - Read specified line numbers first
3. **Follow Fidelity Reminders** - Don't simplify or change logic
4. **Complete Validation Checklist** - Check all boxes
5. **Run AUTO-PR Trigger** - Use exact module name
6. **Wait for BugBot** - Don't proceed until approved
7. **User Testing** - Wait for human validation

### 🎯 **Success Metrics:**

- [ ] All 56 tasks completed successfully
- [ ] Every module has AUTO-PR and BugBot approval
- [ ] UI/UX compliance verified on all screens
- [ ] Responsive design tested on multiple devices
- [ ] Accessibility features functional
- [ ] App builds and runs without errors
- [ ] All automation triggers executed

---

## 📊 STAGE OVERVIEW

| Stage | Tasks | Focus | UI/UX Compliance |
|-------|-------|-------|------------------|
| **1: Foundation** | 5 tasks | Core types, modules | Basic validation |
| **2: Pipeline** | 8 tasks | Orchestration, config | Progress views |
| **3: AI Service** | 6 tasks | API integration | Settings UI |
| **4: Persistence** | 5 tasks | Data storage | Project management |
| **5: Credits** | 7 tasks | Monetization | Purchase flow |
| **6: Video** | 10 tasks | Generation, assembly | Complex UI |
| **7: App Shell** | 6 tasks | Navigation, onboarding | Full compliance |
| **8: Security** | 2 tasks | Audit, docs | N/A |

---

## 🎨 UI/UX COMPLIANCE FRAMEWORK

### 📱 **Responsive Design Requirements:**
- **iPhone SE (4.7"):** Minimum target, optimize for small screens
- **iPhone 15 Pro Max (6.7"):** Maximum target, ensure no wasted space
- **All iPhone sizes:** Test on iPhone 8, 11, 13, 14, 15 variants

### ♿ **Accessibility Requirements:**
- **VoiceOver:** All interactive elements have labels and hints
- **Dynamic Type:** Support all text size scales (xs to xxxl)
- **High Contrast:** 4.5:1 minimum contrast ratios
- **Reduce Motion:** Respect user preferences
- **Color Blindness:** Don't rely on color alone

### 📱 **iPadOS Compatibility:**
- **Adaptive Layouts:** Use size classes where possible
- **Split View:** Support multitasking if applicable
- **Pointer Interactions:** Hover states and cursor changes

### 🎯 **Apple HIG Compliance:**
- **Typography:** Use system fonts and text styles
- **Spacing:** Consistent margins and padding
- **Colors:** System colors with semantic meanings
- **Components:** Native SwiftUI components preferred

---

## ✅ STAGE COMPLETION MARKER
File: STAGE_2_COMPLETE.md
- Auto-generated when all tasks in this stage are validated.
- Used by Cheetah to confirm build progression.

# AUTO-GENERATE STAGE_2_COMPLETE.md after all validation checkboxes are ✅

## ✅ STAGE COMPLETION MARKER
File: STAGE_3_COMPLETE.md
- Auto-generated when all tasks in this stage are validated.
- Used by Cheetah to confirm build progression.

# AUTO-GENERATE STAGE_3_COMPLETE.md after all validation checkboxes are ✅

## ✅ STAGE COMPLETION MARKER
File: STAGE_4_COMPLETE.md
- Auto-generated when all tasks in this stage are validated.
- Used by Cheetah to confirm build progression.

# AUTO-GENERATE STAGE_4_COMPLETE.md after all validation checkboxes are ✅

## ✅ STAGE COMPLETION MARKER
File: STAGE_5_COMPLETE.md
- Auto-generated when all tasks in this stage are validated.
- Used by Cheetah to confirm build progression.

# AUTO-GENERATE STAGE_5_COMPLETE.md after all validation checkboxes are ✅

## 🧾 FINAL PRE-SUBMISSION CHECKLIST
- [ ] STAGE_COMPLETION_REPORT.md generated
- [ ] DeepSeqAPIKey & PolloAPIKey verified for all build configs
- [ ] No storyboard or unused asset references
- [ ] All validations timestamped in STAGE_COMPLETION_REPORT.md

---

**Ready for optimized Cheetah execution!** 🚀

**Start with Stage 1, Task 1.1 and follow the critical path.**
