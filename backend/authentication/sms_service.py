from django.conf import settings
import logging


logger = logging.getLogger(__name__)


def send_otp_sms(phone_number: str, otp: str, purpose: str = "verification") -> dict:
    """
    Send OTP SMS via Twilio (if SMS_OTP_ENABLED=True) or log to console.
    When flag is False, returns success but doesn't send (keeps current flow).
    """
    # Normalize phone number - remove non-digits
    normalized_phone = ''.join(ch for ch in str(phone_number or '') if ch.isdigit())
    
    # If number has country code, keep full length; otherwise pad to 10
    if len(normalized_phone) == 10:
        # Indian number without country code
        full_phone = f"+91{normalized_phone}"
    elif len(normalized_phone) == 12 and normalized_phone.startswith('91'):
        # Indian number with country code (91)
        full_phone = f"+{normalized_phone}"
    else:
        full_phone = f"+{normalized_phone}" if normalized_phone else ""
    
    # Check if SMS OTP is enabled
    sms_enabled = getattr(settings, 'SMS_OTP_ENABLED', False)

    logger.info("[OTP SMS ATTEMPT] enabled=%s purpose=%s phone=%s", sms_enabled, purpose, normalized_phone)
    
    if not sms_enabled:
        if getattr(settings, 'OTP_LOG_TO_PAPERTRAIL', False):
            logger.warning("[SMS OTP DISABLED] phone=%s otp=%s purpose=%s", normalized_phone, otp, purpose)
        else:
            logger.info("[SMS OTP DISABLED] phone=%s otp_hidden=true purpose=%s", normalized_phone, purpose)
        return {'success': True, 'message': 'SMS disabled by feature flag'}
    
    # Send via Twilio
    return _send_via_twilio(full_phone, otp, purpose)


def _send_via_twilio(phone_number: str, otp: str, purpose: str) -> dict:
    """
    Send SMS via Twilio.
    Returns dict with success/failure info.
    """
    try:
        account_sid = getattr(settings, 'TWILIO_ACCOUNT_SID', '')
        auth_token = getattr(settings, 'TWILIO_AUTH_TOKEN', '')
        from_number = getattr(settings, 'TWILIO_PHONE_NUMBER', '')
        
        if not (account_sid and auth_token and from_number):
            if getattr(settings, 'OTP_LOG_TO_PAPERTRAIL', False):
                logger.warning("[SMS TWILIO NOT CONFIGURED] phone=%s otp=%s", phone_number, otp)
            else:
                logger.info("[SMS TWILIO NOT CONFIGURED] phone=%s otp_hidden=true", phone_number)
            return {'success': True, 'message': 'Twilio not configured, logged to console'}
        
        from twilio.rest import Client
        
        client = Client(account_sid, auth_token)
        message_body = f"Your OTP is: {otp}. Valid for 5 minutes. Do not share with anyone."
        
        message = client.messages.create(
            from_=from_number,
            to=phone_number,
            body=message_body
        )
        
        if getattr(settings, 'OTP_LOG_TO_PAPERTRAIL', False):
            logger.warning("[SMS OTP] phone=%s otp=%s sid=%s", phone_number, otp, message.sid)
        else:
            logger.info("[SMS OTP] phone=%s otp_hidden=true sid=%s", phone_number, message.sid)
        
        return {
            'success': True,
            'message': 'OTP sent via SMS',
            'provider': 'twilio'
        }
    except Exception as e:
        logger.exception("[SMS TWILIO ERROR] %s", str(e))
        return {'success': False, 'message': f'SMS failed: {str(e)}'}
