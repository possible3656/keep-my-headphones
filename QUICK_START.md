# Quick Start Guide

## What This Service Does

Automatically fixes the macOS issue where external headphones disappear from audio devices after sleep/wake.

**How it works:**
- Before sleep: Switches from external headphones to built-in speakers
- After wake: Automatically switches back to your headphones

## Installation (3 Steps)

### 1. Build
```bash
./build.sh
```

### 2. Install
```bash
sudo ./install.sh
```

### 3. Done!
The service is now running and will start automatically on boot.

## Verify It's Working

```bash
# Check if service is running
launchctl list | grep headphoneissueservice

# View logs
tail -f ~/Library/Logs/HeadphoneIssueService/service.log
```

## Test It

1. Connect your external headphones
2. Select them as the output device in System Settings
3. Put your Mac to sleep (close the lid or use Apple menu > Sleep)
4. Wake your Mac
5. Your headphones should automatically be selected again!

Check the logs to see what happened:
```bash
cat ~/Library/Logs/HeadphoneIssueService/service.log
```

## Uninstall

```bash
sudo ./uninstall.sh
```

## Troubleshooting

**Service not running?**
```bash
launchctl load ~/Library/LaunchAgents/com.headphoneissueservice.plist
```

**Not switching devices?**
- Check logs: `tail -f ~/Library/Logs/HeadphoneIssueService/service.log`
- Make sure your headphones are detected as "external" devices
- Try restarting the service

**Need help?**
See the full [README.md](README.md) for detailed documentation.

