import hashlib
import hmac

from django.test import RequestFactory, SimpleTestCase, override_settings

from workers.views import _verify_didit_webhook_signature, get_current_user_id


class GetCurrentUserIdTests(SimpleTestCase):
	def setUp(self):
		self.factory = RequestFactory()

	def test_returns_user_id_from_bearer_token(self):
		request = self.factory.get('/api/workers/auth-debug/', HTTP_AUTHORIZATION='Bearer 42')

		user_id = get_current_user_id(request)

		self.assertEqual(user_id, 42)

	def test_falls_back_to_x_user_id_header(self):
		request = self.factory.get(
			'/api/workers/auth-debug/',
			HTTP_AUTHORIZATION='Bearer invalid',
			HTTP_X_USER_ID='55',
		)
		request.session = {}

		user_id = get_current_user_id(request)

		self.assertEqual(user_id, 55)

	def test_uses_session_when_header_missing(self):
		request = self.factory.get('/api/workers/auth-debug/')
		request.session = {'user_id': '77'}

		user_id = get_current_user_id(request)

		self.assertEqual(user_id, 77)

	def test_returns_none_when_no_user_id(self):
		request = self.factory.get('/api/workers/auth-debug/')
		request.session = {}

		user_id = get_current_user_id(request)

		self.assertIsNone(user_id)


class VerifyDiditWebhookSignatureTests(SimpleTestCase):
	def setUp(self):
		self.factory = RequestFactory()
		self.secret = 'unit-test-secret'
		self.body = b'{"status":"approved","vendor_data":"1"}'

	@override_settings(DIDIT_WEBHOOK_SECRET='unit-test-secret')
	def test_accepts_simple_signature(self):
		signature = hmac.new(
			self.secret.encode('utf-8'),
			self.body,
			hashlib.sha256,
		).hexdigest()
		request = self.factory.post(
			'/api/workers/kyc/webhook/',
			data=self.body,
			content_type='application/json',
			HTTP_X_SIGNATURE_SIMPLE=signature,
		)

		self.assertTrue(_verify_didit_webhook_signature(request))

	@override_settings(DIDIT_WEBHOOK_SECRET='unit-test-secret')
	def test_accepts_prefixed_legacy_signature(self):
		signature = hmac.new(
			self.secret.encode('utf-8'),
			self.body,
			hashlib.sha256,
		).hexdigest()
		request = self.factory.post(
			'/api/workers/kyc/webhook/',
			data=self.body,
			content_type='application/json',
			HTTP_X_DIDIT_SIGNATURE=f'sha256={signature}',
		)

		self.assertTrue(_verify_didit_webhook_signature(request))

	@override_settings(DIDIT_WEBHOOK_SECRET='unit-test-secret')
	def test_accepts_v2_signature_with_timestamp(self):
		timestamp = '1712361600'
		payload = f'{timestamp}.{self.body.decode("utf-8")}'.encode('utf-8')
		signature = hmac.new(
			self.secret.encode('utf-8'),
			payload,
			hashlib.sha256,
		).hexdigest()
		request = self.factory.post(
			'/api/workers/kyc/webhook/',
			data=self.body,
			content_type='application/json',
			HTTP_X_TIMESTAMP=timestamp,
			HTTP_X_SIGNATURE_V2=signature,
		)

		self.assertTrue(_verify_didit_webhook_signature(request))

	@override_settings(DIDIT_WEBHOOK_SECRET='unit-test-secret')
	def test_rejects_invalid_signature(self):
		request = self.factory.post(
			'/api/workers/kyc/webhook/',
			data=self.body,
			content_type='application/json',
			HTTP_X_SIGNATURE_SIMPLE='not-valid',
		)

		self.assertFalse(_verify_didit_webhook_signature(request))

	@override_settings(DIDIT_WEBHOOK_SECRET='')
	def test_rejects_when_secret_missing(self):
		request = self.factory.post(
			'/api/workers/kyc/webhook/',
			data=self.body,
			content_type='application/json',
			HTTP_X_SIGNATURE_SIMPLE='anything',
		)

		self.assertFalse(_verify_didit_webhook_signature(request))
