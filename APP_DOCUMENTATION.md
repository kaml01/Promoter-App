# Promoter App Documentation

## 1. Overview

`Promoter App` is a Flutter mobile application used by field promoters to:

- log in with promoter credentials
- mark attendance against a selected shop
- capture shop selfies
- enter daily sales with item-level details and photos
- review monthly dashboard metrics
- view sales reports by date range

The app is structured as a Flutter client that talks to a backend hosted under an `AndroidServer` base URL.

## 2. Primary User Flow

1. The app opens on the splash screen.
2. If a user session exists in `SharedPreferences`, the app goes to `HomeScreen`.
3. Otherwise, the user lands on `LoginScreen`.
4. After login, the user enters the main shell with bottom navigation:
   - Dashboard
   - Attendance
   - Reports
   - Selfie
5. Attendance and sales actions are location-aware and shop-aware.

## 3. Main Screens

### Splash

File:

- [lib/screen/Splashscreen.dart](./lib/screen/Splashscreen.dart)

Responsibilities:

- initializes shared preferences
- checks whether `USER_ID` already exists
- routes to login or home

### Login

File:

- [lib/screen/LoginScreen.dart](./lib/screen/LoginScreen.dart)

Responsibilities:

- collects username and password
- stores the active backend URL in shared preferences
- calls the login helper
- shows validation and connectivity feedback

Current behavior:

- login tries `LoginSalesPerson3` first and falls back to `LoginSalesPerson`
- login can fall back from the configured host to the backup base URL if needed
- only promoter users are allowed into the app

### Home Shell

File:

- [lib/screen/HomeScreen.dart](./lib/screen/HomeScreen.dart)

Responsibilities:

- acts as the main app container after login
- hosts bottom navigation
- handles logout

Tabs:

- Dashboard
- Attendance
- Sales Report
- Selfie

### Dashboard

File:

- [lib/screen/Dashboard.dart](./lib/screen/Dashboard.dart)

Responsibilities:

- displays monthly target information
- shows achieved quantities
- loads user details and SKU master data
- provides quick access to sales entry with `Add Sale`

Notes:

- `GT` and `MT` groups use `Ltrs` as the unit
- other groups use `Boxes`
- dashboard caches SKU data into local SQLite storage for sales entry

### Attendance

File:

- [lib/screen/Attendance.dart](./lib/screen/Attendance.dart)

Responsibilities:

- marks `Present`, `Mid Day`, `End Of Day`, `Week Off`, or `Absent`
- fetches assigned shops
- checks current location against shop coordinates
- captures attendance photo and uploads attendance

Distance rule:

- attendance is allowed when `current distance <= distanceAllowed`
- if distance is greater than `distanceAllowed`, the app shows `Too far from shop`

### Sales Entry

File:

- [lib/screen/SalesEntry.dart](./lib/screen/SalesEntry.dart)

Responsibilities:

- fetches user details, shop list, current location, and offline SKU master
- forces the user to select a valid shop before sales item entry
- captures up to three sales photos
- builds item rows dynamically
- uploads promoter sales data to the backend

Current behavior:

- the floating `+` button appears only after a shop is selected
- the old `Add First Item` button has been removed
- if the user is too far from the selected shop, sales entry is blocked with `Too far from shop`

### Sales Report

File:

- [lib/screen/SalesReport.dart](./lib/screen/SalesReport.dart)

Responsibilities:

- fetches sales reports for a date range
- shows total entries and total pieces
- displays individual report cards

### Selfie

File:

- [lib/screen/Selfie.dart](./lib/screen/Selfie.dart)

Responsibilities:

- validates location against shop distance
- opens the camera
- uploads selfie data to the backend

## 4. Technical Architecture

### App Entry

- [lib/main.dart](./lib/main.dart)

The app uses `MultiProvider` and starts on `SplashScreen`.

### State and Providers

Relevant files:

- [lib/provider/DropdownProvider.dart](./lib/provider/DropdownProvider.dart)
- [lib/view_model/auth_view_model.dart](./lib/view_model/auth_view_model.dart)

Notes:

- the codebase mixes provider-based state with direct helper/service calls
- much of the business logic is still screen-driven rather than fully isolated into view models

### Data and Network Layer

Relevant files:

- [lib/util/ApiHelper.dart](./lib/util/ApiHelper.dart)
- [lib/data/network/NetworkApiService.dart](./lib/data/network/NetworkApiService.dart)
- [lib/repository/Auth_repository.dart](./lib/repository/Auth_repository.dart)

Observed pattern:

- most screen flows use `ApiHelper.dart` directly
- there is also a repository/network abstraction, but it is not the primary path for most features

### Local Storage

Relevant files:

- [lib/util/Shared_pref.dart](./lib/util/Shared_pref.dart)
- [lib/util/DatabaseHelper.dart](./lib/util/DatabaseHelper.dart)
- [lib/config/Common.dart](./lib/config/Common.dart)

Usage:

- `SharedPreferences` stores login/session and app state
- SQLite stores SKU master data and saved sales payloads

Shared preference examples:

