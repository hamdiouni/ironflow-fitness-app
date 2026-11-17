# Store Data Disclosure Guide — IronFlow (Release 2.0.0)

> **IMPORTANT NOTICE FOR OWNER**  
> This document maps what the IronFlow codebase *actually* collects, stores, and shares to the official questionnaires of the Google Play Console (Data Safety section) and Apple App Store Connect (App Privacy section).

---

## Part 1: Google Play Console — Data Safety Form

### 1. Data Collection & Sharing Overview
- **Does your app collect or share any of the required user data types?**  
  **YES** (Personal Info, Health & Fitness, Photos & Videos [ephemeral], App Info & Performance, Device/Other IDs).
- **Is all of the user data collected by your app encrypted in transit?**  
  **YES** (All external communication uses TLS 1.3 / HTTPS).
- **Do you provide a way for users to request that their data be deleted?**  
  **YES** (Both in-app via Settings > Privacy, and via external Delete Account URL).

### 2. Mandatory Deletion Fields (Release 2.0.0 Compliance)
- **Account Deletion URL:**  
  Declare the web link hosted by the app owner (e.g. `https://ironflow.app/delete-account` or `https://ironflow.app/privacy#delete`).  
  *Rule:* The webpage must clearly display the app name ("IronFlow"), explain how user data is purged, and provide a direct request form or mechanism.
- **In-App Deletion Path:**  
  Path: `Settings -> Privacy Settings -> Delete Account and All Data`.

### 3. High-Risk Permissions Disclosure
- **Alarms & Reminders (`SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`):**  
  **NOT REQUESTED / NOT USED**. The rest timer lock-screen countdown runs natively via the Android System UI Notification Chronometer (`usesChronometer: true`, `chronometerCountDown: true`, `category: stopwatch`) under ADR-004. It requires zero exact alarm declarations and consumes 0% background battery.

### 4. Detailed Data Types Breakdown

| Google Data Type | Sub-Type | Collected? | Shared? | Purpose | Ephemeral? | Required / Optional? |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Personal Info** | Email Address | Yes | No | Account management, authentication | No | Required (if using cloud account) |
| **Personal Info** | User IDs | Yes | No | Account management, session security | No | Required |
| **Health and Fitness** | Fitness Info (workouts, sets, reps, weight, RPE, 1RM, exercises, supersets) | Yes (On-device encrypted) | No* (*Sent only to AI Proxy if user opts in) | App functionality, analytics / progress tracking | No | Optional |
| **Health and Fitness** | Health Info (body weight, circumference, nutrition logs, caloric goals) | Yes (On-device encrypted) | No | App functionality, nutrition tracking | No | Optional |
| **Photos and Videos** | Photos (Progress photos) | Yes (On-device sandboxed / Firebase Storage) | No | App functionality | No | Optional |
| **Photos and Videos** | Photos (Meal estimation photo) | Yes (In-memory capture) | Transmitted to AI Proxy | Meal macro estimation (Gemini Vision) | **YES (Ephemeral)** — Never stored to cloud storage or database; discarded immediately after analysis | Optional |
| **App Info & Performance** | Crash logs (Firebase Crashlytics) | Yes (If enabled) | Shared to Google Firebase | Analytics, diagnostics, app stability | No | Optional (Default OFF, toggleable in Privacy Settings) |
| **App Info & Performance** | Diagnostics / Usage metrics (Firebase Analytics) | Yes (If enabled) | Shared to Google Firebase | Analytics, feature usage | No | Optional (Default OFF, toggleable in Privacy Settings) |
| **Device or other IDs** | Device/Instance ID | Yes | Shared to Firebase | Authentication, push messaging, crash diagnostics | No | Required for Firebase services |

---

## Part 2: Apple App Store Connect — App Privacy (Nutrition Labels)

Under App Store Guidelines, specify:

### 1. Data Used to Track You
- **NONE**: IronFlow does not track users across apps and websites owned by other companies, and does not use IDFA or third-party ad networks.

### 2. Data Linked to You
- **Contact Info:** Email Address (used for Account Functionality).
- **Identifiers:** User ID (used for Account Functionality).

### 3. Data Not Linked to You (Diagnostics & Analytics)
- **Diagnostics:** Crash Data, Performance Data (used for Analytics & Product Improvement; can be opted out in app settings).
- **Usage Data:** Product Interaction (screen views, feature taps; opt-out in settings).

### 4. Health & Fitness Data
- **Health & Fitness:** Workouts, biometrics, nutrition.
- Stored on-device by default with 256-bit AES encryption.
- Linked to user ID locally; never shared with data brokers or advertising networks.

### 5. Photos & Camera Access
- **Camera / Photo Library:** Used solely for user-selected profile pictures, progress photos, and ephemeral quick meal estimation (under ADR-003).
- Ephemeral meal images are processed in-memory, transferred over TLS directly to the serverless AI proxy, and immediately discarded without persistence.

---

## Part 3: Third-Party SDK & Data Disclosures

1. **Firebase Authentication:**
   - Handles email/password and federated authentication.
   - Operates under Google Cloud security and privacy terms.
2. **Firebase Analytics & Crashlytics:**
   - Only active when user toggle in Settings > Privacy is set to ON.
   - Anonymized diagnostic events only.
3. **AI Proxy (`functions/aiGenerate`):**
   - Transmits prompt context strictly when user explicitly grants AI consent.
   - Zero API keys embedded in client release binaries.
   - Enforces per-user durable rate limits and responsible safety thresholds (`BLOCK_MEDIUM_AND_ABOVE`).
4. **Open Data Sources (ODbL / Public Domain):**
   - **Open Food Facts**: Nutritional database licensed under the Open Database License (ODbL) v1.0.
   - **USDA FoodData Central**: Public domain nutritional information.
   - Attributions surfaced in-app via `Settings > Privacy > Data Attributions & Open Database Notices` and `Settings > About`.
