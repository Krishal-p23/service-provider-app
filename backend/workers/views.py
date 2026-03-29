from django.shortcuts import render
from django.http import JsonResponse
from django.db import connection
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
import json
from datetime import datetime, timedelta

ACTIVE_JOB_STATUSES = ("pending", "confirmed", "in_progress", "completed")

# Create your views here.

@csrf_exempt
@require_http_methods(["GET"])
def auth_debug(request):
    """Debug endpoint to check authentication"""
    auth_header = request.headers.get('Authorization', 'NOT PRESENT')
    user_id = get_current_user_id(request)
    
    # Check if worker exists
    worker_exists = False
    if user_id:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, user_id FROM workers WHERE user_id = %s", [user_id])
            worker_row = cursor.fetchone()
            worker_exists = worker_row is not None
    
    return JsonResponse({
        "status": "debug",
        "auth_header": auth_header[:50] if len(auth_header) > 50 else auth_header,
        "extracted_user_id": user_id,
        "worker_exists": worker_exists,
        "has_jobs": user_id is not None and worker_exists,
    }, status=200)


def get_current_user_id(request):
    """Extract user_id from request Authorization header or session"""
    # Try Authorization header first (Bearer token from Flutter app)
    auth_header = request.headers.get('Authorization', '')
    if auth_header.startswith('Bearer '):
        try:
            user_id = int(auth_header[7:])  # Remove 'Bearer ' prefix
            print(f"✅ DEBUG: Extracted user_id {user_id} from Authorization header")
            return user_id
        except (ValueError, TypeError) as e:
            print(f"❌ DEBUG: Failed to parse Bearer token: {e}")
    
    # Fallback to session or X-User-Id header
    try:
        user_id = request.session.get('user_id') or request.headers.get('X-User-Id')
        if user_id:
            print(f"✅ DEBUG: Using user_id {user_id} from session/header")
            return int(user_id)
    except (ValueError, TypeError) as e:
        print(f"❌ DEBUG: Failed to parse user_id from session/header: {e}")
    
    print(f"❌ DEBUG: No user_id found. Auth header: {auth_header[:50]}")
    return None


