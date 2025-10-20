# DirectorStudio Architecture Map

## Current System (What Exists)

```
┌─────────────────────────────────────────────────────────────┐
│                   MODERN MODULAR SYSTEM                      │
│                    (6 Validated Modules)                     │
└─────────────────────────────────────────────────────────────┘

┌──────────────────┐
│ DirectorStudio   │  ← Core infrastructure
│ Core             │     - Event bus
│ (core.swift)     │     - Service registry
└────────┬─────────┘     - State management
         │
         ├─────────────────────────────────────────────┐
         │                                             │
    ┌────▼────────┐  ┌──────────────┐  ┌─────────────▼──┐
    │ Rewording   │  │ Segmentation │  │ Story Analysis │
    │ Module      │  │ Module       │  │ Module         │
    │             │  │              │  │                │
    │ 7 types     │  │ Intelligent  │  │ 8-phase deep   │
    └─────────────┘  │ pacing       │  │ analysis       │
                     └──────────────┘  └────────────────┘
    
    ┌─────────────┐  ┌──────────────┐  ┌────────────────┐
    │ Taxonomy    │  │ Continuity   │  │ Packaging      │
    │ Module      │  │ Module       │  │ Module         │
    │             │  │              │  │                │
    │ Cinematic   │  │ Validation & │  │ Final output   │
    │ enrichment  │  │ tracking     │  │ assembly       │
    └─────────────┘  └──────────────┘  └────────────────┘
```

**Status:** ✅ All modules compile and are validated
**Problem:** ⚠️ No way to execute them together!

---

## Missing Infrastructure (What's Needed)

```
┌─────────────────────────────────────────────────────────────┐
│                    MISSING LAYER                             │
│              (Prevents System from Working)                  │
└─────────────────────────────────────────────────────────────┘

                    ┌──────────────────┐
                    │ Pipeline         │  ← CRITICAL MISSING
                    │ Orchestrator     │     - Executes modules
                    │                  │     - Tracks progress
                    │ ⚠️ DOESN'T EXIST │     - Handles errors
                    └────────┬─────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
    ┌────▼────────┐  ┌──────▼──────┐  ┌────────▼──────┐
    │ Pipeline    │  │ AI Service  │  │ Data Models   │
    │ Config      │  │             │  │               │
    │             │  │ ⚠️ DOESN'T  │  │ ⚠️ INCOMPLETE │
    │ ⚠️ MISSING  │  │    EXIST    │  │               │
    └─────────────┘  └─────────────┘  └───────────────┘
```

**Impact:** Modules are isolated, can't work together

---

## Target Architecture (After Reconstruction)

```
┌─────────────────────────────────────────────────────────────┐
│                    USER INTERFACE LAYER                      │
│                       (SwiftUI Views)                        │
└─────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                  ORCHESTRATION LAYER                         │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Pipeline Orchestrator (NEW)                   │  │
│  │  - Executes modules in sequence                       │  │
│  │  - Tracks progress (0.0 → 1.0)                        │  │
│  │  - Handles errors & retries                           │  │
│  │  - Supports cancellation                              │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Pipeline Configuration (NEW)                  │  │
│  │  - Module enable/disable toggles                      │  │
│  │  - Per-module settings                                │  │
│  │  - Presets (.default, .quickProcess, etc.)           │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    MODULE LAYER (EXISTS)                     │
│                                                              │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│  │Rewording│→ │  Story  │→ │Segment- │→ │Taxonomy │       │
│  │         │  │Analysis │  │ation    │  │         │       │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │
│                                                              │
│  ┌─────────┐  ┌─────────┐                                  │
│  │Contin-  │→ │Packaging│                                  │
│  │uity     │  │         │                                  │
│  └─────────┘  └─────────┘                                  │
└─────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                   SERVICE LAYER (NEW)                        │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ AI Service   │  │ Persistence  │  │ Credits      │     │
│  │ (DeepSeek)   │  │ (CoreData)   │  │ (StoreKit)   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │ Keychain     │  │ Sync Engine  │                        │
│  │ (Security)   │  │ (Supabase)   │                        │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER (NEW)                          │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Core Data Models                              │  │
│  │  - PromptSegment (CRITICAL - used by all modules)    │  │
│  │  - PipelineContext (required by all execute())       │  │
│  │  - Project, Scene, Segment entities                  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Flow (Target System)

```
USER INPUT (Story Text)
         │
         ▼
┌────────────────────┐
│ Pipeline           │  1. User configures pipeline
│ Orchestrator       │  2. Validates input
└─────────┬──────────┘  3. Checks credits
          │
          ▼
