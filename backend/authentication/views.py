from django.shortcuts import render
from django.http import JsonResponse
from django.db import connection
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
import json
from .auth_utils import hash_password, verify_password, validate_email, validate_phone, validate_password

# Create your views here.

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
