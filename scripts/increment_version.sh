#!/bin/bash
set -e

# File to store the build number
BUILD_NUMBER_FILE=".build_number"

# Initialize if not exists
if [ ! -f "$BUILD_NUMBER_FILE" ]; then
    echo "1" > "$BUILD_NUMBER_FILE"
fi

# Read current version
current_version=$(cat "$BUILD_NUMBER_FILE")

# Increment
new_version=$((current_version + 1))

# Save
echo "$new_version" > "$BUILD_NUMBER_FILE"

echo "Build number incremented to $new_version"