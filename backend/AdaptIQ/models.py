from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone

class Question(models.Model):
    question_text = models.TextField()
    category = models.CharField(max_length=100)
    difficulty = models.CharField(max_length=10)  # easy, medium, hard
    correct_answer = models.CharField(max_length=255)
    incorrect_answers = models.JSONField()  # Store as list of strings
    api_question_id = models.IntegerField(unique=True, null=True, blank=True)  # Store API question ID
    created_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)
    
    def __str__(self):
        return f"{self.question_text[:50]}... ({self.category} - {self.difficulty})"
    
    class Meta:
        ordering = ['-created_at']