from django.shortcuts import render
from django.http import JsonResponse
from django.conf import settings
from django.db import connection
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
import json
import hmac
import hashlib
import logging
import os
import uuid
from datetime import datetime, timedelta
import requests
from .didit_service import DiditVerificationService
from .upi_qr_reader import extract_upi_from_qr

logger = logging.getLogger(__name__)

ACTIVE_JOB_STATUSES = ("pending", "confirmed", "in_progress", "completed")

# Create your views here.

@csrf_exempt
@require_http_methods(["GET"])
def auth_debug(request):
    """Debug endpoint to check authentication"""
    auth_header = request.headers.get('Authorization', 'NOT PRESENT')
    user_id = get_current_user_id(request)
    
    # Check if worker exists
    worker_exists = False
    if user_id:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, user_id FROM workers WHERE user_id = %s", [user_id])
            worker_row = cursor.fetchone()
            worker_exists = worker_row is not None
    
    return JsonResponse({
        "status": "debug",
        "auth_header": auth_header[:50] if len(auth_header) > 50 else auth_header,
        "extracted_user_id": user_id,
        "worker_exists": worker_exists,
        "has_jobs": user_id is not None and worker_exists,
    }, status=200)


def get_current_user_id(request):
    """Extract user_id from request Authorization header or session"""
    # Try Authorization header first (Bearer token from Flutter app)
    auth_header = request.headers.get('Authorization', '')
    if auth_header.startswith('Bearer '):
        try:
            user_id = int(auth_header[7:])  # Remove 'Bearer ' prefix
            print(f"✅ DEBUG: Extracted user_id {user_id} from Authorization header")
            return user_id
        except (ValueError, TypeError) as e:
            print(f"❌ DEBUG: Failed to parse Bearer token: {e}")
    
    # Fallback to session or X-User-Id header
    try:
        user_id = request.session.get('user_id') or request.headers.get('X-User-Id')
        if user_id:
            print(f"✅ DEBUG: Using user_id {user_id} from session/header")
            return int(user_id)
    except (ValueError, TypeError) as e:
        print(f"❌ DEBUG: Failed to parse user_id from session/header: {e}")
    
    print(f"❌ DEBUG: No user_id found. Auth header: {auth_header[:50]}")
    return None


