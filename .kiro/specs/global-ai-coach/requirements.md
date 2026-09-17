# Requirements Document

## Introduction

The Global AI Coach transforms the AI module from a chat-only feature into a professional fitness coaching system that provides data-driven insights across the entire IronFlow app. The AI Coach automatically analyzes user data (workouts, nutrition, body metrics) and surfaces actionable coaching advice on all main screens without requiring chat interaction.

## Glossary

- **AI_Coach**: The intelligent coaching system that analyzes user fitness data and generates insights
- **Insight_Widget**: A reusable UI component displaying 2-3 coaching insights as a card
- **Insight_Engine**: The service that generates contextual coaching insights based on user data
- **AI_Provider**: The global state management provider that coordinates AI insight generation and updates
- **Context**: The specific screen or domain (Home, Workout, Nutrition, Profile) for which insights are generated
- **Quick_Feedback**: Immediate coaching response shown after user actions (e.g., workout completion)
- **Auto_Update**: Automatic recalculation of insights when underlying data changes
- **Change_Detection**: Mechanism to determine if data has changed since last insight generation
- **Coaching_Quality**: Standards ensuring insights are data-driven, specific, and actionable
- **Volume**: Total weight lifted (reps × weight) across all sets in a workout
- **Progressive_Overload**: Training principle of gradually increasing volume or intensity over time
- **Macro_Targets**: Daily protein, carbohydrate, and fat intake goals
- **PR**: Personal Record - the maximum weight lifted for a specific exercise

## Requirements

### Requirement 1: Global Insight Engine

**User Story:** As a user, I want the AI to analyze my fitness data and generate insights automatically, so that I receive coaching advice without needing to ask questions.

#### Acceptance Criteria

1. THE Insight_Engine SHALL generate insights based on workout history, nutrition data, and body metrics
2. WHEN generating insights, THE Insight_Engine SHALL use data from the last 30 days for workouts and body metrics
3. WHEN generating insights, THE Insight_Engine SHALL use data from the last 7 days for nutrition analysis
4. THE Insight_Engine SHALL generate contextual insights specific to each Context (Home, Workout, Nutrition, Profile)
5. WHEN no data exists for a Context, THE Insight_Engine SHALL generate onboarding insights encouraging data entry
6. THE Insight_Engine SHALL calculate Volume as the sum of (reps × weight) for all sets in a workout
7. WHEN analyzing Progressive_Overload, THE Insight_Engine SHALL compare volume between first half and second half of recent workouts
8. THE Insight_Engine SHALL detect PR by comparing current set performance against historical maximum for the same exercise

### Requirement 2: Coaching Quality Standards

**User Story:** As a user, I want insights that are specific and actionable, so that I know exactly what to do to improve my fitness.

#### Acceptance Criteria

1. THE Insight_Engine SHALL include specific numbers in insights (protein grams, volume calculations, weight changes)
2. THE Insight_Engine SHALL provide actionable recommendations with clear next steps
3. WHEN protein intake is below target, THE Insight_Engine SHALL specify the exact protein deficit in grams
4. WHEN suggesting Progressive_Overload, THE Insight_Engine SHALL specify exact weight increases (e.g., "add 2.5kg")
5. THE Insight_Engine SHALL base protein recommendations on 1.6-2.2g per kg of body weight for muscle building
6. WHEN analyzing volume trends, THE Insight_Engine SHALL calculate percentage changes between time periods
7. THE Insight_Engine SHALL format insights as: Analysis → Numbers → Action Plan
8. THE Insight_Engine SHALL avoid generic advice without supporting data

### Requirement 3: Global AI Provider

**User Story:** As a developer, I want a global AI provider that manages insight state, so that insights are available throughout the app.

#### Acceptance Criteria

1. THE AI_Provider SHALL maintain current insights for each Context (Home, Workout, Nutrition, Profile)
2. THE AI_Provider SHALL expose methods to retrieve insights for a specific Context
3. THE AI_Provider SHALL track the last update timestamp for each Context
4. WHEN data changes, THE AI_Provider SHALL mark affected Context insights as stale
5. THE AI_Provider SHALL provide a method to manually refresh insights for a Context
6. THE AI_Provider SHALL cache insights until underlying data changes
7. THE AI_Provider SHALL listen to workout completion events to trigger insight updates
8. THE AI_Provider SHALL listen to meal logging events to trigger insight updates
9. THE AI_Provider SHALL listen to body weight recording events to trigger insight updates

### Requirement 4: Auto-Update Intelligence

**User Story:** As a user, I want insights to update automatically when I log data, so that I always see relevant coaching advice.

#### Acceptance Criteria

