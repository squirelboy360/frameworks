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

# Ensure we're in the correct directory
if [ ! -d "example/todo_app" ]; then
    echo "Error: example/todo_app directory not found."
    exit 1
fi

# Change to the example directory
cd example/todo_app

clean_ios() {
    echo "Cleaning iOS build..."
    cd ios
    xcodebuild clean -project DirectNativeIOS.xcodeproj -scheme DirectNativeIOS
    cd ..
}

clean_android() {
    echo "Cleaning Android build..."
    cd android
    ./gradlew clean
    cd ..
}

# Compile the Dart code
echo "Compiling Dart code..."
dart compile exe lib/main.dart -o todo_app
if [ $? -ne 0 ]; then
    echo "Error: Dart compilation failed. Check the output above for details."
    exit 1
fi

run_android() {
    echo "Running example on Android..."
    cd android
    if [ ! -f "./gradlew" ]; then
        echo "Error: gradlew not found. Ensure you're in the correct Android project directory."
        exit 1
    fi
    
    echo "Building Android app..."
    ./gradlew assembleDebug
    if [ $? -ne 0 ]; then
        echo "Error: Android build failed. Check the output above for details."
        exit 1
    fi
    
    echo "Installing app on device/emulator..."
    ./gradlew installDebug
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install the app. Ensure an Android device is connected or an emulator is running."
        exit 1
    fi
    
    echo "Launching app..."
    adb shell am start -n "com.example.direct_native_todo_app/.MainActivity"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to launch the app. Ensure the package name and activity name are correct."
        exit 1
    fi
    
    cd ..
}

run_ios() {
    echo "Building and running example on iOS..."
    cd ios
    
    PROJECT="DirectNativeIOS.xcodeproj"
    if [ ! -d "$PROJECT" ]; then
        echo "Error: $PROJECT not found in example/todo_app/ios directory."
        exit 1
    fi

    SCHEME="DirectNativeIOS"

    # Path to the Info.plist file
    INFO_PLIST_PATH="DirectNativeIOS/Info.plist"

    # Check if the Info.plist file exists
    if [ ! -f "$INFO_PLIST_PATH" ]; then
        echo "Error: Info.plist file not found at $INFO_PLIST_PATH."
        exit 1
    fi

    echo "Updating Info.plist located at: $INFO_PLIST_PATH"
    
    # Update Info.plist with correct version and identifier
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1" "$INFO_PLIST_PATH"
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.0" "$INFO_PLIST_PATH"
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.example.DirectNativeIOS" "$INFO_PLIST_PATH"

    echo "Info.plist updated successfully."

    # List available simulators and let user choose
    echo "Available iOS Simulators:"
    xcrun simctl list devices | grep -v '^--' | grep -v '^ --' | grep -v '^$' | nl
    read -p "Enter the number of the simulator you want to use: " SIMULATOR_NUMBER
    SIMULATOR_ID=$(xcrun simctl list devices | grep -v '^--' | grep -v '^ --' | grep -v '^$' | sed -n "${SIMULATOR_NUMBER}p" | awk -F'[()]' '{print $2}')
    SIMULATOR_NAME=$(xcrun simctl list devices | grep -v '^--' | grep -v '^ --' | grep -v '^$' | sed -n "${SIMULATOR_NUMBER}p" | awk -F'[()]' '{print $1}' | xargs)

    echo "Building for simulator: $SIMULATOR_NAME"
    
    # Clean the build folder before building
    xcodebuild clean -project "$PROJECT" -scheme "$SCHEME" -destination "id=$SIMULATOR_ID"

    # Build the project
    xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination "id=$SIMULATOR_ID" build

    # Check if the build was successful
    if [ $? -ne 0 ]; then
        echo "Error: Build failed. Please check the Xcode project for issues."
        exit 1
    fi

    # Get the app path
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "DirectNativeIOS.app" | grep "Debug-iphonesimulator" | head -n 1)
    if [ -z "$APP_PATH" ]; then
        echo "Error: Could not find built app."
        exit 1
    fi

    echo "Found app at: $APP_PATH"

    # Launch the app in the simulator
    xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null
    xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install the app on the simulator."
        echo "Contents of Info.plist in the built app:"
        plutil -p "$APP_PATH/Info.plist"
        exit 1
    fi

    xcrun simctl launch "$SIMULATOR_ID" com.example.DirectNativeIOS
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

echo "Example todo app should now be running. Check the device/simulator for results."