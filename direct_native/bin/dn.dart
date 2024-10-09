import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

final String frameworkPath =
    path.dirname(path.dirname(Platform.script.toFilePath()));

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addCommand('create')
    ..addCommand('run')
    ..addOption('name', abbr: 'n', help: 'Name of the app')
    ..addOption('id', help: 'App ID (e.g., com.example.app)')
    ..addOption('platform', help: 'Platform to run (android or ios)');

  final results = parser.parse(arguments);

  if (results.command?.name == 'create') {
    final name = results['name'] as String?;
    final id = results['id'] as String?;

    if (name == null || id == null) {
      print('Please provide both name and id for the app.');
      print(
          'Usage: dart run bin/dn.dart create --name <app_name> --id <app_id>');
      exit(1);
    }

    createApp(name, id);
  } else if (results.command?.name == 'run') {
    final platform = results['platform'] as String?;

    if (platform == null) {
      print('Please provide a platform (android or ios) to run the app.');
      print('Usage: dart run bin/dn.dart run --platform <android|ios>');
      exit(1);
    }

    runApp(platform);
  } else {
    print('Usage: dart run bin/dn.dart create --name <app_name> --id <app_id>');
    print('       dart run bin/dn.dart run --platform <android|ios>');
  }
}

void createApp(String name, String id) {
  final directory = Directory(name);
  if (directory.existsSync()) {
    print('Directory already exists. Please choose a different name.');
    exit(1);
  }

  directory.createSync();

  createDartProject(directory.path, name, id);
  createAndroidProject(directory.path, name, id);
  createIOSProject(directory.path, name, id);

  print('App "$name" created successfully!');
}

void createDartProject(String basePath, String name, String id) {
  final libDir = Directory(path.join(basePath, 'lib'));
  libDir.createSync();

  final mainFile = File(path.join(libDir.path, 'main.dart'));
  mainFile.writeAsStringSync('''
import 'package:direct_native/direct_native.dart';

void main() {
  final app = DNApp(
    rootView: Column(
      children: [
        Text('Hello, $name!', style: {'fontSize': 24, 'fontWeight': 'bold'}),
        Button(
          label: 'Click me',
          onPressed: () {
            print('Button clicked!');
          },
          style: {'backgroundColor': '#007AFF', 'color': '#FFFFFF'},
        ),
      ],
      style: {'padding': 16},
    ),
  );

  app.run();
}
''');

  final pubspecFile = File(path.join(basePath, 'pubspec.yaml'));
  pubspecFile.writeAsStringSync('''
name: $name
description: A new Direct Native project.
version: 1.0.0+1

environment:
  sdk: '>=2.12.0 <3.0.0'

dependencies:
  direct_native:
    path: ${path.relative(frameworkPath, from: basePath)}

dev_dependencies:
  lints: ^2.0.0
  test: ^1.16.0
''');
}

void createAndroidProject(String basePath, String name, String id) {
  final androidDir = Directory(path.join(basePath, 'android'));
  final templateAndroidDir = Directory(path.join(frameworkPath, 'android'));

  if (!templateAndroidDir.existsSync()) {
    print(
        'Error: Android template directory not found at ${templateAndroidDir.path}');
    exit(1);
  }

  copyDirectory(templateAndroidDir.path, androidDir.path);
  updateAndroidFiles(androidDir.path, name, id);
}

void updateAndroidFiles(String androidPath, String name, String id) {
  // Update build.gradle
  final buildGradlePath = path.join(androidPath, 'app', 'build.gradle');
  if (File(buildGradlePath).existsSync()) {
    var buildGradleContent = File(buildGradlePath).readAsStringSync();
    buildGradleContent =
        buildGradleContent.replaceAll('com.example.directnative', id);
    buildGradleContent = buildGradleContent.replaceAll('DirectNative', name);
    File(buildGradlePath).writeAsStringSync(buildGradleContent);
  } else {
    print('Warning: build.gradle not found at $buildGradlePath');
  }

  // Update AndroidManifest.xml
  final manifestPath =
      path.join(androidPath, 'app', 'src', 'main', 'AndroidManifest.xml');
  if (File(manifestPath).existsSync()) {
    var manifestContent = File(manifestPath).readAsStringSync();
    manifestContent =
        manifestContent.replaceAll('com.example.directnative', id);
    manifestContent = manifestContent.replaceAll('DirectNative', name);
    File(manifestPath).writeAsStringSync(manifestContent);
  } else {
    print('Warning: AndroidManifest.xml not found at $manifestPath');
  }

  // Update and move Kotlin files
  final oldPackagePath = path.join(androidPath, 'app', 'src', 'main', 'kotlin',
      'com', 'example', 'directnative');
  final newPackagePath = path.join(
      androidPath, 'app', 'src', 'main', 'kotlin', id.replaceAll('.', '/'));

  if (Directory(oldPackagePath).existsSync()) {
    Directory(newPackagePath).createSync(recursive: true);
    for (var file in Directory(oldPackagePath).listSync()) {
      if (file is File) {
        var content = file.readAsStringSync();
        content = content.replaceAll(
            'package com.example.directnative', 'package $id');
        content =
            content.replaceAll('import com.example.directnative', 'import $id');
        File(path.join(newPackagePath, path.basename(file.path)))
            .writeAsStringSync(content);
      }
    }
    Directory(path.dirname(path.dirname(oldPackagePath)))
        .deleteSync(recursive: true);
  } else {
    print('Warning: Kotlin source directory not found at $oldPackagePath');
  }
}

void createIOSProject(String basePath, String name, String id) {
  final iosDir = Directory(path.join(basePath, 'ios'));
  final templateIOSDir = Directory(path.join(frameworkPath, 'ios'));

  if (!templateIOSDir.existsSync()) {
    print('Error: iOS template directory not found at ${templateIOSDir.path}');
    exit(1);
  }

  copyDirectory(templateIOSDir.path, iosDir.path);
  updateIOSFiles(iosDir.path, name, id);
}

void updateIOSFiles(String iosPath, String name, String id) {
  // Rename DirectNativeIOS directory to the new app name
  final oldAppDir = Directory(path.join(iosPath, 'DirectNativeIOS'));
  final newAppDir = Directory(path.join(iosPath, name));
  if (oldAppDir.existsSync()) {
    oldAppDir.renameSync(newAppDir.path);
  } else {
    print('Warning: DirectNativeIOS directory not found at ${oldAppDir.path}');
  }

  // Rename DirectNativeIOS.xcodeproj to the new app name
  final oldProjectDir =
      Directory(path.join(iosPath, 'DirectNativeIOS.xcodeproj'));
  final newProjectDir = Directory(path.join(iosPath, '$name.xcodeproj'));
  if (oldProjectDir.existsSync()) {
    oldProjectDir.renameSync(newProjectDir.path);
  } else {
    print(
        'Warning: DirectNativeIOS.xcodeproj directory not found at ${oldProjectDir.path}');
  }

  // Update Info.plist
  final infoPlistPath = path.join(newAppDir.path, 'Info.plist');
  if (File(infoPlistPath).existsSync()) {
    var infoPlistContent = File(infoPlistPath).readAsStringSync();
    infoPlistContent =
        infoPlistContent.replaceAll('com.example.DirectNativeIOS', id);
    infoPlistContent = infoPlistContent.replaceAll('DirectNativeIOS', name);
    File(infoPlistPath).writeAsStringSync(infoPlistContent);
  } else {
    print('Warning: Info.plist not found at $infoPlistPath');
  }

  // Update project.pbxproj
  final projectPath = path.join(newProjectDir.path, 'project.pbxproj');
  if (File(projectPath).existsSync()) {
    var projectContent = File(projectPath).readAsStringSync();
    projectContent =
        projectContent.replaceAll('com.example.DirectNativeIOS', id);
    projectContent = projectContent.replaceAll('DirectNativeIOS', name);
    File(projectPath).writeAsStringSync(projectContent);
  } else {
    print('Warning: project.pbxproj not found at $projectPath');
  }

  // Update and rename DirectNativeIOSApp.swift
  final oldAppSwiftPath = path.join(newAppDir.path, 'DirectNativeIOSApp.swift');
  final newAppSwiftPath = path.join(newAppDir.path, '${name}App.swift');
  if (File(oldAppSwiftPath).existsSync()) {
    var appSwiftContent = File(oldAppSwiftPath).readAsStringSync();
    appSwiftContent = appSwiftContent.replaceAll('DirectNativeIOS', name);
    File(newAppSwiftPath).writeAsStringSync(appSwiftContent);
    File(oldAppSwiftPath).deleteSync();
  } else {
    print('Warning: DirectNativeIOSApp.swift not found at $oldAppSwiftPath');
  }

  // Update ContentView.swift
  final contentViewPath = path.join(newAppDir.path, 'ContentView.swift');
  if (File(contentViewPath).existsSync()) {
    var contentViewContent = File(contentViewPath).readAsStringSync();
    contentViewContent = contentViewContent.replaceAll('DirectNativeIOS', name);
    File(contentViewPath).writeAsStringSync(contentViewContent);
  } else {
    print('Warning: ContentView.swift not found at $contentViewPath');
  }
}

void copyDirectory(String source, String destination) {
  Directory(source).listSync(recursive: true).forEach((entity) {
    if (entity is File) {
      final destPath =
          path.join(destination, path.relative(entity.path, from: source));
      File(destPath).createSync(recursive: true);
      entity.copySync(destPath);
    } else if (entity is Directory) {
      final destPath =
          path.join(destination, path.relative(entity.path, from: source));
      Directory(destPath).createSync(recursive: true);
    }
  });
}

void runApp(String platform) {
  if (platform == 'android') {
    runAndroidApp();
  } else if (platform == 'ios') {
    runIOSApp();
  } else {
    print('Invalid platform. Use "android" or "ios".');
  }
}

