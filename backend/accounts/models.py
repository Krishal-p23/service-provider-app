from django.contrib.auth.models import AbstractUser, PermissionsMixin
from django.db import models
from .managers import UserManager

class User(AbstractUser, PermissionsMixin):
    Role =(
        ('USER', 'User'),
        ('WORKER', 'Worker'),
        )

    email = models.EmailField(unique=True, null=True, blank=True)
    phone = models.CharField(max_length=15, unique=True, null=True, blank=True)
    role = models.CharField(
        max_length=10,
        choices=Role,
        default='USER',
    )

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(auto_now_add=True)
    
    objects = UserManager()
    
    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']

    def __str__(self):
        return f"{self.role} - {self.phone or self.email or self.username}"


class CustomerProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    username = models.CharField(max_length=100, blank=True)

    def __str__(self):
        return f"CustomerProfile({self.user.id})"


class WorkerProfile(models.Model):
    VERIFICATION_STATUS = (
        ('NOT_UPLOADED', 'Not Uploaded'),
        ('PENDING', 'Pending'),
        ('VERIFIED', 'Verified'),
        ('REJECTED', 'Rejected'),
    )

    user = models.OneToOneField(User, on_delete=models.CASCADE)
    worker_name = models.CharField(max_length=100)
    service_type = models.CharField(max_length=100)

    image = models.ImageField(upload_to='workers/images/', null=True, blank=True)
    gov_id = models.FileField(upload_to='workers/gov_ids/', null=True, blank=True)

    verification_status = models.CharField(
        max_length=20,
        choices=VERIFICATION_STATUS,
        default='NOT_UPLOADED'
    )

    def __str__(self):
        return f"Worker({self.worker_name})"

