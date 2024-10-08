#!/bin/bash

print_usage() {
    echo "Usage: $0 <android|ios|both> [clean]"
    echo "  android|ios|both: Platform to run"
    echo "  clean: Optional. Clean the build before running"
}

if [ "$#" -lt 1 ]; then
    print_usage
    exit 1
fi

PLATFORM=$1
CLEAN=${2:-""}

clean_ios() {
    echo "Cleaning iOS build..."
    cd ios
    if [ ! -f "$(ls *.xcodeproj 2>/dev/null)" ]; then
        echo "Error: No Xcode project found in ios/."
        exit 1
    fi
    xcodebuild clean -project *.xcodeproj
    cd ..
}

clean_android() {
    echo "Cleaning Android build..."
    cd android
    if [ ! -f "./gradlew" ]; then
        echo "Error: gradlew not found. Ensure you're in the correct Android project directory."
        exit 1
    fi
    ./gradlew clean
    cd ..
}

# Compile the Dart code
echo "Compiling Dart code..."
dart compile exe lib/main.dart -o dn_app
if [ $? -ne 0 ]; then
    echo "Error: Dart compilation failed."
    exit 1
fi

run_ios() {
    echo "Building and running iOS app..."
    cd ios
    PROJECT=$(ls *.xcodeproj | head -n 1)
    
    if [ -z "$PROJECT" ]; then
        echo "Error: No Xcode project found in ios/ directory."
        exit 1
    fi
    
    SCHEME=$(xcodebuild -list -project $PROJECT | grep -A1 "Schemes:" | tail -n1 | xargs)

    # Clean up project file if needed
    sed -i '' '/Info.plist/d' $PROJECT/project.pbxproj
    
    # Ensure correct Info.plist path in Build Settings
    plutil -replace INFOPLIST_FILE -string "$(basename $PROJECT .xcodeproj)/Info.plist" $PROJECT/project.pbxproj

    # Update Info.plist versioning
    INFO_PLIST_PATH="$(basename $PROJECT .xcodeproj)/Info.plist"
    plutil -replace CFBundleVersion -string "1" "$INFO_PLIST_PATH"
    plutil -replace CFBundleShortVersionString -string "1.0" "$INFO_PLIST_PATH"

    # List available simulators and let the user choose
    echo "Available iOS Simulators:"
    xcrun simctl list devices | grep -v '^--' | grep -v '^ --' | grep -v '^$' | nl
    read -p "Enter the number of the simulator you want to use: " SIMULATOR_NUMBER

    SIMULATOR_ID=$(xcrun simctl list devices | grep -v '^--' | grep -v '^ --' | grep -v '^$' | sed -n "${SIMULATOR_NUMBER}p" | awk -F'[()]' '{print $2}')
    SIMULATOR_NAME=$(xcrun simctl list devices | grep -v '^--' | grep -v '^ --' | grep -v '^$' | sed -n "${SIMULATOR_NUMBER}p" | awk -F'[()]' '{print $1}' | xargs)

    if [ -z "$SIMULATOR_ID" ]; then
        echo "Error: Invalid simulator selected."
        exit 1
    fi

    echo "Building for simulator: $SIMULATOR_NAME"

    xcodebuild -project $PROJECT -scheme $SCHEME -destination "id=$SIMULATOR_ID" build
    if [ $? -ne 0 ]; then
        echo "Error: iOS build failed."
        exit 1
    fi

    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "*.app" | grep "Debug-iphonesimulator" | head -n 1)
    if [ -z "$APP_PATH" ]; then
        echo "Error: Could not find built app."
        exit 1
    fi

    BUNDLE_ID=$(defaults read "$APP_PATH/Info" CFBundleIdentifier)
    xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null
    xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
    xcrun simctl launch "$SIMULATOR_ID" $BUNDLE_ID

    cd ..
}

run_android() {
    echo "Building and running Android app..."
    cd android

    if [ ! -f "./gradlew" ]; then
        echo "Error: gradlew not found. Ensure you're in the correct Android project directory."
        exit 1
    fi

    ./gradlew installDebug
    if [ $? -ne 0 ]; then
        echo "Error: Android build failed."
        exit 1
    fi

    # Extract package name and main activity dynamically
    APP_PACKAGE=$(grep applicationId app/build.gradle | awk '{print $2}' | tr -d '"')
    MAIN_ACTIVITY=$(grep -r "android:name" app/src/main | grep -Eo 'android:name="\.[A-Za-z0-9.]+"' | head -n 1 | cut -d '"' -f 2 | sed 's/^\.//')
    
    if [ -z "$APP_PACKAGE" ] || [ -z "$MAIN_ACTIVITY" ]; then
        echo "Error: Unable to determine package or main activity."
        exit 1
    fi

    echo "Launching app on connected Android device/emulator..."
    adb shell am start -n "$APP_PACKAGE/.$MAIN_ACTIVITY"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to launch Android app."
        exit 1
    fi

    cd ..
}

case $PLATFORM in
    android)
        if [ "$CLEAN" == "clean" ]; then
            clean_android
        fi
        run_android
        ;;
    ios)
        if [ "$CLEAN" == "clean" ]; then
            clean_ios
        fi
        run_ios
        ;;
    both)
        if [ "$CLEAN" == "clean" ]; then
            clean_android
            clean_ios
        fi
        run_android
        run_ios
        ;;
    *)
        echo "Invalid platform. Use 'android', 'ios', or 'both'."
        print_usage
        exit 1
        ;;
esac

echo "Direct Native app should now be running. Check the device/simulator for results."
