# IronFlow Platform Upgrade - Requirements Document

## Executive Summary

IronFlow is transitioning from a feature-complete fitness app (12 phases complete, 68 tasks done) into a **full-featured intelligent fitness platform**. This spec defines the requirements for adding backend infrastructure, AI coaching, advanced nutrition tracking, and enterprise-grade features while maintaining the stable core.

**Current State**: ✅ All 12 phases complete, 315+ tests passing, 0 compilation errors
**Upgrade Scope**: Backend + Cloud Sync + AI System + Advanced Nutrition + Data Management

---

## Part 1: Backend & Cloud Sync

### Requirement 1.1: Cloud Authentication

**User Story**: As a user, I want to sign up with email/Google/Apple and sync my data across devices.

**Acceptance Criteria**:
1. App SHALL support email/password authentication
2. App SHALL support Google Sign-In
3. App SHALL support Apple Sign-In
4. User profile SHALL sync to cloud backend
5. Authentication tokens SHALL persist securely
6. User SHALL be able to sign out and clear local data

### Requirement 1.2: Multi-Device Sync

**User Story**: As a user, I want my workouts and nutrition logged on one device to appear on another device.

**Acceptance Criteria**:
1. Active program SHALL sync to cloud when changed
2. Completed workouts SHALL sync to cloud within 5 seconds
3. Nutrition logs SHALL sync to cloud within 5 seconds
4. Diet plans SHALL sync to cloud when generated
5. Sync conflicts SHALL resolve using last-write-wins strategy
6. User SHALL see sync status indicator

### Requirement 1.3: Offline-First Sync Queue

**User Story**: As a user, I want to log workouts offline and have them sync automatically when online.

**Acceptance Criteria**:
1. App SHALL queue operations when offline
2. Queued operations SHALL persist to local storage
3. When online, app SHALL sync queued operations in order
4. Sync errors SHALL retry up to 3 times
5. User SHALL see pending sync count
6. No data loss during offline periods

### Requirement 1.4: Backend Architecture Choice

**User Story**: As an architect, I need to choose between Firebase and custom backend.

**Acceptance Criteria**:
1. OPTION A: Firebase (Firestore + Auth + Storage)
   - Real-time sync
   - Built-in auth
   - Scalable
   - Lower operational overhead
2. OPTION B: FastAPI/Node.js + PostgreSQL
   - Full control
   - Custom logic
   - Self-hosted or cloud
   - More operational overhead

---

## Part 2: Exercise System Upgrade

### Requirement 2.1: 150+ Exercise Database

**User Story**: As a user, I want access to 150+ exercises organized by muscle group.

**Acceptance Criteria**:
1. Database SHALL contain 150+ exercises
2. Exercises SHALL be categorized by muscle group:
   - Chest (15+ exercises)
   - Back (15+ exercises)
   - Legs (15+ exercises)
   - Shoulders (10+ exercises)
   - Arms (10+ exercises)
   - Abs (8+ exercises)
   - Full Body (5+ exercises)
3. Each exercise SHALL have:
   - Name
   - Muscle group
   - Equipment required
   - Difficulty level (beginner/intermediate/advanced)
   - Image URL
   - Video URL
   - Instructions (text)
   - Common mistakes (text)
4. Exercises SHALL be searchable by name
5. Exercises SHALL be filterable by muscle group, equipment, difficulty

### Requirement 2.2: Exercise Picker UI

**User Story**: As a user, I want to pick exercises from a visual interface, not type them.

**Acceptance Criteria**:
1. Exercise picker SHALL display exercises in grid view
2. Each exercise card SHALL show:
   - Exercise image
   - Exercise name
   - Muscle group badge
   - Equipment icons
3. User SHALL be able to search exercises by name
4. User SHALL be able to filter by muscle group
5. User SHALL be able to filter by equipment
6. User SHALL be able to filter by difficulty
7. Tapping exercise SHALL show full details (video, instructions, mistakes)
8. User SHALL be able to select exercise to add to program

### Requirement 2.3: Exercise Video Integration

**User Story**: As a user, I want to see exercise videos to learn proper form.

**Acceptance Criteria**:
1. Exercise detail view SHALL display video
2. Video SHALL autoplay with muted audio
3. User SHALL be able to unmute
4. User SHALL be able to expand to fullscreen
5. Video SHALL have fallback image if loading fails
6. Video SHALL show loading indicator while buffering

