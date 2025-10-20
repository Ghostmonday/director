# DirectorStudio Legacy Codebase Reconstruction Plan

## Executive Summary

This document provides a comprehensive analysis of the legacy DirectorStudio codebase (31,787 lines across 99 files) and a phased reconstruction plan to integrate abandoned functionality into the new modular architecture.

**Current Modern Architecture Status:**
- ✅ Core Foundation (DirectorStudioCore.swift)
- ✅ Rewording Module (7 transformation types)
- ✅ Segmentation Module (intelligent pacing)
- ✅ Story Analysis Module (8-phase deep analysis)
- ✅ Taxonomy Module (cinematic enrichment)
- ✅ Continuity Module (validation & tracking)

**Legacy Components Identified:** 99 files requiring analysis and integration

---

## Phase 1: Critical Infrastructure Recovery

### 1.1 Pipeline Manager & Orchestration
**Status:** ⚠️ MISSING - Critical for production

**Legacy Files:**
- `DirectorStudio/Modules/PipelineManager.swift` (651 lines)
- `DirectorStudio/Modules/DirectorStudioPipeline.swift` (45 lines - simplified stub)
- `Pipeline/Core/PipelineManager.swift` (748 lines - full implementation)

**What's Missing:**
```swift
// Legacy had full orchestration:
- Async pipeline execution with step tracking
- Progress reporting (0.0-1.0 per step)
- Error recovery and retry logic
- Step dependency management
- Cancellation support
- Module enable/disable toggles
- Execution metadata collection
```

**Modern Integration Required:**
```swift
// Create: PipelineOrchestrator.swift
public actor PipelineOrchestrator {
    // Manages execution of all 6 modules
    // Progress tracking
    // Error handling with retry
    // Cancellation support
    // Integration with DirectorStudioCore
}
```

**Integration Risk:** 🔴 HIGH
- Core functionality - system won't work without it
- Requires careful async/await handling
- Must integrate with existing ModuleProtocol

**Dependencies:**
- All 6 existing modules
- PipelineContext (exists in legacy)
- PipelineConfig (exists in legacy)

---

### 1.2 Pipeline Configuration System
**Status:** ⚠️ PARTIALLY MISSING

**Legacy Files:**
- `DirectorStudio/Modules/PipelineConfig.swift` (154 lines)

**What's Missing:**
```swift
// Configuration for:
- Module enable/disable toggles
- Per-module settings (rewordingType, maxSegmentDuration, etc.)
- API configuration (temperature, maxTokens, rate limiting)
- Retry and timeout settings
- Presets: .default, .quickProcess, .fullProcess, .segmentationOnly
```

**Modern Integration Required:**
```swift
// Create: PipelineConfiguration.swift
@Observable
public final class PipelineConfiguration: Sendable {
    // All module toggles
    // Module-specific settings
    // API configuration
    // Validation logic
    // Preset configurations
}
```

**Integration Risk:** 🟡 MEDIUM
- Needed for user control
- Relatively straightforward
- Must align with PipelineContext

---

### 1.3 AI Service Layer
**Status:** ⚠️ CRITICAL MISSING

**Legacy Files:**
- `DirectorStudio/Services/AIServiceProtocol.swift` (10 lines - protocol only)
- `DirectorStudio/Services/DeepSeekService.swift` (122 lines)
- `DirectorStudio/Services/SoraService.swift` (137 lines - video generation)

**What's Missing:**
```swift
// AIServiceProtocol implementation:
protocol AIServiceProtocol {
    var isAvailable: Bool { get }
    func sendRequest(systemPrompt:userPrompt:temperature:maxTokens:) async throws -> String
    func healthCheck() async -> Bool
}

// DeepSeekService:
- API key management
- HTTP request handling
- Rate limiting
- Error handling
- Response parsing
```

**Modern Integration Required:**
```swift
// Create: AIService.swift
public actor AIService: AIServiceProtocol {
    // DeepSeek API integration
    // Rate limiting
    // Error handling
    // Health checks
    // Token counting
}
```

**Integration Risk:** 🔴 CRITICAL
- Required for Rewording and Story Analysis modules
- Network layer complexity
- API key security
- Rate limiting essential

