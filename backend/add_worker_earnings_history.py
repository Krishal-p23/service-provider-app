#!/usr/bin/env python
"""
Seed historical completed bookings for a worker so earnings charts show real month-wise data.
Usage:
  python add_worker_earnings_history.py
"""

import os
import django
from datetime import datetime, timedelta

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection


def month_start(dt: datetime) -> datetime:
    return datetime(dt.year, dt.month, 1, 10, 0, 0)


def previous_month(dt: datetime) -> datetime:
    first = datetime(dt.year, dt.month, 1)
    prev_last = first - timedelta(days=1)
    return datetime(prev_last.year, prev_last.month, 1)


def ensure_user(cursor, user_id: int, name: str, email: str, phone: str, role: str):
    cursor.execute("SELECT id FROM users WHERE id = %s", [user_id])
    if cursor.fetchone():
        return
    cursor.execute(
        """
        INSERT INTO users (id, name, email, phone, password_hash, role, created_at)
        VALUES (%s, %s, %s, %s, %s, %s, NOW())
        """,
        [user_id, name, email, phone, 'placeholder_hash', role],
    )


def ensure_worker(cursor, worker_id: int, user_id: int):
    cursor.execute("SELECT id FROM workers WHERE id = %s", [worker_id])
    if cursor.fetchone():
        return
    cursor.execute(
        """
        INSERT INTO workers (id, user_id, is_verified, is_available, experience_years, bio, created_at)
        VALUES (%s, %s, TRUE, TRUE, 3, %s, NOW())
        """,
        [worker_id, user_id, 'Auto-created worker for earnings seed'],
    )


def ensure_service(cursor) -> int:
    cursor.execute("SELECT id FROM service_categories ORDER BY id ASC LIMIT 1")
    row = cursor.fetchone()
    if row:
        category_id = row[0]
    else:
        cursor.execute(
            "INSERT INTO service_categories (category_name) VALUES (%s) RETURNING id",
            ['General Services'],
        )
        category_id = cursor.fetchone()[0]

    cursor.execute(
        "SELECT id FROM services WHERE LOWER(service_name) = LOWER(%s) LIMIT 1",
        ['General Service'],
    )
    row = cursor.fetchone()
    if row:
        return row[0]

    cursor.execute(
        """
        INSERT INTO services (category_id, service_name, base_price)
        VALUES (%s, %s, %s)
        RETURNING id
        """,
        [category_id, 'General Service', 1000],
    )
    return cursor.fetchone()[0]


def main():
    worker_user_id = 1
    worker_id = 1
    customer_base_id = 100

    base_amounts = [2200, 3400, 1850, 4100, 2950, 3600]

    with connection.cursor() as cursor:
        ensure_user(
            cursor,
            worker_user_id,
            'Worker One',
            'worker1@example.com',
            '9000000001',
            'worker',
        )
        ensure_worker(cursor, worker_id, worker_user_id)
        service_id = ensure_service(cursor)

        now = datetime.now()
        start = month_start(now)

        inserted = 0
        for i, amount in enumerate(reversed(base_amounts)):
            target_month = start
            for _ in range(i):
                target_month = previous_month(target_month)

            # Create one customer and one completed booking per month.
            customer_id = customer_base_id + i
            ensure_user(
                cursor,
                customer_id,
                f'Customer {customer_id}',
                f'customer{customer_id}@example.com',
                f'9100000{customer_id:03d}'[-10:],
                'customer',
            )

            scheduled_date = target_month + timedelta(days=8)

            cursor.execute(
                """
                SELECT id FROM bookings
                WHERE worker_id = %s
                  AND user_id = %s
                  AND service_id = %s
                  AND DATE_TRUNC('month', scheduled_date) = DATE_TRUNC('month', %s::timestamp)
                  AND LOWER(status) = 'completed'
                LIMIT 1
                """,
                [worker_id, customer_id, service_id, scheduled_date],
            )
            if cursor.fetchone():
                continue

            cursor.execute(
                """
                INSERT INTO bookings (user_id, worker_id, service_id, scheduled_date, status, total_amount, created_at)
                VALUES (%s, %s, %s, %s, %s, %s, NOW())
                """,
                [customer_id, worker_id, service_id, scheduled_date, 'completed', amount],
            )
            inserted += 1

    print(f'Seed complete. Inserted {inserted} completed bookings for worker {worker_id}.')


if __name__ == '__main__':
    main()
