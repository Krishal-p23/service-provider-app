import requests
from django.conf import settings


def send_worker_job_email(
    worker_email: str,
    worker_name: str,
    customer_name: str,
    service_name: str,
    scheduled_date,
    booking_id: int,
    event: str,
) -> dict:
    """Send worker job notification email via MailerSend behind feature flag."""
    enabled = getattr(settings, 'WEBLAB_WORKER_JOB_EMAIL_ENABLED', False)

    # One-line debug log so you can verify mail path quickly from terminal.
    print(
        f"[JOB EMAIL ATTEMPT] enabled={enabled} event={event} booking_id={booking_id} to={worker_email}"
    )

    if not enabled:
        return {'success': True, 'message': 'Worker job email disabled by feature flag'}

    api_token = getattr(settings, 'MAILERSEND_API_TOKEN', '')
    from_email = getattr(settings, 'MAILERSEND_FROM_EMAIL', '')
    from_name = getattr(settings, 'MAILERSEND_FROM_NAME', 'Service Provider App')

    if not api_token or not from_email or not worker_email:
        print(f"[JOB EMAIL CONFIG MISSING] booking_id={booking_id} to={worker_email}")
        return {'success': True, 'message': 'MailerSend config missing, skipped email'}

    if event == 'new_booking':
        subject = f"New Job Assigned | Booking #{booking_id}"
        text = (
            f"Hi {worker_name},\n"
            f"You have a new job booking.\n"
            f"Booking ID: #{booking_id}\n"
            f"Customer: {customer_name}\n"
            f"Service: {service_name}\n"
            f"Scheduled: {scheduled_date}\n"
        )
        html = (
            f"<h3>New Job Assigned</h3>"
            f"<p>Hi {worker_name}, you have a new job booking.</p>"
            f"<p><b>Booking ID:</b> #{booking_id}</p>"
            f"<p><b>Customer:</b> {customer_name}</p>"
            f"<p><b>Service:</b> {service_name}</p>"
            f"<p><b>Scheduled:</b> {scheduled_date}</p>"
        )
    elif event == 'booking_cancelled':
        subject = f"Job Cancelled | Booking #{booking_id}"
        text = (
            f"Hi {worker_name},\n"
            f"A booking has been cancelled.\n"
            f"Booking ID: #{booking_id}\n"
            f"Customer: {customer_name}\n"
            f"Service: {service_name}\n"
            f"Scheduled: {scheduled_date}\n"
        )
        html = (
            f"<h3>Job Cancelled</h3>"
            f"<p>Hi {worker_name}, a booking has been cancelled.</p>"
            f"<p><b>Booking ID:</b> #{booking_id}</p>"
            f"<p><b>Customer:</b> {customer_name}</p>"
            f"<p><b>Service:</b> {service_name}</p>"
            f"<p><b>Scheduled:</b> {scheduled_date}</p>"
        )
    else:
        return {'success': False, 'message': 'Unsupported email event'}

    payload = {
        'from': {'email': from_email, 'name': from_name},
        'to': [{'email': worker_email, 'name': worker_name or 'Worker'}],
        'subject': subject,
        'text': text,
        'html': html,
    }

    headers = {
        'Authorization': f'Bearer {api_token}',
        'Content-Type': 'application/json',
    }

    try:
        response = requests.post(
            'https://api.mailersend.com/v1/email',
            json=payload,
            headers=headers,
            timeout=15,
        )
        if response.status_code == 202:
            print(f"[JOB EMAIL SENT] event={event} booking_id={booking_id} to={worker_email}")
            return {'success': True, 'message': 'Worker email sent'}

        print(
            f"[JOB EMAIL FAILED] event={event} booking_id={booking_id} status={response.status_code} body={response.text}"
        )
        return {
            'success': False,
            'message': f'MailerSend failed with status {response.status_code}',
        }
    except Exception as exc:
        print(f"[JOB EMAIL ERROR] event={event} booking_id={booking_id} error={exc}")
        return {'success': False, 'message': str(exc)}
