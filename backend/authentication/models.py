from django.db import models


class AppUser(models.Model):
    ROLE_CUSTOMER = 'customer'
    ROLE_WORKER = 'worker'
    ROLE_ADMIN = 'admin'

    ROLE_CHOICES = [
        (ROLE_CUSTOMER, 'Customer'),
        (ROLE_WORKER, 'Worker'),
        (ROLE_ADMIN, 'Admin'),
    ]

    name = models.CharField(max_length=255)
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, unique=True)
    password_hash = models.TextField()
    role = models.CharField(max_length=50, choices=ROLE_CHOICES, default=ROLE_CUSTOMER)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'users'
        managed = False
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['phone']),
            models.Index(fields=['role']),
        ]

    def __str__(self):
        return f'{self.name} ({self.role})'


class UserLocation(models.Model):
    user = models.OneToOneField(AppUser, on_delete=models.CASCADE, related_name='location')
    latitude = models.FloatField()
    longitude = models.FloatField()
    address = models.TextField()

    class Meta:
        db_table = 'user_locations'
        managed = False

    def __str__(self):
        return f'{self.user.name} - {self.address[:40]}'
