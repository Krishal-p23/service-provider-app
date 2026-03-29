# Job OTP Activation System - Implementation Guide

## Overview
This document explains the complete OTP (One-Time Password) verification system for job activation. When a worker starts a job, they must verify with an OTP that the customer provides.

## Architecture

### Backend Flow
1. **OTP Generation** (`POST /api/bookings/<booking_id>/initiate-otp/`)
   - Generates a random 4-digit OTP
   - Stores in `job_otp` database table
   - Sets expiry to 10 minutes from now
   - In production: sends via SMS/Email to customer
   - Demo: returns OTP in response

2. **OTP Verification** (`POST /api/bookings/<booking_id>/verify-otp/`)
   - Worker enters 4-digit OTP
   - Backend verifies: correct OTP, not expired, not already used
   - Marks OTP as used
   - Updates booking status from pending → in_progress

### Frontend Flow
1. Worker taps "Start Job" button
2. Navigated to `JobOTPVerificationScreen`
3. Worker enters 4-digit OTP
4. Frontend calls `verifyJobOTP()` API method
5. On success: job marked as active, returns to jobs list

---

## Backend Implementation

### Files Created/Modified

#### 1. `backend/bookings/otp_utils.py` (NEW)
Utility functions for OTP management:
- `generate_otp(length=4)` - Creates random 4-digit OTP
- `create_job_otp_table()` - Creates table if missing (SQLite/Postgres compatible)
- `save_job_otp()` - Stores OTP with booking_id, customer_id, worker_id
- `verify_job_otp()` - Validates OTP, checks expiry, marks as used
- `get_otp_info()` - Debugging function to retrieve current OTP

#### 2. `backend/bookings/views.py` (MODIFIED)
Added two new endpoints:

```python
@csrf_exempt
@require_http_methods(["POST"])
def initiate_job_otp(request):
    """POST /api/bookings/<booking_id>/initiate-otp/"""
    # Generates and stores OTP
    # Returns OTP in response (for demo; remove in production)
    # Expires in 10 minutes

@csrf_exempt
@require_http_methods(["POST"])
def verify_job_otp_endpoint(request):
    """POST /api/bookings/<booking_id>/verify-otp/"""
    # Verifies OTP entered by worker
    # Updates booking status to in_progress on success
```

#### 3. `backend/bookings/urls.py` (MODIFIED)
Added two new routes:
```python
path('<int:booking_id>/initiate-otp/', initiate_job_otp, name='initiate_job_otp'),
path('<int:booking_id>/verify-otp/', verify_job_otp_endpoint, name='verify_job_otp'),
```

### Database Schema
The `job_otp` table is automatically created:
```sql
CREATE TABLE job_otp (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    booking_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    worker_id INTEGER NOT NULL,
    otp TEXT NOT NULL,
    is_used BOOLEAN DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    verified_at DATETIME NULL
);
```

---

## Frontend Implementation

### Files Modified

#### 1. `flutter_project/lib/customer/services/api_service.dart` (MODIFIED)
Added two new API methods:

```dart
/// Initiate job OTP - generate and send OTP to customer
Future<Map<String, dynamic>> initiateJobOTP({required int bookingId}) async

/// Verify job OTP and activate job
Future<Map<String, dynamic>> verifyJobOTP({
  required int bookingId,
  required String otp,
}) async
```

#### 2. `flutter_project/lib/worker/screens/job_otp_verification_screen.dart` (MODIFIED)
Updated the OTP verification screen to:
- Accept `bookingId` as parameter (along with existing `job`)
- Call backend API for verification instead of hardcoded demo
- Handle network errors gracefully
- Show appropriate error messages

---

## Usage

### Step 1: Initiating OTP (When Worker Starts Job)
The system should call initiate OTP when worker presses "Start Job":

```dart
final result = await _apiService.initiateJobOTP(bookingId: booking.id);
if (result['success'] == true) {
  // OTP generated and sent to customer
  // In demo mode, check result['data']['otp'] from response
  final otp = result['data']['otp']; // Demo only - remove in production!
}
```