def _get_worker_id_by_user_id(user_id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT id FROM workers WHERE user_id = %s", [user_id])
        row = cursor.fetchone()
    return row[0] if row else None


def _verify_didit_webhook_signature(request):
    """Validate Didit webhook signature using DIDIT_WEBHOOK_SECRET."""
    secret = (settings.DIDIT_WEBHOOK_SECRET or '').strip()
    if not secret:
        return False

    body = request.body or b''
    timestamp = (request.headers.get('X-Timestamp') or '').strip()

    signature_candidates = []

    # v1/legacy style headers
    legacy = (
        request.headers.get('X-Didit-Signature')
        or request.headers.get('Didit-Signature')
        or request.headers.get('X-Signature')
        or ''
    ).strip()
    if legacy:
        signature_candidates.append(legacy)

    # Didit v3 headers from dashboard test payload
    v2 = (request.headers.get('X-Signature-V2') or '').strip()
    simple = (request.headers.get('X-Signature-Simple') or '').strip()
    if v2:
        signature_candidates.append(v2)
    if simple:
        signature_candidates.append(simple)

    if not signature_candidates:
        return False

    normalized = []
    for sig in signature_candidates:
        if sig.startswith('sha256='):
            normalized.append(sig.split('=', 1)[1])
        else:
            normalized.append(sig)

    expected_simple = hmac.new(
        secret.encode('utf-8'),
        body,
        hashlib.sha256,
    ).hexdigest()

    expected_v2 = ''
    if timestamp:
        expected_v2 = hmac.new(
            secret.encode('utf-8'),
            f'{timestamp}.{body.decode("utf-8", errors="ignore")}'.encode('utf-8'),
            hashlib.sha256,
        ).hexdigest()

    for provided in normalized:
        if hmac.compare_digest(expected_simple, provided):
            return True
        if expected_v2 and hmac.compare_digest(expected_v2, provided):
            return True

    return False


@csrf_exempt
@require_http_methods(["POST"])
def start_kyc_session(request):
    """
    POST /api/workers/kyc/start/
    Create Didit KYC session and return URL to open in WebView.
    
    Flow:
    1. Check if worker already verified in database
    2. If verified, return error (don't call Didit again)
    3. If not verified, call Didit to create session
    4. Didit webhook will update database when verification completes
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse(
                {'success': False, 'message': 'Unauthorized. User ID not found'},
                status=401,
            )

        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse(
                {'success': False, 'message': 'Worker profile not found'},
                status=404,
            )

        # Check if already verified in database
        with connection.cursor() as cursor:
            cursor.execute(
                'SELECT is_verified FROM workers WHERE id = %s',
                [worker_id]
            )
            row = cursor.fetchone()
            if row and row[0]:  # is_verified = TRUE
                return JsonResponse(
                    {
                        'success': False,
                        'message': 'You are already verified. No need to verify again.'
                    },
                    status=400,
                )

        callback_url = f"{settings.BACKEND_BASE_URL}/api/workers/kyc/callback/"
        result = DiditVerificationService.create_verification_session(
            worker_id,
            callback_url,
        )
        status_code = 200 if result.get('success') else 502
        return JsonResponse(result, status=status_code)
    except Exception as exc:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"[KYC] Error in start_kyc_session: {str(exc)}")
        return JsonResponse(
            {
                'success': False,
                'message': 'There is some issue, please try later',
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["GET"])
def kyc_callback(request):
    """
    GET /api/workers/kyc/callback/
    Redirect target after verification completes.
    """
    return JsonResponse(
        {
            'success': True,
            'message': 'Verification callback received. You can return to the app.',
        },
        status=200,
    )


@csrf_exempt
@require_http_methods(["POST"])
def kyc_webhook(request):
    """
    POST /api/workers/kyc/webhook/
    Didit webhook callback for verification status updates.
    """
    is_test_webhook = (request.headers.get('X-Didit-Test-Webhook') or '').strip().lower() == 'true'

    if not _verify_didit_webhook_signature(request):
        # For Didit dashboard test webhooks, acknowledge success to validate URL wiring.
        if is_test_webhook:
            return JsonResponse({'received': True, 'test': True, 'message': 'Test webhook acknowledged'}, status=200)
        return JsonResponse({'received': False, 'message': 'Invalid signature'}, status=401)

    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'received': False, 'message': 'Invalid JSON payload'}, status=400)

    vendor_data = payload.get('vendor_data')
    if vendor_data is None and isinstance(payload.get('session'), dict):
        vendor_data = payload['session'].get('vendor_data')

    status = payload.get('status')
    if status is None and isinstance(payload.get('session'), dict):
        status = payload['session'].get('status')

    status_value = str(status or '').strip().lower()

    try:
        worker_id = int(str(vendor_data).strip()) if vendor_data is not None else None
    except (ValueError, TypeError):
        worker_id = None

    if worker_id and status_value == 'approved':
        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE workers SET is_verified = TRUE, verification_status = %s WHERE id = %s",
                ['approved', worker_id],
            )
            logger.info(
                "[KYC_Webhook] Worker %s KYC approved. Updated is_verified=TRUE, verification_status='approved'",
                worker_id,
            )

    return JsonResponse({'received': True, 'test': is_test_webhook}, status=200)


@csrf_exempt
@require_http_methods(["POST"])
def kyc_mock_approve(request):
    """
    POST /api/workers/kyc/mock-approve/
    Test endpoint: Simulate successful KYC verification and update database
    """
    try:
        worker_id_str = request.POST.get('worker_id') or request.GET.get('worker_id')
        if not worker_id_str:
            return JsonResponse({'success': False, 'message': 'Worker ID is required'}, status=400)
        
        worker_id = int(worker_id_str)
        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE workers SET is_verified = TRUE, verification_status = %s WHERE id = %s",
                ['approved', worker_id],
            )
        
        logger.info(f"[KYC_Mock] Worker {worker_id} approved via mock verification")
        return JsonResponse({'success': True, 'message': 'Mock verification approved'}, status=200)
    except Exception as e:
        logger.error(f"[KYC_Mock_Approve] Error: {e}")
        return JsonResponse({'success': False, 'message': str(e)}, status=500)


@csrf_exempt
@require_http_methods(["POST"])
def kyc_mock_reject(request):
    """
    POST /api/workers/kyc/mock-reject/
    Test endpoint: Simulate failed KYC verification and update database
    """
    try:
        worker_id_str = request.POST.get('worker_id') or request.GET.get('worker_id')
        if not worker_id_str:
            return JsonResponse({'success': False, 'message': 'Worker ID is required'}, status=400)
        
        worker_id = int(worker_id_str)
        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE workers SET is_verified = FALSE, verification_status = %s WHERE id = %s",
                ['rejected', worker_id],
            )
        
        logger.info(f"[KYC_Mock] Worker {worker_id} rejected via mock verification")
        return JsonResponse({'success': True, 'message': 'Mock verification rejected'}, status=200)
    except Exception as e:
        logger.error(f"[KYC_Mock_Reject] Error: {e}")
        return JsonResponse({'success': False, 'message': str(e)}, status=500)


@csrf_exempt
@require_http_methods(["GET"])
def kyc_mock_page(request):
    """
    GET /api/workers/kyc/mock/
    Mock KYC verification page for testing when Didit API credentials are unavailable.
    Displays a test page in WebView.
    """
    worker_id = request.GET.get('worker_id', 'unknown')
    
    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Mock KYC Verification</title>
        <style>
            * {{
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }}
            body {{
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }}
            .container {{
                background: white;
                border-radius: 16px;
                padding: 40px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                max-width: 500px;
                width: 100%;
                text-align: center;
            }}
            .icon {{
                font-size: 60px;
                margin-bottom: 20px;
            }}
            h1 {{
                color: #333;
                margin-bottom: 15px;
                font-size: 28px;
            }}
            .warning {{
                background-color: #fff3cd;
                border-left: 4px solid #ffc107;
                padding: 15px;
                margin: 20px 0;
                border-radius: 4px;
                text-align: left;
                font-size: 14px;
                color: #856404;
            }}
            .message {{
                color: #666;
                margin-bottom: 20px;
                line-height: 1.6;
                font-size: 16px;
            }}
            .button {{
                background-color: #667eea;
                color: white;
                padding: 15px 40px;
                border: none;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                margin: 10px 0;
                transition: background-color 0.3s;
                width: 100%;
                text-decoration: none;
                display: inline-block;
            }}
            .button:hover {{
                background-color: #5568d3;
            }}
            .info {{
                background-color: #e7f3ff;
                border-left: 4px solid #2196F3;
                padding: 15px;
                margin: 20px 0;
                border-radius: 4px;
                text-align: left;
                font-size: 14px;
                color: #0c5aa0;
            }}
            .footer {{
                margin-top: 30px;
                padding-top: 20px;
                border-top: 1px solid #eee;
                font-size: 12px;
                color: #999;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="icon">🧪</div>
            <h1>Mock KYC Verification</h1>
            
            <div class="warning">
                <strong>⚠️ Testing Mode</strong><br>
                Didit API credentials are not configured properly. This is a test page.
            </div>
            
            <div class="message">
                <p>In a real environment, you would complete your identity verification here using Didit's secure KYC process.</p>
            </div>
            
            <div class="info">
                <strong>ℹ️ For Production:</strong><br>
                Contact Didit support to get valid API credentials and update your .env file.
            </div>
            
            <button class="button" onclick="simulateVerification()">
                ✅ Simulate Verification Success
            </button>
            
            <button class="button" style="background-color: #f44336;" onclick="simulateFailure()">
                ❌ Simulate Verification Failure
            </button>
            
            <button class="button" style="background-color: #666;" onclick="goBack()">
                ← Back to App
            </button>
            
            <div class="footer">
                Worker ID: {worker_id} | Mock Session | Test Mode
            </div>
        </div>
        
        <script>
            const workerId = '{worker_id}';
            
            async function simulateVerification() {{
                try {{
                    const response = await fetch('/api/workers/kyc/mock-approve/?worker_id=' + workerId, {{
                        method: 'POST',
                        headers: {{'Content-Type': 'application/json'}},
                    }});
                    const data = await response.json();
                    
                    if (data.success) {{
                        alert('✅ Verification Approved! Database updated.');
                        setTimeout(goBack, 1000);
                    }} else {{
                        alert('❌ Error: ' + data.message);
                    }}
                }} catch (error) {{
                    alert('Error: ' + error);
                }}
            }}
            
            async function simulateFailure() {{
                try {{
                    const response = await fetch('/api/workers/kyc/mock-reject/?worker_id=' + workerId, {{
                        method: 'POST',
                        headers: {{'Content-Type': 'application/json'}},
                    }});
                    const data = await response.json();
                    
                    if (data.success) {{
                        alert('❌ Verification Rejected! Database updated.');
                        setTimeout(goBack, 1000);
                    }} else {{
                        alert('❌ Error: ' + data.message);
                    }}
                }} catch (error) {{
                    alert('Error: ' + error);
                }}
            }}
            
            function goBack() {{
                if (window.history.length > 1) {{
                    window.history.back();
                }} else {{
                    mobileClose();
                }}
            }}
            
            function mobileClose() {{
                // Try to close WebView for mobile apps
                if (typeof webkit !== 'undefined') {{
                    webkit.messageHandlers.close.postMessage(null);
                }} else {{
                    window.close();
                }}
            }}
        </script>
                }}
                // For Flutter WebView
                if (typeof JSChannel !== 'undefined') {{
                    JSChannel.postMessage('close');
                }}
            }}
        </script>
    </body>
    </html>
    """
    
    from django.http import HttpResponse
    return HttpResponse(html, content_type='text/html')


def _ensure_worker_bank_details_table():
    """Create worker_bank_details table if missing (SQLite/Postgres)."""
    vendor = connection.vendor
    with connection.cursor() as cursor:
        if vendor == "postgresql":
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS worker_bank_details (
                    id SERIAL PRIMARY KEY,
                    worker_id INTEGER NOT NULL UNIQUE REFERENCES workers(id) ON DELETE CASCADE,
                    account_holder_name VARCHAR(120) NOT NULL,
                    bank_name VARCHAR(120) NOT NULL,
                    account_number VARCHAR(40) NOT NULL,
                    ifsc_code VARCHAR(20) NOT NULL,
                    upi_id VARCHAR(120) NULL,
                    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
                    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
                )
                """
            )


def _ensure_worker_upi_details_table():
    """Create worker_upi_details table if missing (SQLite/Postgres)."""
    vendor = connection.vendor
    with connection.cursor() as cursor:
        if vendor == "postgresql":
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS worker_upi_details (
                    id SERIAL PRIMARY KEY,
                    worker_id INTEGER NOT NULL UNIQUE REFERENCES workers(id) ON DELETE CASCADE,
                    upi_id VARCHAR(120) NOT NULL,
                    upi_name VARCHAR(120) NULL,
                    upi_raw TEXT NULL,
                    is_verified BOOLEAN NOT NULL DEFAULT TRUE,
                    submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
                    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
                )
                """
            )
        else:
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS worker_upi_details (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    worker_id INTEGER NOT NULL UNIQUE,
                    upi_id TEXT NOT NULL,
                    upi_name TEXT NULL,
                    upi_raw TEXT NULL,
                    is_verified BOOLEAN NOT NULL DEFAULT 1,
                    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )


