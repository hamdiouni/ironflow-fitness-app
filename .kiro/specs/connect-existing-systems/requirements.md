# Requirements Document: Connect Existing Systems in IronFlow

## Introduction

IronFlow is a fully built Flutter fitness app with Clean Architecture implementing workout tracking, nutrition logging, progress monitoring, and AI-powered program generation. All 24 tasks from the original spec are complete. However, the generated workout programs and diet plans exist in isolation and are not integrated into the actual user workflow. This feature connects 8 existing systems to create a cohesive, end-to-end user experience where generated programs become the single source of truth for workout sessions and diet plans drive nutrition tracking.

## Glossary

- **IronFlow**: The Flutter fitness application
- **User**: A person using IronFlow to track fitness activities
- **Active_Program**: The currently selected workout program that drives workout sessions
- **Workout_Program**: A structured multi-day training plan with exercises, sets, reps, and rest periods
- **Program_Day**: A single day within a Workout_Program containing exercises or rest
- **Program_Exercise**: An exercise definition within a Program_Day specifying sets, reps, and rest
- **Workout_Session**: A single training session where the User logs sets and reps
- **Exercise**: A specific movement performed during a Workout_Session
- **Set_Entry**: A logged set with reps, weight, and timestamp
- **Diet_Plan**: A structured meal plan with daily calorie and macro targets
- **Meal_Entry**: A logged meal with calories and macronutrient breakdown
- **Nutrition_Screen**: The UI displaying daily nutrition summary and logged meals
- **Onboarding_Flow**: The initial user setup collecting fitness goals and preferences
- **User_Profile**: Data collected during onboarding (goals, equipment, fitness level)
- **Program_Generator**: The use case that creates Workout_Programs based on User_Profile
- **Diet_Generator**: The use case that creates Diet_Plans based on User_Profile
- **Video_Player**: The component displaying exercise demonstration videos
- **Split_Type**: The training split structure (Full Body, Upper-Lower, Push-Pull-Legs)
- **Active_Program_Provider**: The Riverpod provider managing the Active_Program state
- **Workout_Flow**: The sequence from starting a workout to completing and saving it
- **Program_Editor**: The UI allowing Users to modify exercises, sets, reps, and order
- **Drag_Drop_Interface**: The UI pattern for reordering exercises via touch gestures
- **Fallback_Exercises**: Default exercises loaded when no Active_Program exists
- **Single_Source_Of_Truth**: Architecture pattern where one data source drives all dependent features

## Requirements

### Requirement 1: Active Program as Single Source of Truth

**User Story:** As a User, I want my generated workout program to be the single source of truth for all workout sessions, so that I follow a structured plan instead of random exercises.

#### Acceptance Criteria

1. THE IronFlow SHALL define an Active_Program entity containing program_id, program_name, selected_split, current_day_index, and is_active status
2. WHEN the User completes onboarding, THE Program_Generator SHALL create a Workout_Program and THE IronFlow SHALL save it as the Active_Program
3. WHEN the User taps "Start Workout", THE Workout_Flow SHALL load exercises FROM the Active_Program for the current day
4. THE Active_Program_Provider SHALL be the single source of truth for workout exercises
5. THE Workout_Flow SHALL NOT load Fallback_Exercises when an Active_Program exists
6. WHEN no Active_Program exists, THE Workout_Flow SHALL display an empty state prompting program generation

### Requirement 2: Program Selection and Multiple Splits

**User Story:** As a User, I want to select from multiple training splits and save my choice as the active program, so that I can train according to my preferred schedule.

#### Acceptance Criteria

1. THE IronFlow SHALL provide three Split_Types: Full Body (3 days), Upper-Lower (4 days), and Push-Pull-Legs (6 days)
2. WHEN the User views available programs, THE IronFlow SHALL display all three Split_Types with descriptions and day counts
3. WHEN the User selects a Split_Type, THE Program_Generator SHALL create a Workout_Program matching that split
4. WHEN the User confirms selection, THE IronFlow SHALL save the selected program as the Active_Program
5. THE Active_Program_Provider SHALL update immediately when a new program is selected
6. WHEN the Active_Program changes, THE Workout_Flow SHALL load exercises from the new program

### Requirement 3: Program Editing Capabilities

**User Story:** As a User, I want to edit my workout program by replacing exercises, changing sets and reps, and reordering exercises, so that I can customize the program to my needs.

#### Acceptance Criteria

