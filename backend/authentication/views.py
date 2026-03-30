from django.shortcuts import render
from django.http import JsonResponse
from django.db import connection
from django.conf import settings
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
import json
import random
import uuid
from datetime import timedelta
from django.utils import timezone
from .auth_utils import hash_password, verify_password, validate_email, validate_phone, validate_password
from .sms_service import send_otp_sms

# Create your views here.

OTP_EXPIRY_SECONDS = 300


def _ensure_auth_otp_table():
    """Create persistent OTP session table (SQLite/Postgres compatible)."""
    with connection.cursor() as cursor:
        if connection.vendor == "postgresql":
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS auth_otp_sessions (
                    session_id VARCHAR(64) PRIMARY KEY,
                    email VARCHAR(255) NOT NULL,
                    role VARCHAR(50) NOT NULL,
                    action VARCHAR(20) NOT NULL,
                    otp VARCHAR(10) NOT NULL,
                    attempts INT NOT NULL DEFAULT 0,
                    expires_at TIMESTAMP NOT NULL,
                    payload TEXT NULL,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )
        else:
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS auth_otp_sessions (
                    session_id VARCHAR(64) PRIMARY KEY,
                    email TEXT NOT NULL,
                    role TEXT NOT NULL,
                    action TEXT NOT NULL,
                    otp TEXT NOT NULL,
                    attempts INTEGER NOT NULL DEFAULT 0,
                    expires_at DATETIME NOT NULL,
                    payload TEXT NULL,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )


def _cleanup_expired_otp_sessions():
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DELETE FROM auth_otp_sessions
            WHERE expires_at < %s
            """,
            [timezone.now()],
        )


def _create_otp_session(session_id, email, role, action, otp, expires_at, payload):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO auth_otp_sessions (session_id, email, role, action, otp, attempts, expires_at, payload)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,
            [
                session_id,
                email,
                role,
                action,
                otp,
                0,
                expires_at,
                json.dumps(payload),
            ],
        )


def _get_otp_session(session_id):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT session_id, email, role, action, otp, attempts, expires_at, payload
            FROM auth_otp_sessions
            WHERE session_id = %s
            """,
            [session_id],
        )
        row = cursor.fetchone()

    if not row:
        return None

    payload_raw = row[7] or "{}"
    try:
        parsed_payload = json.loads(payload_raw)
    except json.JSONDecodeError:
        parsed_payload = {}

    return {
        "session_id": row[0],
        "email": row[1],
        "role": row[2],
        "action": row[3],
        "otp": row[4],
        "attempts": int(row[5] or 0),
        "expires_at": row[6],
        "payload": parsed_payload,
    }


def _update_otp_attempts(session_id, attempts):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            UPDATE auth_otp_sessions
            SET attempts = %s
            WHERE session_id = %s
            """,
            [attempts, session_id],
        )


def _refresh_otp_session(session_id, otp, expires_at):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            UPDATE auth_otp_sessions
            SET otp = %s, expires_at = %s, attempts = 0
            WHERE session_id = %s
            """,
            [otp, expires_at, session_id],
        )


