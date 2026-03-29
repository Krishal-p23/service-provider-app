# External ID Verification API Guide

## Overview
You asked about verifying Aadhaar/Government IDs through external APIs. This guide explains the options, trade-offs, and recommendations.

---

## 1. Available Verification Services (India)

### Aadhaar Verification (UIDAI)
**Service**: UIDAI eKYC API  
**Verification Level**: ✅ Real-time government verification  
**Requirements**:
- Partnership with UIDAI (Government of India agency)
- Strict compliance and audits
- KYC compliance (Know Your Customer)

**Pros**:
- ✅ Official government database
- ✅ Real-time verification
- ✅ High accuracy

**Cons**:
- ❌ Complex onboarding process
- ❌ High cost (₹1-5 per verification)
- ❌ Privacy concerns (storing biometric data)
- ❌ Long setup time (2-3 months)

**Timeline**: Not recommended for immediate MVP

---

### PAN Verification
**Service**: PAN validation via GST/Income Tax portal  
**Verification Level**: ⚠️ Partial (format + name matching)

**Current Status**: 
- No official real-time API
- 3rd party services exist (Setu, Razorpay, Stripe)

**Cost**: ₹5-10 per verification

---

### Driving License
**Service**: State RTO databases  
**Verification Level**: ⚠️ Varies by state

**Issues**:
- No centralized verification API
- State-by-state database access
- Difficult to implement

---

### Voter ID & Passport
**Status**: ❌ No public verification APIs available

---

## 2. Current Recommended Approach

### Phase 1: Manual Admin Verification ✅ (CURRENT)
```
[Worker Uploads] → [Admin Reviews Image] → [Approve/Reject]
```
**Advantages**:
- ✅ Zero additional cost
- ✅ Human verification (catches fakes)
- ✅ Quick to implement
- ✅ GDPR compliant (no external data sharing)
- ✅ Simple workflow

**Implementation**: Already done! Uses backend model + API

---

### Phase 2: Automated Image Validation (FUTURE - Easy)
```
[Worker Uploads] → [OCR Extracts ID] → [Format Validation] → [Admin Review]
```

**Tools**:
- AWS Textract ($0.015 per page)
- Google Vision API ($0.60 per 1000 requests)
- Microsoft Computer Vision

**What it does**:
- Reads ID number from image
- Validates format (e.g., Aadhaar = 12 digits)
- Flags suspicious documents
- Pre-fills forms automatically

**Effort**: 2-3 days to integrate

---

### Phase 3: External API Verification (FUTURE - Complex)
```
[Worker Uploads] → [OCR Extracts] → [External API Check] → [Admin Review]
```

**Possible Integrations**:

| Document | API Provider | Cost | Setup Time |
|----------|-------------|------|-----------|
| Aadhaar | Setu (GST verified) | ₹1-2 | 1-2 weeks |
| PAN | Setu / Razorpay | ₹5-10 | 1 week |
| Driving License | Setu | ₹3-5 | 1-2 weeks |
| Passport | Manual only | N/A | N/A |

---

## 3. Implementation Timeline Recommendation

### Week 1-2: ✅ DONE
- [x] Backend model for document storage
- [x] API endpoints for upload
- [x] Admin verification dashboard setup
- [x] Flutter UI with dropdown (document type selector)

### Week 3-4: ⏳ NEXT PRIORITY
- [ ] Complete backend integration (URL routing, migrations)
- [ ] Flutter API integration (call backend instead of SharedPreferences)
- [ ] Admin dashboard for reviewing documents
- [ ] Email notifications for status

### Month 2: OPTIONAL
- [ ] Add OCR (AWS Textract) for auto-extraction
- [ ] Add 3rd party API validation (Setu/Razorpay)
- [ ] Implement approval workflow email alerts

### Month 3+: ADVANCED
- [ ] Aadhaar eKYC (requires UIDAI partnership)
- [ ] Face matching (biometric verification)
- [ ] Liveness detection

---

## 4. Recommendation for Your App

### **Short-term** (Next 3 months):
**Stick with manual verification.**

```
Why:
✅ Faster to market
✅ Cheaper ($0 vs ₹1-5 per user)
✅ More control
✅ Better for building trust
✅ Can switch later if needed
```

### **Medium-term** (3-6 months):
**Add OCR verification.**

```
Cost: $30/month (1000 OCRs)
Benefit: Auto-validate ID format, catch fakes earlier
Time: 2 days to implement
```

### **Long-term** (6-12 months):
**Integrate Setu/Razorpay for real-time verification.**

```
Cost: ₹100-500/user
Benefit: Automated approval, less admin work
Time: 1-2 weeks to integrate
```

