from decimal import Decimal

from django.test import SimpleTestCase

from services.models import Service, ServiceCategory
from services.views import DEMO_CATEGORIES


class ServiceModelTests(SimpleTestCase):
	def test_service_category_string_representation(self):
		category = ServiceCategory(category_name='Plumbing')

		self.assertEqual(str(category), 'Plumbing')

	def test_service_string_representation(self):
		category = ServiceCategory(id=1, category_name='Electrical')
		service = Service(
			id=9,
			category=category,
			service_name='Wiring Fix',
			base_price=Decimal('799.00'),
		)

		self.assertEqual(str(service), 'Wiring Fix')

	def test_models_are_mapped_to_existing_db_tables(self):
		self.assertFalse(ServiceCategory._meta.managed)
		self.assertFalse(Service._meta.managed)


class ServiceDemoCategoriesTests(SimpleTestCase):
	def test_demo_categories_have_unique_non_empty_names(self):
		normalized = [name.strip().lower() for name in DEMO_CATEGORIES]

		self.assertTrue(all(name.strip() for name in DEMO_CATEGORIES))
		self.assertEqual(len(normalized), len(set(normalized)))