1. WHEN a workout is completed, THE AI_Provider SHALL regenerate insights for Home and Workout contexts
2. WHEN a meal is logged, THE AI_Provider SHALL regenerate insights for Home and Nutrition contexts
3. WHEN body weight is recorded, THE AI_Provider SHALL regenerate insights for Home and Profile contexts
4. THE AI_Provider SHALL use Change_Detection to avoid recalculating insights when data has not changed
5. THE AI_Provider SHALL NOT regenerate insights on every screen load
6. WHEN multiple data changes occur within 5 seconds, THE AI_Provider SHALL batch updates and regenerate once
7. THE AI_Provider SHALL persist insight cache to local storage to survive app restarts
8. WHEN app launches, THE AI_Provider SHALL check if cached insights are stale before regenerating

### Requirement 5: Reusable Insight Widget

**User Story:** As a user, I want to see AI insights on every main screen, so that coaching advice is always visible.

#### Acceptance Criteria

1. THE Insight_Widget SHALL display 2-3 insights in a glassmorphic card format
2. THE Insight_Widget SHALL accept a Context parameter to determine which insights to display
3. THE Insight_Widget SHALL show a loading state while insights are being generated
4. WHEN insights are unavailable, THE Insight_Widget SHALL display a friendly message
5. THE Insight_Widget SHALL use icons to visually categorize insights (e.g., 💪 for workouts, 🍽️ for nutrition)
6. THE Insight_Widget SHALL be tappable to navigate to the AI chat screen for detailed discussion
7. THE Insight_Widget SHALL animate in with a fade and slide effect
8. THE Insight_Widget SHALL match the app's glassmorphic design system

### Requirement 6: Home Screen Integration

**User Story:** As a user, I want to see overall progress and next steps on the Home screen, so that I know what to focus on today.

#### Acceptance Criteria

1. THE Home screen SHALL display the Insight_Widget below the weekly activity section
2. WHEN generating Home insights, THE Insight_Engine SHALL analyze overall consistency across all data types
3. WHEN generating Home insights, THE Insight_Engine SHALL identify the most important action for the user
4. THE Home insights SHALL include workout frequency analysis from the last 7 days
5. THE Home insights SHALL include nutrition tracking consistency from the last 7 days
6. WHEN the user has not trained in 3+ days, THE Home insights SHALL prioritize a workout reminder
7. WHEN the user has trained consistently, THE Home insights SHALL provide encouragement and next steps

### Requirement 7: Workout Screen Integration

**User Story:** As a user, I want to see workout-specific insights on the Workout screen, so that I can optimize my training.

#### Acceptance Criteria

1. THE Workout screen SHALL display the Insight_Widget at the top of the workout history list
2. WHEN generating Workout insights, THE Insight_Engine SHALL analyze Volume trends over the last 30 days
3. WHEN generating Workout insights, THE Insight_Engine SHALL analyze Progressive_Overload patterns
4. WHEN generating Workout insights, THE Insight_Engine SHALL identify muscle group balance (push/pull/legs)
5. WHEN a muscle group has not been trained in 7+ days, THE Workout insights SHALL recommend exercises for that group
6. THE Workout insights SHALL display recent PR achievements
7. WHEN Volume is decreasing, THE Workout insights SHALL suggest recovery or deload strategies

### Requirement 8: Nutrition Screen Integration

**User Story:** As a user, I want to see nutrition-specific insights on the Nutrition screen, so that I can optimize my diet.

#### Acceptance Criteria

1. THE Nutrition screen SHALL display the Insight_Widget above the daily meal list
2. WHEN generating Nutrition insights, THE Insight_Engine SHALL analyze average daily Macro_Targets adherence
3. WHEN generating Nutrition insights, THE Insight_Engine SHALL calculate protein intake as a percentage of target
4. WHEN protein intake is below 80% of target, THE Nutrition insights SHALL provide specific food recommendations
5. THE Nutrition insights SHALL display calorie tracking accuracy (days logged vs days missed)
6. WHEN calorie intake deviates more than 200 kcal from target, THE Nutrition insights SHALL provide adjustment recommendations
7. THE Nutrition insights SHALL analyze macro balance (protein/carbs/fats ratio)

### Requirement 9: Profile Screen Integration

**User Story:** As a user, I want to see long-term trends and goal progress on the Profile screen, so that I can track my overall fitness journey.

#### Acceptance Criteria

1. THE Profile screen SHALL display the Insight_Widget in the statistics section
2. WHEN generating Profile insights, THE Insight_Engine SHALL analyze body weight trends over the last 30 days
3. WHEN generating Profile insights, THE Insight_Engine SHALL calculate total workouts completed in the last 30 days
4. WHEN generating Profile insights, THE Insight_Engine SHALL compare current performance to 30 days ago
5. THE Profile insights SHALL display weight change direction and magnitude
6. WHEN weight change aligns with user goal, THE Profile insights SHALL provide positive reinforcement
7. WHEN weight change conflicts with user goal, THE Profile insights SHALL suggest dietary or training adjustments

### Requirement 10: Quick Feedback System