1. WHEN the User opens the Program_Editor, THE IronFlow SHALL display all Program_Days with their exercises
2. WHEN the User taps an exercise, THE Program_Editor SHALL display options to replace, edit sets/reps, or delete
3. WHEN the User selects "Replace Exercise", THE Program_Editor SHALL display an exercise picker filtered by muscle group
4. WHEN the User changes sets or reps, THE Program_Editor SHALL update the Program_Exercise immediately
5. WHEN the User initiates drag gesture on an exercise, THE Drag_Drop_Interface SHALL enable reordering
6. WHEN the User drops an exercise in a new position, THE Program_Editor SHALL update the exercise order in the Program_Day
7. WHEN the User saves edits, THE IronFlow SHALL persist the modified Active_Program to local storage
8. THE Program_Editor SHALL validate that sets are positive integers and reps are valid ranges

### Requirement 4: Video Player Implementation Fix

**User Story:** As a User, I want exercise videos to play automatically with sound muted and expand on tap, so that I can quickly see proper form without manual controls.

#### Acceptance Criteria

1. THE Video_Player SHALL use the video_player package exclusively
2. THE Video_Player SHALL NOT use the url_launcher package for video playback
3. WHEN an exercise video loads, THE Video_Player SHALL autoplay with muted audio
4. WHEN the User taps the video, THE Video_Player SHALL expand to fullscreen mode
5. WHEN the User taps again in fullscreen, THE Video_Player SHALL return to inline mode
6. IF video loading fails, THEN THE Video_Player SHALL display a fallback image with an error message
7. THE Video_Player SHALL display a loading indicator while the video buffers

### Requirement 5: Onboarding to Workout Flow Integration

**User Story:** As a User, I want to be guided from onboarding through program generation to my first workout, so that I can start training immediately without empty states.

#### Acceptance Criteria

1. WHEN the User completes the Onboarding_Flow, THE IronFlow SHALL immediately invoke the Program_Generator
2. WHEN the Program_Generator completes, THE IronFlow SHALL save the result as the Active_Program
3. WHEN the Active_Program is saved, THE IronFlow SHALL navigate to the Workout_Screen
4. THE Workout_Screen SHALL display the first Program_Day from the Active_Program
5. THE IronFlow SHALL NOT display empty states or "no program" messages after onboarding
6. WHEN the User returns to the app after onboarding, THE IronFlow SHALL load the Active_Program automatically

### Requirement 6: Diet Plan Integration with Nutrition Screen

**User Story:** As a User, I want my generated diet plan to appear in the Nutrition screen with editable meals, so that I can follow structured nutrition guidance.

#### Acceptance Criteria

1. WHEN the User completes onboarding, THE Diet_Generator SHALL create a Diet_Plan based on User_Profile
2. THE Diet_Plan SHALL contain daily calorie target, macro targets, and suggested meals
3. WHEN the User opens the Nutrition_Screen, THE IronFlow SHALL display the Diet_Plan targets
4. THE Nutrition_Screen SHALL display suggested meals from the Diet_Plan as editable cards
5. WHEN the User taps a suggested meal, THE Nutrition_Screen SHALL display options to log, swap, or adjust quantity
6. WHEN the User adjusts meal quantity, THE Nutrition_Screen SHALL recalculate calories and macros dynamically
7. WHEN the User swaps a meal, THE Nutrition_Screen SHALL display alternative meals matching the macro profile
8. THE Nutrition_Screen SHALL update macro wheel and remaining macros within 200ms of meal changes

### Requirement 7: State Management Architecture for Active Program

**User Story:** As a developer, I want the Active_Program_Provider to manage program state consistently, so that all screens reflect the current program without duplication.

#### Acceptance Criteria

1. THE IronFlow SHALL define an Active_Program_Provider using Riverpod StateNotifier
2. THE Active_Program_Provider SHALL expose methods: setActiveProgram, updateProgram, clearProgram, getCurrentDay
3. WHEN setActiveProgram is called, THE Active_Program_Provider SHALL persist the program to local storage
4. WHEN updateProgram is called, THE Active_Program_Provider SHALL merge changes and persist
5. THE Workout_Flow SHALL watch the Active_Program_Provider for exercise data
6. THE Program_Editor SHALL watch the Active_Program_Provider for editing
7. WHEN the Active_Program_Provider state changes, THE IronFlow SHALL notify all watching widgets within 100ms
8. THE Active_Program_Provider SHALL load the Active_Program from local storage on app launch

### Requirement 8: Workout Session Using Active Program

**User Story:** As a User, I want my workout sessions to use exercises from my active program with suggested sets and reps, so that I follow my structured plan.

#### Acceptance Criteria

