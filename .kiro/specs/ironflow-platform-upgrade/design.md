# IronFlow Platform Upgrade - Design Document

## Architecture Overview

IronFlow Platform is built on a layered architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (Screens, Widgets, Providers, State Management)            │
├─────────────────────────────────────────────────────────────┤
│                     DOMAIN LAYER                             │
│  (Entities, Use Cases, Repository Interfaces)               │
├─────────────────────────────────────────────────────────────┤
│                     DATA LAYER                               │
│  (Repositories, Data Sources, Models)                       │
├─────────────────────────────────────────────────────────────┤
│                  BACKEND & STORAGE                           │
│  (Firebase/FastAPI, Hive Local Storage, Cloud Sync)         │
└─────────────────────────────────────────────────────────────┘
```

---

## Part 1: Backend Architecture

### Option A: Firebase Architecture (Recommended for MVP)

```
┌─────────────────────────────────────────┐
│         Firebase Console                 │
├─────────────────────────────────────────┤
│  ├─ Authentication (Email, Google, Apple)
│  ├─ Firestore (Real-time Database)
│  ├─ Cloud Storage (Images, Videos)
│  └─ Cloud Functions (Triggers, AI)
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Flutter App (Offline-First)        │
├─────────────────────────────────────────┤
│  ├─ Local Storage (Hive)
│  ├─ Sync Queue (Pending Operations)
│  └─ Cloud Sync (When Online)
└─────────────────────────────────────────┘
```

**Firestore Collections**:
- `users/{userId}` - User profile
- `users/{userId}/programs` - Workout programs
- `users/{userId}/workouts` - Completed workouts
- `users/{userId}/nutrition` - Nutrition logs
- `users/{userId}/body` - Body measurements
- `exercises` - Shared exercise database
- `foods` - Shared food database

### Option B: FastAPI/Node.js Architecture (For Full Control)

```
┌─────────────────────────────────────────┐
│      FastAPI/Node.js Backend            │
├─────────────────────────────────────────┤
│  ├─ Authentication (JWT)
│  ├─ REST/GraphQL API
│  ├─ WebSocket (Real-time Sync)
│  └─ Background Jobs (AI, Analytics)
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      PostgreSQL Database                 │
├─────────────────────────────────────────┤
│  ├─ Users
│  ├─ Programs
│  ├─ Workouts
│  ├─ Nutrition
│  ├─ Exercises
│  └─ Foods
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Flutter App (Offline-First)        │
├─────────────────────────────────────────┤
│  ├─ Local Storage (Hive)
│  ├─ Sync Queue (Pending Operations)
│  └─ Cloud Sync (When Online)
└─────────────────────────────────────────┘
```

---

## Part 2: Database Schema

### Firebase Firestore Schema

```
users/
  {userId}/
    profile: {
      email: string
      name: string
      age: int
      gender: string
      fitnessLevel: string (beginner/intermediate/advanced)
      goals: string[] (strength/hypertrophy/endurance/weight-loss)
      equipment: string[] (barbell/dumbbell/machine/bodyweight)
      createdAt: timestamp
      updatedAt: timestamp
    }
    
    programs/
      {programId}: {
        name: string
        splitType: string (full-body/upper-lower/ppl/arnold/bro)
        days: {
          day1: {
            name: string
            exercises: {
              exercise1: {
                name: string
                sets: int
                reps: string (e.g., "8-12")
                rest: int (seconds)
                notes: string
              }
            }
          }
        }
        currentDay: int
        isActive: boolean
        createdAt: timestamp
        updatedAt: timestamp
      }
    
    workouts/
      {workoutId}: {
        date: timestamp
        programId: string
        dayNumber: int
        exercises: {
          exercise1: {
            name: string
            sets: {
              set1: {
                reps: int
                weight: double
                rpe: int (1-10)
                timestamp: timestamp
              }
            }
          }
        }
        totalVolume: double
        duration: int (minutes)
        notes: string
        createdAt: timestamp
      }
    
    nutrition/
      {dateString}: {
        date: timestamp
        meals: {
          meal1: {
            name: string
            quantity: double
            unit: string (g, ml, serving)
            macros: {
              calories: double
              protein: double
              carbs: double
              fats: double
            }
            micros: {
              fiber: double
              sugar: double
              sodium: double
              potassium: double
            }
            vitamins: {
              a: double
              b: double
              c: double
              d: double
              e: double
            }
            minerals: {
              calcium: double
              iron: double
              magnesium: double
              zinc: double
            }
            timestamp: timestamp
          }
        }
        totals: {
          calories: double
          protein: double
          carbs: double
          fats: double
          fiber: double
          sugar: double
          sodium: double
          potassium: double
        }
      }
    
    body/
      {entryId}: {
        date: timestamp
        weight: double
        measurements: {
          chest: double
          waist: double
          hips: double
          arms: double
          legs: double
        }
        photoUrl: string (optional)
        notes: string
      }

