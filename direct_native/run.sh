#!/bin/bash

set -e

# Compile Dart code
echo "Compiling Dart code..."
dart compile exe bin/dn.dart -o dn

# Build Android native library
echo "Building Android native library..."
cd android
./gradlew assembleDebug
cd ..

# Build iOS native library
echo "Building iOS native library..."
cd ios
xcodebuild -project DirectNative.xcodeproj -scheme DirectNative -configuration Debug -sdk iphoneos
cd ..

echo "Build completed successfully!"