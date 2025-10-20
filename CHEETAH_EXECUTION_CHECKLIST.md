# Cheetah Execution Checklist - DirectorStudio Reconstruction

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

## 🚀 STAGE 1: FOUNDATION (CRITICAL - START HERE)

### Task 1.1: Create PromptSegment Type ⚠️ BLOCKING
**File:** `DataModels.swift`
**Priority:** 🔴 CRITICAL
**Module Name:** `PromptSegment`

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

**Validation:**
- [ ] File compiles
- [ ] Types are Sendable
- [ ] Types are Codable
- [ ] Enums have all cases from legacy


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.2: Create PipelineContext ⚠️ BLOCKING
**File:** Update `continuity.swift` or create `PipelineTypes.swift`
**Priority:** 🔴 CRITICAL
**Module Name:** `PipelineContext`

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**📚 Reference Legacy Code:**
- Read `xxx.txt` lines 4432-4456 for exact `PipelineContext` definition
- Read `xxx.txt` lines 4458-4523 for `PipelineError` enum

```swift
// Add PipelineContext struct (copy from legacy lines 4432-4456)
public struct PipelineContext: Sendable {
    public let sessionID: UUID
    public let config: PipelineConfiguration?
    public var metadata: [String: String]
}
```

**Validation:**
- [ ] Struct compiles
- [ ] Sendable conformance
- [ ] Used in at least one module


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.3: Create MockAIService ⚠️ BLOCKING
**File:** `core.swift` or new `MockServices.swift`
**Priority:** 🔴 CRITICAL
**Module Name:** `MockAIService`

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

```swift
// Implement AIServiceProtocol with mock responses
public actor MockAIService: AIServiceProtocol {
    public var isAvailable: Bool { true }
    public func sendRequest(...) async throws -> String {
        // Return mock response
    }
    public func healthCheck() async -> Bool { true }
}
```

**Validation:**
- [ ] Conforms to AIServiceProtocol
- [ ] Returns reasonable mock data
- [ ] Can be used in tests


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.4: Update rewording.swift + VALIDATE
**File:** `rewording.swift`
**Priority:** 🔴 CRITICAL
**Module Name:** `RewordingModule`

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**Steps:**
1. Update Input/Output types to use PromptSegment
2. Update execute() signature to include PipelineContext
3. Fix compilation errors
4. **VALIDATE:** Run `swiftc -parse core.swift rewording.swift`
5. **VALIDATE:** Test instantiation
6. Mark module complete

**Validation:**
- [ ] File compiles without errors
- [ ] Can instantiate RewordingModule
- [ ] Can call validate()


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.4b: Build Rewording UI + VALIDATE UX
**File:** `RewordingView.swift` (new)
**Priority:** 🔴 CRITICAL
**Module Name:** `RewordingUI`

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create RewordingView.swift with:
// - Text input field (multiline)
// - Transformation type picker (7 types)
// - "Transform" button
// - Loading indicator
// - Result display with before/after comparison
// - Copy to clipboard button
```

**UX Flow:**
1. User enters text
2. Selects transformation type
3. Taps "Transform"
4. Sees loading state
5. Views result with original for comparison
6. Can copy result

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate RewordingView
- [ ] All 7 transformation types appear in picker
- [ ] Text input accepts multiline text
- [ ] Transform button triggers module execution
- [ ] Loading state displays during processing
- [ ] Result displays correctly
- [ ] Copy button works
- [ ] **RUN IN XCODE:** Build and run, test full flow


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.5: Update segmentation.swift + VALIDATE
**File:** `segmentation.swift`
**Priority:** 🔴 CRITICAL
**Module Name:** `SegmentationModule`

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**Steps:**
1. Update to use PromptSegment (already similar)
2. Update execute() signature to include PipelineContext
3. Fix compilation errors
4. **VALIDATE:** Run `swiftc -parse core.swift segmentation.swift`
5. **VALIDATE:** Test instantiation
6. Mark module complete

**Validation:**
- [ ] File compiles without errors
- [ ] Can instantiate SegmentationModule
- [ ] Can call validate()


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.5b: Build Segmentation UI + VALIDATE UX
**File:** `SegmentationView.swift` (new)
**Priority:** 🔴 CRITICAL
**Module Name:** `SegmentationUI`

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create SegmentationView.swift with:
// - Story text input (large multiline)
// - Target duration slider (30s - 300s)
// - Pacing preference picker (balanced/dynamic/cinematic)
// - "Segment Story" button
// - Loading indicator
// - Segment list with timeline visualization
// - Each segment shows: duration, pacing, transition type
// - Tap segment to expand details
```

**UX Flow:**
1. User enters story text
2. Adjusts target duration
3. Selects pacing preference
4. Taps "Segment Story"
5. Sees loading state with progress
6. Views timeline of segments
7. Can tap each segment for details
8. Can adjust and re-segment

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate SegmentationView
- [ ] Text input accepts long stories
- [ ] Duration slider works (30-300s range)
- [ ] Pacing picker shows all options
- [ ] Segment button triggers module
- [ ] Timeline visualization renders
- [ ] Segments display with correct data
- [ ] Tap-to-expand works
- [ ] **RUN IN XCODE:** Build and run, test full flow


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.6: Update storyanalysis.swift + VALIDATE
**File:** `storyanalysis.swift`
**Priority:** 🔴 CRITICAL
**Module Name:** `StoryAnalysisModule`

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**Steps:**
1. Update Input/Output types to use PromptSegment
2. Update execute() signature to include PipelineContext
3. Fix compilation errors
4. **VALIDATE:** Run `swiftc -parse core.swift storyanalysis.swift`
5. **VALIDATE:** Test instantiation
6. Mark module complete

**Validation:**
- [ ] File compiles without errors
- [ ] Can instantiate StoryAnalysisModule
- [ ] Can call validate()


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.6b: Build Story Analysis UI + VALIDATE UX
**File:** `StoryAnalysisView.swift` (new)
**Priority:** 🔴 CRITICAL
**Module Name:** `StoryAnalysisUI`

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create StoryAnalysisView.swift with:
// - Story text input
// - "Analyze Story" button
// - Loading indicator with phase progress (8 phases)
// - Tabbed results view:
//   • Overview (genre, themes, tone)
//   • Characters (entities with relationships)
//   • Structure (acts, plot points)
//   • Emotional Arc (graph visualization)
//   • Themes & Symbols
//   • Pacing Analysis
//   • Dialogue Insights
//   • Recommendations
```

**UX Flow:**
1. User enters story
2. Taps "Analyze Story"
3. Sees 8-phase progress indicator
4. Views comprehensive analysis in tabs
5. Can navigate between analysis sections
6. Can export analysis as JSON

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate StoryAnalysisView
- [ ] Text input works
- [ ] 8-phase progress displays correctly
- [ ] All tabs render with data
- [ ] Character relationships visualize
- [ ] Emotional arc graph displays
- [ ] Navigation between tabs smooth
- [ ] Export functionality works
- [ ] **RUN IN XCODE:** Build and run, test full flow


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.7: Update taxonomy.swift + VALIDATE
**File:** `taxonomy.swift`
**Priority:** 🔴 CRITICAL
**Module Name:** `TaxonomyModule`

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**Steps:**
1. Verify PromptSegment usage (already uses it)
2. Update execute() signature to include PipelineContext
3. Fix compilation errors
4. **VALIDATE:** Run `swiftc -parse core.swift taxonomy.swift`
5. **VALIDATE:** Test instantiation
6. Mark module complete

**Validation:**
- [ ] File compiles without errors
- [ ] Can instantiate CinematicTaxonomyModule
- [ ] Can call validate()


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.7b: Build Taxonomy UI + VALIDATE UX
**File:** `TaxonomyView.swift` (new)
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create TaxonomyView.swift with:
// - Segment list (from previous step)
// - "Enrich with Cinematic Data" button
// - Loading indicator
// - Enhanced segment cards showing:
//   • Shot type with icon
//   • Camera movement with animation preview
//   • Lighting setup with color indicator
//   • Mood/atmosphere tags
// - Visual shot type reference guide
// - Camera movement glossary
```