---

## Part 3: Advanced Nutrition System

### Requirement 3.1: Macro + Micronutrient Tracking

**User Story**: As a user, I want to track not just macros but also micronutrients like fiber, vitamins, and minerals.

**Acceptance Criteria**:
1. App SHALL track macronutrients:
   - Protein (g)
   - Carbohydrates (g)
   - Fats (g)
   - Calories (kcal)
2. App SHALL track micronutrients:
   - Fiber (g)
   - Sugar (g)
   - Sodium (mg)
   - Potassium (mg)
3. App SHALL track vitamins:
   - Vitamin A (mcg)
   - Vitamin B (simplified, mcg)
   - Vitamin C (mg)
   - Vitamin D (mcg)
   - Vitamin E (mg)
4. App SHALL track minerals:
   - Calcium (mg)
   - Iron (mg)
   - Magnesium (mg)
   - Zinc (mg)
5. All values SHALL be per 100g in database
6. Values SHALL scale by quantity when logging meals

### Requirement 3.2: Food Database (200+ Foods)

**User Story**: As a user, I want to log meals from a database of 200+ common foods.

**Acceptance Criteria**:
1. Database SHALL contain 200+ foods
2. Each food SHALL have:
   - Name
   - Category (protein, carb, fat, vegetable, fruit, etc.)
   - Serving size (g)
   - Macros per 100g
   - Micros per 100g
   - Image URL
   - Dietary tags (vegan, gluten-free, etc.)
3. Foods SHALL be searchable by name
4. Foods SHALL be filterable by category
5. Foods SHALL be filterable by dietary tags
6. User SHALL be able to log custom foods

### Requirement 3.3: Smart Food Alternatives

**User Story**: As a user, I want the app to suggest alternative foods with similar macros.

**Acceptance Criteria**:
1. When user logs a food, app SHALL suggest alternatives
2. Alternatives SHALL have macros within 10% of original
3. App SHALL show at least 3 alternatives if available
4. User SHALL be able to swap to alternative with one tap
5. Swapped food SHALL update daily totals immediately

### Requirement 3.4: Nutrition UI - Layered Display

**User Story**: As a user, I want to see nutrition data organized by importance.

**Acceptance Criteria**:
1. LEVEL 1 (Always visible):
   - Calories + macros (protein, carbs, fats)
   - Progress bars showing consumed vs target
2. LEVEL 2 (Expandable):
   - Fiber, sugar, sodium
   - Progress bars with color coding
3. LEVEL 3 (Expandable):
   - Vitamins & minerals
   - Progress bars with color coding
4. Color system:
   - GREEN: Within target range
   - ORANGE: Moderate (75-125% of target)
   - RED: Outside target range
5. User SHALL be able to expand/collapse each level

### Requirement 3.5: Daily Nutrition Summary

**User Story**: As a user, I want to see a summary of my daily nutrition with AI feedback.

**Acceptance Criteria**:
1. Summary SHALL show:
   - Total calories consumed vs target
   - Macro breakdown (protein, carbs, fats)
   - Micronutrient summary (fiber, sugar, sodium)
   - Vitamin & mineral summary
2. Summary SHALL include AI feedback:
   - "Great protein intake today!"
   - "You're low on fiber, consider adding vegetables"
   - "Watch your sodium intake"
3. Summary SHALL be accessible from nutrition screen
4. Summary SHALL update in real-time as meals are logged

---

## Part 4: Program System Upgrade

### Requirement 4.1: Multiple Training Splits

**User Story**: As a user, I want to choose from multiple training splits that match my schedule.

**Acceptance Criteria**:
1. App SHALL provide these splits:
   - Full Body (3 days/week)
   - Upper/Lower (4 days/week)
   - Push/Pull/Legs (6 days/week)
   - Arnold Split (4 days/week)
   - Bro Split (5 days/week)
2. Each split SHALL have:
   - Description
   - Day count
   - Recommended experience level
   - Sample week layout
3. User SHALL be able to select split during onboarding
4. User SHALL be able to change split anytime
5. Changing split SHALL generate new program

### Requirement 4.2: Program Customization

