# Flutter lib Folder Detailed Summary

Generated on: 2026-04-06 09:32:02
Total Dart files analyzed: 103

## How to read this report
- **File type**: inferred from folder structure
- **Defined symbols**: classes found in that file
- **Used by (imports)**: files that directly import this file
- **Used by (symbol references)**: files that mention one or more defined class names
- **Why this file exists**: practical purpose in architecture

## ..\\auth\\auth_screen.dart

- **File type**: Authentication
- **Why this file exists**: Authentication flow component for auth screen to keep login/register/OTP concerns isolated.
- **Defined symbols**: AuthScreen, _AuthScreenState
- **Imports**: package:flutter/material.dart, ../customer/models/user_role.dart, login_tab.dart, register_tab.dart, worker_login_tab.dart, worker_register_tab.dart
- **Used by (imports)**: ..\\customer\\screens\\onboarding_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\auth\\login_tab.dart

- **File type**: Authentication
- **Why this file exists**: Authentication flow component for login tab to keep login/register/OTP concerns isolated.
- **Defined symbols**: LoginTab, _LoginTabState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/user_provider.dart, ../theme/app_theme.dart, otp_verification_screen.dart
- **Used by (imports)**: ..\\auth\\auth_screen.dart, ..\\main.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\auth\\otp_verification_screen.dart

- **File type**: Authentication
- **Why this file exists**: Authentication flow component for otp verification screen to keep login/register/OTP concerns isolated.
- **Defined symbols**: OTPVerificationScreen, _OTPVerificationScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/user_provider.dart, ../theme/app_theme.dart, dart:async
- **Used by (imports)**: ..\\auth\\login_tab.dart, ..\\auth\\register_tab.dart, ..\\auth\\worker_login_tab.dart, ..\\auth\\worker_register_tab.dart, ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\auth\\register_tab.dart

- **File type**: Authentication
- **Why this file exists**: Authentication flow component for register tab to keep login/register/OTP concerns isolated.
- **Defined symbols**: RegisterTab, _RegisterTabState
- **Imports**: package:flutter/material.dart, package:flutter/services.dart, package:provider/provider.dart, ../providers/user_provider.dart, ../theme/app_theme.dart, otp_verification_screen.dart
- **Used by (imports)**: ..\\auth\\auth_screen.dart, ..\\main.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\auth\\worker_login_tab.dart

- **File type**: Authentication
- **Why this file exists**: Authentication flow component for worker login tab to keep login/register/OTP concerns isolated.
- **Defined symbols**: WorkerLoginTab, _WorkerLoginTabState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/worker_provider.dart, ../theme/app_theme.dart, worker_otp_verification_screen.dart
- **Used by (imports)**: ..\\auth\\auth_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\auth\\worker_otp_verification_screen.dart

- **File type**: Authentication
- **Why this file exists**: Authentication flow component for worker otp verification screen to keep login/register/OTP concerns isolated.
- **Defined symbols**: WorkerOTPVerificationScreen, _WorkerOTPVerificationScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/worker_provider.dart, ../theme/app_theme.dart, dart:async
- **Used by (imports)**: ..\\auth\\worker_login_tab.dart, ..\\auth\\worker_register_tab.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\auth\\worker_register_tab.dart

- **File type**: Authentication
- **Why this file exists**: Authentication flow component for worker register tab to keep login/register/OTP concerns isolated.
- **Defined symbols**: WorkerRegisterTab, _WorkerRegisterTabState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/worker_provider.dart, ../theme/app_theme.dart, worker_otp_verification_screen.dart
- **Used by (imports)**: ..\\auth\\auth_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\delegates\\service_search_delegate.dart

- **File type**: Delegate
- **Why this file exists**: Custom delegate for service search delegate to implement framework-driven behavior (search/navigation/etc.) cleanly.
- **Defined symbols**: ServiceSearchDelegate
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/service_provider.dart, ../../providers/user_provider.dart, ../screens/users/search_results_screen.dart, ../../theme/app_theme.dart, ../services/location_service.dart
- **Used by (imports)**: ..\\customer\\screens\\home_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\models\\booking.dart

- **File type**: Model
- **Why this file exists**: Data structure for booking used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: Booking
- **Imports**: (none)
- **Used by (imports)**: ..\\customer\\providers\\booking_provider.dart, ..\\customer\\widgets\\booking_card.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\models\\payment.dart

- **File type**: Model
- **Why this file exists**: Data structure for payment used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: Payment
- **Imports**: (none)
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\models\\review.dart

- **File type**: Model
- **Why this file exists**: Data structure for review used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: Review
- **Imports**: (none)
- **Used by (imports)**: ..\\customer\\providers\\service_provider.dart, ..\\customer\\screens\\users\\review_management_screen.dart, ..\\providers\\user_provider.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\models\\service.dart

