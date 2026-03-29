#!/usr/bin/env python
"""Test the API endpoints and see what they return"""
import requests
import json

base_url = "http://192.168.1.5:8000/api"
headers = {"Authorization": "Bearer 27"}

endpoints = [
    ("/workers/auth-debug/", "Debug endpoint"),
    ("/workers/profile/", "Profile endpoint"),
    ("/workers/jobs/?filter=day", "Jobs endpoint"),
]

print("🧪 Testing API endpoints...\n")

for endpoint, description in endpoints:
    url = base_url + endpoint
    print(f"📍 Testing: {description}")
    print(f"   URL: {url}")
    
    try:
        response = requests.get(url, headers=headers, timeout=5)
        print(f"   Status: {response.status_code}")
        print(f"   Content Length: {len(response.content)} bytes")
        
        # Try to parse as JSON
        try:
            data = response.json()
            print(f"   ✅ Valid JSON: {json.dumps(data, indent=2)[:200]}...")
        except json.JSONDecodeError as e:
            print(f"   ❌ Invalid JSON: {e}")
            print(f"   Raw Response: {response.text[:200]}")
        
        print()
    except requests.exceptions.ConnectionError as e:
        print(f"   ❌ Connection Error: {e}\n")
    except Exception as e:
        print(f"   ❌ Error: {e}\n")

print("\n✅ Diagnostic complete!")