**UX Flow:**
1. User sees segments from previous step
2. Taps "Enrich with Cinematic Data"
3. Sees loading state
4. Views enriched segments with visual indicators
5. Can tap shot type for reference guide
6. Can tap camera movement for preview
7. Can adjust suggestions manually

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate TaxonomyView
- [ ] Segment cards display enrichment data
- [ ] Shot type icons render correctly
- [ ] Camera movement previews work
- [ ] Lighting indicators show colors
- [ ] Mood tags display
- [ ] Reference guide accessible
- [ ] Manual adjustments save
- [ ] **RUN IN XCODE:** Build and run, test full flow


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.8: Update continuity.swift + VALIDATE
**File:** `continuity.swift`
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**Steps:**
1. Verify PromptSegment usage (already uses it)
2. Verify PipelineContext usage (already uses it)
3. Fix any compilation errors
4. **VALIDATE:** Run `swiftc -parse core.swift continuity.swift`
5. **VALIDATE:** Test instantiation
6. Mark module complete

**Validation:**
- [ ] File compiles without errors
- [ ] Can instantiate ContinuityModule
- [ ] Can call validate()


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.8b: Build Continuity UI + VALIDATE UX
**File:** `ContinuityView.swift` (new)
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create ContinuityView.swift with:
// - Segment timeline with continuity indicators
// - "Validate Continuity" button
// - Real-time validation status (✅/⚠️/❌)
// - Issue list with severity levels
// - Continuity anchors visualization
// - Character tracking across segments
// - Location/time consistency checker
// - Suggested fixes for issues
// - Telemetry insights panel
```

**UX Flow:**
1. User sees segment timeline
2. Taps "Validate Continuity"
3. Sees real-time validation progress
4. Views color-coded continuity status
5. Taps issues to see details
6. Reviews suggested fixes
7. Can apply fixes or override
8. Sees telemetry learning insights

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate ContinuityView
- [ ] Timeline renders with segments
- [ ] Validation runs and updates UI
- [ ] Issue list displays with severity
- [ ] Continuity anchors visualize
- [ ] Character tracking shows
- [ ] Suggested fixes display
- [ ] Apply/override actions work
- [ ] Telemetry panel shows insights
- [ ] **RUN IN XCODE:** Build and run, test full flow


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 1.9: Validation Test
**File:** Create `stage1_validation.swift`
**Priority:** 🔴 CRITICAL

```swift
// Create test file that:
// 1. Instantiates all modules
// 2. Creates sample PromptSegment
// 3. Creates PipelineContext
// 4. Calls validate() on each module
// 5. Prints success
```

**Validation:**
- [ ] Test compiles
- [ ] Test runs without errors
- [ ] All modules instantiate
- [ ] Sample data validates


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

## 🔧 STAGE 2: PIPELINE ORCHESTRATION

### Task 2.1: Create PipelineConfiguration
**File:** `PipelineConfiguration.swift`
**Priority:** 🟡 HIGH

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**📚 Reference Legacy Code:**
- Read `xxx.txt` lines 3088-3242 for complete `PipelineConfig` implementation
- Copy the presets (.default, .quickProcess, .fullProcess)

```swift
// Create configuration class (adapt from legacy lines 3088-3242):
// - Module enable/disable toggles
// - Per-module settings
// - API configuration
// - Presets
```

**Validation:**
- [ ] All toggle properties exist
- [ ] Presets work (.default, .quickProcess, etc.)
- [ ] Validation method works


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 2.2: Create PipelineOrchestrator
**File:** `PipelineOrchestrator.swift`
**Priority:** 🟡 HIGH

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**📚 Reference Legacy Code:**
- Read `xxx.txt` lines 3722-4372 for `PipelineManager` implementation
- Read `xxx.txt` lines 25012-25759 for alternative implementation
- Study the execution flow and error handling patterns

```swift
// Create orchestrator actor (adapt from legacy lines 3722-4372):
// - Module execution sequencing
// - Progress tracking
// - Error handling
// - Cancellation support
```

**Validation:**
- [ ] Can execute single module
- [ ] Can execute full pipeline
- [ ] Progress callbacks work
- [ ] Errors are caught


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 2.2b: Build Pipeline Orchestrator UI + VALIDATE UX
**File:** `PipelineView.swift` (new)
**Priority:** 🟡 HIGH

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create PipelineView.swift with:
// - Story input (large text editor)
// - Pipeline configuration panel:
//   • Module enable/disable toggles (6 modules)
//   • Preset selector (Quick/Full/Custom)
//   • Advanced settings per module
// - "Run Pipeline" button (prominent)
// - Real-time progress view:
//   • Current module indicator
//   • Progress bar per module
//   • Overall pipeline progress
//   • Estimated time remaining
// - Live results preview
// - Cancel button
// - Export options (JSON/PDF)
```

**UX Flow:**
1. User enters story or loads project
2. Configures pipeline (presets or custom)
3. Taps "Run Pipeline"
4. Sees real-time progress through all modules
5. Can cancel at any point
6. Views results as they complete
7. Can export final output

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate PipelineView
- [ ] Module toggles work
- [ ] Preset selector updates config
- [ ] Run button triggers orchestrator
- [ ] Progress updates in real-time
- [ ] All 6 modules execute in sequence
- [ ] Cancel button stops execution
- [ ] Results display correctly
- [ ] Export functionality works
- [ ] **RUN IN XCODE:** Build and run, test full pipeline


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 2.3-2.6: Implement Pipeline Features
**File:** `PipelineOrchestrator.swift`
**Priority:** 🟡 HIGH

**Features to add:**
- [ ] Step-by-step execution
- [ ] Progress tracking (0.0-1.0)
- [ ] Retry logic
- [ ] Timeout handling
- [ ] Cancellation support

**Validation:**
- [ ] Can track progress
- [ ] Retries work
- [ ] Can cancel mid-execution

---

### Task 2.7: Integration Test
**File:** `pipeline_integration_test.swift`
**Priority:** 🟡 HIGH

```swift
// Test full pipeline:
// Story → Reword → Analyze → Segment → Taxonomy → Continuity → Package
```

**Validation:**
- [ ] End-to-end test passes
- [ ] All modules execute
- [ ] Output is valid


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 2.8: Add Telemetry for Pipeline Execution
**File:** `PipelineTelemetryService.swift` (new)
**Priority:** 🟡 MEDIUM

**🎯 FIDELITY REMINDER:**
- Build privacy-first telemetry
- Follow Apple privacy guidelines
- Implement opt-in mechanism
- Anonymize all data

**Implementation:**
```swift
// Create PipelineTelemetryService with:
// - Pipeline execution tracking (start, end, duration)
// - Module performance (time per module, success rate)
// - Error tracking (which module failed, why)
// - User choices (which modules enabled, presets used)
// - Prompt editing behavior (edits made, frequency)
// - Output quality metrics

public actor PipelineTelemetryService {
    func trackPipelineStart(config: PipelineConfiguration)
    func trackModuleExecution(module: String, duration: TimeInterval, success: Bool)
    func trackError(module: String, error: Error)
    func trackUserChoice(modulesEnabled: [String], preset: String)
    func trackPromptEdit(segmentID: UUID, editType: String)
}
```

**Validation:**
- [ ] Telemetry service compiles
- [ ] Tracks pipeline execution
- [ ] Tracks module performance
- [ ] Tracks errors
- [ ] Tracks user choices
- [ ] Privacy compliant


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 2.9: Documentation Milestone - Pipeline System
**File:** `PIPELINE_SYSTEM_DOCS.md` (new)
**Priority:** 🟡 MEDIUM

**Documentation Requirements:**
```markdown
# Pipeline System Documentation

## Architecture
- Pipeline orchestration
- Module sequencing
- Error handling
- Progress tracking

## Configuration
- PipelineConfiguration API
- Presets
- Module toggles

## Modules
- Rewording
- Story Analysis
- Segmentation
- Taxonomy
- Continuity
- Packaging

## Telemetry
- Tracked events
- Performance metrics
- Privacy controls
```

**Validation:**
- [ ] Documentation complete
- [ ] Architecture documented
- [ ] All modules documented
- [ ] Configuration guide clear


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

## 🤖 STAGE 3: AI SERVICE INTEGRATION

### Task 3.1: Create Secrets Configuration (Apple Best Practice)
**Files:** `Secrets.xcconfig`, `Secrets-template.xcconfig`, `.gitignore`, `Info.plist`
**Priority:** 🔴 HIGH

**🎯 FIDELITY REMINDER:**
- Follow Apple security best practices
- Never commit API keys to git
- Use .xcconfig for build-time injection
- Provide template for developers

**Setup Steps:**

