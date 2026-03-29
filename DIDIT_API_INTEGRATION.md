# Didit API Integration Guide

## Overview
You've created a Didit account for **Aadhar-based identity verification**. This is an **optional enhancement** to your current system.

---

## Current System (MVP - Manual Verification) ✅

**What you have:**
- Workers upload ID documents (Aadhar, PAN, Driving License, etc.)
- Documents stored securely on Django server at `/media/worker_documents/`
- Admin manually reviews documents in Django admin panel
- Admin approves/rejects verification

**Status:** ✅ **WORKING NOW** - No API key needed

---

## Didit Integration (Phase 2 - Automated Verification)

### What Didit Does:
- **Auto-verifies Aadhar documents** using eKYC (electronic Know-Your-Customer)
- Extracts Aadhar number from image
- Validates against official Aadhar database
- Returns immediate verification result (✅ Verified, ❌ Failed, ⚠️ Needs Manual Review)

### Where to Put Your API Key:

**Option 1: Environment Variable (Recommended)**
```bash
# Create .env file in backend directory
DIDIT_API_KEY=e5f1f223-9731-4ea4-bfec-6bab13e6dd01
```

**Option 2: In Django Settings**
Edit `backend/backend/settings.py`:

```python
# Add at the end of the file (around line 200)

# Didit Identity Verification Settings
DIDIT_API_KEY = '
e5f1f223-9731-4ea4-bfec-6bab13e6dd01'
DIDIT_API_BASE_URL = 'https://api.didit.me/api'
DIDIT_ENABLED = True  # Set to False to disable auto-verification
```

---

## Will It Work? ✅ Yes, But...

### Current State: ✅ Works Without Didit
The app currently works with **manual verification only**:
1. Worker uploads document
2. Admin sees it in Django admin
3. Admin approves/rejects
4. Worker sees status in app

### With Didit: ✅ Auto-verification
1. Worker uploads document
2. **System auto-verifies via Didit** (if Aadhar document)
3. If verified → Status instantly changes to "Verified" ✅
4. If failed → Admin can manually review 
5. Worker sees status immediately

---

## Implementation Plan

### Phase 2 (Optional - Next)
**Create new Django file:** `backend/workers/didit_service.py`

```python
import requests
from django.conf import settings

class DiditVerificationService:
    @staticmethod
    def verify_aadhar(aadhar_number, image_path):
        """
        Verify Aadhar against Didit API
        Returns: {
            'verified': True/False,
            'status': 'verified'/'rejected'/'error',
            'error_message': 'If failed'
        }
        """
        if not settings.DIDIT_ENABLED:
            return {'verified': False, 'status': 'disabled'}
        
        try:
            # Read image file
            with open(image_path, 'rb') as f:
                files = {'document_image': f}
                headers = {'Authorization': f'Bearer {settings.DIDIT_API_KEY}'}
                
                response = requests.post(
                    f'{settings.DIDIT_API_BASE_URL}/verify-aadhar',
                    files=files,
                    data={'aadhar_number': aadhar_number},
                    headers=headers,
                    timeout=30
                )
            
            if response.status_code == 200:
                data = response.json()
                return {
                    'verified': data.get('verified', False),
                    'status': 'verified' if data.get('verified') else 'rejected'
                }
            else:
                return {'verified': False, 'status': 'error', 'error_message': response.text}
        
        except Exception as e:
            return {'verified': False, 'status': 'error', 'error_message': str(e)}
```

### Integrate into Upload View
**Modify:** `backend/workers/verification_views.py`

```python
from .didit_service import DiditVerificationService

class WorkerDocumentUploadView(APIView):
    def post(self, request):
        document_type = request.data.get('document_type')
        document_number = request.data.get('document_number')
        document_image = request.FILES.get('document_image')
        
        # Save document first
        verification = WorkerDocumentVerification.objects.create(
            worker=request.user.worker,
            document_type=document_type,
            document_number=document_number,
            document_image=document_image,
            status='pending'
        )
        
        # Try auto-verification if Aadhar
        if document_type == 'aadhar':
            result = DiditVerificationService.verify_aadhar(
                document_number, 
                verification.document_image.path
            )
            
            if result['verified']:
                verification.status = 'verified'
                verification.verified_at = timezone.now()
                verification.verified_by = None  # Auto-verified
                verification.save()
        
        return Response({'status': verification.get_status_display()})
```

---

## Decision

### Choose Your Path:

**Path A: Use Current Manual System (MVP)**
- ✅ Works now, no setup needed
- ✅ Full control over approvals
- ✅ Works for all document types
- ⚠️ Manual review takes time

**Path B: Add Didit for Auto-Aadhar (Phase 2)**
- ✅ Instant Aadhar verification
- ✅ Users get immediate feedback
- ✅ Manual review still available as fallback
- ⏳ Requires API key configuration (you have it now!)
- 💰 Didit API charges per verification

---

## Next Steps

1. **If staying with manual system:** Skip this, continue testing current system
2. **If adding Didit:** 
   - Create `backend/workers/didit_service.py`
   - Add API key to settings or `.env`
   - Modify `verification_views.py` to call Didit
   - Test with sample Aadhar upload
   - Add to other document types later (PAN, DL, etc.)

---

## Your API Key Reference
```
App ID: e5f1f223-9731-4ea4-bfec-6bab13e6dd01
Max file: 2 MB
Status: Active
```

**Keep this secure!** Don't commit to git - use environment variables in production.