- **File type**: Model
- **Why this file exists**: Data structure for service used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: Service
- **Imports**: (none)
- **Used by (imports)**: ..\\customer\\delegates\\service_search_delegate.dart, ..\\customer\\providers\\booking_provider.dart, ..\\customer\\providers\\service_provider.dart, ..\\customer\\providers\\wallet_provider.dart, ..\\customer\\screens\\edit_profile_screen.dart, ..\\customer\\screens\\users\\payment_screen.dart, ..\\customer\\screens\\users\\scan_payment_qr_screen.dart, ..\\customer\\screens\\users\\search_results_screen.dart, ..\\customer\\screens\\users\\service_provider_details_screen.dart, ..\\customer\\widgets\\address_bar.dart, ..\\customer\\widgets\\category_grid.dart, ..\\main.dart, ..\\providers\\user_provider.dart, ..\\providers\\worker_provider.dart, ..\\worker\\dialogs\\service_category_selection_dialog.dart, ..\\worker\\providers\\job_provider.dart, ..\\worker\\providers\\worker_verification_provider.dart, ..\\worker\\screens\\account_screen.dart, ..\\worker\\screens\\availability_screen.dart, ..\\worker\\screens\\bank_details_screen.dart, ..\\worker\\screens\\edit_profile_screen.dart, ..\\worker\\screens\\job_otp_verification_screen.dart, ..\\worker\\screens\\my_reviews_screen.dart, ..\\worker\\screens\\my_reviews_screen_new.dart, ..\\worker\\screens\\past_services_screen.dart, ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart, ..\\worker\\screens\\verification_screen.dart, ..\\worker\\screens\\worker_money_screen.dart, ..\\worker\\screens\\worker_notifications_screen.dart, ..\\worker\\screens\\worker_services_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\models\\service_category.dart

- **File type**: Model
- **Why this file exists**: Data structure for service category used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: ServiceCategory
- **Imports**: (none)
- **Used by (imports)**: ..\\customer\\providers\\service_provider.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\models\\user.dart

- **File type**: Model
- **Why this file exists**: Data structure for user used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: User
- **Imports**: (none)
- **Used by (imports)**: ..\\customer\\providers\\service_provider.dart, ..\\customer\\screens\\users\\review_management_screen.dart, ..\\customer\\widgets\\service_provider_card.dart, ..\\providers\\user_provider.dart, ..\\providers\\worker_provider.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\models\\user_location.dart

- **File type**: Model
- **Why this file exists**: Data structure for user location used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: UserLocation
- **Imports**: (none)
- **Used by (imports)**: ..\\providers\\user_provider.dart, ..\\providers\\worker_provider.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\models\\user_role.dart

- **File type**: Model
- **Why this file exists**: Data structure for user role used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: (no class declaration detected)
- **Imports**: (none)
- **Used by (imports)**: ..\\auth\\auth_screen.dart, ..\\customer\\screens\\onboarding_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\models\\wallet_transaction.dart

- **File type**: Model
- **Why this file exists**: Data structure for wallet transaction used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: WalletTransaction
- **Imports**: (none)
- **Used by (imports)**: ..\\customer\\providers\\wallet_provider.dart, ..\\customer\\widgets\\wallet_transaction_card.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\models\\worker.dart

- **File type**: Model
- **Why this file exists**: Data structure for worker used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: Worker
- **Imports**: (none)
- **Used by (imports)**: ..\\customer\\providers\\service_provider.dart, ..\\customer\\screens\\users\\review_management_screen.dart, ..\\customer\\widgets\\service_provider_card.dart, ..\\providers\\worker_provider.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\models\\worker_service.dart

- **File type**: Model
- **Why this file exists**: Data structure for worker service used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: WorkerService
- **Imports**: (none)
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\providers\\booking_provider.dart

- **File type**: Provider
- **Why this file exists**: State management unit for booking provider that centralizes business state and notifyListeners updates.
- **Defined symbols**: BookingProvider
- **Imports**: dart:async, package:flutter/foundation.dart, ../models/booking.dart, ../services/api_service.dart
- **Used by (imports)**: ..\\customer\\screens\\history_screen.dart, ..\\customer\\screens\\home_screen.dart, ..\\customer\\screens\\users\\booking_details_screen.dart, ..\\customer\\screens\\users\\booking_status_screen.dart, ..\\customer\\screens\\users\\otp_job_completion_screen.dart, ..\\customer\\screens\\users\\payment_screen.dart, ..\\customer\\screens\\users\\payment_verification_screen.dart, ..\\customer\\screens\\users\\rate_worker_screen.dart, ..\\customer\\screens\\users\\review_management_screen.dart, ..\\main.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\providers\\language_provider.dart

- **File type**: Provider
- **Why this file exists**: State management unit for language provider that centralizes business state and notifyListeners updates.
- **Defined symbols**: LanguageProvider
- **Imports**: package:flutter/foundation.dart
- **Used by (imports)**: ..\\customer\\screens\\settings\\language_screen.dart, ..\\main.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\providers\\service_provider.dart

- **File type**: Provider
- **Why this file exists**: State management unit for service provider that centralizes business state and notifyListeners updates.
- **Defined symbols**: ServiceProvider
- **Imports**: package:flutter/foundation.dart, ../models/worker.dart, ../models/service.dart, ../models/service_category.dart, ../models/user.dart, ../models/review.dart, ../services/api_service.dart, dart:math
- **Used by (imports)**: ..\\customer\\delegates\\service_search_delegate.dart, ..\\customer\\screens\\all_services_screen.dart, ..\\customer\\screens\\history_screen.dart, ..\\customer\\screens\\users\\booking_details_screen.dart, ..\\customer\\screens\\users\\booking_status_screen.dart, ..\\customer\\screens\\users\\rate_worker_screen.dart, ..\\customer\\screens\\users\\review_management_screen.dart, ..\\customer\\screens\\users\\search_results_screen.dart, ..\\customer\\screens\\users\\service_provider_details_screen.dart, ..\\customer\\widgets\\address_bar.dart, ..\\customer\\widgets\\category_grid.dart, ..\\customer\\widgets\\quick_action_tiles.dart, ..\\main.dart, ..\\worker\\dialogs\\service_category_selection_dialog.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\providers\\wallet_provider.dart

