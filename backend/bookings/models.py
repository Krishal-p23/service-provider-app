from django.db import models


class Booking(models.Model):
    STATUS_PENDING = 'pending'
    STATUS_CONFIRMED = 'confirmed'
    STATUS_COMPLETED = 'completed'
    STATUS_CANCELLED = 'cancelled'
# status::text = ANY (ARRAY['pending'::character varying, 'confirmed'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'cancelled'::character varying]::text[])
    STATUS_CHOICES = [
        (STATUS_PENDING, 'Pending'),
        (STATUS_CONFIRMED, 'Confirmed'),
        (STATUS_COMPLETED, 'Completed'),
        (STATUS_CANCELLED, 'Cancelled'),
    ]

    user = models.ForeignKey('authentication.AppUser', on_delete=models.CASCADE, related_name='bookings')
    worker = models.ForeignKey('workers.Worker', on_delete=models.CASCADE, related_name='bookings')
    service = models.ForeignKey('services.Service', on_delete=models.CASCADE, related_name='bookings')
    scheduled_date = models.DateTimeField()
    status = models.CharField(max_length=50, choices=STATUS_CHOICES, default=STATUS_PENDING)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'bookings'
        managed = False
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['worker']),
            models.Index(fields=['service']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return f'Booking #{self.id} - {self.user.name}'
