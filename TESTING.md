Local testing instructions
==========================

1) Start the mock API server (this accepts the test credentials +8801122334455 / 12345678)

```bash
# from project root
python3 mock_api.py
```

2) Confirm the login endpoint works with curl

```bash
curl -s -X POST http://127.0.0.1:5000/api/v1/auth/kitchen/login \
  -H 'Content-Type: application/json' \
  -d '{"email_or_phone":"+8801122334455","password":"12345678"}' | jq
```

Expected: JSON with a token and status 200.

3) Run the built web locally and test login in browser

```bash
# Build web (if you changed AppConstants.baseUrl as above)
flutter pub get
flutter build web --release

# Serve locally
cd build/web
python3 -m http.server 8000

# Open http://localhost:8000 and login with:
# Phone: +8801122334455
# Password: 12345678
```

Notes:
- The app uses `AppConstants.baseUrl` to send API requests. For local testing we set it to `http://127.0.0.1:5000` in `lib/util/app_constants.dart`.
- This mock server is for testing and demonstration only. Revert `AppConstants.baseUrl` to your real backend URL before production deployment.
