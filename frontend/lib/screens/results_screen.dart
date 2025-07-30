import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';

class ResultsScreen extends StatelessWidget {
  final String category;
  final int finalScore;
  final int totalQuestions;
  final List<Map<String, dynamic>> questionHistory;

  ResultsScreen({
    required this.category,
    required this.finalScore,
    required this.totalQuestions,
    required this.questionHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header
                _buildHeader(),
                SizedBox(height: 30),

                // Score Overview
                _buildScoreOverview(),
                SizedBox(height: 30),

                // Performance Analytics
                _buildPerformanceAnalytics(),
                SizedBox(height: 30),

                // AI Difficulty Progression
                _buildDifficultyProgression(),
                SizedBox(height: 30),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.emoji_events, size: 80, color: Colors.amber),
        SizedBox(height: 20),
        Text(
          'Quiz Completed!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Great job completing the $category quiz!',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildScoreOverview() {
    double percentage = totalQuestions > 0
        ? (finalScore / (totalQuestions * 10)) * 100
        : 0;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Score Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreItem('Total Score', finalScore.toString(), Icons.star),
              _buildScoreItem(
                'Questions',
                totalQuestions.toString(),
                Icons.quiz,
              ),
              _buildScoreItem(
                'Percentage',
                '${percentage.toStringAsFixed(1)}%',
                Icons.percent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.blue),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildPerformanceAnalytics() {
    int correctAnswers = questionHistory
        .where((q) => q['is_correct'] == true)
        .length;
    int incorrectAnswers = questionHistory
        .where((q) => q['is_correct'] == false)
        .length;
    double accuracy = totalQuestions > 0
        ? (correctAnswers / totalQuestions) * 100
        : 0;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsItem(
                  'Correct',
                  correctAnswers.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildAnalyticsItem(
                  'Incorrect',
                  incorrectAnswers.toString(),
                  Colors.red,
                  Icons.cancel,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  'Accuracy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDifficultyProgression() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Difficulty Progression',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 20),
          if (questionHistory.isEmpty)
            Text(
              'No questions answered yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            )
          else
            Column(
              children: questionHistory.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> question = entry.value;
                return _buildQuestionTimeline(index + 1, question);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionTimeline(
    int questionNumber,
    Map<String, dynamic> question,
  ) {
    Color difficultyColor = _getDifficultyColor(question['difficulty']);
    Color resultColor = question['is_correct'] ? Colors.green : Colors.red;
    IconData resultIcon = question['is_correct']
        ? Icons.check_circle
        : Icons.cancel;

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: difficultyColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                questionNumber.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question $questionNumber',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: difficultyColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        question['difficulty'].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(resultIcon, color: resultColor, size: 20),
                    SizedBox(width: 5),
                    Text(
                      '+${question['points_earned']} pts',
                      style: TextStyle(
                        color: resultColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Reset quiz and start again
              Provider.of<QuizProvider>(context, listen: false).resetQuiz();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(category: category),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Try Again', style: TextStyle(fontSize: 18)),
          ),
        ),
        SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Go back to home screen
              Provider.of<QuizProvider>(context, listen: false).resetQuiz();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Back to Home', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}
