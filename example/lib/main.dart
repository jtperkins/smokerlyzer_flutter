import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smokerlyzer_flutter/smokerlyzer_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _smokerlyzer = SmokerlyzerFlutter.instance;
  StreamSubscription<SmokerlyzerStatus>? _statusSubscription;

  String _status = 'Not connected';
  String _lastResult = '-';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _setupStatusListener();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  void _setupStatusListener() {
    _statusSubscription = _smokerlyzer.statusStream.listen((status) {
      setState(() {
        _status =
            '${status.state.name}${status.data != null ? ': ${status.data}' : ''}';

        switch (status.state) {
          case SmokerlyzerState.success:
          case SmokerlyzerState.connected:
            _isConnected = true;
            break;
          case SmokerlyzerState.disconnected:
          case SmokerlyzerState.failure:
            _isConnected = false;
            break;
          case SmokerlyzerState.breathTestResult:
            _lastResult = status.data?['latest']?.toString() ?? '-';
            break;
          default:
            break;
        }
      });
    });
  }

  Future<void> _connect() async {
    setState(() => _status = 'Scanning...');
    final success = await _smokerlyzer.scanAndConnect();
    if (!success) {
      setState(() => _status = 'Failed to start scan');
    }
  }

  Future<void> _disconnect() async {
    await _smokerlyzer.disconnect();
  }

  Future<void> _startTest() async {
    setState(() => _status = 'Starting breath test...');
    try {
      final result = await _smokerlyzer.startBreathTest();
      setState(() {
        _lastResult = '${result.latestPpm} ppm';
        _status = 'Test complete';
      });
    } catch (e) {
      setState(() => _status = 'Test failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Smokerlyzer Flutter Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: $_status'),
                      const SizedBox(height: 8),
                      Text('Connected: ${_isConnected ? 'Yes' : 'No'}'),
                      const SizedBox(height: 8),
                      Text('Last CO Result: $_lastResult'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: !_isConnected ? _connect : null,
                child: const Text('Connect to Smokerlyzer'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isConnected ? _disconnect : null,
                child: const Text('Disconnect'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isConnected ? _startTest : null,
                child: const Text('Start CO Breath Test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
