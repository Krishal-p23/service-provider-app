from django.urls import path
from .views import (
	user_bookings,
	create_booking,
	update_booking_status,
	reschedule_booking,
	booking_detail,
	worker_availability,
	mark_job_done,
	initiate_job_otp,
	verify_job_otp_endpoint,
)

app_name = 'bookings'

urlpatterns = [
	path('user/<int:user_id>/', user_bookings, name='user_bookings'),
	path('create/', create_booking, name='create_booking'),
	path('availability/', worker_availability, name='worker_availability'),
	path('<int:booking_id>/', booking_detail, name='booking_detail'),
	path('<int:booking_id>/status/', update_booking_status, name='update_booking_status'),
	path('<int:booking_id>/reschedule/', reschedule_booking, name='reschedule_booking'),
	path('<int:booking_id>/mark-done/', mark_job_done, name='mark_job_done'),
	path('<int:booking_id>/initiate-otp/', initiate_job_otp, name='initiate_job_otp'),
	path('<int:booking_id>/verify-otp/', verify_job_otp_endpoint, name='verify_job_otp'),
]