**1. Create Secrets-template.xcconfig (committed to git):**
```
// Secrets-template.xcconfig
// Copy this file to Secrets.xcconfig and add your actual API keys

// ⚠️ CRITICAL: Use correct API key for each service
// DeepSeek: Text processing (rewording, story analysis, taxonomy, continuity)
// Pollo: Image generation ONLY

DEEPSEEK_API_KEY = YOUR_DEEPSEEK_API_KEY_HERE
POLLO_API_KEY = YOUR_POLLO_API_KEY_HERE
```

**2. Create Secrets.xcconfig (NOT committed, in .gitignore):**
```
// Secrets.xcconfig
// DO NOT COMMIT THIS FILE

// DeepSeek API Key - For text processing modules
DEEPSEEK_API_KEY = sk-your-actual-deepseek-api-key-here

// Pollo API Key - For image generation ONLY
POLLO_API_KEY = your-actual-pollo-api-key-here
```

**3. Update .gitignore:**
```
# API Keys and Secrets
Secrets.xcconfig
*.xcconfig
!Secrets-template.xcconfig
```

**4. Link .xcconfig to Xcode Project:**
- Open Project Settings
- Select Project (not target)
- Go to Info tab
- Under Configurations, set Secrets.xcconfig for Debug and Release

**5. Update Info.plist:**
```xml
<!-- Text Processing API (DeepSeek) -->
<key>DeepSeekAPIKey</key>
<string>$(DEEPSEEK_API_KEY)</string>

<!-- Image Generation API (Pollo) -->
<key>PolloAPIKey</key>
<string>$(POLLO_API_KEY)</string>
```

**6. Swift Access Pattern:**
```swift
// In AIService.swift (DeepSeek for text processing):
guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "DeepSeekAPIKey") as? String,
      !apiKey.isEmpty,
      apiKey != "YOUR_DEEPSEEK_API_KEY_HERE" else {
    fatalError("DeepSeek API key not configured. See Secrets-template.xcconfig")
}

// In ImageGenerationService.swift (Pollo for images):
guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "PolloAPIKey") as? String,
      !apiKey.isEmpty,
      apiKey != "YOUR_POLLO_API_KEY_HERE" else {
    fatalError("Pollo API key not configured. See Secrets-template.xcconfig")
}
```

**7. Create README Section:**
```markdown
## Developer Setup

### API Key Configuration

DirectorStudio requires TWO API keys:

1. **DeepSeek API Key** - For text processing:
   - Rewording module
   - Story analysis module
   - Taxonomy module
   - Continuity module
   - All text-based AI operations

2. **Pollo API Key** - For image generation ONLY:
   - Image generation module
   - Visual content creation

**Setup Instructions:**
1. Copy `Secrets-template.xcconfig` to `Secrets.xcconfig`
2. Edit `Secrets.xcconfig`:
   - Replace `YOUR_DEEPSEEK_API_KEY_HERE` with your DeepSeek API key
   - Replace `YOUR_POLLO_API_KEY_HERE` with your Pollo API key
3. Build and run

**⚠️ CRITICAL:** Do NOT mix up these API keys. Each service has specific responsibilities.

**Note:** `Secrets.xcconfig` is gitignored and will never be committed.
```

**Validation:**
- [ ] Secrets-template.xcconfig created with BOTH keys
- [ ] Secrets.xcconfig in .gitignore
- [ ] .xcconfig linked to Xcode project (Debug & Release)
- [ ] Info.plist reads $(DEEPSEEK_API_KEY) and $(POLLO_API_KEY)
- [ ] Swift can access both keys at runtime
- [ ] Keys NOT visible in git history
- [ ] Build fails gracefully if either key missing
- [ ] README documents BOTH keys and their specific uses
- [ ] Clear warning about NOT mixing up the keys

---

### Task 3.2: Create AIService
**File:** `AIService.swift`
**Priority:** 🔴 HIGH

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**📚 Reference Legacy Code:**
- Read `xxx.txt` lines 9152-9273 for `DeepSeekService` implementation
- Read `xxx.txt` lines 8274-8283 for `AIServiceProtocol` definition
- Copy the HTTP request handling and error patterns

```swift
// Implement DeepSeek API (adapt from legacy lines 9152-9273):
// ⚠️ CRITICAL: This service uses DeepSeek API ONLY
// Used by: Rewording, StoryAnalysis, Taxonomy, Continuity modules

public actor AIService: AIServiceProtocol {
    private let deepSeekAPIKey: String
    
    public init() {
        // Read DeepSeek API key from Info.plist (injected from Secrets.xcconfig)
        guard let key = Bundle.main.object(forInfoDictionaryKey: "DeepSeekAPIKey") as? String,
              !key.isEmpty,
              key != "YOUR_DEEPSEEK_API_KEY_HERE" else {
            fatalError("""
                ❌ DeepSeek API key not configured
                
                This service handles text processing for:
                - Rewording module
                - Story Analysis module
                - Taxonomy module
                - Continuity module
                
                Setup: Edit Secrets.xcconfig and set DEEPSEEK_API_KEY
                """)
        }
        self.deepSeekAPIKey = key
    }
    
    // - HTTP request handling to DeepSeek API
    // - Authentication (Bearer token with deepSeekAPIKey)
    // - Response parsing
    // - Error handling
}
```

**Validation:**
- [ ] Reads DeepSeek API key from Info.plist
- [ ] Fails gracefully if key missing
- [ ] Can make API call to DeepSeek
- [ ] Handles errors gracefully
- [ ] Returns valid response
- [ ] **ONLY uses DeepSeek API** - no Pollo calls

---

### Task 3.2a: Create ImageGenerationService (Pollo API)
**File:** `ImageGenerationService.swift`
**Priority:** 🔴 HIGH

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**📚 Reference Legacy Code:**
- Search `xxx.txt` for Pollo API implementation
- Look for image generation patterns

```swift
// Implement Pollo API for image generation:
// ⚠️ CRITICAL: This service uses Pollo API ONLY
// Used by: Image Generation module EXCLUSIVELY

public actor ImageGenerationService {
    private let polloAPIKey: String
    
    public init() {
        // Read Pollo API key from Info.plist (injected from Secrets.xcconfig)
        guard let key = Bundle.main.object(forInfoDictionaryKey: "PolloAPIKey") as? String,
              !key.isEmpty,
              key != "YOUR_POLLO_API_KEY_HERE" else {
            fatalError("""
                ❌ Pollo API key not configured
                
                This service handles image generation ONLY.
                DO NOT use for text processing.
                
                Setup: Edit Secrets.xcconfig and set POLLO_API_KEY
                """)
        }
        self.polloAPIKey = key
    }
    
    public func generateImage(prompt: String, style: ImageStyle) async throws -> ImageResult {
        // - HTTP request handling to Pollo API
        // - Authentication (with polloAPIKey)
        // - Image generation request
        // - Response parsing
        // - Error handling
    }
}
```

**Validation:**
- [ ] Reads Pollo API key from Info.plist
- [ ] Fails gracefully if key missing
- [ ] Can make API call to Pollo
- [ ] Handles errors gracefully
- [ ] Returns valid image data
- [ ] **ONLY uses Pollo API** - no DeepSeek calls
- [ ] **NEVER used for text processing**


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 3.2b: Build AI Service Settings UI + VALIDATE UX
**File:** `AIServiceSettingsView.swift` (new)
**Priority:** 🔴 HIGH

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create AIServiceSettingsView.swift with:

// SECTION 1: DeepSeek API (Text Processing)
// - API key status display (✅/❌)
// - "Test DeepSeek Connection" button
// - Connection status indicator
// - Usage statistics (requests, tokens, cost)
// - Model selector (DeepSeek models)
// - Temperature slider (0.0-1.0)
// - Max tokens input

// SECTION 2: Pollo API (Image Generation)
// - API key status display (✅/❌)
// - "Test Pollo Connection" button
// - Connection status indicator
// - Usage statistics (images generated, cost)
// - Style presets selector

// SECTION 3: Rate Limiting
// - Rate limit settings per service
// - Save button

// ⚠️ CRITICAL: Clearly separate DeepSeek and Pollo sections
// NOTE: API keys set via Secrets.xcconfig (developer setup)
// UI only shows status, not actual keys
```

**UX Flow:**
1. User sees status for BOTH API keys (DeepSeek and Pollo)
2. If either missing, shows setup instructions
3. Can test each connection independently
4. Views usage statistics per service
5. Adjusts settings per service
6. Settings persist to UserDefaults

**Developer Setup Instructions (shown in UI if keys missing):**
```
API Keys Configuration

DirectorStudio requires TWO API keys:

