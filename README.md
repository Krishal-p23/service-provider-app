## 🛠️ Service Provider App ##

A platform to connect users with local service providers (plumbers, electricians, carpenters, etc.), similar to Uber/Rapido but for home services.

This repository is developed collaboratively with separate responsibilities for frontend, backend, and database, coordinated via API contracts defined in this document.

## 📌 Project Overview ##

# Actors #

- User (Customer) – books services
- Worker (Service Provider) – plumber, electrician, carpenter, etc.

# Tech Stack #

- Frontend: Flutter
- Backend: Django + Django REST Framework
- Database: PostgreSQL
- Authentication: JWT (JSON Web Tokens)

## 🔑 API CONTRACTS (SOURCE OF TRUTH) ##

⚠️ All frontend and database work MUST follow these contracts.
Any change here must be communicated before implementation.

Base URL (development): ```http://<backend-ip>:8000/api```

## 🔐 Authentication APIs ##

- # 1️⃣ Signup (User / Worker) #

    + Endpoint: 
        ```POST /api/accounts/signup/```

    + Request Body:
        ```{"username": "krishal", "password": "password123", "role": "WORKER", "service_type": "plumber"}```

    + Field Rules:
        ```role```must be one of: 
            - ```USER```
            - ```WORKER```

        ```service_type``` is:
            - REQUIRED if role = ```WORKER```
            - IGNORED if role = ```USER```

    + Success Response (201)
        ```{"message": "Signup successful"}```

    + Error Response (400)
        ```{"error": "Username already exists"}```

- # 2️⃣ Login (User & Worker) #

    + Endpoint: 
        ```POST /api/accounts/login/```

    + Request Body:
        ```{"username": "krishal", "password": "password123"}```

    + Success Response (200)
        ```{"access": "jwt_access_token", "refresh": "jwt_refresh_token", "role": "WORKER"}```

    + Error Response (401)
        ```{"error": "Invalid credentials"}```

- # 3️⃣ Get Logged-in User Profile #

    + Endpoint: 
        ```POST /api/accounts/me```

    + Headers:
        ```Authorization: Bearer <access_token>```

    + Success Response (200)
        ```{"username": "krishal", "role": "WORKER", "service_type": "plumber"}```

    + Error Response (401)
        ```{"error": "Authentication credentials were not provided"}```

## 🧠 Backend Notes (Django) ##
- Uses custom User model
- Single user table with role-based logic
- Auth handled using JWT
- PostgreSQL accessed via Django ORM
- DB credentials are loaded via environment variables

## 🎨 Frontend Notes (Flutter)##
- Frontend must not access DB directly
- All communication via REST APIs
- API base URL must be configurable
- JWT token should be stored securely (SharedPreferences)
- Navigation depends on role:
    + ```USER``` → User Home
    + ```WORKER``` → Worker Dashboard

## 🗄️ Database Notes (PostgreSQL) ##
- Database schema must support:
    + username
    + password (hashed)
    + role
    + service_type

- Schema changes must be shared via Django migrations
- No manual table edits in production DB

## 🔄 Git Workflow (Mandatory) ##
Sync with main:
```git checkout main```
```git pull origin main```
```git checkout <your-branch>```
```git merge main```

Merge to main(after testing):
```git checkout main```
```git merge <your-branch>```
```git push origin main```

## 📣 Communication Rules ##

- API changes → update README first
- Schema changes → share migrations
- UI changes → no backend dependency assumptions
- No silent breaking changes

## 🤝 Contributors ##

+ Krishal – Backend & system design
+ Kajal – Frontend (Flutter)
+ Jagriti – Frontend (Flutter)
+ Khushi – Database & schema design