# Privacy Policy Draft — IronFlow (Release 1.2)

> **IMPORTANT NOTICE FOR OWNER / LEGAL COUNSEL**  
> This document is an engineer's factual draft detailing the data the IronFlow codebase *actually* collects, stores, processes, and transmits. It is provided for your review and does not constitute formal legal advice. Please adapt this draft into your finalized privacy policy before publishing to the Apple App Store and Google Play Console.

**Effective Date:** Draft for Release 1.2 (October 2026)  
**Application Name:** IronFlow  
**Developer / Controller:** [Insert Developer / Organization Name]  
**Contact:** [Insert Support / Privacy Contact Email]  

---

## 1. Core Architecture & Philosophy: Local Data Sovereignty

IronFlow is architected with a **local-first** design. Your training history, nutrition logs, and biometric telemetry are stored directly on your personal device by default. You retain complete sovereignty over your data, including the right to export full archives (JSON/CSV), roll back restores, and permanently delete your data or your account at any time.

---

## 2. What Data IronFlow Actually Collects and Stores

### A. Training & Exercise Telemetry (Stored On-Device)
- **Workouts:** Timestamps, workout duration, exercises performed, sets, repetitions, weight loads, Rate of Perceived Exertion (RPE / RIR), set categories (Normal, Warm-up, Drop, Failure), notes, and computed estimated 1RM personal records.
- **Programs & Routines:** Custom workout routines, split templates, and target loads.

### B. Nutrition & Macro Telemetry (Stored On-Device)
- **Meals & Daily Logs:** Food items consumed, serving sizes, macronutrients (calories, protein, carbohydrates, fats), micronutrients, and meal timestamps.
- **Nutritional Targets:** Caloric and macronutrient goals configured during onboarding or settings.

### C. Body Metrics & Telemetry (Stored On-Device)
- **Biometric Logs:** Body weight entries, body fat percentage, circumference measurements (chest, waist, arms, thighs, etc.), and timestamps.
- **Progress Media:** Local progress photos saved exclusively in the app's sandboxed private storage directory.

### D. User Account & Preferences (Stored On-Device & Secure Storage)
- **Authentication Credentials & Tokens:** User ID (`uid`), email address, auth tokens, and session refresh tokens encrypted in platform-level secure storage (`flutter_secure_storage` via Android Keystore / iOS Keychain).
- **Profile Configuration:** Fitness experience level (Beginner, Intermediate, Advanced), training venue (Gym vs. Home), unit preferences (kg/lbs), display options, and safety backup snapshots.
- **Safety Snapshots:** Temporary local backups created immediately before a restore operation to prevent accidental data loss (limited to 3 snapshots, stored strictly in app-private storage).

---

## 3. What Data IronFlow Transmits to External Services

IronFlow only communicates with external services under the following specific circumstances:

### A. Firebase Authentication (Google Cloud)
- **Data Transmitted:** Email address, password (hashed client-side by Firebase SDK), and OAuth provider tokens (e.g., Google Sign-In or Apple Sign-In).
- **Purpose:** Securely authenticating your account and maintaining your login session.
- **Storage:** Managed securely by Firebase Authentication in accordance with Google Cloud security standards.

### B. Firebase Analytics & Crashlytics (Optional — User Controlled)
- **Data Transmitted:** Pseudonymous usage telemetry, screen navigation events, feature engagement counts, crash stack traces, and device OS version.
- **User Control:** You may disable Analytics and Crash Reporting at any time via **Settings > Privacy**. When disabled, event dispatching is completely ceased.
- **Strict Prohibition:** IronFlow never transmits names, emails, raw training weights, or health metrics to analytics pipelines.

### C. Generative AI Coaching (Optional — Opt-In Only)
- **Data Transmitted:** Workout summaries, nutritional totals, and user prompts required to generate training recommendations.
- **Explicit Consent:** AI features require explicit opt-in consent (**Settings > Privacy > AI Personalization Consent**). If consent is disabled, zero training or nutrition data is dispatched to AI proxies.
- **Transport Security:** Release builds route requests through a hardened proxy without embedding client API keys. No persistent user identity or credentials are included in AI payloads.

### D. YouTube Exercise Demonstrations (Official Embed — On-Demand Only)
- **No Background Loading:** IronFlow never loads YouTube webviews, players, or network requests in the background. Video embeds load **only when you explicitly tap the "Play Video" card** on an exercise detail screen.
- **Privacy Domain:** YouTube embeds utilize privacy-enhanced mode (`youtube-nocookie.com`) where supported by the player controller.
- **Fallback:** Complete step-by-step instructions, muscle targeting, and coaching cues remain 100% accessible locally even without loading videos or internet access.

---

## 4. Account and Data Deletion (Store Compliance)

In accordance with **Apple App Store Guideline 5.1.1(v)** and the **Google Play User Data Policy**, IronFlow provides complete, transparent account and data deletion mechanisms.

### In-App Deletion Options (Settings > Privacy)
1. **Delete Local Data (Keep Account):**
   - Wipes all workout logs, nutrition history, biometric measurements, custom routines, local progress photos, AI chat histories, and safety snapshots from the current device.
   - Retains your login credentials so you can log in on another device or start fresh.
2. **Delete Account & All Data (Permanent Destruction):**
   - Requires re-authentication (password or provider verification) to ensure authorization.
   - Purges any existing remote records via the `RemoteDataPurger` pipeline.
   - Deletes the authentication user record from Firebase Authentication.
   - Completely eradicates all local databases, Hive boxes, sandboxed media, scheduled notifications, and encrypted secure storage tokens.
   - Automatically finishes any interrupted wipe if network or process terminates during the operation.

### Web-Accessible Deletion Request Link (Google Play Requirement)
If you have uninstalled the app and wish to delete your account and associated data without reinstalling, submit an account deletion request via our web portal:
`[Insert Public Deletion Request URL declared in Google Play Console]`

---

## 5. Security & Data Retention

- All local databases and files reside within your device's operating system sandboxed storage.
- Communication with external endpoints (Firebase, AI Proxy, YouTube) is conducted exclusively over TLS 1.3 / HTTPS.
- When an account is deleted, all user-scoped data is destroyed immediately. IronFlow does not maintain shadow profiles or sell user data to data brokers.

---

## 6. Updates to This Policy

We may update this policy to reflect changes in our data architecture or regulatory requirements. We encourage users to periodically review this document in **Settings > Privacy > Privacy Policy**.
