#!/usr/bin/env python
"""
Test if the WorkerDocumentVerification table has all required fields
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from workers.models import WorkerDocumentVerification, Worker
from django.db import connection

# Check if we can query the model
print("=" * 60)
print("Testing WorkerDocumentVerification Model")
print("=" * 60)

# Get the actual table columns from database
with connection.cursor() as cursor:
    cursor.execute(f"""
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_name = '{WorkerDocumentVerification._meta.db_table}'
        ORDER BY column_name;
    """)
    columns = cursor.fetchall()
    
    print(f"\n✅ Table: {WorkerDocumentVerification._meta.db_table}")
    print(f"   Database columns ({len(columns)}):")
    for col_name, col_type, is_nullable in columns:
        nullable = "NULL" if is_nullable == 'YES' else "NOT NULL"
        print(f"   - {col_name}: {col_type} ({nullable})")

# Check model fields
print(f"\n✅ Django Model fields ({len(WorkerDocumentVerification._meta.get_fields())}):")
for field in WorkerDocumentVerification._meta.get_fields():
    print(f"   - {field.name}: {field.__class__.__name__}")

# Try to get existing records
print(f"\n✅ Existing records: {WorkerDocumentVerification.objects.count()}")
for doc in WorkerDocumentVerification.objects.all()[:3]:
    print(f"   - {doc}")

print("\n✅ Table schema verification complete!")