**User Story**: As a user, I want to customize my program by editing exercises, sets, and reps.

**Acceptance Criteria**:
1. User SHALL be able to open program editor
2. Editor SHALL show all days in program
3. User SHALL be able to:
   - Replace exercises
   - Change sets/reps
   - Reorder exercises
   - Delete exercises
   - Add exercises
4. Changes SHALL persist to active program
5. Changes SHALL be reflected in next workout

### Requirement 4.3: Program Progression

**User Story**: As a user, I want the app to suggest when to increase weight or reps.

**Acceptance Criteria**:
1. App SHALL analyze last 3 workouts for each exercise
2. App SHALL suggest weight increase if:
   - All sets completed with RPE < 7
   - Same weight/reps for 3+ sessions
3. App SHALL suggest rep increase if:
   - All sets completed with RPE < 6
4. App SHALL suggest deload if:
   - RPE > 9 for 2+ sessions
5. User SHALL be able to accept/dismiss suggestions
6. Accepted suggestions SHALL update program

---

## Part 5: Advanced Analytics

### Requirement 5.1: Strength Progression Charts

**User Story**: As a user, I want to see my strength progress over time with charts.

**Acceptance Criteria**:
1. App SHALL display line chart showing weight progression per exercise
2. Chart SHALL show last 12 weeks of data
3. Chart SHALL be filterable by exercise
4. Chart SHALL show trend line
5. Chart SHALL show personal records
6. User SHALL be able to tap data points for details

### Requirement 5.2: Weight Tracking Graph

**User Story**: As a user, I want to track my body weight over time.

**Acceptance Criteria**:
1. App SHALL display line chart of body weight
2. Chart SHALL show last 12 weeks
3. Chart SHALL show trend line
4. Chart SHALL show weekly average
5. User SHALL be able to log weight entries
6. Chart SHALL update in real-time

### Requirement 5.3: Consistency Tracking

**User Story**: As a user, I want to see my workout consistency metrics.

**Acceptance Criteria**:
1. App SHALL show:
   - Workouts this week
   - Workouts this month
   - Workouts this year
   - Current streak
   - Longest streak
2. App SHALL display consistency as percentage
3. App SHALL show weekly heatmap
4. App SHALL show monthly summary

### Requirement 5.4: Performance Prediction

**User Story**: As a user, I want the app to predict my future performance.

**Acceptance Criteria**:
1. App SHALL analyze performance trends
2. App SHALL predict 1-month strength gain
3. App SHALL predict 3-month strength gain
4. App SHALL predict body weight change
5. Predictions SHALL be based on last 12 weeks
6. Predictions SHALL be displayed with confidence level

---

## Part 6: Retention System

### Requirement 6.1: Workout Reminders

**User Story**: As a user, I want to receive reminders to work out.

**Acceptance Criteria**:
1. User SHALL be able to set reminder time
2. App SHALL send notification at set time
3. Notification SHALL show:
   - "Time to work out!"
   - Today's workout (muscle group)
4. User SHALL be able to snooze reminder
5. User SHALL be able to disable reminders

### Requirement 6.2: Meal Reminders

**User Story**: As a user, I want reminders to log meals.

**Acceptance Criteria**:
1. User SHALL be able to set meal reminder times
2. App SHALL send notifications at set times
3. Notifications SHALL show:
   - "Time to log breakfast/lunch/dinner"
   - Macro targets for meal
4. User SHALL be able to snooze
5. User SHALL be able to disable

### Requirement 6.3: Streak Tracking

**User Story**: As a user, I want to maintain workout streaks.

**Acceptance Criteria**:
1. App SHALL track consecutive workout days
2. Streak SHALL reset if user misses a day
3. App SHALL show current streak with fire icon
4. App SHALL show longest streak
5. App SHALL show streak on dashboard
6. Streak SHALL be included in weekly report

### Requirement 6.4: Achievements

**User Story**: As a user, I want to unlock achievements for milestones.

**Acceptance Criteria**:
1. App SHALL have achievements for:
   - 7 workouts
   - 30 workouts
   - 100 workouts
   - 365 workouts
   - 7-day streak
   - 30-day streak
   - First PR
   - 10 PRs
   - 1000 total volume
   - 5000 total volume
2. User SHALL see achievement badge when unlocked
3. Achievements SHALL be displayed in profile
4. Achievements SHALL be shareable