### Step 2: Worker Enters OTP
Worker navigates to OTP verification screen:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => JobOTPVerificationScreen(
      job: job,
      bookingId: booking.id, // Pass booking ID
    ),
  ),
);
```

### Step 3: Verification Backend Handles
Frontend automatically calls:
```dart
final result = await _apiService.verifyJobOTP(
  bookingId: bookingId,
  otp: enteredOTP,
);
```

On success:
- Booking status changes to `in_progress`
- Worker is returned to jobs list
- Success snackbar shown

---

## Testing Flow

### Manual Testing via Postman/cURL

**1. Initiate OTP:**
```bash
curl -X POST http://localhost:8000/api/bookings/1/initiate-otp/ \
  -H "Content-Type: application/json" \
  -d '{"booking_id": 1}'
```

Response (demo):
```json
{
  "status": "success",
  "data": {
    "booking_id": 1,
    "otp": "7382",
    "validity_minutes": 10,
    "message": "OTP sent to customer. Valid for 10 minutes."
  }
}
```

**2. Verify OTP:**
```bash
curl -X POST http://localhost:8000/api/bookings/1/verify-otp/ \
  -H "Content-Type: application/json" \
  -d '{"booking_id": 1, "otp": "7382"}'
```

Response (success):
```json
{
  "status": "success",
  "message": "Job activated successfully",
  "data": {"booking_id": 1}
}
```

Response (error):
```json
{
  "status": "error",
  "message": "Invalid or expired OTP",
  "code": "INVALID_OTP"
}
```

---

## Production Considerations

### Security & SMS Integration
Currently, the system returns OTP in API response for demo purposes. **In production:**

1. **Remove OTP from Response**: Never return actual OTP in API
   ```python
   # REMOVE THIS LINE in production:
   "otp": otp,  # Remove in production!
   ```

2. **Send via SMS/Email**:
   ```python
   # Add after save_job_otp():
   send_otp_via_sms(customer_phone, otp)
   # OR
   send_otp_via_email(customer_email, otp)
   ```

3. **Use Twilio or Similar Service**:
   ```python
   from twilio.rest import Client
   
   def send_otp_via_sms(phone_number, otp):
       client = Client(account_sid, auth_token)
       client.messages.create(
           to=phone_number,
           from_="+1234567890",
           body=f"Your OTP to activate the job is: {otp}. Valid for 10 minutes."
       )
   ```

4. **Increase Expiry if Using Email** (10 min good for SMS, 30 min for email)
   ```python
   save_job_otp(booking_id, customer_id, worker_id, otp, validity_minutes=30)
   ```

### OTP Attempts & Rate Limiting
Add max attempts:
```python
def verify_job_otp(booking_id, otp):
    # Check failed attempts
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT COUNT(*) FROM job_otp
            WHERE booking_id = %s AND is_used = 0
            AND created_at > NOW() - INTERVAL 10 MINUTE
        """, [booking_id])
        attempts = cursor.fetchone()[0]
        
    if attempts > 5:
        return False  # Too many attempts
```

### Audit & Logging
Log all OTP activities for compliance:
```python
def log_otp_activity(booking_id, worker_id, action, status):
    with connection.cursor() as cursor:
        cursor.execute("""
            INSERT INTO otp_audit_log (booking_id, worker_id, action, status, created_at)
            VALUES (%s, %s, %s, %s, NOW())
        """, [booking_id, worker_id, action, status])
```

---

## Error Handling

The system gracefully handles:
- Missing OTP: "Please enter complete OTP"
- Expired OTP (> 10 min): "Invalid or expired OTP"
- Already used OTP: "Invalid or expired OTP"
- Wrong OTP: "Invalid or expired OTP"
- Network errors: "Network error. Please try again."

---

## Debug Mode

Enable demo OTP in development:
```python
# In otp_utils.py, for testing only:
def verify_job_otp_demo(booking_id, otp):
    """Development only - Accept demo OTP '1234'"""
    if otp == '1234':
        return True
    return verify_job_otp(booking_id, otp)
```

---

## Summary

**What the user provides:**
- `booking_id`: Which job to activate
- `otp`: 4-digit code customer gives

**What the system does:**
1. Generates random 4-digit OTP
2. Stores in DB with 10-min expiry
3. (Future) Sends to customer
4. Worker enters it
5. Backend verifies & activates booking

**Files involved:**
- Backend: `otp_utils.py`, `views.py`, `urls.py`
- Frontend: `api_service.dart`, `job_otp_verification_screen.dart`
- Database: Auto-created `job_otp` table
