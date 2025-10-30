#!/bin/bash

# Uninstallation script for KeepMyHeadphones

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "=== Uninstalling KeepMyHeadphones ==="

# Get the actual user (not root)
ACTUAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo ~$ACTUAL_USER)

# Stop and unload the service
echo "Stopping service..."
sudo -u $ACTUAL_USER launchctl unload "$USER_HOME/Library/LaunchAgents/com.whybex.keepmyheadphones.plist" 2>/dev/null || true
# Also try to stop old service names if they exist
sudo -u $ACTUAL_USER launchctl unload "$USER_HOME/Library/LaunchAgents/com.keepmyheadphones.plist" 2>/dev/null || true
sudo -u $ACTUAL_USER launchctl unload "$USER_HOME/Library/LaunchAgents/com.headphoneissueservice.plist" 2>/dev/null || true

# Remove LaunchAgent plist
echo "Removing LaunchAgent..."
rm -f "$USER_HOME/Library/LaunchAgents/com.whybex.keepmyheadphones.plist"
rm -f "$USER_HOME/Library/LaunchAgents/com.keepmyheadphones.plist"
rm -f "$USER_HOME/Library/LaunchAgents/com.headphoneissueservice.plist"

# Remove binary
echo "Removing binary..."
rm -f /usr/local/bin/KeepMyHeadphones
rm -f /usr/local/bin/HeadphoneIssueService

# Ask if user wants to remove logs and data
echo ""
read -p "Do you want to remove logs and saved data? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing logs and data..."
    rm -rf "$USER_HOME/Library/Logs/KeepMyHeadphones"
    rm -rf "$USER_HOME/Library/Application Support/KeepMyHeadphones"
    # Also remove old directories if they exist
    rm -rf "$USER_HOME/Library/Logs/HeadphoneIssueService"
    rm -rf "$USER_HOME/Library/Application Support/HeadphoneIssueService"
    echo "Logs and data removed."
fi

echo ""
echo "✓ Uninstallation complete!"

