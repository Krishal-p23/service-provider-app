#!/usr/bin/env python
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection

with connection.cursor() as cursor:
    print("🔍 Checking user_id 27...")
    
    # Check if user exists
    cursor.execute("SELECT id, name, role FROM users WHERE id = 27")
    user = cursor.fetchone()
    if user:
        print(f"✅ User 27 exists: {user[1]} (Role: {user[2]})")
    else:
        print("❌ User 27 does not exist")
        exit(1)
    
    # Check if worker profile exists
    cursor.execute("SELECT id, user_id FROM workers WHERE user_id = 27")
    worker = cursor.fetchone()
    if worker:
        worker_id = worker[0]
        print(f"✅ Worker profile exists: Worker ID {worker_id}")
        
        # Check if there are bookings for this worker
        cursor.execute("SELECT COUNT(*) FROM bookings WHERE worker_id = %s", [worker_id])
        booking_count = cursor.fetchone()[0]
        print(f"   - Bookings for this worker: {booking_count}")
        
        if booking_count == 0:
            print("   ⚠️  No bookings found for this worker")
            print("\n   📋 Available workers with bookings:")
            cursor.execute("""
                SELECT DISTINCT w.id, w.user_id, COUNT(b.id) as bookings
                FROM workers w
                LEFT JOIN bookings b ON w.id = b.worker_id
                GROUP BY w.id, w.user_id
                ORDER BY bookings DESC
            """)
            for row in cursor.fetchall():
                print(f"      Worker ID: {row[0]}, User ID: {row[1]}, Bookings: {row[2]}")
        else:
            # Show the bookings
            cursor.execute("""
                SELECT id, scheduled_date, status, total_amount 
                FROM bookings 
                WHERE worker_id = %s
                ORDER BY scheduled_date
            """, [worker_id])
            print("   📅 Bookings:")
            for booking in cursor.fetchall():
                print(f"      ID: {booking[0]}, Date: {booking[1]}, Status: {booking[2]}, Amount: {booking[3]}")
    else:
        print("❌ Worker profile does NOT exist for user 27")
        print("\n   Need to create a worker profile. Available users:")
        cursor.execute("SELECT id, name, role FROM users LIMIT 10")
        for user in cursor.fetchall():
            cursor.execute("SELECT id FROM workers WHERE user_id = %s", [user[0]])
            has_worker = cursor.fetchone() is not None
            status = "✅ has worker" if has_worker else "❌ no worker"
            print(f"      User ID: {user[0]}, Name: {user[1]}, Role: {user[2]} - {status}")
