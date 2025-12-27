/// Represents the various states during Smokerlyzer operations.
enum SmokerlyzerState {
  /// Successfully connected to device
  success,

  /// Connected but recovery is needed before breath test
  successNeedsRecovery,

  /// Device is zeroing its CO sensor
  zeroing,

  /// Connection or operation failed
  failure,

  /// Bluetooth became available
  bluetoothAvailable,

  /// Connected to peripheral
  connected,

  /// Disconnected from peripheral
  disconnected,

  /// Scan started
  scanStarted,

  /// Scan stopped
  scanStopped,

  /// Breath test in progress
  breathTestInProgress,

  /// Breath test completed with result
  breathTestResult,

  /// Recovery in progress
  recoveryInProgress,

  /// Recovery completed
  recoveryComplete,

  /// An error occurred
  error,

  /// Unknown state
  unknown,
}

/// Extension to parse state from string
extension SmokerlyzerStateExtension on SmokerlyzerState {
  static SmokerlyzerState fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SUCCESS':
        return SmokerlyzerState.success;
      case 'SUCCESS_NEEDS_RECOVERY':
        return SmokerlyzerState.successNeedsRecovery;
      case 'ZEROING':
        return SmokerlyzerState.zeroing;
      case 'FAILURE':
        return SmokerlyzerState.failure;
      case 'CONNECTION_BLUETOOTH_AVAILABLE':
        return SmokerlyzerState.bluetoothAvailable;
      case 'CONNECTION_CONNECTED':
      case 'CONNECTED':
        return SmokerlyzerState.connected;
      case 'CONNECTION_DISCONNECTED':
      case 'DISCONNECTED':
        return SmokerlyzerState.disconnected;
      case 'SCAN_STARTED':
        return SmokerlyzerState.scanStarted;
      case 'SCAN_STOPPED':
        return SmokerlyzerState.scanStopped;
      case 'BREATH_TEST_IN_PROGRESS':
        return SmokerlyzerState.breathTestInProgress;
      case 'BREATH_TEST_RESULT':
        return SmokerlyzerState.breathTestResult;
      case 'RECOVERY_IN_PROGRESS':
        return SmokerlyzerState.recoveryInProgress;
      case 'RECOVERY_COMPLETE':
        return SmokerlyzerState.recoveryComplete;
      case 'ERROR':
        return SmokerlyzerState.error;
      default:
        return SmokerlyzerState.unknown;
    }
  }
}

/// Represents a status update from the Smokerlyzer SDK.
class SmokerlyzerStatus {
  /// The current state
  final SmokerlyzerState state;

  /// Optional data associated with the state
  final Map<String, dynamic>? data;

  /// Optional error message
  final String? errorMessage;

  const SmokerlyzerStatus({required this.state, this.data, this.errorMessage});

  factory SmokerlyzerStatus.fromMap(Map<String, dynamic> map) {
    final typeString = map['type'] as String? ?? 'UNKNOWN';
    return SmokerlyzerStatus(
      state: SmokerlyzerStateExtension.fromString(typeString),
      data: map['data'] as Map<String, dynamic>?,
      errorMessage: map['error'] as String?,
    );
  }

  @override
  String toString() =>
      'SmokerlyzerStatus(state: $state, data: $data, error: $errorMessage)';
}
