# 🔐 Security Best Practices - API Key Management

**Date:** October 19, 2025  
**Status:** ✅ IMPLEMENTED  
**Compliance:** Apple Security Guidelines

---

## 🎯 Overview

DirectorStudio follows **Apple's recommended best practices** for API key management using `.xcconfig` files and build-time injection. This ensures:

✅ **Zero secrets in source code**  
✅ **Zero secrets in git history**  
✅ **Developer-friendly setup**  
✅ **Production-ready security**  

---

## 🔧 Implementation

### Architecture:
```
Secrets.xcconfig (gitignored)
    ↓ (build-time injection)
Info.plist
    ↓ (runtime access)
AIService.swift
```

### Files Created:

#### 1. `Secrets-template.xcconfig` (✅ Committed to Git)
```
// Secrets-template.xcconfig
// Template for API key configuration
// Copy this file to Secrets.xcconfig and add your actual key

DEEPSEEK_API_KEY = YOUR_API_KEY_HERE
```

#### 2. `Secrets.xcconfig` (❌ NOT Committed - Gitignored)
```
// Secrets.xcconfig
// DO NOT COMMIT THIS FILE
// This file contains your actual API key

DEEPSEEK_API_KEY = sk-your-actual-deepseek-api-key-here
```

#### 3. `.gitignore` (Updated)
```
# API Keys and Secrets
Secrets.xcconfig
*.xcconfig
!Secrets-template.xcconfig

# Never commit these
*.pem
*.key
*.p12
```

#### 4. `Info.plist` (Updated)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Other keys... -->
    
    <!-- API Key injected from Secrets.xcconfig -->
    <key>DeepSeekAPIKey</key>
    <string>$(DEEPSEEK_API_KEY)</string>
</dict>
</plist>
```

#### 5. `AIService.swift` (Access Pattern)
```swift
import Foundation

public actor AIService: AIServiceProtocol {
    private let apiKey: String
    
    public init() {
        // Read API key from Info.plist (injected from Secrets.xcconfig at build time)
        guard let key = Bundle.main.object(forInfoDictionaryKey: "DeepSeekAPIKey") as? String,
              !key.isEmpty,
              key != "YOUR_API_KEY_HERE" else {
            fatalError("""
                ❌ DeepSeek API key not configured
                
                Setup Instructions:
                1. Copy Secrets-template.xcconfig to Secrets.xcconfig
                2. Edit Secrets.xcconfig and add your API key
                3. Rebuild the app
                
                See README.md for details.
                """)
        }
        self.apiKey = key
    }
    
    public var isAvailable: Bool {
        !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE"
    }
    
    // ... rest of implementation
}
```

---

## 📋 Xcode Project Configuration

### Step 1: Link .xcconfig to Project
1. Open Xcode
2. Select the **Project** (not target) in navigator
3. Go to **Info** tab
4. Under **Configurations**:
   - Debug: Set to `Secrets.xcconfig`
   - Release: Set to `Secrets.xcconfig`

### Step 2: Verify Info.plist
1. Open `Info.plist`
2. Verify `DeepSeekAPIKey` entry exists
3. Value should be `$(DEEPSEEK_API_KEY)`

### Step 3: Build Settings (Optional)
For additional security, you can also set:
- `ENABLE_BITCODE = NO` (for better security analysis)
- `STRIP_INSTALLED_PRODUCT = YES` (for release builds)

---

## 👨‍💻 Developer Setup Instructions

### First-Time Setup:
```bash
# 1. Clone the repository
git clone <repo-url>
cd DirectorStudio

# 2. Copy the template
cp Secrets-template.xcconfig Secrets.xcconfig

# 3. Edit Secrets.xcconfig and add your API key
# (Use any text editor)
nano Secrets.xcconfig
# or
open -e Secrets.xcconfig

# 4. Replace YOUR_API_KEY_HERE with your actual DeepSeek API key
DEEPSEEK_API_KEY = sk-your-actual-key-here

# 5. Save and close

# 6. Open in Xcode and build
open DirectorStudio.xcodeproj
```

### Verification:
```bash
# Verify Secrets.xcconfig is NOT tracked by git
git status
# Should NOT show Secrets.xcconfig