---

## Phase 2: Data Models & Types

### 2.1 Core Data Models
**Status:** ⚠️ MISSING - Required for persistence

**Legacy Files:**
- `DirectorStudio/Core/Project.swift` (165 lines)
- `DirectorStudio/Core/PromptSegment.swift` (55 lines)
- `DirectorStudio/Core/SceneModel.swift` (53 lines)

**What's Missing:**
```swift
// Project model:
struct Project {
    id, title, screenplay, scenes
    timestamps, metadata
    export functionality
}

// PromptSegment (CRITICAL - used by all modules):
struct PromptSegment {
    order: Int
    text: String
    duration: Double
    pacing: PacingType
    transitionType: TransitionType
    metadata: [String: String]
}

// Enums:
enum PacingType { slow, moderate, fast }
enum TransitionType { fadeIn, fadeOut, cut, crossDissolve, standard }
```

**Modern Integration Required:**
```swift
// Create: DataModels.swift
// Add PromptSegment, PacingType, TransitionType
// Ensure Sendable conformance
// Add to core.swift or separate file
```

**Integration Risk:** 🔴 CRITICAL
- PromptSegment is used by EVERY module
- Must be created immediately
- Blocking all module integration

---

### 2.2 Pipeline Types
**Status:** ⚠️ PARTIALLY EXISTS

**Legacy Files:**
- `DirectorStudio/Modules/PipelineModule.swift` (250 lines)

**What Exists in Legacy:**
```swift
// PipelineModule protocol (GOOD - similar to current)
// PipelineContext struct (MISSING in current)
// PipelineError enum (comprehensive)
// ModuleResult struct
// ModuleStatus enum
// PipelineStepInfo struct (for UI)
```

**Modern Integration Required:**
```swift
// Enhance existing PipelineModule protocol
// Add PipelineContext to continuity.swift
// Add comprehensive PipelineError enum
// Add ModuleResult wrapper
```

**Integration Risk:** 🟡 MEDIUM
- Some types exist
- Need alignment
- UI types can wait

---

## Phase 3: Storage & Persistence

### 3.1 CoreData Integration
**Status:** ⚠️ MISSING - Required for production

**Legacy Files:**
- `DirectorStudio/Persistence/PersistenceController.swift` (184 lines)
- `DirectorStudio/Storage/CoreDataEntities.swift` (186 lines)
- `DirectorStudio/Services/CoreDataEntities.swift` (186 lines - duplicate)

**What's Missing:**
```swift
// PersistenceController:
- CoreData stack setup
- Container initialization
- Save/fetch operations
- Migration handling

// Entities:
- ProjectEntity
- SceneEntity
- SegmentEntity
- ContinuityLogEntity
- TelemetryEntity
```

**Modern Integration Required:**
```swift
// Create: PersistenceLayer.swift
public actor PersistenceController {
    // CoreData stack
    // CRUD operations
    // Migration support
}

// Create: CoreDataModels.xcdatamodeld
// Define all entities
```

**Integration Risk:** 🟡 MEDIUM
- Can use in-memory storage initially
- CoreData adds complexity
- Essential for production

---

### 3.2 Local Storage Module
**Status:** ⚠️ MISSING

**Legacy Files:**
- `DirectorStudio/Services/LocalStorageModule.swift` (691 lines)
- `DirectorStudio/Storage/LocalStorageModule.swift` (691 lines - duplicate)

**What's Missing:**
```swift
// LocalStorageModule:
- Project CRUD operations
- Scene management
- Segment storage
- Export functionality
- JSON serialization
```

**Modern Integration Required:**
```swift
// Create: LocalStorage.swift
public actor LocalStorageService {
    // File-based storage
    // JSON persistence
    // Export/import
}
```

**Integration Risk:** 🟢 LOW
- Can be implemented later
- File-based fallback
- Not blocking

---

## Phase 4: Services & Infrastructure

### 4.1 Credits & Monetization
**Status:** ⚠️ MISSING - Required for production

**Legacy Files:**
- `DirectorStudio/Services/CreditWallet.swift` (198 lines)
- `DirectorStudio/Services/CreditsPurchaseManager.swift` (143 lines)
- `DirectorStudio/Services/StoreManager.swift` (199 lines)
- `DirectorStudio/Services/FirstClipGrantService.swift` (88 lines)

