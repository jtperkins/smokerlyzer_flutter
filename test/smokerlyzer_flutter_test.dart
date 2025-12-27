import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smokerlyzer_flutter/smokerlyzer_flutter.dart';
import 'package:smokerlyzer_flutter/smokerlyzer_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSmokerlyzerFlutterPlatform
    with MockPlatformInterfaceMixin
    implements SmokerlyzerFlutterPlatform {
  final StreamController<SmokerlyzerStatus> _statusController =
      StreamController<SmokerlyzerStatus>.broadcast();

  @override
  Stream<SmokerlyzerStatus> get statusStream => _statusController.stream;

  @override
  Future<bool> scanAndConnect() => Future.value(true);

  @override
  Future<void> disconnect() => Future.value();

  @override
  Future<bool> getIsConnected() => Future.value(false);

  @override
  Future<BreathTestResult> startBreathTest() => Future.value(
    const BreathTestResult(
      latestPpm: 5,
      maxPpm: 5,
      state: BreathTestState.finished,
    ),
  );

  @override
  Future<void> handleRecovery() => Future.value();

  @override
  Future<BreathTestResult> startBreathTestNoRecovery() => Future.value(
    const BreathTestResult(
      latestPpm: 5,
      maxPpm: 5,
      state: BreathTestState.finished,
    ),
  );

  void dispose() {
    _statusController.close();
  }
}

void main() {
  final SmokerlyzerFlutterPlatform initialPlatform =
      SmokerlyzerFlutterPlatform.instance;

  test('$MethodChannelSmokerlyzerFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSmokerlyzerFlutter>());
  });

  test('scanAndConnect returns true', () async {
    final fakePlatform = MockSmokerlyzerFlutterPlatform();
    SmokerlyzerFlutterPlatform.instance = fakePlatform;

    final result = await SmokerlyzerFlutter.instance.scanAndConnect();
    expect(result, true);

    fakePlatform.dispose();
  });
}
