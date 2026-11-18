// Firebase Emulator Suite security rules tests (Firestore + Storage).
// Run from repo root with:
//   firebase emulators:exec --project demo-ironflow-rules-test --only firestore,storage "npm --prefix functions run test:rules"
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, it, before, after, beforeEach } from 'node:test';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteDoc } from 'firebase/firestore';
import { ref, uploadBytes, deleteObject, getBytes } from 'firebase/storage';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const REPO_ROOT = resolve(__dirname, '../..');
const PROJECT_ID = 'demo-ironflow-rules-test';

describe('IronFlow Firestore & Storage Security Rules (Wave 1)', () => {
  let testEnv;

  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: readFileSync(resolve(REPO_ROOT, 'firestore.rules'), 'utf8'),
      },
      storage: {
        rules: readFileSync(resolve(REPO_ROOT, 'storage.rules'), 'utf8'),
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

  it('allows owner JSON backup upload/read/delete <= 10MB and rejects anonymous, cross-user, wrong type, and oversize writes', async () => {
    const aliceStorage = testEnv.authenticatedContext('alice').storage();
    const bobStorage = testEnv.authenticatedContext('bob').storage();
    const anonStorage = testEnv.unauthenticatedContext().storage();

    const aliceBackupRef = ref(aliceStorage, 'users/alice/backups/backup_1.json');
    const jsonBytes = new TextEncoder().encode('{"version":1,"workouts":[]}');

    // Owner create & read succeed
    await assertSucceeds(
      uploadBytes(aliceBackupRef, jsonBytes, {
        contentType: 'application/json',
      }),
    );
    await assertSucceeds(getBytes(aliceBackupRef));

    // Other user & anonymous denied read/write/delete
    const bobBackupRef = ref(bobStorage, 'users/alice/backups/backup_1.json');
    const anonBackupRef = ref(anonStorage, 'users/alice/backups/backup_1.json');
    await assertFails(getBytes(bobBackupRef));
    await assertFails(
      uploadBytes(bobBackupRef, jsonBytes, { contentType: 'application/json' }),
    );
    await assertFails(deleteObject(bobBackupRef));
    await assertFails(getBytes(anonBackupRef));
    await assertFails(
      uploadBytes(anonBackupRef, jsonBytes, { contentType: 'application/json' }),
    );

    // Wrong content type denied
    const wrongTypeRef = ref(aliceStorage, 'users/alice/backups/not_json.txt');
    await assertFails(
      uploadBytes(wrongTypeRef, new Uint8Array([65, 66, 67]), {
        contentType: 'text/plain',
      }),
    );

    // Oversized (> 10MB) backup denied
    const oversizeRef = ref(aliceStorage, 'users/alice/backups/oversize.json');
    await assertFails(
      uploadBytes(oversizeRef, new Uint8Array(10 * 1024 * 1024 + 1), {
        contentType: 'application/json',
      }),
    );

    // Owner delete succeeds
    await assertSucceeds(deleteObject(aliceBackupRef));
  });

  it('allows public reads on app_config/feature_flags while blocking non-admin writes (Wave 2.5 ADR-005)', async () => {
    const anonDb = testEnv.unauthenticatedContext().firestore();
    const aliceDb = testEnv.authenticatedContext('alice').firestore();
    const adminDb = testEnv
      .authenticatedContext('operator', { admin: true })
      .firestore();

    await assertSucceeds(
      setDoc(doc(adminDb, 'app_config/feature_flags'), {
        kill_ai_coach: false,
        kill_cloud_sync: false,
        maintenance_mode: false,
      }),
    );

    // Public read (unauthenticated + authenticated) succeeds
    await assertSucceeds(getDoc(doc(anonDb, 'app_config/feature_flags')));
    await assertSucceeds(getDoc(doc(aliceDb, 'app_config/feature_flags')));

    // Normal client and anonymous writes must be denied
    await assertFails(
      setDoc(doc(aliceDb, 'app_config/feature_flags'), {
        kill_ai_coach: true,
      }),
    );
    await assertFails(
      updateDoc(doc(anonDb, 'app_config/feature_flags'), {
        maintenance_mode: true,
      }),
    );
  });
});
