#!/usr/bin/env python
"""
Test file upload to the document verification endpoint
"""
import requests
import json
from pathlib import Path

# Create test image
test_dir = Path("../test_upload")
test_dir.mkdir(exist_ok=True)
test_image = test_dir / "test_image.png"

# Create a minimal PNG if it doesn't exist
if not test_image.exists():
    # 1x1 pixel black PNG
    png_bytes = bytes([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 
        0, 0, 0, 10, 73, 68, 65, 84, 8, 29, 1, 1, 0, 0, 0, 255, 255, 0, 0, 0, 2, 0, 1, 197, 155, 203, 11, 
        0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
    ])
    test_image.write_bytes(png_bytes)
    print(f"✅ Test image created: {test_image}")

# Test upload
print("\n" + "=" * 60)
print("Testing Document Upload Endpoint")
print("=" * 60)

url = "http://192.168.1.5:8000/api/workers/documents/upload/"
headers = {"Authorization": "Bearer 27"}

# Prepare file for upload
with open(test_image, 'rb') as f:
    files = {
        'document_image': ('test_document.png', f, 'image/png'),
    }
    
    data = {
        'document_type': 'aadhar',
        'document_number': '123456789012',
    }
    
    print(f"\n📤 Uploading to: {url}")
    print(f"   Worker ID (Bearer): 27")
    print(f"   Document Type: aadhar")
    print(f"   Government ID: 123456789012")
    print(f"   Image: test_image.png ({test_image.stat().st_size} bytes)")
    
    try:
        response = requests.post(
            url,
            headers=headers,
            files=files,
            data=data,
            timeout=30
        )
        
        print(f"\n📨 Response Status: {response.status_code}")
        
        try:
            resp_data = response.json()
            print(f"📋 Response Data:")
            print(json.dumps(resp_data, indent=2))
            
            # Check if file was stored
            if resp_data.get('data', {}).get('document_image'):
                print(f"\n✅ SUCCESS! Image URL: {resp_data['data']['document_image']}")
            else:
                print(f"\n⚠️  No  image URL in response. Image may not have been stored.")
                
        except json.JSONDecodeError as e:
            print(f"❌ Invalid JSON response: {e}")
            print(f"Raw response: {response.text[:500]}")
            
    except requests.exceptions.ConnectionError as e:
        print(f"❌ Connection Error: {e}")
        print("   Is the server running at http://192.168.1.5:8000?")
    except Exception as e:
        print(f"❌ Error: {e}")

# Check if file exists on disk
print(f"\n" + "=" * 60)
print("Checking Media Directory")
print("=" * 60)

media_dir = Path("media/worker_documents")
if media_dir.exists():
    files_found = list(media_dir.rglob("*"))
    files_found = [f for f in files_found if f.is_file()]
    print(f"✅ Media directory exists: {media_dir.absolute()}")
    print(f"   Files in directory: {len(files_found)}")
    for file in files_found[-5:]:  # Show last 5 files
        print(f"   - {file.relative_to(media_dir.parent.parent)}: {file.stat().st_size} bytes")
else:
    print(f"❌ Media directory not found: {media_dir.absolute()}")

print("\n✅ Upload test complete!")
