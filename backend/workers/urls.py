from django.urls import path
from .views import profile, jobs, stats, auth_debug, earnings_summary, past_services, bank_details, notifications, notifications_mark_all_read
from .verification_views import WorkerDocumentUploadView, AdminDocumentVerificationView

app_name = 'workers'

urlpatterns = [
    path('profile/', profile, name='profile'),
    path('jobs/', jobs, name='jobs'),
    path('stats/', stats, name='stats'),
    path('earnings-summary/', earnings_summary, name='earnings_summary'),
    path('past-services/', past_services, name='past_services'),
    path('bank-details/', bank_details, name='bank_details'),
    path('notifications/', notifications, name='notifications'),
    path('notifications/mark-all-read/', notifications_mark_all_read, name='notifications_mark_all_read'),
    path('auth-debug/', auth_debug, name='auth_debug'),  # Debug endpoint
    # Document verification endpoints
    path('documents/upload/', WorkerDocumentUploadView.as_view(), name='worker-document-upload'),
    path('documents/admin/', AdminDocumentVerificationView.as_view(), name='admin-document-review'),
]
