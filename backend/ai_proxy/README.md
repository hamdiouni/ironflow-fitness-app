# IronFlow Secure AI Proxy Architecture (`AI-01`)

## Overview

The **IronFlow Secure AI Proxy** decouples client applications from the Google Gemini API, resolving the critical store security and financial vulnerability where raw API keys were compiled directly into mobile application binaries.

```
┌─────────────────────────────────┐
│     IronFlow Flutter Client     │
│   (No Gemini API key compiled)  │
└────────────────┬────────────────┘
                 │
                 │ 1. POST /generate
                 │    Authorization: Bearer <Firebase_ID_Token>
                 │    Body: { contents, generationConfig }
                 ▼
┌─────────────────────────────────┐
│     Cloudflare Worker Proxy     │
│   - Validates Firebase JWT      │
│   - Enforces 30 req/day quota   │
│   - Injects server GEMINI_KEY   │
└────────────────┬────────────────┘
                 │
                 │ 2. POST /v1beta/models/gemini-1.5-flash:generateContent
                 │    ?key=<SERVER_SIDE_GEMINI_KEY>
                 ▼
┌─────────────────────────────────┐
│     Google Gemini 1.5 Flash     │
└─────────────────────────────────┘
```

---

## Key Security & Financial Guarantees

1. **Zero Client-Exposed Credentials**:
   - The Flutter mobile client only knows the proxy URL (e.g. `https://ai.ironflow.app/generate`).
   - If an attacker decompiles the APK or IPA, no API keys exist to extract.

2. **Per-User Authenticated Rate Limiting**:
   - Inbound requests must supply a valid, unexpired Firebase Auth JWT.
   - Cloudflare KV tracks request counts per `uid` (key: `ratelimit:YYYY-MM-DD:<uid>`).
   - Requests exceeding 30 requests/day receive an immediate HTTP 429 (`RESOURCE_EXHAUSTED`).

3. **Cost & Quota Predictability**:
   - Gemini 1.5 Flash costs approximately $0.075 per million input tokens.
   - At 30 requests/day/user with an average of 1,000 tokens per prompt, monthly cost per daily active user is less than **$0.07/month**.

---

## Deployment Instructions

### 1. Prerequisites
- [Node.js](https://nodejs.org/) v18+
- Cloudflare account (Free plan is completely sufficient for up to 100,000 requests/day)

### 2. Install & Authenticate Wrangler
```bash
cd backend/ai_proxy
npx wrangler login
```

### 3. Set Up Rate Limit KV Namespace
```bash
npx wrangler kv:namespace create RATE_LIMIT_KV
```
Copy the returned namespace ID into `wrangler.toml`.

### 4. Inject Server Gemini API Key Secret
```bash
npx wrangler secret put GEMINI_API_KEY
```

### 5. Deploy
```bash
npx wrangler deploy
```

### 6. Connect Flutter Client
Add the deployed worker URL to your `.env` or build arguments:
```bash
flutter build apk --dart-define=AI_PROXY_URL=https://your-worker-subdomain.workers.dev
```
