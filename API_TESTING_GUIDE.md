# Manual API Testing Guide

## Quick Test: Upload via cURL

### Test 1: Upload Aadhar Document
```bash
# First, get a token (use worker token 27)
TOKEN="27"

# Prepare image file (use any JPG image for testing)
IMAGE_FILE="path/to/your/image.jpg"

# Upload Aadhar
curl -X POST http://192.168.1.5:8000/api/workers/documents/upload/ \
  -H "Authorization: Bearer $TOKEN" \
  -F "document_type=aadhar" \
  -F "document_number=123456789012" \
  -F "document_image=@$IMAGE_FILE"

# Expected Response (instant, < 1 second):
{
  "message": "Document uploaded successfully",
  "data": {
    "id": 1,
    "status": "pending",
    "document_type": "aadhar",
    "document_image": "http://192.168.1.5:8000/media/worker_documents/2026/03/27/abc123.jpg"
  },
  "note": "Verification in progress in background"
}
```

### Test 2: Check Verification Status Immediately
```bash
# Check status right after upload (should be pending)
curl -X GET http://192.168.1.5:8000/api/workers/documents/upload/ \
  -H "Authorization: Bearer 27"

# Initial Response (within 1 second):
{
  "status": "pending",
  "is_pending": true,
  "is_verified": false,
  "is_rejected": false
}
```

### Test 3: Check Status After 5-10 Seconds
```bash
# Wait 5-10 seconds, then check again
sleep 10

curl -X GET http://192.168.1.5:8000/api/workers/documents/upload/ \
  -H "Authorization: Bearer 27"

# Updated Response:
{
  "status": "verified",  # OR "rejected" 
  "is_verified": true,   # OR false
  "is_rejected": false,  # OR true
  "rejection_reason": null  # OR error message if rejected
}
```

---

## PowerShell Testing (Windows)

### Test 1: Upload via PowerShell
```powershell
# Set variables
$token = "27"
$imageFile = "C:\path\to\image.jpg"
$apiUrl = "http://192.168.1.5:8000/api/workers/documents/upload/"

# Upload
$form = @{
    document_type = 'aadhar'
    document_number = '123456789012'
    document_image = Get-Item -Path $imageFile
}

$response = Invoke-WebRequest -Uri $apiUrl `
    -Method POST `
    -Headers @{"Authorization" = "Bearer $token"} `
    -Form $form

Write-Host $response.Content
```

### Test 2: Check Status
```powershell
$apiUrl = "http://192.168.1.5:8000/api/workers/documents/upload/"

$response = Invoke-WebRequest -Uri $apiUrl `
    -Method GET `
    -Headers @{"Authorization" = "Bearer 27"}

$json = $response.Content | ConvertFrom-Json
Write-Host "Status: $($json.status)"
Write-Host "Is Verified: $($json.is_verified)"
```

---

## Test Cases

### Test Case 1: Valid Aadhar Format
**Input:**
- Document Type: `aadhar`
- Aadhar Number: `123456789012` (12 digits)
- Photo: Any clear image file

**Expected:**
- Upload: ✅ Success (< 1 second)
- Status immediately: `pending`
- Status after 5 seconds: `verified` or `rejected` (depends on image quality)
- If verified: `is_verified = True`

**Console logs:**
```
[Upload] Document saved for worker 1
[AsyncVerification] Calling Didit API for 123456789012
[AsyncVerification] ✅ Auto-verified for worker 1
```

---

### Test Case 2: Invalid Aadhar Number
**Input:**
- Document Type: `aadhar`
- Aadhar Number: `INVALID12345` (not 12 digits)
- Photo: Any image

**Expected:**
- Upload: ✅ or ❌ (depends on validation)
- If validation fails: 400 error
- If saved anyway: Status becomes `rejected` after 3-5 seconds
- `rejection_reason`: "Invalid Aadhar format"

**Console logs:**
```
[AsyncVerification] Didit result: {'verified': False, 'error_message': 'Invalid Aadhar'}
[AsyncVerification] ❌ Rejected for worker 1
```

---

### Test Case 3: Wrong/Blurry Photo
**Input:**
- Document Type: `aadhar`  
- Aadhar Number: `123456789012`
- Photo: Screenshot, blurry photo, or random image

**Expected:**
- Upload: ✅ Success
- Status: `pending` → `rejected` (after 3-5 seconds)
- `rejection_reason`: "Could not extract Aadhar information from image"

---

### Test Case 4: Manual Verification (Non-Aadhar)
**Input:**
- Document Type: `pan`
- PAN Number: `ABCDE1234F`
- Photo: Any image

**Expected:**
- Upload: ✅ Success
- Status: `pending` (stays pending - no auto-verification)
- Admin must manually verify
- When admin approves: Status changes to `verified`

---

### Test Case 5: Check API Key Validity
**Command:**
```bash
# Test if API key is valid
curl -X GET https://api.didit.me/api/auth/verify \
  -H "Authorization: Bearer cxuw6VxduC83exVddDLz82IV0VDQIPL7d0raaAC--tk"
