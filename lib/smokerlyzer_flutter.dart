import 'smokerlyzer_flutter_platform_interface.dart';

export 'smokerlyzer_flutter_platform_interface.dart';

/// Main class for interacting with the Smokerlyzer SDK.
///
/// Use [SmokerlyzerFlutter.instance] to access the singleton.
class SmokerlyzerFlutter {
  SmokerlyzerFlutter._();

  static final SmokerlyzerFlutter _instance = SmokerlyzerFlutter._();

  /// Singleton instance of [SmokerlyzerFlutter].
  static SmokerlyzerFlutter get instance => _instance;

  /// Stream of status updates from the Smokerlyzer SDK.
  Stream<SmokerlyzerStatus> get statusStream =>
      SmokerlyzerFlutterPlatform.instance.statusStream;

  /// Scan for and connect to the nearest Smokerlyzer device.
  ///
  /// Returns `true` if scanning started successfully.
  Future<bool> scanAndConnect() {
    return SmokerlyzerFlutterPlatform.instance.scanAndConnect();
  }

  /// Disconnect from the current device.
  Future<void> disconnect() {
    return SmokerlyzerFlutterPlatform.instance.disconnect();
  }

  /// Check if currently connected to a device.
  Future<bool> getIsConnected() {
    return SmokerlyzerFlutterPlatform.instance.getIsConnected();
  }

  /// Start a breath test.
  ///
  /// This includes the recovery phase if needed. The test involves:
  /// 1. Recovery phase (if needed) - up to 30s
  /// 2. Initialization phase - 14s
  /// 3. Reading phase - 6s to 16s
  ///
  /// Returns a [BreathTestResult] with the CO PPM reading.
  Future<BreathTestResult> startBreathTest() {
    return SmokerlyzerFlutterPlatform.instance.startBreathTest();
  }

  /// Handle device recovery manually.
  ///
  /// Call this if the device connected with `successNeedsRecovery` status.
  Future<void> handleRecovery() {
    return SmokerlyzerFlutterPlatform.instance.handleRecovery();
  }

  /// Start a breath test without the recovery phase.
  ///
  /// Use with caution - only if you're sure recovery isn't needed.
  Future<BreathTestResult> startBreathTestNoRecovery() {
    return SmokerlyzerFlutterPlatform.instance.startBreathTestNoRecovery();
  }
}