- **File type**: Provider
- **Why this file exists**: State management unit for wallet provider that centralizes business state and notifyListeners updates.
- **Defined symbols**: WalletProvider
- **Imports**: package:flutter/foundation.dart, ../models/wallet_transaction.dart, ../services/api_service.dart
- **Used by (imports)**: ..\\customer\\screens\\users\\payment_screen.dart, ..\\main.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\account_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for account screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: AccountScreen
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, package:flutter_project/customer/screens/settings/share_app_bottom_sheet.dart, ../../providers/user_provider.dart, ../../theme/theme_provider.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\customer\\screens\\main_screen.dart, ..\\worker\\worker_home.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\all_services_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for all services screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: AllServicesScreen
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/service_provider.dart, users/search_results_screen.dart
- **Used by (imports)**: ..\\main.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\edit_profile_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for edit profile screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: EditProfileScreen, _EditProfileScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../providers/user_provider.dart, ../../theme/app_theme.dart, ../services/location_service.dart
- **Used by (imports)**: ..\\main.dart, ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\history_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for history screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: HistoryScreen, _HistoryScreenState
- **Imports**: dart:async, package:flutter/material.dart, package:provider/provider.dart, ../providers/booking_provider.dart, ../providers/service_provider.dart, ../../providers/user_provider.dart, package:intl/intl.dart, users/rate_worker_screen.dart, users/review_management_screen.dart, users/payment_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\main_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\home_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for home screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: HomeScreen, _HomeScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/booking_provider.dart, ../../providers/user_provider.dart, ../widgets/address_bar.dart, ../widgets/quick_action_tiles.dart, ../widgets/trust_strip.dart, ../widgets/category_grid.dart, ../delegates/service_search_delegate.dart, ../../theme/app_theme.dart, users/booking_status_screen.dart, users/search_results_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\main_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\main_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for main screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: MainScreen, _MainScreenState
- **Imports**: package:flutter/material.dart, package:flutter_project/customer/widgets/custom_bottom_nav_bar.dart, package:flutter_project/customer/screens/home_screen.dart, package:flutter_project/customer/screens/account_screen.dart, package:flutter_project/customer/screens/history_screen.dart, package:flutter_project/customer/screens/menu_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\users\\booking_details_screen.dart, ..\\main.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\menu_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for menu screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: MenuScreen
- **Imports**: package:flutter/material.dart, package:flutter_project/customer/screens/settings/help_support_screen.dart, package:flutter_project/customer/screens/settings/language_screen.dart, package:flutter_project/customer/screens/settings/rate_us_screen.dart, package:flutter_project/customer/screens/settings/settings_screen.dart, package:flutter_project/customer/screens/settings/share_app_bottom_sheet.dart
- **Used by (imports)**: ..\\customer\\screens\\main_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\onboarding_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for onboarding screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: OnboardingScreen, _OnboardingScreenState
- **Imports**: package:flutter/material.dart, ../models/user_role.dart, ../../auth/auth_screen.dart
- **Used by (imports)**: ..\\main.dart, ..\\worker\\screens\\account_screen.dart, ..\\worker\\screens\\settings_screen.dart, ..\\worker\\worker_dashboard.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\reviews_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for reviews screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: ReviewsScreen
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../providers/user_provider.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\main.dart, ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\settings\\help_support_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for help support screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: HelpSupportScreen
- **Imports**: package:flutter/material.dart
- **Used by (imports)**: ..\\customer\\screens\\menu_screen.dart, ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\settings\\language_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for language screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: LanguageScreen
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../providers/language_provider.dart
- **Used by (imports)**: ..\\customer\\screens\\menu_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\settings\\rate_us_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for rate us screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: RateUsScreen, _RateUsScreenState
- **Imports**: package:flutter/material.dart
- **Used by (imports)**: ..\\customer\\screens\\menu_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\settings\\settings_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for settings screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: SettingsScreen, _SettingsScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../../providers/user_provider.dart, ../../../theme/theme_provider.dart, ../../../theme/app_theme.dart, ../static/privacy_policy_screen.dart, ../static/terms_conditions_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\menu_screen.dart, ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\settings\\share_app_bottom_sheet.dart