def _ensure_worker_availability_table():
    """Create worker_availability table if missing (SQLite/Postgres)."""
    vendor = connection.vendor
    with connection.cursor() as cursor:
        if vendor == "postgresql":
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS worker_availability (
                    id SERIAL PRIMARY KEY,
                    worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE CASCADE,
                    day_of_week INTEGER NOT NULL,
                    start_time TIME NOT NULL,
                    end_time TIME NOT NULL,
                    is_available BOOLEAN NOT NULL DEFAULT TRUE,
                    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                    UNIQUE(worker_id, day_of_week)
                )
                """
            )
        else:
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS worker_availability (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    worker_id INTEGER NOT NULL,
                    day_of_week INTEGER NOT NULL,
                    start_time TEXT NOT NULL,
                    end_time TEXT NOT NULL,
                    is_available BOOLEAN NOT NULL DEFAULT 1,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE(worker_id, day_of_week)
                )
                """
            )


def validate_ifsc(ifsc_code: str) -> dict:
    """
    Validate IFSC code using Razorpay's free public API.
    No API key needed. Endpoint: https://ifsc.razorpay.com/{IFSC}
    Returns bank name if valid, error if not.
    """
    try:
        response = requests.get(
            f'https://ifsc.razorpay.com/{ifsc_code}',
            timeout=5,
        )
        if response.status_code == 200:
            data = response.json()
            return {
                'valid': True,
                'bank': data.get('BANK'),
                'branch': data.get('BRANCH'),
            }
        return {'valid': False, 'message': 'Invalid IFSC code'}
    except Exception as e:
        return {'valid': False, 'message': str(e)}