1. WHEN the User starts a Workout_Session, THE Workout_Flow SHALL retrieve the current Program_Day from Active_Program_Provider
2. WHEN the current Program_Day is retrieved, THE Workout_Flow SHALL create Exercise entities from Program_Exercises
3. THE Workout_Flow SHALL display each exercise with suggested sets and reps from the Program_Exercise
4. WHEN the User logs a Set_Entry, THE Workout_Flow SHALL compare performance against suggested targets
5. WHEN the User completes all suggested sets, THE Workout_Flow SHALL highlight the exercise as complete
6. WHEN the User finishes the Workout_Session, THE Active_Program_Provider SHALL increment current_day_index
7. WHEN current_day_index exceeds the program length, THE Active_Program_Provider SHALL reset to day 1

### Requirement 9: Program Day Navigation

**User Story:** As a User, I want to navigate between program days and see which day I'm on, so that I can follow the weekly structure.

#### Acceptance Criteria

1. THE Workout_Screen SHALL display the current Program_Day name and day number
2. THE Workout_Screen SHALL display a week view showing all Program_Days with current day highlighted
3. WHEN the User taps a different day in the week view, THE Workout_Screen SHALL load that Program_Day
4. WHEN the User manually selects a day, THE Active_Program_Provider SHALL update current_day_index
5. THE Workout_Screen SHALL indicate rest days with a distinct visual style
6. WHEN the current day is a rest day, THE Workout_Screen SHALL display rest day message and disable "Start Workout"

### Requirement 10: Program Persistence and Recovery

**User Story:** As a User, I want my active program and progress to persist across app restarts, so that I don't lose my place in the program.

#### Acceptance Criteria

1. WHEN the Active_Program_Provider updates, THE IronFlow SHALL save the Active_Program to Hive local storage
2. THE IronFlow SHALL store program_id, current_day_index, and last_workout_date in the Active_Program record
3. WHEN the app launches, THE Active_Program_Provider SHALL load the Active_Program from local storage
4. IF no Active_Program exists in local storage, THEN THE Active_Program_Provider SHALL set state to null
5. WHEN the User completes a Workout_Session, THE IronFlow SHALL update last_workout_date in the Active_Program
6. THE IronFlow SHALL use last_workout_date to suggest the next Program_Day based on rest days

### Requirement 11: Exercise Replacement in Active Program

**User Story:** As a User, I want to replace exercises in my active program with alternatives, so that I can adapt to equipment availability or preferences.

#### Acceptance Criteria

1. WHEN the User taps "Replace Exercise" in the Program_Editor, THE IronFlow SHALL display an exercise picker
2. THE exercise picker SHALL filter exercises by the same muscle group as the original exercise
3. WHEN the User selects a replacement exercise, THE Program_Editor SHALL update the Program_Exercise with the new exercise name
4. THE Program_Editor SHALL preserve the original sets, reps, and rest seconds when replacing
5. WHEN the replacement is confirmed, THE Active_Program_Provider SHALL persist the updated program
6. THE Workout_Flow SHALL use the replacement exercise in subsequent Workout_Sessions

### Requirement 12: Macro Wheel Dynamic Updates

**User Story:** As a User, I want the macro wheel to update immediately when I log or modify meals, so that I see real-time progress toward my targets.

#### Acceptance Criteria

1. THE Nutrition_Screen SHALL display a macro wheel showing protein, carbs, and fats distribution
2. WHEN the User logs a Meal_Entry, THE Nutrition_Screen SHALL recalculate total macros within 200ms
3. WHEN total macros change, THE Nutrition_Screen SHALL animate the macro wheel to reflect new proportions
4. THE macro wheel animation SHALL complete within 300ms
5. THE Nutrition_Screen SHALL display remaining macros as numeric values below the wheel
6. WHEN remaining macros reach zero or negative, THE Nutrition_Screen SHALL change the color to red

### Requirement 13: Program Generation Trigger Points

**User Story:** As a User, I want to generate a new program when I complete my current one or want to change goals, so that I can continue structured training.

#### Acceptance Criteria

1. WHEN the User completes the final day of the Active_Program, THE IronFlow SHALL display a "Program Complete" message
2. THE "Program Complete" message SHALL offer options to restart the program or generate a new one
3. WHEN the User selects "Generate New Program", THE IronFlow SHALL navigate to program selection
4. THE program selection screen SHALL allow the User to choose a new Split_Type
5. WHEN the User confirms, THE Program_Generator SHALL create a new Workout_Program
6. THE IronFlow SHALL replace the Active_Program with the newly generated program
7. THE IronFlow SHALL reset current_day_index to 1 when a new program is set

### Requirement 14: Video Player Fallback Handling

