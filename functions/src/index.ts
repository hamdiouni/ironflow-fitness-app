import { onRequest } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { initializeApp, getApps } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getAppCheck } from 'firebase-admin/app-check';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
// @ts-expect-error Pure ESM core module shared with Node test runner
import { handleAiProxyRequest, DEFAULT_DAILY_QUOTA } from './proxy_core.mjs';

if (getApps().length === 0) {
  initializeApp();
}

const geminiApiKeySecret = defineSecret('GEMINI_API_KEY');

/**
 * IronFlow Authenticated AI Proxy (Cloud Functions 2nd Gen — ADR-001).
 *
 * Security controls:
 * 1. Verifies Firebase Auth ID token (`Authorization: Bearer <idToken>`).
 * 2. Verifies Firebase App Check token (`X-Firebase-AppCheck`), supporting
 *    staged monitor mode (`ENFORCE_APP_CHECK=false`) and strict enforcement
 *    (`ENFORCE_APP_CHECK=true`).
 * 3. Enforces atomic per-user daily quotas in Firestore (`users/{uid}/ai_usage/{yyyy-mm-dd}`).
 * 4. Enforces model allow-list (`gemini-2.5-flash`, `gemini-2.0-flash`, `gemini-1.5-flash`)
 *    and strict input size limits.
 * 5. Never logs prompts, responses, or personal health data.
 */
export const aiGenerate = onRequest(
  {
    region: 'us-central1',
    timeoutSeconds: 30,
    memory: '256MiB',
    cors: true,
    secrets: [geminiApiKeySecret],
  },
  async (req, res) => {
    const enforceAppCheck =
      String(process.env.ENFORCE_APP_CHECK ?? 'false').toLowerCase() === 'true';
    const dailyQuotaLimit = Number.parseInt(
      process.env.AI_DAILY_QUOTA ?? String(DEFAULT_DAILY_QUOTA),
      10,
    );

    const db = getFirestore();

    const result = await handleAiProxyRequest({
      method: req.method,
      headers: req.headers,
      body: req.body,
      verifyIdToken: (idToken: string) => getAuth().verifyIdToken(idToken),
      verifyAppCheckToken: (token: string) => getAppCheck().verifyToken(token),
      enforceAppCheck,
      dailyQuotaLimit: Number.isFinite(dailyQuotaLimit)
        ? dailyQuotaLimit
        : DEFAULT_DAILY_QUOTA,
      geminiApiKey: geminiApiKeySecret.value(),
      checkAndIncrementDailyQuota: async ({
        uid,
        dateKey,
        dailyLimit,
        inputChars,
      }: {
        uid: string;
        dateKey: string;
        dailyLimit: number;
        inputChars: number;
      }) => {
        const usageRef = db
          .collection('users')
          .doc(uid)
          .collection('ai_usage')
          .doc(dateKey);

        return db.runTransaction(async (tx) => {
          const snap = await tx.get(usageRef);
          const currentCount = snap.exists
            ? Number(snap.data()?.requestCount ?? 0)
            : 0;
          if (currentCount >= dailyLimit) {
            return { allowed: false, requestCount: currentCount };
          }
          const nextCount = currentCount + 1;
          tx.set(
            usageRef,
            {
              userId: uid,
              dateKey,
              requestCount: nextCount,
              totalInputChars: FieldValue.increment(inputChars),
              updatedAt: FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
          return { allowed: true, requestCount: nextCount };
        });
      },
      refundDailyQuota: async ({
        uid,
        dateKey,
        inputChars,
      }: {
        uid: string;
        dateKey: string;
        inputChars: number;
      }) => {
        const usageRef = db
          .collection('users')
          .doc(uid)
          .collection('ai_usage')
          .doc(dateKey);

        await db.runTransaction(async (tx) => {
          const snap = await tx.get(usageRef);
          if (!snap.exists) return;
          const data = snap.data() ?? {};
          const currentCount = Number(data.requestCount ?? 0);
          const currentChars = Number(data.totalInputChars ?? 0);
          tx.set(
            usageRef,
            {
              requestCount: Math.max(0, currentCount - 1),
              totalInputChars: Math.max(0, currentChars - inputChars),
              updatedAt: FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
        });
      },
      logger: (entry: Record<string, unknown>) => {
        console.log(JSON.stringify(entry));
      },
      onStreamStart: ({
        status,
        headers,
      }: {
        status: number;
        headers: Record<string, string>;
      }) => {
        res.status(status);
        for (const [k, v] of Object.entries(headers ?? {})) {
          res.setHeader(k, String(v));
        }
        if (typeof res.flushHeaders === 'function') {
          res.flushHeaders();
        }
      },
      onStreamChunk: (chunk: string) => {
        res.write(chunk);
      },
      onStreamEnd: () => {
        res.end();
      },
    });

    if (result.streamed) {
      return;
    }

    for (const [k, v] of Object.entries(result.headers ?? {})) {
      res.setHeader(k, String(v));
    }

    if (result.rawBody !== undefined) {
      res.status(result.status).send(result.rawBody);
      return;
    }

    res.status(result.status).json(result.body);
  },
);

