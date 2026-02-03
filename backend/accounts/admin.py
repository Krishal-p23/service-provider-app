from django.contrib import admin
from .models import User, CustomerProfile, WorkerProfile

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('id', 'role', 'username', 'email', 'phone', 'is_active', 'is_staff', 'date_joined')
    search_fields = ('username', 'email', 'phone')
    
@admin.register(CustomerProfile)
class CustomerProfileAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'username')
    
@admin.register(WorkerProfile)
class WorkerProfileAdmin(admin.ModelAdmin):
    list_display = ('id', 'worker_name', 'service_type', 'verification_status')
    list_filters = ('verification_status', 'service_type')