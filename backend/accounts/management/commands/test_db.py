from django.core.management.base import BaseCommand
from django.db import connection
from django.contrib.auth.models import User


class Command(BaseCommand):
    help = 'Test database connection and show database info'

    def handle(self, *args, **options):
        try:
            # Test basic connection
            with connection.cursor() as cursor:
                cursor.execute("SELECT version();")
                db_version = cursor.fetchone()[0]
                
                # Get database name
                cursor.execute("SELECT current_database();")
                db_name = cursor.fetchone()[0]
                
                # Get current user
                cursor.execute("SELECT current_user;")
                db_user = cursor.fetchone()[0]
                
                # Count tables
                cursor.execute("""
                    SELECT COUNT(*) 
                    FROM information_schema.tables 
                    WHERE table_schema = 'public';
                """)
                table_count = cursor.fetchone()[0]
                
            self.stdout.write(self.style.SUCCESS('\n✅ Database Connection Successful!'))
            self.stdout.write(self.style.SUCCESS('=' * 60))
            self.stdout.write(f'📊 Database: {db_name}')
            self.stdout.write(f'👤 User: {db_user}')
            self.stdout.write(f'📦 Tables: {table_count}')
            self.stdout.write(f'🔧 PostgreSQL Version: {db_version[:50]}...')
            self.stdout.write(self.style.SUCCESS('=' * 60))
            
            # Test Django ORM
            user_count = User.objects.count()
            self.stdout.write(f'\n👥 Django Users in database: {user_count}')
            
            self.stdout.write(self.style.SUCCESS('\n✅ All database tests passed!\n'))
            
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'\n❌ Database connection failed: {str(e)}\n'))
