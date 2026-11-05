import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import {
  handleAiProxyRequest,
  MAX_PROMPT_CHARS,
  MAX_MESSAGES_COUNT,
} from '../src/proxy_core.mjs';

function makeValidBody(overrides = {}) {
  return {
    model: 'gemini-2.5-flash',
    contents: [
      {
        role: 'user',
        parts: [{ text: 'Suggest a 3-day upper/lower split.' }],
      },
    ],
    generationConfig: {
      temperature: 0.7,
      maxOutputTokens: 512,
    },
    ...overrides,
  };
}

describe('IronFlow Cloud Functions AI Proxy (Wave 1 Step 6 — ADR-001)', () => {
  it('rejects non-POST requests with 405 and missing Bearer token with 401', async () => {
    const getRes = await handleAiProxyRequest({
      method: 'GET',
      headers: {},
      body: {},
    });
    assert.equal(getRes.status, 405);

    const noAuthRes = await handleAiProxyRequest({
      method: 'POST',
      headers: {},
      body: makeValidBody(),
      verifyIdToken: async () => ({ uid: 'u1' }),
    });
    assert.equal(noAuthRes.status, 401);
    assert.equal(noAuthRes.body.error.code, 'UNAUTHENTICATED');
  });

  it('supports staged App Check (monitor mode allows missing token; enforce mode rejects with 401)', async () => {
    const quotaStore = new Map();
    const checkQuota = async ({ uid, dateKey, dailyLimit }) => {
      const k = `${uid}:${dateKey}`;
      const c = quotaStore.get(k) ?? 0;
      if (c >= dailyLimit) return { allowed: false, requestCount: c };
      quotaStore.set(k, c + 1);
      return { allowed: true, requestCount: c + 1 };
    };

    // Staged monitor mode (enforceAppCheck: false): succeeds even without App Check token
    const monitorRes = await handleAiProxyRequest({
      method: 'POST',
      headers: { authorization: 'Bearer valid-id-token' },
      body: makeValidBody(),
      verifyIdToken: async () => ({ uid: 'user_alice' }),
      verifyAppCheckToken: async () => {
        throw new Error('Missing App Check');
      },
      enforceAppCheck: false,
      checkAndIncrementDailyQuota: checkQuota,
      geminiApiKey: 'test-server-secret',
      fetchImpl: async () => ({
        ok: true,
        status: 200,
        json: async () => ({
          candidates: [{ content: { parts: [{ text: 'Workout plan ready' }] } }],
        }),
      }),
      logger: () => {},
    });
    assert.equal(monitorRes.status, 200);

    // Enforced mode (enforceAppCheck: true): rejects missing/invalid App Check token with 401
    const enforceRes = await handleAiProxyRequest({
      method: 'POST',
      headers: { authorization: 'Bearer valid-id-token' },
      body: makeValidBody(),
      verifyIdToken: async () => ({ uid: 'user_alice' }),
      verifyAppCheckToken: async () => {
        throw new Error('Invalid App Check');
      },
      enforceAppCheck: true,
      checkAndIncrementDailyQuota: checkQuota,
      geminiApiKey: 'test-server-secret',
      logger: () => {},
    });
    assert.equal(enforceRes.status, 401);
    assert.equal(enforceRes.body.error.code, 'APP_CHECK_FAILED');
  });

  it('enforces model allow-list and input size limits', async () => {
    const baseOpts = {
      method: 'POST',
      headers: { authorization: 'Bearer valid' },
      verifyIdToken: async () => ({ uid: 'u1' }),
      verifyAppCheckToken: async () => ({}),
      enforceAppCheck: false,
      checkAndIncrementDailyQuota: async () => ({ allowed: true, requestCount: 1 }),
      geminiApiKey: 'secret',
      logger: () => {},
    };

    // Unapproved model rejected
    const badModel = await handleAiProxyRequest({
      ...baseOpts,
      body: makeValidBody({ model: 'gemini-ultra-expensive' }),
    });
    assert.equal(badModel.status, 400);
    assert.equal(badModel.body.error.code, 'MODEL_NOT_ALLOWED');

    // Oversized message rejected
    const hugePrompt = await handleAiProxyRequest({
      ...baseOpts,
      body: makeValidBody({
        contents: [
          { role: 'user', parts: [{ text: 'x'.repeat(MAX_PROMPT_CHARS + 1) }] },
        ],
      }),
    });
    assert.equal(hugePrompt.status, 400);
    assert.equal(hugePrompt.body.error.code, 'PAYLOAD_TOO_LARGE');

    // Too many messages rejected
    const tooManyMessages = await handleAiProxyRequest({
      ...baseOpts,
      body: makeValidBody({
        contents: Array.from({ length: MAX_MESSAGES_COUNT + 1 }, () => ({
          role: 'user',
          parts: [{ text: 'hi' }],
        })),
      }),
    });
    assert.equal(tooManyMessages.status, 400);
    assert.equal(tooManyMessages.body.error.code, 'PAYLOAD_TOO_LARGE');
  });

  it('enforces durable per-user daily quota and returns 429 with Retry-After', async () => {
    let count = 0;
    const opts = {
      method: 'POST',
      headers: { authorization: 'Bearer valid' },
      body: makeValidBody(),
      verifyIdToken: async () => ({ uid: 'user_quota_test' }),
      verifyAppCheckToken: async () => ({}),
      enforceAppCheck: false,
      dailyQuotaLimit: 2,
      checkAndIncrementDailyQuota: async ({ dailyLimit }) => {
        if (count >= dailyLimit) {
          return { allowed: false, requestCount: count };
        }
        count += 1;
        return { allowed: true, requestCount: count };
      },
      geminiApiKey: 'secret',
      fetchImpl: async () => ({
        ok: true,
        status: 200,
        json: async () => ({
          candidates: [{ content: { parts: [{ text: 'OK' }] } }],
        }),
      }),
      logger: () => {},
    };

    assert.equal((await handleAiProxyRequest(opts)).status, 200);
    assert.equal((await handleAiProxyRequest(opts)).status, 200);
    const third = await handleAiProxyRequest(opts);
    assert.equal(third.status, 429);
    assert.equal(third.body.error.code, 'RATE_LIMIT_EXCEEDED');
    assert.ok(Number(third.headers['Retry-After']) > 0);
  });

  it('maps upstream timeouts to 504, never leaks secrets, and logs zero prompt PII', async () => {
    const logs = [];
    const secretPrompt = 'SENSITIVE_HEALTH_NOTE_192837';

    const timeoutRes = await handleAiProxyRequest({
      method: 'POST',
      headers: { authorization: 'Bearer valid' },
      body: makeValidBody({
        contents: [{ role: 'user', parts: [{ text: secretPrompt }] }],
      }),
      verifyIdToken: async () => ({ uid: 'raw_user_id_abc' }),
      verifyAppCheckToken: async () => ({}),
      enforceAppCheck: false,
      checkAndIncrementDailyQuota: async () => ({ allowed: true, requestCount: 1 }),
      geminiApiKey: 'server-secret-value',
      timeoutMs: 10,
      fetchImpl: async (_url, { signal }) =>
        new Promise((_resolve, reject) => {
          signal.addEventListener('abort', () => {
            const err = new Error('The operation was aborted');
            err.name = 'AbortError';
            reject(err);
          });
        }),
      logger: (entry) => logs.push(entry),
    });

    assert.equal(timeoutRes.status, 504);
    assert.equal(timeoutRes.body.error.code, 'GATEWAY_TIMEOUT');

    // Verify logs never contain the raw UID, the secret prompt, or the server key
    const serializedLogs = JSON.stringify(logs);
    assert.equal(serializedLogs.includes(secretPrompt), false);
    assert.equal(serializedLogs.includes('raw_user_id_abc'), false);
    assert.equal(serializedLogs.includes('server-secret-value'), false);
  });

  it('supports SSE streaming when stream: true is requested', async () => {
    const streamRes = await handleAiProxyRequest({
      method: 'POST',
      headers: { authorization: 'Bearer valid' },
      body: makeValidBody({ stream: true }),
      verifyIdToken: async () => ({ uid: 'u1' }),
      verifyAppCheckToken: async () => ({}),
      enforceAppCheck: false,
      checkAndIncrementDailyQuota: async () => ({ allowed: true, requestCount: 1 }),
      geminiApiKey: 'secret',
      fetchImpl: async (url) => {
        assert.ok(url.includes('streamGenerateContent?alt=sse'));
        return {
          ok: true,
          status: 200,
          text: async () => 'data: {"candidates":[{"content":{"parts":[{"text":"Chunk 1"}]}}]}\n\n',
        };
      },
      logger: () => {},
    });

    assert.equal(streamRes.status, 200);
    assert.equal(streamRes.headers['Content-Type'], 'text/event-stream');
    assert.ok(streamRes.rawBody.includes('Chunk 1'));
  });
});

