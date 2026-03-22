from django.db import models
from django.contrib.auth.models import AbstractUser

# Base user class for common fields
class User(AbstractUser):
    ROLE_CHOICES = (
        ('CUSTOMER', 'Customer'),
        ('WORKER', 'Worker'),
        ('ADMIN', 'Admin'),
    )
    role = models.CharField(choices=ROLE_CHOICES, max_length=10)
    email = models.EmailField(unique=False, blank=True, null=True)
    phone = models.CharField(unique=True, blank=True, null=True)

    profile_picture = models.ImageField(upload_to='profiles/', null=True, blank=True)

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['phone', 'role']

    def __str__(self):
        return self.username

class CustomerProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='customer_profile')
    address = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return f"{self.user.username}'s Profile"


class WorkerProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='worker_profile')
    
    SERVICE_TYPES = (
        ('PLUMBING', 'Plumbing'),
        ('ELECTRICAL', 'Electrical'),
        ('CARPENTRY', 'Carpentry'),
        ('CLEANING', 'Cleaning'),
        ('PAINTING', 'Painting'),
    )
    service_type = models.CharField(max_length=100, choices=SERVICE_TYPES, blank=False, null=False)

    # Verification status for workers
    VERIFICATION_STATUS = (
        ('NOT_UPLOADED', 'Not Uploaded'),
        ('PENDING', 'Pending'),
        ('VERIFIED', 'Verified'),
        ('NOT_VERIFIED', 'Not Verified'),
    )
    verification_status = models.CharField(max_length=20, choices=VERIFICATION_STATUS, default='NOT_UPLOADED')

    lat = models.DecimalField(max_digits=9, decimal_places=6, blank=True, null=True)
    lon = models.DecimalField(max_digits=9, decimal_places=6, blank=True, null=True)
    last_updated = models.DateTimeField(auto_now=True)

    jobs_completed = models.PositiveIntegerField(default=0)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.00)

    class Meta:
        indexes = [
            models.Index(fields=['service_type']),
            models.Index(fields=['verification_status']),
        ]

    def __str__(self):
        return f"{self.user.username}'s Profile"

class OTP(models.Model):
    phone = models.CharField(max_length=15)
    otp = models.CharField(max_length=6)
    data = models.JSONField()
    created_at = models.DateTimeField(auto_now_add=True)

    def is_expired(self):
        from datetime import timedelta
        from django.utils import timezone

        return self.created_at < timezone.now() - timedelta(minutes=5)