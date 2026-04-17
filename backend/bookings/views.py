import json
from django.http import JsonResponse
from django.db import connection
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from datetime import datetime
from django.conf import settings
import requests
import uuid
from .email_service import send_worker_job_email


ACTIVE_BOOKING_STATUSES = ("pending", "confirmed", "in_progress")
BOOKING_ALLOWED_STATUSES = (
	"pending",
	"confirmed",
	"in_progress",
	"awaiting_payment",
	"completed",
	"cancelled",
)


def _ensure_booking_status_constraint():
	"""Ensure Postgres status check constraint allows awaiting_payment lifecycle."""
	if connection.vendor != "postgresql":
		return

	with connection.cursor() as cursor:
		cursor.execute(
			"""
			ALTER TABLE bookings
			DROP CONSTRAINT IF EXISTS bookings_status_check
			"""
		)
		cursor.execute(
			"""
			ALTER TABLE bookings
			ADD CONSTRAINT bookings_status_check
			CHECK (
				LOWER(status) IN (
					'pending',
					'confirmed',
					'in_progress',
					'awaiting_payment',
					'completed',
					'cancelled'
				)
			)
			"""
		)


def _ensure_worker_availability_table():
	"""Create worker_availability table if missing (SQLite/Postgres)."""
	with connection.cursor() as cursor:
		if connection.vendor == "postgresql":
			cursor.execute(
				"""
				CREATE TABLE IF NOT EXISTS worker_availability (
					id SERIAL PRIMARY KEY,
					worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE CASCADE,
					day_of_week INTEGER NOT NULL,
					start_time TIME NOT NULL,
					end_time TIME NOT NULL,
					is_available BOOLEAN NOT NULL DEFAULT TRUE,
					created_at TIMESTAMP NOT NULL DEFAULT NOW(),
					updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
					UNIQUE(worker_id, day_of_week)
				)
				"""
			)


def _ensure_booking_cancellation_columns():
	"""Ensure cancellation metadata columns exist on bookings table."""
	with connection.cursor() as cursor:
		if connection.vendor == "postgresql":
			cursor.execute(
				"ALTER TABLE bookings ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMP NULL"
			)
			cursor.execute(
				"ALTER TABLE bookings ADD COLUMN IF NOT EXISTS cancelled_by VARCHAR(20) NULL"
			)
		else:
			cursor.execute(
				"""
				CREATE TABLE IF NOT EXISTS worker_availability (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					worker_id INTEGER NOT NULL,
					day_of_week INTEGER NOT NULL,
					start_time TEXT NOT NULL,
					end_time TEXT NOT NULL,
					is_available BOOLEAN NOT NULL DEFAULT 1,
					created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
					updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
					UNIQUE(worker_id, day_of_week)
				)
				"""
			)


def _ensure_booking_reschedule_columns():
	"""Ensure reschedule metadata columns exist on bookings table."""
	with connection.cursor() as cursor:
		if connection.vendor == "postgresql":
			cursor.execute(
				"ALTER TABLE bookings ADD COLUMN IF NOT EXISTS previous_scheduled_date TIMESTAMP NULL"
			)
			cursor.execute(
				"ALTER TABLE bookings ADD COLUMN IF NOT EXISTS rescheduled_at TIMESTAMP NULL"
			)
			cursor.execute(
				"ALTER TABLE bookings ADD COLUMN IF NOT EXISTS rescheduled_by VARCHAR(20) NULL"
			)
			cursor.execute(
				"ALTER TABLE bookings ADD COLUMN IF NOT EXISTS reschedule_reason TEXT NULL"
			)
		else:
			cursor.execute("PRAGMA table_info(bookings)")
			existing_columns = {
				str(row[1]).strip().lower()
				for row in cursor.fetchall()
				if row and len(row) > 1 and row[1]
			}

			if "previous_scheduled_date" not in existing_columns:
				cursor.execute("ALTER TABLE bookings ADD COLUMN previous_scheduled_date DATETIME NULL")
			if "rescheduled_at" not in existing_columns:
				cursor.execute("ALTER TABLE bookings ADD COLUMN rescheduled_at DATETIME NULL")
			if "rescheduled_by" not in existing_columns:
				cursor.execute("ALTER TABLE bookings ADD COLUMN rescheduled_by TEXT NULL")
			if "reschedule_reason" not in existing_columns:
				cursor.execute("ALTER TABLE bookings ADD COLUMN reschedule_reason TEXT NULL")


