from django.urls import path
from .views import demo_api, get_users, register, login

app_name = 'accounts'

urlpatterns = [
    path('demo/', demo_api, name='demo_api'),
    path('users/', get_users, name='get_users'),
    path('register/', register, name='register'),
    path('login/', login, name='login'),
]
