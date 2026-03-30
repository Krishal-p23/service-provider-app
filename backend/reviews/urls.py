from django.urls import path
from .views import worker_reviews, user_reviews, create_review, check_review_status

app_name = 'reviews'

urlpatterns = [
	path('worker/<int:worker_id>/', worker_reviews, name='worker_reviews'),
	path('user/<int:user_id>/', user_reviews, name='user_reviews'),
	path('check/<int:booking_id>/', check_review_status, name='check_review_status'),
	path('create/', create_review, name='create_review'),
]