### Requirement 6.5: Weekly Reports

**User Story**: As a user, I want a weekly summary of my progress.

**Acceptance Criteria**:
1. App SHALL generate weekly report every Sunday
2. Report SHALL include:
   - Workouts completed
   - Total volume
   - PRs achieved
   - Meals logged
   - Macro compliance
   - Streak status
3. User SHALL be able to view report in app
4. User SHALL be able to share report

---

## Part 7: AI System

### Requirement 7.1: AI Chat Interface

**User Story**: As a user, I want to chat with an AI coach for personalized guidance.

**Acceptance Criteria**:
1. App SHALL have chat screen
2. User SHALL be able to send messages
3. AI SHALL respond with coaching advice
4. Chat history SHALL persist
5. User SHALL be able to clear chat history
6. Chat SHALL be accessible from main navigation

### Requirement 7.2: Context-Aware AI

**User Story**: As a user, I want the AI to understand my fitness data and give personalized advice.

**Acceptance Criteria**:
1. AI SHALL have access to:
   - User profile (goals, experience level)
   - Workout history (last 12 weeks)
   - Current program
   - Progress data (strength, weight)
   - Nutrition logs (last 7 days)
2. AI SHALL use this data to:
   - Suggest program adjustments
   - Recommend nutrition changes
   - Identify weak points
   - Celebrate achievements
3. AI responses SHALL be specific to user data
4. AI SHALL NOT give generic advice

### Requirement 7.3: AI Workout Coaching

**User Story**: As a user, I want the AI to help me with workout programming.

**Acceptance Criteria**:
1. User SHALL be able to ask:
   - "Generate a new program"
   - "Adjust my program for more volume"
   - "I'm struggling with X exercise"
   - "What should I do next?"
2. AI SHALL:
   - Generate programs based on goals
   - Suggest exercise swaps
   - Recommend progression strategies
   - Identify stagnation
3. AI suggestions SHALL be actionable
4. User SHALL be able to apply suggestions directly

### Requirement 7.4: AI Nutrition Coaching

**User Story**: As a user, I want the AI to help me with nutrition.

**Acceptance Criteria**:
1. User SHALL be able to ask:
   - "Generate a meal plan"
   - "I'm low on protein"
   - "Suggest meals for today"
   - "Is this food good for my goals?"
2. AI SHALL:
   - Detect nutrient deficiencies
   - Suggest foods to fix deficiencies
   - Warn about high sugar/sodium
   - Recommend meal timing
3. AI suggestions SHALL be based on user data
4. User SHALL be able to apply suggestions

### Requirement 7.5: AI Quick Actions

**User Story**: As a user, I want quick buttons to trigger common AI actions.

**Acceptance Criteria**:
1. Chat screen SHALL have quick action buttons:
   - "Generate Workout"
   - "Adjust Diet"
   - "Analyze Progress"
   - "What's Next?"
2. Tapping button SHALL pre-fill chat with request
3. AI SHALL respond immediately
4. User SHALL be able to customize quick actions

### Requirement 7.6: AI Deficiency Detection

**User Story**: As a user, I want the AI to detect nutritional deficiencies.

**Acceptance Criteria**:
1. AI SHALL analyze nutrition logs
2. AI SHALL detect if user is low on:
   - Protein
   - Fiber
   - Vitamins (A, B, C, D, E)
   - Minerals (calcium, iron, magnesium, zinc)
3. AI SHALL suggest foods to fix deficiency
4. AI SHALL show which foods are high in nutrient
5. AI SHALL provide specific recommendations

---

## Part 8: Data Management

### Requirement 8.1: Export Data

**User Story**: As a user, I want to export my data in standard formats.

**Acceptance Criteria**:
1. User SHALL be able to export:
   - Workout history (CSV)
   - Nutrition logs (CSV)
   - Body measurements (CSV)
   - Full data (JSON)
2. Exports SHALL include all data
3. User SHALL be able to download exports
4. Exports SHALL be shareable

### Requirement 8.2: Backup & Restore

**User Story**: As a user, I want to backup my data and restore it if needed.

**Acceptance Criteria**:
1. App SHALL automatically backup to cloud daily
2. User SHALL be able to manually backup
3. User SHALL be able to restore from backup
4. Restore SHALL overwrite local data
5. User SHALL confirm before restore

