import json
from django.http import JsonResponse
from django.db import connection
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt


@csrf_exempt
@require_http_methods(["GET"])
def check_review_status(request, booking_id):
	"""GET /api/reviews/check/<booking_id>/ - check if review exists for booking."""
	try:
		user_id = request.GET.get('user_id')
		if not user_id:
			return JsonResponse(
				{
					"status": "error",
					"message": "user_id query parameter is required",
					"code": "MISSING_USER_ID",
				},
				status=400,
			)

		with connection.cursor() as cursor:
			# Check ifbooking exists and get its status
			cursor.execute(
				"""
				SELECT id, status FROM bookings WHERE id = %s
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

			booking_id_check, booking_status = booking_row

			# Check if review exists for this booking by current user
			cursor.execute(
				"""
				SELECT id, rating, comment, created_at
				FROM reviews
				WHERE booking_id = %s AND user_id = %s
				LIMIT 1
				""",
				[booking_id, user_id],
			)
			review_row = cursor.fetchone()

			if review_row:
				return JsonResponse(
					{
						"status": "success",
						"data": {
							"review_exists": True,
							"review_id": review_row[0],
							"rating": review_row[1],
							"has_comment": bool(review_row[2]),
							"created_at": review_row[3].isoformat() if review_row[3] else None,
						},
					},
					status=200,
				)
			else:
				return JsonResponse(
					{
						"status": "success",
						"data": {
							"review_exists": False,
							"can_review": booking_status and booking_status.lower() == "completed",
						},
					},
					status=200,
				)

	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to check review status",
				"code": "CHECK_REVIEW_ERROR",
				"details": str(e),
			},
			status=500,
		)


def _serialize_review_row(row):
	return {
		"id": row[0],
		"booking_id": row[1],
		"user_id": row[2],
		"worker_id": row[3],
		"rating": row[4],
		"comment": row[5] or "",
		"created_at": row[6].isoformat() if row[6] else None,
		"reviewer_name": row[7],
	}


@csrf_exempt
@require_http_methods(["GET"])
def worker_reviews(request, worker_id):
	"""GET /api/reviews/worker/<worker_id>/ - list reviews for worker."""
	try:
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT
					r.id,
					r.booking_id,
					r.user_id,
					r.worker_id,
					r.rating,
					r.comment,
					r.created_at,
					u.name AS reviewer_name
				FROM reviews r
				JOIN users u ON u.id = r.user_id
				WHERE r.worker_id = %s
				ORDER BY r.created_at DESC
				""",
				[worker_id],
			)
			rows = cursor.fetchall()

		return JsonResponse(
			{
				"status": "success",
				"count": len(rows),
				"data": [_serialize_review_row(row) for row in rows],
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to fetch worker reviews",
				"code": "WORKER_REVIEWS_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["GET"])
def user_reviews(request, user_id):
	"""GET /api/reviews/user/<user_id>/ - list reviews authored by user."""
	try:
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT
					r.id,
					r.booking_id,
					r.user_id,
					r.worker_id,
					r.rating,
					r.comment,
					r.created_at,
					u.name AS reviewer_name
				FROM reviews r
				JOIN users u ON u.id = r.user_id
				WHERE r.user_id = %s
				ORDER BY r.created_at DESC
				""",
				[user_id],
			)
			rows = cursor.fetchall()

		return JsonResponse(
			{
				"status": "success",
				"count": len(rows),
				"data": [_serialize_review_row(row) for row in rows],
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to fetch user reviews",
				"code": "USER_REVIEWS_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def create_review(request):
	"""POST /api/reviews/create/ - create worker review."""
	try:
		payload = json.loads(request.body)
	except json.JSONDecodeError:
		return JsonResponse(
			{"status": "error", "message": "Invalid JSON", "code": "INVALID_JSON"},
			status=400,
		)

	required_fields = ["booking_id", "user_id", "worker_id", "rating"]
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

	rating = payload.get("rating")
	if not isinstance(rating, int) or rating < 1 or rating > 5:
		return JsonResponse(
			{
				"status": "error",
				"message": "Rating must be an integer between 1 and 5",
				"code": "INVALID_RATING",
			},
			status=400,
		)

	try:
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT user_id, worker_id, status
				FROM bookings
				WHERE id = %s
				""",
				[payload["booking_id"]],
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

			booking_user_id, booking_worker_id, booking_status = booking_row
			if (
				int(booking_user_id) != int(payload["user_id"]) or
				int(booking_worker_id) != int(payload["worker_id"])
			):
				return JsonResponse(
					{
						"status": "error",
						"message": "Review payload does not match booking",
						"code": "BOOKING_REVIEW_MISMATCH",
					},
					status=400,
				)

			if str(booking_status or "").lower() != "completed":
				return JsonResponse(
					{
						"status": "error",
						"message": "Review can only be added after booking completion",
						"code": "BOOKING_NOT_COMPLETED",
					},
					status=409,
				)

			cursor.execute(
				"""
				SELECT id
				FROM reviews
				WHERE booking_id = %s AND user_id = %s
				LIMIT 1
				""",
				[payload["booking_id"], payload["user_id"]],
			)
			existing = cursor.fetchone()
			if existing:
				return JsonResponse(
					{
						"status": "error",
						"message": "Review already submitted for this booking",
						"code": "REVIEW_ALREADY_EXISTS",
						"data": {"review_id": existing[0]},
					},
					status=409,
				)

			cursor.execute(
				"""
				INSERT INTO reviews (booking_id, user_id, worker_id, rating, comment, created_at)
				VALUES (%s, %s, %s, %s, %s, NOW())
				RETURNING id
				""",
				[
					payload["booking_id"],
					payload["user_id"],
					payload["worker_id"],
					rating,
					payload.get("comment", ""),
				],
			)
			review_id = cursor.fetchone()[0]

			cursor.execute(
				"""
				SELECT
					r.id,
					r.booking_id,
					r.user_id,
					r.worker_id,
					r.rating,
					r.comment,
					r.created_at,
					u.name AS reviewer_name
				FROM reviews r
				JOIN users u ON u.id = r.user_id
				WHERE r.id = %s
				""",
				[review_id],
			)
			row = cursor.fetchone()

		return JsonResponse(
			{
				"status": "success",
				"message": "Review created successfully",
				"data": _serialize_review_row(row),
			},
			status=201,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to create review",
				"code": "REVIEW_CREATE_ERROR",
				"details": str(e),
			},
			status=500,
		)
