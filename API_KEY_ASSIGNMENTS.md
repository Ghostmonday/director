# 🔑 API Key Assignments - CRITICAL REFERENCE

**Date:** October 19, 2025  
**Status:** ⚠️ CRITICAL - DO NOT DEVIATE  
**Purpose:** Prevent integration errors from previous project

---

## 🚨 CRITICAL: Two Distinct API Keys

DirectorStudio uses **TWO SEPARATE API KEYS** with **ZERO OVERLAP**.

### ⚠️ Previous Integration Errors:
- API keys were mixed up
- Wrong service called for wrong tasks
- Caused failures and confusion

### ✅ Correct Assignment (MUST FOLLOW):

---

## 🔵 DeepSeek API Key

**Variable Name:** `DEEPSEEK_API_KEY`  
**Info.plist Key:** `DeepSeekAPIKey`  
**Service:** `AIService.swift`

### Used EXCLUSIVELY For:
1. ✅ **Rewording Module** - All text transformations (7 types)
2. ✅ **Story Analysis Module** - 8-phase narrative analysis
3. ✅ **Taxonomy Module** - Cinematic enrichment metadata
4. ✅ **Continuity Module** - Validation and tracking
5. ✅ **All text-based AI operations**

### NEVER Used For:
- ❌ Image generation
- ❌ Visual content creation
- ❌ Any Pollo API tasks

---

## 🟢 Pollo API Key

**Variable Name:** `POLLO_API_KEY`  
**Info.plist Key:** `PolloAPIKey`  
**Service:** `ImageGenerationService.swift`

### Used EXCLUSIVELY For:
1. ✅ **Image Generation Module** - Creating visual content
2. ✅ **Visual content creation ONLY**

### NEVER Used For:
- ❌ Text processing
- ❌ Rewording
- ❌ Story analysis
- ❌ Taxonomy
- ❌ Continuity
- ❌ Any DeepSeek API tasks

---

## 📋 Module-to-API Mapping

```
┌─────────────────────────────────────────────────────────────┐
│                    MODULE API ASSIGNMENTS                    │
└─────────────────────────────────────────────────────────────┘

📝 TEXT PROCESSING (DeepSeek API):
├── RewordingModule          → AIService (DeepSeek)
├── StoryAnalysisModule      → AIService (DeepSeek)
├── TaxonomyModule           → AIService (DeepSeek)
└── ContinuityModule         → AIService (DeepSeek)

🎨 IMAGE GENERATION (Pollo API):
└── ImageGenerationModule    → ImageGenerationService (Pollo)

⚠️ NO CROSSOVER ALLOWED
```

---

## 🔧 Implementation Checklist

### Secrets.xcconfig:
```
// ⚠️ CRITICAL: Use correct API key for each service

// DeepSeek: Text processing (rewording, story analysis, taxonomy, continuity)
DEEPSEEK_API_KEY = sk-your-deepseek-key-here

// Pollo: Image generation ONLY
POLLO_API_KEY = your-pollo-key-here
```

### Info.plist:
```xml
<!-- Text Processing API (DeepSeek) -->
<key>DeepSeekAPIKey</key>
<string>$(DEEPSEEK_API_KEY)</string>

<!-- Image Generation API (Pollo) -->
<key>PolloAPIKey</key>
<string>$(POLLO_API_KEY)</string>
```

### AIService.swift (DeepSeek):
```swift
public actor AIService: AIServiceProtocol {
    private let deepSeekAPIKey: String
    
    public init() {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "DeepSeekAPIKey") as? String,
              !key.isEmpty,
              key != "YOUR_DEEPSEEK_API_KEY_HERE" else {
            fatalError("DeepSeek API key not configured")
        }
        self.deepSeekAPIKey = key
    }
    
    // ⚠️ ONLY makes requests to DeepSeek API
    // Used by: Rewording, StoryAnalysis, Taxonomy, Continuity
}
```

### ImageGenerationService.swift (Pollo):
```swift
public actor ImageGenerationService {
    private let polloAPIKey: String
    
    public init() {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "PolloAPIKey") as? String,
              !key.isEmpty,
              key != "YOUR_POLLO_API_KEY_HERE" else {
            fatalError("Pollo API key not configured")
        }
        self.polloAPIKey = key
    }
    
    // ⚠️ ONLY makes requests to Pollo API
    // Used by: ImageGeneration module EXCLUSIVELY
}
```

---

## ✅ Validation Rules

### Before Committing:
- [ ] DeepSeek key ONLY in AIService.swift
- [ ] Pollo key ONLY in ImageGenerationService.swift
- [ ] No key mixing in any module
- [ ] Both keys defined in Secrets-template.xcconfig
- [ ] Info.plist has both keys with correct variable names
- [ ] README documents both keys and their specific uses