- **File type**: Screen
- **Why this file exists**: UI screen for share app bottom sheet functionality so this flow stays modular and independently navigable.
- **Defined symbols**: ShareAppBottomSheet, _ShareOption
- **Imports**: package:flutter/material.dart, package:flutter/services.dart, package:font_awesome_flutter/font_awesome_flutter.dart, package:share_plus/share_plus.dart
- **Used by (imports)**: ..\\customer\\screens\\account_screen.dart, ..\\customer\\screens\\menu_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\static\\about_us_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for about us screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: AboutUsScreen
- **Imports**: package:flutter/material.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\static\\privacy_policy_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for privacy policy screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: PrivacyPolicyScreen
- **Imports**: package:flutter/material.dart
- **Used by (imports)**: ..\\customer\\screens\\settings\\settings_screen.dart, ..\\worker\\screens\\settings_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\static\\terms_conditions_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for terms conditions screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: TermsConditionsScreen
- **Imports**: package:flutter/material.dart
- **Used by (imports)**: ..\\customer\\screens\\settings\\settings_screen.dart, ..\\worker\\screens\\settings_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\users\\booking_details_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for booking details screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: BookingDetailsScreen, _BookingDetailsScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, package:intl/intl.dart, ../../providers/booking_provider.dart, ../../providers/service_provider.dart, ../../../providers/user_provider.dart, ../main_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\users\\service_provider_details_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\users\\booking_status_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for booking status screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: BookingStatusScreen, _BookingStatusScreenState
- **Imports**: dart:async, package:flutter/material.dart, package:provider/provider.dart, ../../providers/booking_provider.dart, ../../providers/service_provider.dart, ../../../providers/user_provider.dart, ../../widgets/booking_card.dart, rate_worker_screen.dart, review_management_screen.dart, payment_screen.dart, scan_payment_qr_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\home_screen.dart, ..\\customer\\screens\\users\\rate_worker_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\users\\demo_payment_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for demo payment screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: DemoPaymentScreen
- **Imports**: package:flutter/material.dart, package:qr_flutter/qr_flutter.dart
- **Used by (imports)**: ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\users\\otp_job_completion_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for otp job completion screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: OtpJobCompletionScreen, _OtpJobCompletionScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../providers/booking_provider.dart, payment_screen.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\users\\payment_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for payment screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: PaymentScreen, _PaymentScreenState
- **Imports**: dart:convert, package:flutter/material.dart, package:provider/provider.dart, package:qr_flutter/qr_flutter.dart, ../../providers/booking_provider.dart, ../../providers/wallet_provider.dart, ../../../providers/user_provider.dart, ../../services/api_service.dart, rate_worker_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\history_screen.dart, ..\\customer\\screens\\users\\booking_status_screen.dart, ..\\customer\\screens\\users\\otp_job_completion_screen.dart, ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\users\\payment_verification_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for payment verification screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: PaymentVerificationScreen, _PaymentVerificationScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../providers/booking_provider.dart, ../../../providers/user_provider.dart, rate_worker_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\users\\scan_payment_qr_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\users\\rate_worker_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for rate worker screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: RateWorkerScreen, _RateWorkerScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../providers/service_provider.dart, ../../providers/booking_provider.dart, ../../../providers/user_provider.dart, package:flutter_project/customer/screens/users/booking_status_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\history_screen.dart, ..\\customer\\screens\\users\\booking_status_screen.dart, ..\\customer\\screens\\users\\payment_screen.dart, ..\\customer\\screens\\users\\payment_verification_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\users\\review_management_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for review management screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: ReviewManagementScreen, _ReviewManagementScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../providers/service_provider.dart, ../../providers/booking_provider.dart, ../../../providers/user_provider.dart, ../../models/review.dart, ../../models/worker.dart, ../../models/user.dart
- **Used by (imports)**: ..\\customer\\screens\\history_screen.dart, ..\\customer\\screens\\users\\booking_status_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\users\\scan_payment_qr_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for scan payment qr screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: ScanPaymentQrScreen, _ScanPaymentQrScreenState
- **Imports**: package:flutter/material.dart, ../../services/api_service.dart, payment_verification_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\users\\booking_status_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\users\\search_results_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for search results screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: SearchResultsScreen, _SearchResultsScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../providers/service_provider.dart, ../../models/service.dart, ../../../providers/user_provider.dart, ../../widgets/service_provider_card.dart, ../../../theme/app_theme.dart, service_provider_details_screen.dart
- **Used by (imports)**: ..\\customer\\delegates\\service_search_delegate.dart, ..\\customer\\screens\\all_services_screen.dart, ..\\customer\\screens\\home_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\screens\\users\\service_provider_details_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for service provider details screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: ServiceProviderDetailsScreen, _StatItem
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../providers/service_provider.dart, ../../models/service.dart, ../../../providers/user_provider.dart, booking_details_screen.dart, package:intl/intl.dart
- **Used by (imports)**: ..\\customer\\screens\\users\\search_results_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\services\\api_service.dart

- **File type**: Service
- **Why this file exists**: Service layer for api service that isolates external API/system calls from presentation logic.
- **Defined symbols**: ApiService
- **Imports**: dart:convert, package:http/http.dart, package:shared_preferences/shared_preferences.dart
- **Used by (imports)**: ..\\customer\\providers\\booking_provider.dart, ..\\customer\\providers\\service_provider.dart, ..\\customer\\providers\\wallet_provider.dart, ..\\customer\\screens\\users\\payment_screen.dart, ..\\customer\\screens\\users\\scan_payment_qr_screen.dart, ..\\main.dart, ..\\providers\\user_provider.dart, ..\\providers\\worker_provider.dart, ..\\worker\\dialogs\\service_category_selection_dialog.dart, ..\\worker\\providers\\job_provider.dart, ..\\worker\\providers\\worker_verification_provider.dart, ..\\worker\\screens\\account_screen.dart, ..\\worker\\screens\\availability_screen.dart, ..\\worker\\screens\\bank_details_screen.dart, ..\\worker\\screens\\job_otp_verification_screen.dart, ..\\worker\\screens\\my_reviews_screen.dart, ..\\worker\\screens\\my_reviews_screen_new.dart, ..\\worker\\screens\\past_services_screen.dart, ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart, ..\\worker\\screens\\verification_screen.dart, ..\\worker\\screens\\worker_money_screen.dart, ..\\worker\\screens\\worker_notifications_screen.dart, ..\\worker\\screens\\worker_services_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\services\\location_service.dart

- **File type**: Service
- **Why this file exists**: Service layer for location service that isolates external API/system calls from presentation logic.
- **Defined symbols**: LocationService
- **Imports**: package:flutter/material.dart, package:geolocator/geolocator.dart, package:geocoding/geocoding.dart
- **Used by (imports)**: ..\\customer\\delegates\\service_search_delegate.dart, ..\\customer\\screens\\edit_profile_screen.dart, ..\\customer\\widgets\\address_bar.dart, ..\\customer\\widgets\\category_grid.dart, ..\\worker\\screens\\edit_profile_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\utils\\constants.dart

- **File type**: Utility
- **Why this file exists**: Helper utilities for constants to keep common logic decoupled from widgets and providers.
- **Defined symbols**: AppConstants
- **Imports**: (none)
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\widgets\\address_bar.dart

