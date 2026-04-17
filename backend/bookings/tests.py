from datetime import timedelta
from decimal import Decimal

from django.test import SimpleTestCase
from django.utils import timezone

from authentication.models import AppUser
from bookings.models import Booking
from services.models import Service, ServiceCategory
from workers.models import Worker


class BookingModelTests(SimpleTestCase):
	def test_status_field_default_is_pending(self):
		status_field = Booking._meta.get_field('status')

		self.assertEqual(status_field.default, Booking.STATUS_PENDING)

	def test_status_choices_include_awaiting_payment(self):
		choice_values = [value for value, _ in Booking.STATUS_CHOICES]

		self.assertIn(Booking.STATUS_AWAITING_PAYMENT, choice_values)

	def test_string_representation_uses_booking_id_and_user_name(self):
		user = AppUser(id=10, name='Asha', email='a@example.com', phone='1111111111', password_hash='x')
		worker_user = AppUser(id=11, name='Rohan', email='r@example.com', phone='2222222222', password_hash='y')
		worker = Worker(id=3, user=worker_user)
		category = ServiceCategory(id=4, category_name='Cleaning')
		service = Service(id=5, category=category, service_name='Deep Cleaning', base_price=Decimal('500.00'))
		booking = Booking(
			id=120,
			user=user,
			worker=worker,
			service=service,
			scheduled_date=timezone.now() + timedelta(days=1),
			total_amount=Decimal('850.00'),
		)

		self.assertEqual(str(booking), 'Booking #120 - Asha')
