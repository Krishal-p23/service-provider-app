from django.shortcuts import render
from django.http import JsonResponse
from django.db import connection
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
import json
from datetime import datetime, timedelta

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
        
        with connection.cursor() as cursor:
            # Get worker_id
            cursor.execute("SELECT id FROM workers WHERE user_id = %s", [user_id])
            worker_row = cursor.fetchone()
            if not worker_row:
                return JsonResponse({
                    "status": "success",
                    "data": {
                        "total_earnings": 0,
                        "today_jobs_count": 0,
                        "average_rating": 0,
                        "total_reviews": 0,
                        "completed_jobs": 0
                    }
                }, status=200)
            
            worker_id = worker_row[0]
            today = datetime.now().date()
            
            # Total earnings from completed bookings
            cursor.execute("""
                SELECT COALESCE(SUM(amount), 0) FROM bookings 
                WHERE worker_id = %s AND status = 'Completed'
            """, [worker_id])
            total_earnings = float(cursor.fetchone()[0])
            
            # Today's jobs count
            cursor.execute("""
                SELECT COUNT(*) FROM bookings 
                WHERE worker_id = %s AND DATE(scheduled_time) = %s
            """, [worker_id, today])
            today_jobs_count = cursor.fetchone()[0]
            
            # Average rating
            cursor.execute("""
                SELECT COALESCE(AVG(rating), 0), COUNT(*) FROM reviews 
                WHERE worker_id = %s
            """, [worker_id])
            avg_rating_row = cursor.fetchone()
            average_rating = float(avg_rating_row[0])
            total_reviews = avg_rating_row[1]
            
            # Completed jobs count
            cursor.execute("""
                SELECT COUNT(*) FROM bookings 
                WHERE worker_id = %s AND status = 'Completed'
            """, [worker_id])
            completed_jobs = cursor.fetchone()[0]
        
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
