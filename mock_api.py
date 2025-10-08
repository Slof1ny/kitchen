#!/usr/bin/env python3
"""
Simple mock API for local testing of the Kitchen app.

Endpoints:
- POST /api/v1/auth/kitchen/login
- GET  /api/v1/kitchen/profile

This accepts the test credentials:
  phone: +8801122334455
  password: 12345678

Run: python3 mock_api.py
"""
from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import sys
import json
from datetime import datetime

app = Flask(__name__)
CORS(app)


def _trim_headers(hdrs):
    # convert headers EnvironHeaders to a plain dict and keep a small subset
    try:
        d = dict(hdrs)
    except Exception:
        d = {k: v for k, v in hdrs.items()}
    keep = ['Host', 'User-Agent', 'Accept', 'Content-Type', 'Origin', 'Authorization']
    return {k: d.get(k) for k in keep if k in d}


@app.before_request
def log_request_info():
    try:
        # Read raw body but cache it so later handlers can still access it
        raw = request.get_data(cache=True, as_text=True)
        body = None
        if raw:
            # try to decode JSON for nicer logs
            try:
                body = json.loads(raw)
            except Exception:
                body = raw
    except Exception:
        body = '<unreadable>'
    entry = {
        'ts': datetime.utcnow().isoformat() + 'Z',
        'method': request.method,
        'path': request.path,
        'headers': _trim_headers(request.headers),
        'body': body
    }
    print('<< REQUEST:', json.dumps(entry, ensure_ascii=False), file=sys.stderr)
    sys.stderr.flush()


@app.after_request
def log_response_info(response):
    try:
        resp_body = response.get_data(as_text=True)
    except Exception:
        resp_body = '<unreadable>'
    entry = {
        'ts': datetime.utcnow().isoformat() + 'Z',
        'status': response.status,
        'path': request.path,
        'response_body_snippet': resp_body[:1000]
    }
    print('>> RESPONSE:', json.dumps(entry, ensure_ascii=False), file=sys.stderr)
    sys.stderr.flush()
    return response

TEST_PHONE = "+8801122334455"
TEST_PASSWORD = "12345678"

@app.route('/api/v1/auth/kitchen/login', methods=['POST'])
def login():
    # Accept JSON, form-encoded, or raw body for flexibility
    data = {}
    try:
        if request.is_json:
            data = request.get_json(silent=True) or {}
        else:
            # Try form values
            if request.form:
                data = request.form.to_dict()
            else:
                raw = request.get_data(as_text=True) or ''
                # try to parse raw as JSON
                try:
                    data = json.loads(raw)
                except Exception:
                    # parse simple key=value& pairs
                    pairs = [p for p in raw.split('&') if '=' in p]
                    for p in pairs:
                        k, v = p.split('=', 1)
                        data[k] = v
    except Exception:
        data = {}

    phone = data.get('email_or_phone') or data.get('phone') or data.get('email')
    password = data.get('password') or data.get('pass')

    # Fallback: if parsing failed, try to find credentials in the raw request body
    try:
        if (not phone or not password):
            raw = request.get_data(cache=True, as_text=True) or ''
            if TEST_PHONE in raw and TEST_PASSWORD in raw:
                phone = TEST_PHONE
                password = TEST_PASSWORD
    except Exception:
        pass

    if phone == TEST_PHONE and password == TEST_PASSWORD:
        return jsonify({
            "token": "TEST_TOKEN_abc123",
            "message": "Logged in"
        }), 200
    else:
        return jsonify({
            "errors": [{"message": "Invalid credentials", "code": 401}]
        }), 401


@app.route('/api/v1/ping', methods=['GET'])
def ping():
    return jsonify({"status": "ok", "time": datetime.utcnow().isoformat() + 'Z'}), 200


@app.route('/api/v1/kitchen/profile', methods=['GET'])
def profile():
    auth = request.headers.get('Authorization', '')
    if auth == 'Bearer TEST_TOKEN_abc123':
        return jsonify({
            "profile": {"branchId": 1},
            "branch": {"id": 1}
        }), 200
    return jsonify({"message": "Unauthorized"}), 401


@app.route('/api/v1/config', methods=['GET'])
def config():
    # minimal config expected by the app (country etc.)
    return jsonify({
        "country": "BD",
        "currency": "BDT",
        "app_name": "Kitchen App Mock"
    }), 200


@app.route('/api/v1/kitchen/order/list', methods=['GET', 'POST'])
def order_list():
    # Return a small list of mock orders
    orders = [
        {"id": 1001, "order_id": "1001", "status": "confirmed", "amount": 250.0},
        {"id": 1002, "order_id": "1002", "status": "cooking", "amount": 150.5},
        {"id": 1003, "order_id": "1003", "status": "done", "amount": 99.99}
    ]
    return jsonify({"data": orders, "total": len(orders)}), 200


@app.route('/api/v1/kitchen/order/details', methods=['POST'])
def order_details():
    try:
        data = request.get_json(force=True)
    except Exception:
        data = {}
    order_id = data.get('order_id') or data.get('id') or 1001
    details = {
        "id": order_id,
        "order_id": str(order_id),
        "status": "confirmed",
        "items": [
            {"name": "Burger", "qty": 2, "price": 120.0},
            {"name": "Fries", "qty": 1, "price": 30.0}
        ],
        "amount": 270.0
    }
    return jsonify(details), 200


@app.route('/api/v1/kitchen/update-fcm-token', methods=['POST'])
def update_fcm():
    # accept token update
    return jsonify({"message": "fcm updated"}), 200


if __name__ == '__main__':
    # Allow selecting a port via the PORT environment variable (fallback to 5000)
    port = int(os.environ.get('PORT', '5000'))
    print(f"Mock API running on http://0.0.0.0:{port} (listening on all interfaces)")
    app.run(host='0.0.0.0', port=port)
