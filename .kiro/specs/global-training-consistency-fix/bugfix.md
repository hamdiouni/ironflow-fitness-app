# Bugfix Requirements Document

## Introduction

The IronFlow fitness app has hardcoded fallback values that override the user's training configuration (`workoutDaysPerWeek`) stored in their UserProfile. This causes inconsistencies where users select a specific number of workout days per week during onboarding, but the app displays different targets or calculations in various screens. This bug affects the home screen, analytics screen, and analytics repository, leading to incorrect weekly targets, consistency calculations, and adherence rates.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN the user's profile is null or unavailable in the home screen THEN the system defaults to 4 workout days per week instead of handling the null case appropriately

1.2 WHEN the analytics screen calculates weekly consistency THEN the system divides by hardcoded value 5 instead of using the user's configured `workoutDaysPerWeek`

1.3 WHEN the analytics provider calculates weekly consistency THEN the system divides by hardcoded value 5 instead of using the user's configured `workoutDaysPerWeek`

1.4 WHEN the analytics repository calculates adherence rate THEN the system multiplies by hardcoded value 5 instead of using the user's configured `workoutDaysPerWeek`

1.5 WHEN a user configures 3 workout days per week during onboarding THEN the system displays targets and calculations based on 4 or 5 days instead of 3 days

1.6 WHEN a user configures 6 workout days per week during onboarding THEN the system displays targets and calculations based on 4 or 5 days instead of 6 days

### Expected Behavior (Correct)

2.1 WHEN the user's profile is null or unavailable in the home screen THEN the system SHALL handle the edge case gracefully without assuming a default value (e.g., show loading state or prompt user to complete profile)

2.2 WHEN the analytics screen calculates weekly consistency THEN the system SHALL use the user's `workoutDaysPerWeek` from their UserProfile as the divisor

2.3 WHEN the analytics provider calculates weekly consistency THEN the system SHALL use the user's `workoutDaysPerWeek` from their UserProfile as the divisor

2.4 WHEN the analytics repository calculates adherence rate THEN the system SHALL use the user's `workoutDaysPerWeek` from their UserProfile as the multiplier

2.5 WHEN a user configures 3 workout days per week during onboarding THEN the system SHALL display targets and calculations based on 3 days consistently across all screens

2.6 WHEN a user configures 6 workout days per week during onboarding THEN the system SHALL display targets and calculations based on 6 days consistently across all screens

### Unchanged Behavior (Regression Prevention)

3.1 WHEN the user's profile contains a valid `workoutDaysPerWeek` value THEN the system SHALL CONTINUE TO use that value for weekly target calculations in the home screen

3.2 WHEN the home screen displays the weekly activity ring THEN the system SHALL CONTINUE TO show the correct progress percentage based on the user's target

3.3 WHEN the analytics screen displays consistency metrics THEN the system SHALL CONTINUE TO show accurate statistics based on workout history

3.4 WHEN the user completes onboarding and sets their `workoutDaysPerWeek` THEN the system SHALL CONTINUE TO save this value correctly in the UserProfile

3.5 WHEN the user views their profile THEN the system SHALL CONTINUE TO display their configured `workoutDaysPerWeek` value correctly

3.6 WHEN the user has completed workouts THEN the system SHALL CONTINUE TO count and display them accurately in all screens

3.7 WHEN the user refreshes the home screen THEN the system SHALL CONTINUE TO reload data from the UserProfile and workout history

3.8 WHEN the analytics repository calculates strength progression THEN the system SHALL CONTINUE TO calculate it correctly without being affected by the consistency fix

3.9 WHEN the analytics repository calculates weight tracking THEN the system SHALL CONTINUE TO calculate it correctly without being affected by the consistency fix

3.10 WHEN the user has no workout history THEN the system SHALL CONTINUE TO display appropriate empty states and zero values
