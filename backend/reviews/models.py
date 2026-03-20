from django.db import models


class Review(models.Model):
    booking = models.ForeignKey('bookings.Booking', on_delete=models.CASCADE, related_name='reviews')
    user = models.ForeignKey('authentication.AppUser', on_delete=models.CASCADE, related_name='reviews_given')
    worker = models.ForeignKey('workers.Worker', on_delete=models.CASCADE, related_name='reviews_received')
    rating = models.IntegerField()
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'reviews'
        managed = False
        indexes = [
            models.Index(fields=['booking']),
            models.Index(fields=['user']),
            models.Index(fields=['worker']),
        ]

    def __str__(self):
        return f'Review #{self.id} - {self.rating}/5'
