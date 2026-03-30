import requests
from django.conf import settings


def send_otp_sms(phone_number: str, otp: str, purpose: str = "verification") -> dict:
    """Send OTP SMS via Fast2SMS or fallback to console logging in development."""
    normalized_phone = ''.join(ch for ch in str(phone_number or '') if ch.isdigit())
    if len(normalized_phone) > 10:
        normalized_phone = normalized_phone[-10:]

    if len(normalized_phone) != 10:
        return {'success': False, 'message': 'Invalid phone number'}

    if not settings.FAST2SMS_API_KEY:
        print(f"[SMS FALLBACK] Phone: {normalized_phone} | OTP: {otp} | Purpose: {purpose}")
        return {'success': True, 'message': 'OTP logged to console (no API key set)'}

    url = "https://www.fast2sms.com/dev/bulkV2"
    payload = {
        "variables_values": otp,
        "route": "otp",
        "numbers": normalized_phone,
    }
    headers = {
        "authorization": settings.FAST2SMS_API_KEY,
        "Content-Type": "application/json",
    }

    try:
        response = requests.post(url, json=payload, headers=headers, timeout=10)
        data = response.json()
        if data.get("return"):
            return {'success': True, 'message': 'OTP sent'}
        return {'success': False, 'message': data.get('message', 'SMS failed')}
    except Exception as exc:
        return {'success': False, 'message': str(exc)}