def _ensure_worker_notifications_table():
    """Create worker_notifications table if missing (SQLite/Postgres)."""
    vendor = connection.vendor
    with connection.cursor() as cursor:
        if vendor == "postgresql":
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS worker_notifications (
                    id SERIAL PRIMARY KEY,
                    worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE CASCADE,
                    notif_type VARCHAR(40) NOT NULL,
                    title VARCHAR(180) NOT NULL,
                    message TEXT NOT NULL,
                    is_read BOOLEAN NOT NULL DEFAULT FALSE,
                    created_at TIMESTAMP NOT NULL DEFAULT NOW()
                )
                """
            )
        else:
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS worker_notifications (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    worker_id INTEGER NOT NULL,
                    notif_type TEXT NOT NULL,
                    title TEXT NOT NULL,
                    message TEXT NOT NULL,
                    is_read BOOLEAN NOT NULL DEFAULT 0,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )


def _seed_worker_notifications(worker_id):
    """Seed first set of notifications from real DB events if none exist."""
    admin_fee_rate = 0.02

    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT COUNT(*) FROM worker_notifications WHERE worker_id = %s",
            [worker_id],
        )
        existing_count = int(cursor.fetchone()[0] or 0)
        if existing_count > 0:
            return

        # Latest completed booking -> payment/earnings notification.
        cursor.execute(
            """
            SELECT b.total_amount, b.scheduled_date
            FROM bookings b
            WHERE b.worker_id = %s
              AND LOWER(b.status) = 'completed'
            ORDER BY b.scheduled_date DESC
            LIMIT 1
            """,
            [worker_id],
        )
        completed = cursor.fetchone()
        if completed:
            gross = float(completed[0] or 0)
            net = round(gross - (gross * admin_fee_rate), 2)
            cursor.execute(
                """
                INSERT INTO worker_notifications (worker_id, notif_type, title, message, is_read)
                VALUES (%s, %s, %s, %s, %s)
                """,
                [
                    worker_id,
                    "payment",
                    "Payment Processed",
                    f"Your completed job earning of Rs{int(net)} is ready for transfer.",
                    False,
                ],
            )

        # Latest active booking -> job notification.
        cursor.execute(
            """
            SELECT s.service_name
            FROM bookings b
            JOIN services s ON b.service_id = s.id
            WHERE b.worker_id = %s
              AND LOWER(b.status) IN ('pending', 'confirmed', 'in_progress')
            ORDER BY b.scheduled_date DESC
            LIMIT 1
            """,
            [worker_id],
        )
        active = cursor.fetchone()
        if active:
            cursor.execute(
                """
                INSERT INTO worker_notifications (worker_id, notif_type, title, message, is_read)
                VALUES (%s, %s, %s, %s, %s)
                """,
                [
                    worker_id,
                    "job",
                    "New Job Available",
                    f"A {active[0]} request matches your profile.",
                    False,
                ],
            )

        # Latest review notification.
        cursor.execute(
            """
            SELECT rating
            FROM reviews
            WHERE worker_id = %s
            ORDER BY created_at DESC
            LIMIT 1
            """,
            [worker_id],
        )
        latest_review = cursor.fetchone()
        if latest_review:
            rating = float(latest_review[0] or 0)
            cursor.execute(
                """
                INSERT INTO worker_notifications (worker_id, notif_type, title, message, is_read)
                VALUES (%s, %s, %s, %s, %s)
                """,
                [
                    worker_id,
                    "review",
                    "New Review",
                    f"You received a {rating:.1f}-star review from a customer.",
                    True,
                ],
            )


@csrf_exempt
@require_http_methods(["GET"])
def notifications(request):
    """
    GET /api/workers/notifications/
    Returns worker notifications from database.
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Unauthorized. User ID not found",
                    "code": "UNAUTHORIZED",
                },
                status=401,
            )

        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse(
                {"status": "success", "data": {"notifications": [], "count": 0}},
                status=200,
            )

        _ensure_worker_notifications_table()
        _seed_worker_notifications(worker_id)

        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, notif_type, title, message, is_read, created_at
                FROM worker_notifications
                WHERE worker_id = %s
                ORDER BY created_at DESC
                LIMIT 100
                """,
                [worker_id],
            )
            rows = cursor.fetchall()

        items = []
        unread_count = 0
        for row in rows:
            is_read = bool(row[4])
            if not is_read:
                unread_count += 1
            created_at = row[5]
            items.append(
                {
                    "id": int(row[0]),
                    "type": row[1],
                    "title": row[2],
                    "message": row[3],
                    "is_read": is_read,
                    "created_at": created_at.isoformat()
                    if isinstance(created_at, datetime)
                    else str(created_at),
                }
            )

        return JsonResponse(
            {
                "status": "success",
                "data": {
                    "notifications": items,
                    "count": len(items),
                    "unread_count": unread_count,
                },
            },
            status=200,
        )

    except Exception as e:
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to fetch worker notifications",
                "code": "NOTIFICATIONS_ERROR",
                "details": str(e),
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["POST"])
def notifications_mark_all_read(request):
    """
    POST /api/workers/notifications/mark-all-read/
    Marks all worker notifications as read.
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Unauthorized. User ID not found",
                    "code": "UNAUTHORIZED",
                },
                status=401,
            )

        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Worker profile not found",
                    "code": "WORKER_NOT_FOUND",
                },
                status=404,
            )

        _ensure_worker_notifications_table()

        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE worker_notifications
                SET is_read = TRUE
                WHERE worker_id = %s
                """,
                [worker_id],
            )

        return JsonResponse(
            {
                "status": "success",
                "message": "All notifications marked as read",
            },
            status=200,
        )

    except Exception as e:
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to mark notifications as read",
                "code": "NOTIFICATIONS_MARK_READ_ERROR",
                "details": str(e),
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["GET", "POST"])
def bank_details(request):
    """
    GET /api/workers/bank-details/
    POST /api/workers/bank-details/
    Persist and fetch worker bank account details.
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Unauthorized. User ID not found",
                    "code": "UNAUTHORIZED",
                },
                status=401,
            )

        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Worker profile not found",
                    "code": "WORKER_NOT_FOUND",
                },
                status=404,
            )

        _ensure_worker_bank_details_table()

        if request.method == "GET":
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT account_holder_name, bank_name, account_number, ifsc_code, upi_id, is_verified
                    FROM worker_bank_details
                    WHERE worker_id = %s
                    """,
                    [worker_id],
                )
                row = cursor.fetchone()

            if not row:
                return JsonResponse(
                    {
                        "status": "success",
                        "data": {
                            "exists": False,
                            "account_holder_name": "",
                            "bank_name": "",
                            "account_number": "",
                            "ifsc_code": "",
                            "upi_id": "",
                            "is_verified": False,
                        },
                    },
                    status=200,
                )

            account_number = str(row[2] or "")
            masked_account_number = (
                f"{'*' * max(0, len(account_number) - 4)}{account_number[-4:]}"
                if account_number
                else ""
            )

            return JsonResponse(
                {
                    "status": "success",
                    "data": {
                        "exists": True,
                        "account_holder_name": row[0] or "",
                        "bank_name": row[1] or "",
                        "account_number": account_number,
                        "masked_account_number": masked_account_number,
                        "ifsc_code": row[3] or "",
                        "upi_id": row[4] or "",
                        "is_verified": bool(row[5]),
                    },
                },
                status=200,
            )

        payload = json.loads(request.body or "{}")
        account_holder_name = str(payload.get("account_holder_name", "")).strip()
        bank_name = str(payload.get("bank_name", "")).strip()
        account_number = str(payload.get("account_number", "")).strip()
        ifsc_code = str(payload.get("ifsc_code", "")).strip().upper()
        upi_id = str(payload.get("upi_id", "")).strip()
        has_full_bank_details = bool(
            account_holder_name and bank_name and account_number and ifsc_code
        )

        if not has_full_bank_details and not upi_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Provide either full bank details or a UPI ID",
                    "code": "VALIDATION_ERROR",
                },
                status=400,
            )

        # TODO: Replace IFSC-only validation with Cashfree penny drop for production.
        # Cashfree sandbox: https://dev.cashfree.com/bank-account-verification
        # Requires CASHFREE_APP_ID and CASHFREE_SECRET_KEY in .env
        if has_full_bank_details:
            ifsc_validation = validate_ifsc(ifsc_code)
            if not ifsc_validation.get("valid"):
                return JsonResponse(
                    {
                        "status": "error",
                        "message": ifsc_validation.get("message", "Invalid IFSC code"),
                        "code": "INVALID_IFSC",
                    },
                    status=400,
                )

            if ifsc_validation.get("bank"):
                bank_name = str(ifsc_validation.get("bank")).strip()

        vendor = connection.vendor
        with connection.cursor() as cursor:
            if vendor == "postgresql":
                cursor.execute(
                    """
                    INSERT INTO worker_bank_details (
                        worker_id, account_holder_name, bank_name, account_number, ifsc_code, upi_id, updated_at
                    ) VALUES (%s, %s, %s, %s, %s, %s, NOW())
                    ON CONFLICT (worker_id)
                    DO UPDATE SET
                        account_holder_name = EXCLUDED.account_holder_name,
                        bank_name = EXCLUDED.bank_name,
                        account_number = EXCLUDED.account_number,
                        ifsc_code = EXCLUDED.ifsc_code,
                        upi_id = EXCLUDED.upi_id,
                        updated_at = NOW()
                    """,
                    [
                        worker_id,
                        account_holder_name,
                        bank_name,
                        account_number,
                        ifsc_code,
                        upi_id or None,
                    ],
                )
            else:
                cursor.execute(
                    """
                    INSERT INTO worker_bank_details (
                        worker_id, account_holder_name, bank_name, account_number, ifsc_code, upi_id, updated_at
                    ) VALUES (%s, %s, %s, %s, %s, %s, CURRENT_TIMESTAMP)
                    ON CONFLICT(worker_id)
                    DO UPDATE SET
                        account_holder_name = excluded.account_holder_name,
                        bank_name = excluded.bank_name,
                        account_number = excluded.account_number,
                        ifsc_code = excluded.ifsc_code,
                        upi_id = excluded.upi_id,
                        updated_at = CURRENT_TIMESTAMP
                    """,
                    [
                        worker_id,
                        account_holder_name,
                        bank_name,
                        account_number,
                        ifsc_code,
                        upi_id or None,
                    ],
                )

        return JsonResponse(
            {
                "status": "success",
                "message": "Bank details saved successfully",
                "data": {
                    "account_holder_name": account_holder_name,
                    "bank_name": bank_name,
                    "account_number": account_number,
                    "ifsc_code": ifsc_code,
                    "upi_id": upi_id,
                    "is_verified": False,
                },
            },
            status=200,
        )

    except Exception as e:
        print(f"Error handling worker bank details: {e}")
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to process bank details",
                "code": "BANK_DETAILS_ERROR",
                "details": str(e),
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["POST"])
def submit_worker_upi_qr(request):
    """
    POST /api/workers/submit-upi-qr/
    Parse uploaded UPI QR and save UPI ID for future worker payouts.
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Unauthorized. User ID not found",
                    "code": "UNAUTHORIZED",
                },
                status=401,
            )

        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Worker profile not found",
                    "code": "WORKER_NOT_FOUND",
                },
                status=404,
            )

        qr_image = request.FILES.get('qr_image')
        if not qr_image:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "No QR image uploaded",
                    "code": "MISSING_FILE",
                },
                status=400,
            )

        result = extract_upi_from_qr(qr_image)
        if not result.get('success'):
            return JsonResponse(
                {
                    "status": "error",
                    "message": result.get('error', 'Could not parse QR code'),
                    "code": "INVALID_UPI_QR",
                },
                status=400,
            )

        _ensure_worker_upi_details_table()
        _ensure_worker_bank_details_table()
        upi_id = result['upi_id']
        upi_name = result.get('name') or ''
        upi_raw = result.get('raw') or ''

        with connection.cursor() as cursor:
            if connection.vendor == 'postgresql':
                cursor.execute(
                    """
                    INSERT INTO worker_upi_details (worker_id, upi_id, upi_name, upi_raw, is_verified, updated_at)
                    VALUES (%s, %s, %s, %s, %s, NOW())
                    ON CONFLICT (worker_id)
                    DO UPDATE SET
                        upi_id = EXCLUDED.upi_id,
                        upi_name = EXCLUDED.upi_name,
                        upi_raw = EXCLUDED.upi_raw,
                        is_verified = EXCLUDED.is_verified,
                        updated_at = NOW()
                    """,
                    [worker_id, upi_id, upi_name or None, upi_raw or None, True],
                )
                cursor.execute(
                    """
                    UPDATE worker_bank_details
                    SET upi_id = %s, updated_at = NOW()
                    WHERE worker_id = %s
                    """,
                    [upi_id, worker_id],
                )
            else:
                cursor.execute(
                    """
                    INSERT INTO worker_upi_details (worker_id, upi_id, upi_name, upi_raw, is_verified, updated_at)
                    VALUES (%s, %s, %s, %s, %s, CURRENT_TIMESTAMP)
                    ON CONFLICT(worker_id)
                    DO UPDATE SET
                        upi_id = excluded.upi_id,
                        upi_name = excluded.upi_name,
                        upi_raw = excluded.upi_raw,
                        is_verified = excluded.is_verified,
                        updated_at = CURRENT_TIMESTAMP
                    """,
                    [worker_id, upi_id, upi_name or None, upi_raw or None, 1],
                )
                cursor.execute(
                    """
                    UPDATE worker_bank_details
                    SET upi_id = %s, updated_at = CURRENT_TIMESTAMP
                    WHERE worker_id = %s
                    """,
                    [upi_id, worker_id],
                )

        return JsonResponse(
            {
                "status": "success",
                "message": "UPI ID saved successfully",
                "data": {
                    "upi_id": upi_id,
                    "name": upi_name,
                    "verified": True,
                },
            },
            status=200,
        )
    except Exception as e:
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to save worker UPI QR",
                "code": "UPI_QR_SAVE_ERROR",
                "details": str(e),
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["GET", "POST"])
def availability(request):
    """
    GET /api/workers/availability/
    POST /api/workers/availability/
    Manage worker weekly availability schedule.
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Unauthorized. User ID not found",
                    "code": "UNAUTHORIZED",
                },
                status=401,
            )

        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Worker profile not found",
                    "code": "WORKER_NOT_FOUND",
                },
                status=404,
            )

        _ensure_worker_availability_table()

        if request.method == "GET":
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT day_of_week, start_time, end_time, is_available
                    FROM worker_availability
                    WHERE worker_id = %s
                    ORDER BY day_of_week ASC
                    """,
                    [worker_id],
                )
                rows = cursor.fetchall()

            data = [
                {
                    "day_of_week": int(row[0]),
                    "start_time": str(row[1]),
                    "end_time": str(row[2]),
                    "is_available": bool(row[3]),
                }
                for row in rows
            ]
            return JsonResponse({"status": "success", "data": data}, status=200)

        payload = json.loads(request.body or "{}")
        slots = payload.get("availability") or []
        if not isinstance(slots, list):
            return JsonResponse(
                {
                    "status": "error",
                    "message": "availability must be a list",
                    "code": "VALIDATION_ERROR",
                },
                status=400,
            )

        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM worker_availability WHERE worker_id = %s", [worker_id])

            for slot in slots:
                day_of_week = int(slot.get("day_of_week", -1))
                start_time = str(slot.get("start_time", "")).strip()
                end_time = str(slot.get("end_time", "")).strip()
                is_available = bool(slot.get("is_available", False))

                if day_of_week < 0 or day_of_week > 6 or not start_time or not end_time:
                    continue

                if connection.vendor == "postgresql":
                    cursor.execute(
                        """
                        INSERT INTO worker_availability (
                            worker_id, day_of_week, start_time, end_time, is_available, updated_at
                        ) VALUES (%s, %s, %s, %s, %s, NOW())
                        """,
                        [worker_id, day_of_week, start_time, end_time, is_available],
                    )
                else:
                    cursor.execute(
                        """
                        INSERT INTO worker_availability (
                            worker_id, day_of_week, start_time, end_time, is_available, updated_at
                        ) VALUES (%s, %s, %s, %s, %s, CURRENT_TIMESTAMP)
                        """,
                        [worker_id, day_of_week, start_time, end_time, 1 if is_available else 0],
                    )

        return JsonResponse(
            {
                "status": "success",
                "message": "Availability updated successfully",
            },
            status=200,
        )
    except Exception as e:
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to update availability",
                "code": "WORKER_AVAILABILITY_ERROR",
                "details": str(e),
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["GET"])
def validate_ifsc_endpoint(request):
    ifsc_code = str(request.GET.get("ifsc") or "").strip().upper()
    if not ifsc_code:
        return JsonResponse(
            {
                "status": "error",
                "message": "ifsc query parameter is required",
                "code": "MISSING_IFSC",
            },
            status=400,
        )

    # TODO: Replace IFSC-only validation with Cashfree penny drop for production.
    # Cashfree sandbox: https://dev.cashfree.com/bank-account-verification
    # Requires CASHFREE_APP_ID and CASHFREE_SECRET_KEY in .env
    result = validate_ifsc(ifsc_code)
    if not result.get("valid"):
        return JsonResponse(
            {
                "status": "error",
                "message": result.get("message", "Invalid IFSC code"),
                "code": "INVALID_IFSC",
            },
            status=400,
        )

    return JsonResponse({"status": "success", "data": result}, status=200)


