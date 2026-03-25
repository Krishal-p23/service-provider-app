from django.urls import path
from .views import RegisterApi, UserApi, LoginApi, VerifyOTPApi, MeApi

urlpatterns = [
    path('user/', UserApi.as_view(), name='user'),
    path('me/', MeApi.as_view(), name='me'),
    path('login/', LoginApi.as_view(), name='login'),
    path('register/', RegisterApi.as_view(), name='register'),
    path('verify-otp/', VerifyOTPApi.as_view(), name='verify-otp'),
]
