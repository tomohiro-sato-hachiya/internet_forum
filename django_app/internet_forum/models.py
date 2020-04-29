from django.db import models

class Speech(models.Model):
    speaker = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    content = models.TextField()
    created = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created']