void runAndroidApp() {
  final result = Process.runSync('adb', ['devices']);
  final devices = result.stdout
      .toString()
      .split('\n')
      .where((line) => line.contains('\t'))
      .map((line) => line.split('\t')[0])
      .toList();

  if (devices.isEmpty) {
    print(
        'No Android devices found. Please connect a device or start an emulator.');
    return;
  }

  print('Available Android devices:');
  for (var i = 0; i < devices.length; i++) {
    print('${i + 1}. ${devices[i]}');
  }

  stdout.write('Select a device (1-${devices.length}): ');
  final selection = int.parse(stdin.readLineSync()!) - 1;

  if (selection < 0 || selection >= devices.length) {
    print('Invalid selection.');
    return;
  }

  final selectedDevice = devices[selection];
  print('Running app on $selectedDevice...');

  final gradlew = Platform.isWindows ? 'gradlew.bat' : './gradlew';
  final result2 =
      Process.runSync(gradlew, ['assembleDebug'], workingDirectory: 'android');
  if (result2.exitCode != 0) {
    print('Error building Android app:');
    print(result2.stderr);
    return;
  }

  final apkPath = 'android/app/build/outputs/apk/debug/app-debug.apk';
  if (!File(apkPath).existsSync()) {
    print('Error: APK not found at $apkPath');
    return;
  }

  Process.runSync('adb', ['-s', selectedDevice, 'install', '-r', apkPath]);

  final manifestFile = File('android/app/src/main/AndroidManifest.xml');
  if (!manifestFile.existsSync()) {
    print('Error: AndroidManifest.xml not found');
    return;
  }
  final manifestContent = manifestFile.readAsStringSync();
  final packageName =
      RegExp(r'package="([^"]*)"').firstMatch(manifestContent)?.group(1);
  if (packageName == null) {
    print('Error: Could not find package name in AndroidManifest.xml');
    return;
  }

  Process.runSync('adb', [
    '-s',
    selectedDevice,
    'shell',
    'am',
    'start',
    '-n',
    '$packageName/.MainActivity'
  ]);
}

void runIOSApp() {
  final result = Process.runSync(
      'xcrun', ['simctl', 'list', 'devices', 'available', '-j']);
  final simulators =
      (jsonDecode(result.stdout)['devices'] as Map<String, dynamic>)
          .values
          .expand((deviceList) => deviceList)
          .toList();

  if (simulators.isEmpty) {
    print('No iOS simulators found. Please create a simulator in Xcode.');
    return;
  }

  print('Available iOS simulators:');
  for (var i = 0; i < simulators.length; i++) {
    print('${i + 1}. ${simulators[i]['name']} (${simulators[i]['udid']})');
  }

  stdout.write('Select a simulator (1-${simulators.length}): ');
  final selection = int.parse(stdin.readLineSync()!) - 1;

  if (selection < 0 || selection >= simulators.length) {
    print('Invalid selection.');
    return;
  }

  final selectedSimulator = simulators[selection]['udid'];
  print('Running app on ${simulators[selection]['name']}...');

  final appName = path.basename(Directory.current.path);
  final workspacePath = 'ios/$appName.xcworkspace';
  final schemeName = appName;

  if (!Directory(workspacePath).existsSync()) {
    print('Error: Xcode workspace not found at $workspacePath');
    return;
  }

  print('Building iOS app...');
  final buildResult = Process.runSync('xcodebuild', [
    '-workspace',
    workspacePath,
    '-scheme',
    schemeName,
    '-destination',
    'id=$selectedSimulator',
    'build'
  ]);

  if (buildResult.exitCode != 0) {
    print('Error building iOS app:');
    print(buildResult.stderr);
    return;
  }

  print('Installing app on simulator...');
  final appPath = 'ios/build/Build/Products/Debug-iphonesimulator/$appName.app';
  if (!Directory(appPath).existsSync()) {
    print('Error: Built app not found at $appPath');
    return;
  }

  final installResult = Process.runSync(
      'xcrun', ['simctl', 'install', selectedSimulator, appPath]);
  if (installResult.exitCode != 0) {
    print('Error installing app on simulator:');
    print(installResult.stderr);
    return;
  }

  print('Launching app...');
  final infoPlistPath = 'ios/$appName/Info.plist';
  if (!File(infoPlistPath).existsSync()) {
    print('Error: Info.plist not found at $infoPlistPath');
    return;
  }

  final infoPlistContent = File(infoPlistPath).readAsStringSync();
  final bundleIdMatch =
      RegExp(r'<key>CFBundleIdentifier</key>\s*<string>(.*?)</string>')
          .firstMatch(infoPlistContent);
  final bundleId = bundleIdMatch?.group(1);

  if (bundleId == null) {
    print('Error: Could not find bundle identifier in Info.plist');
    return;
  }

  final launchResult = Process.runSync(
      'xcrun', ['simctl', 'launch', selectedSimulator, bundleId]);
  if (launchResult.exitCode != 0) {
    print('Error launching app on simulator:');
    print(launchResult.stderr);
    return;
  }

  print('App launched successfully on iOS simulator.');
}