- **File type**: Widget
- **Why this file exists**: Reusable UI component for address bar to avoid duplicating view code across screens.
- **Defined symbols**: AddressBar
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/service_provider.dart, ../../providers/user_provider.dart, ../../theme/app_theme.dart, ../services/location_service.dart
- **Used by (imports)**: ..\\customer\\screens\\home_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\widgets\\booking_card.dart

- **File type**: Widget
- **Why this file exists**: Reusable UI component for booking card to avoid duplicating view code across screens.
- **Defined symbols**: BookingCard
- **Imports**: package:flutter/material.dart, ../models/booking.dart, package:intl/intl.dart
- **Used by (imports)**: ..\\customer\\screens\\users\\booking_status_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\widgets\\category_grid.dart

- **File type**: Widget
- **Why this file exists**: Reusable UI component for category grid to avoid duplicating view code across screens.
- **Defined symbols**: CategoryGrid
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/service_provider.dart, ../../providers/user_provider.dart, ../../theme/app_theme.dart, ../services/location_service.dart
- **Used by (imports)**: ..\\customer\\screens\\home_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\widgets\\custom_bottom_nav_bar.dart

- **File type**: Widget
- **Why this file exists**: Reusable UI component for custom bottom nav bar to avoid duplicating view code across screens.
- **Defined symbols**: CustomBottomNavBar
- **Imports**: package:flutter/material.dart
- **Used by (imports)**: ..\\customer\\screens\\main_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\widgets\\quick_action_tiles.dart

- **File type**: Widget
- **Why this file exists**: Reusable UI component for quick action tiles to avoid duplicating view code across screens.
- **Defined symbols**: QuickActionTiles
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/service_provider.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\customer\\screens\\home_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\widgets\\service_provider_card.dart

- **File type**: Widget
- **Why this file exists**: Reusable UI component for service provider card to avoid duplicating view code across screens.
- **Defined symbols**: ServiceProviderCard
- **Imports**: package:flutter/material.dart, ../models/worker.dart, ../models/user.dart
- **Used by (imports)**: ..\\customer\\screens\\users\\search_results_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\widgets\\trust_strip.dart

- **File type**: Widget
- **Why this file exists**: Reusable UI component for trust strip to avoid duplicating view code across screens.
- **Defined symbols**: TrustStrip
- **Imports**: package:flutter/material.dart
- **Used by (imports)**: ..\\customer\\screens\\home_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\customer\\widgets\\wallet_transaction_card.dart

- **File type**: Widget
- **Why this file exists**: Reusable UI component for wallet transaction card to avoid duplicating view code across screens.
- **Defined symbols**: WalletTransactionCard
- **Imports**: package:flutter/material.dart, ../models/wallet_transaction.dart, package:intl/intl.dart, ../../theme/app_theme.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\main.dart

- **File type**: Entry Point
- **Why this file exists**: App startup file that initializes global providers, theme, and initial navigation flow.
- **Defined symbols**: HomeServicesApp, AppInitializer, _AppInitializerState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, package:firebase_core/firebase_core.dart, package:firebase_messaging/firebase_messaging.dart, package:flutter_project/theme/theme_provider.dart, package:flutter_project/providers/user_provider.dart, package:flutter_project/providers/worker_provider.dart, package:flutter_project/theme/app_theme.dart, package:flutter_project/customer/screens/onboarding_screen.dart, package:flutter_project/auth/login_tab.dart, package:flutter_project/auth/register_tab.dart, package:flutter_project/customer/screens/edit_profile_screen.dart, package:flutter_project/customer/screens/reviews_screen.dart, package:flutter_project/customer/screens/all_services_screen.dart, package:flutter_project/customer/screens/main_screen.dart, package:flutter_project/worker/worker_home.dart, package:flutter_project/worker/providers/job_provider.dart, package:flutter_project/customer/providers/booking_provider.dart, package:flutter_project/customer/providers/service_provider.dart, package:flutter_project/customer/providers/wallet_provider.dart, package:flutter_project/customer/providers/language_provider.dart, package:flutter_project/customer/services/api_service.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\providers\\user_provider.dart

- **File type**: Provider
- **Why this file exists**: State management unit for user provider that centralizes business state and notifyListeners updates.
- **Defined symbols**: UserProvider
- **Imports**: package:flutter/material.dart, ../customer/models/user.dart, ../customer/models/user_location.dart, ../customer/models/review.dart, ../customer/services/api_service.dart
- **Used by (imports)**: ..\\auth\\login_tab.dart, ..\\auth\\otp_verification_screen.dart, ..\\auth\\register_tab.dart, ..\\customer\\delegates\\service_search_delegate.dart, ..\\customer\\screens\\account_screen.dart, ..\\customer\\screens\\edit_profile_screen.dart, ..\\customer\\screens\\history_screen.dart, ..\\customer\\screens\\home_screen.dart, ..\\customer\\screens\\reviews_screen.dart, ..\\customer\\screens\\settings\\settings_screen.dart, ..\\customer\\screens\\users\\booking_details_screen.dart, ..\\customer\\screens\\users\\booking_status_screen.dart, ..\\customer\\screens\\users\\payment_screen.dart, ..\\customer\\screens\\users\\payment_verification_screen.dart, ..\\customer\\screens\\users\\rate_worker_screen.dart, ..\\customer\\screens\\users\\review_management_screen.dart, ..\\customer\\screens\\users\\search_results_screen.dart, ..\\customer\\screens\\users\\service_provider_details_screen.dart, ..\\customer\\widgets\\address_bar.dart, ..\\customer\\widgets\\category_grid.dart, ..\\main.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\providers\\worker_provider.dart