exercises/ (Shared collection)
  {exerciseId}: {
    name: string
    muscleGroup: string
    equipment: string[]
    difficulty: string (beginner/intermediate/advanced)
    imageUrl: string
    videoUrl: string
    instructions: string
    commonMistakes: string[]
  }

foods/ (Shared collection)
  {foodId}: {
    name: string
    category: string
    servingSize: double
    servingUnit: string
    macros: {
      caloriesPer100g: double
      proteinPer100g: double
      carbsPer100g: double
      fatsPer100g: double
    }
    micros: {
      fiberPer100g: double
      sugarPer100g: double
      sodiumPer100g: double
      potassiumPer100g: double
    }
    vitamins: {
      aPer100g: double
      bPer100g: double
      cPer100g: double
      dPer100g: double
      ePer100g: double
    }
    minerals: {
      calciumPer100g: double
      ironPer100g: double
      magnesiumPer100g: double
      zincPer100g: double
    }
    imageUrl: string
    dietaryTags: string[] (vegan/vegetarian/gluten-free/etc)
  }
```

---

## Part 3: Flutter Architecture

### Directory Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_theme.dart
│   │   ├── style_guide.dart
│   │   └── nutrition_constants.dart
│   ├── providers/
│   │   ├── theme_provider.dart
│   │   ├── auth_provider.dart
│   │   ├── connectivity_provider.dart
│   │   └── sync_provider.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── utils/
│   │   ├── input_validators.dart
│   │   ├── cache_manager.dart
│   │   ├── sync_queue_manager.dart
│   │   └── nutrition_calculator.dart
│   └── widgets/
│       ├── loading_indicator.dart
│       ├── error_dialog.dart
│       └── offline_banner.dart
│
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── workout/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── nutrition/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── analytics/
│   ├── ai/
│   ├── retention/
│   └── settings/
│
├── shared/
│   ├── animations/
│   ├── widgets/
│   └── models/
│
└── main.dart
```

### State Management Pattern (Riverpod)

```dart
// Provider for authentication
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(firebaseAuthRepositoryProvider));
});

// Provider for active program
final activeProgramProvider = StateNotifierProvider<ActiveProgramNotifier, ActiveProgram?>((ref) {
  return ActiveProgramNotifier(ref.watch(programRepositoryProvider));
});

// Provider for sync queue
final syncQueueProvider = StateNotifierProvider<SyncQueueNotifier, List<SyncOperation>>((ref) {
  return SyncQueueNotifier(ref.watch(syncRepositoryProvider));
});

// Provider for nutrition summary
final dailyNutritionProvider = FutureProvider<NutritionSummary>((ref) async {
  final nutrition = ref.watch(nutritionRepositoryProvider);
  return nutrition.getDailySummary(DateTime.now());
});
```

---

## Part 4: AI System Design

### AI Architecture

```
┌─────────────────────────────────────────┐
│      Flutter Chat UI                     │
│  (User sends message)                   │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      AI Context Builder                  │
│  (Gathers user data)                    │
├─────────────────────────────────────────┤
│  ├─ User profile
│  ├─ Last 12 weeks workouts
│  ├─ Current program
│  ├─ Last 7 days nutrition
│  ├─ Body measurements
│  └─ Progress trends
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      AI Service (OpenAI/Claude)          │
│  (Generates response)                   │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Response Parser                     │
│  (Structures response)                  │
├─────────────────────────────────────────┤
│  ├─ Text response
│  ├─ Actionable suggestions
│  ├─ Program updates
│  └─ Meal recommendations
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Flutter Chat UI                     │
│  (Display response)                     │
└─────────────────────────────────────────┘
```

