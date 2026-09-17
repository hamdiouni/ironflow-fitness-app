# IronFlow - Setup Checklist ✓

## Pre-Flight Check

- [ ] I have Flutter installed
- [ ] I have Chrome browser installed
- [ ] I'm in the project directory (`gym app`)
- [ ] I've read `RUN_THESE_COMMANDS.txt`

## Setup Steps

### Step 1: Dependencies
- [ ] Run: `flutter pub get`
- [ ] Wait for it to complete
- [ ] No errors shown

### Step 2: Code Generation (TAKES 5-10 MINUTES!)
- [ ] Run: `dart run build_runner build --delete-conflicting-outputs`
- [ ] **BE PATIENT** - This takes 5-10 minutes
- [ ] Don't interrupt it
- [ ] Wait for "Succeeded" message
- [ ] Check that `*.freezed.dart` files are generated

### Step 3: Run the App
- [ ] Run: `flutter run -d chrome`
- [ ] Wait for Chrome to open
- [ ] See the login screen
- [ ] No compilation errors

## Testing

### Authentication
- [ ] Can see login screen
- [ ] Can log in with `demo@ironflow.com` / `password123`
- [ ] Can see home screen after login
- [ ] Can log out
- [ ] Can create new account
- [ ] Can log in with new account

### Workout Features
- [ ] Can navigate to Workout tab
- [ ] Can see exercise library
- [ ] Can start a workout
- [ ] Can log sets and reps
- [ ] Can complete a workout
- [ ] Can view workout history

### Nutrition Features
- [ ] Can navigate to Nutrition tab
- [ ] Can log a meal
- [ ] Can add food items
- [ ] Can see macro totals
- [ ] Can view nutrition history

### Progress Features
- [ ] Can navigate to Progress tab
- [ ] Can log body weight
- [ ] Can add measurements
- [ ] Can view charts
- [ ] Can see progress over time

### Settings
- [ ] Can navigate to Profile/Settings
- [ ] Can toggle dark mode
- [ ] Can change units (metric/imperial)
- [ ] Can export data
- [ ] Settings persist after refresh

## Troubleshooting

### If Step 1 Fails:
- [ ] Check internet connection
- [ ] Run: `flutter clean`
- [ ] Try again: `flutter pub get`

### If Step 2 Fails:
- [ ] Check that Step 1 completed
- [ ] Run: `flutter clean`
- [ ] Run: `flutter pub get`
- [ ] Try again: `dart run build_runner build --delete-conflicting-outputs`

### If Step 3 Fails:
- [ ] Check that Step 2 completed
- [ ] Look for error messages
- [ ] Check that Chrome is installed
- [ ] Try: `flutter devices` to see available devices
- [ ] Try again: `flutter run -d chrome`

### If Login Doesn't Work:
- [ ] Check you're using correct credentials
- [ ] Email: `demo@ironflow.com`
- [ ] Password: `password123`
- [ ] Check browser console for errors (F12)

### If Features Don't Work:
- [ ] Check browser console (F12)
- [ ] Look for error messages
- [ ] Try refreshing the page
- [ ] Try logging out and back in

## Success Indicators

### ✅ You're Good If:
- No compilation errors
- App loads in Chrome
- Can log in successfully
- Can navigate between tabs
- Can log a workout
- Can log a meal
- Data persists after refresh (except auth)

### ❌ Something's Wrong If:
- Compilation errors
- White screen in Chrome
- Can't log in
- Features crash
- Data doesn't save

## Quick Reference

### Commands:
```bash
# Step 1
flutter pub get

# Step 2 (TAKES 5-10 MINUTES!)
dart run build_runner build --delete-conflicting-outputs

# Step 3
flutter run -d chrome

# If problems:
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

### Login:
- Email: `demo@ironflow.com`
- Password: `password123`

### Documentation:
- `RUN_THESE_COMMANDS.txt` - Quick commands
- `SIMPLIFIED_APP_READY.md` - Full guide
- `FIX_AND_RUN.md` - Detailed instructions
- `FINAL_STATUS.md` - What was changed

## Completion

- [ ] All setup steps completed
- [ ] All tests passed
- [ ] App is running smoothly
- [ ] Ready to use IronFlow! 💪

---

**Stuck?** Check the documentation files or review the error messages carefully.

**Success?** Start tracking your fitness journey! 🚀