- **File type**: Provider
- **Why this file exists**: State management unit for worker provider that centralizes business state and notifyListeners updates.
- **Defined symbols**: WorkerProvider
- **Imports**: package:flutter/material.dart, ../customer/models/user.dart, ../customer/models/worker.dart, ../customer/models/user_location.dart, package:flutter_project/customer/services/api_service.dart
- **Used by (imports)**: ..\\auth\\worker_login_tab.dart, ..\\auth\\worker_otp_verification_screen.dart, ..\\auth\\worker_register_tab.dart, ..\\main.dart, ..\\worker\\screens\\account_screen.dart, ..\\worker\\screens\\edit_profile_screen.dart, ..\\worker\\screens\\my_reviews_screen.dart, ..\\worker\\screens\\my_reviews_screen_new.dart, ..\\worker\\screens\\settings_screen.dart, ..\\worker\\screens\\worker_money_screen.dart, ..\\worker\\screens\\worker_services_screen.dart, ..\\worker\\worker_dashboard.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\theme\\app_theme.dart

- **File type**: Theme
- **Why this file exists**: Theme/styling configuration for consistent visual behavior across the app.
- **Defined symbols**: AppTheme
- **Imports**: package:flutter/material.dart
- **Used by (imports)**: ..\\auth\\login_tab.dart, ..\\auth\\otp_verification_screen.dart, ..\\auth\\register_tab.dart, ..\\auth\\worker_login_tab.dart, ..\\auth\\worker_otp_verification_screen.dart, ..\\auth\\worker_register_tab.dart, ..\\customer\\delegates\\service_search_delegate.dart, ..\\customer\\screens\\account_screen.dart, ..\\customer\\screens\\edit_profile_screen.dart, ..\\customer\\screens\\home_screen.dart, ..\\customer\\screens\\reviews_screen.dart, ..\\customer\\screens\\settings\\settings_screen.dart, ..\\customer\\screens\\users\\search_results_screen.dart, ..\\customer\\widgets\\address_bar.dart, ..\\customer\\widgets\\category_grid.dart, ..\\customer\\widgets\\quick_action_tiles.dart, ..\\customer\\widgets\\wallet_transaction_card.dart, ..\\main.dart, ..\\worker\\screens\\account_screen.dart, ..\\worker\\screens\\bank_details_screen.dart, ..\\worker\\screens\\bank_transfers_screen.dart, ..\\worker\\screens\\document_status_screen.dart, ..\\worker\\screens\\edit_profile_screen.dart, ..\\worker\\screens\\help_support_screen.dart, ..\\worker\\screens\\job_details_screen.dart, ..\\worker\\screens\\pending_deductions_screen.dart, ..\\worker\\screens\\privacy_policy_screen.dart, ..\\worker\\screens\\scheduled_jobs_day_screen.dart, ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart, ..\\worker\\screens\\scheduled_jobs_month_screen.dart, ..\\worker\\screens\\scheduled_jobs_week_screen.dart, ..\\worker\\screens\\settings_screen.dart, ..\\worker\\screens\\terms_conditions_screen.dart, ..\\worker\\screens\\verification_screen.dart, ..\\worker\\screens\\worker_money_screen.dart, ..\\worker\\screens\\worker_notifications_screen.dart, ..\\worker\\screens\\worker_services_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\theme\\theme_provider.dart

- **File type**: Theme
- **Why this file exists**: Theme/styling configuration for consistent visual behavior across the app.
- **Defined symbols**: ThemeProvider
- **Imports**: package:flutter/material.dart, package:flutter/scheduler.dart
- **Used by (imports)**: ..\\customer\\screens\\account_screen.dart, ..\\customer\\screens\\settings\\settings_screen.dart, ..\\main.dart, ..\\worker\\screens\\settings_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\utils\\map_launcher.dart

- **File type**: Utility
- **Why this file exists**: Helper utilities for map launcher to keep common logic decoupled from widgets and providers.
- **Defined symbols**: MapLauncher
- **Imports**: package:url_launcher/url_launcher.dart
- **Used by (imports)**: ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart, ..\\worker\\widgets\\current_job_card.dart, ..\\worker\\widgets\\job_action_overlay.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\dialogs\\service_category_selection_dialog.dart

- **File type**: Dialog
- **Why this file exists**: Dialog-specific UI/logic for service category selection dialog separated from primary screens for clarity and reuse.
- **Defined symbols**: ServiceCategorySelectionDialog, _ServiceCategorySelectionDialogState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../customer/providers/service_provider.dart, ../../customer/services/api_service.dart
- **Used by (imports)**: ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\models\\job.dart

- **File type**: Model
- **Why this file exists**: Data structure for job used to transfer and validate typed data between UI, providers, and API layers.
- **Defined symbols**: Job
- **Imports**: (none)
- **Used by (imports)**: ..\\worker\\providers\\job_provider.dart, ..\\worker\\screens\\job_details_screen.dart, ..\\worker\\screens\\job_otp_verification_screen.dart, ..\\worker\\screens\\scheduled_jobs_day_screen.dart, ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart, ..\\worker\\screens\\scheduled_jobs_month_screen.dart, ..\\worker\\screens\\scheduled_jobs_week_screen.dart, ..\\worker\\widgets\\current_job_card.dart, ..\\worker\\widgets\\job_action_overlay.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\providers\\job_provider.dart