- `USER_ID`
- `PERSON_NAME`
- `GROUP`
- `ATT_STATUS`
- `DISTANCE_ALLOWED`
- `SHOP_ID`
- `IP_URL`

SQLite tables:

- `SKU`
- `SAVESALES`

## 5. Backend Configuration

Relevant file:

- [lib/res/app_url.dart](./lib/res/app_url.dart)

Configured base URL:

- `http://dsr.jivocanola.com/AndroidServer/`

Code also contains a backup/raw IP path used in login failover logic:

- `http://103.89.45.75:90/AndroidServer/`

Main backend routes referenced in code:

- `LoginSalesPerson3`
- `LoginSalesPerson`
- `Userdetails`
- `GetShopsDataver3`
- `GetShopsItemData`
- `GetPersonMonthlyItemReport`
- `SavePromoterSales2`
- `AddSalesPersonAttendance`
- `SelfieData`
- `SaveLocationsV2`
- `checkLatestAppVersion`

## 6. Permissions

Android manifest:

- [android/app/src/main/AndroidManifest.xml](./android/app/src/main/AndroidManifest.xml)

Declared permissions include:

- internet
- fine and coarse location
- background location
- camera
- foreground service
- network state
- phone state
- phone numbers

These are used for:

- location-based attendance and shop validation
- camera capture for attendance, sales photos, and selfies
- background location/service flows
- SIM or device-related identification

## 7. Offline and Cached Data

The app caches SKU data locally:

1. Dashboard calls `GetShopsItemData`
2. the response is stored into the local `SKU` table
3. Sales Entry reads from SQLite to populate item selection

This allows sales item selection to remain available even if the SKU list does not need to be fetched again immediately.

## 8. Distance Validation Rule

Shared helper:

- [lib/util/functionhelper.dart](./lib/util/functionhelper.dart)

Current rule:

- calculate distance using `Geolocator.distanceBetween`
- compare against `DISTANCE_ALLOWED`
- allow only when actual distance is less than or equal to allowed distance

Affected flows:

- Attendance
- Sales Entry
- Selfie

Failure message:

- `Too far from shop`

## 9. Dependencies Used

Important Flutter packages from [pubspec.yaml](./pubspec.yaml):

- `provider`
- `http`
- `shared_preferences`
- `sqflite`
- `geolocator`
- `geocoding`
- `location`
- `permission_handler`
- `image_picker`
- `fluttertoast`
- `flutter_progress_hud`
- `connectivity_plus`
- `battery_plus`
- `flutter_background_service`
- `flutter_local_notifications`
- `syncfusion_flutter_charts`
- `pie_chart`
- `fl_chart`
- `package_info_plus`
- `device_info_plus`
- `mobile_number`
- `flutter_sim_data`

## 10. Developer Setup

### Requirements

- Flutter SDK compatible with Dart `>=3.4.4 <4.0.0`
- Android Studio or VS Code with Flutter tooling
- Android device or emulator

### Install

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Analyze

```bash
flutter analyze
```

## 11. Project Structure

High-level structure:

- `lib/main.dart`: app bootstrap
- `lib/screen/`: UI screens
- `lib/util/`: helpers, shared prefs, DB, API helper
- `lib/models/`: API and local data models
- `lib/provider/`: provider state
- `lib/data/`: lower-level API/network abstractions
- `lib/res/`: backend URL config
- `assets/`: icons and images

## 12. Known Code Characteristics

This codebase currently has a few patterns worth knowing before extending it:

- some business logic lives directly inside screens
- network access is split between helper-style and repository-style code
- there are legacy and newer UI patterns mixed together
- backend routing is sensitive to exact host and endpoint selection
- there are existing analyzer lint warnings unrelated to the latest feature fixes

## 13. Recommended Next Improvements

If the project is going to keep growing, these would be strong next steps:

- centralize all API calls into one service layer
- move more screen logic into controllers or view models
- create a single environment/config strategy for base URLs
- document API request and response schemas
- add form validation and error-state widgets consistently
- add offline upload retry for saved sales rows in `SAVESALES`
- add tests for login, distance validation, and sales item creation

## 14. Reference Files

Useful entry points for future maintenance:

- [lib/main.dart](./lib/main.dart)
- [lib/screen/LoginScreen.dart](./lib/screen/LoginScreen.dart)
- [lib/screen/HomeScreen.dart](./lib/screen/HomeScreen.dart)
- [lib/screen/Dashboard.dart](./lib/screen/Dashboard.dart)
- [lib/screen/Attendance.dart](./lib/screen/Attendance.dart)
- [lib/screen/SalesEntry.dart](./lib/screen/SalesEntry.dart)
- [lib/screen/SalesReport.dart](./lib/screen/SalesReport.dart)
- [lib/screen/Selfie.dart](./lib/screen/Selfie.dart)
- [lib/util/ApiHelper.dart](./lib/util/ApiHelper.dart)
- [lib/util/functionhelper.dart](./lib/util/functionhelper.dart)
- [lib/util/DatabaseHelper.dart](./lib/util/DatabaseHelper.dart)
- [lib/util/Shared_pref.dart](./lib/util/Shared_pref.dart)
- [lib/res/app_url.dart](./lib/res/app_url.dart)

