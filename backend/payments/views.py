from django.http import JsonResponse
from django.db import connection
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
import json


def _ensure_wallet_table():
	"""Create wallet_transactions table if missing (SQLite/Postgres)."""
	vendor = connection.vendor
	with connection.cursor() as cursor:
		if vendor == 'postgresql':
			cursor.execute(
				"""
				CREATE TABLE IF NOT EXISTS wallet_transactions (
					id SERIAL PRIMARY KEY,
					user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
					amount NUMERIC(12, 2) NOT NULL,
					type VARCHAR(20) NOT NULL,
					description TEXT NOT NULL,
					created_at TIMESTAMP NOT NULL DEFAULT NOW()
				)
				"""
			)
		else:
			cursor.execute(
				"""
				CREATE TABLE IF NOT EXISTS wallet_transactions (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					user_id INTEGER NOT NULL,
					amount REAL NOT NULL,
					type TEXT NOT NULL,
					description TEXT NOT NULL,
					created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
				)
				"""
			)


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
		_ensure_wallet_table()
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
		_ensure_wallet_table()
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
@require_http_methods(["POST"])
def add_money(request):
	try:
		_ensure_wallet_table()
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
		_ensure_wallet_table()
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
		_ensure_wallet_table()
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
