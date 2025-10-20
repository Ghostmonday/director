#!/bin/bash
# 🤖 Stage Daemon Installation Script

echo "🚀 Installing Stage Validation Daemon"

# Check if launchd plist exists
PLIST_SOURCE="/Users/user944529/Desktop/director/automation/daemon/com.ghostmonday.director.stage-daemon.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/com.ghostmonday.director.stage-daemon.plist"

if [[ ! -f "$PLIST_SOURCE" ]]; then
    echo "❌ Error: Daemon plist not found at $PLIST_SOURCE"
    exit 1
fi

# Copy plist to LaunchAgents
echo "📋 Copying daemon configuration..."
cp "$PLIST_SOURCE" "$PLIST_DEST"

# Set correct permissions
echo "🔒 Setting permissions..."
chmod 644 "$PLIST_DEST"

# Load the daemon
echo "🔄 Loading daemon..."
launchctl load "$PLIST_DEST"

# Start the daemon
echo "🚀 Starting daemon..."
launchctl start com.ghostmonday.director.stage-daemon

echo ""
echo "✅ Stage Validation Daemon installed successfully!"
echo "📊 Logs will be written to: automation/logs/daemon.log"
echo "🔍 Check status with: launchctl list | grep director"
echo "⏰ Daemon will run hourly and auto-start on login"
echo ""
echo "🧪 Test the daemon manually:"
echo "   ./automation/daemon/stage-validation-daemon.sh --test"
echo "   ./automation/daemon/stage-validation-daemon.sh --once"