┌─────────────────────┐
│ Step 1: Rewording   │  Input: Story text
│ (Optional)          │  Output: Transformed text
└─────────┬───────────┘  Uses: AI Service
          │
          ▼
┌─────────────────────┐
│ Step 2: Story       │  Input: Story text
│ Analysis            │  Output: Characters, locations, themes
└─────────┬───────────┘  Uses: AI Service (optional)
          │
          ▼
┌─────────────────────┐
│ Step 3: Segmentation│  Input: Story text
│                     │  Output: Array of PromptSegments
└─────────┬───────────┘  Uses: Internal logic
          │
          ▼
┌─────────────────────┐
│ Step 4: Cinematic   │  Input: PromptSegments
│ Taxonomy            │  Output: Enriched segments with metadata
└─────────┬───────────┘  Uses: Internal logic
          │
          ▼
┌─────────────────────┐
│ Step 5: Continuity  │  Input: Enriched segments
│ Validation          │  Output: Validated segments + issues
└─────────┬───────────┘  Uses: Telemetry data
          │
          ▼
┌─────────────────────┐
│ Step 6: Packaging   │  Input: All previous outputs
│                     │  Output: Final deliverable
└─────────┬───────────┘  Uses: Quality metrics
          │
          ▼
    FINAL OUTPUT
    (Production-ready package)
```

---

## Type Dependencies (Critical)

```
┌─────────────────────────────────────────────────────────────┐
│                    TYPE SYSTEM                               │
│              (Foundation for Everything)                     │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ PromptSegment (CRITICAL - BLOCKING)                      │
│ ⚠️ MUST CREATE FIRST                                     │
│                                                           │
│ struct PromptSegment: Sendable, Codable {               │
│     let order: Int                                       │
│     var text: String                                     │
│     let duration: Double                                 │
│     let pacing: PacingType                              │
│     let transitionType: TransitionType                  │
│     var metadata: [String: String]                      │
│ }                                                        │
│                                                           │
│ Used by:                                                 │
│ ✓ SegmentationModule (output)                           │
│ ✓ CinematicTaxonomyModule (input/output)               │
│ ✓ ContinuityModule (input/output)                       │
│ ✓ PackagingModule (input)                               │
└──────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ PipelineContext (CRITICAL - BLOCKING)                    │
│ ⚠️ MUST CREATE SECOND                                    │
│                                                           │
│ struct PipelineContext: Sendable {                      │
│     let sessionID: UUID                                  │
│     let config: PipelineConfiguration?                  │
│     var metadata: [String: String]                      │
│ }                                                        │
│                                                           │
│ Used by:                                                 │
│ ✓ All modules (execute() parameter)                     │
│ ✓ PipelineOrchestrator (passes to modules)             │
└──────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│ Supporting Types                                          │
│                                                           │
│ enum PacingType: String, Codable, Sendable {            │
│     case slow, moderate, fast                           │
│ }                                                        │
│                                                           │
│ enum TransitionType: String, Codable, Sendable {        │
│     case fadeIn, fadeOut, cut,                          │
│          crossDissolve, standard                         │
│ }                                                        │
└──────────────────────────────────────────────────────────┘
```

---

## Module Protocol (Existing - Good!)

```
┌─────────────────────────────────────────────────────────────┐
│ PipelineModule Protocol (EXISTS - KEEP)                     │
│                                                              │
│ protocol PipelineModule: Sendable {                         │
│     associatedtype Input: Sendable                          │
│     associatedtype Output: Sendable                         │
│                                                              │
│     var moduleID: String { get }                            │
│     var moduleName: String { get }                          │
│     var version: String { get }                             │
│                                                              │
│     func execute(                                           │
│         input: Input,                                       │
│         context: PipelineContext  ← NEEDS THIS              │
│     ) async -> Result<Output, PipelineError>               │
│                                                              │
│     func validate(input: Input) -> [String]                │
│     func canSkip() -> Bool                                  │
│ }                                                            │
└─────────────────────────────────────────────────────────────┘
```

**Status:** ✅ Protocol is good, just needs PipelineContext added

---

## Integration Points

```
┌─────────────────────────────────────────────────────────────┐
│              HOW EVERYTHING CONNECTS                         │
└─────────────────────────────────────────────────────────────┘

USER TAPS "GENERATE"
         │
         ▼
