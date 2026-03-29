from django.urls import path
from .views import (
	user_bookings,
	create_booking,
	update_booking_status,
	booking_detail,
	worker_availability,
)

app_name = 'bookings'

urlpatterns = [
	path('user/<int:user_id>/', user_bookings, name='user_bookings'),
	path('create/', create_booking, name='create_booking'),
	path('availability/', worker_availability, name='worker_availability'),
	path('<int:booking_id>/', booking_detail, name='booking_detail'),
	path('<int:booking_id>/status/', update_booking_status, name='update_booking_status'),
]