DeepSeek API (Text Processing):
✅ Configured / ❌ Missing
Used for: Rewording, Story Analysis, Taxonomy, Continuity

Pollo API (Image Generation):
✅ Configured / ❌ Missing
Used for: Image Generation ONLY

Setup Instructions:
1. Open Secrets.xcconfig in project root
2. Set DEEPSEEK_API_KEY = your_deepseek_key
3. Set POLLO_API_KEY = your_pollo_key
4. Rebuild the app

⚠️ DO NOT mix up these keys!

See Secrets-template.xcconfig for reference.
```

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate AIServiceSettingsView
- [ ] Shows status for BOTH API keys (DeepSeek and Pollo)
- [ ] Displays setup instructions if either key missing
- [ ] Test DeepSeek connection works independently
- [ ] Test Pollo connection works independently
- [ ] Status indicators update correctly for each service
- [ ] Usage stats display correctly per service
- [ ] DeepSeek settings (model, temperature) work
- [ ] Pollo settings (style presets) work
- [ ] Settings save to UserDefaults
- [ ] Clear visual separation between services
- [ ] **RUN IN XCODE:** Build and run, test BOTH API connections

---
### Task 3.3: Add Rate Limiting
**File:** `AIService.swift`
**Priority:** 🟡 MEDIUM

```swift
// Add rate limiting:
// - Token bucket algorithm
// - Request queue
// - Retry with backoff
```

**Validation:**
- [ ] Respects rate limits
- [ ] Queues requests
- [ ] Retries work


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 3.4-3.6: Update Modules for Real AI
**Files:** `rewording.swift`, `storyanalysis.swift`
**Priority:** 🔴 HIGH

**Updates:**
- [ ] Replace MockAIService with AIService
- [ ] Test with real API key
- [ ] Verify output quality

**Validation:**
- [ ] Rewording works with real AI
- [ ] Story Analysis works with real AI
- [ ] Output is high quality

---

## 💾 STAGE 4: PERSISTENCE LAYER

### Task 4.1: Create CoreData Model
**File:** `DirectorStudio.xcdatamodeld`
**Priority:** 🟡 MEDIUM

**Entities to create:**
- [ ] ProjectEntity
- [ ] SceneEntity
- [ ] SegmentEntity
- [ ] ContinuityLogEntity
- [ ] TelemetryEntity

**Validation:**
- [ ] Model compiles
- [ ] All relationships defined
- [ ] Migrations work


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 4.2: Create PersistenceController
**File:** `PersistenceController.swift`
**Priority:** 🟡 MEDIUM

```swift
// Implement:
// - CoreData stack setup
// - Save operations
// - Fetch operations
// - Delete operations
```

**Validation:**
- [ ] Can save project
- [ ] Can fetch project
- [ ] Can delete project
- [ ] Data persists


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 4.2b: Build Project Management UI + VALIDATE UX
**File:** `ProjectsView.swift` (new)
**Priority:** 🟡 MEDIUM

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create ProjectsView.swift with:
// - Project list with thumbnails
// - Search and filter options
// - Sort by: date, name, status
// - "New Project" button
// - Swipe actions: delete, duplicate, share
// - Project cards showing:
//   • Title
//   • Last modified date
//   • Status (draft/processing/complete)
//   • Preview thumbnail
// - Tap to open project
// - Empty state for no projects
```

**UX Flow:**
1. User sees list of projects
2. Can search/filter/sort
3. Taps "New Project" to create
4. Taps project to open
5. Swipes for actions
6. Projects auto-save
7. Can share/export projects

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate ProjectsView
- [ ] Project list displays from CoreData
- [ ] Search works
- [ ] Filter/sort works
- [ ] New project creates entry
- [ ] Swipe actions work
- [ ] Tap opens project
- [ ] Auto-save works
- [ ] Share/export works
- [ ] **RUN IN XCODE:** Build and run, test CRUD operations


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 4.3-4.5: Integrate with Core
**File:** `core.swift`
**Priority:** 🟡 MEDIUM

**Integration:**
- [ ] Add persistence to DirectorStudioCore
- [ ] Save after pipeline execution
- [ ] Load on app launch

**Validation:**
- [ ] Projects persist
- [ ] Can resume work
- [ ] No data loss

---

## 💰 STAGE 5: CREDITS SYSTEM

### Task 5.1: Create CreditsService
**File:** `CreditsService.swift`
**Priority:** 🟡 MEDIUM

```swift
// Implement:
// - Balance tracking
// - Deduction logic
// - Transaction history
```

**Validation:**
- [ ] Can track balance
- [ ] Can deduct credits
- [ ] History is accurate


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 5.2: Create StoreKitService
**File:** `StoreKitService.swift`
**Priority:** 🟡 MEDIUM

```swift
// Implement:
// - Product loading
// - Purchase flow
// - Receipt validation
// - Restore purchases
```

**Validation:**
- [ ] Can load products
- [ ] Can purchase
- [ ] Can restore
- [ ] Receipt validates


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 5.2b: Build Credits & Store UI + VALIDATE UX
**File:** `CreditsStoreView.swift` (new)
**Priority:** 🟡 MEDIUM

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create CreditsStoreView.swift with:
// - Current credits balance (prominent)
// - Credits usage history
// - Purchase options grid:
//   • 100 credits - $4.99
//   • 500 credits - $19.99 (Best Value)
//   • 1000 credits - $34.99
// - "Restore Purchases" button
// - Cost per module breakdown
// - Subscription option (optional)
// - Purchase confirmation
// - Receipt display
```

**UX Flow:**
1. User sees current balance
2. Views purchase options
3. Taps package to purchase
4. Sees system payment sheet
5. Purchase processes
6. Balance updates immediately
7. Can restore previous purchases
8. Can view usage history

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate CreditsStoreView
- [ ] Balance displays correctly
- [ ] Purchase options render
- [ ] Tap triggers StoreKit
- [ ] Payment sheet appears
- [ ] Purchase completes
- [ ] Balance updates
- [ ] Restore purchases works
- [ ] Usage history displays
- [ ] **RUN IN XCODE:** Build and run, test purchase flow (sandbox)


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 5.3: Integrate with Pipeline
**File:** `PipelineOrchestrator.swift`
**Priority:** 🟡 MEDIUM

**Integration:**
- [ ] Check credits before execution
- [ ] Deduct credits after execution
- [ ] Handle insufficient credits

**Validation:**
- [ ] Credits deducted correctly
- [ ] Blocks if insufficient
- [ ] Refunds on error

---

### Task 5.4: Add Telemetry for Credits System
**File:** `CreditsTelemetryService.swift` (new)
**Priority:** 🟡 MEDIUM

**🎯 FIDELITY REMINDER:**
- Build privacy-first telemetry
- Follow Apple privacy guidelines
- Implement opt-in mechanism
- Anonymize all data

**Implementation:**
```swift
// Create CreditsTelemetryService with:
// - Credit redemption tracking (when, how many, for what module)
// - Purchase behavior (packages, frequency, timing)
// - Usage patterns (credits per module, burn rate)
// - Conversion metrics (free to paid)
// - Error tracking (failed purchases, refunds)
// - Free entitlement tracking

public actor CreditsTelemetryService {
    func trackCreditRedemption(amount: Int, module: String, timestamp: Date)
    func trackPurchase(package: String, amount: Int, price: Decimal)
    func trackUsagePattern(module: String, creditsUsed: Int)
    func trackConversion(fromFree: Bool, package: String)
    func trackFreeEntitlement(clipsUsed: Int, limit: Int)
}
```

**Validation:**
- [ ] Telemetry service compiles
- [ ] Tracks credit redemption
- [ ] Tracks purchases
- [ ] Tracks usage patterns
- [ ] Privacy compliant


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 5.5: Create Developer Dashboard & Monetization Control
**File:** `DeveloperDashboardService.swift` (new)
**Priority:** 🔴 HIGH

**🎯 FIDELITY REMINDER:**
- Build modular, externally configurable system
- No hardcoded pricing
- Support remote configuration
- Enable updates without app resubmission

**Implementation:**
```swift
// Create DeveloperDashboardService with:
// - Externally configurable pricing logic
// - Remote configuration support (Firebase Remote Config, CloudKit, or custom backend)
// - Modular pricing calculations

public struct MonetizationConfig: Codable {
    // Pricing
    var pricePerCredit: Decimal
    var tokensPerSecondOfVideo: Int
    var videoLengthTiers: [VideoLengthTier]
    var generationCostMultipliers: [String: Decimal]  // By resolution, style, etc.
    
