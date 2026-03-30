from django.http import JsonResponse
from django.db import connection
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt


DEMO_CATEGORIES = [
	"AC Repair",
	"Plumbing",
	"Electrician",
	"Cleaning",
	"Painting",
	"Carpenter",
	"Pest Control",
	"Appliance Repair",
]


def _ensure_demo_categories():
	"""Insert missing demo categories (idempotent by name)."""
	with connection.cursor() as cursor:
		cursor.execute("SELECT category_name FROM service_categories")
		existing = {
			(str(row[0]).strip().lower())
			for row in cursor.fetchall()
			if row and row[0]
		}

		for category_name in DEMO_CATEGORIES:
			if category_name.strip().lower() not in existing:
				cursor.execute(
					"INSERT INTO service_categories (category_name) VALUES (%s)",
					[category_name],
				)


@csrf_exempt
@require_http_methods(["GET"])
def service_categories(request):
	"""GET /api/services/categories/ - Return service categories from DB."""
	try:
		_ensure_demo_categories()

		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT
					sc.id,
					sc.category_name,
					COALESCE(COUNT(s.id), 0) AS services_count
				FROM service_categories sc
				LEFT JOIN services s ON s.category_id = sc.id
				GROUP BY sc.id, sc.category_name
				ORDER BY sc.category_name ASC
				"""
			)
			rows = cursor.fetchall()

		data = [
			{
				"id": row[0],
				"category_name": row[1],
				"services_count": row[2],
			}
			for row in rows
		]

		return JsonResponse({"status": "success", "data": data}, status=200)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to fetch categories",
				"code": "CATEGORIES_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["GET"])
def services_list(request):
	"""GET /api/services/list/?category_id=optional - Return services from DB."""
	category_id = request.GET.get("category_id")

	try:
		with connection.cursor() as cursor:
			query = """
				SELECT id, category_id, service_name, base_price
				FROM services
			"""
			params = []

			if category_id:
				query += " WHERE category_id = %s"
				params.append(category_id)

			query += " ORDER BY service_name ASC"
			cursor.execute(query, params)
			rows = cursor.fetchall()

		data = [
			{
				"id": row[0],
				"category_id": row[1],
				"service_name": row[2],
				"base_price": float(row[3]),
			}
			for row in rows
		]

		return JsonResponse({"status": "success", "data": data}, status=200)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to fetch services",
				"code": "SERVICES_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["GET"])
def workers_list(request):
	"""
	GET /api/services/workers/?service_id=&search=&min_rating=&lat=&lng=&radius_km=
	Return real workers and summary stats from database.
	"""
	service_id = request.GET.get("service_id")
	category_id = request.GET.get("category_id")
	search = (request.GET.get("search") or "").strip().lower()
	min_rating = request.GET.get("min_rating")
	lat = request.GET.get("lat")
	lng = request.GET.get("lng")
	radius_km = request.GET.get("radius_km")

	has_coords = False
	parsed_lat = None
	parsed_lng = None
	parsed_radius = 20.0
	try:
		if lat is not None and lng is not None:
			parsed_lat = float(lat)
			parsed_lng = float(lng)
			has_coords = True
		if radius_km is not None:
			parsed_radius = float(radius_km)
	except (TypeError, ValueError):
		has_coords = False
		parsed_radius = 20.0

	try:
		with connection.cursor() as cursor:
			params = []
			where_clauses = ["w.is_available = TRUE"]

			if service_id:
				where_clauses.append(
					"""
					EXISTS (
						SELECT 1
						FROM worker_services ws
						WHERE ws.worker_id = w.id AND ws.service_id = %s
					)
					"""
				)
				params.append(service_id)

			if category_id:
				where_clauses.append(
					"""
					EXISTS (
						SELECT 1
						FROM worker_services ws
						JOIN services s ON s.id = ws.service_id
						WHERE ws.worker_id = w.id AND s.category_id = %s
					)
					"""
				)
				params.append(category_id)

			if search:
				where_clauses.append("(LOWER(u.name) LIKE %s OR LOWER(COALESCE(w.bio, '')) LIKE %s)")
				like_search = f"%{search}%"
				params.extend([like_search, like_search])

			where_sql = " AND ".join(where_clauses)

			if has_coords:
				query = f"""
					SELECT * FROM (
						SELECT
							w.id,
							w.user_id,
							w.is_verified,
							w.is_available,
							w.experience_years,
							w.bio,
							w.profile_photo,
							u.name,
							u.email,
							u.phone,
							COALESCE((SELECT AVG(r.rating) FROM reviews r WHERE r.worker_id = w.id), 0) AS avg_rating,
							COALESCE((SELECT COUNT(*) FROM reviews r WHERE r.worker_id = w.id), 0) AS review_count,
							COALESCE((SELECT COUNT(*) FROM bookings b WHERE b.worker_id = w.id AND LOWER(b.status) = 'completed'), 0) AS completed_jobs,
							CASE
								WHEN wl.latitude IS NOT NULL AND wl.longitude IS NOT NULL
								THEN (6371 * acos(cos(radians(%s)) * cos(radians(wl.latitude)) * cos(radians(wl.longitude) - radians(%s)) + sin(radians(%s)) * sin(radians(wl.latitude))))
								ELSE NULL
							END AS distance_km
						FROM workers w
						JOIN users u ON u.id = w.user_id
						LEFT JOIN user_locations wl ON wl.user_id = w.user_id
						WHERE {where_sql}
					) worker_results
					WHERE worker_results.distance_km IS NULL OR worker_results.distance_km <= %s
					ORDER BY COALESCE(worker_results.distance_km, 999999) ASC, worker_results.avg_rating DESC, worker_results.completed_jobs DESC, worker_results.id ASC
				"""
				cursor.execute(query, [parsed_lat, parsed_lng, parsed_lat, *params, parsed_radius])
			else:
				query = f"""
					SELECT
						w.id,
						w.user_id,
						w.is_verified,
						w.is_available,
						w.experience_years,
						w.bio,
						w.profile_photo,
						u.name,
						u.email,
						u.phone,
						COALESCE((SELECT AVG(r.rating) FROM reviews r WHERE r.worker_id = w.id), 0) AS avg_rating,
						COALESCE((SELECT COUNT(*) FROM reviews r WHERE r.worker_id = w.id), 0) AS review_count,
						COALESCE((SELECT COUNT(*) FROM bookings b WHERE b.worker_id = w.id AND LOWER(b.status) = 'completed'), 0) AS completed_jobs,
						NULL AS distance_km
					FROM workers w
					JOIN users u ON u.id = w.user_id
					WHERE {where_sql}
					ORDER BY avg_rating DESC, completed_jobs DESC, w.id ASC
				"""
				cursor.execute(query, params)
			rows = cursor.fetchall()

			workers_data = []
			for row in rows:
				avg_rating = float(row[10]) if row[10] is not None else 0.0
				if min_rating:
					try:
						if avg_rating < float(min_rating):
							continue
					except (TypeError, ValueError):
						pass

				workers_data.append(
					{
						"worker": {
							"id": row[0],
							"user_id": row[1],
							"is_verified": row[2],
							"is_available": row[3],
							"experience_years": row[4],
							"bio": row[5] or "",
							"profile_photo": row[6] or "",
						},
						"user": {
							"id": row[1],
							"name": row[7],
							"email": row[8],
							"phone": row[9],
							"role": "worker",
						},
						"rating": avg_rating,
						"review_count": row[11],
						"completed_jobs": row[12],
						"distance_km": float(row[13]) if row[13] is not None else None,
					}
				)

		return JsonResponse(
			{
				"status": "success",
				"count": len(workers_data),
				"data": workers_data,
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to fetch workers",
				"code": "WORKERS_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["GET"])
def workers_debug(request):
	"""
	GET /api/services/workers/debug/ - Debug endpoint to diagnose worker availability issues
	Shows all workers, services, and worker_services relationships
	"""
	try:
		debug_info = {
			"status": "debug",
			"workers": [],
			"services": [],
			"worker_services_links": [],
			"table_check": {},
		}

		with connection.cursor() as cursor:
			# Check if tables exist
			try:
				cursor.execute("SELECT COUNT(*) FROM workers")
				debug_info["table_check"]["workers"] = cursor.fetchone()[0]
			except:
				debug_info["table_check"]["workers"] = "TABLE NOT FOUND"

			try:
				cursor.execute("SELECT COUNT(*) FROM services")
				debug_info["table_check"]["services"] = cursor.fetchone()[0]
			except:
				debug_info["table_check"]["services"] = "TABLE NOT FOUND"

			try:
				cursor.execute("SELECT COUNT(*) FROM worker_services")
				debug_info["table_check"]["worker_services"] = cursor.fetchone()[0]
			except:
				debug_info["table_check"]["worker_services"] = "TABLE NOT FOUND"

			# Get all workers
			try:
				cursor.execute(
					"""
					SELECT w.id, w.user_id, w.is_verified, w.is_available, 
					       u.name, u.email, u.phone
					FROM workers w
					JOIN users u ON u.id = w.user_id
					ORDER BY w.id
					"""
				)
				for row in cursor.fetchall():
					debug_info["workers"].append({
						"worker_id": row[0],
						"user_id": row[1],
						"is_verified": row[2],
						"is_available": row[3],
						"name": row[4],
						"email": row[5],
						"phone": row[6],
					})
			except Exception as e:
				debug_info["workers"] = f"Query failed: {str(e)}"

			# Get all services
			try:
				cursor.execute(
					"""
					SELECT id, service_name, category_id, base_price
					FROM services
					ORDER BY id
					"""
				)
				for row in cursor.fetchall():
					debug_info["services"].append({
						"service_id": row[0],
						"service_name": row[1],
						"category_id": row[2],
						"base_price": row[3],
					})
			except Exception as e:
				debug_info["services"] = f"Query failed: {str(e)}"

			# Get all worker_services links
			try:
				cursor.execute(
					"""
					SELECT ws.worker_id, ws.service_id, ws.price_override,
					       w_name.name AS worker_name, s.service_name
					FROM worker_services ws
					LEFT JOIN workers w ON w.id = ws.worker_id
					LEFT JOIN users w_name ON w_name.id = w.user_id
					LEFT JOIN services s ON s.id = ws.service_id
					ORDER BY ws.worker_id, ws.service_id
					"""
				)
				for row in cursor.fetchall():
					debug_info["worker_services_links"].append({
						"worker_id": row[0],
						"service_id": row[1],
						"price_override": row[2],
						"worker_name": row[3],
						"service_name": row[4],
					})
			except Exception as e:
				debug_info["worker_services_links"] = f"Query failed: {str(e)}"

		return JsonResponse(debug_info, status=200)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Debug endpoint failed",
				"error": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def bulk_link_workers_to_services(request):
	"""
	POST /api/services/workers/bulk-link/
	Helper endpoint: Automatically link all workers to all services if no links exist.
	Useful if workers were created without service associations.
	"""
	try:
		with connection.cursor() as cursor:
			# Check if we need to do anything
			cursor.execute("SELECT COUNT(*) FROM worker_services")
			existing_links = cursor.fetchone()[0]
			
			if existing_links > 0:
				return JsonResponse({
					"status": "info",
					"message": "Worker-service links already exist",
					"existing_links": existing_links,
				}, status=200)
			
			# Get all workers and services
			cursor.execute("SELECT id FROM workers")
			workers = [row[0] for row in cursor.fetchall()]
			
			cursor.execute("SELECT id FROM services")
			services = [row[0] for row in cursor.fetchall()]
			
			if not workers or not services:
				return JsonResponse({
					"status": "error",
					"message": f"Cannot create links: {len(workers)} workers, {len(services)} services",
				}, status=400)
			
			# Link each worker to each service
			created_count = 0
			for worker_id in workers:
				for service_id in services:
					try:
						cursor.execute(
							"""
							INSERT INTO worker_services (worker_id, service_id)
							VALUES (%s, %s)
							ON CONFLICT DO NOTHING
							""",
							[worker_id, service_id]
						)
						created_count += cursor.rowcount
					except:
						# Ignore unique constraint violations
						pass
			
			return JsonResponse({
				"status": "success",
				"message": f"Created {created_count} worker-service links",
				"workers_count": len(workers),
				"services_count": len(services),
			}, status=200)
	except Exception as e:
		return JsonResponse({
			"status": "error",
			"message": str(e),
		}, status=500)


@csrf_exempt
@require_http_methods(["GET"])
def worker_details(request, worker_id):
	"""GET /api/services/workers/<worker_id>/ - Detailed worker profile from DB."""
	try:
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT
					w.id,
					w.user_id,
					w.is_verified,
					w.is_available,
					w.experience_years,
					w.bio,
					w.profile_photo,
					u.name,
					u.email,
					u.phone,
					COALESCE((SELECT AVG(r.rating) FROM reviews r WHERE r.worker_id = w.id), 0) AS avg_rating,
					COALESCE((SELECT COUNT(*) FROM reviews r WHERE r.worker_id = w.id), 0) AS review_count,
					COALESCE((SELECT COUNT(*) FROM bookings b WHERE b.worker_id = w.id AND LOWER(b.status) = 'completed'), 0) AS completed_jobs
				FROM workers w
				JOIN users u ON u.id = w.user_id
				WHERE w.id = %s
				""",
				[worker_id],
			)
			worker_row = cursor.fetchone()

			if not worker_row:
				return JsonResponse(
					{
						"status": "error",
						"message": "Worker not found",
						"code": "WORKER_NOT_FOUND",
					},
					status=404,
				)

			cursor.execute(
				"""
				SELECT
					s.id,
					s.category_id,
					s.service_name,
					COALESCE(ws.price_override, s.base_price) AS effective_price,
					sc.category_name
				FROM worker_services ws
				JOIN services s ON s.id = ws.service_id
				JOIN service_categories sc ON sc.id = s.category_id
				WHERE ws.worker_id = %s
				ORDER BY sc.category_name ASC, s.service_name ASC
				""",
				[worker_id],
			)
			service_rows = cursor.fetchall()

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
				LIMIT 20
				""",
				[worker_id],
			)
			review_rows = cursor.fetchall()

		services = [
			{
				"id": row[0],
				"category_id": row[1],
				"service_name": row[2],
				"base_price": float(row[3]),
				"category_name": row[4],
			}
			for row in service_rows
		]

		reviews = [
			{
				"id": row[0],
				"booking_id": row[1],
				"user_id": row[2],
				"worker_id": row[3],
				"rating": row[4],
				"comment": row[5] or "",
				"created_at": row[6].isoformat() if row[6] else None,
				"reviewer_name": row[7],
			}
			for row in review_rows
		]

		payload = {
			"worker": {
				"id": worker_row[0],
				"user_id": worker_row[1],
				"is_verified": worker_row[2],
				"is_available": worker_row[3],
				"experience_years": worker_row[4],
				"bio": worker_row[5] or "",
				"profile_photo": worker_row[6] or "",
			},
			"user": {
				"id": worker_row[1],
				"name": worker_row[7],
				"email": worker_row[8],
				"phone": worker_row[9],
				"role": "worker",
			},
			"rating": float(worker_row[10]) if worker_row[10] is not None else 0.0,
			"review_count": worker_row[11],
			"completed_jobs": worker_row[12],
			"distance": float((worker_row[0] % 10) + 1),
			"services": services,
			"reviews": reviews,
		}

		return JsonResponse({"status": "success", "data": payload}, status=200)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to fetch worker details",
				"code": "WORKER_DETAILS_ERROR",
				"details": str(e),
			},
			status=500,
		)
