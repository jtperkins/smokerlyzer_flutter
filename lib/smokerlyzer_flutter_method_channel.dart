import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'smokerlyzer_flutter_platform_interface.dart';

/// An implementation of [SmokerlyzerFlutterPlatform] that uses method channels.
class MethodChannelSmokerlyzerFlutter extends SmokerlyzerFlutterPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('smokerlyzer_flutter');

  @visibleForTesting
  final eventChannel = const EventChannel('smokerlyzer_flutter/events');

  StreamController<SmokerlyzerStatus>? _statusController;
  StreamSubscription? _eventSubscription;

  @override
  Stream<SmokerlyzerStatus> get statusStream {
    _statusController ??= StreamController<SmokerlyzerStatus>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _statusController!.stream;
  }

  void _startListening() {
    _eventSubscription = eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          final status = SmokerlyzerStatus.fromMap(
            Map<String, dynamic>.from(event),
          );
          _statusController?.add(status);
        }
      },
      onError: (dynamic error) {
        _statusController?.addError(error);
      },
    );
  }

  void _stopListening() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  @override
  Future<bool> scanAndConnect() async {
    final result = await methodChannel.invokeMethod<bool>('scanAndConnect');
    return result ?? false;
  }

  @override
  Future<void> disconnect() async {
    await methodChannel.invokeMethod<void>('disconnect');
  }

  @override
  Future<bool> getIsConnected() async {
    final result = await methodChannel.invokeMethod<bool>('getIsConnected');
    return result ?? false;
  }

  @override
  Future<BreathTestResult> startBreathTest() async {
    final result = await methodChannel.invokeMethod<Map>('startBreathTest');
    if (result == null) {
      throw const SmokerlyzerBreathTestException('No result returned');
    }
    return BreathTestResult.fromMap(Map<String, dynamic>.from(result));
  }

  @override
  Future<void> handleRecovery() async {
    await methodChannel.invokeMethod<void>('handleRecovery');
  }

  @override
  Future<BreathTestResult> startBreathTestNoRecovery() async {
    final result = await methodChannel.invokeMethod<Map>(
      'startBreathTestNoRecovery',
    );
    if (result == null) {
      throw const SmokerlyzerBreathTestException('No result returned');
    }
    return BreathTestResult.fromMap(Map<String, dynamic>.from(result));
  }
}
