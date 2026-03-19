from django.db import models


class Payment(models.Model):
    STATUS_PENDING = 'pending'
    STATUS_PAID = 'paid'
    STATUS_FAILED = 'failed'
    STATUS_REFUNDED = 'refunded'

    STATUS_CHOICES = [
        (STATUS_PENDING, 'Pending'),
        (STATUS_PAID, 'Paid'),
        (STATUS_FAILED, 'Failed'),
        (STATUS_REFUNDED, 'Refunded'),
    ]

    booking = models.ForeignKey('bookings.Booking', on_delete=models.CASCADE, related_name='payments')
    payment_method = models.CharField(max_length=50)
    payment_status = models.CharField(max_length=50, choices=STATUS_CHOICES, default=STATUS_PENDING)
    transaction_id = models.CharField(max_length=255, unique=True)
    paid_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'payments'
        managed = False
        indexes = [
            models.Index(fields=['booking']),
            models.Index(fields=['payment_status']),
            models.Index(fields=['transaction_id']),
        ]

    def __str__(self):
        return f'Payment #{self.id} - {self.payment_status}'
