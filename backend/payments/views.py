from django.http import JsonResponse
from django.db import connection
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
import json
import uuid
import requests
from urllib.parse import quote_plus

from .upi_qr import generate_upi_qr


def _create_razorpay_order(amount: float, booking_id: int):
	"""Create Razorpay order when keys are configured. Returns None on graceful fallback."""
	key_id = getattr(settings, "RAZORPAY_KEY_ID", "")
	key_secret = getattr(settings, "RAZORPAY_KEY_SECRET", "")
	if not key_id or not key_secret:
		print(f"[RAZORPAY ORDER SKIPPED] Missing keys for booking_id={booking_id}")
		return None

	paise = int(round(amount * 100))
	payload = {
		"amount": paise,
		"currency": "INR",
		"receipt": f"booking_{booking_id}",
		"notes": {"booking_id": str(booking_id)},
	}

	try:
		response = requests.post(
			"https://api.razorpay.com/v1/orders",
			json=payload,
			auth=(key_id, key_secret),
			timeout=12,
		)
		if response.status_code in {200, 201}:
			data = response.json()
			return {
				"order_id": data.get("id"),
				"amount": data.get("amount"),
				"currency": data.get("currency"),
			}
		print(
			f"[RAZORPAY ORDER FAILED] booking_id={booking_id} status={response.status_code} body={response.text}"
		)
		return None
	except Exception as exc:
		print(f"[RAZORPAY ORDER ERROR] booking_id={booking_id} error={exc}")
		return None


def _get_balance(user_id):
	with connection.cursor() as cursor:
		cursor.execute(
			"""
			SELECT COALESCE(
				SUM(CASE WHEN type IN ('credit', 'refund') THEN amount ELSE 0 END) -
				SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END),
				0
			)
			FROM wallet_transactions
			WHERE user_id = %s
			""",
			[user_id],
		)
		row = cursor.fetchone()
	return float(row[0] or 0)


