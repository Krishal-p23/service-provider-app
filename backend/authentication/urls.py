from django.urls import path
from .views import RegisterApi, UserApi, LoginApi, VerifyOTPApi

urlpatterns = [
    path('user/', UserApi.as_view(), name='user'),
    path('login/', LoginApi.as_view(), name='login'),
    path('register/', RegisterApi.as_view(), name='register'),
    path('verify-otp/', VerifyOTPApi.as_view(), name='verify-otp'),
]
