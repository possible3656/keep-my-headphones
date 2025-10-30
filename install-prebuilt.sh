#!/bin/bash

# Installation script for pre-built KeepMyHeadphones binary
# No Xcode or Swift required!

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "=== Installing KeepMyHeadphones ==="

# Check if binary exists
if [ ! -f "KeepMyHeadphones" ]; then
    echo "Error: KeepMyHeadphones binary not found in current directory."
    echo "Please make sure you've extracted the release archive and are in the correct directory."
    exit 1
fi

# Check if plist exists
if [ ! -f "com.whybex.keepmyheadphones.plist" ]; then
    echo "Error: com.whybex.keepmyheadphones.plist not found in current directory."
    exit 1
fi

# Get the actual user (not root)
ACTUAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo ~$ACTUAL_USER)

# Stop the service if it's running
echo "Stopping service if running..."
sudo -u $ACTUAL_USER launchctl unload "$USER_HOME/Library/LaunchAgents/com.whybex.keepmyheadphones.plist" 2>/dev/null || true
# Also try to stop old service names if they exist
sudo -u $ACTUAL_USER launchctl unload "$USER_HOME/Library/LaunchAgents/com.keepmyheadphones.plist" 2>/dev/null || true
sudo -u $ACTUAL_USER launchctl unload "$USER_HOME/Library/LaunchAgents/com.headphoneissueservice.plist" 2>/dev/null || true

# Copy binary to /usr/local/bin
echo "Installing binary to /usr/local/bin..."
mkdir -p /usr/local/bin
cp KeepMyHeadphones /usr/local/bin/
chmod +x /usr/local/bin/KeepMyHeadphones

# Verify binary is executable
if [ ! -x /usr/local/bin/KeepMyHeadphones ]; then
    echo "Error: Failed to make binary executable"
    exit 1
fi

# Copy LaunchAgent plist
echo "Installing LaunchAgent..."
mkdir -p "$USER_HOME/Library/LaunchAgents"
cp com.whybex.keepmyheadphones.plist "$USER_HOME/Library/LaunchAgents/"
chown $ACTUAL_USER "$USER_HOME/Library/LaunchAgents/com.whybex.keepmyheadphones.plist"

# Load the LaunchAgent
echo "Loading LaunchAgent..."
sudo -u $ACTUAL_USER launchctl load "$USER_HOME/Library/LaunchAgents/com.whybex.keepmyheadphones.plist"

# Wait a moment for the service to start
sleep 2

# Check if service is running
if sudo -u $ACTUAL_USER launchctl list | grep -q "com.whybex.keepmyheadphones"; then
    echo ""
    echo "✓ Installation complete!"
    echo ""
    echo "The service is now running and will start automatically on boot."
    echo ""
    echo "Useful commands:"
    echo "  - Check status: launchctl list | grep keepmyheadphones"
    echo "  - View logs: tail -f ~/Library/Logs/KeepMyHeadphones/service.log"
    echo "  - Stop service: launchctl unload ~/Library/LaunchAgents/com.whybex.keepmyheadphones.plist"
    echo "  - Start service: launchctl load ~/Library/LaunchAgents/com.whybex.keepmyheadphones.plist"
    echo "  - Uninstall: sudo ./uninstall.sh"
else
    echo ""
    echo "⚠ Installation completed but service may not be running."
    echo "Check logs: tail -f ~/Library/Logs/KeepMyHeadphones/service.log"
    echo "Or system logs: tail -f /tmp/keep-my-headphones.err.log"
fi

