#!/usr/bin/env python
"""
Test script to verify Didit API credentials are working
"""
import os
import sys
import django
import requests

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.conf import settings

print("\n" + "="*80)
print("DIDIT CREDENTIALS TEST")
print("="*80)

print(f"\n1. Checking settings:")
print(f"   DIDIT_ENABLED: {settings.DIDIT_ENABLED}")
print(f"   DIDIT_API_KEY: {settings.DIDIT_API_KEY[:20]}..." if settings.DIDIT_API_KEY else "   DIDIT_API_KEY: NOT SET")
print(f"   DIDIT_AUTH_URL: {settings.DIDIT_AUTH_URL}")
print(f"   DIDIT_BASE_URL: {settings.DIDIT_BASE_URL}")
print(f"   DIDIT_WORKFLOW_ID: {settings.DIDIT_WORKFLOW_ID}")

if not settings.DIDIT_API_KEY:
    print("\n❌ ERROR: DIDIT_API_KEY is not set!")
    sys.exit(1)

print(f"\n2. Testing authentication endpoint:")
auth_urls = [
    settings.DIDIT_AUTH_URL.rstrip("/") if settings.DIDIT_AUTH_URL else None,
    "https://api.didit.me"
]
auth_urls = [url for url in auth_urls if url]

print(f"   Auth URLs to test: {auth_urls}")

for auth_url in auth_urls:
    token_url = f"{auth_url}/auth/v2/token/"
    print(f"\n   Testing: {token_url}")
    try:
        response = requests.post(
            token_url,
            headers={
                "Content-Type": "application/json",
                "X-API-Key": settings.DIDIT_API_KEY,
            },
            timeout=10,
        )
        print(f"   Status Code: {response.status_code}")
        print(f"   Response: {response.text[:200]}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                token = data.get("access_token")
                if token:
                    print(f"   ✅ SUCCESS! Token received: {token[:30]}...")
                    print(f"\n3. Testing session creation with this token:")
                    
                    session_url = f"{settings.DIDIT_BASE_URL}/v1/session/"
                    print(f"   Session URL: {session_url}")
                    
                    session_response = requests.post(
                        session_url,
                        headers={
                            "Authorization": f"Bearer {token}",
                            "Content-Type": "application/json",
                        },
                        json={
                            "workflow_id": settings.DIDIT_WORKFLOW_ID,
                            "callback": "https://example.com/callback",
                            "vendor_data": "123",
                        },
                        timeout=15,
                    )
                    print(f"   Session Status: {session_response.status_code}")
                    print(f"   Session Response: {session_response.text[:200]}")
                    
                    if session_response.status_code == 201:
                        print(f"   ✅ Session creation successful!")
                    else:
                        print(f"   ❌ Session creation failed")
                    sys.exit(0)
            except Exception as e:
                print(f"   Error parsing response: {e}")
        else:
            print(f"   ❌ Failed to get token (status {response.status_code})")
            
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Network error: {e}")

print("\n" + "="*80)
print("TEST COMPLETE")
print("="*80 + "\n")