@csrf_exempt
@require_http_methods(["GET"])
def profile(request):
    """
    GET /api/workers/profile/
    Fetch current worker's profile including basic info, verification status, availability
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse({
                "status": "error",
                "message": "Unauthorized. User ID not found",
                "code": "UNAUTHORIZED"
            }, status=401)
        
        with connection.cursor() as cursor:
            # Get worker profile
            cursor.execute("""
                SELECT 
                    w.id,
                    w.user_id,
                    w.is_verified,
                    w.verification_status,
                    w.is_available,
                    w.experience_years,
                    w.bio,
                    w.profile_photo,
                    u.name,
                    u.email,
                    u.phone
                FROM workers w
                JOIN users u ON w.user_id = u.id
                WHERE w.user_id = %s
            """, [user_id])
            
            row = cursor.fetchone()
            if not row:
                return JsonResponse({
                    "status": "error",
                    "message": "Worker profile not found",
                    "code": "PROFILE_NOT_FOUND"
                }, status=404)
            
            # Get worker services
            cursor.execute("""
                SELECT 
                    ws.id,
                    ws.service_id,
                    s.service_name,
                    s.base_price,
                    ws.price_override,
                    sc.category_name
                FROM worker_services ws
                JOIN services s ON ws.service_id = s.id
                JOIN service_categories sc ON s.category_id = sc.id
                WHERE ws.worker_id = %s
                ORDER BY sc.category_name, s.service_name
            """, [row[0]])  # row[0] is worker.id
            
            services = []
            for svc_row in cursor.fetchall():
                services.append({
                    "service_id": svc_row[1],
                    "service_name": svc_row[2],
                    "base_price": float(svc_row[3]),
                    "price_override": float(svc_row[4]) if svc_row[4] else None,
                    "category_name": svc_row[5]
                })
        
        return JsonResponse({
            "status": "success",
            "data": {
                "worker_id": row[0],
                "user_id": row[1],
                "name": row[8],
                "email": row[9],
                "phone": row[10],
                "is_verified": row[2],
                "verification_status": row[3] or 'not_started',
                "is_available": row[4],
                "experience_years": row[5],
                "bio": row[6] or "",
                "profile_photo": row[7] or "",
                "services": services
            }
        }, status=200)
    
    except Exception as e:
        print(f"Error fetching worker profile: {e}")
        return JsonResponse({
            "status": "error",
            "message": "Failed to fetch worker profile",
            "code": "PROFILE_ERROR",
            "details": str(e)
        }, status=500)


@csrf_exempt
@require_http_methods(["POST"])
def profile_photo(request):
    """
    POST /api/workers/profile-photo/
    Upload optional worker profile photo and save URL in workers.profile_photo.
    Multipart field name: profile_photo
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Unauthorized. User ID not found",
                    "code": "UNAUTHORIZED",
                },
                status=401,
            )

        uploaded_file = request.FILES.get("profile_photo")
        if not uploaded_file:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "profile_photo file is required",
                    "code": "MISSING_FILE",
                },
                status=400,
            )

        ext = os.path.splitext(uploaded_file.name or "")[1].lower()
        if ext not in {".jpg", ".jpeg", ".png", ".webp"}:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Only jpg, jpeg, png or webp images are allowed",
                    "code": "INVALID_FILE_TYPE",
                },
                status=400,
            )

        filename = f"worker_profiles/{user_id}_{uuid.uuid4().hex}{ext}"
        stored_path = default_storage.save(filename, uploaded_file)
        media_relative = f"{settings.MEDIA_URL.rstrip('/')}/{stored_path}"
        absolute_url = request.build_absolute_uri(media_relative)

        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE workers SET profile_photo = %s WHERE user_id = %s",
                [absolute_url, user_id],
            )
            if cursor.rowcount == 0:
                return JsonResponse(
                    {
                        "status": "error",
                        "message": "Worker profile not found",
                        "code": "PROFILE_NOT_FOUND",
                    },
                    status=404,
                )

        return JsonResponse(
            {
                "status": "success",
                "message": "Profile photo updated",
                "data": {
                    "profile_photo": absolute_url,
                },
            },
            status=200,
        )
    except Exception as e:
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to upload profile photo",
                "code": "PROFILE_PHOTO_UPLOAD_ERROR",
                "details": str(e),
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["GET", "POST"])
def services_selection(request):
    """
    GET /api/workers/services/
    POST /api/workers/services/
    Manage services provided by the current worker.
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Unauthorized. User ID not found",
                    "code": "UNAUTHORIZED",
                },
                status=401,
            )

        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Worker profile not found",
                    "code": "WORKER_NOT_FOUND",
                },
                status=404,
            )

        if request.method == "GET":
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT
                        s.id,
                        s.service_name,
                        s.base_price,
                        s.category_id,
                        sc.category_name,
                        ws.id IS NOT NULL AS is_selected,
                        ws.price_override
                    FROM services s
                    JOIN service_categories sc ON sc.id = s.category_id
                    LEFT JOIN worker_services ws
                        ON ws.service_id = s.id AND ws.worker_id = %s
                    ORDER BY sc.category_name, s.service_name
                    """,
                    [worker_id],
                )

                items = []
                selected_service_ids = []
                for row in cursor.fetchall():
                    is_selected = bool(row[5])
                    if is_selected:
                        selected_service_ids.append(int(row[0]))
                    items.append(
                        {
                            "service_id": int(row[0]),
                            "service_name": row[1],
                            "base_price": float(row[2]) if row[2] is not None else 0.0,
                            "category_id": int(row[3]) if row[3] is not None else None,
                            "category_name": row[4],
                            "is_selected": is_selected,
                            "price_override": float(row[6]) if row[6] is not None else None,
                        }
                    )

            return JsonResponse(
                {
                    "status": "success",
                    "data": {
                        "worker_id": worker_id,
                        "selected_service_ids": selected_service_ids,
                        "services": items,
                    },
                },
                status=200,
            )

        payload = json.loads(request.body or "{}")
        service_ids = payload.get("service_ids")
        if not isinstance(service_ids, list):
            return JsonResponse(
                {
                    "status": "error",
                    "message": "service_ids must be a list",
                    "code": "VALIDATION_ERROR",
                },
                status=400,
            )

        normalized_service_ids = []
        seen = set()
        for raw_id in service_ids:
            try:
                service_id = int(raw_id)
            except (TypeError, ValueError):
                continue
            if service_id <= 0 or service_id in seen:
                continue
            seen.add(service_id)
            normalized_service_ids.append(service_id)

        with connection.cursor() as cursor:
            valid_service_ids = set()
            if normalized_service_ids:
                placeholders = ", ".join(["%s"] * len(normalized_service_ids))
                cursor.execute(
                    f"SELECT id FROM services WHERE id IN ({placeholders})",
                    normalized_service_ids,
                )
                valid_service_ids = {int(row[0]) for row in cursor.fetchall()}

            cursor.execute("DELETE FROM worker_services WHERE worker_id = %s", [worker_id])

            inserted = 0
            for service_id in normalized_service_ids:
                if service_id not in valid_service_ids:
                    continue
                cursor.execute(
                    """
                    INSERT INTO worker_services (worker_id, service_id, price_override)
                    VALUES (%s, %s, NULL)
                    """,
                    [worker_id, service_id],
                )
                inserted += 1

        return JsonResponse(
            {
                "status": "success",
                "message": "Worker services updated",
                "data": {
                    "worker_id": worker_id,
                    "selected_count": inserted,
                    "service_ids": sorted(valid_service_ids.intersection(set(normalized_service_ids))),
                },
            },
            status=200,
        )

    except Exception as e:
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to update worker services",
                "code": "WORKER_SERVICES_ERROR",
                "details": str(e),
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["GET"])
def jobs(request):
    """
    GET /api/workers/jobs?filter=day|week|month
    Fetch current worker's scheduled bookings
    
    Query parameters:
    - filter: 'day' (default), 'week', or 'month'
    - status: optional filter by job status (confirmed, pending, completed, cancelled)
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse({
                "status": "error",
                "message": "Unauthorized. User ID not found",
                "code": "UNAUTHORIZED"
            }, status=401)
        
        filter_type = request.GET.get('filter', 'day').lower()
        status_filter = request.GET.get('status', '').lower()
        
        # Validate filter type
        if filter_type not in ['day', 'week', 'month']:
            filter_type = 'day'
        
        # Calculate date range
        now = datetime.now()
        today_start = datetime(now.year, now.month, now.day, 0, 0, 0)  # Midnight today
        
        if filter_type == 'day':
            # Today: midnight to midnight
            start_date = today_start
            end_date = today_start.replace(hour=23, minute=59, second=59)
        elif filter_type == 'week':
            # Next 7 days from today
            start_date = today_start
            end_date = (today_start + timedelta(days=7)).replace(hour=23, minute=59, second=59)
        else:  # month
            # Next 30 days from today
            start_date = today_start
            end_date = (today_start + timedelta(days=30)).replace(hour=23, minute=59, second=59)
        
        with connection.cursor() as cursor:
            # First, get worker_id from user_id
            cursor.execute("SELECT id FROM workers WHERE user_id = %s", [user_id])
            worker_row = cursor.fetchone()
            if not worker_row:
                return JsonResponse({
                    "status": "success",
                    "data": {
                        "filter": filter_type,
                        "jobs": []
                    }
                }, status=200)
            
            worker_id = worker_row[0]
            
            # Query bookings for this worker
            query = """
                SELECT 
                    b.id,
                    b.service_id,
                    b.user_id,
                    b.scheduled_date,
                    b.status,
                    b.total_amount,
                    s.service_name,
                    u.name as customer_name,
                    u.phone as customer_phone,
                    sc.category_name,
                    COALESCE(ul_customer.address, '') as customer_address,
                    ul_customer.latitude as customer_latitude,
                    ul_customer.longitude as customer_longitude,
                    CASE
                        WHEN ul_customer.latitude IS NOT NULL
                         AND ul_customer.longitude IS NOT NULL
                         AND ul_worker.latitude IS NOT NULL
                         AND ul_worker.longitude IS NOT NULL
                        THEN (
                            6371 * acos(
                                cos(radians(ul_worker.latitude))
                                * cos(radians(ul_customer.latitude))
                                * cos(radians(ul_customer.longitude) - radians(ul_worker.longitude))
                                + sin(radians(ul_worker.latitude))
                                * sin(radians(ul_customer.latitude))
                            )
                        )
                        ELSE NULL
                    END as customer_distance_km
                FROM bookings b
                JOIN services s ON b.service_id = s.id
                JOIN service_categories sc ON s.category_id = sc.id
                JOIN users u ON b.user_id = u.id
                JOIN workers w ON w.id = b.worker_id
                LEFT JOIN user_locations ul_customer ON ul_customer.user_id = b.user_id
                LEFT JOIN user_locations ul_worker ON ul_worker.user_id = w.user_id
                WHERE b.worker_id = %s
            """
            
            params = [worker_id]
            
            # Add date range filter
            query += " AND b.scheduled_date >= %s AND b.scheduled_date <= %s"
            params.extend([start_date, end_date])
            
            # Add status filter if provided
            if status_filter:
                query += " AND LOWER(b.status) = %s"
                params.append(status_filter)
            else:
                query += " AND LOWER(b.status) IN (%s, %s, %s, %s)"
                params.extend(["pending", "confirmed", "in_progress", "awaiting_payment"])
            
            query += " ORDER BY b.scheduled_date ASC"
            
            cursor.execute(query, params)
            
            jobs_list = []
            for row in cursor.fetchall():
                jobs_list.append({
                    "job_id": row[0],
                    "service_id": row[1],
                    "customer_id": row[2],
                    "service_name": row[6],
                    "customer_name": row[7],
                    "customer_phone": row[8],
                    "scheduled_time": row[3].isoformat() if isinstance(row[3], datetime) else str(row[3]),
                    "status": row[4],
                    "amount": float(row[5]),
                    "category_name": row[9],
                    "address": row[10],
                    "customer_latitude": float(row[11]) if row[11] is not None else None,
                    "customer_longitude": float(row[12]) if row[12] is not None else None,
                    "customer_distance_km": float(row[13]) if row[13] is not None else None,
                })
        
        return JsonResponse({
            "status": "success",
            "data": {
                "filter": filter_type,
                "job_count": len(jobs_list),
                "jobs": jobs_list
            }
        }, status=200)
    
    except Exception as e:
        print(f"Error fetching worker jobs: {e}")
        return JsonResponse({
            "status": "error",
            "message": "Failed to fetch worker jobs",
            "code": "JOBS_ERROR",
            "details": str(e)
        }, status=500)


@csrf_exempt
@require_http_methods(["GET"])
def past_services(request):
    """
    GET /api/workers/past-services/?limit=50
    Fetch completed jobs history used by Past Services screen and payouts view.
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Unauthorized. User ID not found",
                    "code": "UNAUTHORIZED",
                },
                status=401,
            )

        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse(
                {"status": "success", "data": {"services": [], "count": 0}},
                status=200,
            )

        raw_limit = request.GET.get("limit", "50")
        try:
            limit = max(1, min(200, int(raw_limit)))
        except ValueError:
            limit = 50

        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    b.id,
                    s.service_name,
                    u.name,
                    u.phone,
                    b.scheduled_date,
                    b.total_amount,
                    b.status,
                    COALESCE(p.payment_status, 'unknown') AS payment_status
                FROM bookings b
                JOIN services s ON b.service_id = s.id
                JOIN users u ON b.user_id = u.id
                LEFT JOIN payments p ON p.booking_id = b.id
                WHERE b.worker_id = %s
                  AND LOWER(b.status) = 'completed'
                ORDER BY b.scheduled_date DESC
                LIMIT %s
                """,
                [worker_id, limit],
            )

            rows = cursor.fetchall()

        admin_fee_rate = 0.02
        services = []
        for row in rows:
            gross_amount = float(row[5] or 0)
            admin_fee = round(gross_amount * admin_fee_rate, 2)
            worker_amount = round(gross_amount - admin_fee, 2)

            scheduled_at = row[4]
            if isinstance(scheduled_at, datetime):
                scheduled_iso = scheduled_at.isoformat()
            else:
                scheduled_iso = str(scheduled_at)

            services.append(
                {
                    "booking_id": row[0],
                    "service_name": row[1],
                    "customer_name": row[2],
                    "customer_phone": row[3],
                    "scheduled_time": scheduled_iso,
                    "status": row[6],
                    "payment_status": row[7],
                    "gross_amount": gross_amount,
                    "admin_fee": admin_fee,
                    "worker_amount": worker_amount,
                }
            )

        return JsonResponse(
            {
                "status": "success",
                "data": {
                    "services": services,
                    "count": len(services),
                },
            },
            status=200,
        )

    except Exception as e:
        print(f"Error fetching worker past services: {e}")
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to fetch worker past services",
                "code": "PAST_SERVICES_ERROR",
                "details": str(e),
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["GET"])
def stats(request):
    """
    GET /api/workers/stats/
    Fetch worker statistics: total earnings, today's jobs count, average rating, reviews count
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse({
                "status": "error",
                "message": "Unauthorized. User ID not found",
                "code": "UNAUTHORIZED"
            }, status=401)
        
        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse({
                "status": "success",
                "data": {
                    "total_earnings": 0,
                    "today_jobs_count": 0,
                    "average_rating": 0,
                    "total_reviews": 0,
                    "completed_jobs": 0,
                }
            }, status=200)

        today = datetime.now().date()

        with connection.cursor() as cursor:
            # Total earnings from completed bookings
            cursor.execute(
                """
                SELECT COALESCE(SUM(total_amount), 0)
                FROM bookings
                WHERE worker_id = %s
                  AND LOWER(status) = 'completed'
                """,
                [worker_id],
            )
            total_earnings = float(cursor.fetchone()[0] or 0)

            # Today's jobs count (all active/relevant statuses)
            cursor.execute(
                """
                SELECT COUNT(*)
                FROM bookings
                WHERE worker_id = %s
                  AND DATE(scheduled_date) = %s
                  AND LOWER(status) = ANY(%s)
                """,
                [worker_id, today, list(ACTIVE_JOB_STATUSES)],
            )
            today_jobs_count = int(cursor.fetchone()[0] or 0)

            # Average rating and review count
            cursor.execute(
                """
                SELECT COALESCE(AVG(rating), 0), COUNT(*)
                FROM reviews
                WHERE worker_id = %s
                """,
                [worker_id],
            )
            avg_rating_row = cursor.fetchone()
            average_rating = float(avg_rating_row[0] or 0)
            total_reviews = int(avg_rating_row[1] or 0)

            # Completed jobs count
            cursor.execute(
                """
                SELECT COUNT(*)
                FROM bookings
                WHERE worker_id = %s
                  AND LOWER(status) = 'completed'
                """,
                [worker_id],
            )
            completed_jobs = int(cursor.fetchone()[0] or 0)
        
        return JsonResponse({
            "status": "success",
            "data": {
                "total_earnings": total_earnings,
                "today_jobs_count": today_jobs_count,
                "average_rating": round(average_rating, 2),
                "total_reviews": total_reviews,
                "completed_jobs": completed_jobs
            }
        }, status=200)
    
    except Exception as e:
        print(f"Error fetching worker stats: {e}")
        return JsonResponse({
            "status": "error",
            "message": "Failed to fetch worker stats",
            "code": "STATS_ERROR",
            "details": str(e)
        }, status=500)


