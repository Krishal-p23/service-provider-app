import requests

headers = {
    'Authorization': 'Bearer 27',
    'Host': 'actually-decrease-preliminary-maintenance.trycloudflare.com',
    'Cf-Visitor': '{"scheme":"https"}',
    'X-Forwarded-Proto': 'https',
}

r = requests.get('http://127.0.0.1:8000/api/workers/auth-debug/', headers=headers, timeout=10)
print('status=', r.status_code)
print('body=', r.text[:220])
