from django.contrib.auth.base_user import BaseUserManager

class UserManager(BaseUserManager):
    def create_user(self, password=None, **extra_fields):
        if not extra_fields.get('phone') and not extra_fields.get('email'):
            raise ValueError('Phone or Email is required')
        
        user = self.model(**extra_fields)
        user.set_password(password)
        user.save()
        return user
    
    def create_superuser(self, username, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', 'CUSTOMER')
        
        if not extra_fields.get('email'):
            raise ValueError('Superuser must have an email address')

        return self.create_user(username=username, password=password, **extra_fields)