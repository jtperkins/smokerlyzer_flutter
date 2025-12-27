import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smokerlyzer_flutter/smokerlyzer_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSmokerlyzerFlutter platform = MethodChannelSmokerlyzerFlutter();
  const MethodChannel channel = MethodChannel('smokerlyzer_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'scanAndConnect':
              return true;
            case 'getIsConnected':
              return false;
            case 'disconnect':
            case 'handleRecovery':
              return null;
            case 'startBreathTest':
            case 'startBreathTestNoRecovery':
              return {
                'status': 'success',
                'data': {'latest': 5, 'max': 5, 'state': 'FINISHED'},
              };
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('scanAndConnect returns true', () async {
    expect(await platform.scanAndConnect(), true);
  });

  test('getIsConnected returns false', () async {
    expect(await platform.getIsConnected(), false);
  });

  test('disconnect completes without error', () async {
    await expectLater(platform.disconnect(), completes);
  });
}
