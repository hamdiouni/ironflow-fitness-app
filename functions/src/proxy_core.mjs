import crypto from 'node:crypto';

/**
 * Allowed Gemini model identifiers (AI-01 / ADR-001).
 * Prevents clients from requesting expensive or unapproved models.
 */
export const ALLOWED_MODELS = new Set([
  'gemini-2.5-flash',
  'gemini-2.0-flash',
  'gemini-1.5-flash',
]);

export const DEFAULT_MODEL = 'gemini-2.5-flash';
export const MAX_PROMPT_CHARS = 8000;
export const MAX_TOTAL_PAYLOAD_CHARS = 24000;
export const MAX_MESSAGES_COUNT = 20;
export const MAX_OUTPUT_TOKENS_LIMIT = 4096;
export const DEFAULT_DAILY_QUOTA = 50;
export const DEFAULT_TIMEOUT_MS = 25000;

/**
 * Hashes a user ID with SHA-256 (truncated to 12 hex chars) so operational logs
 * can correlate abuse without storing raw UIDs or PII (SEC-07 / AI-01).
 */
export function hashUidForLogs(uid) {
  return crypto.createHash('sha256').update(String(uid)).digest('hex').slice(0, 12);
}

/**
 * Computes UTC date key `YYYY-MM-DD` and seconds remaining until next UTC midnight.
 */
export function getUtcQuotaWindow(now = new Date()) {
  const dateKey = now.toISOString().slice(0, 10);
  const nextMidnight = Date.UTC(
    now.getUTCFullYear(),
    now.getUTCMonth(),
    now.getUTCDate() + 1,
    0,
    0,
    0,
  );
  const retryAfterSeconds = Math.max(
    1,
    Math.ceil((nextMidnight - now.getTime()) / 1000),
  );
  return { dateKey, retryAfterSeconds };
}

/**
 * Validates and normalizes the incoming AI proxy request body.
 * Enforces model allow-list, message count bounds, and character size limits.
 */
export function validateProxyPayload(body) {
  if (!body || typeof body !== 'object') {
    return {
      ok: false,
      status: 400,
      code: 'INVALID_PAYLOAD',
      message: 'Request body must be a JSON object.',
    };
  }

  const requestedModel =
    typeof body.model === 'string' && body.model.trim().length > 0
      ? body.model.trim()
      : DEFAULT_MODEL;

  if (!ALLOWED_MODELS.has(requestedModel)) {
    return {
      ok: false,
      status: 400,
      code: 'MODEL_NOT_ALLOWED',
      message: `Model '${requestedModel}' is not in the approved allow-list.`,
    };
  }

  const contents = Array.isArray(body.contents) ? body.contents : null;
  if (!contents || contents.length === 0) {
    return {
      ok: false,
      status: 400,
      code: 'EMPTY_CONTENTS',
      message: 'Request must include a non-empty contents array.',
    };
  }

  if (contents.length > MAX_MESSAGES_COUNT) {
    return {
      ok: false,
      status: 400,
      code: 'PAYLOAD_TOO_LARGE',
      message: `Conversation history exceeds maximum of ${MAX_MESSAGES_COUNT} messages.`,
    };
  }

  let totalChars = 0;
  for (const item of contents) {
    if (!item || typeof item !== 'object' || !Array.isArray(item.parts)) {
      return {
        ok: false,
        status: 400,
        code: 'INVALID_CONTENTS_FORMAT',
        message: 'Each content item must contain a parts array.',
      };
    }
    for (const part of item.parts) {
      const text = typeof part?.text === 'string' ? part.text : '';
      if (text.length > MAX_PROMPT_CHARS) {
        return {
          ok: false,
          status: 400,
          code: 'PAYLOAD_TOO_LARGE',
          message: `Individual message exceeds ${MAX_PROMPT_CHARS} character limit.`,
        };
      }
      totalChars += text.length;
    }
  }

  if (totalChars === 0) {
    return {
      ok: false,
      status: 400,
      code: 'EMPTY_CONTENTS',
      message: 'Message text cannot be empty.',
    };
  }

  if (totalChars > MAX_TOTAL_PAYLOAD_CHARS) {
    return {
      ok: false,
      status: 400,
      code: 'PAYLOAD_TOO_LARGE',
      message: `Total payload exceeds ${MAX_TOTAL_PAYLOAD_CHARS} character limit.`,
    };
  }

  const rawGenConfig =
    body.generationConfig && typeof body.generationConfig === 'object'
      ? body.generationConfig
      : {};
  const temperature =
    typeof rawGenConfig.temperature === 'number'
      ? Math.min(Math.max(rawGenConfig.temperature, 0.0), 1.5)
      : 0.7;
  const maxOutputTokens =
    typeof rawGenConfig.maxOutputTokens === 'number'
      ? Math.min(Math.max(Math.trunc(rawGenConfig.maxOutputTokens), 64), MAX_OUTPUT_TOKENS_LIMIT)
      : 2048;

  return {
    ok: true,
    model: requestedModel,
    stream: Boolean(body.stream),
    totalChars,
    geminiPayload: {
      contents,
      generationConfig: {
        temperature,
        maxOutputTokens,
        topP: 0.95,
        topK: 40,
      },
    },
  };
}

