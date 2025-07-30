import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class OpenCVMonitoringService {
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  int _warningCount = 0;
  final int _maxWarnings = 3;

  // Callbacks
  Function(String)? onWarning;
  Function()? onForceQuit;
  Function(String)? onStatusUpdate;

  // Monitoring parameters
  static const int _monitoringInterval =
      2000; // Check every 2 seconds (faster for testing)
  static const int _faceDetectionTimeout =
      2000; // 2 seconds without face = warning
  static const double _minFaceConfidence =
      0.7; // Minimum confidence for face detection

  // State tracking
  DateTime? _lastFaceDetected;
  bool _isFaceVisible = false;
  int _consecutiveNoFaceFrames = 0;
  static const int _maxNoFaceFrames =
      1; // 1 consecutive frame without face = warning (faster for testing)

  // Warning tracking
  String? _lastWarning;

  /// Initialize camera and request permissions
  Future<bool> initializeCamera() async {
    try {
      if (kIsWeb) {
        onStatusUpdate?.call('Web platform - using simulation mode');
        return true;
      }

      // For mobile platforms, you would implement actual camera initialization here
      onStatusUpdate?.call(
        'Mobile platform - camera initialization not implemented',
      );
      return false;
    } catch (e) {
      onStatusUpdate?.call('Camera initialization failed: $e');
      return false;
    }
  }

  /// Start monitoring for cheating detection
  Future<bool> startMonitoring(int quizSessionId) async {
    if (_isMonitoring) {
      onStatusUpdate?.call('Monitoring already active');
      return true;
    }

    try {
      // Start monitoring timer (simulates camera stream)
      _monitoringTimer = Timer.periodic(
        Duration(milliseconds: _monitoringInterval),
        (_) => _checkMonitoringStatus(quizSessionId),
      );

      _isMonitoring = true;
      _warningCount = 0;
      _lastFaceDetected = DateTime.now();
      _isFaceVisible = false;
      _consecutiveNoFaceFrames = 0;

      onStatusUpdate?.call('Monitoring started (simulation mode)');

      // Notify backend that monitoring has started
      await ApiService.startCameraMonitoring(quizSessionId);

      return true;
    } catch (e) {
      onStatusUpdate?.call('Failed to start monitoring: $e');
      return false;
    }
  }

  /// Stop monitoring
  Future<void> stopMonitoring(int quizSessionId) async {
    if (!_isMonitoring) return;

    try {
      _monitoringTimer?.cancel();
      _monitoringTimer = null;

      _isMonitoring = false;

      onStatusUpdate?.call('Monitoring stopped');

      // Notify backend that monitoring has stopped
      await ApiService.stopCameraMonitoring(quizSessionId);
    } catch (e) {
      onStatusUpdate?.call('Error stopping monitoring: $e');
    }
  }

  /// Simulate face detection (replace with actual OpenCV implementation)
  void _simulateFaceDetection() {
    // For testing: Simulate face detection based on time
    // This will make it easier to test the warning system
    int currentSecond = DateTime.now().second;

    // Face is "detected" for first 10 seconds of each 15-second cycle
    // Face is "not detected" for last 5 seconds (to trigger warnings)
    bool faceDetected = currentSecond < 10;

    if (faceDetected) {
      _lastFaceDetected = DateTime.now();
      _isFaceVisible = true;
      _consecutiveNoFaceFrames = 0;
      print('OpenCV: Face detected (second: $currentSecond)');
    } else {
      _consecutiveNoFaceFrames++;
      print(
        'OpenCV: No face detected (second: $currentSecond, frame: $_consecutiveNoFaceFrames)',
      );
      if (_consecutiveNoFaceFrames >= _maxNoFaceFrames) {
        _isFaceVisible = false;
        print('OpenCV: Face marked as not visible');
      }
    }
  }

  /// Check monitoring status and trigger warnings
  void _checkMonitoringStatus(int quizSessionId) {
    if (!_isMonitoring) return;

    // Simulate face detection
    _simulateFaceDetection();

    DateTime now = DateTime.now();

    // Debug logging
    print(
      'OpenCV Monitoring: Face visible: $_isFaceVisible, Consecutive no-face frames: $_consecutiveNoFaceFrames',
    );

    // Check if face has been missing for too long
    if (_lastFaceDetected != null) {
      int timeSinceLastFace = now.difference(_lastFaceDetected!).inMilliseconds;

      if (timeSinceLastFace > _faceDetectionTimeout && _isFaceVisible) {
        print(
          'OpenCV Warning: Face not detected for too long (${timeSinceLastFace}ms)',
        );
        _addWarning(
          'looking_away',
          'Face not detected for too long',
          quizSessionId,
        );
      }
    }

    // Check if face is currently not visible
    if (!_isFaceVisible) {
      print('OpenCV Warning: Face left the camera frame');
      _addWarning('left_frame', 'Face left the camera frame', quizSessionId);
    }
  }

  /// Add a warning and check if quiz should be terminated
  void _addWarning(String warningType, String reason, int quizSessionId) async {
    // Prevent duplicate warnings
    if (_lastWarning == reason) return;
    _lastWarning = reason;

    _warningCount++;

    String warningMessage = 'Warning $_warningCount/$_maxWarnings: $reason';
    print('OpenCV Warning Added: $warningMessage');
    onWarning?.call(warningMessage);

    // Report warning to backend
    try {
      await ApiService.reportMovementViolation(
        warningType,
        reason,
        quizSessionId,
      );
      print('Warning reported to backend successfully');
    } catch (e) {
      print('Failed to report warning: $e');
    }

    // Check if quiz should be force quit
    if (_warningCount >= _maxWarnings) {
      print('OpenCV: Max warnings reached, force quitting quiz');
      await _forceQuitQuiz(quizSessionId);
    }
  }

  /// Force quit the quiz due to cheating
  Future<void> _forceQuitQuiz(int quizSessionId) async {
    onStatusUpdate?.call('Quiz terminated due to multiple violations');
    onForceQuit?.call();

    // Stop monitoring
    await stopMonitoring(quizSessionId);
  }

  /// Get current warning count
  int get warningCount => _warningCount;

  /// Get max warnings allowed
  int get maxWarnings => _maxWarnings;

  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;

  /// Manually add a warning (for testing purposes)
  void addTestWarning(String reason, int quizSessionId) {
    _addWarning('test_warning', reason, quizSessionId);
  }

  /// Simulate face detection failure (for testing)
  void simulateFaceDetectionFailure() {
    _isFaceVisible = false;
    _consecutiveNoFaceFrames = _maxNoFaceFrames;
    print('OpenCV: Face detection failure simulated');
  }

  /// Dispose resources
  void dispose() {
    _monitoringTimer?.cancel();
  }
}
