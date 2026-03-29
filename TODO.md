# Backend-Frontend Connection: Customer Flow
Current Working Directory: c:/flutterDevelop/project/service-provider-app

## ✅ Completed/Ready
- [x] Backend auth APIs functional (register/login/me/profile)
- [x] Frontend ApiService matches backend endpoints
- [x] CORS configured for Flutter
- [x] Platform-specific base URLs (emulator/localhost)

## 🔄 In Progress
### Step 1: Test Current Auth Connection
- [ ] Run Django server: `cd backend && python manage.py runserver`
- [ ] Run Flutter: `cd flutter_project && flutter run`
- [ ] Test customer register/login in app

### Step 2: Backend - Enable Customer-Related Apps
- [ ] Uncomment URLs in `backend/backend/urls.py` (workers, services, bookings, payments, reviews)
- [ ] Add stubs for missing customer endpoints:
  | Endpoint | App | Method | Status |
  |----------|-----|--------|--------|
  | `/locations/` | bookings | GET/POST/PUT | Missing |
  | `/reviews/user/<id>/` | reviews | GET | Missing |
  | `/workers/` | workers | GET | Exists |

### Step 3: Frontend - Customer Flow Cleanup
- [ ] Remove mock data from `lib/providers/user_provider.dart`
- [ ] Replace mock workers/jobs in customer screens with API calls
- [ ] Handle missing endpoints gracefully (404 → empty list)

### Step 4: Customer Features to Connect
Priority order:
1. **Auth** ✅
2. **Profile/Location** (updateUserLocation → locations endpoints)
3. **Service Discovery** (workers list → /api/workers/)
4. **Bookings** (create/GET bookings)
5. **Reviews** (fetch/submit reviews)
6. **Wallet/Payments** (if backend ready)

## Next Action Items
```
1. execute_command: cd backend && python manage.py runserver
2. Test auth in Flutter app
3. Update backend/urls.py
4. Clean customer providers
```

**Progress: 20%** (Auth ready, testing pending)