    // Free tier
    var freeClipEntitlement: Int
    var freeCreditsOnSignup: Int
    
    // Feature gating
    var freeFeatures: [String]
    var proFeatures: [String]
    
    // UI display per tier
    var displayedFeaturesPerTier: [String: [String]]
    
    // Cost baseline data (from telemetry)
    var averageCostPerClip: Decimal
    var averageTokensPerClip: Int
    var averageProcessingTime: TimeInterval
}

public struct VideoLengthTier: Codable {
    let duration: TimeInterval  // e.g., 4s, 8s, 12s
    let creditCost: Int
    let multiplier: Decimal
}

public actor DeveloperDashboardService {
    // Load configuration (remote or local)
    func loadConfiguration() async throws -> MonetizationConfig
    
    // Calculate costs dynamically
    func calculateClipCost(duration: TimeInterval, resolution: VideoResolution, 
                          style: VideoStyle) -> Int
    
    // Check feature access
    func hasFeatureAccess(feature: String, userTier: UserTier) -> Bool
    
    // Update configuration (remote)
    func updateConfiguration(_ config: MonetizationConfig) async throws
    
    // Analytics for developer
    func getAnalytics() -> DashboardAnalytics
}

public struct DashboardAnalytics: Codable {
    let totalUsers: Int
    let freeUsers: Int
    let paidUsers: Int
    let totalRevenue: Decimal
    let averageRevenuePerUser: Decimal
    let costBaselines: [CostBaseline]
    let conversionRate: Double
}
```

**Validation:**
- [ ] Dashboard service compiles
- [ ] Loads configuration (local/remote)
- [ ] Calculates costs dynamically
- [ ] Feature gating works
- [ ] Can update config without resubmission
- [ ] Analytics accessible


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 5.6: Documentation Milestone - Credits & Monetization
**File:** `CREDITS_MONETIZATION_DOCS.md` (new)
**Priority:** 🟡 MEDIUM

**Documentation Requirements:**
```markdown
# Credits & Monetization System Documentation

## Overview
- Credit economy design
- Pricing structure
- Module costs
- Developer dashboard

## Implementation
- CreditsService API
- StoreKit integration
- Purchase flow
- Telemetry integration

## Developer Dashboard
- Configuration management
- Remote config setup
- Pricing adjustments
- Feature gating
- Analytics access

## Cost Baseline
- How baseline is calculated
- Using telemetry data
- Adjusting pricing based on costs

## Usage
- Checking balance
- Deducting credits
- Handling errors
- Refund logic

## Telemetry
- Tracked metrics
- Privacy controls
- Data retention
```

**Validation:**
- [ ] Documentation complete
- [ ] API documented
- [ ] Dashboard documented
- [ ] Cost baseline explained
- [ ] Telemetry documented


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

## 🎬 STAGE 6: VIDEO GENERATION PIPELINE

### Task 6.1: Update Segmentation for Video Clip Calculation
**File:** `segmentation.swift`
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**Updates Required:**
```swift
// ADD to SegmentationOutput:
public struct SegmentationOutput {
    public let segments: [PromptSegment]
    public let totalSegments: Int
    public let averageDuration: TimeInterval
    public let metrics: SegmentationMetrics
    public let processingTime: TimeInterval
    
    // NEW: Video generation parameters
    public let videoClipCount: Int                    // Number of video clips needed
    public let recommendedClipDuration: TimeInterval  // Optimal duration per clip
    public let totalVideoDuration: TimeInterval       // Total film length
}

// In SegmentationModule.execute():
let videoClipCount = segments.count
let recommendedClipDuration = calculateOptimalDuration(for: segments, maxDuration: input.maxDuration)
let totalVideoDuration = Double(videoClipCount) * recommendedClipDuration
```

**Validation:**
- [ ] videoClipCount equals segments.count
- [ ] recommendedClipDuration calculated correctly
- [ ] totalVideoDuration = clipCount × duration
- [ ] Existing functionality preserved
- [ ] **RUN IN XCODE:** Build and test


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 6.2: Create VideoGenerationModule
**File:** `VideoGenerationModule.swift` (new)
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**📚 Reference Legacy Code:**
- Read `xxx.txt` lines 568-610 for video clip structure
- Read `xxx.txt` lines 1100-1353 for video generation patterns
- Read `xxx.txt` lines 2723-2830 for video events

**Implementation:**
```swift
// Create VideoGenerationModule with:
// - VideoGenerationInput (segments, duration, style, resolution)
// - VideoGenerationOutput (clips, totalClips, totalDuration)
// - VideoClip struct (id, segmentID, order, duration, videoURL, status)
// - Integration with ImageGenerationService (Pollo API)
// - Enhanced prompt building with cinematic metadata
// - Progress tracking per clip
// - Error handling for failed clips

public struct VideoGenerationInput {
    public let segments: [PromptSegment]
    public let durationPerClip: TimeInterval       // User-defined (default: 4s)
    public let style: VideoStyle                   // cinematic, dramatic, etc.
    public let resolution: VideoResolution         // 1080p, 4K, etc.
}

public struct VideoClip: Identifiable, Codable {
    public let id: UUID
    public let segmentID: UUID                     // Links to PromptSegment
    public let order: Int
    public let duration: TimeInterval
    public let videoURL: URL?                      // Generated video
    public let status: ClipStatus                  // pending/generating/completed/failed
    public let metadata: VideoMetadata             // Cinematic data
}
```

**Validation:**
- [ ] Module compiles without errors
- [ ] Can instantiate VideoGenerationModule
- [ ] Calculates correct number of clips
- [ ] Respects user-defined duration
- [ ] Uses Pollo API (ImageGenerationService)
- [ ] Builds enhanced prompts with metadata
- [ ] Handles failed clips gracefully
- [ ] Returns VideoClip array
- [ ] **RUN IN XCODE:** Build and test generation


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 6.2b: Build Video Generation Settings UI + VALIDATE UX
**File:** `VideoGenerationSettingsView.swift` (new)
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create VideoGenerationSettingsView.swift with:

// SECTION 1: Clip Configuration
// - Auto-calculated clip count (read-only, from segments)
// - Duration per clip slider (2-20 seconds)
// - Total duration display (auto-calculated)
// - Visual preview: "Your story will be X clips of Ys each = Zs total"

// SECTION 2: Video Style
// - Style picker (Cinematic, Dramatic, Action, Documentary, Artistic)
// - Style description for each option
// - Preview thumbnail for each style

// SECTION 3: Quality Settings
// - Resolution picker (720p, 1080p, 4K)
// - Quality vs. speed tradeoff indicator
// - Estimated generation time per clip

// SECTION 4: Advanced Options
// - Frame rate selector (24fps, 30fps, 60fps)
// - Aspect ratio (16:9, 9:16, 1:1)
// - Color grading presets

// SECTION 5: Preview & Estimate
// - Total clips count
// - Total duration
// - Estimated generation time
// - Estimated file size
// - Credits cost estimate
```

**UX Flow:**
1. User sees auto-calculated clip count from segments
2. Adjusts duration per clip slider (2-20s)
3. Sees total duration update in real-time
4. Selects video style from picker
5. Views style preview/description
6. Selects resolution (sees quality/speed tradeoff)
7. Optionally adjusts advanced settings
8. Reviews estimates (time, size, cost)
9. Taps "Continue to Generation"

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate VideoGenerationSettingsView
- [ ] Clip count displays correctly (from segments)
- [ ] Duration slider works (2-20s)
- [ ] Total duration updates automatically
- [ ] Style picker shows all options
- [ ] Style descriptions display
- [ ] Resolution picker works
- [ ] Quality indicator updates
- [ ] Advanced options toggle works
- [ ] All estimates calculate correctly
- [ ] Continue button navigates to generation view
- [ ] **RUN IN XCODE:** Build and run, test all controls

---

### Task 6.3: Create VideoAssemblyModule
**File:** `VideoAssemblyModule.swift` (new)
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**📚 Reference Legacy Code:**
- Read `xxx.txt` lines 1787-1960 for export patterns
- Look for AVFoundation usage for video stitching

