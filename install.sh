#!/bin/bash

# Installation script for HeadphoneIssueService

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "=== Installing HeadphoneIssueService ==="

# Check if binary exists
if [ ! -f ".build/release/HeadphoneIssueService" ]; then
    echo "Error: Binary not found. Please run ./build.sh first."
    exit 1
fi

# Stop the service if it's running
echo "Stopping service if running..."
launchctl unload ~/Library/LaunchAgents/com.headphoneissueservice.plist 2>/dev/null || true

# Copy binary to /usr/local/bin
echo "Installing binary to /usr/local/bin..."
mkdir -p /usr/local/bin
cp .build/release/HeadphoneIssueService /usr/local/bin/
chmod +x /usr/local/bin/HeadphoneIssueService

# Get the actual user (not root)
ACTUAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo ~$ACTUAL_USER)

# Copy LaunchAgent plist
echo "Installing LaunchAgent..."
mkdir -p "$USER_HOME/Library/LaunchAgents"
cp com.headphoneissueservice.plist "$USER_HOME/Library/LaunchAgents/"
chown $ACTUAL_USER "$USER_HOME/Library/LaunchAgents/com.headphoneissueservice.plist"

# Load the LaunchAgent
echo "Loading LaunchAgent..."
sudo -u $ACTUAL_USER launchctl load "$USER_HOME/Library/LaunchAgents/com.headphoneissueservice.plist"

echo ""
echo "✓ Installation complete!"
echo ""
echo "The service is now running and will start automatically on boot."
echo ""
echo "Useful commands:"
echo "  - Check status: launchctl list | grep headphoneissueservice"
echo "  - View logs: tail -f ~/Library/Logs/HeadphoneIssueService/service.log"
echo "  - Stop service: launchctl unload ~/Library/LaunchAgents/com.headphoneissueservice.plist"
echo "  - Start service: launchctl load ~/Library/LaunchAgents/com.headphoneissueservice.plist"
echo "  - Uninstall: sudo ./uninstall.sh"

