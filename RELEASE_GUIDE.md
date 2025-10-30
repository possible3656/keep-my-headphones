# Release Guide for Keep My Headphones

This guide explains how to create releases for distribution on GitHub.

## Why Pre-built Releases?

Pre-built releases allow users to install the service **without needing Xcode or Swift installed**. This makes installation much easier for end users.

## Creating a Release

### Method 1: Using the Release Script (Recommended)

1. **Create the release package:**
   ```bash
   ./create-release.sh 1.1.0
   ```
   
   This will:
   - Build the binary in release mode
   - Create a directory with all necessary files
   - Package everything into a `.tar.gz` file
   - Generate SHA-256 checksum

2. **Test the package locally (optional but recommended):**
   ```bash
   # Extract to a test directory
   mkdir test-install
   cd test-install
   tar -xzf ../KeepMyHeadphones-1.1.0-macos.tar.gz
   cd KeepMyHeadphones-1.1.0
   
   # Test installation
   sudo ./install.sh
   
   # Verify it works
   launchctl list | grep keepmyheadphones
   tail -f ~/Library/Logs/KeepMyHeadphones/service.log
   
   # Uninstall after testing
   sudo ./uninstall.sh
   cd ../..
   rm -rf test-install
   ```

3. **Create a Git tag:**
   ```bash
   git tag -a v1.1.0 -m "Release version 1.1.0"
   git push origin v1.1.0
   ```

4. **Create GitHub Release:**

   **Option A: Using GitHub Web Interface**
   
   1. Go to your repository on GitHub
   2. Click "Releases" → "Create a new release"
   3. Select the tag you just created (v1.1.0)
   4. Set the title: "Keep My Headphones v1.1.0"
   5. Add release notes (see template below)
   6. Upload these files:
      - `KeepMyHeadphones-1.1.0-macos.tar.gz`
      - `KeepMyHeadphones-1.1.0-macos.tar.gz.sha256`
   7. Click "Publish release"

   **Option B: Using GitHub CLI (gh)**
   
   ```bash
   gh release create v1.1.0 \
     KeepMyHeadphones-1.1.0-macos.tar.gz \
     KeepMyHeadphones-1.1.0-macos.tar.gz.sha256 \
     --title "Keep My Headphones v1.1.0" \
     --notes-file RELEASE_NOTES.md
   ```

### Method 2: Automatic GitHub Actions (Future)

The repository includes a GitHub Actions workflow (`.github/workflows/release.yml`) that will automatically build and create releases when you push a tag.

**To use it:**
```bash
git tag v1.1.0
git push origin v1.1.0
```

The workflow will automatically:
- Build the binary on GitHub's macOS runners
- Create the release package
- Upload it to GitHub Releases

## Release Notes Template

Create a file called `RELEASE_NOTES.md` with content like this:

```markdown
## Keep My Headphones v1.1.0

### 🎉 What's New

- Improved external headphone detection
- Fixed issue where 3.5mm headphones weren't recognized as external
- Rebranded to "Keep My Headphones" with Whybex company identifier

### 📦 Installation (No Xcode Required!)

1. **Download** `KeepMyHeadphones-1.1.0-macos.tar.gz`
2. **Extract:**
   ```bash
   tar -xzf KeepMyHeadphones-1.1.0-macos.tar.gz
   cd KeepMyHeadphones-1.1.0
   ```
3. **Install:**
   ```bash
   sudo ./install.sh
   ```

### ✅ System Requirements

- macOS 12.0 (Monterey) or later
- No Xcode or developer tools required!

### 🔐 Verify Download

Check the SHA-256 checksum:
```bash
shasum -a 256 KeepMyHeadphones-1.1.0-macos.tar.gz
```
Compare with the `.sha256` file.

### 📝 Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete details.

### 🐛 Bug Reports

Found an issue? [Open an issue](https://github.com/whybex/keep-my-headphones/issues)
```

## What Gets Included in the Release Package

The release package includes:
- `KeepMyHeadphones` - Pre-built binary (no compilation needed)
- `install.sh` - Installation script
- `uninstall.sh` - Uninstallation script
- `com.whybex.keepmyheadphones.plist` - LaunchAgent configuration
- `README.md` - Full documentation
- `QUICK_START.md` - Quick start guide
- `CHANGELOG.md` - Version history

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- **Major** (1.0.0): Breaking changes
- **Minor** (1.1.0): New features, backward compatible
- **Patch** (1.1.1): Bug fixes, backward compatible

## Checklist Before Release

- [ ] Update version in CHANGELOG.md
- [ ] Test the service thoroughly
- [ ] Build and test the release package locally
- [ ] Update README.md if needed
- [ ] Create and push git tag
- [ ] Create GitHub release with binaries
- [ ] Test installation from the release package
- [ ] Announce the release (if applicable)

## Troubleshooting

### "Binary is damaged and can't be opened"

Users might see this error on macOS Catalina or later due to Gatekeeper. They can fix it with:

```bash
xattr -cr KeepMyHeadphones-1.1.0
cd KeepMyHeadphones-1.1.0
sudo ./install.sh
```

Consider code signing the binary in the future to avoid this issue.

### Binary doesn't work on older macOS versions

The binary is built for macOS 12.0+. To support older versions, you would need to:
1. Lower the deployment target in Package.swift
2. Test on older macOS versions
3. Create separate builds for different macOS versions

## Future Improvements

- [ ] Code sign the binary to avoid Gatekeeper warnings
- [ ] Notarize the app with Apple
- [ ] Create a .pkg installer for easier installation
- [ ] Support multiple macOS versions with separate builds
- [ ] Automate releases with GitHub Actions

