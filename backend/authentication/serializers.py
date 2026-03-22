import uuid
import random
from rest_framework import serializers
from .models import User, CustomerProfile, WorkerProfile, OTP
from django.contrib.auth import get_user_model
from django.db import transaction

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        exclude = ['password']

class LoginSerializer(serializers.Serializer):
    identifier = serializers.CharField()
    password = serializers.CharField()
    role = serializers.ChoiceField(choices=User.ROLE_CHOICES)

    def validate(self, data):
        identifier = data.get('identifier')
        password = data.get('password')
        role = data.get('role')

        user = User.objects.filter(username=identifier).first() or \
               User.objects.filter(phone=identifier).first()

        if not user:
            raise serializers.ValidationError({
                "identifier": "Invalid email or phone or username."
                })

        if not user.check_password(password):
            raise serializers.ValidationError({
                "password": "Incorrect password."
                })

        if user.role != role:
            raise serializers.ValidationError({
                "role": "User role mismatch."
                })

        data['user'] = user
        return data
    
class RegisterSerializer(serializers.ModelSerializer):
    role = serializers.ChoiceField(choices=User.ROLE_CHOICES)
    password = serializers.CharField(write_only=True)

    username = serializers.CharField(required=False)
    email = serializers.EmailField(required=False)
    phone = serializers.CharField()

    service_type = serializers.ChoiceField(choices=WorkerProfile.SERVICE_TYPES, required=False)
    lat = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)
    lon = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)

    address = serializers.CharField(required=False)

    class Meta:
        model = User
        fields = ['username', 'password', 'email', 'role', 'phone', 'service_type', 'lat', 'lon', 'address']

    def validate(self, data):
        role = data.get('role')

        if not data.get('username'):
            data['username'] = f"user_{uuid.uuid4().hex[:8]}"

        phone = data.get('phone')
        if not phone:
            raise serializers.ValidationError({
                "phone": "Phone number is required."
                })
            
        if User.objects.filter(phone=phone).exists():
            raise serializers.ValidationError({
                "phone": "A user with this phone number already exists."
            })
        
        email = data.get('email')
        if email:
            if User.objects.filter(email=email).exists():
                raise serializers.ValidationError({
                    "email": "A user with this email already exists."
                })
            
        elif role == 'WORKER':
            if not data.get('service_type'):
                raise serializers.ValidationError(
                    "Worker must provide service_type."
                )
            
        return data

    def create(self, validated_data):
        phone = validated_data.get('phone')

        validated_data['email'] = validated_data.get('email') or None

        otp = str(random.randint(100000, 999999))

        with transaction.atomic():
            OTP.objects.filter(phone=phone).delete()
            OTP.objects.update_or_create(
                phone=phone,
                defaults={
                    "otp": otp,
                    "data": validated_data
                })

            print(f"OTP for {phone}: {otp}")

            return {
                "phone": phone,
                "message": "OTP sent to phone. Please verify to complete registration."
            }
        
class VerifyOTPSerializer(serializers.Serializer):
    phone = serializers.CharField()
    otp = serializers.CharField()

    def validate(self, data):
        phone = data.get('phone')
        otp = data.get('otp')

        otp_obj = OTP.objects.filter(phone=phone, otp=otp).last()
        if not otp_obj:
            raise serializers.ValidationError("Invalid OTP.")

        if otp_obj.is_expired():
            raise serializers.ValidationError("OTP has expired.")
        
        data['otp_obj'] = otp_obj
        return data
    
    def create(self, validated_data):
        with transaction.atomic():

            otp_obj = validated_data.get('otp_obj')
            data = otp_obj.data

            phone = otp_obj.phone
            role = data.get('role')
            email = data.get('email')  or None

            if email and User.objects.filter(email=email).exists():
                raise serializers.ValidationError({
                    "email": "A user with this email already exists."
                })

            user = User.objects.create_user(
                username=data.get('username') or f"user_{uuid.uuid4().hex[:8]}",
                email=email,
                phone=phone,
                password=data.get('password'),
                role=role
            )

            if role == 'CUSTOMER':
                CustomerProfile.objects.create(
                    user=user,
                    address=data.get('address', None)
                )
            else:
                WorkerProfile.objects.create(
                user=user,
                service_type=data.get('service_type'),
                lat=data.get('lat', None),
                lon=data.get('lon', None)
            )
                
            OTP.objects.filter(phone=phone).delete()
            return user
    
class UpdateProfileSerializer(serializers.ModelSerializer):
    address = serializers.CharField(required=False)

    class Meta:
        model = User
        fields = ['username', 'email', 'profile_picture']

    def update(self, instance, validated_data):
        request = self.context.get('request')

        instance.username = validated_data.get('username', instance.username)
        instance.email = validated_data.get('email', instance.email)
        instance.profile_picture = validated_data.get('profile_picture', instance.profile_picture)
        instance.save()

        if instance.role == 'CUSTOMER':
            address = validated_data.get('address')
            if address:
                instance.customer_profile.address = address
                instance.customer_profile.save()
                
        return instance