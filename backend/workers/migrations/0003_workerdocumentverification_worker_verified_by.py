# Fix missing worker field in WorkerDocumentVerification model
# This migration adds the worker OneToOne field and verified_by FK that were missing from 0002

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('workers', '0002_workerdocumentverification'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        # Add the worker field if it doesn't exist
        migrations.AddField(
            model_name='workerdocumentverification',
            name='worker',
            field=models.OneToOneField(default=1, on_delete=django.db.models.deletion.CASCADE, related_name='document_verification', to='workers.worker'),
            preserve_default=False,
        ),
        # Add the verified_by field if it doesn't exist
        migrations.AddField(
            model_name='workerdocumentverification',
            name='verified_by',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='verified_workers', to='authentication.appuser'),
        ),
        # Update the document_type choices to include voter_id (was missing in 0002)
        migrations.AlterField(
            model_name='workerdocumentverification',
            name='document_type',
            field=models.CharField(choices=[('aadhar', 'Aadhar Card'), ('pan', 'PAN Card'), ('driving_license', 'Driving License'), ('passport', 'Passport'), ('voter_id', 'Voter ID')], default='aadhar', max_length=50),
        ),
    ]
