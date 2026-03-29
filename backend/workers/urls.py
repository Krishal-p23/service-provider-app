from django.urls import path
from .views import profile, jobs, stats, auth_debug

app_name = 'workers'

urlpatterns = [
    path('profile/', profile, name='profile'),
    path('jobs/', jobs, name='jobs'),
    path('stats/', stats, name='stats'),
    path('auth-debug/', auth_debug, name='auth_debug'),  # Debug endpoint
]
