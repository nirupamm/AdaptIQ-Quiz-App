import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/opencv_monitoring_service.dart';

class QuizProvider with ChangeNotifier {
  // Quiz state
  Map<String, dynamic>? currentQuestion;
  int? quizSessionId;
  String currentDifficulty = 'medium';
  int totalScore = 0;
  bool isLoading = false;
  String? error;
  List<Map<String, dynamic>> questionHistory = [];

  // OpenCV monitoring state
  OpenCVMonitoringService? _monitoringService;
  bool _isMonitoring = false;
  String? _monitoringStatus;
  String? _lastWarning;
  bool _isCheatingDetected = false;

  // Getters
  String? get currentQuestionText => currentQuestion?['question_text'];
  List<String>? get currentQuestionAnswers =>
      currentQuestion?['answers']?.cast<String>();
  int? get currentQuestionId => currentQuestion?['id'];
  int get totalQuestionsAnswered => questionHistory.length;
  int get correctAnswersCount =>
      questionHistory.where((q) => q['is_correct'] == true).length;
  double get accuracyPercentage => totalQuestionsAnswered > 0
      ? (correctAnswersCount / totalQuestionsAnswered) * 100
      : 0;

  // OpenCV getters
  bool get isMonitoring => _isMonitoring;
  String? get monitoringStatus => _monitoringStatus;
  String? get lastWarning => _lastWarning;
  bool get isCheatingDetected => _isCheatingDetected;
  int get warningCount => _monitoringService?.warningCount ?? 0;
  int get maxWarnings => _monitoringService?.maxWarnings ?? 3;
  OpenCVMonitoringService? get monitoringService => _monitoringService;

  Future<void> startQuiz(String category) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response = await ApiService.startQuiz(category);

      if (response != null) {
        currentQuestion = response['question'];
        quizSessionId = response['quiz_session_id'];
        currentDifficulty = response['current_difficulty'] ?? 'medium';
        totalScore = 0;
        questionHistory.clear();

        // Reset OpenCV state
        _isCheatingDetected = false;
        _lastWarning = null;

        // Start OpenCV monitoring
        await _startMonitoring();

        isLoading = false;
        notifyListeners();
      } else {
        error = 'Failed to start quiz';
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      error = 'Error starting quiz: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(String selectedAnswer) async {
    if (currentQuestion == null || quizSessionId == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final response = await ApiService.submitAnswer(
        quizSessionId!,
        currentQuestion!['id'],
        selectedAnswer,
      );

      if (response != null) {
        // Add to question history
        questionHistory.add({
          'question': currentQuestion!['question_text'],
          'selected_answer': selectedAnswer,
          'correct_answer': response['correct_answer'],
          'is_correct': response['is_correct'],
          'points_earned': response['points_earned'],
          'difficulty': currentDifficulty,
        });

        // Update score and difficulty
        totalScore = response['total_score'];
        currentDifficulty = response['current_difficulty'];

        // Check if quiz is complete
        if (response['next_question'] == null) {
          // Quiz completed - stop monitoring
          await stopMonitoring();
          currentQuestion = null;
        } else {
          currentQuestion = response['next_question'];
        }

        isLoading = false;
        notifyListeners();
      } else {
        error = 'Failed to submit answer';
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      error = 'Error submitting answer: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _startMonitoring() async {
    if (quizSessionId == null) return;

    try {
      _monitoringService = OpenCVMonitoringService();

      // Set up callbacks
      _monitoringService!.onWarning = (String warning) {
        _lastWarning = warning;
        _isCheatingDetected = false;
        notifyListeners();
        print('Quiz OpenCV Warning: $warning');
      };

      _monitoringService!.onForceQuit = () {
        _isCheatingDetected = true;
        notifyListeners();
        print('Quiz OpenCV: Force quit triggered');
      };

      _monitoringService!.onStatusUpdate = (String status) {
        _monitoringStatus = status;
        notifyListeners();
        print('Quiz OpenCV Status: $status');
      };

      // Start monitoring
      bool success = await _monitoringService!.startMonitoring(quizSessionId!);
      _isMonitoring = success;
      notifyListeners();

      if (success) {
        print('Quiz OpenCV: Monitoring started successfully');
      } else {
        print('Quiz OpenCV: Failed to start monitoring');
      }
    } catch (e) {
      print('Quiz OpenCV Error: $e');
      _isMonitoring = false;
      notifyListeners();
    }
  }

  Future<void> stopMonitoring() async {
    if (_monitoringService != null && quizSessionId != null) {
      await _monitoringService!.stopMonitoring(quizSessionId!);
      _isMonitoring = false;
      _monitoringStatus = null;
      notifyListeners();
      print('Quiz OpenCV: Monitoring stopped');
    }
  }

  void resetQuiz() {
    currentQuestion = null;
    quizSessionId = null;
    currentDifficulty = 'medium';
    totalScore = 0;
    isLoading = false;
    error = null;
    questionHistory.clear();

    // Reset OpenCV state
    _isCheatingDetected = false;
    _lastWarning = null;
    _monitoringStatus = null;

    // Stop monitoring
    stopMonitoring();

    notifyListeners();
  }

  @override
  void dispose() {
    stopMonitoring();
    _monitoringService?.dispose();
    super.dispose();
  }
}
