from django.urls import path
from .views import service_categories, services_list, workers_list, worker_details, workers_debug, bulk_link_workers_to_services

app_name = 'services'

urlpatterns = [
	path('categories/', service_categories, name='service_categories'),
	path('list/', services_list, name='services_list'),
	path('workers/', workers_list, name='workers_list'),
	path('workers/debug/', workers_debug, name='workers_debug'),
	path('workers/bulk-link/', bulk_link_workers_to_services, name='bulk_link_workers_to_services'),
	path('workers/<int:worker_id>/', worker_details, name='worker_details'),
]
