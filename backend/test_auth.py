#!/usr/bin/env python
"""
Check authentication for user 27
"""
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from authentication.models import AppUser
from rest_framework.authtoken.models import Token

print("=" * 60)
print("Authentication Test")
print("=" * 60)

# Check if user 27 exists
try:
    user = AppUser.objects.get(id=27)
    print(f"\n✅ User 27 found!")
    print(f"   Name: {user.name}")
    print(f"   Role: {user.role}")
    print(f"   Email: {user.email}")
    print(f"   ID: {user.id}")
    
    # Check for token
    token, created = Token.objects.get_or_create(user=user)
    print(f"\n✅ Token found{'(created)' if created else ''}:")
    print(f"   Token: {token.key}")
    
except AppUser.DoesNotExist:
    print(f"\n❌ User 27 NOT found!")
    print(f"   Available users:")
    for user in AppUser.objects.all()[:10]:
        print(f"   - ID {user.id}: {user.name} ({user.role})")
except Exception as e:
    print(f"❌ Error: {e}")

print("\n✅ Authentication check complete!")
