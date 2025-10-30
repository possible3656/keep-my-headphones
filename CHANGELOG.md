# Changelog

## Version 1.1.0 - Rebranding & Bug Fixes

### Changed - Service Renamed to "Keep My Headphones"

**Old Name:** `HeadphoneIssueService` / `headphone-issue-service`  
**New Name:** `KeepMyHeadphones` / `keep-my-headphones`

**Package Identifier:** `com.whybex.keepmyheadphones`

#### Updated Files:
- **Package.swift** - Product and target renamed to `KeepMyHeadphones`
- **com.whybex.keepmyheadphones.plist** - LaunchAgent configuration with Whybex company identifier
- **build.sh** - Updated binary name references
- **install.sh** - Updated installation paths and service names
- **uninstall.sh** - Updated uninstallation paths (includes cleanup of old service names)
- **Sources/Logger.swift** - Updated log directory to `~/Library/Logs/KeepMyHeadphones/`
- **Sources/AudioDeviceManager.swift** - Updated state directory to `~/Library/Application Support/KeepMyHeadphones/`
- **README.md** - Updated all documentation references
- **QUICK_START.md** - Updated quick start guide

### Fixed - External Headphone Detection

**Issue:** External headphones connected via the 3.5mm headphone jack were incorrectly identified as "built-in" devices, causing the service to not save and restore them.

**Root Cause:** The original detection logic only checked the transport type. However, external headphones connected via the headphone jack use the same "Built-In" transport type as internal speakers because they share the same audio controller.

**Solution:** Implemented a multi-layered detection approach in `AudioDeviceManager.isBuiltInDevice()`:

1. **Name-based detection** - Checks device name for "external headphones", "headphones", etc.
2. **Transport type checking** - USB, Bluetooth, AirPlay, etc. are clearly external
3. **Data source checking** - For built-in transport, distinguishes headphone jack from internal speakers
4. **Enhanced logging** - Logs transport type and data source for debugging

#### Technical Details:
- Added `getTransportTypeName()` helper to decode transport type codes
- Added `getDataSourceName()` helper to check audio data source
- Improved logging to show device classification reasoning
- Handles edge cases like different headphone types and connection methods

### Migration Notes

If you have the old service installed:

1. **Uninstall the old service first:**
   ```bash
   sudo ./uninstall.sh
   ```

2. **Rebuild and install the new version:**
   ```bash
   ./build.sh
   sudo ./install.sh
   ```

The installation script automatically handles cleanup of old service names, but it's recommended to uninstall first for a clean migration.

### File Locations (New)

- **Binary**: `/usr/local/bin/KeepMyHeadphones`
- **LaunchAgent**: `~/Library/LaunchAgents/com.whybex.keepmyheadphones.plist`
- **Logs**: `~/Library/Logs/KeepMyHeadphones/service.log`
- **State**: `~/Library/Application Support/KeepMyHeadphones/device_state.json`

### File Locations (Old - Will be cleaned up)

- **Binary**: `/usr/local/bin/HeadphoneIssueService`
- **LaunchAgent**: `~/Library/LaunchAgents/com.headphoneissueservice.plist`
- **Logs**: `~/Library/Logs/HeadphoneIssueService/`
- **State**: `~/Library/Application Support/HeadphoneIssueService/`

---

## Version 1.0.0 - Initial Release

### Features

- Monitors macOS system sleep/wake events
- Automatically saves external headphone configuration before sleep
- Switches to built-in speakers before sleep to prevent device disappearance
- Restores external headphones after wake (with 2-second delay for audio system stabilization)
- Runs as a LaunchAgent for automatic startup on boot
- Comprehensive logging for troubleshooting
- Lightweight and efficient (5-10 MB memory, event-driven)

### Technical Implementation

- **Swift 5.9** with Swift Package Manager
- **CoreAudio Framework** for audio device management
- **IOKit Framework** for power event monitoring
- **LaunchAgent** for automatic service management
- State persistence using JSON in Application Support directory