def _delete_otp_session(session_id):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            DELETE FROM auth_otp_sessions
            WHERE session_id = %s
            """,
            [session_id],
        )


def _generate_demo_otp():
    return f"{random.randint(0, 999999):06d}"


def _build_user_payload(user_tuple):
    return {
        "id": user_tuple[0],
        "email": user_tuple[1],
        "name": user_tuple[2],
        "role": user_tuple[4],
    }


def _ensure_worker_profile_row(user_id, name=""):
    """Guarantee a workers-table row exists for a worker-role account."""
    with connection.cursor() as cursor:
        cursor.execute("SELECT id FROM workers WHERE user_id = %s", [user_id])
        if cursor.fetchone():
            return

        cursor.execute(
            """
            INSERT INTO workers (user_id, is_verified, is_available, experience_years, bio, profile_photo)
            VALUES (%s, FALSE, TRUE, 0, %s, '')
            """,
            [user_id, f"{(name or 'Worker').strip()} worker profile"],
        )


def _create_user_record(name, email, phone, password, role):
    password_hash = hash_password(password)
    with connection.cursor() as cursor:
        cursor.execute("SELECT id FROM users WHERE email = %s", [email])
        if cursor.fetchone():
            return None, JsonResponse(
                {
                    "status": "error",
                    "message": "Email already registered",
                    "code": "EMAIL_EXISTS",
                },
                status=400,
            )

        cursor.execute(
            """
            INSERT INTO users (name, email, phone, password_hash, role, created_at)
            VALUES (%s, %s, %s, %s, %s, NOW())
            RETURNING id, email, name, password_hash, role
            """,
            [name, email, phone, password_hash, role],
        )
        user = cursor.fetchone()

    if str(role).strip().lower() == "worker":
        _ensure_worker_profile_row(user[0], user[2])

    return user, None


def _validate_registration_payload(data):
    name = data.get("name", "").strip()
    email = data.get("email", "").strip()
    phone = data.get("phone", "").strip()
    password = data.get("password", "")
    role = data.get("role", "customer").strip().lower()

    if not all([name, email, phone, password]):
        return None, JsonResponse(
            {
                "status": "error",
                "message": "All fields are required",
                "code": "MISSING_FIELDS",
            },
            status=400,
        )

    if role not in ["customer", "worker"]:
        return None, JsonResponse(
            {
                "status": "error",
                "message": "Role must be either customer or worker",
                "code": "INVALID_ROLE",
            },
            status=400,
        )

    if not validate_email(email):
        return None, JsonResponse(
            {
                "status": "error",
                "message": "Invalid email format",
                "code": "INVALID_EMAIL",
            },
            status=400,
        )

    if not validate_phone(phone):
        return None, JsonResponse(
            {
                "status": "error",
                "message": "Invalid phone number. Please enter a 10-digit number",
                "code": "INVALID_PHONE",
            },
            status=400,
        )

    is_valid, msg = validate_password(password)
    if not is_valid:
        return None, JsonResponse(
            {
                "status": "error",
                "message": msg,
                "code": "WEAK_PASSWORD",
            },
            status=400,
        )

    return {
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        "role": role,
    }, None


def _validate_login_payload(data):
    email = data.get("email", "").strip()
    password = data.get("password", "")
    role = data.get("role", "").strip().lower()

    if not email or not password:
        return None, JsonResponse(
            {
                "status": "error",
                "message": "Email and password are required",
                "code": "MISSING_FIELDS",
            },
            status=400,
        )

    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT id, email, name, password_hash, role, phone FROM users WHERE email = %s",
            [email],
        )
        user = cursor.fetchone()

    if not user or not verify_password(password, user[3]):
        return None, JsonResponse(
            {
                "status": "error",
                "message": "Invalid email or password",
                "code": "INVALID_CREDENTIALS",
            },
            status=401,
        )

    user_role = (user[4] or "").strip().lower()
    if role and role != user_role:
        return None, JsonResponse(
            {
                "status": "error",
                "message": "Invalid role for this account",
                "code": "ROLE_MISMATCH",
            },
            status=403,
        )

    return {
        "id": user[0],
        "email": user[1],
        "name": user[2],
        "password_hash": user[3],
        "role": user[4],
        "phone": user[5],
    }, None


@csrf_exempt
@require_http_methods(["POST"])
def otp_start(request):
    """
    Start an OTP challenge for register/login.
    Expected JSON payload:
    {
        "action": "register" | "login",
        "role": "customer" | "worker",
        "name": "...",        # register only
        "email": "...",
        "phone": "...",       # register only
        "password": "..."
    }
    """
    try:
        data = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse(
            {
                "status": "error",
                "message": "Invalid JSON format",
                "code": "INVALID_JSON",
            },
            status=400,
        )

    try:
        action = (data.get("action") or "").strip().lower()
        print(f"[OTP START] action={action} sms_enabled={getattr(settings, 'SMS_OTP_ENABLED', False)}")
        if action not in ["register", "login"]:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Action must be register or login",
                    "code": "INVALID_ACTION",
                },
                status=400,
            )

        _ensure_auth_otp_table()
        _cleanup_expired_otp_sessions()

        otp = _generate_demo_otp()
        expires_at = timezone.now() + timedelta(seconds=OTP_EXPIRY_SECONDS)
        session_id = str(uuid.uuid4())

        if action == "register":
            payload, error_response = _validate_registration_payload(data)
            if error_response:
                return error_response

            _create_otp_session(
                session_id=session_id,
                email=payload["email"],
                role=payload["role"],
                action="register",
                otp=otp,
                expires_at=expires_at,
                payload=payload,
            )

            print(
                f"[DEMO OTP] register role={payload['role']} email={payload['email']} otp={otp}"
            )

            # Send OTP via SMS if enabled
            phone_number = payload.get("phone", "")
            sms_result = send_otp_sms(phone_number, otp, purpose="registration")

            response_data = {
                "session_id": session_id,
                "expires_in": OTP_EXPIRY_SECONDS,
                "action": "register",
                "phone": phone_number,
                "sms_status": sms_result,
            }
            if getattr(settings, "OTP_EXPOSE_IN_API", True):
                response_data["otp"] = otp

            return JsonResponse(
                {
                    "status": "success",
                    "message": "OTP sent successfully",
                    "data": response_data,
                },
                status=200,
            )

        login_payload, error_response = _validate_login_payload(data)
        if error_response:
            return error_response

        _create_otp_session(
            session_id=session_id,
            email=login_payload["email"],
            role=login_payload["role"],
            action="login",
            otp=otp,
            expires_at=expires_at,
            payload=login_payload,
        )

        print(
            f"[DEMO OTP] login role={login_payload['role']} email={login_payload['email']} otp={otp}"
        )

        # Send OTP via SMS if enabled
        phone_number = login_payload.get("phone", "")
        sms_result = send_otp_sms(phone_number, otp, purpose="login")

        response_data = {
            "session_id": session_id,
            "expires_in": OTP_EXPIRY_SECONDS,
            "action": "login",
            "phone": phone_number,
            "sms_status": sms_result,
        }
        if getattr(settings, "OTP_EXPOSE_IN_API", True):
            response_data["otp"] = otp

        return JsonResponse(
            {
                "status": "success",
                "message": "OTP sent successfully",
                "data": response_data,
            },
            status=200,
        )
    except Exception as e:
        print(f"OTP start error: {e}")
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to start OTP verification",
                "code": "OTP_START_ERROR",
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["POST"])
def otp_verify(request):
    """
    Verify an OTP challenge and complete register/login.
    Expected JSON payload:
    {
        "session_id": "...",
        "otp": "123456"
    }
    """
    try:
        data = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse(
            {
                "status": "error",
                "message": "Invalid JSON format",
                "code": "INVALID_JSON",
            },
            status=400,
        )

    session_id = (data.get("session_id") or "").strip()
    otp = (data.get("otp") or "").strip()

    if not session_id or not otp:
        return JsonResponse(
            {
                "status": "error",
                "message": "Session id and OTP are required",
                "code": "MISSING_FIELDS",
            },
            status=400,
        )

    _ensure_auth_otp_table()
    _cleanup_expired_otp_sessions()
    otp_session = _get_otp_session(session_id)

    if not otp_session:
        return JsonResponse(
            {
                "status": "error",
                "message": "OTP session expired or invalid",
                "code": "INVALID_SESSION",
            },
            status=400,
        )

    if not getattr(settings, "FIREBASE_PHONE_AUTH_ENABLED", True):
        if otp_session["otp"] != otp:
            attempts = otp_session["attempts"] + 1
            if attempts >= 5:
                _delete_otp_session(session_id)
                return JsonResponse(
                    {
                        "status": "error",
                        "message": "Too many invalid OTP attempts",
                        "code": "OTP_ATTEMPTS_EXCEEDED",
                    },
                    status=429,
                )

            _update_otp_attempts(session_id, attempts)

            return JsonResponse(
                {
                    "status": "error",
                    "message": "Invalid OTP",
                    "code": "INVALID_OTP",
                },
                status=400,
            )

    try:
        payload = otp_session["payload"]
        action = otp_session["action"]

        if action == "register":
            user, error_response = _create_user_record(
                payload["name"],
                payload["email"],
                payload["phone"],
                payload["password"],
                payload["role"],
            )
            if error_response:
                _delete_otp_session(session_id)
                return error_response

            _delete_otp_session(session_id)
            return JsonResponse(
                {
                    "status": "success",
                    "message": "Registration successful",
                    "data": _build_user_payload(user),
                },
                status=201,
            )

        user = (
            payload["id"],
            payload["email"],
            payload["name"],
            payload["password_hash"],
            payload["role"],
        )
        if str(payload.get("role") or "").strip().lower() == "worker":
            _ensure_worker_profile_row(payload["id"], payload.get("name", ""))
        _delete_otp_session(session_id)
        return JsonResponse(
            {
                "status": "success",
                "message": "Login successful",
                "data": _build_user_payload(user),
            },
            status=200,
        )
    except Exception as e:
        print(f"OTP verify error: {e}")
        return JsonResponse(
            {
                "status": "error",
                "message": "OTP verification failed",
                "code": "OTP_VERIFY_ERROR",
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["POST"])
def otp_resend(request):
    """
    Resend OTP for an existing OTP session.
    Expected JSON payload:
    {
        "session_id": "..."
    }
    """
    try:
        data = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse(
            {
                "status": "error",
                "message": "Invalid JSON format",
                "code": "INVALID_JSON",
            },
            status=400,
        )

    session_id = (data.get("session_id") or "").strip()
    if not session_id:
        return JsonResponse(
            {
                "status": "error",
                "message": "Session id is required",
                "code": "MISSING_SESSION_ID",
            },
            status=400,
        )

    _ensure_auth_otp_table()
    _cleanup_expired_otp_sessions()
    otp_session = _get_otp_session(session_id)

    if not otp_session:
        return JsonResponse(
            {
                "status": "error",
                "message": "OTP session expired or invalid",
                "code": "INVALID_SESSION",
            },
            status=400,
        )

    otp = otp_session["otp"]
    expires_at = timezone.now() + timedelta(seconds=OTP_EXPIRY_SECONDS)
    _refresh_otp_session(session_id, otp, expires_at)

    payload = otp_session["payload"]
    print(
        f"[DEMO OTP] resend action={otp_session['action']} role={payload.get('role')} email={payload.get('email')} otp={otp}"
    )

    phone_number = payload.get("phone", "")
    sms_result = send_otp_sms(phone_number, otp, purpose="resend")

    response_data = {
        "session_id": session_id,
        "expires_in": OTP_EXPIRY_SECONDS,
        "phone": phone_number,
        "sms_status": sms_result,
    }
    if getattr(settings, "OTP_EXPOSE_IN_API", True):
        response_data["otp"] = otp

    return JsonResponse(
        {
            "status": "success",
            "message": "OTP resent successfully",
            "data": response_data,
        },
        status=200,
    )

@csrf_exempt
@require_http_methods(["POST"])
def register(request):
    """
    Register a new user
    Expected JSON payload:
    {
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "9876543210",
        "password": "password123",
        "role": "customer"
    }
    """
    try:
        # Parse request body
        data = json.loads(request.body)
        
        # Extract fields
        name = data.get('name', '').strip()
        email = data.get('email', '').strip()
        phone = data.get('phone', '').strip()
        password = data.get('password', '')
        role = data.get('role', 'customer')
        
        # Validation
        if not all([name, email, phone, password]):
            return JsonResponse({
                "status": "error",
                "message": "All fields are required",
                "code": "MISSING_FIELDS"
            }, status=400)
        
        if not validate_email(email):
            return JsonResponse({
                "status": "error",
                "message": "Invalid email format",
                "code": "INVALID_EMAIL"
            }, status=400)
        
        if not validate_phone(phone):
            return JsonResponse({
                "status": "error",
                "message": "Invalid phone number. Please enter a 10-digit number",
                "code": "INVALID_PHONE"
            }, status=400)
        
        is_valid, msg = validate_password(password)
        if not is_valid:
            return JsonResponse({
                "status": "error",
                "message": msg,
                "code": "WEAK_PASSWORD"
            }, status=400)
        
        # Hash password
        password_hash = hash_password(password)
        
        # Insert into database using Django DB cursor
        try:
            with connection.cursor() as cursor:
                # Check if user already exists
                cursor.execute("SELECT id FROM users WHERE email = %s", [email])
                if cursor.fetchone():
                    return JsonResponse({
                        "status": "error",
                        "message": "Email already registered",
                        "code": "EMAIL_EXISTS"
                    }, status=400)

                # Insert new user
                cursor.execute(
                    """
                    INSERT INTO users (name, email, phone, password_hash, role, created_at)
                    VALUES (%s, %s, %s, %s, %s, NOW())
                    RETURNING id, email, name, role
                    """,
                    [name, email, phone, password_hash, role],
                )
                user = cursor.fetchone()

            if str(role).strip().lower() == 'worker':
                _ensure_worker_profile_row(user[0], user[2])
            
            return JsonResponse({
                "status": "success",
                "message": "Registration successful",
                "data": {
                    "id": user[0],
                    "email": user[1],
                    "name": user[2],
                    "role": user[3]
                }
            }, status=201)
            
        except Exception as db_error:
            print(f"Database error: {db_error}")
            return JsonResponse({
                "status": "error",
                "message": "Database error during registration",
                "code": "DB_ERROR",
                "details": str(db_error)
            }, status=500)
    
    except json.JSONDecodeError:
        return JsonResponse({
            "status": "error",
            "message": "Invalid JSON format",
            "code": "INVALID_JSON"
        }, status=400)
    except Exception as e:
        print(f"Error: {e}")
        return JsonResponse({
            "status": "error",
            "message": "Registration failed",
            "code": "REGISTRATION_ERROR",
            "details": str(e)
        }, status=500)


@csrf_exempt
@require_http_methods(["POST"])
def login(request):
    """
    User login
    Expected JSON payload:
    {
        "email": "john@example.com",
        "password": "password123"
    }
    """
    try:
        data = json.loads(request.body)
        email = data.get('email', '').strip()
        password = data.get('password', '')
        
        if not email or not password:
            return JsonResponse({
                "status": "error",
                "message": "Email and password are required",
                "code": "MISSING_FIELDS"
            }, status=400)
        
        try:
            with connection.cursor() as cursor:
                # Fetch user by email
                cursor.execute(
                    "SELECT id, email, name, password_hash, role FROM users WHERE email = %s",
                    [email],
                )
                user = cursor.fetchone()
            
            if not user:
                return JsonResponse({
                    "status": "error",
                    "message": "Invalid email or password",
                    "code": "INVALID_CREDENTIALS"
                }, status=401)
            
            # Verify password
            user_id, user_email, user_name, password_hash, user_role = user

            if not verify_password(password, password_hash):
                return JsonResponse({
                    "status": "error",
                    "message": "Invalid email or password",
                    "code": "INVALID_CREDENTIALS"
                }, status=401)

            if str(user_role).strip().lower() == 'worker':
                _ensure_worker_profile_row(user_id, user_name)

            return JsonResponse({
                "status": "success",
                "message": "Login successful",
                "data": {
                    "id": user_id,
                    "email": user_email,
                    "name": user_name,
                    "role": user_role
                }
            }, status=200)
            
        except Exception as db_error:
            print(f"Database error: {db_error}")
            return JsonResponse({
                "status": "error",
                "message": "Login failed",
                "code": "DB_ERROR"
            }, status=500)
    
    except json.JSONDecodeError:
        return JsonResponse({
            "status": "error",
            "message": "Invalid JSON format",
            "code": "INVALID_JSON"
        }, status=400)
    except Exception as e:
        print(f"Error: {e}")
        return JsonResponse({
            "status": "error",
            "message": "Login failed",
            "code": "LOGIN_ERROR"
        }, status=500)


def demo_api(request):
    """Demo API endpoint to test backend-frontend connection"""
    return JsonResponse({
        "status": "success",
        "message": "Hello from Django Backend!",
        "data": {
            "timestamp": "2026-02-08",
            "version": "1.0.0"
        }
    })

def get_users(request):
    """Fetch users from database and return as JSON"""
    try:
        with connection.cursor() as cursor:
            # Check if users table exists
            cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name = 'users'
                );
            """)
            table_exists = cursor.fetchone()[0]
            
            if not table_exists:
                # If users table doesn't exist, return Django auth users
                cursor.execute("""
                    SELECT id, username, email, first_name, last_name, is_active, date_joined
                    FROM auth_user
                    ORDER BY date_joined DESC
                    LIMIT 10;
                """)
                columns = [col[0] for col in cursor.description]
                users = [dict(zip(columns, row)) for row in cursor.fetchall()]
                
                return JsonResponse({
                    "status": "success",
                    "message": "Fetched Django auth_user table (users table not found)",
                    "count": len(users),
                    "data": users
                })
            else:
                # Fetch from custom users table
                cursor.execute("SELECT * FROM users LIMIT 10;")
                columns = [col[0] for col in cursor.description]
                users = [dict(zip(columns, row)) for row in cursor.fetchall()]
                
                return JsonResponse({
                    "status": "success",
                    "message": "Fetched custom users table",
                    "count": len(users),
                    "data": users
                })
        
    except Exception as e:
        print(f"Error fetching users: {e}")
        return JsonResponse({
            "status": "error",
            "message": "Failed to fetch users",
            "code": "FETCH_ERROR"
        }, status=500)


