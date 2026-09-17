# Cloud Sync - Quick Start Guide

## 🚀 Get Sync Running in 15 Minutes

### Step 1: Install Dependencies (2 min)

```bash
flutter pub get
```

### Step 2: Generate Freezed Code (3 min)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates code for:
- `sync_action.freezed.dart`
- `sync_action.g.dart`
- `sync_status.freezed.dart`
- `sync_status.g.dart`

### Step 3: Update Firestore Security Rules (2 min)

In Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /workouts/{workoutId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /programs/{programId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /nutrition/{logId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /body_progress/{progressId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /sync_metadata/{metadataId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

Click **"Publish"**

### Step 4: Add Sync Indicator to Home Screen (3 min)

Open `lib/features/workout/presentation/screens/home_screen.dart`:

```dart
import '../../../sync/presentation/widgets/sync_indicator.dart';

// In AppBar
AppBar(
  title: const Text('IronFlow'),
  actions: [
    CompactSyncIndicator(), // Add this
    // ... other actions
  ],
)
```

### Step 5: Test Sync (5 min)

```bash
flutter run -d chrome
```

**Test Steps**:
1. ✅ Sign in to your account
2. ✅ Create a workout
3. ✅ Watch sync indicator (should show syncing animation)
4. ✅ Check Firebase Console → Firestore → workouts collection
5. ✅ Verify workout appears in Firestore
6. ✅ Open app on another device/browser
7. ✅ Verify workout syncs across devices

---

## 🎯 What You Get

### Automatic Sync
- ✅ Workouts sync after save
- ✅ Programs sync after update
- ✅ Nutrition logs sync after entry
- ✅ Body progress syncs after measurement

### Offline Support
- ✅ Works offline (saves to local Hive)
- ✅ Queues actions for later sync
- ✅ Auto-syncs when back online
- ✅ No data loss

### Visual Feedback
- ✅ Sync indicator in app bar
- ✅ Shows syncing animation
- ✅ Displays pending/failed count
- ✅ Shows last sync time

### Smart Retry
- ✅ Auto-retries failed syncs (max 3 times)
- ✅ Exponential backoff
- ✅ Manual retry option

---

## 📊 Sync Indicator States

| State | Icon | Color | Meaning |
|-------|------|-------|---------|
| Syncing | ⟳ (animated) | Blue | Currently syncing |
| Synced | ☁️✓ | Green | All data synced |
| Pending | ☁️↑ | Orange | Actions waiting to sync |
| Failed | ⚠️ | Red | Some actions failed |
| Offline | ☁️✗ | Grey | No internet connection |

---

## 🔧 Advanced Usage

### Manual Sync Trigger

```dart
// Add a button to trigger sync
ElevatedButton(
  onPressed: () => ref.read(syncTriggerProvider)(),
  child: const Text('Sync Now'),
)
```

### Watch Sync Status

```dart
final syncStatus = ref.watch(syncStatusStreamProvider);

syncStatus.when(
  data: (status) {
    if (status.isSyncing) {
      return Text('Syncing...');
    }
    return Text('Synced ${timeago.format(status.lastSyncTime!)}');
  },
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
)
```

### Retry Failed Actions

```dart
if (syncStatus.failedActions > 0) {
  TextButton(
    onPressed: () => ref.read(retryFailedActionsProvider)(),
    child: Text('Retry ${syncStatus.failedActions} Failed'),
  );
}
```

### Check Online Status

```dart
final isOnline = ref.watch(isOnlineProvider).valueOrNull ?? false;

if (!isOnline) {
  Container(
    color: Colors.orange,
    padding: EdgeInsets.all(8),
    child: Text('Offline - Changes will sync when online'),
  );
}
```

---

## 🐛 Troubleshooting

### Sync not working?

**Check 1: Firebase configured?**
```bash
# Verify firebase_options.dart has real credentials
cat lib/firebase_options.dart
```

**Check 2: User authenticated?**
```dart
// In your code
final user = ref.watch(currentUserProvider).valueOrNull;
print('User ID: ${user?.id}'); // Should not be null
```

**Check 3: Internet connection?**
```dart
final isOnline = ref.watch(isOnlineProvider).valueOrNull;
print('Online: $isOnline'); // Should be true
```

**Check 4: Firestore rules?**
- Go to Firebase Console → Firestore → Rules
- Verify rules are published
- Check for permission denied errors

**Check 5: Console errors?**
```bash
# Look for errors in console
flutter run -d chrome --verbose
```

### Actions stuck in pending?

```dart
// Check pending count
final status = await ref.read(syncStatusProvider.future);
print('Pending: ${status.pendingActions}');
print('Failed: ${status.failedActions}');

// Retry failed actions
ref.read(retryFailedActionsProvider)();
```

### Data not syncing across devices?

1. Sign out and sign in again
2. Trigger manual sync
3. Check Firestore Console for data
4. Verify userId matches in Firestore documents

---

## 📈 Monitoring

### Check Sync Status

```dart
// Get current status
final status = await ref.read(syncStatusProvider.future);

print('Is Syncing: ${status.isSyncing}');
print('Pending: ${status.pendingActions}');
print('Failed: ${status.failedActions}');
print('Last Sync: ${status.lastSyncTime}');
```

### View Firestore Data

1. Go to Firebase Console
2. Click "Firestore Database"
3. Browse collections:
   - `workouts` - All synced workouts
   - `programs` - All synced programs
   - `nutrition` - All nutrition logs
   - `body_progress` - All body measurements
   - `sync_metadata` - Sync timestamps

---

## ✅ Success Checklist

- [ ] Dependencies installed (`flutter pub get`)
- [ ] Freezed code generated (`build_runner`)
- [ ] Firestore rules updated
- [ ] Sync indicator added to UI
- [ ] Tested workout sync
- [ ] Verified data in Firestore
- [ ] Tested offline mode
- [ ] Tested multi-device sync

---

## 🎉 You're Done!

Your app now has:
- ✅ Automatic cloud sync
- ✅ Offline support
- ✅ Multi-device sync
- ✅ Visual sync indicators
- ✅ Smart retry logic
- ✅ No data loss

**Next Steps**:
1. Test on multiple devices
2. Monitor sync performance
3. Add sync to other screens
4. Implement batch operations (optional)
5. Add analytics tracking (optional)

---

## 📚 Documentation

- **Full Documentation**: `CLOUD_SYNC_IMPLEMENTATION.md`
- **Architecture**: See "Architecture" section in full docs
- **API Reference**: See "Components" section in full docs
- **Troubleshooting**: See "Troubleshooting" section in full docs

---

**Questions?** Check `CLOUD_SYNC_IMPLEMENTATION.md` for detailed information.
