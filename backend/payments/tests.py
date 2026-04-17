from datetime import timedelta
from decimal import Decimal

from django.test import SimpleTestCase
from django.utils import timezone

from authentication.models import AppUser
from bookings.models import Booking
from payments.models import Payment, WalletTransaction
from services.models import Service, ServiceCategory
from workers.models import Worker


class PaymentModelTests(SimpleTestCase):
	def test_payment_status_default_is_pending(self):
		payment_status_field = Payment._meta.get_field('payment_status')

		self.assertEqual(payment_status_field.default, Payment.STATUS_PENDING)

	def test_payment_string_representation(self):
		user = AppUser(id=1, name='User', email='u@example.com', phone='1000000000', password_hash='z')
		worker_user = AppUser(id=2, name='Worker', email='w@example.com', phone='2000000000', password_hash='z')
		worker = Worker(id=20, user=worker_user)
		category = ServiceCategory(id=30, category_name='AC Repair')
		service = Service(id=40, category=category, service_name='AC Service', base_price=Decimal('999.00'))
		booking = Booking(
			id=50,
			user=user,
			worker=worker,
			service=service,
			scheduled_date=timezone.now() + timedelta(days=1),
			total_amount=Decimal('999.00'),
		)
		payment = Payment(
			id=7,
			booking=booking,
			payment_method='upi',
			payment_status=Payment.STATUS_PAID,
			transaction_id='txn_123',
		)

		self.assertEqual(str(payment), 'Payment #7 - paid')


class WalletTransactionModelTests(SimpleTestCase):
	def test_wallet_transaction_type_choices_are_available(self):
		choice_values = [value for value, _ in WalletTransaction.TYPE_CHOICES]

		self.assertIn(WalletTransaction.TYPE_CREDIT, choice_values)
		self.assertIn(WalletTransaction.TYPE_DEBIT, choice_values)
		self.assertIn(WalletTransaction.TYPE_REFUND, choice_values)

	def test_wallet_transaction_is_managed_by_django(self):
		self.assertTrue(WalletTransaction._meta.managed)

	def test_wallet_transaction_string_representation(self):
		user = AppUser(id=99, name='Nora', email='n@example.com', phone='3000000000', password_hash='x')
		transaction = WalletTransaction(
			id=15,
			user=user,
			amount=Decimal('100.00'),
			type=WalletTransaction.TYPE_CREDIT,
			description='Signup bonus',
		)

		self.assertEqual(str(transaction), 'WalletTransaction #15 - credit')
