#!/bin/bash
set -e

# File to store the build number
BUILD_NUMBER_FILE="$SRCROOT/.build_number"

if [ ! -f "$BUILD_NUMBER_FILE" ]; then
    echo "Error: .build_number file not found at $BUILD_NUMBER_FILE"
    exit 1
fi

new_version=$(cat "$BUILD_NUMBER_FILE")
# Target the build artifact
plist_path="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

echo "Applying version $new_version to $plist_path"

if [ -f "$plist_path" ]; then
    # Use PlistBuddy to update the CFBundleVersion
    if /usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$plist_path" >/dev/null 2>&1; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $new_version" "$plist_path"
    else
        /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $new_version" "$plist_path"
    fi
    echo "Successfully updated CFBundleVersion to $new_version"

    # Also ensure CFBundleShortVersionString is set
    marketing_ver="${MARKETING_VERSION:-1.0}"
    if /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist_path" >/dev/null 2>&1; then
        current_short=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist_path")
        if [ "$current_short" == "\$(MARKETING_VERSION)" ] || [ -z "$current_short" ]; then
             /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $marketing_ver" "$plist_path"
             echo "Updated CFBundleShortVersionString to $marketing_ver"
        fi
    else
        /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $marketing_ver" "$plist_path"
        echo "Added CFBundleShortVersionString $marketing_ver"
    fi

else
    echo "Error: Info.plist not found at $plist_path"
    exit 1
fi