"""
Custom authentication backends for REST Framework
"""
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from authentication.models import AppUser


class BearerTokenAuthentication(BaseAuthentication):
    """
    Custom authentication that uses Bearer <user_id> format.
    Extracted from existing authentication views for consistency.
    """
    
    def authenticate(self, request):
        """
        Authenticate using Authorization: Bearer <user_id>
        """
        auth_header = request.META.get("HTTP_AUTHORIZATION", "")
        if not auth_header.startswith("Bearer "):
            return None
        
        try:
            token = auth_header.split(" ", 1)[1].strip()
            user_id = int(token)
            
            if user_id <= 0:
                raise AuthenticationFailed("Invalid user ID in token")
            
            # Fetch the user
            user = AppUser.objects.get(id=user_id)
            
            # Return (user, auth) tuple
            return (user, None)
            
        except (ValueError, TypeError):
            raise AuthenticationFailed("Invalid token format. Use: Bearer <user_id>")
        except AppUser.DoesNotExist:
            raise AuthenticationFailed(f"User {user_id} not found")
        except Exception as e:
            raise AuthenticationFailed(f"Authentication failed: {str(e)}")