@csrf_exempt
@require_http_methods(["GET"])
def earnings_summary(request):
    """
    GET /api/workers/earnings-summary/?months=6
    Returns month-wise real earnings, upcoming transfer and pending deductions.
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Unauthorized. User ID not found",
                    "code": "UNAUTHORIZED",
                },
                status=401,
            )

        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse(
                {
                    "status": "success",
                    "data": {
                        "months": [],
                        "current_month_earnings": 0,
                        "upcoming_transfer": 0,
                        "pending_deductions": 0,
                        "deductions_breakdown": [],
                    },
                },
                status=200,
            )

        raw_months = request.GET.get("months", "6")
        try:
            months_count = max(1, min(12, int(raw_months)))
        except ValueError:
            months_count = 6

        now = datetime.now()
        month_anchor = datetime(now.year, now.month, 1)

        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT MAX(scheduled_date)
                FROM bookings
                WHERE worker_id = %s
                  AND LOWER(status) = 'completed'
                """,
                [worker_id],
            )
            latest_completed = cursor.fetchone()[0]

        if latest_completed:
            latest_dt = latest_completed
            if isinstance(latest_dt, str):
                latest_dt = datetime.fromisoformat(latest_dt)
            latest_month = datetime(latest_dt.year, latest_dt.month, 1)
            if latest_month > month_anchor:
                month_anchor = latest_month

        month_start = month_anchor
        start_month = month_start - timedelta(days=32 * (months_count - 1))
        start_month = datetime(start_month.year, start_month.month, 1)

        with connection.cursor() as cursor:
            # Keep SQL database-agnostic (SQLite/Postgres) by aggregating months in Python.
            cursor.execute(
                """
                SELECT scheduled_date, total_amount
                FROM bookings
                WHERE worker_id = %s
                  AND scheduled_date >= %s
                  AND LOWER(status) = 'completed'
                ORDER BY scheduled_date ASC
                """,
                [worker_id, start_month],
            )
            rows = cursor.fetchall()

            monthly_map = {}
            for scheduled_date, total_amount in rows:
                dt = scheduled_date
                if isinstance(dt, str):
                    dt = datetime.fromisoformat(dt)
                key = (dt.year, dt.month)
                monthly_map[key] = float(monthly_map.get(key, 0)) + float(total_amount or 0)

            admin_fee_rate = 0.02
            months = []
            cursor_month = start_month
            for _ in range(months_count):
                key = (cursor_month.year, cursor_month.month)
                gross_earnings = float(monthly_map.get(key, 0))
                admin_fee = round(gross_earnings * admin_fee_rate, 2)
                worker_earnings = round(gross_earnings - admin_fee, 2)
                months.append(
                    {
                        "label": cursor_month.strftime("%b"),
                        "year": cursor_month.year,
                        "month": cursor_month.month,
                        # Keep `earnings` as worker net amount for Flutter compatibility.
                        "earnings": worker_earnings,
                        "gross_earnings": gross_earnings,
                        "admin_fee": admin_fee,
                    }
                )

                next_month = cursor_month.month + 1
                next_year = cursor_month.year
                if next_month == 13:
                    next_month = 1
                    next_year += 1
                cursor_month = datetime(next_year, next_month, 1)

            current_month_earnings = months[-1]["earnings"] if months else 0
            current_month_admin_fee = months[-1]["admin_fee"] if months else 0
            upcoming_transfer = current_month_earnings

            # Keep cancellation count for visibility (does not reduce payout).
            next_month = month_start.month + 1
            next_month_year = month_start.year
            if next_month == 13:
                next_month = 1
                next_month_year += 1
            next_month_start = datetime(next_month_year, next_month, 1)

            cursor.execute(
                """
                SELECT COUNT(*)
                FROM bookings
                WHERE worker_id = %s
                  AND scheduled_date >= %s
                  AND scheduled_date < %s
                  AND LOWER(status) = 'cancelled'
                """,
                [worker_id, month_start, next_month_start],
            )
            cancelled_count = int(cursor.fetchone()[0] or 0)

            pending_deductions = current_month_admin_fee

            deductions_breakdown = [
                {
                    "title": "Platform Commission",
                    "amount": current_month_admin_fee,
                    "description": "2% admin fee on this month completed earnings",
                },
            ]

        return JsonResponse(
            {
                "status": "success",
                "data": {
                    "months": months,
                    "current_month_earnings": current_month_earnings,
                    "upcoming_transfer": upcoming_transfer,
                    "pending_deductions": pending_deductions,
                    "deductions_breakdown": deductions_breakdown,
                    "cancelled_count_current_month": cancelled_count,
                },
            },
            status=200,
        )
    except Exception as e:
        print(f"Error fetching worker earnings summary: {e}")
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to fetch worker earnings summary",
                "code": "EARNINGS_SUMMARY_ERROR",
                "details": str(e),
            },
            status=500,
        )
