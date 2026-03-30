#!/usr/bin/env python
"""
Seed workers, services, and worker-service mappings so every category has workers.

Login format created by this script:
- email: {worker}@gmail.com
- password: {worker}

Passwords are always stored as password_hash using Django's hash_password helper.
"""

import os
import re
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.db import connection
from authentication.auth_utils import hash_password

TARGET_WORKERS_PER_CATEGORY = 3


def slugify(value: str) -> str:
    text = re.sub(r'[^a-zA-Z0-9]+', '', (value or '').strip().lower())
    return text or 'worker'


def next_unique_phone(cursor) -> str:
    """Generate a unique 10-digit phone number."""
    cursor.execute("SELECT COALESCE(MAX(CAST(phone AS BIGINT)), 7000000000) FROM users WHERE phone ~ '^[0-9]{10}$'")
    max_phone = int(cursor.fetchone()[0] or 7000000000)

    candidate = max(max_phone + 1, 7000000001)
    while True:
        phone = str(candidate)
        cursor.execute("SELECT 1 FROM users WHERE phone = %s", [phone])
        if not cursor.fetchone():
            return phone
        candidate += 1


def ensure_worker_profile(cursor, user_id: int, worker_name: str) -> int:
    cursor.execute("SELECT id FROM workers WHERE user_id = %s", [user_id])
    row = cursor.fetchone()
    if row:
        worker_id = int(row[0])
        cursor.execute(
            """
            UPDATE workers
            SET is_available = TRUE,
                bio = COALESCE(NULLIF(bio, ''), %s)
            WHERE id = %s
            """,
            [f'{worker_name} service professional', worker_id],
        )
        return worker_id

    cursor.execute(
        """
        INSERT INTO workers (user_id, is_verified, is_available, experience_years, bio, profile_photo)
        VALUES (%s, FALSE, TRUE, 2, %s, '')
        RETURNING id
        """,
        [user_id, f'{worker_name} service professional'],
    )
    return int(cursor.fetchone()[0])


def ensure_service_for_category(cursor, category_id: int, category_name: str) -> list[int]:
    cursor.execute(
        "SELECT id FROM services WHERE category_id = %s ORDER BY id",
        [category_id],
    )
    service_ids = [int(row[0]) for row in cursor.fetchall()]

    if service_ids:
        return service_ids

    service_name = f'Basic {category_name.strip() or "Service"}'
    cursor.execute(
        """
        INSERT INTO services (category_id, service_name, base_price)
        VALUES (%s, %s, %s)
        RETURNING id
        """,
        [category_id, service_name, 499],
    )
    return [int(cursor.fetchone()[0])]


def ensure_worker_for_alias(cursor, alias: str, display_name: str) -> tuple[int, bool]:
    email = f'{alias}@gmail.com'
    password_hash = hash_password(alias)

    cursor.execute("SELECT id FROM users WHERE email = %s", [email])
    row = cursor.fetchone()
    created = False

    if row:
        user_id = int(row[0])
        cursor.execute(
            """
            UPDATE users
            SET role = 'worker', password_hash = %s, name = %s
            WHERE id = %s
            """,
            [password_hash, display_name, user_id],
        )
    else:
        phone = next_unique_phone(cursor)
        cursor.execute(
            """
            INSERT INTO users (name, email, phone, password_hash, role, created_at)
            VALUES (%s, %s, %s, %s, 'worker', NOW())
            RETURNING id
            """,
            [display_name, email, phone, password_hash],
        )
        user_id = int(cursor.fetchone()[0])
        created = True

    worker_id = ensure_worker_profile(cursor, user_id, display_name)
    return worker_id, created


def map_worker_to_services(cursor, worker_id: int, service_ids: list[int]) -> None:
    for service_id in service_ids:
        cursor.execute(
            "SELECT 1 FROM worker_services WHERE worker_id = %s AND service_id = %s",
            [worker_id, service_id],
        )
        if cursor.fetchone():
            continue

        cursor.execute(
            "INSERT INTO worker_services (worker_id, service_id, price_override) VALUES (%s, %s, NULL)",
            [worker_id, service_id],
        )


def main():
    created_aliases = []

    with connection.cursor() as cursor:
        # Backfill worker table rows for any existing users with role=worker.
        cursor.execute(
            """
            SELECT u.id, u.name
            FROM users u
            LEFT JOIN workers w ON w.user_id = u.id
            WHERE u.role = 'worker' AND w.id IS NULL
            ORDER BY u.id
            """
        )
        for user_id, name in cursor.fetchall():
            ensure_worker_profile(cursor, int(user_id), str(name or 'Worker'))

        cursor.execute("SELECT id, category_name FROM service_categories ORDER BY id")
        categories = [(int(row[0]), str(row[1] or 'service')) for row in cursor.fetchall()]

        if not categories:
            print('No categories found. Please create categories first.')
            return

        for category_id, category_name in categories:
            service_ids = ensure_service_for_category(cursor, category_id, category_name)

            cursor.execute(
                """
                SELECT COUNT(DISTINCT ws.worker_id)
                FROM worker_services ws
                JOIN services s ON s.id = ws.service_id
                JOIN workers w ON w.id = ws.worker_id
                WHERE s.category_id = %s AND w.is_available = TRUE
                """,
                [category_id],
            )
            worker_count = int(cursor.fetchone()[0] or 0)

            to_add = max(0, TARGET_WORKERS_PER_CATEGORY - worker_count)
            base = slugify(category_name)

            for i in range(1, to_add + 1):
                alias = f'{base}{i}'
                display_name = f'{category_name.title()} Worker {i}'
                worker_id, created = ensure_worker_for_alias(cursor, alias, display_name)
                map_worker_to_services(cursor, worker_id, service_ids)
                if created:
                    created_aliases.append(alias)

            # Ensure existing category workers are linked to all services in category.
            cursor.execute(
                """
                SELECT DISTINCT ws.worker_id
                FROM worker_services ws
                JOIN services s ON s.id = ws.service_id
                WHERE s.category_id = %s
                """,
                [category_id],
            )
            category_worker_ids = [int(row[0]) for row in cursor.fetchall()]
            for worker_id in category_worker_ids:
                map_worker_to_services(cursor, worker_id, service_ids)

    print('Seeding complete.')
    print('Created login aliases (email/password):')
    for alias in created_aliases:
        print(f'  {alias}@gmail.com / {alias}')


if __name__ == '__main__':
    main()