### AI Prompt Structure

```
System Prompt:
"You are an expert fitness coach with deep knowledge of:
- Strength training programming
- Nutrition science
- Body composition
- Performance optimization

You have access to the user's fitness data and must:
1. Provide personalized advice based on their data
2. Identify specific issues (e.g., 'Your squat hasn't improved in 4 weeks')
3. Give actionable recommendations
4. Celebrate achievements
5. Never give generic advice"

User Context:
{
  "profile": {
    "age": 28,
    "fitnessLevel": "intermediate",
    "goals": ["strength", "hypertrophy"]
  },
  "recentWorkouts": [...],
  "currentProgram": {...},
  "nutritionLast7Days": {...},
  "bodyMetrics": {...}
}

User Message:
"I'm struggling with my bench press"

Expected Response:
{
  "text": "I see your bench press has been stuck at 185lbs for 3 weeks. Let's fix this...",
  "suggestions": [
    {
      "type": "exercise_swap",
      "current": "Bench Press",
      "suggested": "Incline Bench Press",
      "reason": "Targets upper chest weakness"
    }
  ],
  "actionable": true
}
```

---

## Part 5: Nutrition Data Structure

### Nutrition Tracking Hierarchy

```
LEVEL 1 - MACROS (Always Visible)
├─ Calories (kcal)
├─ Protein (g)
├─ Carbohydrates (g)
└─ Fats (g)

LEVEL 2 - MICRONUTRIENTS (Expandable)
├─ Fiber (g)
├─ Sugar (g)
├─ Sodium (mg)
└─ Potassium (mg)

LEVEL 3 - VITAMINS & MINERALS (Expandable)
├─ Vitamins
│  ├─ Vitamin A (mcg)
│  ├─ Vitamin B (mcg)
│  ├─ Vitamin C (mg)
│  ├─ Vitamin D (mcg)
│  └─ Vitamin E (mg)
└─ Minerals
   ├─ Calcium (mg)
   ├─ Iron (mg)
   ├─ Magnesium (mg)
   └─ Zinc (mg)
```

### Food Data Model

```dart
class Food {
  final String id;
  final String name;
  final String category;
  final double servingSize;
  final String servingUnit;
  
  // Per 100g
  final MacrosPer100g macros;
  final MicrosPer100g micros;
  final VitaminsPer100g vitamins;
  final MineralsPer100g minerals;
  
  final String imageUrl;
  final List<String> dietaryTags;
}

class MacrosPer100g {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
}

class MicrosPer100g {
  final double fiber;
  final double sugar;
  final double sodium;
  final double potassium;
}

class VitaminsPer100g {
  final double vitaminA;
  final double vitaminB;
  final double vitaminC;
  final double vitaminD;
  final double vitaminE;
}

class MineralsPer100g {
  final double calcium;
  final double iron;
  final double magnesium;
  final double zinc;
}
```

---

## Part 6: Chat UI Structure

### Chat Screen Layout

```
┌─────────────────────────────────────────┐
│  IronFlow AI Coach                      │
├─────────────────────────────────────────┤
│                                         │
│  [Chat History]                         │
│  ├─ User: "Generate a new program"     │
│  ├─ AI: "Based on your data..."        │
│  └─ [Apply] [Dismiss]                  │
│                                         │
├─────────────────────────────────────────┤
│  Quick Actions:                         │
│  [Generate Workout] [Adjust Diet]       │
│  [Analyze Progress] [What's Next?]      │
├─────────────────────────────────────────┤
│  [Message Input Field]                  │
│  [Send Button]                          │
└─────────────────────────────────────────┘
```

### AI Response Types

```dart
enum AIResponseType {
  text,           // Simple text response
  suggestion,     // Actionable suggestion
  program,        // Workout program
  mealPlan,       // Nutrition plan
  analysis,       // Data analysis
  celebration,    // Achievement
}

class AIResponse {
  final AIResponseType type;
  final String text;
  final dynamic data;  // Program, MealPlan, etc.
  final List<AIAction> actions;
}

class AIAction {
  final String label;
  final String actionType;  // apply, dismiss, edit, etc.
  final dynamic payload;
}
```