### Before Running:
- [ ] Secrets.xcconfig has BOTH keys
- [ ] Keys are NOT swapped
- [ ] Test DeepSeek connection (text modules)
- [ ] Test Pollo connection (image module)
- [ ] Verify no crossover in logs

### During Development:
- [ ] Rewording uses AIService (DeepSeek)
- [ ] StoryAnalysis uses AIService (DeepSeek)
- [ ] Taxonomy uses AIService (DeepSeek)
- [ ] Continuity uses AIService (DeepSeek)
- [ ] ImageGeneration uses ImageGenerationService (Pollo)
- [ ] NO module uses both services

---

## 🚨 Common Mistakes to Avoid

### ❌ WRONG:
```swift
// DON'T DO THIS:
class RewordingModule {
    let polloService = ImageGenerationService() // ❌ WRONG API
}

// DON'T DO THIS:
class ImageGenerationModule {
    let aiService = AIService() // ❌ WRONG API
}

// DON'T DO THIS:
let apiKey = Bundle.main.object(forInfoDictionaryKey: "PolloAPIKey") // ❌ In AIService
```

### ✅ CORRECT:
```swift
// DO THIS:
class RewordingModule {
    let aiService = AIService() // ✅ DeepSeek for text
}

// DO THIS:
class ImageGenerationModule {
    let imageService = ImageGenerationService() // ✅ Pollo for images
}

// DO THIS in AIService:
let apiKey = Bundle.main.object(forInfoDictionaryKey: "DeepSeekAPIKey") // ✅ Correct key

// DO THIS in ImageGenerationService:
let apiKey = Bundle.main.object(forInfoDictionaryKey: "PolloAPIKey") // ✅ Correct key
```

---

## 📊 API Usage Matrix

| Module | Service | API Key | Purpose |
|--------|---------|---------|---------|
| Rewording | AIService | DeepSeek | Text transformation |
| StoryAnalysis | AIService | DeepSeek | Narrative analysis |
| Taxonomy | AIService | DeepSeek | Cinematic metadata |
| Continuity | AIService | DeepSeek | Validation/tracking |
| ImageGeneration | ImageGenerationService | Pollo | Visual content |

**Total Services:** 2  
**Total API Keys:** 2  
**Overlap:** 0 (ZERO)

---

## 🔍 Testing Verification

### Test 1: DeepSeek API (Text Processing)
```swift
func testDeepSeekAPI() async throws {
    let aiService = AIService()
    let result = try await aiService.sendRequest(
        systemPrompt: "Test",
        userPrompt: "Hello",
        temperature: 0.7,
        maxTokens: 100
    )
    XCTAssertFalse(result.isEmpty)
    // ✅ Should succeed with DeepSeek key
}
```

### Test 2: Pollo API (Image Generation)
```swift
func testPolloAPI() async throws {
    let imageService = ImageGenerationService()
    let result = try await imageService.generateImage(
        prompt: "Test image",
        style: .cinematic
    )
    XCTAssertNotNil(result.imageData)
    // ✅ Should succeed with Pollo key
}
```

### Test 3: No Crossover
```swift
func testNoCrossover() {
    // AIService should NEVER use Pollo key
    // ImageGenerationService should NEVER use DeepSeek key
    // Verify in logs that correct endpoints are called
}
```

---

## 📝 Documentation Requirements

### README.md Must Include:
```markdown
## API Keys

DirectorStudio requires TWO API keys:

1. **DeepSeek API Key** - For text processing
   - Get yours at: https://deepseek.com
   - Used by: Rewording, Story Analysis, Taxonomy, Continuity

2. **Pollo API Key** - For image generation
   - Get yours at: https://pollo.ai
   - Used by: Image Generation module ONLY

⚠️ CRITICAL: Do NOT mix up these keys!

Setup:
1. Copy Secrets-template.xcconfig to Secrets.xcconfig
2. Add BOTH keys
3. Rebuild

See SECURITY_BEST_PRACTICES.md for details.
```

---

## 🎯 Summary

### The Rule:
```
DeepSeek = Text Processing
Pollo = Image Generation
NO OVERLAP. EVER.
```

### Why This Matters:
- ✅ Prevents API errors
- ✅ Correct billing per service
- ✅ Clear separation of concerns
- ✅ Easier debugging
- ✅ Matches previous project architecture

### Enforcement:
- ⚠️ Code review must verify correct API usage
- ⚠️ Tests must validate no crossover
- ⚠️ Documentation must be clear
- ⚠️ Fatalerror if wrong key used

---

**THIS DOCUMENT IS CRITICAL. DO NOT DEVIATE FROM THESE ASSIGNMENTS.**

**Any deviation will cause the same integration errors as the previous project.**

**When in doubt, refer to this document.**

---

**Last Updated:** October 19, 2025  
**Status:** ✅ APPROVED - READY FOR IMPLEMENTATION

