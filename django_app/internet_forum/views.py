from rest_framework import viewsets
from django.contrib.auth.models import User
from rest_framework import permissions
from .models import Speech
from .serializers import SpeechSerializer, UserSerializer

class SpeechListViewSet(viewsets.ModelViewSet):
    queryset = Speech.objects.all()
    serializer_class = SpeechSerializer

    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def perform_create(self, serializer):
        serializer.save(speaker=self.request.user)

class UserViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer