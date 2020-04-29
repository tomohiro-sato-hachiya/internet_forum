from rest_framework.urlpatterns import format_suffix_patterns
from django.urls import path
from .views import SpeechListViewSet, UserViewSet

speech_list = SpeechListViewSet.as_view({
    'get': 'list',
    'post': 'create'
})

user_detail = UserViewSet.as_view({
    'get': 'retrieve'
})

urlpatterns = format_suffix_patterns([
    path('speeches/', speech_list, name='speech-list'),
    path('users/<int:pk>/', user_detail, name='user-detail'),
])