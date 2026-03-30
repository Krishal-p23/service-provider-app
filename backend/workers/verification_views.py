"""
Worker Document Verification - Serializers and Views
Handles Aadhar, Government ID uploads and verification
"""
from rest_framework import serializers
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.status import (
    HTTP_200_OK, HTTP_400_BAD_REQUEST, HTTP_401_UNAUTHORIZED, 
    HTTP_403_FORBIDDEN
)
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
import base64
import logging
from .verification_models import WorkerDocumentVerification
from .surepass_service import SurepassVerificationService
from .views import get_current_user_id

logger = logging.getLogger(__name__)


class WorkerDocumentVerificationSerializer(serializers.ModelSerializer):
    """Serializer for worker document verification"""
    worker_name = serializers.CharField(source='worker.user.name', read_only=True)
    is_verified = serializers.BooleanField(read_only=True)
    is_pending = serializers.BooleanField(read_only=True)
    is_rejected = serializers.BooleanField(read_only=True)
    document_type_display = serializers.CharField(
        source='get_document_type_display',
        read_only=True
    )
    status_display = serializers.CharField(
        source='get_status_display',
        read_only=True
    )
    
    class Meta:
        model = WorkerDocumentVerification
        fields = [
            'id',
            'worker_name',
            'document_type',
            'document_type_display',
            'document_number',
            'document_image',
            'document_image_back',
            'status',
            'status_display',
            'rejection_reason',
            'is_verified',
            'is_pending',
            'is_rejected',
            'created_at',
            'updated_at',
            'verified_at',
        ]
        read_only_fields = [
            'id',
            'status',
            'rejection_reason',
            'verified_by',
            'created_at',
            'updated_at',
            'verified_at',
        ]