**Implementation:**
```swift
// Create VideoAssemblyModule with:
// - VideoAssemblyInput (clips, continuityReport, transitions, format)
// - VideoAssemblyOutput (finalVideoURL, totalDuration, fileSize)
// - Clip stitching with AVFoundation
// - Transition application (cut, fade, dissolve, wipe)
// - Continuity fix integration
// - Multi-format export (MP4, MOV, AVI)

public struct VideoAssemblyInput {
    public let clips: [VideoClip]
    public let continuityReport: ContinuityReport
    public let transitions: [TransitionType]
    public let exportFormat: ExportFormat
}

public struct VideoAssemblyOutput {
    public let finalVideoURL: URL
    public let totalDuration: TimeInterval
    public let clipCount: Int
    public let fileSize: Int64
    public let continuityScore: Double
}
```

**Validation:**
- [ ] Module compiles without errors
- [ ] Can instantiate VideoAssemblyModule
- [ ] Stitches clips in correct order
- [ ] Applies transitions correctly
- [ ] Integrates continuity fixes
- [ ] Exports to valid format
- [ ] Final video plays correctly
- [ ] File size calculated correctly
- [ ] **RUN IN XCODE:** Build and test assembly


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 6.3b: Build Video Assembly Settings UI + VALIDATE UX
**File:** `VideoAssemblySettingsView.swift` (new)
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create VideoAssemblySettingsView.swift with:

// SECTION 1: Transition Settings
// - Default transition picker (Cut, Fade, Dissolve, Wipe)
// - Transition duration slider (0.1-2.0 seconds)
// - "Apply to all" toggle
// - Per-clip transition override list

// SECTION 2: Continuity Options
// - "Apply continuity fixes" toggle
// - Continuity score display (from report)
// - List of detected issues with fix/ignore buttons
// - "Auto-fix all" button

// SECTION 3: Export Settings
// - Format picker (MP4, MOV, AVI)
// - Codec options (H.264, H.265, ProRes)
// - Quality preset (Web, Standard, High, Maximum)
// - File size estimate

// SECTION 4: Audio Options (if applicable)
// - Background music toggle
// - Music track selector
// - Volume slider
// - Fade in/out options

// SECTION 5: Preview
// - Estimated final duration
// - Estimated file size
// - Export location selector
```

**UX Flow:**
1. User sees default transition settings
2. Can adjust transition type and duration
3. Views continuity report and issues
4. Can apply/ignore individual fixes
5. Selects export format and quality
6. Optionally adds background music
7. Reviews final estimates
8. Taps "Assemble & Export"

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate VideoAssemblySettingsView
- [ ] Transition picker works
- [ ] Transition duration slider works
- [ ] Per-clip overrides display
- [ ] Continuity score displays
- [ ] Issue list shows detected problems
- [ ] Fix/ignore buttons work
- [ ] Format/codec pickers work
- [ ] Quality preset updates estimates
- [ ] Audio options work (if implemented)
- [ ] File size estimate updates
- [ ] Export location picker works
- [ ] Assemble button triggers module
- [ ] **RUN IN XCODE:** Build and run, test all settings

---

### Task 6.4: Update ContinuityModule for Video Validation
**File:** `continuity.swift`
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Maintain 100% functionality from legacy code
- Preserve all properties, methods, and logic
- Keep all edge cases and error handling
- Don't simplify or skip features

**Updates Required:**
```swift
// ADD to ContinuityModule:
public func validateVideoSequence(clips: [VideoClip]) -> VideoSequenceReport {
    // Check for:
    // - Visual continuity between clips
    // - Temporal consistency
    // - Character appearance consistency
    // - Location consistency
    // - Lighting/mood transitions
    // - Shot flow coherence
    
    return VideoSequenceReport(
        issues: detectVideoIssues(clips),
        recommendations: generateVideoRecommendations(clips),
        overallScore: calculateVideoScore(clips)
    )
}

public struct VideoSequenceReport: Codable {
    public let issues: [VideoIssue]
    public let recommendations: [String]
    public let overallScore: Double
}
```

**Validation:**
- [ ] Video validation function added
- [ ] Detects visual continuity issues
- [ ] Checks temporal consistency
- [ ] Validates character/location consistency
- [ ] Generates recommendations
- [ ] Calculates video score
- [ ] **RUN IN XCODE:** Build and test


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 6.5: Build Video Generation Progress UI + VALIDATE UX
**File:** `VideoGenerationProgressView.swift` (new)
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create VideoGenerationProgressView.swift with:

// SECTION 1: Overall Progress
// - Large progress ring (0-100%)
// - "Generating X of Y clips" text
// - Estimated time remaining
// - Cancel button (with confirmation)

// SECTION 2: Clip Grid
// - Grid of clip cards (3-4 columns)
// - Each card shows:
//   • Thumbnail (when available)
//   • Clip number and segment text preview
//   • Status badge (Pending/Generating/Complete/Failed)
//   • Progress bar (for generating clips)
//   • Duration label
//   • Retry button (for failed clips)

// SECTION 3: Current Clip Details
// - Expanded view of currently generating clip
// - Enhanced prompt text
// - Cinematic metadata (shot type, camera, lighting)
// - Generation progress (0-100%)
// - Preview updates as it generates

// SECTION 4: Statistics
// - Clips completed: X/Y
// - Success rate: X%
// - Total time elapsed
// - Average time per clip
// - Failed clips count (with "Retry All" button)

// SECTION 5: Actions
// - "Pause Generation" button
// - "Continue to Assembly" button (enabled when all complete)
// - "Save Draft" button (saves progress)
// - "Cancel" button (with confirmation)
```

**UX Flow:**
1. User lands here after tapping "Generate Videos" in settings
2. Sees overall progress ring and clip count
3. Views grid of all clips with status badges
4. Watches clips generate one by one
5. Sees thumbnails appear as clips complete
6. Can tap any clip to see details
7. Can retry individual failed clips
8. Can pause/resume generation
9. When all complete, taps "Continue to Assembly"
10. Navigates to assembly settings

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate VideoGenerationProgressView
- [ ] Progress ring updates correctly
- [ ] Clip count displays accurately
- [ ] Time remaining calculates correctly
- [ ] Clip grid renders all clips
- [ ] Status badges update in real-time
- [ ] Thumbnails display when available
- [ ] Retry button works for failed clips
- [ ] Current clip details display
- [ ] Statistics calculate correctly
- [ ] Pause/resume works
- [ ] Continue button enables when ready
- [ ] Save draft persists state
- [ ] Cancel confirmation works
- [ ] **RUN IN XCODE:** Build and run, test full generation flow

---

### Task 6.6: Build Video Assembly Progress UI + VALIDATE UX
**File:** `VideoAssemblyProgressView.swift` (new)
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create VideoAssemblyProgressView.swift with:

// SECTION 1: Assembly Progress
// - Large progress bar (0-100%)
// - Current step indicator:
//   • "Stitching clips..."
//   • "Applying transitions..."
//   • "Applying continuity fixes..."
//   • "Encoding final video..."
//   • "Exporting..."
// - Estimated time remaining
// - Cancel button (with warning)

// SECTION 2: Timeline Preview
// - Horizontal timeline showing all clips
// - Clips represented as colored blocks
// - Transition indicators between clips
// - Continuity fix markers
// - Playhead showing current assembly position

// SECTION 3: Live Preview
// - Video player showing assembled portion
// - Play/pause controls
// - Scrub through completed sections
// - Quality indicator

// SECTION 4: Statistics
// - Total clips: X
// - Total duration: Xs
// - Transitions applied: X
// - Continuity fixes applied: X
// - File size (updating)
// - Encoding progress

// SECTION 5: Completion
// - Success message when done
// - Final video player (full screen capable)
// - Export options:
//   • Save to Photos
//   • Share
//   • Export to Files
//   • Copy link
// - Quality metrics display
```

**UX Flow:**
1. User lands here after tapping "Assemble & Export"
2. Sees progress bar and current step
3. Watches timeline preview fill in
4. Can preview assembled sections in real-time
5. Sees statistics update
6. When complete, sees success message
7. Plays final video
8. Taps export option (Photos/Share/Files)
9. Receives confirmation
10. Can start new project or return to editing

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate VideoAssemblyProgressView
- [ ] Progress bar updates correctly
- [ ] Step indicator shows current operation
- [ ] Time remaining calculates
- [ ] Timeline preview renders
- [ ] Transition indicators display
- [ ] Live preview player works
- [ ] Can scrub through completed sections
- [ ] Statistics update in real-time
- [ ] Success message displays
- [ ] Final video player works
- [ ] Full screen mode works
- [ ] Export to Photos works
- [ ] Share sheet works
- [ ] Export to Files works
- [ ] Quality metrics display
- [ ] **RUN IN XCODE:** Build and run, test full assembly flow

---

### Task 6.7: Build Video Library & Management UI + VALIDATE UX
**File:** `VideoLibraryView.swift` (new)
**Priority:** 🟡 HIGH

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready UI
- Follow Apple HIG guidelines
- Ensure smooth user flow
- Test all interactions

**UI Requirements:**
```swift
// Create VideoLibraryView.swift with:

// SECTION 1: Library Grid
// - Grid of generated videos (2-3 columns)
// - Each card shows:
//   • Thumbnail
//   • Title (from project name)
//   • Duration
//   • Creation date
//   • Clip count
//   • Quality badge (720p/1080p/4K)
//   • Status (Draft/Complete)

// SECTION 2: Filters & Search
// - Search bar (by title)
// - Filter by: Status, Resolution, Date
// - Sort by: Recent, Duration, Title

// SECTION 3: Video Card Actions
// - Tap to play
// - Long press for context menu:
//   • Play
//   • Edit
//   • Re-export
//   • Share
//   • Delete
//   • Duplicate

// SECTION 4: Batch Actions
// - Select mode toggle
// - Multi-select videos
// - Batch actions:
//   • Export all
//   • Delete selected
//   • Share selected

// SECTION 5: Empty State
// - "No videos yet" message
// - "Create your first video" button
// - Quick start guide
```

**UX Flow:**
1. User navigates to Video Library
2. Sees grid of all generated videos
3. Can search/filter/sort
4. Taps video to play full screen
5. Long presses for actions menu
6. Can select multiple videos
7. Applies batch actions
8. Taps "Create New" to start new video

**Validation:**
- [ ] UI compiles without errors
- [ ] Can instantiate VideoLibraryView
- [ ] Grid displays all videos
- [ ] Thumbnails load correctly
- [ ] Metadata displays accurately
- [ ] Search works
- [ ] Filters work
- [ ] Sort options work
- [ ] Tap to play works
- [ ] Context menu appears on long press
- [ ] All actions work (play/edit/share/delete)
- [ ] Select mode works
- [ ] Batch actions work
- [ ] Empty state displays when no videos
- [ ] Create button navigates correctly
- [ ] **RUN IN XCODE:** Build and run, test library management

---

### Task 6.8: Add Telemetry for Video Generation
**File:** `VideoTelemetryService.swift` (new)
**Priority:** 🟡 MEDIUM

**🎯 FIDELITY REMINDER:**
- Build privacy-first telemetry
- Follow Apple privacy guidelines
- Implement opt-in mechanism
- Anonymize all data

**Implementation:**
```swift
// Create VideoTelemetryService with:
// - Video generation metrics (clips generated, duration, style, resolution)
// - Performance tracking (generation time, success rate, errors)
// - User preferences (most used styles, durations, formats)
// - Prompt-to-clip lifecycle tracking (prompt → segment → clip → assembly)
// - Cost baseline collection (prompt length, video duration, API usage, processing time, retries)
// - Opt-in anonymized clip storage for personalization
// - Privacy controls (enable/disable, clear data)

public actor VideoTelemetryService {
    // Track video generation events
    func trackVideoGeneration(clipCount: Int, duration: TimeInterval, style: VideoStyle)
    
    // Track prompt-to-clip lifecycle
    func trackPromptToClip(promptLength: Int, segmentCount: Int, clipDuration: TimeInterval, 
                          apiTokensUsed: Int, processingTime: TimeInterval, retries: Int)
    
    // Calculate and store cost baseline
    func calculateCostBaseline(promptLength: Int, videoDuration: TimeInterval, 
                              apiCost: Decimal, processingTime: TimeInterval) -> CostBaseline
    
    // Track performance metrics
    func trackPerformance(generationTime: TimeInterval, successRate: Double)
    
    // Opt-in for anonymized storage
    func requestClipStorageConsent() -> Bool
    func storeAnonymizedClip(metadata: ClipMetadata)
}

public struct CostBaseline: Codable {
    let promptLength: Int
    let videoDuration: TimeInterval
    let apiTokensUsed: Int
    let apiCost: Decimal
    let processingTime: TimeInterval
    let retries: Int
    let unitCostPerClip: Decimal
    let timestamp: Date
}
```

**Validation:**
- [ ] Telemetry service compiles
- [ ] Tracks video generation events
- [ ] Tracks prompt-to-clip lifecycle
- [ ] Calculates cost baseline
- [ ] Stores baseline for developer review
- [ ] Opt-in mechanism works
- [ ] Privacy controls functional


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 6.9: Documentation Milestone - Video Pipeline
**File:** `VIDEO_PIPELINE_DOCS.md` (new)
**Priority:** 🟡 MEDIUM

**Documentation Requirements:**
```markdown
# Video Generation Pipeline Documentation

## Overview
- Architecture diagram
- Module dependencies
- Data flow
- Cost baseline collection

## API Reference
- VideoGenerationModule API
- VideoAssemblyModule API
- VideoTelemetryService API

## Usage Examples
- Basic video generation
- Custom settings
- Error handling
- Telemetry integration
- Cost tracking

## Configuration
- Secrets.xcconfig setup
- Pollo API integration
- Performance tuning
- Cost baseline setup

## Telemetry
- Tracked metrics
- Privacy controls
- Cost baseline data
- Developer dashboard integration

## Troubleshooting
- Common errors
- Performance issues
- API failures
- Cost calculation issues
```

**Validation:**
- [ ] Documentation complete
- [ ] All APIs documented
- [ ] Examples provided
- [ ] Cost tracking documented
- [ ] Telemetry documented


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

## 🎬 STAGE 6: VIDEO GENERATION PIPELINE
**File:** `DirectorStudioApp.swift`
**Priority:** 🟢 MEDIUM

```swift
// Create:
// - @main App struct
// - Environment setup
// - Tab navigation
```

**Validation:**
- [ ] App launches
- [ ] Tabs visible
- [ ] Navigation works

---

### Task 6.10: Create Additional UI Views
**Files:** Multiple view files
**Priority:** 🟢 LOW
**Module Name:** `AdditionalUIViews`

**Views to create:**
- [ ] MainTabView
- [ ] ProjectListView
- [ ] PipelineProgressView
- [ ] ConfigurationView
- [ ] SceneDetailView

**Validation:**
- [ ] All views render
- [ ] Navigation works
- [ ] Data displays correctly


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

## ✅ COMPLETION CHECKLIST

### Stage 1 Complete:
- [ ] All modules compile
- [ ] PromptSegment exists
- [ ] PipelineContext exists
- [ ] MockAIService works
- [ ] Validation test passes

### Stage 2 Complete:
- [ ] Pipeline orchestrator works
- [ ] Can execute full pipeline
- [ ] Progress tracking functional
- [ ] Error handling works
- [ ] Integration test passes

### Stage 3 Complete:
- [ ] Real AI service works
- [ ] API keys secure
- [ ] Rate limiting functional
- [ ] Rewording produces output
- [ ] Story Analysis produces output

### Stage 4 Complete:
- [ ] CoreData model defined
- [ ] Persistence works
- [ ] Projects save/load
- [ ] No data loss

### Stage 5 Complete:
- [ ] Credits system works
- [ ] StoreKit integrated
- [ ] Purchases work
- [ ] Credits deduct correctly

### Stage 6 Complete:
- [ ] App launches
- [ ] UI functional
- [ ] All views work
- [ ] Navigation smooth

---

### Task 7.3: Create Onboarding & User Guidance Flow
**File:** `OnboardingFlowView.swift` (new)
**Priority:** 🟡 HIGH

**🎯 FIDELITY REMINDER:**
- Build intuitive, production-ready onboarding
- Guide users through key features
- Ensure smooth first-time experience
- Test all interactions

**Implementation:**
```swift
// Create OnboardingFlowView.swift with:

// SCREEN 1: Welcome
// - App logo
// - Welcome message
// - "Get Started" button

// SCREEN 2: Prompt Writing Guide
// - "Write Your Story" header
// - Tips for effective prompts:
//   • Be descriptive
//   • Include character details
//   • Describe the scene
//   • Add emotional context
// - Example prompts
// - "Next" button

// SCREEN 3: Video Duration Selection
// - "Choose Your Video Length" header
// - Duration options (4s, 8s, 12s)
// - Credit cost per duration
// - Quality recommendations
// - "Next" button

// SCREEN 4: Credits System
// - "How Credits Work" header
// - Credit costs per module
// - Free tier entitlement (X free clips)
// - Purchase options
// - "Next" button

