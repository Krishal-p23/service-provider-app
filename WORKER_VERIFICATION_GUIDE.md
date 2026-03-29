# Worker Document Verification System - Architecture Guide

## Current State

### Frontend (Flutter)
**Location**: `lib/worker/screens/verification_screen.dart`

**Current Storage**:
- Uses `SharedPreferences` (local device storage)
- Stores: Government ID number + image path
- **Problem**: Only stored locally, not synced to backend
- **Security Risk**: No server-side validation or storage

**Fields Being Collected**:
- Government ID Number (Aadhar/PAN/Driving License)
- Image file (via `image_picker` plugin)

### Backend (Django)
**Current State**: **NO BACKEND STORAGE**

**Missing Components**:
1. ❌ No database model for storing documents
2. ❌ No API endpoints for upload/retrieval
3. ❌ No verification workflow
4. ❌ No admin panel for reviewing documents

---

## Proposed Solution

### 1. DATABASE MODEL
**File**: `backend/workers/verification_models.py` ✅ CREATED

**Table**: `worker_document_verification`

```
Columns:
- id (Primary Key)
- worker_id (Foreign Key → workers)
- document_type (aadhar, pan, driving_license, passport)
- document_number (e.g., "123456789012")
- document_image (ImageField → stored in media/worker_documents/)
- document_image_back (optional - back side of document)
- status (pending, verified, rejected)
- rejection_reason (if rejected)
- verified_by (Admin who verified it)
- created_at
- updated_at
- verified_at
```

### 2. API ENDPOINTS
**File**: `backend/workers/verification_views.py` ✅ CREATED

#### Upload Document (Worker)
**POST** `/api/workers/documents/upload/`
```json
{
    "document_type": "aadhar",
    "document_number": "123456789012",
    "document_image": <file>,
    "document_image_back": <file> (optional)
}
```
**Response**:
```json
{
    "message": "Document uploaded successfully",
    "data": {
        "id": 1,
        "document_type": "aadhar",
        "document_type_display": "Aadhar Card",
        "document_number": "123456789012",
        "document_image": "http://.../worker_documents/2026/03/26/aadhar.jpg",
        "status": "pending",
        "status_display": "Pending Review",
        "is_verified": false,
        "is_pending": true,
        "created_at": "2026-03-26T10:30:00Z"
    }
}
```

#### Get Document Status (Worker)
**GET** `/api/workers/documents/upload/`
**Returns**: Current document status or "No documents submitted yet"

#### Admin Review Documents
**GET** `/api/workers/documents/admin/?status=pending`
**Returns**: List of all documents waiting for admin review

**POST** `/api/workers/documents/admin/{verification_id}/`
```json
{
    "action": "approve",  // or "reject"
    "rejection_reason": "Document quality is poor"
}
```

---

## Where Images Are Stored

### Frontend
1. **During Upload**: Stored locally in device temp cache
   - Path: `/data/user/0/com.example.app/cache/` (Android)
   - Path: `App Documents/` (iOS)

2. **Local Storage**: SharedPreferences (encrypted)
   - Not suitable for production

### Backend (Recommended)
**Location**: `MEDIA_ROOT/worker_documents/YYYY/MM/DD/`

**Example**: 
```
/media/
  └─ worker_documents/
     └─ 2026/03/26/
        ├─ worker_1_aadhar_front.jpg
        ├─ worker_1_aadhar_back.jpg
        ├─ worker_2_pan_front.jpg
```

**Security**: 
- ✅ Backend validation
- ✅ Virus scanning possible
- ✅ Secure database linked
- ✅ Access control via permissions
- ✅ Audit trail (who verified, when)

---

## Verification Workflow

### Step 1: Worker Uploads Document
```
Worker App → Upload Screen
    ↓
    Select Image (Aadhar/PAN/DL)
    ↓
    Enter ID Number
    ↓
    Submit → POST /api/workers/documents/upload/
    ↓
    Backend: Save to media/ folder + DB
    ↓
    Status: PENDING
```

### Step 2: Admin Reviews Document
```
Admin Dashboard
    ↓
    View all PENDING documents
    ↓
    Verify authenticity:
    - Check ID number format
    - Verify image quality
    - Confirm identity details
    ↓
    Click APPROVE or REJECT
    ↓
    POST /api/workers/documents/admin/{id}/
    ↓
    If APPROVED:
    - Set status = VERIFIED
    - Update worker.is_verified = True
    ↓
    If REJECTED:
    - Set status = REJECTED
    - Send reason to worker
```

