import json
from django.http import JsonResponse
from django.db import connection
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt


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