**What's Missing:**
```swift
// CreditWallet:
- Credit balance tracking
- Deduction logic
- Transaction history
- Sync with backend

// StoreKit Integration:
- Product loading
- Purchase flow
- Receipt validation
- Restore purchases
```

**Modern Integration Required:**
```swift
// Create: CreditsService.swift
public actor CreditsService {
    // Balance management
    // Transaction tracking
    // StoreKit integration
}
```

**Integration Risk:** 🟡 MEDIUM
- Required for monetization
- StoreKit complexity
- Can use mock initially

---

### 4.2 Backend Sync Engine
**Status:** ⚠️ MISSING

**Legacy Files:**
- `DirectorStudio/Services/SupabaseSyncEngine.swift` (733 lines)
- `DirectorStudio/Sync/SupabaseSyncEngine.swift` (733 lines - duplicate)

**What's Missing:**
```swift
// SupabaseSyncEngine:
- Project sync to cloud
- Real-time updates
- Conflict resolution
- Offline queue
- Authentication integration
```

**Modern Integration Required:**
```swift
// Create: SyncEngine.swift
public actor SyncEngine {
    // Cloud sync
    // Conflict resolution
    // Offline support
}
```

**Integration Risk:** 🟢 LOW
- Can work offline initially
- Complex but not blocking
- Backend dependency

---

### 4.3 Security Services
**Status:** ⚠️ MISSING

**Legacy Files:**
- `DirectorStudio/Services/KeychainService.swift` (107 lines)
- `DirectorStudio/Services/SecretsManager.swift` (86 lines)
- `DirectorStudio/Services/APIKeyManager.swift` (88 lines)

**What's Missing:**
```swift
// KeychainService:
- Secure storage for API keys
- Credential management
- Encryption

// SecretsManager:
- API key retrieval
- Environment-based secrets
```

**Modern Integration Required:**
```swift
// Create: SecurityServices.swift
public actor KeychainService {
    // Secure storage
    // API key management
}
```

**Integration Risk:** 🔴 HIGH
- Required for API keys
- Security critical
- Must implement early

---

## Phase 5: UI Components & Views

### 5.1 Main App Structure
**Status:** ⚠️ MISSING - Required for app

**Legacy Files:**
- `DirectorStudio/DirectorStudioApp.swift` (761 lines)
- `DirectorStudio/Views/MainTabView.swift` (87 lines)

**What's Missing:**
```swift
// App structure:
- Tab-based navigation
- Coordinator pattern
- Environment objects
- Background task registration
- App lifecycle handling
```

**Modern Integration Required:**
```swift
// Create: DirectorStudioApp.swift
@main
struct DirectorStudioApp: App {
    // Tab navigation
    // State management
    // Environment setup
}
```

**Integration Risk:** 🟡 MEDIUM
- UI layer
- SwiftUI knowledge required
- Not blocking core functionality

---

### 5.2 Pipeline UI Components
**Status:** ⚠️ MISSING

**Legacy Files:**
- `DirectorStudio/Sheets/PipelineProgressSheet.swift` (62 lines)
- `DirectorStudio/Views/PipelineControlPanel.swift` (459 lines)
- `DirectorStudio/Sheets/SceneControlSheet.swift` (532 lines)
- `DirectorStudio/Components/PipelineStepView.swift` (4 lines - stub)

**What's Missing:**
```swift
// PipelineProgressSheet:
- Real-time progress display
- Step-by-step visualization
- Cancel button
- Error display

// SceneControlSheet:
- Module toggles
- Configuration sliders
- Preset selection
- Validation feedback
```

**Modern Integration Required:**
```swift
// Create: PipelineUI.swift
// Progress views
// Control panels
// Configuration sheets
```

**Integration Risk:** 🟢 LOW
- UI only
- Can use basic UI initially
- Polish later

---

## Phase 6: Advanced Features

### 6.1 Pricing & Cost Tracking
**Status:** ⚠️ MISSING