### Step 3: Worker Sees Status
```
Worker App → Account → Verification
    ↓
    GET /api/workers/documents/upload/
    ↓
    Show:
    - Document Type: Aadhar
    - Document Number: 123456...
    - Front Image (clickable to view)
    - Back Image (if uploaded)
    - Status: ✅ VERIFIED or ⏳ PENDING or ❌ REJECTED
    - Rejection Reason (if rejected)
```

---

## How to Implement

### Backend Setup

1. **Add Model to `workers/models.py`**:
   ```python
   # Import at top
   from .verification_models import WorkerDocumentVerification
   ```

2. **Add URLs in `workers/urls.py`**:
   ```python
   from .verification_views import WorkerDocumentUploadView, AdminDocumentVerificationView
   
   urlpatterns = [
       # ... existing URLs
       path('documents/upload/', WorkerDocumentUploadView.as_view(), name='worker-document-upload'),
       path('documents/admin/', AdminDocumentVerificationView.as_view(), name='admin-document-review'),
   ]
   ```

3. **Configure Media Storage in `backend/settings.py`**:
   ```python
   MEDIA_URL = '/media/'
   MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
   ```

4. **Run Migration**:
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

5. **Add to Admin in `workers/admin.py`**:
   ```python
   from .verification_models import WorkerDocumentVerification
   
   admin.site.register(WorkerDocumentVerification)
   ```

---

## Frontend Updates Needed

### Update `verification_screen.dart`

Change from local storage to API:

```dart
// OLD: Uses SharedPreferences
// NEW: Uses HTTP API

Future<void> _submitVerification() async {
    final formData = FormData.fromMap({
      'document_type': _selectedDocType, // 'aadhar', 'pan', etc
      'document_number': _govIdController.text,
      'document_image': await MultipartFile.fromFile(_selectedImagePath!),
    });
    
    final response = await Dio().post(
      '${ApiConstants.baseUrl}/workers/documents/upload/',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    
    if (response.statusCode == 200) {
      // Navigate to status screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DocumentStatusScreen()),
      );
    }
}
```

### Create `document_status_screen.dart`

Display current verification status:

```dart
// Show:
- Status badge (Pending/Verified/Rejected)
- Document type & number
- Uploaded images
- Rejection reason (if any)
- Option to resubmit if rejected
```

---

## Security Considerations

### ✅ Recommended Practices
1. **Validate image** on backend:
   - Check file type (only JPG/PNG)
   - Check file size (max 5MB)
   - Scan for malware

2. **Protect image storage**:
   - Use cloud storage (AWS S3) or private folder
   - Generate temporary signed URLs for viewing
   - Set expiration on URLs

3. **Audit trail**:
   - Log all approvals/rejections
   - Track who verified what and when
   - Keep historical records

4. **PII Protection**:
   - Mask ID numbers in logs
   - Encrypt sensitive fields
   - GDPR compliance for data retention

### ❌ Current Issues
- Images stored in SharedPreferences (insecure)
- No backend validation
- No audit trail
- No admin review process

---

## Testing the API

```bash
# 1. Upload document (as worker)
curl -X POST http://localhost:8000/api/workers/documents/upload/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "document_type=aadhar" \
  -F "document_number=123456789012" \
  -F "document_image=@path/to/image.jpg"

# 2. Check status (as worker)
curl -X GET http://localhost:8000/api/workers/documents/upload/ \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. Admin review (as admin)
curl -X GET http://localhost:8000/api/workers/documents/admin/?status=pending \
  -H "Authorization: Bearer ADMIN_TOKEN"

# 4. Approve document (as admin)
curl -X POST http://localhost:8000/api/workers/documents/admin/1/ \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"action": "approve"}'
```

---

## Summary

| Aspect | Current | Proposed |
|--------|---------|----------|
| **Storage** | Local (SharedPreferences) | Backend (Database + Media) |
| **Security** | ❌ Low | ✅ High |
| **Verification** | ❌ Manual review | ✅ Admin dashboard |
| **Scalability** | ❌ Limited | ✅ Unlimited |
| **Audit** | ❌ None | ✅ Full trail |
| **User Experience** | Shows "Pending" | Shows actual status |
| **Data Protection** | ❌ At risk | ✅ Secure |

---

## Next Steps

1. ✅ Models created (`verification_models.py`)
2. ✅ API views created (`verification_views.py`)
3. ⏳ Add URLs to `workers/urls.py`
4. ⏳ Create Flutter API service
5. ⏳ Update verification_screen.dart to use API
6. ⏳ Create document_status_screen.dart
7. ⏳ Add admin dashboard for verification
8. ⏳ Set up media file storage (S3, etc.)
