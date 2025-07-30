from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import Question, QuizSession, UserAnswer, KidMode
from .serializers import QuestionSerializer, QuizSessionSerializer, UserAnswerSerializer, KidModeSerializer
import random

# Global storage for testing (in production, use database)
quiz_sessions = {}

@api_view(['POST'])
# @permission_classes([IsAuthenticated])  # Commented out for testing
def start_quiz(request):
    """Start a new quiz session"""
    category = request.data.get('category')
    
    if not category:
        return Response({'error': 'Category is required'}, status=status.HTTP_400_BAD_REQUEST)
    
    # Get a random medium difficulty question to start
    question = get_random_question(category, 'medium')
    
    if not question:
        return Response({'error': 'No questions available for this category'}, status=status.HTTP_404_NOT_FOUND)
    
    # For testing without authentication, create a mock session ID
    session_id = random.randint(1000, 9999)
    
    # Initialize session state for AI tracking
    quiz_sessions[session_id] = {
        'category': category,
        'current_difficulty': 'medium',
        'consecutive_correct': 0,
        'consecutive_incorrect': 0,
        'total_score': 0,
        'total_questions_answered': 0,
        'max_questions': 10  # Set limit to 10 questions for testing
    }
    
    # Prepare answers (shuffle them)
    all_answers = [question.correct_answer] + question.incorrect_answers
    random.shuffle(all_answers)
    
    return Response({
        'quiz_session_id': session_id,
        'question': {
            'id': question.id,
            'question_text': question.question_text,
            'category': question.category,
            'difficulty': question.difficulty,
            'answers': all_answers
        },
        'current_difficulty': 'medium'
    })

@api_view(['POST'])
# @permission_classes([IsAuthenticated])  # Commented out for testing
def submit_answer(request):
    """Submit an answer and get next question using proper AI logic"""
    quiz_session_id = request.data.get('quiz_session_id')
    question_id = request.data.get('question_id')
    selected_answer = request.data.get('selected_answer')
    
    # Get the question
    try:
        question = Question.objects.get(id=question_id)
    except Question.DoesNotExist:
        return Response({'error': 'Question not found'}, status=status.HTTP_404_NOT_FOUND)
    
    # Check if answer is correct
    is_correct = selected_answer == question.correct_answer
    
    # Get session state
    if quiz_session_id not in quiz_sessions:
        return Response({'error': 'Invalid session ID'}, status=status.HTTP_400_BAD_REQUEST)
    
    session = quiz_sessions[quiz_session_id]
    session['total_questions_answered'] += 1
    
    # Apply AI logic
    if is_correct:
        session['consecutive_correct'] += 1
        session['consecutive_incorrect'] = 0
        
        # Calculate points based on current difficulty
        difficulty_points = {'easy': 5, 'medium': 10, 'hard': 20}
        points_earned = difficulty_points.get(session['current_difficulty'], 10)
        session['total_score'] += points_earned
        
        # Rule: If 2 consecutive correct, increase difficulty
        if session['consecutive_correct'] >= 2:
            if session['current_difficulty'] == 'easy':
                session['current_difficulty'] = 'medium'
                session['consecutive_correct'] = 0  # Reset counter after difficulty change
            elif session['current_difficulty'] == 'medium':
                session['current_difficulty'] = 'hard'
                session['consecutive_correct'] = 0  # Reset counter after difficulty change
            # If already 'hard', stay 'hard' (no further increase)
    else:
        session['consecutive_incorrect'] += 1
        session['consecutive_correct'] = 0
        points_earned = 0
        
        # Rule: If 2 consecutive incorrect, decrease difficulty
        if session['consecutive_incorrect'] >= 2:
            if session['current_difficulty'] == 'hard':
                session['current_difficulty'] = 'medium'
                session['consecutive_incorrect'] = 0  # Reset counter after difficulty change
            elif session['current_difficulty'] == 'medium':
                session['current_difficulty'] = 'easy'
                session['consecutive_incorrect'] = 0  # Reset counter after difficulty change
            # If already 'easy', stay 'easy' (no further decrease)
    
    # Check if quiz is complete (reached max questions)
    if session['total_questions_answered'] >= session['max_questions']:
        next_question_data = None
    else:
        # Get next question based on new difficulty
        next_question = get_random_question(question.category, session['current_difficulty'])
        
        if next_question:
            # Prepare answers for next question
            all_answers = [next_question.correct_answer] + next_question.incorrect_answers
            random.shuffle(all_answers)
            
            next_question_data = {
                'id': next_question.id,
                'question_text': next_question.question_text,
                'category': next_question.category,
                'difficulty': next_question.difficulty,
                'answers': all_answers
            }
        else:
            next_question_data = None
    
    return Response({
        'is_correct': is_correct,
        'correct_answer': question.correct_answer,
        'points_earned': points_earned,
        'current_difficulty': session['current_difficulty'],
        'total_score': session['total_score'],
        'questions_answered': session['total_questions_answered'],
        'max_questions': session['max_questions'],
        'next_question': next_question_data
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