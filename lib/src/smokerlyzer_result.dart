/// Represents the result of a breath test.
class BreathTestResult {
  /// The latest PPM reading
  final int latestPpm;

  /// The maximum PPM reading during the test
  final int maxPpm;

  /// The state of the breath test
  final BreathTestState state;

  const BreathTestResult({
    required this.latestPpm,
    required this.maxPpm,
    required this.state,
  });

  factory BreathTestResult.fromMap(Map<String, dynamic> map) {
    final data = map['data'] as Map<String, dynamic>? ?? map;
    return BreathTestResult(
      latestPpm: (data['latest'] as num?)?.toInt() ?? 0,
      maxPpm: (data['max'] as num?)?.toInt() ?? 0,
      state: BreathTestStateExtension.fromString(
        data['state'] as String? ?? '',
      ),
    );
  }

  @override
  String toString() =>
      'BreathTestResult(latest: $latestPpm ppm, max: $maxPpm ppm, state: $state)';
}

/// State of the breath test
enum BreathTestState {
  /// Test is initializing
  initializing,

  /// Test is in reading phase
  reading,

  /// Test finished successfully
  finished,

  /// Test was stopped
  stopped,

  /// Unknown state
  unknown,
}

extension BreathTestStateExtension on BreathTestState {
  static BreathTestState fromString(String value) {
    switch (value.toUpperCase()) {
      case 'INITIALIZING':
        return BreathTestState.initializing;
      case 'READING':
        return BreathTestState.reading;
      case 'FINISHED':
        return BreathTestState.finished;
      case 'STOPPED':
        return BreathTestState.stopped;
      default:
        return BreathTestState.unknown;
    }
  }
}
