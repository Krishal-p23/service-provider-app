#!/usr/bin/env python
"""
Add verification_status column to workers table if it doesn't exist
"""
import os
import sys
import django

# Setup Django environment
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend.settings")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

django.setup()

from django.db import connection

try:
    with connection.cursor() as cursor:
        # Check if column exists
        cursor.execute("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='workers' AND column_name='verification_status'
        """)
        
        if cursor.fetchone():
            print("✓ verification_status column already exists")
        else:
            print("Adding verification_status column to workers table...")
            cursor.execute("""
                ALTER TABLE workers 
                ADD COLUMN verification_status VARCHAR(50) DEFAULT 'not_started'
            """)
            print("✓ verification_status column added successfully")
            
except Exception as e:
    print(f"✗ Error: {e}")
    sys.exit(1)
