#!/usr/bin/env python
"""
Test different Didit auth endpoints to find the correct one
"""
import requests

API_KEY = "cxuw6VxduC83exVddDLz82IV0VDQIPL7d0raaAC--tk"

endpoints_to_test = [
    "https://api.didit.me/auth/v2/token/",
    "https://api.didit.me/auth/token/",
    "https://api.didit.me/v2/token/",
    "https://api.didit.me/api/auth/v2/token/",
    "https://auth.didit.me/auth/v2/token/",
    "https://auth.didit.me/token/",
]

print("\n" + "="*80)
print("TESTING DIFFERENT DIDIT AUTH ENDPOINTS")
print("="*80)

for endpoint in endpoints_to_test:
    print(f"\nTesting: {endpoint}")
    try:
        response = requests.post(
            endpoint,
            headers={
                "Content-Type": "application/json",
                "X-API-Key": API_KEY,
            },
            timeout=10,
        )
        print(f"  Status: {response.status_code}")
        print(f"  Response: {response.text[:150]}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                if data.get("access_token"):
                    print(f"  ✅ SUCCESS! Token: {data.get('access_token')[:30]}...")
            except:
                pass
    except Exception as e:
        print(f"  Error: {e}")

print("\n" + "="*80)
