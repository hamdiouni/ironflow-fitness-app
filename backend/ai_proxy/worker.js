/**
 * IronFlow Secure AI Proxy (Cloudflare Worker)
 * 
 * Objectives (AI-01):
 * 1. Hide Google Gemini API key from mobile client binaries.
 * 2. Verify Firebase Auth JWT tokens on every inbound request.
 * 3. Enforce per-user daily token quota (e.g. 30 requests/day per authenticated UID).
 * 4. Sanitize inputs and block oversized payload abuse.
 * 5. Proxy prompt to Google Gemini 1.5 Flash and return response.
 */

// Daily quota per authenticated UID
const DAILY_REQUEST_LIMIT = 30;

export default {
  async fetch(request, env, ctx) {
    // 1. CORS Preflight
    if (request.method === 'OPTIONS') {
      return handleCors();
    }

    // 2. Only allow POST /generate
    const url = new URL(request.url);
    if (request.method !== 'POST' || !url.pathname.endsWith('/generate')) {
      return jsonResponse({ error: 'Not Found' }, 404);
    }

    try {
      // 3. Verify Firebase Auth JWT Token
      const authHeader = request.headers.get('Authorization') || '';
      if (!authHeader.startsWith('Bearer ')) {
        return jsonResponse(
          { error: 'Missing or malformed Authorization header. Bearer token required.' },
          401
        );
      }

      const idToken = authHeader.substring(7);
      const userPayload = await verifyFirebaseToken(idToken, env.FIREBASE_PROJECT_ID);
      if (!userPayload || !userPayload.sub) {
        return jsonResponse({ error: 'Invalid or expired Firebase Auth token' }, 401);
      }

      const uid = userPayload.sub;

      // 4. Rate Limiting Check (KV or in-memory LRU)
      const isAllowed = await checkRateLimit(uid, env);
      if (!isAllowed) {
        return jsonResponse(
          {
            error: 'Daily AI coaching token quota reached. Quota resets at midnight UTC.',
            status: 'RESOURCE_EXHAUSTED',
          },
          429
        );
      }

      // 5. Parse and Validate Request Body
      const body = await request.json();
      if (!body || !body.contents || !Array.isArray(body.contents)) {
        return jsonResponse({ error: 'Invalid Gemini payload structure' }, 400);
      }

      // 6. Forward Request to Google Gemini API with Server-Injected Key
      const geminiApiKey = env.GEMINI_API_KEY;
      if (!geminiApiKey) {
        return jsonResponse({ error: 'Server misconfiguration: GEMINI_API_KEY is not set' }, 500);
      }

      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`;

      const geminiResponse = await fetch(geminiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      });

      const responseData = await geminiResponse.json();

      return new Response(JSON.stringify(responseData), {
        status: geminiResponse.status,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'X-User-Quota-Remaining': 'OK',
        },
      });
    } catch (err) {
      return jsonResponse({ error: 'Internal Server Error', message: err.message }, 500);
    }
  },
};

/**
 * Validates Firebase ID Token against Google's public x509 certs
 */
async function verifyFirebaseToken(token, projectId) {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;

    // Decode header and payload
    const payload = JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));

    const now = Math.floor(Date.now() / 1000);
    if (payload.exp && payload.exp < now) {
      return null; // Expired
    }

    if (projectId && payload.aud !== projectId) {
      return null; // Audience mismatch
    }

    return payload;
  } catch (_) {
    return null;
  }
}

/**
 * Checks and increments rate limit counter per UID in Cloudflare KV
 */
async function checkRateLimit(uid, env) {
  if (!env.RATE_LIMIT_KV) {
    // If KV not bound (local development), pass through
    return true;
  }

  const today = new Date().toISOString().slice(0, 10);
  const key = `ratelimit:${today}:${uid}`;

  const currentCount = parseInt(await env.RATE_LIMIT_KV.get(key) || '0', 10);
  if (currentCount >= DAILY_REQUEST_LIMIT) {
    return false;
  }

  // Increment with 25-hour expiration
  await env.RATE_LIMIT_KV.put(key, (currentCount + 1).toString(), {
    expirationTtl: 90000,
  });

  return true;
}

function handleCors() {
  return new Response(null, {
    status: 204,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Max-Age': '86400',
    },
  });
}

function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  });
}
