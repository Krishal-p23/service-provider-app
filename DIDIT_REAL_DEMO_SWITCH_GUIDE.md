# Didit KYC Mode Switch Guide (Real API <-> Demo Mock)

This project already supports both modes using environment variables and existing endpoints.

## Where mode is decided

Backend logic is in:
- `backend/workers/didit_service.py`
- `backend/workers/views.py` (`start_kyc_session`)

`POST /api/workers/kyc/start/` always calls `DiditVerificationService.create_verification_session(...)`.

From there:
1. If Didit config is valid, it creates a real Didit session (`is_mock: false`)
2. If config is missing/invalid and `DIDIT_ALLOW_MOCK_FALLBACK=True`, it returns mock page URL (`is_mock: true`)

---

## Env variables used

Defined in `backend/backend/settings.py`:
- `DIDIT_API_KEY`
- `DIDIT_API_ID` (optional)
- `DIDIT_WORKFLOW_ID`
- `DIDIT_WEBHOOK_SECRET`
- `DIDIT_BASE_URL` (default `https://verification.didit.me`)
- `DIDIT_ALLOW_MOCK_FALLBACK` (default `True`)
- `BACKEND_BASE_URL` (must be reachable by Didit for callback/webhook)

Note: `DIDIT_ENABLED` exists in settings but current KYC flow does not gate on it in code.

---

## Switch to REAL Didit API mode

Update `backend/.env` with real credentials and disable fallback:

```env
DIDIT_API_KEY=your_real_api_key
DIDIT_API_ID=your_real_api_id
DIDIT_WORKFLOW_ID=your_real_workflow_id
DIDIT_WEBHOOK_SECRET=your_real_webhook_secret
DIDIT_BASE_URL=https://verification.didit.me
BACKEND_BASE_URL=https://your-public-backend-url
DIDIT_ALLOW_MOCK_FALLBACK=False
```

Important:
1. `BACKEND_BASE_URL` must be public (not localhost) for Didit webhooks.
2. Configure Didit webhook URL to:
   - `https://your-public-backend-url/api/workers/kyc/webhook/`
3. Restart Django server after env changes.

Expected behavior:
- Start KYC returns real Didit URL
- Worker status becomes `pending`
- After approved webhook, DB updates:
  - `is_verified = TRUE`
  - `verification_status = 'approved'`

---

## Switch back to DEMO (mock) mode

Use any one of these safe options.

### Option A (recommended): keep fallback ON + remove/break credentials

```env
DIDIT_ALLOW_MOCK_FALLBACK=True
DIDIT_API_KEY=
DIDIT_WORKFLOW_ID=
```

(You can keep `DIDIT_BASE_URL` as default.)

### Option B: keep credentials but force network/config failure intentionally

If credentials are present but you still want demo, easiest is Option A. Demo kicks in when live call cannot be used and fallback is `True`.

Restart Django server after changes.

Expected behavior:
- Start KYC returns:
  - `session_url`: `/api/workers/kyc/mock/?worker_id=...`
  - `is_mock: true`

---

## Manual demo endpoints (already available)

- Mock page:
  - `GET /api/workers/kyc/mock/?worker_id=<worker_id>`
- Approve in DB:
  - `POST /api/workers/kyc/mock-approve/?worker_id=<worker_id>`
- Reject in DB:
  - `POST /api/workers/kyc/mock-reject/?worker_id=<worker_id>`

These endpoints update DB directly for testing.

---

## Quick verification checklist

1. Worker is not already verified before starting KYC.
2. Start KYC from app.
3. Check API response field:
   - `is_mock=false` -> Real mode
   - `is_mock=true` -> Demo mode
4. Confirm DB status in `workers` table.

---

## Common pitfalls

1. `BACKEND_BASE_URL` is localhost while testing real webhook.
   - Didit cannot call localhost.
2. Server not restarted after `.env` changes.
3. `DIDIT_ALLOW_MOCK_FALLBACK=True` with bad creds causes silent fallback to demo (by design).
4. Worker already verified -> start endpoint returns "already verified".

---

## Suggested command sequence after changing mode

From `backend/`:

```bash
python manage.py runserver 0.0.0.0:8000
```

Then test start endpoint from app or API client:

```http
POST /api/workers/kyc/start/
Authorization: Bearer <user_id>
```

Check `is_mock` in response.
