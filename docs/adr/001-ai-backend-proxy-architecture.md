# ADR-001: Authenticated AI Backend Proxy Architecture

- **Status**: Proposed (Awaiting Owner Approval before Wave 1.2)
- **Date**: 2026-11-05
- **Wave**: Wave 1.2

## 1. Problem
`GeminiAIService` rightly blocks direct API keys in profile/release builds (`AppConfig.allowDirectAiApiKeys = kDebugMode && _directAiKeysOptIn`), expecting an authenticated backend proxy at `AI_PROXY_URL`. However, no proxy server or serverless function exists in the repository yet, leaving AI coaching non-functional in release builds.

## 2. Options Considered

| Option | Description | Pros | Cons / Cost |
| :--- | :--- | :--- | :--- |
| **Option A: Firebase Cloud Functions (2nd Gen, Node.js/TypeScript, backed by Cloud Run)** | Deploy an HTTPS function (`onRequest`) in `functions/` that verifies Firebase Auth ID token + App Check token, checks/increments per-user daily quota in Firestore (`users/{uid}/ai_usage/{date}`), calls Gemini API using a Google Secret Manager key, and streams SSE chunks back. | Zero separate infrastructure to manage; native Firebase Auth & App Check verification via `firebase-admin`; scales to zero. | **Requires Firebase Blaze (pay-as-you-go) plan**. Free tier includes 2M invocations/month; beyond free tier ~$0.40/M invocations + Gemini Flash token cost (~$0.075–$0.15 per 1M input tokens). |
| **Option B: Standalone Cloud Run Container (Dart / Node.js / Go)** | Deploy a stateless container to Google Cloud Run with Secret Manager and Firestore Admin SDK. | Portable across clouds; full control over HTTP/2 streaming and timeouts. | Requires Docker pipeline + Google Cloud billing enabled (Blaze equivalent). |
| **Option C: Owner's Existing Custom API Server (FastAPI / Node / Go on VPS)** | Host `/v1/ai/chat` on the owner's existing backend server using `firebase-admin` SDK to verify JWTs. | Fixed monthly VPS cost ($5–$10/mo); no Firebase Blaze requirement if Firestore stays on Spark free tier. | Owner must maintain server uptime, TLS, and deployment. |

## 3. Recommendation
- **Option A (Firebase Cloud Functions 2nd Gen)** if the project uses Firebase Blaze (with a hard billing budget alert set in GCP), **or Option C** if the Owner prefers a fixed-cost custom API without enabling Firebase Blaze.
- **No new client runtime package required** (`http: ^1.2.2` already in `pubspec.yaml`).
- **License**: `firebase-admin` / `firebase-functions` (Apache-2.0 / MIT).
- **Size Impact on App**: **0 KB** (server-side only; client uses `AiTransport` over `http`).
- **Rollback**: Flip remote feature flag `ai_proxy_enabled = false` to fall back to `OfflineHeuristicTransport` (`AIInsightsEngineImpl`).
