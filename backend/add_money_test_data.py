"""
Script to add test payment/earnings data for the money page
"""
import os
import django
from datetime import datetime, timedelta
from decimal import Decimal

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from workers.models import Worker
from authentication.models import AppUser
from services.models import Service
from bookings.models import Booking
from payments.models import Payment

def add_test_data():
    # Get the first worker
    worker = Worker.objects.first()
    if not worker:
        print("ERROR: No workers found. Please create a worker first.")
        return
    
    print(f"Worker: {worker.user.name if worker.user else 'Unknown'} (ID: {worker.id})")
    
    # Get first user (customer)
    user = AppUser.objects.filter(role='customer').first()
    if not user:
        print("ERROR: No customers found. Please create a customer first.")
        return
    
    print(f"Customer: {user.name} (ID: {user.id})")
    
    # Get first service
    service = Service.objects.first()
    if not service:
        print("ERROR: No services found. Please create a service first.")
        return
    
    print(f"Service: {service.service_name} (ID: {service.id})")
    
    # Clear existing bookings and payments for this worker (optional)
    existing_bookings = Booking.objects.filter(worker=worker).count()
    print(f"Existing bookings for worker: {existing_bookings}")
    
    # Add test bookings with payments from the past 6 months
    months_data = [
        {'month': 'September', 'days_ago': 180, 'amount': 3200, 'count': 4},
        {'month': 'October', 'days_ago': 150, 'amount': 5400, 'count': 6},
        {'month': 'November', 'days_ago': 120, 'amount': 1800, 'count': 2},
        {'month': 'December', 'days_ago': 90, 'amount': 6100, 'count': 7},
        {'month': 'January', 'days_ago': 60, 'amount': 4300, 'count': 5},
        {'month': 'February', 'days_ago': 30, 'amount': 2750, 'count': 3},
    ]
    
    bookings_created = 0
    payments_created = 0
    
    for month_info in months_data:
        month = month_info['month']
        days_ago = month_info['days_ago']
        total_amount = month_info['amount']
        count = month_info['count']
        
        # Distribute amount across bookings
        amount_per_booking = Decimal(total_amount / count)
        
        for i in range(count):
            # Create varied booking dates within the month
            scheduled_date = datetime.now() - timedelta(days=days_ago - (i * 2))
            
            booking = Booking.objects.create(
                user=user,
                worker=worker,
                service=service,
                scheduled_date=scheduled_date,
                status=Booking.STATUS_COMPLETED,
                total_amount=amount_per_booking,
            )
            bookings_created += 1
            
            # Create corresponding payment
            payment = Payment.objects.create(
                booking=booking,
                payment_method='credit_card',
                payment_status=Payment.STATUS_PAID,
                transaction_id=f'TXN_{booking.id}_{int(datetime.now().timestamp())}',
                paid_at=scheduled_date + timedelta(hours=1),
            )
            payments_created += 1
            
            print(f"  {month}: Booking #{booking.id} - Rs{amount_per_booking} - Payment #{payment.id}")
    
    # Add some pending data for upcoming transfer
    upcoming_date = datetime.now() + timedelta(days=7)
    pending_booking = Booking.objects.create(
        user=user,
        worker=worker,
        service=service,
        scheduled_date=upcoming_date,
        status=Booking.STATUS_COMPLETED,
        total_amount=Decimal('2750'),
    )
    bookings_created += 1
    
    pending_payment = Payment.objects.create(
        booking=pending_booking,
        payment_method='credit_card',
        payment_status=Payment.STATUS_PENDING,
        transaction_id=f'TXN_{pending_booking.id}_{int(datetime.now().timestamp())}',
        paid_at=None,
    )
    payments_created += 1
    
    print(f"\n[SUCCESS] Data added successfully!")
    print(f"   Bookings created: {bookings_created}")
    print(f"   Payments created: {payments_created}")
    print(f"\nYour money page should now display:")
    print(f"   - Monthly earnings chart with 6 months of data")
    print(f"   - Upcoming transfer: Rs2750")
    print(f"   - Historical bank transfers")

if __name__ == '__main__':
    add_test_data()
