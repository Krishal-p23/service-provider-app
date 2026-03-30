# Add verification_status field to Worker model
# Tracks KYC verification state: not_started, pending, approved, rejected

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('workers', '0003_workerdocumentverification_worker_verified_by'),
    ]

    operations = [
        migrations.AddField(
            model_name='worker',
            name='verification_status',
            field=models.CharField(
                max_length=50,
                default='not_started',
                choices=[
                    ('not_started', 'Not Started'),
                    ('pending', 'Pending'),
                    ('approved', 'Approved'),
                    ('rejected', 'Rejected'),
                ],
                help_text='KYC verification status: not_started, pending, approved, rejected'
            ),
        ),
        # Note: Since managed = False, you may need to manually run:
        # ALTER TABLE workers ADD COLUMN verification_status VARCHAR(50) DEFAULT 'not_started';
    ]