def _serialize_booking_row(row):
	def _row_value(index):
		return row[index] if len(row) > index else None

	return {
		"id": _row_value(0),
		"user_id": _row_value(1),
		"worker_id": _row_value(2),
		"service_id": _row_value(3),
		"scheduled_date": _row_value(4).isoformat() if _row_value(4) else None,
		"status": _row_value(5),
		"total_amount": float(_row_value(6) or 0),
		"created_at": _row_value(7).isoformat() if _row_value(7) else None,
		"worker_name": _row_value(8),
		"service_name": _row_value(9),
		"activation_otp": _row_value(10),
		"otp_expires_at": (
			_row_value(11).isoformat()
			if hasattr(_row_value(11), "isoformat")
			else (str(_row_value(11)) if _row_value(11) else None)
		),
		"previous_scheduled_date": (
			_row_value(12).isoformat()
			if hasattr(_row_value(12), "isoformat")
			else (str(_row_value(12)) if _row_value(12) else None)
		),
		"rescheduled_at": (
			_row_value(13).isoformat()
			if hasattr(_row_value(13), "isoformat")
			else (str(_row_value(13)) if _row_value(13) else None)
		),
		"rescheduled_by": _row_value(14),
		"reschedule_reason": _row_value(15),
	}


def send_fcm_notification(fcm_token, title, body, data=None):
	"""Send push notification via FCM legacy HTTP API."""
	if not settings.FCM_SERVER_KEY or not fcm_token:
		return {"success": False, "message": "FCM not configured"}

	try:
		response = requests.post(
			"https://fcm.googleapis.com/fcm/send",
			headers={
				"Authorization": f"key={settings.FCM_SERVER_KEY}",
				"Content-Type": "application/json",
			},
			json={
				"to": fcm_token,
				"notification": {
					"title": title,
					"body": body,
				},
				"data": data or {},
			},
			timeout=10,
		)
		return {"success": response.status_code == 200, "status_code": response.status_code}
	except Exception as exc:
		return {"success": False, "message": str(exc)}


