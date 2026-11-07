# Privacy Policy for IronFlow

**Last Updated:** November 7, 2026  
**Effective Date:** November 7, 2026

At **IronFlow** ("we", "our", "us"), we are deeply committed to user privacy, data minimization, and transparent data processing. This Privacy Policy outlines what information we collect, how it is encrypted and processed, and how you control your personal health and workout data.

---

## 1. Information We Collect

### A. Information Stored Locally (Encrypted at Rest)
IronFlow is built on an **offline-first** architecture. The majority of your data resides locally on your device, protected by 256-bit AES encryption (`HiveAesCipher`) with hardware-backed encryption key storage:
- **Workout Logs**: Exercises, sets, reps, weight loads, RPE, duration, and completion timestamps.
- **Body & Anatomical Metrics**: Bodyweight, body fat percentage, circumference measurements, and manual soreness flags.
- **Nutrition Logs**: Meal entries, macro breakdown (protein, carbs, fat), calories, and hydration.
- **Personal Profile**: Display name, fitness goals, unit preferences (kg/lbs), and onboarding settings.

### B. Cloud Account & Sync Data (When Signed In)
If you create an authenticated cloud account:
- **Authentication**: Email address, user ID (UID), and profile picture URL managed via Firebase Authentication.
- **Cloud Database**: Synchronized workout and nutrition records stored in encrypted Google Cloud Firestore databases isolated strictly by your UID (`users/{uid}/*`).
- **Media Storage**: Progress photos and user avatar media stored in secure Firebase Cloud Storage buckets under `users/{uid}/*`.

### C. Technical & Telemetry Information (Opt-In Only)
- **Crash Reporting & Diagnostics**: Handled via Firebase Crashlytics. **Default is OFF (opt-in only)**.
- **Usage Analytics**: Screen navigation, feature engagement, and workout completion events via Firebase Analytics. **Default is OFF (opt-in only)**.
- **App Integrity**: Firebase App Check tokens (Play Integrity on Android, App Attest on iOS, reCAPTCHA Enterprise on Web) to prevent bot abuse and tampering.

---

## 2. How We Use Your Information

We use collected information solely to:
1. Provide core workout tracking, progressive overload analytics, and volume calculations.
2. Render anatomical recovery estimates on the 2D Vector Body Map.
3. Power personalized AI coaching suggestions (only when AI personalization consent is explicitly enabled).
4. Synchronize data across your authorized devices via encrypted outbox queues.

---

## 3. AI Coaching & Data Minimization

When interacting with IronFlow's AI Coach:
1. **Authenticated Proxy**: Prompts route through a private Google Cloud serverless proxy (`functions/aiGenerate`) that verifies your identity and App Check tokens. Direct developer keys are never embedded in client binaries.
2. **Consent Guard**: If you disable AI Personalization consent in Settings, the AI proxy receives only the text of your immediate chat message without your historical workout records, body measurements, or health profile.
3. **No Model Training**: Your personal conversations and health metrics are never sold, rented, or used to train third-party foundation models.
4. **Normalized FAQ Cache**: Frequent standard fitness questions (e.g., protein recommendations, warm-up protocols) are answered from a local zero-latency cache without sending requests to external APIs.

---

## 4. Data Sharing & Third Parties

We do **not** sell, rent, or trade your personal or health data. We share data only with verified cloud infrastructure providers necessary to operate the service:
- **Google Firebase / Google Cloud Platform**: Authentication, Firestore cloud sync, Storage, Cloud Functions, and Firebase App Check.
- **Google Gemini API**: Real-time natural language coaching (routed through private backend proxy).

---

## 5. Security Safeguards

- **At-Rest Encryption**: 256-bit AES encryption for all local Hive database boxes.
- **In-Transit Encryption**: All communication with Firebase and the AI proxy uses TLS 1.3 / HTTPS.
- **Strict Storage & Firestore Rules**: Multi-user isolation enforced server-side. Users can only read and write documents where `request.auth.uid == resource.data.userId`.
- **R8 Code Obfuscation**: Android release binaries are minified and obfuscated with ProGuard/R8 to prevent binary decompilation and tampering.

---

## 6. Your Rights & Data Ownership (GDPR & CCPA)

Regardless of your geographic location, you enjoy full control over your data:
- **Access & Export**: You may export your entire workout and nutrition history in portable format.
- **Revoke Consent**: Toggle Crashlytics, Analytics, or AI Personalization consent at any time in `Settings > Privacy & Telemetry`.
- **Right to Erasure (Account Purge)**: Tapping "Delete Account" in Settings initiates an immediate, permanent, and recursive deletion of:
  - Your Firebase Auth identity.
  - All personal Firestore subcollections (`workouts`, `meals`, `macro_targets`, `profile`, `ai_usage`).
  - All personal Cloud Storage media prefixes (`users/{uid}/*`).
  - All local encrypted databases on the active device.

---

## 7. Children's Privacy

IronFlow is not directed to children under 16 years of age. We do not knowingly collect personal information from children. If you become aware that a child has provided us with personal data, please contact us for immediate removal.

---

## 8. Changes to This Privacy Policy

We may update this Privacy Policy from time to time to reflect operational or legal updates. When significant changes occur, we will notify you through an in-app notice or updated effective date.

---

## 9. Contact Us

If you have questions regarding this Privacy Policy or wish to exercise your data rights:
- **Email**: `privacy@ironflow.app`
- **Data Protection Officer**: Designated client administrator.

