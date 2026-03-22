### Django REST Framework ###

from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import User
from .serializers import RegisterSerializer, UserSerializer, LoginSerializer, VerifyOTPSerializer
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