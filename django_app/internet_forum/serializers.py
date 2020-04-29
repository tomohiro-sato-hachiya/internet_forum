from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Speech

class SpeechSerializer(serializers.ModelSerializer):

    class Meta:
        model = Speech
        fields = ['id', 'speaker', 'content', 'created']

class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = ['username']