from django.urls import path
from .views import demo_api, get_users, register, login, me, update_profile, workers

app_name = 'authentication'

urlpatterns = [
    path('demo/', demo_api, name='demo_api'),
    path('users/', get_users, name='get_users'),
    path('workers/', workers, name='workers'),
    path('register/', register, name='register'),
    path('login/', login, name='login'),
    path('me/', me, name='me'),
    path('profile/<int:user_id>/', update_profile, name='update_profile'),
]
