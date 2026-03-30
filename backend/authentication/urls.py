from django.urls import path
from .views import (
    demo_api,
    get_users,
    register,
    login,
    me,
    update_profile,
    workers,
    save_fcm_token,
    otp_start,
    otp_verify,
    otp_resend,
)

app_name = 'authentication'

urlpatterns = [
    path('demo/', demo_api, name='demo_api'),
    path('users/', get_users, name='get_users'),
    path('workers/', workers, name='workers'),
    path('fcm-token/', save_fcm_token, name='save_fcm_token'),
    path('register/', register, name='register'),
    path('login/', login, name='login'),
    path('auth/otp/start/', otp_start, name='otp_start'),
    path('auth/otp/verify/', otp_verify, name='otp_verify'),
    path('auth/otp/resend/', otp_resend, name='otp_resend'),
    path('me/', me, name='me'),
    path('profile/<int:user_id>/', update_profile, name='update_profile'),
]