**Legacy Files:**
- `DirectorStudio/Services/Pricing/ActualUsageMeasurement.swift` (527 lines)
- `DirectorStudio/Services/Pricing/MeasuredCostTracker.swift` (267 lines)
- `DirectorStudio/Services/Pricing/CorrectPricingUI.swift` (627 lines)

**What's Missing:**
```swift
// Cost tracking:
- Per-module cost calculation
- Token counting
- Credit deduction
- Usage analytics
```

**Modern Integration Required:**
```swift
// Create: CostTracking.swift
public actor CostTracker {
    // Token counting
    // Cost calculation
    // Analytics
}
```

**Integration Risk:** 🟢 LOW
- Nice to have
- Can estimate initially
- Refinement later

---

### 6.2 Export & Sharing
**Status:** ⚠️ MISSING

**Legacy Files:**
- `DirectorStudio/Sheets/ExportSheet.swift` (160 lines)
- `DirectorStudio/Sheets/ShareSheet.swift` (23 lines)

**What's Missing:**
```swift
// Export functionality:
- JSON export
- Screenplay format
- Shot list format
- Share sheet integration
```

**Modern Integration Required:**
```swift
// Create: ExportService.swift
public struct ExportService {
    // Multiple format support
    // Share sheet
}
```

**Integration Risk:** 🟢 LOW
- Feature enhancement
- Not blocking
- Can add later

---

## Phase 7: Testing & Validation

### 7.1 Pipeline Tests
**Status:** ⚠️ MISSING

**Legacy Files:**
- `DirectorStudio/Modules/PipelineTests.swift` (458 lines)
- `DirectorStudio/Modules/PipelineDebugHarness.swift` (440 lines)

**What's Missing:**
```swift
// Test harness:
- Module unit tests
- Integration tests
- Performance tests
- Debug utilities
```

**Modern Integration Required:**
```swift
// Create: Tests/ directory
// Unit tests for each module
// Integration tests
// Performance benchmarks
```

**Integration Risk:** 🟢 LOW
- Quality assurance
- Not blocking
- Continuous addition

---

## Critical Missing Types Summary

### BLOCKING - Must Implement Immediately:

1. **PromptSegment** (used by ALL modules)
```swift
public struct PromptSegment: Sendable, Codable {
    public let order: Int
    public var text: String
    public let duration: Double
    public let pacing: PacingType
    public let transitionType: TransitionType
    public var metadata: [String: String]
}

public enum PacingType: String, Codable, Sendable {
    case slow, moderate, fast
}

public enum TransitionType: String, Codable, Sendable {
    case fadeIn, fadeOut, cut, crossDissolve, standard
}
```

2. **PipelineContext** (used by all PipelineModule.execute())
```swift
public struct PipelineContext: Sendable {
    public let sessionID: UUID
    public let config: PipelineConfiguration?
    public var metadata: [String: String]
}
```

3. **AIServiceProtocol Implementation**
```swift
public protocol AIServiceProtocol: Sendable {
    var isAvailable: Bool { get }
    func sendRequest(systemPrompt:userPrompt:temperature:maxTokens:) async throws -> String
    func healthCheck() async -> Bool
}
```

---

## Modular Integration Plan

### Stage 1: Foundation (Week 1) - CRITICAL PATH
**Goal:** Make existing modules functional

**Tasks:**
1. ✅ Create `PromptSegment` and related types
2. ✅ Create `PipelineContext` struct
3. ✅ Implement `MockAIService` for testing
4. ✅ Update all modules to use PromptSegment
5. ✅ Add PipelineContext parameter to all execute() methods
6. ✅ Validate compilation

**Deliverable:** All 6 modules compile and can be instantiated

**Cheetah Execution:**
```bash
# Task 1.1: Create DataModels.swift with PromptSegment
# Task 1.2: Add PipelineContext to continuity.swift
# Task 1.3: Create MockAIService in core.swift
# Task 1.4: Update rewording.swift to use PromptSegment
# Task 1.5: Update segmentation.swift to use PromptSegment
# Task 1.6: Update storyanalysis.swift to use PromptSegment
# Task 1.7: Update taxonomy.swift to use PromptSegment
# Task 1.8: Update continuity.swift to use PromptSegment
# Task 1.9: Compile and validate
```

