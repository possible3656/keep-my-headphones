#!/bin/bash

# Script to create a release package for distribution
# This creates a tarball that users can download and install without Xcode

set -e

VERSION=${1:-"latest"}

echo "=== Creating Release Package for KeepMyHeadphones ==="
echo "Version: $VERSION"
echo ""

# Build the release binary
echo "Building release binary..."
./build.sh

# Create release directory
RELEASE_DIR="KeepMyHeadphones-${VERSION}"
echo "Creating release package in ${RELEASE_DIR}..."
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# Copy files
echo "Copying files..."
cp .build/release/KeepMyHeadphones "$RELEASE_DIR/"
cp com.whybex.keepmyheadphones.plist "$RELEASE_DIR/"
cp install-prebuilt.sh "$RELEASE_DIR/install.sh"
cp uninstall.sh "$RELEASE_DIR/"
cp README.md "$RELEASE_DIR/"
cp QUICK_START.md "$RELEASE_DIR/"
cp CHANGELOG.md "$RELEASE_DIR/"

# Make scripts executable
chmod +x "$RELEASE_DIR/KeepMyHeadphones"
chmod +x "$RELEASE_DIR/install.sh"
chmod +x "$RELEASE_DIR/uninstall.sh"

# Create tarball
TARBALL="KeepMyHeadphones-${VERSION}-macos.tar.gz"
echo "Creating tarball: $TARBALL"
tar -czf "$TARBALL" "$RELEASE_DIR"

# Generate checksum
echo "Generating checksum..."
shasum -a 256 "$TARBALL" > "${TARBALL}.sha256"

# Get file size
SIZE=$(du -h "$TARBALL" | cut -f1)

echo ""
echo "✓ Release package created successfully!"
echo ""
echo "Package: $TARBALL"
echo "Size: $SIZE"
echo "Checksum: $(cat ${TARBALL}.sha256)"
echo ""
echo "To test the package:"
echo "  1. Extract: tar -xzf $TARBALL"
echo "  2. Install: cd $RELEASE_DIR && sudo ./install.sh"
echo ""
echo "To create a GitHub release:"
echo "  1. Create a new tag: git tag v${VERSION}"
echo "  2. Push the tag: git push origin v${VERSION}"
echo "  3. Upload $TARBALL and ${TARBALL}.sha256 to the GitHub release"
echo ""
echo "Or use the GitHub CLI:"
echo "  gh release create v${VERSION} $TARBALL ${TARBALL}.sha256 --title \"Keep My Headphones v${VERSION}\" --notes \"See CHANGELOG.md for details\""

