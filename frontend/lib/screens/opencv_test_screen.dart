import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class OpenCVTestScreen extends StatefulWidget {
  @override
  _OpenCVTestScreenState createState() => _OpenCVTestScreenState();
}

class _OpenCVTestScreenState extends State<OpenCVTestScreen> {
  bool _isInitialized = false;
  bool _isMonitoring = false;
  Timer? _monitoringTimer;

  // Face detection state
  bool _isFaceDetected = false;
  int _consecutiveNoFaceFrames = 0;
  int _warningCount = 0;
  final int _maxWarnings = 3;

  // Test results
  List<String> _logMessages = [];
  String _currentStatus = 'Not started';

  @override
  void initState() {
    super.initState();
    _addLog('OpenCV Test Screen initialized');
    _addLog('Platform: ${kIsWeb ? "Web" : "Mobile"}');
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logMessages.add(
        '${DateTime.now().toString().substring(11, 19)}: $message',
      );
      if (_logMessages.length > 20) {
        _logMessages.removeAt(0);
      }
    });
    print('OpenCV Test: $message');
  }

  Future<void> _initializeCamera() async {
    _addLog('Starting camera initialization...');
    _setStatus('Initializing camera...');

    try {
      // Simulate camera initialization delay
      await Future.delayed(Duration(seconds: 2));

      if (kIsWeb) {
        _addLog('🌐 Web platform detected - using simulation mode');
        _addLog('✅ Camera simulation initialized successfully');
        _setStatus('Camera ready (simulation)');
      } else {
        _addLog('📱 Mobile platform detected');
        _addLog('✅ Camera initialized successfully');
        _setStatus('Camera ready');
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      _addLog('❌ Camera initialization failed: $e');
      _setStatus('Camera initialization failed');
    }
  }

  void _setStatus(String status) {
    setState(() {
      _currentStatus = status;
    });
  }

  Future<void> _startMonitoring() async {
    if (!_isInitialized) {
      _addLog('❌ Camera not initialized');
      return;
    }

    if (_isMonitoring) {
      _addLog('⚠️ Monitoring already active');
      return;
    }

    try {
      _addLog('🚀 Starting face detection monitoring...');
      _setStatus('Monitoring active');

      // Start monitoring timer (simulates camera stream)
      _monitoringTimer = Timer.periodic(
        Duration(seconds: 2),
        (_) => _simulateFaceDetection(),
      );

      setState(() {
        _isMonitoring = true;
        _warningCount = 0;
        _consecutiveNoFaceFrames = 0;
      });

      _addLog('✅ Monitoring started successfully');
      if (kIsWeb) {
        _addLog('🌐 Running in web simulation mode');
      }
    } catch (e) {
      _addLog('❌ Failed to start monitoring: $e');
      _setStatus('Monitoring failed');
    }
  }

  Future<void> _stopMonitoring() async {
    if (!_isMonitoring) return;

    try {
      _monitoringTimer?.cancel();
      _monitoringTimer = null;

      setState(() {
        _isMonitoring = false;
      });

      _addLog('🛑 Monitoring stopped');
      _setStatus('Monitoring stopped');
    } catch (e) {
      _addLog('❌ Error stopping monitoring: $e');
    }
  }

  void _simulateFaceDetection() {
    if (!_isMonitoring) return;

    int currentSecond = DateTime.now().second;

    // Face detected for first 20 seconds, not detected for last 5 seconds
    // This creates a cycle every 25 seconds
    bool faceDetected = currentSecond < 20;

    if (faceDetected) {
      if (!_isFaceDetected) {
        _addLog('👤 Face detected (second: $currentSecond)');
      }
      _isFaceDetected = true;
      _consecutiveNoFaceFrames = 0;
    } else {
      _consecutiveNoFaceFrames++;
      if (_consecutiveNoFaceFrames == 1) {
        _addLog('❌ No face detected (second: $currentSecond)');
      }
      _isFaceDetected = false;

      // Check for warning after 2 consecutive frames without face
      if (_consecutiveNoFaceFrames >= 2) {
        _addWarning('Face left camera frame');
      }
    }
  }

  void _addWarning(String reason) {
    _warningCount++;
    String warningMessage = '🚨 Warning $_warningCount/$_maxWarnings: $reason';
    _addLog(warningMessage);

    if (_warningCount >= _maxWarnings) {
      _addLog('💥 MAX WARNINGS REACHED - Test terminated');
      _setStatus('Test terminated - Max warnings');
      _stopMonitoring();
    }
  }

  void _addTestWarning() {
    _addWarning('Manual test warning');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenCV Face Detection Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Status: $_currentStatus',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isMonitoring ? Colors.green : Colors.orange,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatusItem('Camera', _isInitialized ? '✅' : '❌'),
                        _buildStatusItem(
                          'Monitoring',
                          _isMonitoring ? '✅' : '❌',
                        ),
                        _buildStatusItem('Face', _isFaceDetected ? '👤' : '❌'),
                        _buildStatusItem(
                          'Warnings',
                          '$_warningCount/$_maxWarnings',
                        ),
                      ],
                    ),
                    if (kIsWeb) ...[
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '🌐 Web Simulation Mode',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isInitialized ? null : _initializeCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Initialize Camera'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isInitialized && !_isMonitoring
                        ? _startMonitoring
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Start Monitoring'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isMonitoring ? _stopMonitoring : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Stop Monitoring'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isMonitoring ? _addTestWarning : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Test Warning'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Instructions Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Test Instructions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '1. Click "Initialize Camera" to start\n'
                      '2. Click "Start Monitoring" to begin face detection\n'
                      '3. Watch for face detection changes every 2 seconds\n'
                      '4. Face is "detected" for first 20 seconds of each 25-second cycle\n'
                      '5. Face is "not detected" for last 5 seconds (triggers warnings)\n'
                      '6. Or click "Test Warning" to manually trigger warnings\n'
                      '7. After 3 warnings, test terminates',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Log Messages
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Log:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: _logMessages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  _logMessages[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
