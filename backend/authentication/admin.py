from django.contrib import admin
from .models import AppUser, UserLocation

admin.site.register(AppUser)
admin.site.register(UserLocation)
