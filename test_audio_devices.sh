#!/bin/bash

# Quick test script to verify the service can detect audio devices

echo "=== Testing Audio Device Detection ==="
echo ""
echo "This will run the service for 5 seconds to test audio device detection."
echo "Check the output for current audio device information."
echo ""

# Build if needed
if [ ! -f ".build/release/HeadphoneIssueService" ]; then
    echo "Building service first..."
    ./build.sh
fi

# Run the service for a few seconds
echo "Starting service..."
timeout 5 .build/release/HeadphoneIssueService || true

echo ""
echo "Test complete. If you saw device information above, the service is working correctly."

