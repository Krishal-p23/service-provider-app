from django.test import SimpleTestCase

from authentication.models import AppUser, UserLocation


class AppUserModelTests(SimpleTestCase):
	def test_default_role_is_customer(self):
		role_field = AppUser._meta.get_field('role')

		self.assertEqual(role_field.default, AppUser.ROLE_CUSTOMER)

	def test_string_representation(self):
		user = AppUser(
			id=1,
			name='Khushi',
			email='khushi@example.com',
			phone='9876543210',
			password_hash='secret',
			role=AppUser.ROLE_WORKER,
		)

		self.assertEqual(str(user), 'Khushi (worker)')


class UserLocationModelTests(SimpleTestCase):
	def test_string_representation_truncates_address_to_40_chars(self):
		user = AppUser(
			id=2,
			name='Aman',
			email='aman@example.com',
			phone='9876500000',
			password_hash='secret',
		)
		address = '123 Long Street Name, Apartment 7, Big City, Country'
		location = UserLocation(
			user=user,
			latitude=12.0,
			longitude=77.0,
			address=address,
		)

		self.assertEqual(str(location), f'Aman - {address[:40]}')
