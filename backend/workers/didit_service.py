"""
Didit API Service for Aadhar eKYC Verification
Handles automatic verification of Aadhar documents through Didit's API
"""

import requests
import logging
from django.conf import settings
from typing import Dict, Any

logger = logging.getLogger(__name__)


class DiditVerificationService:
    """
    Service for verifying Aadhar documents via Didit eKYC API
    """

    @staticmethod
    def is_enabled() -> bool:
        """Check if Didit verification is enabled"""
        return settings.DIDIT_ENABLED and settings.DIDIT_API_KEY

    @staticmethod
    def verify_aadhar(aadhar_number: str, image_path: str) -> Dict[str, Any]:
        """
        Verify Aadhar document against Didit eKYC API
        
        Args:
            aadhar_number: 12-digit Aadhar number
            image_path: Path to Aadhar document image
            
        Returns:
            {
                'verified': bool,
                'status': 'verified'/'rejected'/'error'/'disabled',
                'message': 'Description',
                'error_message': 'If error occurred'
            }
        """
        if not DiditVerificationService.is_enabled():
            logger.info('[Didit] Verification disabled - skipping')
            return {
                'verified': False,
                'status': 'disabled',
                'message': 'Didit verification is disabled'
            }

        try:
            logger.info(f'[Didit] Starting Aadhar verification for: {aadhar_number}')

            # Validate image file exists
            import os
            if not os.path.exists(image_path):
                logger.error(f'[Didit] Image file not found: {image_path}')
                return {
                    'verified': False,
                    'status': 'error',
                    'message': 'Image file not found',
                    'error_message': f'File not found: {image_path}'
                }

            # Prepare request
            with open(image_path, 'rb') as image_file:
                files = {
                    'document_image': (
                        os.path.basename(image_path),
                        image_file,
                        'image/jpeg'
                    )
                }
                
                data = {
                    'aadhar_number': aadhar_number,
                    'consent': 'true'
                }

                headers = {
                    'Authorization': f'Bearer {settings.DIDIT_API_KEY}'
                }

                # Make request to Didit API
                logger.info(f'[Didit] Calling API: {settings.DIDIT_API_BASE_URL}/verify-aadhar')
                
                response = requests.post(
                    f'{settings.DIDIT_API_BASE_URL}/verify-aadhar',
                    files=files,
                    data=data,
                    headers=headers,
                    timeout=30
                )

                logger.info(f'[Didit] API Response Status: {response.status_code}')

                # Handle response
                if response.status_code == 200:
                    response_data = response.json()
                    logger.info(f'[Didit] Verification result: {response_data}')

                    # Check if verification was successful
                    if response_data.get('verified') or response_data.get('status') == 'verified':
                        return {
                            'verified': True,
                            'status': 'verified',
                            'message': 'Aadhar verified successfully',
                            'extracted_data': response_data.get('data', {})
                        }
                    elif response_data.get('status') == 'rejected':
                        return {
                            'verified': False,
                            'status': 'rejected',
                            'message': 'Aadhar verification failed',
                            'error_message': response_data.get('error', 'Verification rejected')
                        }
                    else:
                        return {
                            'verified': False,
                            'status': 'pending',
                            'message': 'Manual review required',
                            'error_message': response_data.get('message', 'Needs manual verification')
                        }

                elif response.status_code == 400:
                    logger.error(f'[Didit] Bad request: {response.text}')
                    return {
                        'verified': False,
                        'status': 'error',
                        'message': 'Invalid document image or Aadhar number',
                        'error_message': response.json().get('error', 'Bad request')
                    }

                elif response.status_code == 401:
                    logger.error('[Didit] Authentication failed - invalid API key')
                    return {
                        'verified': False,
                        'status': 'error',
                        'message': 'API authentication failed',
                        'error_message': 'Invalid API credentials'
                    }

                elif response.status_code == 429:
                    logger.error('[Didit] Rate limit exceeded')
                    return {
                        'verified': False,
                        'status': 'error',
                        'message': 'Too many verification requests. Please try later.',
                        'error_message': 'Rate limit exceeded'
                    }

                else:
                    logger.error(f'[Didit] API error: {response.status_code} - {response.text}')
                    return {
                        'verified': False,
                        'status': 'error',
                        'message': f'Didit API error: {response.status_code}',
                        'error_message': response.text
                    }

        except requests.exceptions.Timeout:
            logger.error('[Didit] Request timeout - API took too long to respond')
            return {
                'verified': False,
                'status': 'error',
                'message': 'Verification timeout - please try again',
                'error_message': 'Request timeout'
            }

        except requests.exceptions.ConnectionError as e:
            logger.error(f'[Didit] Connection error: {str(e)}')
            return {
                'verified': False,
                'status': 'error',
                'message': 'Network error - unable to reach verification service',
                'error_message': str(e)
            }

        except Exception as e:
            logger.error(f'[Didit] Unexpected error: {str(e)}')
            return {
                'verified': False,
                'status': 'error',
                'message': 'Unexpected error during verification',
                'error_message': str(e)
            }

    @staticmethod
    def verify_pan(pan_number: str, image_path: str) -> Dict[str, Any]:
        """
        Verify PAN document (Future enhancement)
        Currently not implemented - returns error
        """
        logger.info('[Didit] PAN verification not yet implemented')
        return {
            'verified': False,
            'status': 'error',
            'message': 'PAN verification coming soon',
            'error_message': 'Not implemented'
        }

    @staticmethod
    def verify_driving_license(dl_number: str, image_path: str) -> Dict[str, Any]:
        """
        Verify Driving License (Future enhancement)
        Currently not implemented - returns error
        """
        logger.info('[Didit] Driving License verification not yet implemented')
        return {
            'verified': False,
            'status': 'error',
            'message': 'Driving License verification coming soon',
            'error_message': 'Not implemented'
        }