- **File type**: Provider
- **Why this file exists**: State management unit for job provider that centralizes business state and notifyListeners updates.
- **Defined symbols**: JobProvider
- **Imports**: package:flutter/material.dart, ../models/job.dart, package:flutter_project/customer/services/api_service.dart
- **Used by (imports)**: ..\\main.dart, ..\\worker\\screens\\job_otp_verification_screen.dart, ..\\worker\\screens\\scheduled_jobs_day_screen.dart, ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart, ..\\worker\\screens\\scheduled_jobs_month_screen.dart, ..\\worker\\screens\\scheduled_jobs_week_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\providers\\worker_verification_provider.dart

- **File type**: Provider
- **Why this file exists**: State management unit for worker verification provider that centralizes business state and notifyListeners updates.
- **Defined symbols**: WorkerVerificationProvider
- **Imports**: package:flutter/material.dart, package:shared_preferences/shared_preferences.dart, ../services/worker_verification_api_service.dart, ../../customer/services/api_service.dart
- **Used by (imports)**: ..\\worker\\screens\\document_status_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\account_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for account screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: WorkerAccountScreen
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, package:image_picker/image_picker.dart, ../../providers/worker_provider.dart, ../../theme/app_theme.dart, ../../customer/services/api_service.dart, ../../customer/screens/onboarding_screen.dart, edit_profile_screen.dart, verification_screen.dart, bank_transfers_screen.dart, bank_details_screen.dart, past_services_screen.dart, my_reviews_screen.dart, help_support_screen.dart, settings_screen.dart, availability_screen.dart, worker_services_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\main_screen.dart, ..\\worker\\worker_home.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\availability_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for availability screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: AvailabilityScreen, _AvailabilityScreenState
- **Imports**: package:flutter/material.dart, ../../customer/services/api_service.dart
- **Used by (imports)**: ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\bank_details_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for bank details screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: BankDetailsScreen, _BankDetailsScreenState
- **Imports**: dart:io, package:flutter/material.dart, package:image_picker/image_picker.dart, ../../customer/services/api_service.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\bank_transfers_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for bank transfers screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: BankTransfersScreen
- **Imports**: package:flutter/material.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\worker\\screens\\account_screen.dart, ..\\worker\\screens\\worker_money_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\document_status_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for document status screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: DocumentStatusScreen, _DocumentStatusScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/worker_verification_provider.dart, ../../theme/app_theme.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\edit_profile_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for edit profile screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: EditProfileScreen, _EditProfileScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../providers/worker_provider.dart, ../../theme/app_theme.dart, ../../customer/services/location_service.dart
- **Used by (imports)**: ..\\main.dart, ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\help_support_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for help support screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: HelpSupportScreen
- **Imports**: package:flutter/material.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\customer\\screens\\menu_screen.dart, ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\job_details_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for job details screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: JobDetailsScreen
- **Imports**: package:flutter/material.dart, package:intl/intl.dart, ../models/job.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\worker\\screens\\scheduled_jobs_day_screen.dart, ..\\worker\\screens\\scheduled_jobs_month_screen.dart, ..\\worker\\screens\\scheduled_jobs_week_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\job_otp_verification_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for job otp verification screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: JobOTPVerificationScreen, _JobOTPVerificationScreenState
- **Imports**: package:flutter/material.dart, package:flutter/services.dart, package:provider/provider.dart, ../models/job.dart, ../providers/job_provider.dart, ../../customer/services/api_service.dart, ../utils/worker_theme.dart
- **Used by (imports)**: ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\my_reviews_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for my reviews screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: MyReviewsScreen, _MyReviewsScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, package:dio/dio.dart, ../../customer/services/api_service.dart, ../../providers/worker_provider.dart, package:intl/intl.dart
- **Used by (imports)**: ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\my_reviews_screen_new.dart

- **File type**: Screen
- **Why this file exists**: UI screen for my reviews screen new functionality so this flow stays modular and independently navigable.
- **Defined symbols**: MyReviewsScreen, _MyReviewsScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, package:dio/dio.dart, ../../customer/services/api_service.dart, ../../providers/worker_provider.dart, package:intl/intl.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\past_services_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for past services screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: PastServicesScreen, _PastServicesScreenState
- **Imports**: package:flutter/material.dart, ../../customer/services/api_service.dart
- **Used by (imports)**: ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\pending_deductions_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for pending deductions screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: PendingDeductionsScreen
- **Imports**: package:flutter/material.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\worker\\screens\\worker_money_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\privacy_policy_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for privacy policy screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: PrivacyPolicyScreen
- **Imports**: package:flutter/material.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\customer\\screens\\settings\\settings_screen.dart, ..\\worker\\screens\\settings_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\scheduled_jobs_day_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for scheduled jobs day screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: ScheduledJobsDayScreen
- **Imports**: package:flutter/material.dart, package:intl/intl.dart, package:provider/provider.dart, ../../theme/app_theme.dart, ../models/job.dart, ../providers/job_provider.dart, job_details_screen.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart

- **File type**: Screen
- **Why this file exists**: UI screen for scheduled jobs hub screen new functionality so this flow stays modular and independently navigable.
- **Defined symbols**: ScheduledJobsHubScreenNew, _ScheduledJobsHubScreenNewState
- **Imports**: package:flutter/material.dart, package:intl/intl.dart, package:provider/provider.dart, package:shared_preferences/shared_preferences.dart, ../../customer/services/api_service.dart, ../../customer/screens/users/demo_payment_screen.dart, ../../theme/app_theme.dart, ../../utils/map_launcher.dart, ../models/job.dart, ../dialogs/service_category_selection_dialog.dart, ../providers/job_provider.dart, ../widgets/job_action_overlay.dart, ../screens/job_otp_verification_screen.dart
- **Used by (imports)**: ..\\worker\\worker_home.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\scheduled_jobs_month_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for scheduled jobs month screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: ScheduledJobsMonthScreen
- **Imports**: package:flutter/material.dart, package:intl/intl.dart, package:provider/provider.dart, ../../theme/app_theme.dart, ../models/job.dart, ../providers/job_provider.dart, job_details_screen.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\scheduled_jobs_week_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for scheduled jobs week screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: ScheduledJobsWeekScreen
- **Imports**: package:flutter/material.dart, package:intl/intl.dart, package:provider/provider.dart, ../../theme/app_theme.dart, ../models/job.dart, ../providers/job_provider.dart, job_details_screen.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\settings_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for settings screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: SettingsScreen, _SettingsScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../theme/theme_provider.dart, ../../theme/app_theme.dart, ../../providers/worker_provider.dart, ../../customer/screens/onboarding_screen.dart, privacy_policy_screen.dart, terms_conditions_screen.dart
- **Used by (imports)**: ..\\customer\\screens\\menu_screen.dart, ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\terms_conditions_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for terms conditions screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: TermsConditionsScreen
- **Imports**: package:flutter/material.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\customer\\screens\\settings\\settings_screen.dart, ..\\worker\\screens\\settings_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\verification_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for verification screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: VerificationScreen, _VerificationScreenState, DiditKycWebViewScreen, _DiditKycWebViewScreenState
- **Imports**: package:flutter/material.dart, package:webview_flutter/webview_flutter.dart, package:webview_flutter_android/webview_flutter_android.dart, ../../customer/services/api_service.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\auth\\login_tab.dart, ..\\auth\\register_tab.dart, ..\\auth\\worker_login_tab.dart, ..\\auth\\worker_register_tab.dart, ..\\customer\\screens\\users\\scan_payment_qr_screen.dart, ..\\worker\\screens\\account_screen.dart, ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\worker_money_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for worker money screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: WorkerMoneyScreen, _WorkerMoneyScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../providers/worker_provider.dart, ../../customer/services/api_service.dart, ../../theme/app_theme.dart, worker_notifications_screen.dart, bank_transfers_screen.dart, pending_deductions_screen.dart
- **Used by (imports)**: ..\\worker\\worker_home.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\worker_notifications_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for worker notifications screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: WorkerNotificationsScreen, _WorkerNotificationsScreenState
- **Imports**: package:flutter/material.dart, ../../customer/services/api_service.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\worker\\screens\\worker_money_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\screens\\worker_services_screen.dart

- **File type**: Screen
- **Why this file exists**: UI screen for worker services screen functionality so this flow stays modular and independently navigable.
- **Defined symbols**: WorkerServicesScreen, _WorkerServicesScreenState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../../customer/services/api_service.dart, ../../providers/worker_provider.dart, ../../theme/app_theme.dart
- **Used by (imports)**: ..\\worker\\screens\\account_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\services\\worker_verification_api_service.dart

- **File type**: Service
- **Why this file exists**: Service layer for worker verification api service that isolates external API/system calls from presentation logic.
- **Defined symbols**: WorkerVerificationApiService
- **Imports**: package:dio/dio.dart
- **Used by (imports)**: ..\\worker\\providers\\worker_verification_provider.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\utils\\worker_theme.dart

- **File type**: Utility
- **Why this file exists**: Helper utilities for worker theme to keep common logic decoupled from widgets and providers.
- **Defined symbols**: WorkerTheme
- **Imports**: package:flutter/material.dart
- **Used by (imports)**: ..\\worker\\screens\\job_otp_verification_screen.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\widgets\\current_job_card.dart

- **File type**: Widget
- **Why this file exists**: Reusable UI component for current job card to avoid duplicating view code across screens.
- **Defined symbols**: CurrentJobCard
- **Imports**: package:flutter/material.dart, package:intl/intl.dart, ../../utils/map_launcher.dart, ../models/job.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\widgets\\gradient_button.dart

- **File type**: Widget
- **Why this file exists**: Reusable UI component for gradient button to avoid duplicating view code across screens.
- **Defined symbols**: GradientButton
- **Imports**: package:flutter/material.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\widgets\\job_action_overlay.dart

- **File type**: Widget
- **Why this file exists**: Reusable UI component for job action overlay to avoid duplicating view code across screens.
- **Defined symbols**: JobActionOverlay
- **Imports**: package:flutter/material.dart, package:intl/intl.dart, ../../utils/map_launcher.dart, ../models/job.dart
- **Used by (imports)**: ..\\worker\\screens\\scheduled_jobs_hub_screen_new.dart
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\worker_dashboard.dart

- **File type**: General
- **Why this file exists**: Supporting module for worker dashboard created to keep this concern isolated and maintainable.
- **Defined symbols**: WorkerDashboard, _WorkerDashboardState
- **Imports**: package:flutter/material.dart, package:provider/provider.dart, ../providers/worker_provider.dart, ../customer/screens/onboarding_screen.dart
- **Used by (imports)**: (no direct import usage found)
- **Used by (symbol references)**: (no class-name references found)

## ..\\worker\\worker_home.dart

- **File type**: General
- **Why this file exists**: Supporting module for worker home created to keep this concern isolated and maintainable.
- **Defined symbols**: WorkerHome, _WorkerHomeContent, _WorkerHomeContentState
- **Imports**: package:flutter/material.dart, screens/worker_money_screen.dart, screens/account_screen.dart, screens/scheduled_jobs_hub_screen_new.dart
- **Used by (imports)**: ..\\main.dart
- **Used by (symbol references)**: (no class-name references found)

