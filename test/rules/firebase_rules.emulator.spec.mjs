// Firebase Emulator Suite security rules tests (Firestore + Storage).
// Run with:
//   firebase emulators:exec --only firestore,storage "node --test test/rules/firebase_rules.emulator.spec.mjs"
import { readFileSync } from 'node:fs';
import { describe, it, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteDoc } from 'firebase/firestore';
import { ref, uploadBytes, deleteObject, getBytes } from 'firebase/storage';

const PROJECT_ID = 'demo-ironflow-rules-test';

describe('IronFlow Firestore & Storage Security Rules (Wave 1)', () => {
  let testEnv;

  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: readFileSync('firestore.rules', 'utf8'),
      },
      storage: {
        rules: readFileSync('storage.rules', 'utf8'),
      },
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
    await testEnv.clearStorage();
  });

  it('denies unauthenticated reads/writes on flat collections and user tree', async () => {
    const anonDb = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(anonDb, 'workouts/w1')));
    await assertFails(
      setDoc(doc(anonDb, 'workouts/w1'), { userId: 'u1', name: 'Push' }),
    );
    await assertFails(getDoc(doc(anonDb, 'users/u1')));
  });

  it('allows owner create/read/update/delete on flat collections and denies cross-user hijack (BKD-01)', async () => {
    const aliceDb = testEnv.authenticatedContext('alice').firestore();
    const bobDb = testEnv.authenticatedContext('bob').firestore();

    for (const col of ['workouts', 'programs', 'nutrition', 'body_progress']) {
      const refId = `${col}/rec_1`;
      await assertSucceeds(
        setDoc(doc(aliceDb, refId), {
          userId: 'alice',
          name: 'Valid Record',
          notes: 'Short note',
        }),
      );

      // Bob cannot read Alice's doc
      await assertFails(getDoc(doc(bobDb, refId)));

      // BKD-01 regression check: Bob cannot hijack Alice's doc via update
      await assertFails(
        updateDoc(doc(bobDb, refId), {
          userId: 'bob',
          name: 'Hijacked by Bob',
        }),
      );

      // Bob cannot delete Alice's doc
      await assertFails(deleteDoc(doc(bobDb, refId)));

      // Alice can update her own doc and tombstone it
      await assertSucceeds(
        updateDoc(doc(aliceDb, refId), {
          userId: 'alice',
          deletedAt: '2026-11-05T10:00:00.000Z',
        }),
      );
      await assertSucceeds(deleteDoc(doc(aliceDb, refId)));
    }
  });

  it('enforces field bounds and blocks client writes to users/{uid}/ai_usage (BKD-04)', async () => {
    const aliceDb = testEnv.authenticatedContext('alice').firestore();

    // Oversized notes (> 10000 chars) must be denied
    await assertFails(
      setDoc(doc(aliceDb, 'workouts/oversized'), {
        userId: 'alice',
        notes: 'x'.repeat(10001),
      }),
    );

    // Client cannot write or reset their own AI quota document
    await assertFails(
      setDoc(doc(aliceDb, 'users/alice/ai_usage/2026-11-05'), {
        requestCount: 0,
      }),
    );
  });

  it('allows owner file upload and delete in Storage and denies cross-user access (BKD-02)', async () => {
    const aliceStorage = testEnv.authenticatedContext('alice').storage();
    const bobStorage = testEnv.authenticatedContext('bob').storage();

    const avatarRef = ref(aliceStorage, 'users/alice/profile/avatar.png');
    await assertSucceeds(
      uploadBytes(avatarRef, new Uint8Array([1, 2, 3, 4]), {
        contentType: 'image/png',
      }),
    );

    // Bob cannot read or delete Alice's avatar
    const bobAvatarRef = ref(bobStorage, 'users/alice/profile/avatar.png');
    await assertFails(getBytes(bobAvatarRef));
    await assertFails(deleteObject(bobAvatarRef));

    // BKD-02 regression check: Alice CAN delete her own avatar (request.resource == null)
    await assertSucceeds(deleteObject(avatarRef));
  });
});

