from django.contrib import admin
from .models import Worker, WorkerService
from .verification_models import WorkerDocumentVerification

admin.site.register(Worker)
admin.site.register(WorkerService)
admin.site.register(WorkerDocumentVerification)