/**
 * Scrubs any accidental secret or key pattern from error strings before
 * logging or returning errors.
 */
export function sanitizeErrorString(raw) {
  const text = String(raw ?? 'Unknown error');
  return text
    .replace(/AIza[0-9A-Za-z\-_]{10,}/g, '[REDACTED_KEY]')
    .replace(/key=[^&\s]+/gi, 'key=[REDACTED]');
}

/**
 * Core handler for the IronFlow AI Proxy (ADR-001).
 *
 * Dependencies are injected so the handler can be unit-tested deterministically
 * and wired to Firebase Admin SDK in production.
 */
export async function handleAiProxyRequest({
  method,
  headers,
  body,
  verifyIdToken,
  verifyAppCheckToken,
  enforceAppCheck = false,
  checkAndIncrementDailyQuota,
  dailyQuotaLimit = DEFAULT_DAILY_QUOTA,
  geminiApiKey,
  fetchImpl = globalThis.fetch,
  timeoutMs = DEFAULT_TIMEOUT_MS,
  logger = console.log,
  now = new Date(),
}) {
  const startedAt = Date.now();

  if (method !== 'POST') {
    return {
      status: 405,
      headers: { 'Content-Type': 'application/json' },
      body: {
        error: {
          code: 'METHOD_NOT_ALLOWED',
          message: 'Only POST requests are supported.',
        },
      },
    };
  }

  // 1. Verify Firebase Auth Bearer ID token
  const authHeader = headers?.authorization || headers?.Authorization || '';
  const match = /^Bearer\s+(.+)$/i.exec(String(authHeader).trim());
  if (!match || !match[1]) {
    return {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
      body: {
        error: {
          code: 'UNAUTHENTICATED',
          message: 'Missing Firebase Auth Bearer ID token.',
        },
      },
    };
  }

  let uid;
  try {
    const decoded = await verifyIdToken(match[1].trim());
    uid = decoded?.uid;
    if (!uid) {
      throw new Error('Missing uid in token');
    }
  } catch (_) {
    return {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
      body: {
        error: {
          code: 'UNAUTHENTICATED',
          message: 'Invalid or expired Firebase Auth ID token.',
        },
      },
    };
  }

  // 2. Verify Firebase App Check token (staged monitor vs enforce mode — Wave 1 Step 7)
  const appCheckToken =
    headers?.['x-firebase-appcheck'] || headers?.['X-Firebase-AppCheck'] || '';
  let appCheckVerified = false;
  if (appCheckToken) {
    try {
      await verifyAppCheckToken(String(appCheckToken).trim());
      appCheckVerified = true;
    } catch (_) {
      appCheckVerified = false;
    }
  }

  if (!appCheckVerified && enforceAppCheck) {
    logger({
      event: 'ai_proxy_app_check_rejected',
      uidHash: hashUidForLogs(uid),
      enforced: true,
    });
    return {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
      body: {
        error: {
          code: 'APP_CHECK_FAILED',
          message: 'Firebase App Check attestation required.',
        },
      },
    };
  }

  // 3. Validate payload size, message bounds, and model allow-list
  const validation = validateProxyPayload(body);
  if (!validation.ok) {
    return {
      status: validation.status,
      headers: { 'Content-Type': 'application/json' },
      body: {
        error: {
          code: validation.code,
          message: validation.message,
        },
      },
    };
  }

  // 4. Enforce durable per-user daily quota in Firestore (`users/{uid}/ai_usage/{yyyy-mm-dd}`)
  const { dateKey, retryAfterSeconds } = getUtcQuotaWindow(now);
  const quotaResult = await checkAndIncrementDailyQuota({
    uid,
    dateKey,
    dailyLimit: dailyQuotaLimit,
    inputChars: validation.totalChars,
  });

  if (!quotaResult.allowed) {
    logger({
      event: 'ai_proxy_quota_exceeded',
      uidHash: hashUidForLogs(uid),
      dateKey,
      requestCount: quotaResult.requestCount,
      dailyLimit: dailyQuotaLimit,
    });
    return {
      status: 429,
      headers: {
        'Content-Type': 'application/json',
        'Retry-After': String(retryAfterSeconds),
      },
      body: {
        error: {
          code: 'RATE_LIMIT_EXCEEDED',
          message: 'Daily AI coaching limit reached. Quota resets at midnight UTC.',
          retryAfterSeconds,
        },
      },
    };
  }

  // 5. Ensure server-side Gemini API key is configured
  if (!geminiApiKey || typeof geminiApiKey !== 'string' || !geminiApiKey.trim()) {
    return {
      status: 503,
      headers: { 'Content-Type': 'application/json' },
      body: {
        error: {
          code: 'PROXY_MISCONFIGURED',
          message: 'AI service is temporarily unavailable.',
        },
      },
    };
  }

  // 6. Call upstream Gemini API with explicit AbortController timeout
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  const endpointAction = validation.stream
    ? 'streamGenerateContent?alt=sse'
    : 'generateContent';
  const upstreamUrl =
    `https://generativelanguage.googleapis.com/v1beta/models/${validation.model}:${endpointAction}`;

  try {
    const upstreamResponse = await fetchImpl(upstreamUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': geminiApiKey.trim(),
      },
      body: JSON.stringify(validation.geminiPayload),
      signal: controller.signal,
    });

    const latencyMs = Date.now() - startedAt;

    if (!upstreamResponse.ok) {
      logger({
        event: 'ai_proxy_upstream_error',
        uidHash: hashUidForLogs(uid),
        model: validation.model,
        upstreamStatus: upstreamResponse.status,
        appCheckVerified,
        latencyMs,
      });

      const mappedStatus = upstreamResponse.status === 429 ? 429 : 502;
      return {
        status: mappedStatus,
        headers: { 'Content-Type': 'application/json' },
        body: {
          error: {
            code: mappedStatus === 429 ? 'UPSTREAM_RATE_LIMIT' : 'UPSTREAM_ERROR',
            message:
                mappedStatus === 429
                  ? 'AI service is busy. Please wait a moment and try again.'
                  : 'Failed to generate AI response from upstream provider.',
          },
        },
      };
    }

    // Operational log without PII or prompt content
    logger({
      event: 'ai_proxy_success',
      uidHash: hashUidForLogs(uid),
      model: validation.model,
      stream: validation.stream,
      inputChars: validation.totalChars,
      appCheckVerified,
      latencyMs,
    });

    if (validation.stream) {
      const sseText = await upstreamResponse.text();
      return {
        status: 200,
        headers: {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          Connection: 'keep-alive',
        },
        rawBody: sseText,
      };
    }

    const data = await upstreamResponse.json();
    return {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
      body: data,
    };
  } catch (err) {
    const isAbort =
      err?.name === 'AbortError' ||
      String(err?.message || '').toLowerCase().includes('abort');
    logger({
      event: isAbort ? 'ai_proxy_timeout' : 'ai_proxy_network_error',
      uidHash: hashUidForLogs(uid),
      model: validation.model,
      error: sanitizeErrorString(err?.message || err),
      latencyMs: Date.now() - startedAt,
    });
    return {
      status: isAbort ? 504 : 502,
      headers: { 'Content-Type': 'application/json' },
      body: {
        error: {
          code: isAbort ? 'GATEWAY_TIMEOUT' : 'UPSTREAM_NETWORK_ERROR',
          message: isAbort
            ? 'AI response timed out. Please try a shorter question.'
            : 'Unable to reach AI provider.',
        },
      },
    };
  } finally {
    clearTimeout(timer);
  }
}