// SCREEN 5: Clip Management
// - "Save & Manage Your Videos" header
// - Video library overview
// - Export options
// - Sharing features
// - "Start Creating" button

public struct OnboardingFlowView: View {
    @State private var currentPage = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    var body: some View {
        TabView(selection: $currentPage) {
            WelcomeScreen().tag(0)
            PromptGuideScreen().tag(1)
            VideoDurationScreen().tag(2)
            CreditsGuideScreen().tag(3)
            ClipManagementScreen().tag(4)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
```

**Validation:**
- [ ] Onboarding flow compiles
- [ ] All screens display correctly
- [ ] Navigation works smoothly
- [ ] Can skip onboarding
- [ ] Can replay onboarding from settings
- [ ] Guides are clear and helpful
- [ ] **RUN IN XCODE:** Test full onboarding flow


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 7.4: Add Localization Scaffolding
**File:** `Localizable.strings` (multiple languages)
**Priority:** 🟢 MEDIUM

**🎯 FIDELITY REMINDER:**
- Prepare for international markets
- Follow Apple localization best practices
- Make all user-facing strings localizable
- Test with pseudo-localization

**Implementation:**
```swift
// 1. Create Localizable.strings files for:
//    - English (en)
//    - Spanish (es)
//    - French (fr)
//    - German (de)
//    - Japanese (ja)
//    - Chinese Simplified (zh-Hans)

// 2. Extract all hardcoded strings from UI
// 3. Replace with NSLocalizedString()
// 4. Add string keys to Localizable.strings

// Example:
// Before: Text("Create Video")
// After: Text(NSLocalizedString("create_video_button", comment: "Button to create new video"))

// Localizable.strings (en):
// "create_video_button" = "Create Video";
// "credits_balance" = "Credits: %d";
// "video_duration_label" = "Duration: %@ seconds";

// 3. Create LocalizationService for dynamic content
public actor LocalizationService {
    func localizePrompt(_ prompt: String, to language: String) async throws -> String
    func getSupportedLanguages() -> [String]
}
```

**Validation:**
- [ ] Localization files created
- [ ] All UI strings extracted
- [ ] NSLocalizedString used throughout
- [ ] Pseudo-localization tested
- [ ] Layout handles longer strings
- [ ] **RUN IN XCODE:** Test with different languages


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 7.5: Add Accessibility Validation
**File:** Accessibility audit across all views
**Priority:** 🟡 HIGH

**🎯 FIDELITY REMINDER:**
- Follow WCAG 2.1 guidelines
- Support VoiceOver completely
- Ensure Dynamic Type support
- Test with accessibility tools

**Implementation:**
```swift
// For every view, ensure:

// 1. VoiceOver Support
// - All interactive elements have accessibility labels
// - Proper accessibility hints
// - Logical focus order
// - Grouped related elements

// Example:
Button(action: generateVideo) {
    Image(systemName: "play.circle")
}
.accessibilityLabel("Generate Video")
.accessibilityHint("Starts video generation from your prompt")

// 2. Dynamic Type
// - Use .font(.body), .font(.headline), etc.
// - Avoid fixed font sizes
// - Test with largest accessibility sizes

// 3. Color Contrast
// - Ensure 4.5:1 contrast ratio minimum
// - Don't rely on color alone
// - Support both light and dark mode

// 4. Reduce Motion
@Environment(\.accessibilityReduceMotion) var reduceMotion

if reduceMotion {
    // Use simple transitions
} else {
    // Use animated transitions
}

// 5. Create AccessibilityAuditService
public actor AccessibilityAuditService {
    func auditView(_ view: String) -> AccessibilityReport
    func generateReport() -> ComprehensiveAccessibilityReport
}
```

**Validation:**
- [ ] VoiceOver works on all screens
- [ ] Dynamic Type supported
- [ ] Color contrast meets standards
- [ ] Reduce Motion respected
- [ ] Keyboard navigation works
- [ ] Accessibility audit passes
- [ ] **RUN IN XCODE:** Test with VoiceOver enabled


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

---

## 🔒 STAGE 8: SECURITY & PRIVACY AUDIT

### Task 8.1: Comprehensive Security Review
**File:** Security audit across entire codebase
**Priority:** 🔴 CRITICAL

**🎯 FIDELITY REMINDER:**
- Follow Apple security best practices
- Ensure data protection
- Validate all user inputs
- Test for common vulnerabilities

**Audit Checklist:**

**1. API Key Security**
- [ ] All API keys in Secrets.xcconfig
- [ ] No keys hardcoded in source
- [ ] Keys not in version control
- [ ] Keys loaded securely at runtime

**2. Data Protection**
- [ ] Sensitive data encrypted at rest
- [ ] Use Keychain for credentials
- [ ] CoreData encryption enabled
- [ ] Secure file storage

**3. Network Security**
- [ ] All API calls use HTTPS
- [ ] Certificate pinning implemented
- [ ] Timeout handling
- [ ] Retry logic secure

**4. Input Validation**
- [ ] All user inputs validated
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] Buffer overflow prevention

**5. Authentication & Authorization**
- [ ] Secure token storage
- [ ] Session management
- [ ] Proper logout handling
- [ ] Biometric authentication (if applicable)

**6. Privacy Compliance**
- [ ] Privacy policy in place
- [ ] User consent for telemetry
- [ ] Data retention policies
- [ ] Right to deletion

**7. Code Security**
- [ ] No sensitive data in logs
- [ ] Secure random number generation
- [ ] Memory management (no leaks)
- [ ] Third-party dependency audit

**Validation:**
- [ ] Security audit complete
- [ ] All vulnerabilities addressed
- [ ] Penetration testing passed
- [ ] Privacy policy reviewed
- [ ] **RUN IN XCODE:** Full security test


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

### Task 8.2: Create Security Documentation
**File:** `SECURITY_AUDIT_REPORT.md` (new)
**Priority:** 🔴 CRITICAL

**Documentation Requirements:**
```markdown
# Security & Privacy Audit Report

## Executive Summary
- Audit date
- Scope
- Key findings
- Recommendations

## API Key Management
- Implementation details
- Security measures
- Best practices followed

## Data Protection
- Encryption methods
- Storage security
- Access controls

## Network Security
- HTTPS enforcement
- Certificate pinning
- API security

## Privacy Compliance
- GDPR compliance
- CCPA compliance
- Apple privacy requirements
- User consent mechanisms

## Telemetry & Analytics
- Data collected
- Anonymization methods
- Opt-in/opt-out
- Data retention

## Vulnerability Assessment
- Known vulnerabilities
- Mitigation strategies
- Testing results

## Recommendations
- Immediate actions
- Long-term improvements
- Monitoring strategies

## Compliance Checklist
- [ ] App Store Review Guidelines
- [ ] Privacy Policy
- [ ] Terms of Service
- [ ] Data Processing Agreement
```

**Validation:**
- [ ] Documentation complete
- [ ] All findings documented
- [ ] Recommendations clear
- [ ] Compliance verified


**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**

**🤖 AUTO-PR TRIGGER:**
✅ **REQUIRED - Run immediately after validation:**
```bash
./automation/scripts/create-module-pr.sh <ModuleName>
```
This will automatically:
- Create PR branch with timestamp
- Trigger BugBot review (build, lint, security checks)
- Auto-merge if approved OR create patch branch if issues found
- Log status to `automation/logs/pr-tracker.md`

**⏸️ WAIT for BugBot approval before proceeding to next task**

**🛑 STOP FOR USER TESTING:**
After BugBot approves, STOP and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
- [ ] Confirm readiness for next module
**⏸️ WAIT for user approval before proceeding to next task**

---

---

## 🚨 CRITICAL PATH (Must Do First)

1. ✅ Create PromptSegment (Task 1.1)
2. ✅ Create PipelineContext (Task 1.2)
3. ✅ Create MockAIService (Task 1.3)
4. ✅ Update all modules (Task 1.4-1.8)
5. ✅ Validate Stage 1 (Task 1.9)
6. Create PipelineOrchestrator (Task 2.2)
7. Create AIService (Task 3.2)
8. Create KeychainService (Task 3.1)

9. Create ImageGenerationService (Task 3.2a)

**Everything else can be done in parallel or later.**

---


## 🎯 Success Metrics

- [ ] All 6 modules functional
- [ ] End-to-end pipeline works
- [ ] Real AI integration works
- [ ] Data persists
- [ ] Credits system works
- [ ] App is usable

---

**Ready for Cheetah execution. Start with Stage 1, Task 1.1.**

