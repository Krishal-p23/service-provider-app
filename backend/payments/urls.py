from django.urls import path
from .views import (
	balance,
	transactions,
	add_money,
	deduct_money,
	process_refund,
	get_payment_qr,
	generate_payment_qr,
	confirm_payment,
)

app_name = 'payments'

urlpatterns = [
	path('balance/<int:user_id>/', balance, name='wallet_balance'),
	path('transactions/<int:user_id>/', transactions, name='wallet_transactions'),
	path('add/', add_money, name='wallet_add'),
	path('deduct/', deduct_money, name='wallet_deduct'),
	path('refund/', process_refund, name='wallet_refund'),
	path('qr/<int:booking_id>/', get_payment_qr, name='payment_qr'),
	path('qr/generate/', generate_payment_qr, name='generate_payment_qr'),
	path('confirm/', confirm_payment, name='confirm_payment'),
]
