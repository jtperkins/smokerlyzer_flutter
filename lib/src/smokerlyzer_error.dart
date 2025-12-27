/// Base exception class for Smokerlyzer SDK errors.
class SmokerlyzerException implements Exception {
  final String message;
  final String? code;

  const SmokerlyzerException(this.message, {this.code});

  @override
  String toString() =>
      'SmokerlyzerException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when Bluetooth is not available.
class SmokerlyzerBluetoothException extends SmokerlyzerException {
  const SmokerlyzerBluetoothException([
    super.message = 'Bluetooth is not available',
  ]) : super(code: 'BLUETOOTH_UNAVAILABLE');
}

/// Exception thrown when connection fails.
class SmokerlyzerConnectionException extends SmokerlyzerException {
  const SmokerlyzerConnectionException([super.message = 'Connection failed'])
    : super(code: 'CONNECTION_FAILED');
}

/// Exception thrown when connection times out.
class SmokerlyzerTimeoutException extends SmokerlyzerException {
  const SmokerlyzerTimeoutException([super.message = 'Connection timed out'])
    : super(code: 'TIMEOUT');
}

/// Exception thrown when not connected to a device.
class SmokerlyzerNotConnectedException extends SmokerlyzerException {
  const SmokerlyzerNotConnectedException([
    super.message = 'Not connected to a device',
  ]) : super(code: 'NOT_CONNECTED');
}

/// Exception thrown when breath test fails.
class SmokerlyzerBreathTestException extends SmokerlyzerException {
  const SmokerlyzerBreathTestException([super.message = 'Breath test failed'])
    : super(code: 'BREATH_TEST_FAILED');
}

/// Exception thrown when recovery is needed.
class SmokerlyzerRecoveryNeededException extends SmokerlyzerException {
  const SmokerlyzerRecoveryNeededException([
    super.message = 'Device recovery is needed',
  ]) : super(code: 'RECOVERY_NEEDED');
}