```

**If valid (200):**
```
{"status": "valid"}
```

**If invalid (401):**
```
{"error": "Invalid API key"}
```

---

## Monitoring Verification

### Via Django Admin
1. Go to: `http://192.168.1.5:8000/admin`
2. Login as admin
3. Click: **Workers** → **Worker Document Verifications**
4. Filter by Status:
   - `Pending` - Waiting for verification
   - `Verified` - Auto-verified by Didit
   - `Rejected` - Failed verification

### Via API Endpoint
```bash
# Get all pending documents (admin only)
curl -X GET "http://192.168.1.5:8000/api/workers/documents/admin/?status=pending" \
  -H "Authorization: Bearer ADMIN_TOKEN"

# Get all verified documents
curl -X GET "http://192.168.1.5:8000/api/workers/documents/admin/?status=verified" \
  -H "Authorization: Bearer ADMIN_TOKEN"

# Get all rejected documents
curl -X GET "http://192.168.1.5:8000/api/workers/documents/admin/?status=rejected" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

### Via Console Logs
Watch Django terminal for:
- `[Upload]` messages - Document saved
- `[AsyncVerification]` messages - API call details
- `✅` - Success
- `❌` - Failure/rejection
- `⏳` - Still pending

---

## Handling Wrong Documents

### Problem: Worker uploads wrong photo
**Solution:**
1. Photo rejected automatically (status = `rejected`)
2. `rejection_reason` shows why (e.g., "Could not extract Aadhar")
3. Worker sees error in app: ❌ "Document rejected - Please upload clear Aadhar photo"
4. Worker can retry with better photo
5. New upload creates new verification record

### Problem: Worker uses fake/invalid Aadhar
**Solution:**
1. Didit API rejects it (can't validate against UIDAI database)
2. Status = `rejected`
3. `rejection_reason` = "Aadhar verification failed"
4. Worker can:
   - Option A: Retry with real Aadhar
   - Option B: Use different document (PAN, DL, etc.)
   - Option C: Wait for manual admin review

### Problem: API is slow/offline
**Solution:**
1. Upload still succeeds ✅
2. Background verification fails silently
3. Status stays `pending`
4. Admin can manually review and approve/reject
5. Document not lost - always available for manual verification

---

## Response Status Codes

| Status | Code | Meaning |
|--------|------|---------|
| 200 | OK | Upload successful |
| 400 | Bad Request | Missing required fields |
| 401 | Unauthorized | Invalid token |
| 403 | Forbidden | User is not worker |
| 413 | Payload Too Large | Image > 5 MB |
| 500 | Server Error | Django error |

---

## Free Tier Usage

**Check your usage:**
1. Go to: https://www.didit.me/dashboard
2. Login with your Didit account
3. Check "API Usage" or "Credits"
4. Free tier: 50 verifications/month

**When you exceed:**
- Status: Changes to `pending`
- Error: "Rate limit exceeded" or "Quota exceeded"
- Solution: Upgrade to paid plan or wait for next month

---

## Debugging Tips

### Enable Verbose Logging
Add to Django settings.py:
```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'DEBUG',
    },
}
```

### Check Background Thread
Add to verification_views.py:
```python
import threading
print(f"Active threads: {threading.active_count()}")
for thread in threading.enumerate():
    print(f"  - {thread.name}")
```

### Verify File Storage
```bash
# Check if images are saved
ls -la /media/worker_documents/

# Should show directory structure like:
# 2026/03/27/
#   document_front_abc123.jpg
#   document_back_def456.jpg
```

---

## Test Your API Now

### Quick 2-Minute Test:
```bash
# 1. Upload document
curl -X POST http://192.168.1.5:8000/api/workers/documents/upload/ \
  -H "Authorization: Bearer 27" \
  -F "document_type=aadhar" \
  -F "document_number=123456789012" \
  -F "document_image=@test.jpg"

# 2. Check status (should be pending)
curl -X GET http://192.168.1.5:8000/api/workers/documents/upload/ \
  -H "Authorization: Bearer 27"

# 3. Wait 10 seconds

# 4. Check status again (should be verified or rejected)
curl -X GET http://192.168.1.5:8000/api/workers/documents/upload/ \
  -H "Authorization: Bearer 27"
```

**Result:** If verified or rejected appears, API is ✅ WORKING!

---

**Next: Test with your Flutter app by uploading a real document!**
