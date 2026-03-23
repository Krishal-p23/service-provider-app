from django.urls import path
from .views import ChangePasswordApi, ChangePhoneVerifyOTP, RegisterApi, UpdateWorkerLocationApi, UserApi, LoginApi, VerifyOTPApi, ChangePhoneApi

urlpatterns = [
    path('user/', UserApi.as_view(), name='user'),
    path('login/', LoginApi.as_view(), name='login'),
    path('register/', RegisterApi.as_view(), name='register'),
    path('verify-otp/', VerifyOTPApi.as_view(), name='verify-otp'),
    path('change-password/', ChangePasswordApi.as_view(), name='change-password'),
    path('change-phone/request-otp/', ChangePhoneApi.as_view(), name='change-phone-request-otp'),
    path('change-phone/verify-otp/', ChangePhoneVerifyOTP.as_view(), name='change-phone-verify-otp'),
    path('worker/update-location/', UpdateWorkerLocationApi.as_view(), name='update-worker-location'),
]
