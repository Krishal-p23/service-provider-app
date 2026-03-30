"""OTP generation and validation utilities for job activation."""
import random
import string
from datetime import datetime, timedelta
from django.db import connection


def generate_otp(length=4):
    """Generate a random numeric OTP."""
    return ''.join(random.choices(string.digits, k=length))


def create_job_otp_table():
    """Create job_otp table if it doesn't exist (SQLite/Postgres compatible)."""
    with connection.cursor() as cursor:
        if connection.vendor == "postgresql":
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS job_otp (
                    id SERIAL PRIMARY KEY,
                    booking_id BIGINT NOT NULL,
                    customer_id BIGINT NOT NULL,
                    worker_id BIGINT NOT NULL,
                    otp VARCHAR(10) NOT NULL,
                    is_used BOOLEAN NOT NULL DEFAULT FALSE,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    expires_at TIMESTAMP NOT NULL,
                    verified_at TIMESTAMP NULL
                )
                """
            )
        else:
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS job_otp (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    booking_id INTEGER NOT NULL,
                    customer_id INTEGER NOT NULL,
                    worker_id INTEGER NOT NULL,
                    otp TEXT NOT NULL,
                    is_used BOOLEAN NOT NULL DEFAULT 0,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    expires_at DATETIME NOT NULL,
                    verified_at DATETIME NULL
                )
                """
            )


def save_job_otp(booking_id, customer_id, worker_id, otp, validity_minutes=10):
    """Save OTP to database."""
    try:
        create_job_otp_table()
        
        expires_at = datetime.now() + timedelta(minutes=validity_minutes)
        
        with connection.cursor() as cursor:
            # Invalidate previous OTPs for this booking
            cursor.execute(
                """
                UPDATE job_otp
                SET is_used = TRUE
                WHERE booking_id = %s AND is_used = FALSE
                """,
                [booking_id],
            )
            
            # Save new OTP
            cursor.execute(
                """
                INSERT INTO job_otp (booking_id, customer_id, worker_id, otp, expires_at)
                VALUES (%s, %s, %s, %s, %s)
                """,
                [booking_id, customer_id, worker_id, otp, expires_at],
            )
        
        return True
    except Exception as e:
        print(f"Error saving OTP: {e}")
        return False


def verify_job_otp(booking_id, otp):
    """Verify OTP for a booking. Returns True if valid, False otherwise."""
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, expires_at, is_used
                FROM job_otp
                WHERE booking_id = %s AND otp = %s
                ORDER BY created_at DESC
                LIMIT 1
                """,
                [booking_id, otp],
            )
            row = cursor.fetchone()
        
        if not row:
            return False
        
        otp_id, expires_at, is_used = row[0], row[1], row[2]
        
        # Check if already used
        if is_used:
            return False
        
        # Check if expired
        if isinstance(expires_at, str):
            expires_at = datetime.fromisoformat(expires_at)
        
        if datetime.now() > expires_at:
            return False
        
        # Mark as used
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE job_otp
                SET is_used = TRUE, verified_at = %s
                WHERE id = %s
                """,
                [datetime.now(), otp_id],
            )
        
        return True
    except Exception as e:
        print(f"Error verifying OTP: {e}")
        return False


def get_otp_info(booking_id):
    """Get current OTP info for a booking (for debugging)."""
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT otp, is_used, expires_at, created_at
                FROM job_otp
                WHERE booking_id = %s
                ORDER BY created_at DESC
                LIMIT 1
                """,
                [booking_id],
            )
            row = cursor.fetchone()
        
        if row:
            return {
                "otp": row[0],
                "is_used": row[1],
                "expires_at": row[2].isoformat() if row[2] else None,
                "created_at": row[3].isoformat() if row[3] else None,
            }
        return None
    except Exception as e:
        print(f"Error getting OTP info: {e}")
        return None
