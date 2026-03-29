#!/usr/bin/env python
"""
Insert test bookings for worker_id=1 to test the jobs API endpoint
"""
import os
import django
from datetime import datetime, timedelta
import random

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

try:
    with connection.cursor() as cursor:
        # First, verify/create services if needed
        print("📋 Checking services...")
        cursor.execute("SELECT COUNT(*) FROM services")
        if cursor.fetchone()[0] == 0:
            print("⚠️  No services found. Creating test services...")
            cursor.execute("SELECT id FROM service_categories LIMIT 1")
            cat_row = cursor.fetchone()
            if cat_row:
                cat_id = cat_row[0]
                cursor.execute("""
                    INSERT INTO services (category_id, service_name, base_price)
                    VALUES 
                    (%s, 'AC Repair', 1500),
                    (%s, 'Plumbing', 800),
                    (%s, 'Electrical', 600)
                    ON CONFLICT DO NOTHING
                """, [cat_id, cat_id, cat_id])
                print("✅ Services created")
        
        # Test data for bookings
        today = datetime.now()
        test_bookings = [
            {
                'user_id': 2,
                'worker_id': 1,
                'service_id': 1,
                'scheduled_date': today.replace(hour=9, minute=0, second=0, microsecond=0),
                'status': 'confirmed',
                'total_amount': 1500.00,
            },
            {
                'user_id': 3,
                'worker_id': 1,
                'service_id': 1,
                'scheduled_date': today.replace(hour=14, minute=0, second=0, microsecond=0),
                'status': 'confirmed',
                'total_amount': 800.00,
            },
            {
                'user_id': 4,
                'worker_id': 1,
                'service_id': 2,
                'scheduled_date': (today + timedelta(days=1)).replace(hour=10, minute=0, second=0, microsecond=0),
                'status': 'confirmed',
                'total_amount': 2500.00,
            },
            {
                'user_id': 5,
                'worker_id': 1,
                'service_id': 1,
                'scheduled_date': (today + timedelta(days=2)).replace(hour=11, minute=0, second=0, microsecond=0),
                'status': 'confirmed',
                'total_amount': 1200.00,
            },
        ]
        
        print("\n📅 Inserting bookings...")
        inserted_count = 0
        
        for i, booking in enumerate(test_bookings):
            user_id = booking['user_id']
            
            # Check if user exists, create if needed with unique phone
            cursor.execute("SELECT id FROM users WHERE id = %s", [user_id])
            if not cursor.fetchone():
                unique_phone = f"989876543{user_id:03d}"  # Unique phone per user
                cursor.execute("""
                    INSERT INTO users (id, name, email, phone, password_hash, role, created_at)
                    VALUES (%s, %s, %s, %s, %s, %s, NOW())
                    ON CONFLICT (id) DO NOTHING
                """, [
                    user_id,
                    f"Customer {user_id}",
                    f"customer{user_id}@example.com",
                    unique_phone,
                    "placeholder_hash",
                    "customer"
                ])
            
            # Check service exists
            cursor.execute("SELECT id FROM services WHERE id = %s", [booking['service_id']])
            if not cursor.fetchone():
                print(f"⚠️  Service {booking['service_id']} does not exist. Skipping booking {i+1}.")
                continue
            
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
            print(f"✅ Booking {i+1}: Service {booking['service_id']} on {booking['scheduled_date']}")
            inserted_count += 1
        
        print(f"\n✅ Successfully inserted {inserted_count} test bookings!")
        print("\n📍 You can now view jobs in the Flutter app:")
        print("  - GET /api/workers/jobs/?filter=day")
        print("  - GET /api/workers/jobs/?filter=week")
        print("  - GET /api/workers/jobs/?filter=month")

except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()