┌──────────────────────┐
│ PipelineOrchestrator │
│ .execute()           │
└──────────┬───────────┘
           │
           ├─→ Check credits (CreditsService)
           ├─→ Load config (PipelineConfiguration)
           ├─→ Create context (PipelineContext)
           │
           ├─→ Module 1: Rewording
           │   ├─→ Uses: AIService
           │   └─→ Returns: Transformed text
           │
           ├─→ Module 2: Story Analysis
           │   ├─→ Uses: AIService (optional)
           │   └─→ Returns: Analysis data
           │
           ├─→ Module 3: Segmentation
           │   ├─→ Uses: Internal logic
           │   └─→ Returns: PromptSegments[]
           │
           ├─→ Module 4: Cinematic Taxonomy
           │   ├─→ Uses: Internal logic
           │   └─→ Returns: Enriched segments
           │
           ├─→ Module 5: Continuity
           │   ├─→ Uses: Storage (telemetry)
           │   └─→ Returns: Validated segments
           │
           └─→ Module 6: Packaging
               ├─→ Uses: All previous outputs
               └─→ Returns: Final package
           │
           ├─→ Deduct credits (CreditsService)
           ├─→ Save project (PersistenceController)
           └─→ Return to UI
```

---

## File Organization (Target)

```
director/
├── Core/
│   ├── core.swift                    ← EXISTS
│   ├── DataModels.swift              ← CREATE (PromptSegment)
│   ├── PipelineTypes.swift           ← CREATE (PipelineContext)
│   └── PipelineOrchestrator.swift    ← CREATE (Orchestrator)
│
├── Modules/
│   ├── rewording.swift               ← EXISTS
│   ├── segmentation.swift            ← EXISTS
│   ├── storyanalysis.swift           ← EXISTS
│   ├── taxonomy.swift                ← EXISTS
│   └── continuity.swift              ← EXISTS
│
├── Services/
│   ├── AIService.swift               ← CREATE (DeepSeek)
│   ├── KeychainService.swift         ← CREATE (Security)
│   ├── CreditsService.swift          ← CREATE (Monetization)
│   ├── PersistenceController.swift   ← CREATE (CoreData)
│   └── SyncEngine.swift              ← CREATE (Cloud sync)
│
├── Configuration/
│   └── PipelineConfiguration.swift   ← CREATE (Settings)
│
├── UI/
│   ├── DirectorStudioApp.swift       ← CREATE (App entry)
│   ├── MainTabView.swift             ← CREATE (Navigation)
│   ├── PipelineProgressView.swift    ← CREATE (Progress)
│   └── ConfigurationView.swift       ← CREATE (Settings)
│
└── Tests/
    ├── ModuleTests.swift             ← CREATE (Unit tests)
    └── IntegrationTests.swift        ← CREATE (E2E tests)
```

---

## Execution Flow (Visual)

```
START
  │
  ▼
┌─────────────────┐
│ User Input      │ Story text + config
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Orchestrator    │ Validates & prepares
│ .execute()      │
└────────┬────────┘
         │
         ├─────────────────────────────────────┐
         │                                     │
         ▼                                     ▼
    ┌─────────┐                          ┌─────────┐
    │ Step 1  │ Rewording                │ Step 2  │ Analysis
    │ [====  ]│ Progress: 20%            │ [      ]│ Pending
    └─────────┘                          └─────────┘
         │
         ▼
    ┌─────────┐
    │ Step 1  │ Rewording
    │ [======]│ Progress: 100% ✓
    └─────────┘
         │
         ▼
    ┌─────────┐
    │ Step 2  │ Analysis
    │ [===   ]│ Progress: 60%
    └─────────┘
         │
         ▼
    ... (continues for all 6 steps)
         │
         ▼
┌─────────────────┐
│ Final Output    │ Complete package
└────────┬────────┘
         │
         ▼
    ┌─────────┐
    │ Save    │ Persist to CoreData
    └─────────┘
         │
         ▼
    ┌─────────┐
    │ UI      │ Display results
    └─────────┘
         │
         ▼
      END
```

---

## Summary

**Current State:**
- ✅ 6 beautiful, well-designed modules
- ⚠️ No way to execute them together
- ⚠️ Missing critical types (PromptSegment, PipelineContext)
- ⚠️ No AI service implementation
- ⚠️ No persistence layer
- ⚠️ No UI

**After Stage 1 (4 hours):**
- ✅ All modules compile
- ✅ Types exist
- ✅ Can instantiate modules
- ⚠️ Still can't execute end-to-end

**After Stage 2 (12 hours):**
- ✅ Can execute full pipeline
- ✅ Progress tracking works
- ✅ Error handling works
- ⚠️ Using mock AI

**After Stage 3 (18 hours):**
- ✅ Real AI integration
- ✅ Rewording works
- ✅ Story Analysis works
- ⚠️ No persistence

**Production Ready (40-50 hours):**
- ✅ Everything works
- ✅ Projects persist
- ✅ Credits system functional
- ✅ UI complete
- ✅ App Store ready

---

**Next Action:** Create PromptSegment in DataModels.swift

