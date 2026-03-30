#!/usr/bin/env python
"""
Test different header formats for Didit auth
"""
import requests
import base64

API_KEY = "cxuw6VxduC83exVddDLz82IV0VDQIPL7d0raaAC--tk"
endpoint = "https://api.didit.me/auth/v2/token/"

print("\n" + "="*80)
print("TESTING DIFFERENT DIDIT AUTH HEADER FORMATS")
print("="*80)

# Test 1: X-API-Key header
print(f"\n1. Testing with X-API-Key header:")
try:
    response = requests.post(
        endpoint,
        headers={
            "Content-Type": "application/json",
            "X-API-Key": API_KEY,
        },
        timeout=10,
    )
    print(f"   Status: {response.status_code}")
    print(f"   Response: {response.text[:200]}")
except Exception as e:
    print(f"   Error: {e}")

# Test 2: Authorization Bearer
print(f"\n2. Testing with Bearer token in Authorization header:")
try:
    response = requests.post(
        endpoint,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {API_KEY}",
        },
        timeout=10,
    )
    print(f"   Status: {response.status_code}")
    print(f"   Response: {response.text[:200]}")
except Exception as e:
    print(f"   Error: {e}")

# Test 3: Basic auth
print(f"\n3. Testing with Basic Auth:")
try:
    response = requests.post(
        endpoint,
        headers={
            "Content-Type": "application/json",
        },
        auth=('api', API_KEY),
        timeout=10,
    )
    print(f"   Status: {response.status_code}")
    print(f"   Response: {response.text[:200]}")
except Exception as e:
    print(f"   Error: {e}")

# Test 4: API key in JSON body
print(f"\n4. Testing with API key in JSON body:")
try:
    response = requests.post(
        endpoint,
        headers={"Content-Type": "application/json"},
        json={"api_key": API_KEY},
        timeout=10,
    )
    print(f"   Status: {response.status_code}")
    print(f"   Response: {response.text[:200]}")
except Exception as e:
    print(f"   Error: {e}")

# Test 5: Try without any auth - maybe it's a public endpoint
print(f"\n5. Testing with NO authentication:")
try:
    response = requests.post(
        endpoint,
        headers={"Content-Type": "application/json"},
        timeout=10,
    )
    print(f"   Status: {response.status_code}")
    print(f"   Response: {response.text[:200]}")
except Exception as e:
    print(f"   Error: {e}")

# Test 6: Try GET instead of POST
print(f"\n6. Testing with GET instead of POST:")
try:
    response = requests.get(
        endpoint,
        headers={
            "Content-Type": "application/json",
            "X-API-Key": API_KEY,
        },
        timeout=10,
    )
    print(f"   Status: {response.status_code}")
    print(f"   Response: {response.text[:200]}")
except Exception as e:
    print(f"   Error: {e}")

print("\n" + "="*80)
