from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import Question, QuizSession, UserAnswer, KidMode
from .serializers import QuestionSerializer, QuizSessionSerializer, UserAnswerSerializer, KidModeSerializer
import random

@api_view(['POST'])
# @permission_classes([IsAuthenticated])  # Commented out for testing
def start_quiz(request):
    """Start a new quiz session"""
    category = request.data.get('category')
    
    if not category:
        return Response({'error': 'Category is required'}, status=status.HTTP_400_BAD_REQUEST)
    
    # For testing, return a mock response
    return Response({
        'quiz_session_id': 1,
        'message': f'Quiz started for category: {category}',
        'current_difficulty': 'medium'
    })

@api_view(['POST'])
# @permission_classes([IsAuthenticated])  # Commented out for testing
def submit_answer(request):
    """Submit an answer and get next question"""
    quiz_session_id = request.data.get('quiz_session_id')
    question_id = request.data.get('question_id')
    selected_answer = request.data.get('selected_answer')
    
    # For testing, return a mock response
    return Response({
        'is_correct': True,
        'correct_answer': 'Test Answer',
        'points_earned': 10,
        'current_difficulty': 'medium',
        'total_score': 10,
        'message': 'Answer submitted successfully'
    })

@api_view(['GET'])
# @permission_classes([IsAuthenticated])  # Commented out for testing
def get_quiz_stats(request):
    """Get user's quiz statistics"""
    # For testing, return mock stats
    stats = {
        'total_sessions': 5,
        'total_score': 150,
        'total_questions': 25,
        'categories_played': ['computer', 'maths', 'sports'],
        'message': 'Stats retrieved successfully'
    }
    
    return Response(stats)

@api_view(['POST'])
# @permission_classes([IsAuthenticated])  # Commented out for testing
def report_movement_violation(request):
    """Report movement violation from OpenCV analysis"""
    violation_type = request.data.get('violation_type')
    reason = request.data.get('reason', '')
    quiz_session_id = request.data.get('quiz_session_id')
    
    # For testing, return a mock response
    return Response({
        'warning_number': 1,
        'max_warnings': 2,
        'should_force_quit': False,
        'message': f'Warning recorded: {violation_type} - {reason}'
    })

@api_view(['POST'])
# @permission_classes([IsAuthenticated])  # Commented out for testing
def start_camera_monitoring(request):
    """Start camera monitoring for a quiz session"""
    quiz_session_id = request.data.get('quiz_session_id')
    
    return Response({
        'status': 'monitoring_started',
        'max_warnings': 2,
        'message': 'Camera monitoring active'
    })

@api_view(['POST'])
# @permission_classes([IsAuthenticated])  # Commented out for testing
def stop_camera_monitoring(request):
    """Stop camera monitoring"""
    quiz_session_id = request.data.get('quiz_session_id')
    
    return Response({
        'status': 'monitoring_stopped',
        'total_warnings': 0,
        'message': 'Camera monitoring stopped'
    })

def get_random_question(category, difficulty):
    """Get a random question for given category and difficulty"""
    questions = Question.objects.filter(
        category=category,
        difficulty=difficulty,
        is_active=True
    )
    
    if questions.exists():
        return random.choice(questions)
    return None