# Store Data Disclosure Guide — IronFlow (Release 1.2)

> **IMPORTANT NOTICE FOR OWNER**  
> This document maps what the IronFlow codebase *actually* collects, stores, and shares to the official questionnaires of the Google Play Console (Data Safety section) and Apple App Store Connect (App Privacy section).

---

## Part 1: Google Play Console — Data Safety Form

### 1. Data Collection & Sharing Overview
- **Does your app collect or share any of the required user data types?**  
  **YES** (Personal Info, Health & Fitness, App Info & Performance, Device/Other IDs).
- **Is all of the user data collected by your app encrypted in transit?**  
  **YES** (All external communication uses TLS 1.3 / HTTPS).
- **Do you provide a way for users to request that their data be deleted?**  
  **YES** (Both in-app via Settings > Privacy, and via external Delete Account URL).

### 2. Mandatory Deletion Fields (Release 1.2 Compliance)
- **Account Deletion URL:**  
  Declare the web link hosted by the app owner (e.g. `https://ironflow.app/delete-account` or `https://ironflow.app/privacy#delete`).  
  *Rule:* The webpage must clearly display the app name ("IronFlow"), explain how user data is purged, and provide a direct request form or mechanism.
- **In-App Deletion Path:**  
  Path: `Settings -> Privacy Settings -> Delete Account and All Data`.

### 3. Detailed Data Types Breakdown

| Google Data Type | Sub-Type | Collected? | Shared? | Purpose | Ephemeral? | Required / Optional? |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Personal Info** | Email Address | Yes | No | Account management, authentication | No | Required |
| **Personal Info** | User IDs | Yes | No | Account management, session security | No | Required |
| **Health and Fitness** | Fitness Info (workouts, sets, reps, weight, RPE, 1RM, exercises) | Yes (On-device) | No* (*Sent only to AI Proxy if user opts in) | App functionality, analytics / progress tracking | No | Optional |
| **Health and Fitness** | Health Info (body weight, circumference, nutrition logs, caloric goals) | Yes (On-device) | No | App functionality, nutrition tracking | No | Optional |
| **Photos and Videos** | Photos (Progress photos) | Yes (On-device sandboxed) | No | App functionality | No | Optional |
| **App Info & Performance** | Crash logs (Firebase Crashlytics) | Yes (If enabled) | Shared to Google Firebase | Analytics, diagnostics, app stability | No | Optional (Toggleable in Privacy Settings) |
| **App Info & Performance** | Diagnostics / Usage metrics (Firebase Analytics) | Yes (If enabled) | Shared to Google Firebase | Analytics, feature usage | No | Optional (Toggleable in Privacy Settings) |
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
- Stored on-device by default.
- Linked to user ID locally; never shared with data brokers or advertising networks.

---

## Part 3: Third-Party SDK Disclosures

1. **Firebase Authentication:**
   - Handles email/password and federated authentication.
   - Operates under Google Cloud security and privacy terms.
2. **Firebase Analytics & Crashlytics:**
   - Only active when user toggle in Settings > Privacy is set to ON.
   - Anonymized diagnostic events only.
3. **YouTube Player Embed (iframe):**
   - Loads ONLY upon direct user tap on the video card.
   - Privacy-enhanced mode requested where supported.
   - No video content or user data is cached or extracted.
4. **AI Proxy (When configured):**
   - Transmits prompt context strictly when user explicitly grants AI consent.
   - No API keys embedded in client release binaries.
   - No persistent user identifiers transmitted.
