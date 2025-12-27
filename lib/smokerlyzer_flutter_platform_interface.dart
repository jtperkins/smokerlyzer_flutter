import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'smokerlyzer_flutter_method_channel.dart';
import 'src/smokerlyzer_state.dart';
import 'src/smokerlyzer_result.dart';

export 'src/smokerlyzer_state.dart';
export 'src/smokerlyzer_result.dart';
export 'src/smokerlyzer_error.dart';

abstract class SmokerlyzerFlutterPlatform extends PlatformInterface {
  SmokerlyzerFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmokerlyzerFlutterPlatform _instance =
      MethodChannelSmokerlyzerFlutter();

  static SmokerlyzerFlutterPlatform get instance => _instance;

  static set instance(SmokerlyzerFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Stream of status updates from the Smokerlyzer SDK
  Stream<SmokerlyzerStatus> get statusStream;

  /// Scan for and connect to the nearest Smokerlyzer device
  Future<bool> scanAndConnect();

  /// Disconnect from the current device
  Future<void> disconnect();

  /// Check if connected to a device
  Future<bool> getIsConnected();

  /// Start a breath test (includes recovery if needed)
  Future<BreathTestResult> startBreathTest();

  /// Handle device recovery
  Future<void> handleRecovery();

  /// Start breath test without recovery phase
  Future<BreathTestResult> startBreathTestNoRecovery();
}
