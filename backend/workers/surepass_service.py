import requests
from django.conf import settings


class SurepassVerificationService:
    """Surepass.io KYC verification service wrapper."""

    BASE_URL = 'https://kyc-api.surepass.io/api/v1'

    @staticmethod
    def _get_headers():
        return {
            'Authorization': f'Bearer {settings.SUREPASS_API_TOKEN}',
            'Content-Type': 'application/json',
        }

    @staticmethod
    def is_enabled() -> bool:
        return bool(settings.SUREPASS_API_TOKEN)

    @staticmethod
    def verify_aadhaar_ocr(image_base64: str) -> dict:
        if not settings.SUREPASS_API_TOKEN:
            return {'success': False, 'message': 'SUREPASS_API_TOKEN not set in .env'}

        try:
            response = requests.post(
                f'{SurepassVerificationService.BASE_URL}/aadhaar-v3/ocr',
                headers=SurepassVerificationService._get_headers(),
                json={'id': image_base64},
                timeout=30,
            )
            data = response.json()
            if data.get('success'):
                return {'success': True, 'data': data.get('data', {})}
            return {'success': False, 'message': data.get('message', 'Verification failed')}
        except Exception as exc:
            return {'success': False, 'message': str(exc)}

    @staticmethod
    def verify_pan(pan_number: str) -> dict:
        if not settings.SUREPASS_API_TOKEN:
            return {'success': False, 'message': 'SUREPASS_API_TOKEN not set in .env'}

        try:
            response = requests.post(
                f'{SurepassVerificationService.BASE_URL}/pan/pan',
                headers=SurepassVerificationService._get_headers(),
                json={'id_number': pan_number},
                timeout=15,
            )
            data = response.json()
            if data.get('success'):
                return {'success': True, 'data': data.get('data', {})}
            return {'success': False, 'message': data.get('message', 'PAN verification failed')}
        except Exception as exc:
            return {'success': False, 'message': str(exc)}
