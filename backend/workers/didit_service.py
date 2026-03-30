import logging

import requests
from django.conf import settings
from django.db import connection
from requests import RequestException

logger = logging.getLogger(__name__)


class DiditVerificationService:
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

        headers = {
            "X-API-Key": settings.DIDIT_API_KEY,
            "Content-Type": "application/json",
        }
        didit_api_id = (getattr(settings, "DIDIT_API_ID", "") or "").strip()
        if didit_api_id:
            headers["X-API-Id"] = didit_api_id

        logger.info(
            "[DiditService] Creating live session at %s (workflow_id=%s, api_id_set=%s)",
            session_url,
            settings.DIDIT_WORKFLOW_ID,
            bool(didit_api_id),
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