@csrf_exempt
@require_http_methods(["GET"])
def user_bookings(request, user_id):
	"""GET /api/bookings/user/<user_id>/ - all bookings for a customer."""
	try:
		# Ensure OTP table exists so booking list can include activation OTP metadata.
		from .otp_utils import create_job_otp_table
		create_job_otp_table()
		_ensure_booking_reschedule_columns()

		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT
					b.id,
					b.user_id,
					b.worker_id,
					b.service_id,
					b.scheduled_date,
					b.status,
					b.total_amount,
					b.created_at,
					u.name AS worker_name,
					s.service_name,
					(
						SELECT jo.otp
						FROM job_otp jo
						WHERE jo.booking_id = b.id
						  AND jo.is_used = FALSE
						  AND jo.expires_at > CURRENT_TIMESTAMP
						ORDER BY jo.created_at DESC
						LIMIT 1
					) AS activation_otp,
					(
						SELECT jo.expires_at
						FROM job_otp jo
						WHERE jo.booking_id = b.id
						  AND jo.is_used = FALSE
						  AND jo.expires_at > CURRENT_TIMESTAMP
						ORDER BY jo.created_at DESC
						LIMIT 1
					) AS otp_expires_at,
					b.previous_scheduled_date,
					b.rescheduled_at,
					b.rescheduled_by,
					b.reschedule_reason
				FROM bookings b
				JOIN workers w ON w.id = b.worker_id
				JOIN users u ON u.id = w.user_id
				JOIN services s ON s.id = b.service_id
				WHERE b.user_id = %s
				ORDER BY b.scheduled_date DESC
				""",
				[user_id],
			)
			rows = cursor.fetchall()

		return JsonResponse(
			{
				"status": "success",
				"count": len(rows),
				"data": [_serialize_booking_row(row) for row in rows],
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to fetch bookings",
				"code": "BOOKINGS_FETCH_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def create_booking(request):
	"""POST /api/bookings/create/ - create booking from customer app."""
	try:
		payload = json.loads(request.body)
	except json.JSONDecodeError:
		return JsonResponse(
			{"status": "error", "message": "Invalid JSON", "code": "INVALID_JSON"},
			status=400,
		)

	required_fields = ["user_id", "worker_id", "service_id", "scheduled_date", "total_amount"]
	missing = [field for field in required_fields if payload.get(field) is None]
	if missing:
		return JsonResponse(
			{
				"status": "error",
				"message": f"Missing fields: {', '.join(missing)}",
				"code": "MISSING_FIELDS",
			},
			status=400,
		)

	try:
		scheduled_date_raw = str(payload["scheduled_date"])
		try:
			scheduled_date = datetime.fromisoformat(
				scheduled_date_raw.replace("Z", "+00:00")
			)
		except ValueError:
			return JsonResponse(
				{
					"status": "error",
					"message": "Invalid scheduled_date format",
					"code": "INVALID_SCHEDULED_DATE",
				},
				status=400,
			)

		with connection.cursor() as cursor:
			_ensure_booking_reschedule_columns()
			# Prevent worker time collisions for active bookings.
			cursor.execute(
				"""
				SELECT id
				FROM bookings
				WHERE worker_id = %s
				  AND scheduled_date = %s
				  AND LOWER(status) = ANY(%s)
				LIMIT 1
				""",
				[
					payload["worker_id"],
					scheduled_date,
					list(ACTIVE_BOOKING_STATUSES),
				],
			)
			if cursor.fetchone():
				return JsonResponse(
					{
						"status": "error",
						"message": "Selected time is not available for this worker",
						"code": "SLOT_UNAVAILABLE",
					},
					status=409,
				)

			cursor.execute(
				"""
				INSERT INTO bookings (user_id, worker_id, service_id, scheduled_date, status, total_amount, created_at)
				VALUES (%s, %s, %s, %s, %s, %s, NOW())
				RETURNING id
				""",
				[
					payload["user_id"],
					payload["worker_id"],
					payload["service_id"],
					scheduled_date,
					payload.get("status", "pending"),
					payload["total_amount"],
				],
			)
			booking_id = cursor.fetchone()[0]

			cursor.execute(
				"""
				SELECT
					b.id,
					b.user_id,
					b.worker_id,
					b.service_id,
					b.scheduled_date,
					b.status,
					b.total_amount,
					b.created_at,
					u.name AS worker_name,
					s.service_name,
					NULL AS activation_otp,
					NULL AS otp_expires_at,
					b.previous_scheduled_date,
					b.rescheduled_at,
					b.rescheduled_by,
					b.reschedule_reason
				FROM bookings b
				JOIN workers w ON w.id = b.worker_id
				JOIN users u ON u.id = w.user_id
				JOIN services s ON s.id = b.service_id
				WHERE b.id = %s
				""",
				[booking_id],
			)
			row = cursor.fetchone()

			cursor.execute("SELECT phone, name FROM users WHERE id = %s", [payload["user_id"]])
			customer_phone_row = cursor.fetchone()

			cursor.execute(
				"""
				SELECT u.fcm_token, u.email, u.name
				FROM workers w
				JOIN users u ON u.id = w.user_id
				WHERE w.id = %s
				""",
				[payload["worker_id"]],
			)
			worker_fcm_row = cursor.fetchone()

		from authentication.sms_service import send_otp_sms
		if (
			getattr(settings, "SMS_NON_OTP_NOTIFICATIONS_ENABLED", False)
			and customer_phone_row
			and customer_phone_row[0]
		):
			send_otp_sms(str(customer_phone_row[0]), str(booking_id), purpose="confirmation")

		customer_name = customer_phone_row[1] if customer_phone_row and len(customer_phone_row) > 1 else "Customer"
		if worker_fcm_row and len(worker_fcm_row) > 1 and worker_fcm_row[1]:
			send_worker_job_email(
				worker_email=str(worker_fcm_row[1]),
				worker_name=str(worker_fcm_row[2] or "Worker") if len(worker_fcm_row) > 2 else "Worker",
				customer_name=str(customer_name or "Customer"),
				service_name=str(row[9] or "Service"),
				scheduled_date=str(row[4] or ""),
				booking_id=booking_id,
				event="new_booking",
			)

		if worker_fcm_row and worker_fcm_row[0]:
			send_fcm_notification(
				worker_fcm_row[0],
				"New Booking Received",
				f"You have a new booking request #{booking_id}",
				{
					"booking_id": str(booking_id),
					"type": "new_booking",
				},
			)

		return JsonResponse(
			{
				"status": "success",
				"message": "Booking created successfully",
				"data": _serialize_booking_row(row),
			},
			status=201,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to create booking",
				"code": "BOOKING_CREATE_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["GET"])
def worker_availability(request):
	"""GET /api/bookings/availability/?worker_id=&date=YYYY-MM-DD"""
	worker_id = request.GET.get("worker_id")
	date_str = (request.GET.get("date") or "").strip()

	if not worker_id or not date_str:
		return JsonResponse(
			{
				"status": "error",
				"message": "worker_id and date are required",
				"code": "MISSING_FIELDS",
			},
			status=400,
		)

	try:
		target_date = datetime.strptime(date_str, "%Y-%m-%d").date()
	except ValueError:
		return JsonResponse(
			{
				"status": "error",
				"message": "Invalid date format. Use YYYY-MM-DD",
				"code": "INVALID_DATE",
			},
			status=400,
		)

	try:
		_ensure_worker_availability_table()
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT id, scheduled_date, status
				FROM bookings
				WHERE worker_id = %s
				  AND DATE(scheduled_date) = %s
				  AND LOWER(status) = ANY(%s)
				ORDER BY scheduled_date ASC
				""",
				[worker_id, target_date, list(ACTIVE_BOOKING_STATUSES)],
			)
			rows = cursor.fetchall()

			cursor.execute(
				"""
				SELECT start_time, end_time, is_available
				FROM worker_availability
				WHERE worker_id = %s AND day_of_week = %s
				""",
				[worker_id, target_date.weekday()],
			)
			schedule_row = cursor.fetchone()

		unavailable_hours_set = {
			row[1].hour
			for row in rows
			if row[1] is not None and hasattr(row[1], "hour")
		}

		if schedule_row:
			start_time, end_time, is_available = schedule_row
			if not is_available:
				unavailable_hours_set.update(range(24))
			else:
				def _hour_from_time(value):
					if hasattr(value, "hour"):
						return int(value.hour)
					parts = str(value).split(":")
					return int(parts[0]) if parts and parts[0].isdigit() else 0

				start_hour = _hour_from_time(start_time)
				end_hour = _hour_from_time(end_time)
				available_hours = set(range(start_hour, end_hour if end_hour > start_hour else start_hour))
				outside_hours = set(range(24)) - available_hours
				unavailable_hours_set.update(outside_hours)

		unavailable_hours = sorted(unavailable_hours_set)
		booked_slots = [
			{
				"booking_id": row[0],
				"scheduled_date": row[1].isoformat() if row[1] else None,
				"status": row[2],
			}
			for row in rows
		]

		return JsonResponse(
			{
				"status": "success",
				"data": {
					"worker_id": int(worker_id),
					"date": date_str,
					"unavailable_hours": unavailable_hours,
					"booked_slots": booked_slots,
				},
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to fetch availability",
				"code": "AVAILABILITY_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["PATCH", "PUT"])
def update_booking_status(request, booking_id):
	"""PATCH /api/bookings/<id>/status/ - update booking status."""
	_ensure_booking_status_constraint()
	try:
		payload = json.loads(request.body)
	except json.JSONDecodeError:
		return JsonResponse(
			{"status": "error", "message": "Invalid JSON", "code": "INVALID_JSON"},
			status=400,
		)

	status = (payload.get("status") or "").strip().lower()
	allowed_statuses = {
		"pending",
		"confirmed",
		"in_progress",
		"awaiting_payment",
		"completed",
		"cancelled",
	}
	if status not in allowed_statuses:
		return JsonResponse(
			{
				"status": "error",
				"message": "Invalid status",
				"code": "INVALID_STATUS",
			},
			status=400,
		)

	try:
		_ensure_booking_cancellation_columns()

		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT user_id, worker_id, status, total_amount
				FROM bookings
				WHERE id = %s
				""",
				[booking_id],
			)
			booking_row = cursor.fetchone()

			if not booking_row:
				return JsonResponse(
					{
						"status": "error",
						"message": "Booking not found",
						"code": "BOOKING_NOT_FOUND",
					},
					status=404,
				)

			user_id, worker_id, old_status, total_amount = booking_row
			old_status = str(old_status or "").lower()

			if status == "cancelled":
				# Prevent cancellation if booking is already in progress, completed, or already cancelled
				if old_status in {"in_progress", "awaiting_payment", "completed", "cancelled"}:
					return JsonResponse(
						{
							"status": "error",
							"message": f"Cannot cancel booking in {old_status} status",
							"code": "INVALID_CANCELLATION_STATE",
						},
						status=409,
					)

				cancelled_by = str(payload.get("cancelled_by") or "user").strip().lower()
				if cancelled_by not in {"user", "admin", "worker"}:
					cancelled_by = "user"

				refund_amount = 0.0
				cursor.execute(
					"""
					SELECT COUNT(*)
					FROM payments
					WHERE booking_id = %s AND payment_status = 'paid'
					""",
					[booking_id],
				)
				paid_count = int(cursor.fetchone()[0] or 0)

				if paid_count > 0:
					total_amount_value = float(total_amount or 0)
					if old_status == "pending":
						refund_amount = total_amount_value
					elif old_status in {"confirmed", "in_progress"}:
						cancellation_fee_pct = float(
							getattr(settings, "CANCELLATION_FEE_PERCENT", 20)
						)
						refund_amount = max(
							0,
							total_amount_value * (1 - (cancellation_fee_pct / 100)),
						)

				if refund_amount > 0:
					from payments.views import _insert_wallet_txn

					_insert_wallet_txn(
						user_id,
						refund_amount,
						"refund",
						f"Cancellation refund for booking #{booking_id}",
					)

				cursor.execute(
					"""
					UPDATE bookings
					SET status = %s, cancelled_at = NOW(), cancelled_by = %s
					WHERE id = %s
					""",
					[status, cancelled_by, booking_id],
				)

				cursor.execute("SELECT phone, name FROM users WHERE id = %s", [user_id])
				customer_phone_row = cursor.fetchone()
				cursor.execute(
					"""
					SELECT u.phone, u.email, u.name, s.service_name, b.scheduled_date
					FROM workers w
					JOIN users u ON u.id = w.user_id
					JOIN bookings b ON b.worker_id = w.id AND b.id = %s
					JOIN services s ON s.id = b.service_id
					WHERE w.id = %s
					""",
					[booking_id, worker_id],
				)
				worker_phone_row = cursor.fetchone()

				from authentication.sms_service import send_otp_sms

				if (
					getattr(settings, "SMS_NON_OTP_NOTIFICATIONS_ENABLED", False)
					and customer_phone_row
					and customer_phone_row[0]
				):
					send_otp_sms(
						str(customer_phone_row[0]),
						str(booking_id),
						purpose="cancellation_customer",
					)
				if (
					getattr(settings, "SMS_NON_OTP_NOTIFICATIONS_ENABLED", False)
					and worker_phone_row
					and worker_phone_row[0]
				):
					send_otp_sms(
						str(worker_phone_row[0]),
						str(booking_id),
						purpose="cancellation_worker",
					)

				customer_name = customer_phone_row[1] if customer_phone_row and len(customer_phone_row) > 1 else "Customer"
				if worker_phone_row and len(worker_phone_row) > 1 and worker_phone_row[1]:
					send_worker_job_email(
						worker_email=str(worker_phone_row[1]),
						worker_name=str(worker_phone_row[2] or "Worker") if len(worker_phone_row) > 2 else "Worker",
						customer_name=str(customer_name or "Customer"),
						service_name=str(worker_phone_row[3] or "Service") if len(worker_phone_row) > 3 else "Service",
						scheduled_date=str(worker_phone_row[4] or "") if len(worker_phone_row) > 4 else "",
						booking_id=booking_id,
						event="booking_cancelled",
					)
			else:
				cursor.execute(
					"UPDATE bookings SET status = %s WHERE id = %s",
					[status, booking_id],
				)

		return JsonResponse(
			{"status": "success", "message": "Booking status updated", "data": {"id": booking_id, "status": status}},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to update booking",
				"code": "BOOKING_UPDATE_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["GET"])
def booking_detail(request, booking_id):
	"""GET /api/bookings/<id>/ - single booking detail."""
	try:
		_ensure_booking_reschedule_columns()
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT
					b.id,
					b.user_id,
					b.worker_id,
					b.service_id,
					b.scheduled_date,
					b.status,
					b.total_amount,
					b.created_at,
					u.name AS worker_name,
					s.service_name,
					NULL AS activation_otp,
					NULL AS otp_expires_at,
					b.previous_scheduled_date,
					b.rescheduled_at,
					b.rescheduled_by,
					b.reschedule_reason
				FROM bookings b
				JOIN workers w ON w.id = b.worker_id
				JOIN users u ON u.id = w.user_id
				JOIN services s ON s.id = b.service_id
				WHERE b.id = %s
				""",
				[booking_id],
			)
			row = cursor.fetchone()

		if not row:
			return JsonResponse(
				{
					"status": "error",
					"message": "Booking not found",
					"code": "BOOKING_NOT_FOUND",
				},
				status=404,
			)

		return JsonResponse({"status": "success", "data": _serialize_booking_row(row)}, status=200)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to fetch booking",
				"code": "BOOKING_DETAIL_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def reschedule_booking(request, booking_id):
	"""POST /api/bookings/<booking_id>/reschedule/ - worker reschedules with reason and new datetime."""
	try:
		payload = json.loads(request.body)
	except json.JSONDecodeError:
		return JsonResponse(
			{"status": "error", "message": "Invalid JSON", "code": "INVALID_JSON"},
			status=400,
		)

	new_scheduled_date_raw = (payload.get("scheduled_date") or "").strip()
	reschedule_reason = str(payload.get("reason") or "").strip()

	if not new_scheduled_date_raw or not reschedule_reason:
		return JsonResponse(
			{
				"status": "error",
				"message": "scheduled_date and reason are required",
				"code": "MISSING_FIELDS",
			},
			status=400,
		)

	if len(reschedule_reason) < 5:
		return JsonResponse(
			{
				"status": "error",
				"message": "Please provide a valid reschedule reason (min 5 characters)",
				"code": "INVALID_REASON",
			},
			status=400,
		)

	try:
		new_scheduled_date = datetime.fromisoformat(
			new_scheduled_date_raw.replace("Z", "+00:00")
		)
	except ValueError:
		return JsonResponse(
			{
				"status": "error",
				"message": "Invalid scheduled_date format",
				"code": "INVALID_SCHEDULED_DATE",
			},
			status=400,
		)

	try:
		_ensure_booking_status_constraint()
		_ensure_booking_reschedule_columns()

		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT user_id, worker_id, service_id, scheduled_date, status, total_amount, created_at
				FROM bookings
				WHERE id = %s
				""",
				[booking_id],
			)
			row = cursor.fetchone()

			if not row:
				return JsonResponse(
					{
						"status": "error",
						"message": "Booking not found",
						"code": "BOOKING_NOT_FOUND",
					},
					status=404,
				)

			user_id, worker_id, service_id, old_scheduled_date, current_status, total_amount, created_at = row
			current_status = str(current_status or "").lower()

			if current_status not in {"pending", "confirmed", "in_progress"}:
				return JsonResponse(
					{
						"status": "error",
						"message": "Only pending/confirmed/in_progress jobs can be rescheduled",
						"code": "INVALID_BOOKING_STATUS",
						"data": {"current_status": current_status},
					},
					status=409,
				)

			cursor.execute(
				"""
				SELECT id
				FROM bookings
				WHERE worker_id = %s
				  AND id <> %s
				  AND scheduled_date = %s
				  AND LOWER(status) = ANY(%s)
				LIMIT 1
				""",
				[
					worker_id,
					booking_id,
					new_scheduled_date,
					list(ACTIVE_BOOKING_STATUSES),
				],
			)
			if cursor.fetchone():
				return JsonResponse(
					{
						"status": "error",
						"message": "Selected new time is not available",
						"code": "SLOT_UNAVAILABLE",
					},
					status=409,
				)

			cursor.execute(
				"""
				UPDATE bookings
				SET previous_scheduled_date = scheduled_date,
					scheduled_date = %s,
					rescheduled_at = NOW(),
					rescheduled_by = %s,
					reschedule_reason = %s
				WHERE id = %s
				""",
				[new_scheduled_date, "worker", reschedule_reason, booking_id],
			)

			cursor.execute(
				"""
				SELECT
					b.id,
					b.user_id,
					b.worker_id,
					b.service_id,
					b.scheduled_date,
					b.status,
					b.total_amount,
					b.created_at,
					u.name AS worker_name,
					s.service_name,
					NULL AS activation_otp,
					NULL AS otp_expires_at,
					b.previous_scheduled_date,
					b.rescheduled_at,
					b.rescheduled_by,
					b.reschedule_reason
				FROM bookings b
				JOIN workers w ON w.id = b.worker_id
				JOIN users u ON u.id = w.user_id
				JOIN services s ON s.id = b.service_id
				WHERE b.id = %s
				""",
				[booking_id],
			)
			updated_row = cursor.fetchone()

		return JsonResponse(
			{
				"status": "success",
				"message": "Booking rescheduled successfully",
				"data": _serialize_booking_row(updated_row),
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to reschedule booking",
				"code": "BOOKING_RESCHEDULE_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def mark_job_done(request, booking_id):
	"""POST /api/bookings/<booking_id>/mark-done/ - worker marks in-progress job as awaiting payment."""
	try:
		payload = json.loads(request.body or "{}")
	except json.JSONDecodeError:
		return JsonResponse(
			{"status": "error", "message": "Invalid JSON", "code": "INVALID_JSON"},
			status=400,
		)

	requested_amount = payload.get("total_amount")
	parsed_amount = None
	if requested_amount is not None:
		try:
			parsed_amount = float(requested_amount)
		except (TypeError, ValueError):
			return JsonResponse(
				{
					"status": "error",
					"message": "total_amount must be numeric",
					"code": "VALIDATION_ERROR",
				},
				status=400,
			)
		if parsed_amount <= 0:
			return JsonResponse(
				{
					"status": "error",
					"message": "total_amount must be greater than 0",
					"code": "VALIDATION_ERROR",
				},
				status=400,
			)

	try:
		_ensure_booking_status_constraint()
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT status, total_amount
				FROM bookings
				WHERE id = %s
				""",
				[booking_id],
			)
			row = cursor.fetchone()

			if not row:
				return JsonResponse(
					{
						"status": "error",
						"message": "Booking not found",
						"code": "BOOKING_NOT_FOUND",
					},
					status=404,
				)

			current_status = str(row[0] or "").lower()
			resolved_amount = parsed_amount if parsed_amount is not None else float(row[1] or 0)
			if current_status != "in_progress":
				return JsonResponse(
					{
						"status": "error",
						"message": "Only in-progress bookings can be marked done",
						"code": "INVALID_BOOKING_STATUS",
						"data": {
							"current_status": current_status,
						},
					},
					status=409,
				)

			cursor.execute(
				"""
				UPDATE bookings
				SET status = %s, total_amount = %s
				WHERE id = %s
				""",
				["awaiting_payment", resolved_amount, booking_id],
			)

		return JsonResponse(
			{
				"status": "success",
				"message": "Job marked done. Awaiting customer confirmation.",
				"data": {
					"booking_id": booking_id,
					"status": "awaiting_payment",
					"total_amount": resolved_amount,
				},
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to mark job done",
				"code": "MARK_DONE_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def confirm_booking_completion(request, booking_id):
	"""POST /api/bookings/<booking_id>/confirm-complete/ - customer confirms completion in demo flow."""
	_ensure_booking_status_constraint()
	try:
		payload = json.loads(request.body or "{}")
	except json.JSONDecodeError:
		return JsonResponse(
			{"status": "error", "message": "Invalid JSON", "code": "INVALID_JSON"},
			status=400,
		)

	requested_user_id = payload.get("user_id")
	requested_amount = payload.get("amount")
	requested_payment_mode = str(payload.get("payment_mode") or "").strip().lower()
	razorpay_enabled = bool(getattr(settings, "WEBLAB_RAZORPAY_ENABLED", False))

	parsed_requested_amount = None
	if requested_amount is not None:
		try:
			parsed_requested_amount = float(requested_amount)
		except (TypeError, ValueError):
			return JsonResponse(
				{
					"status": "error",
					"message": "amount must be numeric",
					"code": "VALIDATION_ERROR",
				},
				status=400,
			)
		if parsed_requested_amount <= 0:
			return JsonResponse(
				{
					"status": "error",
					"message": "amount must be greater than 0",
					"code": "VALIDATION_ERROR",
				},
				status=400,
			)

	try:
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT id, user_id, status, total_amount
				FROM bookings
				WHERE id = %s
				""",
				[booking_id],
			)
			row = cursor.fetchone()

			if not row:
				return JsonResponse(
					{
						"status": "error",
						"message": "Booking not found",
						"code": "BOOKING_NOT_FOUND",
					},
					status=404,
				)

			_, booking_user_id, current_status, amount = row
			booking_amount = float(amount or 0)
			current_status = str(current_status or "").lower()

			if (
				parsed_requested_amount is not None
				and abs(parsed_requested_amount - booking_amount) > 0.01
			):
				return JsonResponse(
					{
						"status": "error",
						"message": "Scanned amount does not match booking amount",
						"code": "AMOUNT_MISMATCH",
						"data": {
							"booking_id": int(booking_id),
							"provided_amount": parsed_requested_amount,
							"expected_amount": booking_amount,
						},
					},
					status=409,
				)

			if requested_user_id is not None and int(requested_user_id) != int(booking_user_id):
				return JsonResponse(
					{
						"status": "error",
						"message": "You are not allowed to confirm this booking",
						"code": "FORBIDDEN",
					},
					status=403,
				)

			if current_status == "completed":
				return JsonResponse(
					{
						"status": "success",
						"message": "Booking already completed",
						"data": {
							"booking_id": int(booking_id),
							"status": "completed",
						},
					},
					status=200,
				)

			if current_status not in {"awaiting_payment", "in_progress"}:
				return JsonResponse(
					{
						"status": "error",
						"message": "Booking is not ready for completion confirmation",
						"code": "INVALID_BOOKING_STATUS",
						"data": {"current_status": current_status},
					},
					status=409,
				)

			# WebLab path: force payment step before completion for online mode.
			# When customer chooses cash, allow completion in one step.
			if razorpay_enabled and current_status == "awaiting_payment":
				if requested_payment_mode in {"cash", "cod"}:
					transaction_ref = f"COD-{uuid.uuid4().hex[:12].upper()}"
					cursor.execute(
						"""
						INSERT INTO payments (booking_id, payment_method, payment_status, transaction_id, paid_at)
						VALUES (%s, %s, %s, %s, NOW())
						""",
						[booking_id, "COD", "paid", transaction_ref],
					)

					cursor.execute(
						"""
						UPDATE bookings
						SET status = %s
						WHERE id = %s
						""",
						["completed", booking_id],
					)

					return JsonResponse(
						{
							"status": "success",
							"message": "Booking completed successfully",
							"data": {
								"booking_id": int(booking_id),
								"status": "completed",
								"payment_status": "paid",
								"payment_method": "COD",
								"transaction_ref": transaction_ref,
								"amount": booking_amount,
							},
						},
						status=200,
					)

				# Require online payment confirmation endpoint before completion.
				return JsonResponse(
					{
						"status": "error",
						"message": "Payment required before completion",
						"code": "PAYMENT_REQUIRED",
						"data": {
							"booking_id": int(booking_id),
							"status": current_status,
							"amount": booking_amount,
							"allow_cash": True,
							"allow_online": True,
							"payment_gateway": "razorpay",
						},
					},
					status=402,
				)

			transaction_ref = f"DEMO-{uuid.uuid4().hex[:12].upper()}"
			cursor.execute(
				"""
				INSERT INTO payments (booking_id, payment_method, payment_status, transaction_id, paid_at)
				VALUES (%s, %s, %s, %s, NOW())
				""",
				[booking_id, "UPI", "paid", transaction_ref],
			)

			cursor.execute(
				"""
				UPDATE bookings
				SET status = %s
				WHERE id = %s
				""",
				["completed", booking_id],
			)

		return JsonResponse(
			{
				"status": "success",
				"message": "Booking completed successfully",
				"data": {
					"booking_id": int(booking_id),
					"status": "completed",
					"payment_status": "paid",
					"payment_method": "UPI",
					"transaction_ref": transaction_ref,
					"amount": booking_amount,
				},
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to confirm completion",
				"code": "CONFIRM_COMPLETION_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def initiate_job_otp(request, booking_id):
	"""POST /api/bookings/<booking_id>/initiate-otp/ - Generate and send OTP to customer for job activation."""
	if not booking_id:
		return JsonResponse(
			{"status": "error", "message": "booking_id required", "code": "MISSING_BOOKING_ID"},
			status=400,
		)

	try:
		from .otp_utils import generate_otp, save_job_otp
		from authentication.sms_service import send_otp_sms

		# Fetch booking details
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT id, user_id, worker_id, status
				FROM bookings
				WHERE id = %s
				""",
				[booking_id],
			)
			row = cursor.fetchone()

		if not row:
			return JsonResponse(
				{"status": "error", "message": "Booking not found", "code": "BOOKING_NOT_FOUND"},
				status=404,
			)

		booking_id, customer_id, worker_id, status = row

		# Generate OTP
		otp = generate_otp()

		# Save OTP to database
		success = save_job_otp(booking_id, customer_id, worker_id, otp, validity_minutes=10)
		if not success:
			return JsonResponse(
				{"status": "error", "message": "Failed to generate OTP", "code": "OTP_GENERATION_FAILED"},
				status=500,
			)

		with connection.cursor() as cursor:
			cursor.execute("SELECT phone FROM users WHERE id = %s", [customer_id])
			phone_row = cursor.fetchone()

		sms_result = {"success": False, "message": "Customer phone not found"}
		if phone_row and phone_row[0]:
			if getattr(settings, "JOB_OTP_SMS_ENABLED", False):
				sms_result = send_otp_sms(str(phone_row[0]), otp, "job_start")
			else:
				sms_result = {"success": True, "message": "SMS skipped by feature flag"}

		data = {
			"booking_id": booking_id,
			"validity_minutes": 10,
			"message": f"OTP sent to customer. Valid for 10 minutes.",
			"sms_status": sms_result,
		}

		# Development fallback when SMS OTP is disabled or API OTP exposure is enabled.
		if getattr(settings, "OTP_EXPOSE_IN_API", True):
			data["demo_otp"] = otp

		return JsonResponse(
			{
				"status": "success",
				"message": "OTP initiated successfully",
				"data": data,
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to initiate OTP",
				"code": "OTP_INITIATION_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def verify_job_otp_endpoint(request, booking_id):
	"""POST /api/bookings/<booking_id>/verify-otp/ - Verify OTP and activate job."""
	_ensure_booking_status_constraint()
	try:
		payload = json.loads(request.body)
	except json.JSONDecodeError:
		return JsonResponse(
			{"status": "error", "message": "Invalid JSON", "code": "INVALID_JSON"},
			status=400,
		)

	otp = payload.get("otp")

	if not booking_id or not otp:
		return JsonResponse(
			{"status": "error", "message": "booking_id and otp required", "code": "MISSING_FIELDS"},
			status=400,
		)

	try:
		from .otp_utils import verify_job_otp

		# Verify OTP
		is_valid = verify_job_otp(booking_id, otp)

		if not is_valid:
			return JsonResponse(
				{
					"status": "error",
					"message": "Invalid or expired OTP",
					"code": "INVALID_OTP",
				},
				status=401,
			)

		# Update booking status to in_progress
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				UPDATE bookings
				SET status = %s
				WHERE id = %s
				""",
				["in_progress", booking_id],
			)

		return JsonResponse(
			{
				"status": "success",
				"message": "Job activated successfully",
				"data": {"booking_id": booking_id},
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to verify OTP",
				"code": "OTP_VERIFICATION_ERROR",
				"details": str(e),
			},
			status=500,
		)
