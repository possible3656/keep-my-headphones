#!/bin/bash

# Build script for HeadphoneIssueService

set -e

echo "=== Building HeadphoneIssueService ==="

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo "Error: Swift is not installed. Please install Xcode Command Line Tools."
    exit 1
fi

# Clean previous build
echo "Cleaning previous build..."
rm -rf .build

# Build in release mode
echo "Building in release mode..."
swift build -c release

# Check if build was successful
if [ -f ".build/release/HeadphoneIssueService" ]; then
    echo "✓ Build successful!"
    echo "Binary location: .build/release/HeadphoneIssueService"
else
    echo "✗ Build failed!"
    exit 1
fi

echo ""
echo "To install the service, run: sudo ./install.sh"