### Requirement 8.3: Import Programs

**User Story**: As a user, I want to import workout programs from files.

**Acceptance Criteria**:
1. User SHALL be able to import programs from JSON
2. Imported program SHALL be added to program list
3. User SHALL be able to set imported program as active
4. Import SHALL validate program structure

### Requirement 8.4: Privacy Controls

**User Story**: As a user, I want control over my data privacy.

**Acceptance Criteria**:
1. User SHALL be able to:
   - Delete account
   - Delete all data
   - Opt out of analytics
   - Control data sharing
2. Deletion SHALL be permanent
3. User SHALL receive confirmation

---

## Part 9: Performance & Optimization

### Requirement 9.1: Lazy Loading

**User Story**: As a user, I want the app to load quickly even with large datasets.

**Acceptance Criteria**:
1. Lists SHALL lazy load items
2. Images SHALL lazy load
3. Charts SHALL lazy load data
4. App SHALL handle 1000+ workouts
5. App SHALL handle 5000+ foods

### Requirement 9.2: Caching

**User Story**: As a user, I want the app to be fast by caching data.

**Acceptance Criteria**:
1. App SHALL cache:
   - Exercise database
   - Food database
   - User profile
   - Computed values (totals, trends)
2. Cache SHALL invalidate when data changes
3. Cache SHALL persist across sessions

### Requirement 9.3: Background Sync

**User Story**: As a user, I want data to sync in the background.

**Acceptance Criteria**:
1. App SHALL sync data in background
2. Sync SHALL not block UI
3. Sync SHALL happen every 5 minutes when online
4. User SHALL see sync status

---

## Part 10: UX Polish

### Requirement 10.1: Dark/Light Mode

**User Story**: As a user, I want to choose between dark and light themes.

**Acceptance Criteria**:
1. App SHALL support dark mode
2. App SHALL support light mode
3. User SHALL be able to toggle theme
4. Theme preference SHALL persist
5. All screens SHALL support both themes

### Requirement 10.2: Animations

**User Story**: As a user, I want smooth animations for visual feedback.

**Acceptance Criteria**:
1. Screen transitions SHALL be smooth
2. List items SHALL animate on load
3. Charts SHALL animate on update
4. Buttons SHALL have ripple effect
5. Animations SHALL be 200-500ms

### Requirement 10.3: Modern UI

**User Story**: As a user, I want a modern, clean interface.

**Acceptance Criteria**:
1. UI SHALL use Material 3 design
2. UI SHALL use consistent spacing
3. UI SHALL use consistent colors
4. UI SHALL use consistent typography
5. UI SHALL be clutter-free

---

## Part 11: Localization

### Requirement 11.1: Multi-Language Support

**User Story**: As a user, I want the app in my language.

**Acceptance Criteria**:
1. App SHALL support:
   - English
   - Spanish
   - French
   - German
   - Portuguese
   - Japanese
   - Chinese (Simplified)
2. User SHALL be able to change language
3. Language preference SHALL persist
4. All text SHALL be translated

### Requirement 11.2: Units System

**User Story**: As a user, I want to use my preferred units (kg/lbs, cm/in).

**Acceptance Criteria**:
1. App SHALL support:
   - Metric (kg, cm, g)
   - Imperial (lbs, in, oz)
2. User SHALL be able to change units
3. All values SHALL convert automatically
4. Unit preference SHALL persist

### Requirement 11.3: Timezone Support

**User Story**: As a user, I want the app to respect my timezone.

**Acceptance Criteria**:
1. App SHALL detect user timezone
2. All timestamps SHALL be in user timezone
3. Reminders SHALL respect timezone
4. User SHALL be able to change timezone

---

## Success Criteria

✅ All existing features remain stable
✅ Backend sync works reliably
✅ AI provides personalized coaching
✅ Nutrition tracking includes macros + micros
✅ 150+ exercises available
✅ 200+ foods in database
✅ Multiple training splits
✅ Advanced analytics with predictions
✅ Retention system drives engagement
✅ Data export/import works
✅ Performance optimized for large datasets
✅ UX is modern and polished
✅ Multi-language support
✅ All tests pass (315+ tests)
✅ Zero compilation errors

