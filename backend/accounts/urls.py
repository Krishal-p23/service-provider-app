from django.urls import include, path

app_name = 'accounts'

# Keep this app as a compatibility alias. All account/auth APIs are served by
# authentication.urls to avoid duplicate implementations.
urlpatterns = [
    path('', include('authentication.urls')),
]