---

## 5. How to Implement in Django Backend

### Option A: No External API (Current)
```python
# Just store document and wait for admin review
POST /api/workers/documents/upload/
    ↓
    Save to database
    ↓
    Admin approves manually
```

### Option B: Add OCR (Future)
```python
# Extract ID number from image using OCR
import boto3  # AWS Textract

def upload_document(request):
    image = request.FILES['document_image']
    
    # Extract ID using AWS Textract
    textract = boto3.client('textract')
    response = textract.detect_document_text(Document={'Bytes': image.read()})
    extracted_text = response['Blocks'][0]['Text']
    
    # Validate format
    if validate_id_format(extracted_text):
        # Save with "PENDING" status for admin
        verification.status = 'pending'
    else:
        # Flag as suspicious
        verification.status = 'rejected'
        verification.rejection_reason = "Invalid ID format"
```

### Option C: Add 3rd Party API (Future)
```python
# Verify with Setu/Razorpay
import requests

def verify_with_external_api(document_type, id_number):
    """Verify using Setu API (example)"""
    url = 'https://api.setu.co/verify'
    
    response = requests.post(url, json={
        'document_type': document_type,  # 'aadhaar', 'pan', etc
        'document_number': id_number,
        'api_key': settings.SETU_API_KEY,
    })
    
    if response.status_code == 200:
        result = response.json()
        return result['is_valid']  # True/False
    
    return None  # API failed

# In your view
def upload_document(request):
    doc_type = request.data['document_type']
    id_number = request.data['document_number']
    
    # Verify with external service
    is_valid = verify_with_external_api(doc_type, id_number)
    
    if is_valid is True:
        verification.status = 'verified'  # Auto-approve
    elif is_valid is False:
        verification.status = 'rejected'
        verification.rejection_reason = "Invalid ID number"
    else:
        verification.status = 'pending'  # Wait for admin
```

---

## 6. Dependencies to Add (When Ready)

### For AWS Textract (OCR):
```bash
pip install boto3
```

Add to settings.py:
```python
AWS_ACCESS_KEY_ID = 'your_access_key'
AWS_SECRET_ACCESS_KEY = 'your_secret_key'
AWS_REGION = 'ap-south-1'  # Mumbai
```

### For Setu API (Real-time verification):
```bash
pip install requests
```

Add to settings.py:
```python
SETU_API_KEY = 'your_api_key'
SETU_API_URL = 'https://api.setu.co'
```

---

## 7. Quick Decision Tree

```
Do you need real-time verification?
    ↓
    NO (Current MVP phase)
    → Use manual admin verification ✅ (You're here)
    
    YES, but low volume?
    → Add admin dashboard for bulk review (Phase 2)
    
    YES, high volume?
    → Add OCR for auto-validation (Phase 2.5)
    
    YES, need automated approval?
    → Integrate Setu/Razorpay (Phase 3)
    
    YES, government compliance?
    → Aadhaar eKYC partnership (Phase 4)
```

---

## 8. Current Backend Status

✅ **What's ready** (with previous work):
- `WorkerDocumentVerification` model (stores documents)
- `WorkerDocumentUploadView` (handles uploads)
- `AdminDocumentVerificationView` (admin approval)
- Full database schema

📋 **Next steps**:
1. Add URL routing to `workers/urls.py`
2. Run Django migrations
3. Set up admin dashboard
4. Flutter API integration

🔮 **Future options** (when needed):
- OCR extraction (AWS Textract)
- Real-time API verification (Setu)
- Auto-approval workflows

---

## 9. Summary

| Stage | Implementation | Cost | Time | Priority |
|-------|----------------|------|------|----------|
| **Now** | Manual verification + dropdown | $0 | ✅ Done | ⭐⭐⭐ |
| **Phase 2** | Admin dashboard | $0 | 1 week | ⭐⭐ |
| **Phase 3** | OCR extraction | $30/mo | 2 days | ⭐⭐ |
| **Phase 4** | Setu API | ₹100-500/user | 1 week | ⭐ |
| **Phase 5** | Aadhaar eKYC | $1000+/mo | 2 months | ⭐ |

**Recommendation**: Keep Phase 1 (manual verification) for 2-3 months, then evaluate based on user volume.

---

## Questions?

**Should I add external APIs now?**
→ No, focus on completing Phase 1 first (backend + admin dashboard)

**Which API is best?**
→ Start with manual, then add Setu (most affordable + reliable)

**How much will external verification cost?**
→ ₹1-10 per user per verification (add to your pricing model)

**Can I change verification methods later?**
→ Yes! Our model design allows easy switching between manual → OCR → API

