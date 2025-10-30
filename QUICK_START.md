# Quick Start Guide

## What This Service Does

Automatically fixes the macOS issue where external headphones disappear from audio devices after sleep/wake.

**How it works:**

- Before sleep: Switches from external headphones to built-in speakers
- After wake: Automatically switches back to your headphones

## Installation

### Option A: Pre-built Binary (Easiest - No Xcode!)

1. **Download** from [Releases](https://github.com/whybex/keep-my-headphones/releases)
2. **Extract:**
   ```bash
   tar -xzf KeepMyHeadphones-*-macos.tar.gz
   cd KeepMyHeadphones-*
   ```
3. **Install:**
   ```bash
   sudo ./install.sh
   ```
4. **Done!** Service is running.

### Option B: Build from Source

1. **Build:**

   ```bash
   ./build.sh
   ```

2. **Install:**

   ```bash
   sudo ./install.sh
   ```

3. **Done!** Service is running.

## Verify It's Working

```bash
# Check if service is running
launchctl list | grep keepmyheadphones

# View logs
tail -f ~/Library/Logs/KeepMyHeadphones/service.log
```

## Test It

1. Connect your external headphones
2. Select them as the output device in System Settings
3. Put your Mac to sleep (close the lid or use Apple menu > Sleep)
4. Wake your Mac
5. Your headphones should automatically be selected again!

Check the logs to see what happened:

```bash
cat ~/Library/Logs/KeepMyHeadphones/service.log
```

## Uninstall

```bash
sudo ./uninstall.sh
```

## Troubleshooting

**Service not running?**

```bash
launchctl load ~/Library/LaunchAgents/com.whybex.keepmyheadphones.plist
```

**Not switching devices?**

- Check logs: `tail -f ~/Library/Logs/KeepMyHeadphones/service.log`
- Make sure your headphones are detected as "external" devices
- Try restarting the service

**Need help?**
See the full [README.md](README.md) for detailed documentation.
