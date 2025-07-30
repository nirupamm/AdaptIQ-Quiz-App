from rest_framework import serializers
from .models import Question, QuizSession, UserAnswer, KidMode

class QuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Question
        fields = ['id', 'question_text', 'category', 'difficulty', 'correct_answer', 'incorrect_answers']

class QuizSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = QuizSession
        fields = ['id', 'category', 'current_difficulty', 'total_questions_answered', 'total_score', 'is_active']

class UserAnswerSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserAnswer
        fields = ['id', 'question', 'selected_answer', 'is_correct', 'points_earned', 'difficulty_at_time']

class KidModeSerializer(serializers.ModelSerializer):
    class Meta:
        model = KidMode
        fields = ['is_enabled', 'max_difficulty', 'time_limit_per_question']