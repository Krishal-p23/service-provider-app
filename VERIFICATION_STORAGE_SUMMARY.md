# WORKER ID VERIFICATION - CURRENT STATE & STORAGE

## 🔴 CURRENT ISSUE: NO PROPER BACKEND STORAGE

### Where Photos Are Currently Stored:

**Frontend Only (Not Recommended)**:
- 📱 Local device storage: `SharedPreferences`
- 🗂️ Temporary cache during upload
- ❌ **NOT synced to server**
- ❌ **Lost if app is uninstalled**

**File**: `lib/worker/screens/verification_screen.dart` (Flutter)

```dart
// Currently just stores locally:
_govIdController.text → Stored in SharedPreferences
_selectedImagePath → Just file path on device
```

**Backend**: 
- 🚫 **NO DATABASE FIELDS** for ID documents
- 🚫 **NO API ENDPOINTS** for upload
- 🚫 **NO VERIFICATION WORKFLOW**

---

## ✅ WHAT I'VE CREATED FOR YOU

### 1. Database Model
**File**: `backend/workers/verification_models.py` ✅

Stores:
- Document type (Aadhar, PAN, Driving License, Passport)
- Document number (ID number)
- Front image (uploaded to media folder)
- Back image (optional)
- Verification status (Pending, Verified, Rejected)
- Admin notes and timestamps

### 2. API Endpoints
**File**: `backend/workers/verification_views.py` ✅

**For Workers**:
- `POST /api/workers/documents/upload/` - Upload ID document
- `GET /api/workers/documents/upload/` - Check verification status

**For Admins**:
- `GET /api/workers/documents/admin/` - View all pending documents
- `POST /api/workers/documents/admin/{id}/` - Approve/Reject document

### 3. Complete Documentation
**File**: `WORKER_VERIFICATION_GUIDE.md` ✅

---

## 📊 COMPARISON

### Current Flow (❌ Insecure)
```
Worker App
    ↓
Fills ID form
    ↓
Uploads image
    ↓
Stored in SharedPreferences (device only)
    ↓
❌ Lost if app deleted
❌ No admin verification
❌ No audit trail
```

### Proposed Flow (✅ Secure)
```
Worker App
    ↓
Fills ID form
    ↓
Uploads image to API
    ↓
Backend saves to: /media/worker_documents/YYYY/MM/DD/
    ↓
Stored in Database with full record
    ↓
Admin Dashboard
    ↓
Admin reviews document
    ↓
Approve → Worker gets verified badge
    ↓
✅ Secure
✅ Auditable
✅ Scalable
```

---

## 🔐 HOW TO VERIFY DOCUMENTS

### Admin Verification Process:

```
1. Admin Login to Dashboard
   ↓
2. Go to "Verification" → "Pending Documents"
   ↓
3. See Worker's:
   - Name & ID
   - Document type (Aadhar, PAN, etc)
   - Front & Back images
   - Document number
   ↓
4. Verify by checking:
   - ✓ Image quality (clear, not blurry)
   - ✓ Document validity (not expired)
   - ✓ ID number format (correct for type)
   - ✓ Document authenticity (compare if needed)
   ↓
5. Click:
   - APPROVE ✅ → Worker account fully verified
   OR
   - REJECT ❌ → Send rejection reason to worker
```

---

## 📁 FILE STORAGE LOCATIONS

### Backend Storage:
```
project/
├── media/
│   └── worker_documents/
│       └── 2026/03/26/
│           ├── worker_1_aadhar_front.jpg
│           ├── worker_1_aadhar_back.jpg
│           ├── worker_2_pan.jpg
│           └── worker_3_driving_license_front.jpg
```

### Database Records:
```
worker_document_verification table:
│ ID │ Worker │ Type   │ Number      │ Status   │ Image Path                        │
├────┼────────┼────────┼─────────────┼──────────┼───────────────────────────────────┤
│ 1  │ krishal│ aadhar │ 123456789   │ verified │ worker_documents/2026/03/26/...   │
│ 2  │ akanshaaj│ pan  │ ABCDE1234F │ pending  │ worker_documents/2026/03/26/...   │
```

---

## 🚀 NEXT STEPS

### 1. Backend Setup (Django)
```bash
# Add to workers/urls.py:
from .verification_views import WorkerDocumentUploadView, AdminDocumentVerificationView

urlpatterns = [
    path('documents/upload/', WorkerDocumentUploadView.as_view()),
    path('documents/admin/', AdminDocumentVerificationView.as_view()),
]

# Run migrations:
python manage.py makemigrations
python manage.py migrate
```

### 2. Frontend Update (Flutter)
Replace current `verification_screen.dart` to:
- Upload to API instead of SharedPreferences
- Show real-time verification status
- Display rejection reasons

### 3. Create Admin Dashboard
- View pending documents
- Approve/Reject with admin notes
- Download images for manual verification

### 4. Optional Enhancements
- **OCR**: Automatically read ID numbers from images
- **Video KYC**: Record video for additional verification
- **Self-signing**: Use device fingerprint to prevent fraud
- **Blockchain**: Store verification proofs immutably

---

## 🔒 SECURITY NOTES

### ✅ Best Practices Implemented:
- Database linked to Worker profile
- Status tracking (pending/verified/rejected)
- Admin audit trail
- Timestamped records
- Rejection reason logging

### ⚠️ Still Needed:
- [ ] Use AWS S3 or secure cloud storage (don't save locally)
- [ ] Add image validation (size, format, quality)
- [ ] Add malware scanning
- [ ] Integrate with government ID verification APIs (if available)
- [ ] Add GDPR data retention policies
- [ ] Encrypt sensitive fields in database

---

## 📞 SUMMARY

| Question | Answer |
|----------|--------|
| **Where are IDs stored now?** | LocalDevice (SharedPreferences) ❌ |
| **Where should they be stored?** | Backend `/media/worker_documents/` ✅ |
| **How to verify?** | Admin dashboard with image review ✅ |
| **Secure?** | Current: No ❌ / Future: Yes ✅ |
| **Can be audited?** | Current: No ❌ / Future: Yes ✅ |

---

## All Files Created:

1. ✅ `backend/workers/verification_models.py` - Database model
2. ✅ `backend/workers/verification_views.py` - API endpoints
3. ✅ `WORKER_VERIFICATION_GUIDE.md` - Full documentation

Ready to integrate! Let me know if you need help with any specific part.
