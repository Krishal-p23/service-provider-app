from rest_framework import serializers
from .models import User, WorkerProfile

class SignupSerializer(serializers.Serializer):
    role = serializers.ChoiceField(choices=['CUSTOMER', 'WORKER'])
    phone = serializers.CharField(required=False)
    email = serializers.EmailField(required=False)
    password = serializers.CharField(write_only=True)

    service_type = serializers.CharField(required=False)
    worker_name = serializers.CharField(required=False)

    def create(self, validated_data):
        role = validated_data.pop('role')
        password = validated_data.pop('password')

        user = User.objects.create_user(
            role=role,
            password=password,
            **validated_data
        )

        if role == 'WORKER':
            worker = user.workerprofile
            worker.service_type = validated_data.get('service_type')
            worker.worker_name = validated_data.get('worker_name', '')
            worker.save()

        return user
    
    
class GovIDUploadSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkerProfile
        fields = ['gov_id']

    def update(self, instance, validated_data):
        instance.gov_id = validated_data['gov_id']
        instance.verification_status = 'PENDING'
        instance.save()

        return instance
