from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('authentication', '0001_initial'),
    ]

    operations = [
        migrations.RunSQL(
            sql=(
                "ALTER TABLE users "
                "ADD COLUMN IF NOT EXISTS fcm_token VARCHAR(512)"
            ),
            reverse_sql=(
                "ALTER TABLE users "
                "DROP COLUMN IF EXISTS fcm_token"
            ),
        ),
    ]