---

### Stage 2: Pipeline Orchestration (Week 1-2)
**Goal:** End-to-end pipeline execution

**Tasks:**
1. Create `PipelineConfiguration.swift`
2. Create `PipelineOrchestrator.swift`
3. Implement step-by-step execution
4. Add progress tracking
5. Add error handling and retry
6. Add cancellation support
7. Integration tests

**Deliverable:** Can run full pipeline from story → packaged output

**Cheetah Execution:**
```bash
# Task 2.1: Create PipelineConfiguration.swift
# Task 2.2: Create PipelineOrchestrator.swift
# Task 2.3: Implement executeFullPipeline()
# Task 2.4: Add progress callbacks
# Task 2.5: Add error recovery
# Task 2.6: Add cancellation
# Task 2.7: Create integration test
```

---

### Stage 3: AI Service Integration (Week 2)
**Goal:** Real AI API calls

**Tasks:**
1. Create `AIService.swift` with DeepSeek implementation
2. Implement `KeychainService` for API keys
3. Add rate limiting
4. Add error handling
5. Replace MockAIService in modules
6. Test with real API

**Deliverable:** Rewording and Story Analysis work with real AI

**Cheetah Execution:**
```bash
# Task 3.1: Create KeychainService.swift
# Task 3.2: Create AIService.swift
# Task 3.3: Implement DeepSeek API
# Task 3.4: Add rate limiting
# Task 3.5: Update rewording.swift
# Task 3.6: Update storyanalysis.swift
# Task 3.7: Test with API key
```

---

### Stage 4: Persistence Layer (Week 2-3)
**Goal:** Save and load projects

**Tasks:**
1. Create `PersistenceController.swift`
2. Define CoreData model
3. Implement CRUD operations
4. Add migration support
5. Integrate with pipeline
6. Test save/load cycle

**Deliverable:** Projects persist across app launches

**Cheetah Execution:**
```bash
# Task 4.1: Create CoreDataModel.xcdatamodeld
# Task 4.2: Create PersistenceController.swift
# Task 4.3: Implement save operations
# Task 4.4: Implement fetch operations
# Task 4.5: Add to DirectorStudioCore
# Task 4.6: Test persistence
```

---

### Stage 5: Credits System (Week 3)
**Goal:** Monetization infrastructure

**Tasks:**
1. Create `CreditsService.swift`
2. Implement balance tracking
3. Add deduction logic
4. Create `StoreKitService.swift`
5. Implement purchase flow
6. Add first-clip grant
7. Test purchase flow

**Deliverable:** Credits system functional

**Cheetah Execution:**
```bash
# Task 5.1: Create CreditsService.swift
# Task 5.2: Implement balance tracking
# Task 5.3: Add deduction logic
# Task 5.4: Create StoreKitService.swift
# Task 5.5: Implement IAP
# Task 5.6: Test purchases
```

---

### Stage 6: UI Layer (Week 3-4)
**Goal:** User interface

**Tasks:**
1. Create `DirectorStudioApp.swift`
2. Create main tab navigation
3. Create pipeline progress UI
4. Create configuration UI
5. Create project list UI
6. Create scene detail UI
7. Polish and test

**Deliverable:** Functional iOS app

**Cheetah Execution:**
```bash
# Task 6.1: Create DirectorStudioApp.swift
# Task 6.2: Create MainTabView.swift
# Task 6.3: Create PipelineProgressView.swift
# Task 6.4: Create ConfigurationView.swift
# Task 6.5: Create ProjectListView.swift
# Task 6.6: Create SceneDetailView.swift
# Task 6.7: UI testing
```

---

### Stage 7: Advanced Features (Week 4+)
**Goal:** Production polish

**Tasks:**
1. Backend sync engine
2. Export functionality
3. Cost tracking
4. Analytics
5. Onboarding
6. Settings
7. Performance optimization

**Deliverable:** Production-ready app

---

## Risk Assessment & Mitigation

### 🔴 CRITICAL RISKS:

1. **Missing PromptSegment Type**
   - **Impact:** Blocks all modules
   - **Mitigation:** Implement immediately in Stage 1
   - **Timeline:** Day 1