**User Story:** As a user, I want immediate feedback after completing actions, so that I feel motivated and informed.

#### Acceptance Criteria

1. WHEN a workout is completed, THE AI_Coach SHALL display a Quick_Feedback bottom sheet
2. THE Quick_Feedback bottom sheet SHALL appear automatically within 1 second of workout completion
3. THE Quick_Feedback SHALL highlight notable achievements (PR, volume records, consistency milestones)
4. WHEN a PR is achieved, THE Quick_Feedback SHALL display the specific exercise and weight
5. WHEN weekly Volume exceeds previous week by 10%+, THE Quick_Feedback SHALL celebrate the Progressive_Overload
6. THE Quick_Feedback SHALL include a call-to-action button to view detailed insights in AI chat
7. THE Quick_Feedback bottom sheet SHALL be dismissible by swiping down or tapping outside
8. THE Quick_Feedback SHALL use celebratory language and emojis for positive achievements

### Requirement 11: Performance Optimization

**User Story:** As a developer, I want insight generation to be performant, so that the app remains responsive.

#### Acceptance Criteria

1. THE Insight_Engine SHALL complete insight generation within 500ms for any Context
2. THE AI_Provider SHALL cache generated insights in memory
3. THE AI_Provider SHALL persist insight cache to local storage using Hive
4. WHEN cached insights are less than 1 hour old and data has not changed, THE AI_Provider SHALL return cached insights
5. THE AI_Provider SHALL use Change_Detection by comparing data timestamps to cache timestamps
6. THE Insight_Engine SHALL limit database queries to only the required date ranges
7. WHEN generating insights for multiple Contexts, THE AI_Provider SHALL reuse common data queries
8. THE AI_Provider SHALL generate insights asynchronously without blocking the UI thread

### Requirement 12: Chat Integration

**User Story:** As a user, I want to discuss insights in detail through chat, so that I can ask follow-up questions.

#### Acceptance Criteria

1. WHEN the Insight_Widget is tapped, THE app SHALL navigate to the AI chat screen
2. THE AI chat screen SHALL remain accessible from the Profile screen
3. WHEN navigating from an Insight_Widget, THE AI chat SHALL pre-populate context about the tapped insight
4. THE AI chat SHALL continue to use the existing LocalAICoach service for conversational responses
5. THE AI chat SHALL have access to the same data as the Insight_Engine
6. THE AI chat SHALL provide more detailed explanations than the Insight_Widget
7. THE AI chat SHALL allow users to ask specific questions about their data

### Requirement 13: Error Handling

**User Story:** As a user, I want graceful error handling when insights cannot be generated, so that the app remains usable.

#### Acceptance Criteria

1. WHEN insight generation fails, THE Insight_Widget SHALL display a friendly error message
2. WHEN insight generation fails, THE Insight_Widget SHALL provide a retry button
3. WHEN data is unavailable, THE Insight_Widget SHALL display onboarding guidance instead of an error
4. THE AI_Provider SHALL log insight generation errors for debugging
5. WHEN insight generation times out after 5 seconds, THE AI_Provider SHALL return cached insights if available
6. WHEN cached insights are unavailable and generation fails, THE Insight_Widget SHALL display generic motivational content
7. THE Insight_Widget SHALL never crash the app due to insight generation errors

### Requirement 14: Contextual Insight Rules

**User Story:** As a user, I want insights that are relevant to what I'm viewing, so that the coaching feels personalized.

#### Acceptance Criteria

1. WHEN Context is Home, THE Insight_Engine SHALL prioritize overall consistency and next actions
2. WHEN Context is Workout, THE Insight_Engine SHALL prioritize Volume, Progressive_Overload, and muscle balance
3. WHEN Context is Nutrition, THE Insight_Engine SHALL prioritize Macro_Targets adherence and calorie tracking
4. WHEN Context is Profile, THE Insight_Engine SHALL prioritize long-term trends and goal alignment
5. THE Insight_Engine SHALL NOT repeat the same insight across multiple Contexts
6. WHEN generating insights for a Context, THE Insight_Engine SHALL select the 2-3 most important insights
7. THE Insight_Engine SHALL prioritize actionable insights over descriptive insights
8. WHEN multiple insights have equal priority, THE Insight_Engine SHALL rotate insights on each generation

### Requirement 15: Data Privacy

**User Story:** As a user, I want my fitness data to remain private, so that I can trust the AI Coach.

#### Acceptance Criteria

1. THE Insight_Engine SHALL process all data locally on the device
2. THE AI_Coach SHALL NOT send user data to external servers
3. THE AI_Provider SHALL store insight cache locally using Hive
4. THE AI_Coach SHALL only access data that the user has explicitly logged
5. WHEN the user deletes data, THE AI_Provider SHALL invalidate related cached insights
6. THE AI_Coach SHALL comply with the app's existing data privacy policies
