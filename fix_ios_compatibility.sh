#!/bin/bash

echo "🔧 Fixing iOS compatibility issues..."

# Fix system colors - replace Color(.systemGray6) with Color.systemGray6
find Sources/DirectorStudioUI -name "*.swift" -exec sed -i '' 's/Color(\.systemGray6)/Color.systemGray6/g' {} \;
find Sources/DirectorStudioUI -name "*.swift" -exec sed -i '' 's/Color(\.systemGray4)/Color.systemGray4/g' {} \;
find Sources/DirectorStudioUI -name "*.swift" -exec sed -i '' 's/Color(\.systemBackground)/Color.systemBackground/g' {} \;

# Remove macOS-specific navigation modifiers
find Sources/DirectorStudioUI -name "*.swift" -exec sed -i '' '/\.navigationBarTitleDisplayMode(/d' {} \;

# Fix toolbar placements
find Sources/DirectorStudioUI -name "*.swift" -exec sed -i '' 's/\.navigationBarTrailing/.topBarTrailing/g' {} \;
find Sources/DirectorStudioUI -name "*.swift" -exec sed -i '' 's/\.navigationBarLeading/.topBarLeading/g' {} \;

# Fix Button syntax - replace Button(action: { ... }) { ... } with Button { ... } label: { ... }
find Sources/DirectorStudioUI -name "*.swift" -exec sed -i '' 's/Button(action: { \([^}]*\) }) {/Button { \1 } label: {/g' {} \;

# Fix UIPasteboard references - replace with iOS-compatible version
find Sources/DirectorStudioUI -name "*.swift" -exec sed -i '' 's/UIPasteboard\.general\.string = /UIPasteboard.general.string = /g' {} \;

# Remove UIImpactFeedbackGenerator references (not needed for basic functionality)
find Sources/DirectorStudioUI -name "*.swift" -exec sed -i '' '/UIImpactFeedbackGenerator/d' {} \;
find Sources/DirectorStudioUI -name "*.swift" -exec sed -i '' '/impactFeedback\.impactOccurred/d' {} \;

echo "✅ iOS compatibility fixes applied!"
