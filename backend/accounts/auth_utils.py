"""
Utility functions for authentication
"""
from django.contrib.auth.hashers import make_password, check_password
import re

def hash_password(password):
    """Hash a password using Django's built-in password hashing"""
    return make_password(password)

def verify_password(password, hashed_password):
    """Verify a password against its hash"""
    return check_password(password, hashed_password)

def validate_email(email):
    """Validate email format"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_phone(phone):
    """Validate phone number (10 digits for India)"""
    return len(phone) == 10 and phone.isdigit()

def validate_password(password):
    """Validate password strength"""
    if len(password) < 6:
        return False, "Password must be at least 6 characters"
    return True, "Valid password"
