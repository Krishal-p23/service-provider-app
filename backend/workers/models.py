from django.db import models
from .verification_models import WorkerDocumentVerification


class Worker(models.Model):
    VERIFICATION_STATUS_NOT_STARTED = 'not_started'
    VERIFICATION_STATUS_PENDING = 'pending'
    VERIFICATION_STATUS_APPROVED = 'approved'
    VERIFICATION_STATUS_REJECTED = 'rejected'
    
    VERIFICATION_STATUSES = [
        (VERIFICATION_STATUS_NOT_STARTED, 'Not Started'),
        (VERIFICATION_STATUS_PENDING, 'Pending'),
        (VERIFICATION_STATUS_APPROVED, 'Approved'),
        (VERIFICATION_STATUS_REJECTED, 'Rejected'),
    ]
    
    user = models.OneToOneField('authentication.AppUser', on_delete=models.CASCADE, related_name='worker_profile')
    is_verified = models.BooleanField(default=False)
    verification_status = models.CharField(
        max_length=50,
        choices=VERIFICATION_STATUSES,
        default=VERIFICATION_STATUS_NOT_STARTED,
        help_text="KYC verification status: not_started, pending, approved, rejected"
    )
    is_available = models.BooleanField(default=True)
    experience_years = models.IntegerField(default=0)
    bio = models.TextField(blank=True)
    profile_photo = models.TextField(blank=True)

    class Meta:
        db_table = 'workers'
        managed = False

    def __str__(self):
        return f'Worker: {self.user.name}'


class WorkerService(models.Model):
    worker = models.ForeignKey(Worker, on_delete=models.CASCADE, related_name='worker_services')
    service = models.ForeignKey('services.Service', on_delete=models.CASCADE, related_name='service_workers')
    price_override = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    class Meta:
        db_table = 'worker_services'
        managed = False
        unique_together = ('worker', 'service')

    def __str__(self):
        return f'{self.worker.user.name} - {self.service.service_name}'
