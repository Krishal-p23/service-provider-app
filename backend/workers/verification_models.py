"""
Worker Document Verification Models
Stores Aadhar, PAN, Driving License and other government IDs
"""
from django.db import models


class WorkerDocumentVerification(models.Model):
    """
    Stores worker's government ID documents for verification
    """
    DOC_TYPE_AADHAR = 'aadhar'
    DOC_TYPE_PAN = 'pan'
    DOC_TYPE_DRIVING_LICENSE = 'driving_license'
    DOC_TYPE_PASSPORT = 'passport'
    DOC_TYPE_VOTER_ID = 'voter_id'

    DOC_TYPES = [
        (DOC_TYPE_AADHAR, 'Aadhar Card'),
        (DOC_TYPE_PAN, 'PAN Card'),
        (DOC_TYPE_DRIVING_LICENSE, 'Driving License'),
        (DOC_TYPE_PASSPORT, 'Passport'),
        (DOC_TYPE_VOTER_ID, 'Voter ID'),
    ]

    STATUS_PENDING = 'pending'
    STATUS_VERIFIED = 'verified'
    STATUS_REJECTED = 'rejected'

    STATUSES = [
        (STATUS_PENDING, 'Pending Review'),
        (STATUS_VERIFIED, 'Verified'),
        (STATUS_REJECTED, 'Rejected'),
    ]

    worker = models.OneToOneField(
        'workers.Worker',
        on_delete=models.CASCADE,
        related_name='document_verification'
    )
    
    document_type = models.CharField(
        max_length=50,
        choices=DOC_TYPES,
        default=DOC_TYPE_AADHAR
    )
    
    # Document number (Aadhar/PAN/License number)
    document_number = models.CharField(max_length=255)
    
    # Document image file - stored in media/worker_documents/
    document_image = models.ImageField(
        upload_to='worker_documents/%Y/%m/%d/',
        null=True,
        blank=True,
        help_text='Front side of ID document'
    )
    
    # Back side image (for documents that have back)
    document_image_back = models.ImageField(
        upload_to='worker_documents/%Y/%m/%d/',
        null=True,
        blank=True,
        help_text='Back side of ID document'
    )
    
    # Verification status
    status = models.CharField(
        max_length=50,
        choices=STATUSES,
        default=STATUS_PENDING
    )
    
    # Admin notes for rejection reason
    rejection_reason = models.TextField(blank=True)
    verified_by = models.ForeignKey(
        'authentication.AppUser',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='verified_workers'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    verified_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'worker_document_verification'
        managed = True
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.worker.user.name} - {self.get_document_type_display()} ({self.status})"
    
    @property
    def is_verified(self):
        return self.status == self.STATUS_VERIFIED
    
    @property
    def is_pending(self):
        return self.status == self.STATUS_PENDING
    
    @property
    def is_rejected(self):
        return self.status == self.STATUS_REJECTED
