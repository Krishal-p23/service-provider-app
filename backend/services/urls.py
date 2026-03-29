from django.urls import path
from .views import service_categories, services_list, workers_list, worker_details

app_name = 'services'

urlpatterns = [
	path('categories/', service_categories, name='service_categories'),
	path('list/', services_list, name='services_list'),
	path('workers/', workers_list, name='workers_list'),
	path('workers/<int:worker_id>/', worker_details, name='worker_details'),
]
