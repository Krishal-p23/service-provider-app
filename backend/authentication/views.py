### Django REST Framework ###

from random import random

from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import OTP, User
from .serializers import RegisterSerializer, UpdateProfileSerializer, UserSerializer, LoginSerializer, VerifyOTPSerializer
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.permissions import IsAuthenticated


class UserApi(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        queryset = User.objects.all()
        serializer = UserSerializer(queryset, many=True)
        return Response({
            'status': True,
            'data' : serializer.data,
        }, status=status.HTTP_200_OK)
    
class LoginApi(APIView):
    def post(self, request):
        data = request.data
        serializer = LoginSerializer(data=data)
        if not serializer.is_valid():
            return Response({
                'status': 400,
                'message': 'Invalid data',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
        
        user = serializer.validated_data['user']
        
        if user:
            token, _ = Token.objects.get_or_create(user=user)
            return Response({
                'status': 200,
                'data': {'token': token.key},
                'message': 'Login successful',
            }, status=status.HTTP_200_OK)
       
        return Response({
            'status': 401,
            'data': {},
            'message': 'Invalid credentials',
        }, status=status.HTTP_401_UNAUTHORIZED)

class RegisterApi(APIView):
    def post(self, request):
        serializer = RegisterSerializer(data=request.data, context={'request': request})
        
        if serializer.is_valid():
            data = serializer.save()
            return Response({
                'status': 201,
                'data': data,
                'message': 'OTP sent successfully',
            }, status=status.HTTP_201_CREATED)
        else:
            return Response({
                'status': 400,
                'data': {},
                'message': 'Registration failed',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

class VerifyOTPApi(APIView):
    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        
        if serializer.is_valid():
            user = serializer.save()
            
            return Response({
                'status': 201,
                'message': 'User registration successfully',
                'user': {
                    'id': user.id,
                    'username': user.username,
                    'phone': user.phone,
                    'role': user.role
                }
            }, status=status.HTTP_201_CREATED)
        
        return Response({
            'status': 400,
            'data': {},
            'message': 'OTP verification failed',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
    
class ProfileApi(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(
            serializer.data,
            status=status.HTTP_200_OK
        )
    
    def patch(self, request):
        serializer = UpdateProfileSerializer(
            request.user,
            data=request.data,
            partial=True,
            context={'request': request}
        )

        if serializer.is_valid():
            user = serializer.save()
            return Response(
                UserSerializer(user).data,
                status=status.HTTP_200_OK
            )
        
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
class ChangePhoneRequestOTP(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        new_phone = request.data.get('new_phone')

        if User.objects.filter(phone=new_phone).exists():
            return Response({
                'error': 'A user with this phone number already exists.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        otp = str(random.randint(100000, 999999))

        OTP.objects.update_or_create(
            phone=new_phone,
            defaults={
                "otp": otp,
                "data": {"user_id": request.user.id}
            }
        )

        print(f"OTP for changing phone to {new_phone}: {otp}")

        return Response(
            {"message": "OTP sent to new phone number. Please verify to complete the change."},
            status=status.HTTP_200_OK
        )
    
class ChangePhoneVerifyOTP(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        phone = request.data.get('phone')
        otp = request.data.get('otp')

        otp_obj = OTP.objects.filter(phone=phone, otp=otp).last()

        if not otp_obj or otp_obj.is_expired():
            return Response(
                {"error": "Invalid or expired OTP"},
                status=status.HTTP_400_BAD_REQUEST
            )

        request.user.phone = phone
        request.user.save()

        otp_obj.delete()

        return Response(
            {"message": "Phone updated successfully"},
            status=status.HTTP_200_OK
        )
    
class ChangePasswordApi(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        old_password = request.data.get('old_password')
        new_password = request.data.get('new_password')

        user = request.user

        if not user.check_password(old_password):
            return Response(
                {"error": "Incorrect old password"},
                status=status.HTTP_400_BAD_REQUEST
            )

        user.set_password(new_password)
        user.save()

        return Response(
            {"message": "Password updated successfully"},
            status=status.HTTP_200_OK
        )

class UpdateWorkerLocationApi(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.data.get('role') != 'WORKER':
            return Response(
                {"error": "Unauthorized."},
                status=status.HTTP_403_FORBIDDEN
            )
        
        lat = request.data.get('lat')
        lon = request.data.get('lon')

        worker = request.user.worker_profile
        worker.lat = lat
        worker.lon = lon
        worker.save()

        return Response(
            {"message": "Location updated successfully"},
            status=status.HTTP_200_OK
        )