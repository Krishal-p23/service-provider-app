from django.contrib import admin
from .models import Worker, WorkerService
from .verification_models import WorkerDocumentVerification
from django.utils import timezone

admin.site.register(Worker)
admin.site.register(WorkerService)


@admin.register(WorkerDocumentVerification)
class WorkerDocumentVerificationAdmin(admin.ModelAdmin):
	list_display = (
		'id',
		'worker',
		'document_type',
		'status',
		'created_at',
		'verified_at',
	)
	list_filter = ('status', 'document_type', 'created_at')
	search_fields = ('worker__user__name', 'document_number')
	actions = ('approve_documents', 'reject_documents')

	@admin.action(description='Approve selected documents')
	def approve_documents(self, request, queryset):
		updated = 0
		for verification in queryset:
			verification.status = WorkerDocumentVerification.STATUS_VERIFIED
			verification.verified_at = timezone.now()
			verification.verified_by = request.user if hasattr(request.user, 'id') else None
			verification.rejection_reason = ''
			verification.save(update_fields=['status', 'verified_at', 'verified_by', 'rejection_reason'])

			verification.worker.is_verified = True
			verification.worker.save(update_fields=['is_verified'])
			updated += 1

		self.message_user(request, f'Approved {updated} document verification request(s).')

	@admin.action(description='Reject selected documents')
	def reject_documents(self, request, queryset):
		reason = 'Rejected by admin review'
		updated = 0
		for verification in queryset:
			verification.status = WorkerDocumentVerification.STATUS_REJECTED
			verification.verified_at = timezone.now()
			verification.verified_by = request.user if hasattr(request.user, 'id') else None
			verification.rejection_reason = reason
			verification.save(update_fields=['status', 'verified_at', 'verified_by', 'rejection_reason'])

			verification.worker.is_verified = False
			verification.worker.save(update_fields=['is_verified'])
			updated += 1

		self.message_user(request, f'Rejected {updated} document verification request(s). Update rejection reason per record if needed.')