@csrf_exempt
@require_http_methods(["GET"])
def balance(request, user_id):
	try:
		wallet_balance = _get_balance(user_id)
		return JsonResponse(
			{
				'status': 'success',
				'data': {
					'user_id': int(user_id),
					'balance': wallet_balance,
				},
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				'status': 'error',
				'message': 'Failed to fetch wallet balance',
				'code': 'WALLET_BALANCE_ERROR',
				'details': str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["GET"])
def transactions(request, user_id):
	try:
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT id, user_id, amount, type, description, created_at
				FROM wallet_transactions
				WHERE user_id = %s
				ORDER BY created_at DESC
				""",
				[user_id],
			)
			rows = cursor.fetchall()

		txns = []
		for row in rows:
			created_at = row[5]
			txns.append(
				{
					'id': int(row[0]),
					'user_id': int(row[1]),
					'amount': float(row[2] or 0),
					'type': row[3],
					'description': row[4] or '',
					'created_at': created_at.isoformat() if hasattr(created_at, 'isoformat') else str(created_at),
				}
			)

		return JsonResponse(
			{
				'status': 'success',
				'data': {
					'user_id': int(user_id),
					'transactions': txns,
				},
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				'status': 'error',
				'message': 'Failed to fetch wallet transactions',
				'code': 'WALLET_TRANSACTIONS_ERROR',
				'details': str(e),
			},
			status=500,
		)


def _parse_wallet_payload(request):
	payload = json.loads(request.body or '{}')
	user_id = payload.get('userId')
	amount = payload.get('amount')
	description = str(payload.get('description', '')).strip()

	if user_id is None or amount is None or not description:
		return None, JsonResponse(
			{
				'status': 'error',
				'message': 'userId, amount and description are required',
				'code': 'VALIDATION_ERROR',
			},
			status=400,
		)

	try:
		parsed_user_id = int(user_id)
		parsed_amount = float(amount)
	except (ValueError, TypeError):
		return None, JsonResponse(
			{
				'status': 'error',
				'message': 'userId must be int and amount must be numeric',
				'code': 'VALIDATION_ERROR',
			},
			status=400,
		)

	if parsed_amount <= 0:
		return None, JsonResponse(
			{
				'status': 'error',
				'message': 'amount must be greater than 0',
				'code': 'VALIDATION_ERROR',
			},
			status=400,
		)

	return {
		'user_id': parsed_user_id,
		'amount': parsed_amount,
		'description': description,
	}, None


def _insert_wallet_txn(user_id, amount, txn_type, description):
	with connection.cursor() as cursor:
		cursor.execute(
			"""
			INSERT INTO wallet_transactions (user_id, amount, type, description)
			VALUES (%s, %s, %s, %s)
			""",
			[user_id, amount, txn_type, description],
		)


@csrf_exempt
@require_http_methods(["GET"])
def get_payment_qr(request, booking_id):
	"""GET /api/payments/qr/<booking_id>/ - return UPI deep-link string for QR rendering."""
	try:
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT id, total_amount, status
				FROM bookings
				WHERE id = %s
				""",
				[booking_id],
			)
			row = cursor.fetchone()

		if not row:
			return JsonResponse(
				{
					"status": "error",
					"message": "Booking not found",
					"code": "BOOKING_NOT_FOUND",
				},
				status=404,
			)

		amount = float(row[1] or 0)
		upi_id = settings.BUSINESS_UPI_ID
		business_name = settings.BUSINESS_NAME or "HomeServices"

		if not upi_id:
			return JsonResponse(
				{
					"status": "error",
					"message": "BUSINESS_UPI_ID is not configured",
					"code": "UPI_NOT_CONFIGURED",
				},
				status=500,
			)

		note = f"Booking #{booking_id} payment"
		upi_string = (
			f"upi://pay?pa={quote_plus(upi_id)}"
			f"&pn={quote_plus(business_name)}"
			f"&am={amount:.2f}"
			"&cu=INR"
			f"&tn={quote_plus(note)}"
		)

		return JsonResponse(
			{
				"status": "success",
				"data": {
					"booking_id": int(booking_id),
					"amount": amount,
					"upi_string": upi_string,
					"booking_status": row[2],
				},
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to generate payment QR",
				"code": "PAYMENT_QR_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def generate_payment_qr(request):
	"""POST /api/payments/qr/generate/ - return QR image + UPI link for checkout."""
	try:
		payload = json.loads(request.body or "{}")
	except json.JSONDecodeError:
		return JsonResponse(
			{
				"status": "error",
				"message": "Invalid JSON",
				"code": "INVALID_JSON",
			},
			status=400,
		)

	booking_id = payload.get("booking_id")
	amount_value = payload.get("amount")
	worker_upi = str(payload.get("worker_upi") or "").strip()
	use_admin_upi = bool(payload.get("use_admin_upi", True))

	if booking_id is None or amount_value is None:
		return JsonResponse(
			{
				"status": "error",
				"message": "booking_id and amount are required",
				"code": "MISSING_FIELDS",
			},
			status=400,
		)

	try:
		total_amount = float(amount_value)
	except (TypeError, ValueError):
		return JsonResponse(
			{
				"status": "error",
				"message": "amount must be numeric",
				"code": "VALIDATION_ERROR",
			},
			status=400,
		)

	if total_amount <= 0:
		return JsonResponse(
			{
				"status": "error",
				"message": "amount must be greater than 0",
				"code": "VALIDATION_ERROR",
			},
			status=400,
		)

	commission_percent = float(getattr(settings, "ADMIN_CUT_PERCENT", 2) or 2)
	admin_amount = round(total_amount * (commission_percent / 100.0), 2)
	worker_amount = round(total_amount - admin_amount, 2)

	receiver_upi = settings.BUSINESS_UPI_ID if use_admin_upi else worker_upi
	receiver_name = settings.BUSINESS_NAME or "HomeServices"

	if not receiver_upi:
		return JsonResponse(
			{
				"status": "error",
				"message": "Receiver UPI ID is not configured",
				"code": "UPI_NOT_CONFIGURED",
			},
			status=400,
		)

	ref = str(uuid.uuid4())[:12].upper()
	description = f"Booking-{booking_id}"
	razorpay_enabled = bool(getattr(settings, "WEBLAB_RAZORPAY_ENABLED", False))
	razorpay_order = _create_razorpay_order(total_amount, int(booking_id)) if razorpay_enabled else None

	qr_image, upi_link = generate_upi_qr(
		amount=total_amount,
		payee_upi=receiver_upi,
		payee_name=receiver_name,
		transaction_ref=ref,
		description=description,
	)

	return JsonResponse(
		{
			"status": "success",
			"data": {
				"qr_image": qr_image,
				"upi_link": upi_link,
				"total": total_amount,
				"worker_gets": worker_amount,
				"admin_gets": admin_amount,
				"ref": ref,
				"payment_gateway": "razorpay" if razorpay_enabled else "upi",
				"razorpay_enabled": razorpay_enabled,
				"razorpay": razorpay_order,
				"settlement_mode": "admin_first" if use_admin_upi else "direct_to_worker",
			},
		},
		status=200,
	)


@csrf_exempt
@require_http_methods(["POST"])
def confirm_payment(request):
	"""POST /api/payments/confirm/ - record payment and complete booking."""
	try:
		payload = json.loads(request.body or "{}")
	except json.JSONDecodeError:
		return JsonResponse(
			{
				"status": "error",
				"message": "Invalid JSON",
				"code": "INVALID_JSON",
			},
			status=400,
		)

	booking_id = payload.get("booking_id")
	payment_method = str(payload.get("payment_method") or "").strip().upper()
	transaction_ref = str(payload.get("transaction_ref") or "").strip()
	payment_status = str(payload.get("payment_status") or "").strip().lower()
	use_wallet = bool(payload.get("use_wallet", False))
	user_id = payload.get("user_id")

	if booking_id is None or not payment_method:
		return JsonResponse(
			{
				"status": "error",
				"message": "booking_id and payment_method are required",
				"code": "MISSING_FIELDS",
			},
			status=400,
		)

	if payment_method not in {"UPI", "COD", "WALLET"}:
		return JsonResponse(
			{
				"status": "error",
				"message": "Unsupported payment_method",
				"code": "INVALID_PAYMENT_METHOD",
			},
			status=400,
		)

	resolved_status = "paid"
	if payment_method == "COD" and payment_status == "pending":
		resolved_status = "pending"

	if not transaction_ref:
		transaction_ref = f"{payment_method}-{uuid.uuid4().hex[:12]}"

	try:
		with connection.cursor() as cursor:
			cursor.execute(
				"""
				SELECT id, user_id, total_amount
				FROM bookings
				WHERE id = %s
				""",
				[booking_id],
			)
			booking_row = cursor.fetchone()

			if not booking_row:
				return JsonResponse(
					{
						"status": "error",
						"message": "Booking not found",
						"code": "BOOKING_NOT_FOUND",
					},
					status=404,
				)

			booking_user_id = booking_row[1]
			amount = float(booking_row[2] or 0)

			if use_wallet:
				wallet_user_id = int(user_id) if user_id is not None else int(booking_user_id)
				current_balance = _get_balance(wallet_user_id)
				if current_balance < amount:
					return JsonResponse(
						{
							"status": "error",
							"message": "Insufficient wallet balance",
							"code": "INSUFFICIENT_BALANCE",
							"data": {"balance": current_balance},
						},
						status=400,
					)
				_insert_wallet_txn(
					wallet_user_id,
					amount,
					"debit",
					f"Booking #{booking_id} payment via wallet",
				)

			cursor.execute(
				"""
				INSERT INTO payments (booking_id, payment_method, payment_status, transaction_id, paid_at)
				VALUES (%s, %s, %s, %s, NOW())
				""",
				[booking_id, payment_method, resolved_status, transaction_ref],
			)

			cursor.execute(
				"""
				UPDATE bookings
				SET status = %s
				WHERE id = %s
				""",
				["completed", booking_id],
			)

		return JsonResponse(
			{
				"status": "success",
				"data": {
					"booking_id": int(booking_id),
					"payment_method": payment_method,
					"payment_status": resolved_status,
					"transaction_ref": transaction_ref,
					"booking_status": "completed",
				},
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				"status": "error",
				"message": "Failed to confirm payment",
				"code": "PAYMENT_CONFIRM_ERROR",
				"details": str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def add_money(request):
	try:
		payload, error_response = _parse_wallet_payload(request)
		if error_response is not None:
			return error_response

		_insert_wallet_txn(
			payload['user_id'],
			payload['amount'],
			'credit',
			payload['description'],
		)

		return JsonResponse(
			{
				'status': 'success',
				'data': {
					'user_id': payload['user_id'],
					'balance': _get_balance(payload['user_id']),
				},
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				'status': 'error',
				'message': 'Failed to add wallet money',
				'code': 'WALLET_ADD_ERROR',
				'details': str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def deduct_money(request):
	try:
		payload, error_response = _parse_wallet_payload(request)
		if error_response is not None:
			return error_response

		current_balance = _get_balance(payload['user_id'])
		if current_balance < payload['amount']:
			return JsonResponse(
				{
					'status': 'error',
					'message': 'Insufficient wallet balance',
					'code': 'INSUFFICIENT_BALANCE',
					'data': {
						'balance': current_balance,
					},
				},
				status=400,
			)

		_insert_wallet_txn(
			payload['user_id'],
			payload['amount'],
			'debit',
			payload['description'],
		)

		return JsonResponse(
			{
				'status': 'success',
				'data': {
					'user_id': payload['user_id'],
					'balance': _get_balance(payload['user_id']),
				},
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				'status': 'error',
				'message': 'Failed to deduct wallet money',
				'code': 'WALLET_DEDUCT_ERROR',
				'details': str(e),
			},
			status=500,
		)


@csrf_exempt
@require_http_methods(["POST"])
def process_refund(request):
	try:
		payload, error_response = _parse_wallet_payload(request)
		if error_response is not None:
			return error_response

		_insert_wallet_txn(
			payload['user_id'],
			payload['amount'],
			'refund',
			payload['description'],
		)

		return JsonResponse(
			{
				'status': 'success',
				'data': {
					'user_id': payload['user_id'],
					'balance': _get_balance(payload['user_id']),
				},
			},
			status=200,
		)
	except Exception as e:
		return JsonResponse(
			{
				'status': 'error',
				'message': 'Failed to process wallet refund',
				'code': 'WALLET_REFUND_ERROR',
				'details': str(e),
			},
			status=500,
		)
