"""
URL configuration for backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse
from authentication.views import locations_collection, location_by_id, location_by_user
import logging

logger = logging.getLogger(__name__)


def root_status(request):
    return JsonResponse(
        {
            'service': 'servigo-backend',
            'status': 'ok',
            'message': 'Backend is running. Use /api/... endpoints.',
        },
        status=200,
    )


def health_check(request):
    return JsonResponse({'ok': True}, status=200)


def test_logging(request):
    """Test endpoint to verify logging is working. Check Papertrail logs immediately after calling this."""
    logger.info('[TEST LOG] Testing Papertrail logging from servigo-backend')
    logger.warning('[TEST LOG] This is a warning message')
    logger.error('[TEST LOG] This is an error message')
    return JsonResponse({'message': 'Test log messages sent. Check Papertrail within 5 seconds.'}, status=200)

urlpatterns = [
    path('', root_status, name='root_status'),
    path('health/', health_check, name='health_check'),
        path('test-logging/', test_logging, name='test_logging'),
    path('admin/', admin.site.urls),
    path('api/accounts/', include('authentication.urls')),
    path('api/locations/', locations_collection, name='locations_collection'),
    path('api/locations/<int:location_id>/', location_by_id, name='location_by_id'),
    path('api/locations/user/<int:user_id>/', location_by_user, name='location_by_user'),
    path('api/workers/', include('workers.urls')),
    path('api/services/', include('services.urls')),
    path('api/bookings/', include('bookings.urls')),
    path('api/reviews/', include('reviews.urls')),
    path('api/wallet/', include(('payments.urls', 'wallet'), namespace='wallet')),
    path('api/payments/', include(('payments.urls', 'payments'), namespace='payments')),
]

# Serve media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
