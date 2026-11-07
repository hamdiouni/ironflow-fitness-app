# IronFlow — Client Technical Handover Pack

**Package Name:** `progression_tracker` (Product: **IronFlow**)  
**Release Version:** `2.0.0+6` (Production Release)  
**Handover Date:** November 7, 2026  
**Commercial Model:** Complete Source Code Transfer (Single Client Ownership)

---

## 1. Executive Summary

**IronFlow** is a modern, production-hardened fitness and strength progression tracking platform built with Flutter. It delivers an offline-first mobile and web experience engineered specifically for serious lifters and fitness enthusiasts.

The codebase has undergone a complete **Production Readiness 360 & Hardening Protocol**, elevating code quality, security, performance, accessibility, and legal compliance to institutional standards:

- **100% Secret-Free**: Zero keys or secrets in source code, build output, or Git history. Protected by serverless Firebase Cloud Functions AI proxy (`functions/aiGenerate`) and Firebase App Check.
- **Offline-First & Encrypted**: All user workouts, nutrition, and body metrics are stored locally with 256-bit AES encryption (`HiveAesCipher`), synchronizing seamlessly with Google Cloud Firestore via an intelligent outbox queue.
- **Interactive 2D Vector Body Map**: High-performance, dependency-free anatomical muscle recovery engine rendering front and back silhouettes across 20 distinct muscular regions with sub-millisecond paint times.
- **Design System ("Soft & Layered")**: Cohesive visual identity across all screens and components using Direction 4 tokens, bundled OFL fonts (`Inter` and `Space Grotesk`), and zero raw hex codes.
- **100% Permissive Open Source**: All 227 third-party dependencies use permissive licenses (MIT, BSD, Apache 2.0, ISC) with zero GPL viral contamination, ensuring clean commercial intellectual property ownership.

---

## 2. Handover Documentation Directory

This `docs/CLIENT_PACK/` package contains everything required for your technical team to deploy, configure, customize, and operate IronFlow:

| Document | Description |
| :--- | :--- |
| **[`ARCHITECTURE_OVERVIEW.md`](file:///c:/Users/HP/OneDrive/Bureau/gym%20app/docs/CLIENT_PACK/ARCHITECTURE_OVERVIEW.md)** | Deep architectural blueprint covering Clean Architecture, Riverpod Notifier state management, offline sync, Body Map engine, and AI proxy routing. |
| **[`DEPLOYMENT_RUNBOOK.md`](file:///c:/Users/HP/OneDrive/Bureau/gym%20app/docs/CLIENT_PACK/DEPLOYMENT_RUNBOOK.md)** | Step-by-step production deployment guide for Firebase Hosting, Cloud Functions proxy, Firestore/Storage security rules, and App Check. |
| **[`KEY_ROTATION_AND_CREDENTIALS.md`](file:///c:/Users/HP/OneDrive/Bureau/gym%20app/docs/CLIENT_PACK/KEY_ROTATION_AND_CREDENTIALS.md)** | Zero-trust secrets management SOP, key rotation guides, keystore configuration, and emergency incident response. |
| **[`STORE_RELEASE_CHECKLIST.md`](file:///c:/Users/HP/OneDrive/Bureau/gym%20app/docs/CLIENT_PACK/STORE_RELEASE_CHECKLIST.md)** | Google Play Store, Web PWA, and Apple App Store launch checklist with exact store listing and data safety requirements. |
| **[`DEPENDENCY_LICENSES.csv`](file:///c:/Users/HP/OneDrive/Bureau/gym%20app/docs/CLIENT_PACK/DEPENDENCY_LICENSES.csv)** | Machine-readable audit of all 227 locked pub packages certifying 100% permissive commercial usability. |
| **[`docs/legal/`](file:///c:/Users/HP/OneDrive/Bureau/gym%20app/docs/legal/)** | Production-ready legal pack including Terms of Service, Privacy Policy, and Fitness & Medical Disclaimers. |
| **[`docs/setup/ENVIRONMENT_AND_FLAVORS.md`](file:///c:/Users/HP/OneDrive/Bureau/gym%20app/docs/setup/ENVIRONMENT_AND_FLAVORS.md)** | Day-1 developer onboarding and environment configuration guide. |

---

## 3. Technology Stack Summary

- **Framework**: Flutter 3.24+ / Dart 3.5+
- **State Management**: Flutter Riverpod 2.5+ (`Notifier`, `AsyncNotifier`, `FamilyNotifier`)
- **Local Persistence**: Hive (AES-256 encrypted via `flutter_secure_storage`)
- **Cloud Backend**: Google Firebase (Authentication, Cloud Firestore, Cloud Storage, Cloud Functions 2nd Gen, Hosting, App Check)
- **AI Intelligence**: Google Gemini 2.5 Flash via serverless authenticated proxy with local question cache
- **Vector Graphics**: Pure Flutter `CustomPainter` with normalized `ui.Path` coordinates
- **Platforms**: Android (Min SDK 24, Target SDK 34), Web PWA (CanvasKit/Wasm ready), iOS (Compile-ready)

---

## 4. Key Metrics & Quality Scorecard

```
========================================================================================
                      IronFlow Production Quality Metrics
========================================================================================
 Static Analysis:           0 issues found (0 errors, 0 warnings, 0 infos)
 Unit & Integration Tests:  955+ tests passing (100% pass rate)
 Code Coverage:             63.40% overall (76.14% domain layer, 81.25% shared)
 Web Gzipped JS Bundle:     1.60 MB (well below 2.5 MB performance budget)
 Recovery Calculation:      <5ms for 1-year workout history (3,000+ sets)
 Body Map Paint Latency:    <0.4ms per frame on mobile and web
 Local Data Security:       256-bit AES at-rest encryption on all health data
 Open Source Compliance:    100% permissive (zero restrictive/copyleft licenses)
========================================================================================
```

---

## 5. Contact & Support

This codebase is delivered with complete source ownership, test suites, and operational runbooks. For inquiries regarding this handover package:
- Technical Documentation: `docs/CLIENT_PACK/`
- Release Branch: `feat/prod-wave-6`