class WorkerDocumentUploadView(APIView):
    """
    API endpoint for workers to upload government ID documents
    """
    def post(self, request):
        """
        Upload worker document for verification
        Expected fields:
        - document_type: 'aadhar', 'pan', 'driving_license', 'passport'
        - document_number: ID number
        - document_image: Image file (front)
        - document_image_back: Image file (back) - optional
        """
        try:
            print(f'[Upload] Received request: {request.META.get("HTTP_AUTHORIZATION", "No auth")}')
            user_id = get_current_user_id(request)
            if not user_id:
                return Response(
                    {'error': 'Authentication required. Use Authorization: Bearer <user_id>'},
                    status=HTTP_401_UNAUTHORIZED
                )

            from authentication.models import AppUser
            try:
                user = AppUser.objects.get(id=user_id)
            except AppUser.DoesNotExist:
                return Response(
                    {'error': 'Invalid authorization token'},
                    status=HTTP_401_UNAUTHORIZED
                )
            
            if not hasattr(user, 'role'):
                return Response(
                    {'error': 'User authentication failed - role attribute missing'},
                    status=HTTP_401_UNAUTHORIZED
                )
            
            if user.role != 'worker':
                return Response(
                    {'error': 'Only workers can upload documents'},
                    status=HTTP_403_FORBIDDEN
                )
            
            # Get worker
            from .models import Worker
            try:
                worker = Worker.objects.get(user=user)
                print(f'[Upload] Worker found: {worker.id}')
            except Worker.DoesNotExist:
                print(f'[Upload] Worker profile not found for user {user.id}')
                return Response(
                    {'error': 'Worker profile not found'},
                    status=HTTP_400_BAD_REQUEST
                )
            
            # Get form data
            document_type = request.data.get('document_type')
            document_number = request.data.get('document_number')
            document_image = request.FILES.get('document_image')
            document_image_back = request.FILES.get('document_image_back')
            
            # Validation
            if not all([document_type, document_number, document_image]):
                return Response(
                    {'error': 'Missing required fields: document_type, document_number, document_image'},
                    status=HTTP_400_BAD_REQUEST
                )
            
            # Create or update verification record
            verification, created = WorkerDocumentVerification.objects.update_or_create(
                worker=worker,
                defaults={
                    'document_type': document_type,
                    'document_number': document_number,
                    'document_image': document_image,
                    'document_image_back': document_image_back,
                    'status': WorkerDocumentVerification.STATUS_PENDING,
                }
            )
            
            logger.info(f'[Upload] Document saved (created={created}) for worker {worker.id}')
            
            # ✅ IMPORTANT: Return success immediately without waiting for API verification
            # API verification happens in background - see trigger_async_verification() method
            serializer = WorkerDocumentVerificationSerializer(verification)
            
            # Trigger background verification asynchronously (don't wait for it)
            if SurepassVerificationService.is_enabled() and document_type == 'aadhar':
                logger.info(f'[Upload] Triggering async Surepass verification for worker {worker.id}')
                # Start verification in background thread (non-blocking)
                import threading
                thread = threading.Thread(
                    target=WorkerDocumentUploadView.trigger_async_verification,
                    args=(verification.id, document_number, verification.document_image.path),
                    daemon=True
                )
                thread.start()
                logger.info(f'[Upload] Background verification thread started')
            
            return Response(
                {
                    'message': 'Document uploaded successfully' if created else 'Document updated',
                    'data': serializer.data,
                    'action': 'created' if created else 'updated',
                    'note': 'Verification in progress in background' if SurepassVerificationService.is_enabled() and document_type == 'aadhar' else 'Manual verification required'
                },
                status=HTTP_200_OK
            )
        
        except Exception as e:
            logger.error(f'[Upload] Exception: {str(e)}')
            return Response(
                {'error': f'Error uploading document: {str(e)}'},
                status=HTTP_400_BAD_REQUEST
            )
    
    @staticmethod
    def trigger_async_verification(verification_id: int, document_number: str, image_path: str):
        """
        Background thread task to verify document asynchronously
        Called in separate thread - doesn't block the upload response
        """
        import time
        from django.db import connection
        
        logger.info(f'[AsyncVerification] Starting background verification for verification_id={verification_id}')
        
        try:
            # Small delay to ensure file is written to disk
            time.sleep(1)
            
            # Get the verification record
            verification = WorkerDocumentVerification.objects.get(id=verification_id)
            
            # Call Surepass API with base64 image payload
            logger.info(f'[AsyncVerification] Calling Surepass OCR API for {document_number}')
            with open(image_path, 'rb') as image_file:
                image_base64 = base64.b64encode(image_file.read()).decode('utf-8')
            result = SurepassVerificationService.verify_aadhaar_ocr(image_base64)
            
            logger.info(f'[AsyncVerification] Didit result: {result}')
            
            # Update verification status based on result
            if result.get('success'):
                verification.status = WorkerDocumentVerification.STATUS_VERIFIED
                verification.verified_at = timezone.now()
                verification.verified_by = None  # Auto-verified
                logger.info(f'[AsyncVerification] ✅ Auto-verified for worker {verification.worker.id}')
                
                # Update worker's verification status
                verification.worker.is_verified = True
                verification.worker.save()
            
            else:
                verification.status = WorkerDocumentVerification.STATUS_REJECTED
                verification.rejection_reason = result.get('message', 'Aadhaar verification failed')
                verification.verified_at = timezone.now()
                logger.warning(f'[AsyncVerification] ❌ Rejected for worker {verification.worker.id}: {result.get("message")}')
            
            verification.save()
            logger.info(f'[AsyncVerification] ✅ Completed for verification_id={verification_id}')
        
        except WorkerDocumentVerification.DoesNotExist:
            logger.error(f'[AsyncVerification] ❌ Verification record not found: {verification_id}')
        except Exception as e:
            logger.error(f'[AsyncVerification] ❌ Exception: {str(e)}')
        finally:
            # Close database connection for this thread
            connection.close()
    
    def get(self, request):
        """Get current worker's document verification status"""
        try:
            user_id = get_current_user_id(request)
            if not user_id:
                return Response(
                    {'error': 'Authentication required'},
                    status=HTTP_401_UNAUTHORIZED
                )

            from authentication.models import AppUser
            try:
                user = AppUser.objects.get(id=user_id)
            except AppUser.DoesNotExist:
                return Response(
                    {'error': 'Invalid authorization token'},
                    status=HTTP_401_UNAUTHORIZED
                )

            if user.role != 'worker':
                return Response(
                    {'error': 'Only workers can view their documents'},
                    status=HTTP_403_FORBIDDEN
                )
            
            from .models import Worker
            try:
                worker = Worker.objects.get(user=user)
            except Worker.DoesNotExist:
                return Response(
                    {'error': 'Worker profile not found'},
                    status=HTTP_400_BAD_REQUEST
                )
            
            try:
                verification = WorkerDocumentVerification.objects.get(worker=worker)
                serializer = WorkerDocumentVerificationSerializer(verification)
                return Response(serializer.data, status=HTTP_200_OK)
            except WorkerDocumentVerification.DoesNotExist:
                return Response(
                    {'message': 'No documents submitted yet'},
                    status=HTTP_200_OK
                )
        
        except Exception as e:
            return Response(
                {'error': f'Error retrieving document: {str(e)}'},
                status=HTTP_400_BAD_REQUEST
            )


