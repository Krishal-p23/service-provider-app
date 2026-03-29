from django.urls import path
from .views import profile, jobs, stats, auth_debug
from .verification_views import WorkerDocumentUploadView, AdminDocumentVerificationView

app_name = 'workers'

urlpatterns = [
    path('profile/', profile, name='profile'),
    path('jobs/', jobs, name='jobs'),
    path('stats/', stats, name='stats'),
    path('auth-debug/', auth_debug, name='auth_debug'),  # Debug endpoint
    # Document verification endpoints
    path('documents/upload/', WorkerDocumentUploadView.as_view(), name='worker-document-upload'),
    path('documents/admin/', AdminDocumentVerificationView.as_view(), name='admin-document-review'),
]
