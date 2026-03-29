#!/usr/bin/env python
"""
Add test bookings for worker_id=2 (user 27) at various times
"""
import os
import django
from datetime import datetime, timedelta

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

try:
    with connection.cursor() as cursor:
        today = datetime.now().date()
        
        # Delete old bookings for worker 2 first
        cursor.execute("DELETE FROM bookings WHERE worker_id = 2")
        print("🗑️  Cleared old bookings for worker 2")
        
        # Test bookings at different times today and upcoming days
        test_bookings = [
            # Today's bookings
            {
                'user_id': 2,  # Customer placeholder
                'worker_id': 2,
                'service_id': 1,
                'scheduled_date': datetime(today.year, today.month, today.day, 9, 0, 0),
                'status': 'confirmed',
                'total_amount': 1500.00,
            },
            {
                'user_id': 3,
                'worker_id': 2,
                'service_id': 1,
                'scheduled_date': datetime(today.year, today.month, today.day, 14, 0, 0),
                'status': 'confirmed',
                'total_amount': 2000.00,
            },
            {
                'user_id': 4,
                'worker_id': 2,
                'service_id': 1,
                'scheduled_date': datetime(today.year, today.month, today.day, 18, 0, 0),
                'status': 'pending',
                'total_amount': 1200.00,
            },
            # Tomorrow's bookings
            {
                'user_id': 5,
                'worker_id': 2,
                'service_id': 1,
                'scheduled_date': datetime((today + timedelta(days=1)).year, (today + timedelta(days=1)).month, (today + timedelta(days=1)).day, 10, 0, 0),
                'status': 'confirmed',
                'total_amount': 1800.00,
            },
            # Day after tomorrow
            {
                'user_id': 6,
                'worker_id': 2,
                'service_id': 1,
                'scheduled_date': datetime((today + timedelta(days=2)).year, (today + timedelta(days=2)).month, (today + timedelta(days=2)).day, 11, 0, 0),
                'status': 'confirmed',
                'total_amount': 2500.00,
            },
            # Next week
            {
                'user_id': 7,
                'worker_id': 2,
                'service_id': 1,
                'scheduled_date': datetime((today + timedelta(days=5)).year, (today + timedelta(days=5)).month, (today + timedelta(days=5)).day, 9, 0, 0),
                'status': 'pending',
                'total_amount': 1500.00,
            },
        ]
        
        print("\n📅 Inserting test bookings for worker 2 (user 27)...\n")
        
        for i, booking in enumerate(test_bookings, 1):
            # Create customer user if needed
            user_id = booking['user_id']
            cursor.execute("SELECT id FROM users WHERE id = %s", [user_id])
            if not cursor.fetchone():
                unique_phone = f"989876543{user_id:03d}"
                cursor.execute("""
                    INSERT INTO users (id, name, email, phone, password_hash, role, created_at)
                    VALUES (%s, %s, %s, %s, %s, %s, NOW())
                    ON CONFLICT (id) DO NOTHING
                """, [
                    user_id,
                    f"Customer {user_id}",
                    f"cust{user_id}@test.com",
                    unique_phone,
                    "hash",
                    "customer"
                ])
            
            # Insert booking
            cursor.execute("""
                INSERT INTO bookings (user_id, worker_id, service_id, scheduled_date, status, total_amount, created_at)
                VALUES (%s, %s, %s, %s, %s, %s, NOW())
            """, [
                booking['user_id'],
                booking['worker_id'],
                booking['service_id'],
                booking['scheduled_date'],
                booking['status'],
                booking['total_amount']
            ])
            
            day_name = booking['scheduled_date'].strftime('%A')
            time_str = booking['scheduled_date'].strftime('%H:%M')
            print(f"✅ Booking {i}: {day_name} at {time_str} - ₹{booking['total_amount']}")
        
        print(f"\n✅ All bookings added for worker 2 (user 27)!")
        print("\n🧪 Test the API:")
        print("   GET /api/workers/jobs/?filter=day     → Should show 3 jobs today")
        print("   GET /api/workers/jobs/?filter=week    → Should show 5 jobs (this week)")
        print("   GET /api/workers/jobs/?filter=month   → Should show 6 jobs (this month)")

except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