**User Story:** As a User, I want to see a clear fallback when exercise videos fail to load, so that I'm not blocked from continuing my workout.

#### Acceptance Criteria

1. WHEN the Video_Player fails to load a video, THE Video_Player SHALL catch the error
2. THE Video_Player SHALL display a static fallback image showing the exercise
3. THE Video_Player SHALL display an error message "Video unavailable" below the image
4. THE Video_Player SHALL NOT block the User from logging sets when video fails
5. THE Video_Player SHALL log the error to console for debugging
6. THE Video_Player SHALL retry loading once after a 2-second delay

### Requirement 15: Diet Plan Meal Swapping

**User Story:** As a User, I want to swap suggested meals with alternatives that have similar macros, so that I can adapt the diet plan to my preferences.

#### Acceptance Criteria

1. WHEN the User taps "Swap Meal" on a suggested meal, THE Nutrition_Screen SHALL display alternative meals
2. THE alternative meals SHALL have macro profiles within 10% of the original meal
3. THE Nutrition_Screen SHALL display at least 3 alternative meals if available
4. WHEN the User selects an alternative, THE Nutrition_Screen SHALL replace the suggested meal
5. THE Nutrition_Screen SHALL recalculate daily totals with the new meal
6. THE swapped meal SHALL persist in the Diet_Plan for future days

### Requirement 16: Program Editor Validation

**User Story:** As a User, I want the program editor to prevent invalid inputs, so that my program remains structurally sound.

#### Acceptance Criteria

1. WHEN the User enters sets, THE Program_Editor SHALL validate that the value is a positive integer
2. WHEN the User enters reps, THE Program_Editor SHALL validate that the value is a positive integer or valid range (e.g., "8-12")
3. WHEN the User enters rest seconds, THE Program_Editor SHALL validate that the value is a non-negative integer
4. IF validation fails, THEN THE Program_Editor SHALL display an error message and prevent saving
5. THE Program_Editor SHALL NOT allow deleting all exercises from a Program_Day
6. WHEN the User attempts to save an invalid program, THE Program_Editor SHALL highlight invalid fields

### Requirement 17: Active Program Indicator

**User Story:** As a User, I want to see which program is currently active, so that I know what I'm following.

#### Acceptance Criteria

1. THE Workout_Screen SHALL display the Active_Program name at the top
2. THE Workout_Screen SHALL display the Split_Type (e.g., "Upper-Lower Split")
3. THE Workout_Screen SHALL display the current week number if the program has multiple weeks
4. WHEN no Active_Program exists, THE Workout_Screen SHALL display "No Active Program"
5. THE Workout_Screen SHALL provide a button to view or change the Active_Program

### Requirement 18: Nutrition Screen Diet Plan Display

**User Story:** As a User, I want to see my daily calorie and macro targets from my diet plan, so that I know what to aim for.

#### Acceptance Criteria

1. THE Nutrition_Screen SHALL display daily calorie target at the top
2. THE Nutrition_Screen SHALL display macro targets for protein, carbs, and fats
3. THE Nutrition_Screen SHALL display consumed amounts for each macro
4. THE Nutrition_Screen SHALL display remaining amounts for each macro
5. WHEN the User has no Diet_Plan, THE Nutrition_Screen SHALL display default targets (2000 calories, 150g protein, 200g carbs, 60g fats)
6. THE Nutrition_Screen SHALL provide a button to generate or edit the Diet_Plan

### Requirement 19: Program Day Completion Tracking

**User Story:** As a User, I want to see which program days I've completed, so that I can track my consistency.

#### Acceptance Criteria

1. THE Workout_Screen week view SHALL display a checkmark on completed Program_Days
2. WHEN the User completes a Workout_Session, THE Active_Program_Provider SHALL mark the current day as complete
3. THE IronFlow SHALL store completion status with date in the Active_Program record
4. THE Workout_Screen SHALL display completion percentage for the current week
5. WHEN the User views program history, THE IronFlow SHALL display completion data for past weeks

### Requirement 20: Exercise Video Autoplay Control

**User Story:** As a User, I want videos to autoplay muted so I can quickly see form, but I want to enable sound if needed.

#### Acceptance Criteria

1. WHEN the Video_Player loads, THE Video_Player SHALL autoplay with volume set to 0
2. THE Video_Player SHALL display a volume icon indicating muted state
3. WHEN the User taps the volume icon, THE Video_Player SHALL unmute and set volume to 1.0
4. WHEN the User taps the volume icon again, THE Video_Player SHALL mute
5. THE Video_Player SHALL remember volume preference for the current session
6. WHEN the User navigates away and returns, THE Video_Player SHALL reset to muted autoplay