2. **No AI Service Implementation**
   - **Impact:** Rewording and Story Analysis non-functional
   - **Mitigation:** Use MockAIService initially, real service in Stage 3
   - **Timeline:** Week 2

3. **Missing Pipeline Orchestrator**
   - **Impact:** Can't run end-to-end pipeline
   - **Mitigation:** Priority in Stage 2
   - **Timeline:** Week 1-2

### 🟡 MEDIUM RISKS:

1. **CoreData Complexity**
   - **Impact:** Persistence issues
   - **Mitigation:** Use in-memory storage initially
   - **Timeline:** Week 2-3

2. **StoreKit Integration**
   - **Impact:** Monetization delayed
   - **Mitigation:** Use mock credits initially
   - **Timeline:** Week 3

### 🟢 LOW RISKS:

1. **UI Polish**
   - **Impact:** User experience
   - **Mitigation:** Basic UI first, polish later
   - **Timeline:** Week 4+

2. **Backend Sync**
   - **Impact:** Cloud features
   - **Mitigation:** Local-only initially
   - **Timeline:** Week 4+

---

## Files to Discard (Superseded)

### Duplicates:
- `ContinuityBackup/` - Old version, use current `continuity.swift`
- `ContinuityEngineAnalysis/` - Analysis version, use current
- `files_rezipped/` - Old backup
- `newupgrade/` - Superseded by current modules
- `PipelineBackup/` - Old backup

### Obsolete:
- `ContentView.swift` - Placeholder file
- `CodebaseOptimizationGuide.swift` - Documentation only
- Multiple duplicate `CoreDataEntities.swift` files

### Keep for Reference:
- `DirectorStudioApp.swift` - UI structure reference
- `PipelineManager.swift` - Orchestration logic
- `PipelineConfig.swift` - Configuration patterns
- `AIServiceProtocol.swift` - Service interface
- `DeepSeekService.swift` - API implementation

---

## Success Criteria

### Stage 1 Complete:
- ✅ All modules compile without errors
- ✅ PromptSegment type exists and is used
- ✅ PipelineContext exists
- ✅ MockAIService works

### Stage 2 Complete:
- ✅ Can execute full pipeline
- ✅ Progress tracking works
- ✅ Error handling functional
- ✅ Cancellation works

### Stage 3 Complete:
- ✅ Real AI API calls work
- ✅ Rate limiting functional
- ✅ API keys secure
- ✅ Rewording produces real output

### Production Ready:
- ✅ All 6 modules functional
- ✅ Persistence works
- ✅ Credits system works
- ✅ UI complete
- ✅ Tests passing
- ✅ Performance acceptable

---

## Next Steps

1. **Review this plan** - Confirm approach
2. **Begin Stage 1** - Create foundation types
3. **Validate compilation** - Ensure modules work
4. **Proceed to Stage 2** - Build orchestrator
5. **Iterate** - Test and refine

---

## Appendix: File Inventory

### Core Modules (Current - Keep):
- ✅ `core.swift` - DirectorStudioCore
- ✅ `rewording.swift` - RewordingModule
- ✅ `segmentation.swift` - SegmentationModule
- ✅ `storyanalysis.swift` - StoryAnalysisModule
- ✅ `taxonomy.swift` - CinematicTaxonomyModule + PackagingModule
- ✅ `continuity.swift` - ContinuityModule

### To Implement (Priority Order):
1. 🔴 `DataModels.swift` - PromptSegment, PacingType, TransitionType
2. 🔴 `PipelineContext.swift` - Execution context
3. 🔴 `AIService.swift` - Real AI implementation
4. 🔴 `PipelineOrchestrator.swift` - Pipeline execution
5. 🟡 `PipelineConfiguration.swift` - User configuration
6. 🟡 `KeychainService.swift` - Secure storage
7. 🟡 `PersistenceController.swift` - CoreData
8. 🟡 `CreditsService.swift` - Monetization
9. 🟢 `DirectorStudioApp.swift` - UI entry point
10. 🟢 `ExportService.swift` - Export functionality

---

**Document Version:** 1.0
**Created:** 2025-10-19
**Status:** READY FOR EXECUTION