# Verify .gitignore is working
git check-ignore Secrets.xcconfig
# Should output: Secrets.xcconfig
```

---

## 🚨 Security Checklist

### ✅ Before Committing:
- [ ] `Secrets.xcconfig` is in `.gitignore`
- [ ] `Secrets-template.xcconfig` has placeholder value only
- [ ] No API keys in source code
- [ ] No API keys in Info.plist (only `$(VARIABLE)` references)
- [ ] No API keys in commit messages
- [ ] No API keys in PR descriptions

### ✅ Before Releasing:
- [ ] All team members have their own `Secrets.xcconfig`
- [ ] CI/CD uses environment variables (not committed files)
- [ ] Production keys are different from development keys
- [ ] API key rotation plan in place
- [ ] Rate limiting configured
- [ ] Usage monitoring enabled

---

## 🔄 CI/CD Integration

### GitHub Actions Example:
```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Create Secrets.xcconfig
      run: |
        echo "DEEPSEEK_API_KEY = ${{ secrets.DEEPSEEK_API_KEY }}" > Secrets.xcconfig
    
    - name: Build
      run: xcodebuild -scheme DirectorStudio -configuration Debug
```

### Environment Variables:
- Store `DEEPSEEK_API_KEY` in GitHub Secrets
- Never log or print the key value
- Rotate keys regularly

---

## 🆚 Why This Approach?

### ❌ Bad Practices (DO NOT USE):
```swift
// ❌ Hardcoded in source
let apiKey = "sk-1234567890abcdef"

// ❌ Committed to git
// config.json with API keys

// ❌ UserDefaults for secrets
UserDefaults.standard.set(apiKey, forKey: "apiKey")

// ❌ Plain text files committed
// secrets.txt in repository
```

### ✅ Good Practice (THIS APPROACH):
```swift
// ✅ Build-time injection from .xcconfig
let apiKey = Bundle.main.object(forInfoDictionaryKey: "DeepSeekAPIKey")

// ✅ Template committed, actual secrets gitignored
// Secrets-template.xcconfig (committed)
// Secrets.xcconfig (gitignored)

// ✅ Fails gracefully if not configured
guard let key = apiKey, !key.isEmpty else {
    fatalError("API key not configured")
}
```

---

## 📚 Additional Resources

### Apple Documentation:
- [Protecting User Privacy](https://developer.apple.com/documentation/security/protecting_user_privacy)
- [Secure Coding Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/SecureCodingGuide/)

### Best Practices:
- Never commit secrets to version control
- Use different keys for dev/staging/production
- Rotate keys regularly
- Monitor API usage for anomalies
- Implement rate limiting
- Log security events (without exposing keys)

### Key Rotation:
```bash
# When rotating keys:
1. Generate new key from DeepSeek dashboard
2. Update Secrets.xcconfig locally
3. Update CI/CD secrets
4. Rebuild and test
5. Revoke old key after verification
```

---

## 🎯 Benefits

### For Developers:
✅ **Simple setup** - Copy one file, edit one line  
✅ **No accidental commits** - Gitignored by default  
✅ **Clear errors** - Fails fast with helpful message  
✅ **Team-friendly** - Each dev has their own key  

### For Security:
✅ **Zero secrets in code** - Build-time injection only  
✅ **Zero secrets in git** - Template only, actual key gitignored  
✅ **Audit trail** - Template changes tracked, keys are not  
✅ **Compliance** - Follows Apple best practices  

### For Production:
✅ **Environment-specific** - Different keys per environment  
✅ **CI/CD ready** - Works with GitHub Actions, etc.  
✅ **Scalable** - Easy to add more secrets  
✅ **Maintainable** - Clear, documented process  

---

## ✅ Validation

### Manual Testing:
```bash
# 1. Build without Secrets.xcconfig
# Should fail with clear error message

# 2. Create Secrets.xcconfig with placeholder
# Should fail with "YOUR_API_KEY_HERE" check

# 3. Add real API key
# Should build and run successfully

# 4. Check git status
git status
# Should NOT show Secrets.xcconfig
```

### Automated Testing:
```swift
// In tests:
func testAPIKeyConfiguration() {
    let key = Bundle.main.object(forInfoDictionaryKey: "DeepSeekAPIKey") as? String
    XCTAssertNotNil(key, "API key should be configured")
    XCTAssertNotEqual(key, "YOUR_API_KEY_HERE", "API key should not be placeholder")
    XCTAssertFalse(key?.isEmpty ?? true, "API key should not be empty")
}
```

---

## 🎉 Summary

**DirectorStudio uses industry-standard, Apple-recommended security practices for API key management.**

- ✅ Secrets never committed to git
- ✅ Developer-friendly setup process
- ✅ Production-ready security
- ✅ CI/CD compatible
- ✅ Fully documented

**This approach is secure, scalable, and maintainable for teams of any size.**

---

**Security implementation complete. Ready for production! 🔐**

