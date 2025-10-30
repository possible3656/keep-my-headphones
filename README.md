# Headphone Issue Service for macOS

A lightweight macOS background service that solves the common audio device switching issue where external headphones disappear from the available audio devices list after the MacBook wakes from sleep.

## Problem Statement

On macOS, when an external headphone is selected as the output audio device and the MacBook goes to sleep, the external headphone device often disappears from the available audio devices list upon wake. This is a known issue reported by many users across various macOS versions.

## Solution

This service automatically:
1. **Before Sleep**: Detects if an external headphone is currently selected, saves its information, and switches to built-in speakers
2. **After Wake**: Checks if the previously used external headphone is available and automatically switches back to it

## Features

- ✅ Monitors system sleep/wake events
- ✅ Automatically switches audio devices before sleep and after wake
- ✅ Handles edge cases (different headphones, no headphones, etc.)
- ✅ Runs silently in the background
- ✅ Starts automatically on system boot
- ✅ Lightweight with minimal system impact
- ✅ Comprehensive logging for troubleshooting

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode Command Line Tools (for building)
- Swift 5.9 or later

## Installation

### 1. Install Xcode Command Line Tools (if not already installed)

```bash
xcode-select --install
```

### 2. Clone or Download this Repository

```bash
cd ~/mac-apps
git clone <repository-url> headphone-issue-service
cd headphone-issue-service
```

### 3. Build the Service

```bash
./build.sh
```

### 4. Install the Service

```bash
sudo ./install.sh
```

The service will be installed to `/usr/local/bin/HeadphoneIssueService` and configured to start automatically on boot.

## Usage

Once installed, the service runs automatically in the background. No user interaction is required.

### Checking Service Status

```bash
launchctl list | grep headphoneissueservice
```

If the service is running, you'll see output like:
```
12345   0   com.headphoneissueservice
```

### Viewing Logs

The service maintains detailed logs for troubleshooting:

```bash
# View real-time logs
tail -f ~/Library/Logs/HeadphoneIssueService/service.log

# View all logs
cat ~/Library/Logs/HeadphoneIssueService/service.log
```

### Manual Control

**Stop the service:**
```bash
launchctl unload ~/Library/LaunchAgents/com.headphoneissueservice.plist
```

**Start the service:**
```bash
launchctl load ~/Library/LaunchAgents/com.headphoneissueservice.plist
```

**Restart the service:**
```bash
launchctl unload ~/Library/LaunchAgents/com.headphoneissueservice.plist
launchctl load ~/Library/LaunchAgents/com.headphoneissueservice.plist
```

## Uninstallation

To completely remove the service:

```bash
sudo ./uninstall.sh
```

You'll be prompted whether to remove logs and saved data.

## How It Works

### Architecture

The service consists of four main components:

1. **AudioDeviceManager**: Handles all audio device operations using CoreAudio APIs
   - Detects current output device
   - Lists all available audio devices
   - Switches between devices
   - Identifies built-in vs. external devices
   - Persists device state

2. **PowerEventMonitor**: Monitors system power events using IOKit
   - Detects when system is going to sleep
   - Detects when system wakes up
   - Provides callbacks for power events

3. **HeadphoneService**: Main coordinator that orchestrates the solution
   - Responds to sleep events by saving external headphone info and switching to speakers
   - Responds to wake events by restoring the previous external headphone

4. **Logger**: Provides comprehensive logging for debugging and monitoring

### Workflow

**Before Sleep:**
```
1. System sends "will sleep" notification
2. Service checks current output device
3. If external headphone → save device info + switch to built-in speakers
4. If built-in device → no action needed
5. System goes to sleep
```

**After Wake:**
```
1. System sends "did wake" notification
2. Service waits 2 seconds for audio system to stabilize
3. Check if external headphone was previously saved
4. If saved device is available → switch back to it
5. If not available → keep current device
6. Clear saved device state
```

### Edge Cases Handled

- ✅ Different headphones connected after wake
- ✅ No headphones connected after wake
- ✅ Multiple external audio devices
- ✅ System not sleeping (cancelled sleep)
- ✅ Audio system not ready immediately after wake

## Troubleshooting

### Service Not Starting

1. Check if the service is loaded:
   ```bash
   launchctl list | grep headphoneissueservice
   ```

2. Check for errors in system logs:
   ```bash
   tail -f /tmp/headphone-issue-service.err.log
   ```

3. Try reloading the service:
   ```bash
   launchctl unload ~/Library/LaunchAgents/com.headphoneissueservice.plist
   launchctl load ~/Library/LaunchAgents/com.headphoneissueservice.plist
   ```

### Audio Not Switching

1. Check the service logs:
   ```bash
   tail -f ~/Library/Logs/HeadphoneIssueService/service.log
   ```

2. Verify your headphones are detected as external devices:
   - The service only switches external devices
   - Built-in audio ports may not be detected as external

3. Test the sleep/wake cycle:
   - Put your Mac to sleep manually
   - Check logs for "Handling System Sleep" and "Handling System Wake" messages

### Permissions Issues

The service requires access to:
- Audio device management (CoreAudio)
- Power event notifications (IOKit)
- File system (for logs and state)

These are standard system APIs and don't require special permissions.

## Technical Details

### Technologies Used

- **Swift**: Modern, safe, and performant
- **CoreAudio**: macOS audio device management
- **IOKit**: System power event monitoring
- **LaunchAgent**: Automatic startup on boot

### File Locations

- **Binary**: `/usr/local/bin/HeadphoneIssueService`
- **LaunchAgent**: `~/Library/LaunchAgents/com.headphoneissueservice.plist`
- **Logs**: `~/Library/Logs/HeadphoneIssueService/service.log`
- **State**: `~/Library/Application Support/HeadphoneIssueService/device_state.json`

### Performance

- **Memory**: ~5-10 MB
- **CPU**: Negligible (event-driven, not polling)
- **Disk**: Minimal (logs rotate, state file is tiny)

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is provided as-is for personal use.

## Acknowledgments

This service was created to solve a common macOS issue that affects many users with external audio devices.

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review the logs for error messages
3. Open an issue with detailed information about your setup and the problem

---

**Note**: This service is designed for MacBook users experiencing the external headphone disappearing issue after sleep/wake cycles. It may not be necessary for all users or all audio devices.

