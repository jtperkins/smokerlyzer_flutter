# smokerlyzer_flutter

A Flutter plugin for [Bedfont Smokerlyzer](https://www.bedfont.com/) CO breathalyzers. This plugin wraps the official Bedfont SDK for both iOS and Android.

## Features

- Connect to Smokerlyzer Bluetooth devices
- Take CO (Carbon Monoxide) breath tests
- Get real-time status updates via stream
- Handle device recovery when needed

## Getting Started

### 1. Install the Plugin

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smokerlyzer_flutter:
    git:
      url: https://github.com/jtperkins/smokerlyzer_flutter.git
```

### 2. Platform Setup

#### Android

Add the following permissions to your `AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
</manifest>
```

#### iOS

Add to your `Info.plist`:

```xml
<dict>
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app needs Bluetooth to connect to the Smokerlyzer</string>
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>This app needs Bluetooth to connect to the Smokerlyzer</string>
</dict>
```

## Usage

### Connect to Device

```dart
import 'package:smokerlyzer_flutter/smokerlyzer_flutter.dart';

final smokerlyzer = SmokerlyzerFlutter.instance;

// Start scanning and connect
final success = await smokerlyzer.scanAndConnect();
```

### Listen to Status Updates

```dart
smokerlyzer.statusStream.listen((status) {
  switch (status.state) {
    case SmokerlyzerState.success:
      print('Connected successfully');
      break;
    case SmokerlyzerState.successNeedsRecovery:
      print('Connected - recovery needed before test');
      break;
    case SmokerlyzerState.zeroing:
      print('Device is zeroing sensor...');
      break;
    case SmokerlyzerState.failure:
      print('Connection failed: ${status.errorMessage}');
      break;
    default:
      break;
  }
});
```

### Take a Breath Test

```dart
// Start breath test (includes recovery if needed)
final result = await smokerlyzer.startBreathTest();
print('CO Level: ${result.latestPpm} ppm');

// Or start without recovery phase
final result = await smokerlyzer.startBreathTestNoRecovery();
```

### Handle Recovery Manually

```dart
// If connected with successNeedsRecovery status
await smokerlyzer.handleRecovery();
```

### Disconnect

```dart
await smokerlyzer.disconnect();
```

## API Reference

### SmokerlyzerFlutter

| Method | Description |
|--------|-------------|
| `scanAndConnect()` | Scan for and connect to nearest Smokerlyzer |
| `disconnect()` | Disconnect from current device |
| `getIsConnected()` | Check if connected |
| `startBreathTest()` | Start CO breath test (with recovery) |
| `startBreathTestNoRecovery()` | Start test without recovery phase |
| `handleRecovery()` | Handle device recovery manually |

### SmokerlyzerState

| State | Description |
|-------|-------------|
| `success` | Connected successfully |
| `successNeedsRecovery` | Connected, but recovery needed |
| `zeroing` | Device is zeroing CO sensor |
| `failure` | Connection or operation failed |
| `connected` | Bluetooth connected |
| `disconnected` | Bluetooth disconnected |

### BreathTestResult

| Property | Type | Description |
|----------|------|-------------|
| `latestPpm` | int | Latest CO reading in PPM |
| `maxPpm` | int | Maximum CO reading during test |
| `state` | BreathTestState | Test state (finished, stopped, etc.) |

## Updating the Native SDKs

This plugin vendors the official Bedfont SDKs. To update:

### iOS SDK Update

1. Get the latest SDK from Bedfont
2. Replace `ios/Frameworks/SmokerlyzerSDK.xcframework`
3. Update Swift bridge if needed

### Android SDK Update

1. Get the latest AAR from Bedfont
2. Update `android/maven-repo/` with new files
3. Update version in `android/build.gradle`
4. Update Kotlin bridge if needed

## License

MIT License - see [LICENSE](LICENSE) file.

## Credits

This plugin wraps the official Bedfont Smokerlyzer SDK.
