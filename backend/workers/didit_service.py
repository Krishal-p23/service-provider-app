import logging

import requests
from django.conf import settings
from django.db import connection
from requests import RequestException

logger = logging.getLogger(__name__)


class DiditVerificationService:
    STATUS_APPROVED = "approved"
    STATUS_PENDING = "pending"
    STATUS_REJECTED = "rejected"

    @staticmethod
    def _didit_headers() -> dict:
        headers = {
            "X-API-Key": settings.DIDIT_API_KEY,
            "Content-Type": "application/json",
        }
        didit_api_id = (getattr(settings, "DIDIT_API_ID", "") or "").strip()
        if didit_api_id:
            headers["X-API-Id"] = didit_api_id
        return headers

    @staticmethod
    def _normalize_status(raw_status: str) -> str:
        value = str(raw_status or "").strip().lower().replace("_", " ")
        if value in ("approved", "verified", "success", "completed"):
            return DiditVerificationService.STATUS_APPROVED
        if value in ("declined", "rejected", "failed", "abandoned"):
            return DiditVerificationService.STATUS_REJECTED
        if value in ("not started", "in progress", "in review", "pending", "review"):
            return DiditVerificationService.STATUS_PENDING
        return DiditVerificationService.STATUS_PENDING

    @staticmethod
    def _list_sessions(vendor_data: str, limit: int = 5) -> list:
        list_url = f"{settings.DIDIT_BASE_URL.rstrip('/')}/v3/sessions"
        params = {
            "vendor_data": str(vendor_data or "").strip(),
            "offset": 0,
            "limit": max(1, min(limit, 20)),
        }
        workflow_id = (getattr(settings, "DIDIT_WORKFLOW_ID", "") or "").strip()
        if workflow_id:
            params["workflow_id"] = workflow_id

        response = requests.get(
            list_url,
            headers=DiditVerificationService._didit_headers(),
            params=params,
            timeout=20,
        )
        if response.status_code != 200:
            logger.warning(
                "[DiditService] List sessions failed (%s): %s",
                response.status_code,
                (response.text or "")[:500],
            )
            return []

        payload = response.json() if response.content else {}
        results = payload.get("results") if isinstance(payload, dict) else []
        return results if isinstance(results, list) else []

    @staticmethod
    def _retrieve_session_status(session_id: str) -> str | None:
        if not session_id:
            return None

        retrieve_url = f"{settings.DIDIT_BASE_URL.rstrip('/')}/v3/session/{session_id}/decision/"
        response = requests.get(
            retrieve_url,
            headers=DiditVerificationService._didit_headers(),
            timeout=20,
        )
        if response.status_code != 200:
            logger.warning(
                "[DiditService] Retrieve session failed (%s) for %s: %s",
                response.status_code,
                session_id,
                (response.text or "")[:500],
            )
            return None

        payload = response.json() if response.content else {}
        if not isinstance(payload, dict):
            return None

        return DiditVerificationService._normalize_status(payload.get("status"))

    @staticmethod
    def retrieve_session_result(session_id: str) -> dict:
        """Retrieve session decision payload and normalize status/vendor_data."""
        if not settings.DIDIT_BASE_URL or not settings.DIDIT_API_KEY:
            return {
                "success": False,
                "status": None,
                "vendor_data": None,
                "message": "Didit is not configured",
            }
        if not session_id:
            return {
                "success": False,
                "status": None,
                "vendor_data": None,
                "message": "Missing session id",
            }

        retrieve_url = f"{settings.DIDIT_BASE_URL.rstrip('/')}/v3/session/{session_id}/decision/"
        response = requests.get(
            retrieve_url,
            headers=DiditVerificationService._didit_headers(),
            timeout=20,
        )
        if response.status_code != 200:
            logger.warning(
                "[DiditService] Retrieve decision failed (%s) for %s: %s",
                response.status_code,
                session_id,
                (response.text or "")[:500],
            )
            return {
                "success": False,
                "status": None,
                "vendor_data": None,
                "message": "Retrieve session failed",
            }

        payload = response.json() if response.content else {}
        if not isinstance(payload, dict):
            return {
                "success": False,
                "status": None,
                "vendor_data": None,
                "message": "Invalid session payload",
            }

        return {
            "success": True,
            "status": DiditVerificationService._normalize_status(payload.get("status")),
            "vendor_data": payload.get("vendor_data"),
            "session_id": payload.get("session_id") or session_id,
        }

    @staticmethod
    def get_latest_verification_status(vendor_candidates: list[str]) -> dict:
        """Fetch and normalize the latest Didit verification status for any vendor candidate."""
        if not settings.DIDIT_BASE_URL or not settings.DIDIT_API_KEY:
            return {
                "success": False,
                "status": None,
                "message": "Didit is not configured",
            }

        for candidate in vendor_candidates:
            candidate_value = str(candidate or "").strip()
            if not candidate_value:
                continue

            try:
                sessions = DiditVerificationService._list_sessions(candidate_value)
            except RequestException as exc:
                logger.warning(
                    "[DiditService] List sessions request failed for %s: %s",
                    candidate_value,
                    exc,
                )
                continue
            except ValueError as exc:
                logger.warning(
                    "[DiditService] List sessions decode failed for %s: %s",
                    candidate_value,
                    exc,
                )
                continue

            if not sessions:
                continue

            # API returns latest-first in practice; if not, this still resolves with newest created_at.
            session = sessions[0]
            session_id = str(session.get("session_id") or "").strip()
            listed_status = DiditVerificationService._normalize_status(session.get("status"))

            try:
                status = DiditVerificationService._retrieve_session_status(session_id) or listed_status
            except RequestException as exc:
                logger.warning(
                    "[DiditService] Retrieve session request failed for %s: %s",
                    session_id,
                    exc,
                )
                status = listed_status
            except ValueError as exc:
                logger.warning(
                    "[DiditService] Retrieve session decode failed for %s: %s",
                    session_id,
                    exc,
                )
                status = listed_status

            return {
                "success": True,
                "status": status,
                "session_id": session_id,
                "vendor_data": session.get("vendor_data"),
            }

        return {
            "success": False,
            "status": None,
            "message": "No sessions found for provided vendor data",
        }

    @staticmethod
    def _mock_session(worker_id: int, reason: str) -> dict:
        return {
            "success": True,
            "session_id": f"mock_session_{worker_id}",
            "session_url": f"{settings.BACKEND_BASE_URL}/api/workers/kyc/mock/?worker_id={worker_id}",
            "is_mock": True,
            "message": reason,
        }

    @staticmethod
    def create_verification_session(worker_id: int, callback_url: str) -> dict:
        """Create a Didit verification session. Uses live API call first, optional mock fallback."""
        allow_mock_fallback = bool(getattr(settings, "DIDIT_ALLOW_MOCK_FALLBACK", True))

        if not settings.DIDIT_BASE_URL or not settings.DIDIT_WORKFLOW_ID:
            logger.error("[DiditService] Missing DIDIT_BASE_URL or DIDIT_WORKFLOW_ID")
            if allow_mock_fallback:
                return DiditVerificationService._mock_session(
                    worker_id,
                    "Using demo KYC because Didit settings are incomplete",
                )
            return {"success": False, "message": "There is some issue, please try later"}

        if not settings.DIDIT_API_KEY:
            logger.error("[DiditService] Missing DIDIT_API_KEY")
            if allow_mock_fallback:
                return DiditVerificationService._mock_session(
                    worker_id,
                    "Using demo KYC because API key is missing",
                )
            return {"success": False, "message": "There is some issue, please try later"}

        session_url = f"{settings.DIDIT_BASE_URL.rstrip('/')}/v1/session/"
        payload = {
            "workflow_id": settings.DIDIT_WORKFLOW_ID,
            "callback": callback_url,
            "vendor_data": str(worker_id),
        }

        headers = DiditVerificationService._didit_headers()
        didit_api_id = bool(headers.get("X-API-Id"))

        logger.info(
            "[DiditService] Creating live session at %s (workflow_id=%s, api_id_set=%s)",
            session_url,
            settings.DIDIT_WORKFLOW_ID,
            didit_api_id,
        )

        try:
            response = requests.post(
                session_url,
                headers=headers,
                json=payload,
                timeout=20,
            )
        except RequestException as exc:
            logger.error("[DiditService] Live session request failed: %s", exc)
            if allow_mock_fallback:
                return DiditVerificationService._mock_session(
                    worker_id,
                    "Using demo KYC because live Didit service is unreachable",
                )
            return {"success": False, "message": "There is some issue, please try later"}

        if response.status_code == 201:
            try:
                data = response.json()
            except ValueError:
                logger.error("[DiditService] Live session JSON parse failed")
                if allow_mock_fallback:
                    return DiditVerificationService._mock_session(
                        worker_id,
                        "Using demo KYC because live Didit response was invalid",
                    )
                return {"success": False, "message": "There is some issue, please try later"}

            # Update worker's verification status to 'pending' when session is created
            try:
                with connection.cursor() as cursor:
                    cursor.execute(
                        "UPDATE workers SET verification_status = %s WHERE id = %s",
                        ['pending', worker_id],
                    )
                logger.info(
                    "[DiditService] Updated worker %s verification_status to 'pending'",
                    worker_id,
                )
            except Exception as e:
                logger.warning(
                    "[DiditService] Failed to update verification_status for worker %s: %s",
                    worker_id,
                    e,
                )

            logger.info("[DiditService] Live session created: %s", data.get("session_id"))
            return {
                "success": True,
                "session_id": data.get("session_id"),
                "session_url": data.get("url"),
                "is_mock": False,
            }

        logger.error(
            "[DiditService] Live session creation failed (%s): %s",
            response.status_code,
            (response.text or "")[:500],
        )
        if allow_mock_fallback:
            return DiditVerificationService._mock_session(
                worker_id,
                "Using demo KYC because live Didit credentials/config were rejected",
            )
        return {"success": False, "message": "There is some issue, please try later"}
