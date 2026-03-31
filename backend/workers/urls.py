from django.urls import path
from .views import profile, profile_photo, jobs, stats, auth_debug, earnings_summary, past_services, bank_details, notifications, notifications_mark_all_read, availability, validate_ifsc_endpoint, start_kyc_session, kyc_callback, kyc_webhook, kyc_mock_page, kyc_mock_approve, kyc_mock_reject, services_selection, submit_worker_upi_qr
from .verification_views import WorkerDocumentUploadView, AdminDocumentVerificationView

app_name = 'workers'

urlpatterns = [
    path('profile/', profile, name='profile'),
    path('profile-photo/', profile_photo, name='profile_photo'),
    path('jobs/', jobs, name='jobs'),
    path('stats/', stats, name='stats'),
    path('earnings-summary/', earnings_summary, name='earnings_summary'),
    path('past-services/', past_services, name='past_services'),
    path('bank-details/', bank_details, name='bank_details'),
    path('submit-upi-qr/', submit_worker_upi_qr, name='submit_worker_upi_qr'),
    path('services/', services_selection, name='services_selection'),
    path('availability/', availability, name='availability'),
    path('validate-ifsc/', validate_ifsc_endpoint, name='validate_ifsc'),
    path('kyc/start/', start_kyc_session, name='start_kyc_session'),
    path('kyc/callback/', kyc_callback, name='kyc_callback'),
    path('kyc/webhook/', kyc_webhook, name='kyc_webhook'),
    path('kyc/mock/', kyc_mock_page, name='kyc_mock'),
    path('kyc/mock-approve/', kyc_mock_approve, name='kyc_mock_approve'),
    path('kyc/mock-reject/', kyc_mock_reject, name='kyc_mock_reject'),
    path('notifications/', notifications, name='notifications'),
    path('notifications/mark-all-read/', notifications_mark_all_read, name='notifications_mark_all_read'),
    path('auth-debug/', auth_debug, name='auth_debug'),  # Debug endpoint
    # Document verification endpoints
    path('documents/upload/', WorkerDocumentUploadView.as_view(), name='worker-document-upload'),
    path('documents/admin/', AdminDocumentVerificationView.as_view(), name='admin-document-review'),
]
