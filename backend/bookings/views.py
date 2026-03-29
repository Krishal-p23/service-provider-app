import json
from django.http import JsonResponse
from django.db import connection
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from datetime import datetime


ACTIVE_BOOKING_STATUSES = ("pending", "confirmed", "in_progress")


def _serialize_booking_row(row):
	return {
		"id": row[0],
		"user_id": row[1],
		"worker_id": row[2],
		"service_id": row[3],
		"scheduled_date": row[4].isoformat() if row[4] else None,
		"status": row[5],
		"total_amount": float(row[6]),
		"created_at": row[7].isoformat() if row[7] else None,
		"worker_name": row[8],
		"service_name": row[9],
	}


@csrf_exempt
@require_http_methods(["GET"])
def user_bookings(request, user_id):
	"""GET /api/bookings/user/<user_id>/ - all bookings for a customer."""
	try:
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
					s.service_name
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
					s.service_name
				FROM bookings b
				JOIN workers w ON w.id = b.worker_id
				JOIN users u ON u.id = w.user_id
				JOIN services s ON s.id = b.service_id
				WHERE b.id = %s
				""",
				[booking_id],
			)
			row = cursor.fetchone()

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

		unavailable_hours = sorted(
			{
				row[1].hour
				for row in rows
				if row[1] is not None and hasattr(row[1], "hour")
			}
		)
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
	try:
		payload = json.loads(request.body)
	except json.JSONDecodeError:
		return JsonResponse(
			{"status": "error", "message": "Invalid JSON", "code": "INVALID_JSON"},
			status=400,
		)

	status = (payload.get("status") or "").strip().lower()
	allowed_statuses = {"pending", "confirmed", "in_progress", "completed", "cancelled"}
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
		with connection.cursor() as cursor:
			cursor.execute(
				"UPDATE bookings SET status = %s WHERE id = %s",
				[status, booking_id],
			)

			if cursor.rowcount == 0:
				return JsonResponse(
					{
						"status": "error",
						"message": "Booking not found",
						"code": "BOOKING_NOT_FOUND",
					},
					status=404,
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
					s.service_name
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