class AdminDocumentVerificationView(APIView):
    """
    Admin endpoint to verify worker documents
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request, verification_id):
        """
        Admin verifies or rejects worker document
        Expected fields:
        - action: 'approve' or 'reject'
        - rejection_reason: reason for rejection (if rejecting)
        """
        try:
            user = request.user
            
            # Check if user is admin
            if user.role != 'admin':
                return Response(
                    {'error': 'Only admins can verify documents'},
                    status=HTTP_403_FORBIDDEN
                )
            
            verification = WorkerDocumentVerification.objects.get(id=verification_id)
            action = request.data.get('action')
            
            if action == 'approve':
                verification.status = WorkerDocumentVerification.STATUS_VERIFIED
                verification.verified_by = user
                verification.verified_at = timezone.now()
                verification.rejection_reason = ''
                verification.save()
                
                # Update worker's is_verified status
                verification.worker.is_verified = True
                verification.worker.save()
                
                return Response(
                    {
                        'message': f'Document verified for {verification.worker.user.name}',
                        'data': WorkerDocumentVerificationSerializer(verification).data
                    },
                    status=HTTP_200_OK
                )
            
            elif action == 'reject':
                reason = request.data.get('rejection_reason', 'Document does not meet requirements')
                verification.status = WorkerDocumentVerification.STATUS_REJECTED
                verification.verified_by = user
                verification.verified_at = timezone.now()
                verification.rejection_reason = reason
                verification.save()
                
                return Response(
                    {
                        'message': f'Document rejected for {verification.worker.user.name}',
                        'data': WorkerDocumentVerificationSerializer(verification).data
                    },
                    status=HTTP_200_OK
                )
            
            else:
                return Response(
                    {'error': 'Invalid action. Use "approve" or "reject"'},
                    status=HTTP_400_BAD_REQUEST
                )
        
        except WorkerDocumentVerification.DoesNotExist:
            return Response(
                {'error': 'Verification record not found'},
                status=HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {'error': f'Error verifying document: {str(e)}'},
                status=HTTP_400_BAD_REQUEST
            )
    
    def get(self, request):
        """Get all pending documents for admin review"""
        try:
            user = request.user
            
            if user.role != 'admin':
                return Response(
                    {'error': 'Only admins can view all documents'},
                    status=HTTP_403_FORBIDDEN
                )
            
            # Get filter from query params
            status = request.query_params.get('status', 'pending')  # pending, verified, rejected
            
            verifications = WorkerDocumentVerification.objects.filter(
                status=status
            ).order_by('-created_at')
            
            serializer = WorkerDocumentVerificationSerializer(verifications, many=True)
            return Response(
                {
                    'count': verifications.count(),
                    'status': status,
                    'data': serializer.data
                },
                status=HTTP_200_OK
            )
        
        except Exception as e:
            return Response(
                {'error': f'Error retrieving documents: {str(e)}'},
                status=HTTP_400_BAD_REQUEST
            )
