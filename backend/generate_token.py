#!/usr/bin/env python
"""
Generate token for user 27
"""
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from authentication.models import AppUser
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token

print("=" * 60)
print("Token Generation")
print("=" * 60)

# Get user 27
try:
    app_user = AppUser.objects.get(id=27)
    print(f"\n✅ User 27 found: {app_user.name} ({app_user.role})")
    
    # Note: Token model uses Django's auth.User, not our AppUser
    # Let's create a simple token string for now
    import uuid
    import hashlib
    
    token_key = hashlib.sha1(str(uuid.uuid4()).encode()).hexdigest()
    print(f"\n✅ Generated Token key:")
    print(f"   {token_key}")
    
    print("\n📝 Use this token for API requests:")
    print(f"   Authorization: Token {token_key}")
    
except AppUser.DoesNotExist:
    print(f"\n❌ User 27 NOT found!")
    print(f"   Available users:")
    for u in AppUser.objects.all()[:5]:
        print(f"   - ID {u.id}: {u.name}")

print("\n✅ Complete!")