def _get_worker_id_by_user_id(user_id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT id FROM workers WHERE user_id = %s", [user_id])
        row = cursor.fetchone()
    return row[0] if row else None


@csrf_exempt
@require_http_methods(["GET"])
def profile(request):
    """
    GET /api/workers/profile/
    Fetch current worker's profile including basic info, verification status, availability
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse({
                "status": "error",
                "message": "Unauthorized. User ID not found",
                "code": "UNAUTHORIZED"
            }, status=401)
        
        with connection.cursor() as cursor:
            # Get worker profile
            cursor.execute("""
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
                    u.phone
                FROM workers w
                JOIN users u ON w.user_id = u.id
                WHERE w.user_id = %s
            """, [user_id])
            
            row = cursor.fetchone()
            if not row:
                return JsonResponse({
                    "status": "error",
                    "message": "Worker profile not found",
                    "code": "PROFILE_NOT_FOUND"
                }, status=404)
            
            # Get worker services
            cursor.execute("""
                SELECT 
                    ws.id,
                    ws.service_id,
                    s.service_name,
                    s.base_price,
                    ws.price_override,
                    sc.category_name
                FROM worker_services ws
                JOIN services s ON ws.service_id = s.id
                JOIN service_categories sc ON s.category_id = sc.id
                WHERE ws.worker_id = %s
                ORDER BY sc.category_name, s.service_name
            """, [row[0]])  # row[0] is worker.id
            
            services = []
            for svc_row in cursor.fetchall():
                services.append({
                    "service_id": svc_row[1],
                    "service_name": svc_row[2],
                    "base_price": float(svc_row[3]),
                    "price_override": float(svc_row[4]) if svc_row[4] else None,
                    "category_name": svc_row[5]
                })
        
        return JsonResponse({
            "status": "success",
            "data": {
                "worker_id": row[0],
                "user_id": row[1],
                "name": row[7],
                "email": row[8],
                "phone": row[9],
                "is_verified": row[2],
                "is_available": row[3],
                "experience_years": row[4],
                "bio": row[5] or "",
                "profile_photo": row[6] or "",
                "services": services
            }
        }, status=200)
    
    except Exception as e:
        print(f"Error fetching worker profile: {e}")
        return JsonResponse({
            "status": "error",
            "message": "Failed to fetch worker profile",
            "code": "PROFILE_ERROR",
            "details": str(e)
        }, status=500)


@csrf_exempt
@require_http_methods(["GET"])
def jobs(request):
    """
    GET /api/workers/jobs?filter=day|week|month
    Fetch current worker's scheduled bookings
    
    Query parameters:
    - filter: 'day' (default), 'week', or 'month'
    - status: optional filter by job status (confirmed, pending, completed, cancelled)
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse({
                "status": "error",
                "message": "Unauthorized. User ID not found",
                "code": "UNAUTHORIZED"
            }, status=401)
        
        filter_type = request.GET.get('filter', 'day').lower()
        status_filter = request.GET.get('status', '').lower()
        
        # Validate filter type
        if filter_type not in ['day', 'week', 'month']:
            filter_type = 'day'
        
        # Calculate date range
        now = datetime.now()
        today_start = datetime(now.year, now.month, now.day, 0, 0, 0)  # Midnight today
        
        if filter_type == 'day':
            # Today: midnight to midnight
            start_date = today_start
            end_date = today_start.replace(hour=23, minute=59, second=59)
        elif filter_type == 'week':
            # Next 7 days from today
            start_date = today_start
            end_date = (today_start + timedelta(days=7)).replace(hour=23, minute=59, second=59)
        else:  # month
            # Next 30 days from today
            start_date = today_start
            end_date = (today_start + timedelta(days=30)).replace(hour=23, minute=59, second=59)
        
        with connection.cursor() as cursor:
            # First, get worker_id from user_id
            cursor.execute("SELECT id FROM workers WHERE user_id = %s", [user_id])
            worker_row = cursor.fetchone()
            if not worker_row:
                return JsonResponse({
                    "status": "success",
                    "data": {
                        "filter": filter_type,
                        "jobs": []
                    }
                }, status=200)
            
            worker_id = worker_row[0]
            
            # Query bookings for this worker
            query = """
                SELECT 
                    b.id,
                    b.service_id,
                    b.user_id,
                    b.scheduled_date,
                    b.status,
                    b.total_amount,
                    s.service_name,
                    u.name as customer_name,
                    u.phone as customer_phone,
                    sc.category_name
                FROM bookings b
                JOIN services s ON b.service_id = s.id
                JOIN service_categories sc ON s.category_id = sc.id
                JOIN users u ON b.user_id = u.id
                WHERE b.worker_id = %s
            """
            
            params = [worker_id]
            
            # Add date range filter
            query += " AND b.scheduled_date >= %s AND b.scheduled_date <= %s"
            params.extend([start_date, end_date])
            
            # Add status filter if provided
            if status_filter:
                query += " AND LOWER(b.status) = %s"
                params.append(status_filter)
            
            query += " ORDER BY b.scheduled_date ASC"
            
            cursor.execute(query, params)
            
            jobs_list = []
            for row in cursor.fetchall():
                jobs_list.append({
                    "job_id": row[0],
                    "service_id": row[1],
                    "customer_id": row[2],
                    "service_name": row[6],
                    "customer_name": row[7],
                    "customer_phone": row[8],
                    "scheduled_time": row[3].isoformat() if isinstance(row[3], datetime) else str(row[3]),
                    "status": row[4],
                    "amount": float(row[5]),
                    "category_name": row[9]
                })
        
        return JsonResponse({
            "status": "success",
            "data": {
                "filter": filter_type,
                "job_count": len(jobs_list),
                "jobs": jobs_list
            }
        }, status=200)
    
    except Exception as e:
        print(f"Error fetching worker jobs: {e}")
        return JsonResponse({
            "status": "error",
            "message": "Failed to fetch worker jobs",
            "code": "JOBS_ERROR",
            "details": str(e)
        }, status=500)


@csrf_exempt
@require_http_methods(["GET"])
def stats(request):
    """
    GET /api/workers/stats/
    Fetch worker statistics: total earnings, today's jobs count, average rating, reviews count
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse({
                "status": "error",
                "message": "Unauthorized. User ID not found",
                "code": "UNAUTHORIZED"
            }, status=401)
        
        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse({
                "status": "success",
                "data": {
                    "total_earnings": 0,
                    "today_jobs_count": 0,
                    "average_rating": 0,
                    "total_reviews": 0,
                    "completed_jobs": 0,
                }
            }, status=200)

        today = datetime.now().date()

        with connection.cursor() as cursor:
            # Total earnings from completed bookings
            cursor.execute(
                """
                SELECT COALESCE(SUM(total_amount), 0)
                FROM bookings
                WHERE worker_id = %s
                  AND LOWER(status) = 'completed'
                """,
                [worker_id],
            )
            total_earnings = float(cursor.fetchone()[0] or 0)

            # Today's jobs count (all active/relevant statuses)
            cursor.execute(
                """
                SELECT COUNT(*)
                FROM bookings
                WHERE worker_id = %s
                  AND DATE(scheduled_date) = %s
                  AND LOWER(status) = ANY(%s)
                """,
                [worker_id, today, list(ACTIVE_JOB_STATUSES)],
            )
            today_jobs_count = int(cursor.fetchone()[0] or 0)

            # Average rating and review count
            cursor.execute(
                """
                SELECT COALESCE(AVG(rating), 0), COUNT(*)
                FROM reviews
                WHERE worker_id = %s
                """,
                [worker_id],
            )
            avg_rating_row = cursor.fetchone()
            average_rating = float(avg_rating_row[0] or 0)
            total_reviews = int(avg_rating_row[1] or 0)

            # Completed jobs count
            cursor.execute(
                """
                SELECT COUNT(*)
                FROM bookings
                WHERE worker_id = %s
                  AND LOWER(status) = 'completed'
                """,
                [worker_id],
            )
            completed_jobs = int(cursor.fetchone()[0] or 0)
        
        return JsonResponse({
            "status": "success",
            "data": {
                "total_earnings": total_earnings,
                "today_jobs_count": today_jobs_count,
                "average_rating": round(average_rating, 2),
                "total_reviews": total_reviews,
                "completed_jobs": completed_jobs
            }
        }, status=200)
    
    except Exception as e:
        print(f"Error fetching worker stats: {e}")
        return JsonResponse({
            "status": "error",
            "message": "Failed to fetch worker stats",
            "code": "STATS_ERROR",
            "details": str(e)
        }, status=500)


@csrf_exempt
@require_http_methods(["GET"])
def earnings_summary(request):
    """
    GET /api/workers/earnings-summary/?months=6
    Returns month-wise real earnings, upcoming transfer and pending deductions.
    """
    try:
        user_id = get_current_user_id(request)
        if not user_id:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Unauthorized. User ID not found",
                    "code": "UNAUTHORIZED",
                },
                status=401,
            )

        worker_id = _get_worker_id_by_user_id(user_id)
        if not worker_id:
            return JsonResponse(
                {
                    "status": "success",
                    "data": {
                        "months": [],
                        "current_month_earnings": 0,
                        "upcoming_transfer": 0,
                        "pending_deductions": 0,
                        "deductions_breakdown": [],
                    },
                },
                status=200,
            )

        raw_months = request.GET.get("months", "6")
        try:
            months_count = max(1, min(12, int(raw_months)))
        except ValueError:
            months_count = 6

        now = datetime.now()
        month_start = datetime(now.year, now.month, 1)
        start_month = month_start - timedelta(days=32 * (months_count - 1))
        start_month = datetime(start_month.year, start_month.month, 1)

        with connection.cursor() as cursor:
            # Keep SQL database-agnostic (SQLite/Postgres) by aggregating months in Python.
            cursor.execute(
                """
                SELECT scheduled_date, total_amount
                FROM bookings
                WHERE worker_id = %s
                  AND scheduled_date >= %s
                  AND LOWER(status) = 'completed'
                ORDER BY scheduled_date ASC
                """,
                [worker_id, start_month],
            )
            rows = cursor.fetchall()

            monthly_map = {}
            for scheduled_date, total_amount in rows:
                dt = scheduled_date
                if isinstance(dt, str):
                    dt = datetime.fromisoformat(dt)
                key = (dt.year, dt.month)
                monthly_map[key] = float(monthly_map.get(key, 0)) + float(total_amount or 0)

            months = []
            cursor_month = start_month
            for _ in range(months_count):
                key = (cursor_month.year, cursor_month.month)
                months.append(
                    {
                        "label": cursor_month.strftime("%b"),
                        "year": cursor_month.year,
                        "month": cursor_month.month,
                        "earnings": float(monthly_map.get(key, 0)),
                    }
                )

                next_month = cursor_month.month + 1
                next_year = cursor_month.year
                if next_month == 13:
                    next_month = 1
                    next_year += 1
                cursor_month = datetime(next_year, next_month, 1)

            current_month_earnings = months[-1]["earnings"] if months else 0

            # Worker gets 98% of completed earnings; admin keeps 2% platform fee.
            commission_rate = 0.02
            commission_amount = round(current_month_earnings * commission_rate, 2)
            upcoming_transfer = round(current_month_earnings - commission_amount, 2)

            # Keep cancellation count for visibility (does not reduce payout).
            next_month = month_start.month + 1
            next_month_year = month_start.year
            if next_month == 13:
                next_month = 1
                next_month_year += 1
            next_month_start = datetime(next_month_year, next_month, 1)

            cursor.execute(
                """
                SELECT COUNT(*)
                FROM bookings
                WHERE worker_id = %s
                  AND scheduled_date >= %s
                  AND scheduled_date < %s
                  AND LOWER(status) = 'cancelled'
                """,
                [worker_id, month_start, next_month_start],
            )
            cancelled_count = int(cursor.fetchone()[0] or 0)

            pending_deductions = commission_amount

            deductions_breakdown = [
                {
                    "title": "Platform Commission",
                    "amount": commission_amount,
                    "description": "2% admin fee on this month completed earnings",
                },
            ]

        return JsonResponse(
            {
                "status": "success",
                "data": {
                    "months": months,
                    "current_month_earnings": current_month_earnings,
                    "upcoming_transfer": upcoming_transfer,
                    "pending_deductions": pending_deductions,
                    "deductions_breakdown": deductions_breakdown,
                    "cancelled_count_current_month": cancelled_count,
                },
            },
            status=200,
        )
    except Exception as e:
        print(f"Error fetching worker earnings summary: {e}")
        return JsonResponse(
            {
                "status": "error",
                "message": "Failed to fetch worker earnings summary",
                "code": "EARNINGS_SUMMARY_ERROR",
                "details": str(e),
            },
            status=500,
        )
