# App Store & Google Play Data Safety Declarations

This document provides exact, verified answers for Apple App Store Privacy and Google Play Data Safety forms for **IronFlow** (`progression_tracker`).

---

## 1. Google Play Store: Data Safety Section

### Overview
- **Data Collection**: Yes (minimal, strictly for app functionality and optional opt-in telemetry).
- **Data Sharing**: **No**. Data is NEVER shared with third-party advertising or broker networks.
- **Data Encryption in Transit**: **Yes**. All network traffic is encrypted via HTTPS / TLS 1.3.
- **Data Encryption at Rest**: **Yes**. Sensitive local health and user records are encrypted via Hive AES-256 (`HiveAesCipher`) with hardware-backed keys.
- **Account Deletion Request**: **Yes**. Users can delete their account and associated cloud data at any time in-app (`SettingsScreen` $\rightarrow$ `Delete Account`) or via a standard web URL.

### Data Types Collected

| Data Category | Data Type | Collected? | Shared? | Ephemeral? | Required / Optional | Purpose |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| **Personal Info** | Name / Email | Yes | No | No | Required (if signing up) | Account management, authentication |
| **Personal Info** | User IDs | Yes | No | No | Required | Account management, scoping cloud data |
| **Health and Fitness** | Fitness Info (workouts, lifts, reps, volume) | Yes | No | No | Required | Core app functionality |
| **Health and Fitness** | Nutrition Info (meals, macros, calories) | Yes | No | No | Required | Core app functionality |
| **Photos and Videos** | Photos (progress photos, avatar) | Yes | No | No | Optional | Progress tracking (stored locally or user Storage) |
| **App Info and Performance** | Crash logs | Optional | No | No | Optional (Consent-gated) | Analytics / diagnostics (default: OFF) |
| **App Info and Performance** | Diagnostics / Perf | Optional | No | No | Optional (Consent-gated) | Analytics / diagnostics (default: OFF) |
| **Device or other IDs** | App Check / FCM Token | Yes | No | No | Required | Abuse prevention (App Check), notifications |

---

## 2. Apple App Store: App Privacy (Nutrition Label)

### Overview
- **Tracking**: **No**. IronFlow does NOT track users across apps and websites owned by other companies. (`NSPrivacyTracking` = `false`).
- **Third-Party Advertising**: **No**. Zero advertising SDKs are installed or bundled.

### Data Linked to the User
The following data types may be collected and linked to the user's account identity (`NSPrivacyCollectedDataTypeLinked` = `true`):

1. **Fitness & Health**:
   - Workouts, routines, sets, reps, weight logs, and muscle recovery records.
   - Purpose: **App Functionality** (`NSPrivacyCollectedDataTypePurposeAppFunctionality`).
2. **Contact Info**:
   - Email address and display name (when account is created).
   - Purpose: **App Functionality**.
3. **User Content**:
   - Progress photos (if the user takes or selects photos).
   - Purpose: **App Functionality**.
4. **Diagnostics (Optional)**:
   - Crash logs and performance metrics (ONLY if user explicitly opts in on the Telemetry Consent screen).
   - Purpose: **Analytics & Diagnostics**.

### Apple Privacy Manifest (`PrivacyInfo.xcprivacy`)
Declared in `ios/Runner/PrivacyInfo.xcprivacy`:
- `NSPrivacyTracking`: `false`
- `NSPrivacyCollectedDataTypes`:
  - `NSPrivacyCollectedDataTypeFitness` (Purpose: `AppFunctionality`, Linked: `true`, Tracking: `false`)
- `NSPrivacyAccessedAPITypes`:
  - `NSPrivacyAccessedAPICategoryUserDefaults` (`CA92.1` — app preferences)
  - `NSPrivacyAccessedAPICategoryFileTimestamp` (`C617.1` — local database maintenance)
  - `NSPrivacyAccessedAPICategorySystemBootTime` (`35F9.1` — rest timer calculation)
  - `NSPrivacyAccessedAPICategoryDiskSpace` (`E174.1` — local cache management)

