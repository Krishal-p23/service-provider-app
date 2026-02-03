# 🏠 Home Services App

A complete marketplace-style mobile application for local home services, built with Flutter. The app follows content-rich layouts and comprehensive navigation.

---

## 📑 Table of Contents

- [Overview](#-overview)  
- [Features](#-features)  
- [Screens & UX Flow](#-screens--ux-flow)  
- [Project Structure](#-project-structure)  
- [State Management & Key Components](#-state-management--key-components)  
- [Theme System](#-theme-system)  
- [Installation & Run](#-installation--run)  
- [Platform-specific Setup (Image Picker)](#-platform-specific-setup-image-picker)  
- [Application Functionality Overview](#-application-functionality-overview)  
- [Routes](#-routes)  
- [Testing Checklist](#-testing-checklist)  
- [Future Improvements](#-future-improvements)  
- [Security Notes](#-security-notes)  
- [Support & References](#-support--references)

---

## 🧩 Overview

Home Services App is a modular, provider-driven Flutter application for booking local household services such as AC repair, plumbing, electrical work, cleaning, appliance repair, and more.

The app emphasizes trust, usability, and scalability — offering a guest-friendly experience, persistent theme controls, split login/register flows, profile management with photo support, real-time search, and a filterable booking history system. The architecture is backend-ready while currently operating with in-memory mock data for rapid development and testing.

---

## ✨ Features

- Fixed 5-tab bottom navigation (Home • You • History • Wallet • Menu)  
- Separate Login and Registration screens  
- Guest-accessible Account page  
- Profile management with edit functionality  
- Optional profile photo upload (camera / gallery)  
- Booking history with search, filters, ratings, and sorting  
- Theme customization: Light / Dark / System  
- Address management with manual entry and location support  
- Service catalog with category browsing and “See All”  
- Real-time search on the Home screen (16 services)  
- Reviews screen showing user feedback  
- In-memory mock data for users, bookings, and reviews

---

## 🧭 Screens & UX Flow

App Launch  
↓  
Main Screen (Home Tab Active)  
↓  

┌─────────────────────────────────────┐  
│  Fixed Bottom Navigation (Always)   │  
│  Home | You | History | Wallet | Menu│  
└─────────────────────────────────────┘

Navigation possibilities:
- Login (from address bar or Account)  
- Register (from Login)  
- Edit Profile (from Account)  
- Reviews (from Account → Activity)  
- All Services (from category grid)  
- Individual service pages (UI-only)

Screen list:
- Home — lib/screens/home_screen.dart (sticky search, address selector, quick actions, promos, trust strip, categories)  
- Account / You — lib/screens/account_screen.dart (guest & logged-in modes, appearance settings, manage account)  
- History — lib/screens/history_screen.dart (searchable/filterable bookings)  
- Wallet — lib/screens/wallet_screen.dart (placeholder)  
- Menu — lib/screens/menu_screen.dart (help, settings, language, share, rate)  
- Login — lib/screens/login_screen_new.dart (email/mobile + password)  
- Register — lib/screens/register_screen.dart (full registration with optional photo)  
- Edit Profile — lib/screens/edit_profile_screen.dart (update name, address, photo)  
- Reviews — lib/screens/reviews_screen.dart (user/provider reviews)  
- All Services — lib/screens/all_services_screen.dart (full catalog)

---

## 📂 Project Structure

```
lib/
├── main.dart
├── models/
│   ├── user.dart
│   ├── service_item.dart
│   ├── service_booking.dart
│   └── review.dart
├── providers/
│   ├── theme_provider.dart
│   └── user_provider.dart
├── screens/
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── account_screen.dart
│   ├── history_screen.dart
│   ├── wallet_screen.dart
│   ├── menu_screen.dart
│   ├── login_screen_new.dart
│   ├── register_screen.dart
│   ├── edit_profile_screen.dart
│   ├── reviews_screen.dart
│   └── all_services_screen.dart
├── widgets/
│   ├── custom_bottom_nav_bar.dart
│   ├── sticky_search_bar.dart
│   ├── address_bar.dart
│   ├── quick_action_tiles.dart
│   ├── promotional_cards.dart
│   ├── trust_strip.dart
│   ├── category_grid.dart
│   └── history_card.dart
└── utils/
    └── app_theme.dart
```

---

## 🧠 State Management & Key Components

State management: Provider.

ThemeProvider
- themeMode (Light / Dark / System)  
- isDarkMode  
- setThemeMode(AppThemeMode)

UserProvider
- currentUser  
- bookingHistory  
- reviews  
- isLoggedIn  
- register(User)  
- login(emailOrMobile, password)  
- logout()  
- getFilteredBookings(...)

Business logic is separated from UI widgets and structured for future backend integration.

---

## 🎨 Theme System

Light Theme
- Primary: Teal — #00897B  
- Background: #F5F5F5  
- Cards: White  
- Text: Dark grey

Dark Theme
- Primary: Light Teal — #4DB6AC  
- Background: #121212  
- Cards: #1E1E1E  
- Text: Light grey

Theme controls:
- Toggle switch in Account  
- Dropdown selector (Light / Dark / System)

---

## 🚀 Installation & Run

Prerequisites:
- Flutter SDK 3.0.0+  
- Dart SDK 3.0.0+  
- Android Studio or VS Code

Quick setup:
```bash
flutter pub get
flutter run
```

Platform-specific commands:
- Android: flutter run -d android  
- iOS: flutter run -d ios  
- Web: flutter run -d chrome  
- macOS: flutter run -d macos

---

## 📸 Platform-specific Setup (Image Picker)

The app uses image_picker for profile photos.

Add to pubspec.yaml:
```yaml
dependencies:
  image_picker: ^1.0.7
```

iOS (ios/Info.plist)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos to set profile picture</string>
<key>NSCameraUsageDescription</key>
<string>We need access to camera to take profile picture</string>
```

Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

Example usage:
```dart
final XFile? image = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  maxWidth: 512,
  maxHeight: 512,
);
```

---

## 🧾 Application Functionality Overview

- Separate login and registration flows (fast login + full register)  
- Optional profile photo upload with preview and remove option  
- Guest-accessible account and appearance settings  
- Editable profile with immediate UI updates  
- Reviews listing with rating, provider details, and dates  
- Real-time home search across 16 services  
- In-memory authentication and session handling (auto-login on register)  
- Scroll-safe filter bottom sheets in History  
- Provider-driven UI updates and centralized state

---

## 🛣 Routes

```dart
routes: {
  '/login': LoginScreen(),
  '/register': RegisterScreen(),
  '/edit-profile': EditProfileScreen(),
  '/reviews': ReviewsScreen(),
  '/all-services': AllServicesScreen(),
}
```

---

## 🧪 Testing Checklist

- Registration with/without photo  
- Login via email or mobile  
- Invalid credential handling  
- Guest account access  
- Theme switching and persistence  
- Profile editing (name, address, photo)  
- Search & filter functionality (Home & History)  
- History list scrolling and filtering

---

## 🔮 Future Improvements

- Backend integration (auth, services, bookings)  
- Secure password storage & persistent sessions  
- Push notifications & payment gateway integration  
- Social authentication (Google / Apple / Facebook)  
- Cloud image uploads for profile pictures

---

## 🔐 Security Notes

Current implementation uses in-memory storage:
- Plain text passwords (development only)  
- No encryption or secure storage

Production readiness guidance:
- Use password hashing (bcrypt/argon2)  
- Secure storage (Keychain / Android KeyStore)  
- Token-based authentication (JWT) with refresh tokens  
- HTTPS-only APIs

---

## 📚 Support & References

- Flutter Docs: https://docs.flutter.dev  
- Provider: https://pub.dev/packages/provider  
- Material 3: https://m3.material.io

---

Happy Coding! 🚀