def _get_user_id_from_bearer(request):
    """Extract a numeric user id from Authorization: Bearer <id>."""
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return None

    token = auth_header.split(" ", 1)[1].strip()
    try:
        user_id = int(token)
        return user_id if user_id > 0 else None
    except (TypeError, ValueError):
        return None


@csrf_exempt
@require_http_methods(["POST"])
def me(request):
    """Get the currently logged in user profile using Bearer <user_id>."""
    user_id = _get_user_id_from_bearer(request)
    if not user_id:
        return JsonResponse(
            {
                "status": "error",
                "message": "Unauthorized",
                "code": "UNAUTHORIZED",
            },
            status=401,
        )

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, name, email, phone, password_hash, role, created_at
                FROM users
                WHERE id = %s
                """,
                [user_id],
            )
            user = cursor.fetchone()

        if not user:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "User not found",
                    "code": "NOT_FOUND",
                },
                status=404,
            )

        return JsonResponse(
            {
                "status": "success",
                "data": {
                    "id": user[0],
                    "name": user[1],
                    "email": user[2],
                    "phone": user[3],
                    "password_hash": user[4],
                    "role": user[5],
                    "created_at": user[6].isoformat() if user[6] else None,
                },
            },
            status=200,
        )
    except Exception as db_error:
        print(f"Database error in me(): {db_error}")
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to fetch profile",
                "code": "DB_ERROR",
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["PUT"])
def update_profile(request, user_id):
    """Update profile fields for a user by id."""
    try:
        data = json.loads(request.body) if request.body else {}
    except json.JSONDecodeError:
        return JsonResponse(
            {
                "status": "error",
                "message": "Invalid JSON format",
                "code": "INVALID_JSON",
            },
            status=400,
        )

    name = data.get("name")
    email = data.get("email")
    phone = data.get("phone")

    update_fields = []
    update_values = []

    if name is not None:
        trimmed_name = str(name).strip()
        if not trimmed_name:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Name cannot be empty",
                    "code": "INVALID_NAME",
                },
                status=400,
            )
        update_fields.append("name = %s")
        update_values.append(trimmed_name)

    if email is not None:
        trimmed_email = str(email).strip()
        if not validate_email(trimmed_email):
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Invalid email format",
                    "code": "INVALID_EMAIL",
                },
                status=400,
            )
        update_fields.append("email = %s")
        update_values.append(trimmed_email)

    if phone is not None:
        trimmed_phone = str(phone).strip()
        if not validate_phone(trimmed_phone):
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Invalid phone number. Please enter a 10-digit number",
                    "code": "INVALID_PHONE",
                },
                status=400,
            )
        update_fields.append("phone = %s")
        update_values.append(trimmed_phone)

    if not update_fields:
        return JsonResponse(
            {
                "status": "error",
                "message": "No valid fields provided to update",
                "code": "NO_FIELDS",
            },
            status=400,
        )

    try:
        with connection.cursor() as cursor:
            if email is not None:
                cursor.execute(
                    "SELECT id FROM users WHERE email = %s AND id <> %s",
                    [str(email).strip(), user_id],
                )
                if cursor.fetchone():
                    return JsonResponse(
                        {
                            "status": "error",
                            "message": "Email already registered",
                            "code": "EMAIL_EXISTS",
                        },
                        status=400,
                    )

            if phone is not None:
                cursor.execute(
                    "SELECT id FROM users WHERE phone = %s AND id <> %s",
                    [str(phone).strip(), user_id],
                )
                if cursor.fetchone():
                    return JsonResponse(
                        {
                            "status": "error",
                            "message": "Phone already registered",
                            "code": "PHONE_EXISTS",
                        },
                        status=400,
                    )

            query = f"UPDATE users SET {', '.join(update_fields)} WHERE id = %s"
            cursor.execute(query, [*update_values, user_id])

            if cursor.rowcount == 0:
                return JsonResponse(
                    {
                        "status": "error",
                        "message": "User not found",
                        "code": "NOT_FOUND",
                    },
                    status=404,
                )

            cursor.execute(
                """
                SELECT id, name, email, phone, password_hash, role, created_at
                FROM users
                WHERE id = %s
                """,
                [user_id],
            )
            user = cursor.fetchone()

        return JsonResponse(
            {
                "status": "success",
                "message": "Profile updated successfully",
                "data": {
                    "id": user[0],
                    "name": user[1],
                    "email": user[2],
                    "phone": user[3],
                    "password_hash": user[4],
                    "role": user[5],
                    "created_at": user[6].isoformat() if user[6] else None,
                },
            },
            status=200,
        )
    except Exception as db_error:
        print(f"Database error in update_profile(): {db_error}")
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to update profile",
                "code": "DB_ERROR",
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["GET", "POST"])
def locations_collection(request):
    """GET list locations or POST create location."""
    try:
        if request.method == "GET":
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT id, user_id, latitude, longitude, address
                    FROM user_locations
                    ORDER BY id DESC
                    """
                )
                rows = cursor.fetchall()

            data = [
                {
                    "id": row[0],
                    "user_id": row[1],
                    "latitude": float(row[2]),
                    "longitude": float(row[3]),
                    "address": row[4],
                }
                for row in rows
            ]
            return JsonResponse({"status": "success", "data": data}, status=200)

        payload = json.loads(request.body or "{}")
        user_id = payload.get("user_id")
        latitude = payload.get("latitude")
        longitude = payload.get("longitude")
        address = (payload.get("address") or "").strip()

        if user_id is None or latitude is None or longitude is None or not address:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "user_id, latitude, longitude and address are required",
                    "code": "MISSING_FIELDS",
                },
                status=400,
            )

        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO user_locations (user_id, latitude, longitude, address)
                VALUES (%s, %s, %s, %s)
                RETURNING id, user_id, latitude, longitude, address
                """,
                [user_id, latitude, longitude, address],
            )
            row = cursor.fetchone()

        return JsonResponse(
            {
                "status": "success",
                "data": {
                    "id": row[0],
                    "user_id": row[1],
                    "latitude": float(row[2]),
                    "longitude": float(row[3]),
                    "address": row[4],
                },
            },
            status=201,
        )
    except json.JSONDecodeError:
        return JsonResponse(
            {
                "status": "error",
                "message": "Invalid JSON format",
                "code": "INVALID_JSON",
            },
            status=400,
        )
    except Exception as db_error:
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to process locations request",
                "code": "LOCATIONS_ERROR",
                "details": str(db_error),
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["GET"])
def location_by_user(request, user_id):
    """GET /api/locations/user/<user_id>/ - fetch location for a user."""
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, user_id, latitude, longitude, address
                FROM user_locations
                WHERE user_id = %s
                ORDER BY id DESC
                LIMIT 1
                """,
                [user_id],
            )
            row = cursor.fetchone()

        if not row:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Location not found",
                    "code": "NOT_FOUND",
                },
                status=404,
            )

        return JsonResponse(
            {
                "status": "success",
                "data": {
                    "id": row[0],
                    "user_id": row[1],
                    "latitude": float(row[2]),
                    "longitude": float(row[3]),
                    "address": row[4],
                },
            },
            status=200,
        )
    except Exception as db_error:
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to fetch user location",
                "code": "LOCATION_FETCH_ERROR",
                "details": str(db_error),
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["PUT"])
def location_by_id(request, location_id):
    """PUT /api/locations/<location_id>/ - update location."""
    try:
        payload = json.loads(request.body or "{}")
        user_id = payload.get("user_id")
        latitude = payload.get("latitude")
        longitude = payload.get("longitude")
        address = (payload.get("address") or "").strip()

        if user_id is None or latitude is None or longitude is None or not address:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "user_id, latitude, longitude and address are required",
                    "code": "MISSING_FIELDS",
                },
                status=400,
            )

        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE user_locations
                SET user_id = %s, latitude = %s, longitude = %s, address = %s
                WHERE id = %s
                RETURNING id, user_id, latitude, longitude, address
                """,
                [user_id, latitude, longitude, address, location_id],
            )
            row = cursor.fetchone()

        if not row:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Location not found",
                    "code": "NOT_FOUND",
                },
                status=404,
            )

        return JsonResponse(
            {
                "status": "success",
                "data": {
                    "id": row[0],
                    "user_id": row[1],
                    "latitude": float(row[2]),
                    "longitude": float(row[3]),
                    "address": row[4],
                },
            },
            status=200,
        )
    except json.JSONDecodeError:
        return JsonResponse(
            {
                "status": "error",
                "message": "Invalid JSON format",
                "code": "INVALID_JSON",
            },
            status=400,
        )
    except Exception as db_error:
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to update location",
                "code": "LOCATION_UPDATE_ERROR",
                "details": str(db_error),
            },
            status=500,
        )


@csrf_exempt
@require_http_methods(["POST"])
def save_fcm_token(request):
    """Save/update FCM token for current account."""
    user_id = _get_user_id_from_bearer(request)
    if not user_id:
        return JsonResponse(
            {
                "status": "error",
                "message": "Unauthorized",
                "code": "UNAUTHORIZED",
            },
            status=401,
        )

    try:
        data = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse(
            {
                "status": "error",
                "message": "Invalid JSON format",
                "code": "INVALID_JSON",
            },
            status=400,
        )

    fcm_token = str(data.get("fcm_token") or "").strip()
    if not fcm_token:
        return JsonResponse(
            {
                "status": "error",
                "message": "fcm_token is required",
                "code": "MISSING_FCM_TOKEN",
            },
            status=400,
        )

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE users
                SET fcm_token = %s
                WHERE id = %s
                """,
                [fcm_token, user_id],
            )

            if cursor.rowcount == 0:
                return JsonResponse(
                    {
                        "status": "error",
                        "message": "User not found",
                        "code": "NOT_FOUND",
                    },
                    status=404,
                )

        return JsonResponse(
            {
                "status": "success",
                "message": "FCM token saved",
            },
            status=200,
        )
    except Exception as db_error:
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to save FCM token",
                "code": "DB_ERROR",
                "details": str(db_error),
            },
            status=500,
        )


@require_http_methods(["GET"])
def workers(request):
    """Return all workers from users table."""
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, name, email, phone, role, created_at
                FROM users
                WHERE LOWER(role) = 'worker'
                ORDER BY created_at DESC
                """
            )
            rows = cursor.fetchall()

        data = [
            {
                "id": row[0],
                "name": row[1],
                "email": row[2],
                "phone": row[3],
                "role": row[4],
                "created_at": row[5].isoformat() if row[5] else None,
            }
            for row in rows
        ]

        return JsonResponse({"status": "success", "data": data}, status=200)
    except Exception as db_error:
        print(f"Database error in workers(): {db_error}")
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to fetch workers",
                "code": "DB_ERROR",
            },
            status=500,
        )