---

## Part 7: Sync Architecture

### Offline-First Sync Queue

```
┌─────────────────────────────────────────┐
│      User Action (Offline)              │
│  (Log workout, add meal, etc.)          │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Save to Local Storage              │
│  (Hive)                                 │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Add to Sync Queue                  │
│  (Pending operations)                   │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Check Connectivity                 │
└─────────────────────────────────────────┘
         ↓
    ┌────────────────────┬────────────────────┐
    ↓                    ↓
┌─────────────────┐  ┌─────────────────┐
│   Online        │  │   Offline       │
│ Sync to Cloud   │  │ Wait for Online │
│ (Firebase)      │  │                 │
└─────────────────┘  └─────────────────┘
    ↓
┌─────────────────────────────────────────┐
│      Conflict Resolution                │
│  (Last-write-wins)                      │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│      Remove from Sync Queue             │
│  (Mark as synced)                       │
└─────────────────────────────────────────┘
```

---

## Part 8: Performance Optimization

### Caching Strategy

```
┌─────────────────────────────────────────┐
│      In-Memory Cache                    │
│  (Fast, limited size)                   │
├─────────────────────────────────────────┤
│  ├─ User profile
│  ├─ Active program
│  ├─ Exercise database
│  └─ Food database
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Hive Local Storage                 │
│  (Persistent, larger)                   │
├─────────────────────────────────────────┤
│  ├─ All workouts
│  ├─ All nutrition logs
│  ├─ All body measurements
│  └─ Sync queue
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Cloud Storage                      │
│  (Authoritative, synced)                │
├─────────────────────────────────────────┤
│  ├─ User data
│  ├─ Shared databases
│  └─ Backups
└─────────────────────────────────────────┘
```

### Lazy Loading Strategy

```
- Lists: Load 20 items, load more on scroll
- Images: Load thumbnail first, full image on demand
- Charts: Load data points on demand, sample if >100 points
- Databases: Load on first use, cache in memory
```

---

## Part 9: Security & Privacy

### Authentication Flow

```
┌─────────────────────────────────────────┐
│      User Signup/Login                  │
├─────────────────────────────────────────┤
│  ├─ Email/Password
│  ├─ Google Sign-In
│  └─ Apple Sign-In
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Firebase Authentication            │
│  (Secure token generation)              │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Store Token Securely               │
│  (Flutter Secure Storage)               │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│      Attach to API Requests             │
│  (Authorization header)                 │
└─────────────────────────────────────────┘
```

### Data Privacy

- User data encrypted in transit (HTTPS)
- Sensitive data encrypted at rest
- User can delete account and all data
- User can opt out of analytics
- GDPR compliant

---

## Part 10: Testing Strategy

### Test Coverage

```
Unit Tests (70% coverage)
├─ Use cases
├─ Repositories
├─ Providers
└─ Utilities

Integration Tests (20% coverage)
├─ Auth flow
├─ Workout flow
├─ Nutrition flow
├─ Sync flow
└─ AI chat flow

Widget Tests (10% coverage)
├─ Chat screen
├─ Nutrition screen
├─ Analytics screen
└─ Settings screen
```

---

## Implementation Phases

### Phase 1: Backend & Auth (Week 1-2)
- Set up Firebase/FastAPI
- Implement authentication
- Create database schema
- Set up Hive local storage

### Phase 2: Sync System (Week 2-3)
- Implement offline-first sync
- Create sync queue manager
- Handle conflict resolution
- Test with large datasets

### Phase 3: Exercise & Nutrition (Week 3-4)
- Populate 150+ exercises
- Populate 200+ foods
- Create exercise picker UI
- Create nutrition tracking UI

### Phase 4: AI System (Week 4-5)
- Integrate OpenAI/Claude API
- Build context builder
- Create chat UI
- Implement AI coaching features

### Phase 5: Analytics & Retention (Week 5-6)
- Create analytics screens
- Implement streak tracking
- Add notifications
- Create achievements

### Phase 6: Polish & Testing (Week 6-7)
- Performance optimization
- UI/UX refinement
- Comprehensive testing
- Documentation

