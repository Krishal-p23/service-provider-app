import os
import django
from django.db import connection
from datetime import datetime, timedelta


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()


def seed_transfer_data():
    now = datetime.now()
    today = datetime(now.year, now.month, now.day, 12, 0, 0)

    inserted = 0

    with connection.cursor() as cursor:
        cursor.execute("SELECT id, user_id FROM workers ORDER BY id ASC")
        workers = cursor.fetchall()

        if not workers:
            print("No workers found. Nothing to seed.")
            return

        cursor.execute("SELECT id FROM services ORDER BY id ASC")
        services = [row[0] for row in cursor.fetchall()]
        if not services:
            print("No services found. Nothing to seed.")
            return

        cursor.execute("SELECT id FROM users WHERE LOWER(role) = 'customer' ORDER BY id ASC")
        customers = [row[0] for row in cursor.fetchall()]
        if not customers:
            print("No customers found. Nothing to seed.")
            return

        for worker_id, worker_user_id in workers:
            # Pick deterministic service and customer.
            service_id = services[worker_id % len(services)]
            customer_id = customers[worker_id % len(customers)]

            # Ensure one completed booking exists in current month for transfer calculations.
            month_start = datetime(now.year, now.month, 1)
            cursor.execute(
                """
                SELECT id FROM bookings
                WHERE worker_id = %s
                  AND LOWER(status) = 'completed'
                  AND scheduled_date >= %s
                LIMIT 1
                """,
                [worker_id, month_start],
            )
            exists = cursor.fetchone()
            if not exists:
                cursor.execute(
                    """
                    INSERT INTO bookings (user_id, worker_id, service_id, scheduled_date, status, total_amount, created_at)
                    VALUES (%s, %s, %s, %s, 'completed', %s, NOW())
                    """,
                    [customer_id, worker_id, service_id, today - timedelta(hours=2), 550],
                )
                inserted += 1

            # Ensure at least one pending booking today for day-list consistency.
            cursor.execute(
                """
                SELECT id FROM bookings
                WHERE worker_id = %s
                  AND LOWER(status) IN ('pending', 'confirmed', 'in_progress')
                  AND DATE(scheduled_date) = DATE(%s)
                LIMIT 1
                """,
                [worker_id, today],
            )
            active_today = cursor.fetchone()
            if not active_today:
                cursor.execute(
                    """
                    INSERT INTO bookings (user_id, worker_id, service_id, scheduled_date, status, total_amount, created_at)
                    VALUES (%s, %s, %s, %s, 'pending', %s, NOW())
                    """,
                    [customer_id, worker_id, service_id, today + timedelta(hours=1), 420],
                )
                inserted += 1

    print(f"Seed complete. Inserted {inserted} bookings across workers.")


if __name__ == '__main__':
    seed_transfer_data()
