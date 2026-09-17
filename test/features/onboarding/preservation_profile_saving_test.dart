import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';

/// Preservation Property Test - Task 2.2
/// 
/// **Validates: Requirements 3.4, 3.5**
/// 
/// This test verifies that during onboarding, `workoutDaysPerWeek` is saved
/// correctly to UserProfile and can be retrieved accurately. This is a 
/// PRESERVATION test that should PASS on UNFIXED code, confirming baseline 
/// behavior that must be maintained after the fix.
/// 
/// **Property**: For all valid `workoutDaysPerWeek` values (1-7), profile 
/// saves and retrieves correctly
/// 
/// **EXPECTED OUTCOME ON UNFIXED CODE**: Test PASSES
/// - Confirms that profile saving works correctly before the fix
/// - Establishes baseline behavior to preserve
/// 
/// **EXPECTED OUTCOME AFTER FIX**: Test PASSES
/// - Confirms that profile saving still works correctly after the fix
/// - No regression in profile saving functionality
/// 
/// This test uses property-based testing principles by testing all valid
/// values in the domain (workoutDaysPerWeek: 1-7) to ensure comprehensive
/// coverage of the input space.
/// 
/// Note: This test focuses on the data serialization/deserialization layer
/// (toJson/fromJson operations) which is independent of the consistency 
/// calculation bug. We test the serialization logic rather than the full
/// storage layer to avoid Hive initialization complexity in unit tests.
void main() {
  group('Preservation - Profile Saving', () {

    test('Property: workoutDaysPerWeek=1 serializes and deserializes correctly', () {
      // ARRANGE: Create profile with workoutDaysPerWeek = 1
      final profile = _createTestProfile(workoutDaysPerWeek: 1);

      // ACT: Serialize to JSON and deserialize back
      final json = profile.toJson();
      final deserialized = UserProfile.fromJson(json);

      // ASSERT: Deserialized profile should match original profile
      expect(deserialized.workoutDaysPerWeek, equals(1), 
          reason: 'workoutDaysPerWeek=1 should be preserved through serialization');
      _assertProfilesEqual(profile, deserialized);
    });

    test('Property: workoutDaysPerWeek=2 serializes and deserializes correctly', () {
      // ARRANGE: Create profile with workoutDaysPerWeek = 2
      final profile = _createTestProfile(workoutDaysPerWeek: 2);

      // ACT: Serialize to JSON and deserialize back
      final json = profile.toJson();
      final deserialized = UserProfile.fromJson(json);

      // ASSERT: Deserialized profile should match original profile
      expect(deserialized.workoutDaysPerWeek, equals(2), 
          reason: 'workoutDaysPerWeek=2 should be preserved through serialization');
      _assertProfilesEqual(profile, deserialized);
    });

    test('Property: workoutDaysPerWeek=3 serializes and deserializes correctly', () {
      // ARRANGE: Create profile with workoutDaysPerWeek = 3
      final profile = _createTestProfile(workoutDaysPerWeek: 3);

      // ACT: Serialize to JSON and deserialize back
      final json = profile.toJson();
      final deserialized = UserProfile.fromJson(json);

      // ASSERT: Deserialized profile should match original profile
      expect(deserialized.workoutDaysPerWeek, equals(3), 
          reason: 'workoutDaysPerWeek=3 should be preserved through serialization');
      _assertProfilesEqual(profile, deserialized);
    });

    test('Property: workoutDaysPerWeek=4 serializes and deserializes correctly', () {
      // ARRANGE: Create profile with workoutDaysPerWeek = 4
      final profile = _createTestProfile(workoutDaysPerWeek: 4);

      // ACT: Serialize to JSON and deserialize back
      final json = profile.toJson();
      final deserialized = UserProfile.fromJson(json);

      // ASSERT: Deserialized profile should match original profile
      expect(deserialized.workoutDaysPerWeek, equals(4), 
          reason: 'workoutDaysPerWeek=4 should be preserved through serialization');
      _assertProfilesEqual(profile, deserialized);
    });

    test('Property: workoutDaysPerWeek=5 serializes and deserializes correctly', () {
      // ARRANGE: Create profile with workoutDaysPerWeek = 5
      final profile = _createTestProfile(workoutDaysPerWeek: 5);

      // ACT: Serialize to JSON and deserialize back
      final json = profile.toJson();
      final deserialized = UserProfile.fromJson(json);

      // ASSERT: Deserialized profile should match original profile
      expect(deserialized.workoutDaysPerWeek, equals(5), 
          reason: 'workoutDaysPerWeek=5 should be preserved through serialization');
      _assertProfilesEqual(profile, deserialized);
    });

    test('Property: workoutDaysPerWeek=6 serializes and deserializes correctly', () {
      // ARRANGE: Create profile with workoutDaysPerWeek = 6
      final profile = _createTestProfile(workoutDaysPerWeek: 6);

      // ACT: Serialize to JSON and deserialize back
      final json = profile.toJson();
      final deserialized = UserProfile.fromJson(json);

      // ASSERT: Deserialized profile should match original profile
      expect(deserialized.workoutDaysPerWeek, equals(6), 
          reason: 'workoutDaysPerWeek=6 should be preserved through serialization');
      _assertProfilesEqual(profile, deserialized);
    });

    test('Property: workoutDaysPerWeek=7 serializes and deserializes correctly', () {
      // ARRANGE: Create profile with workoutDaysPerWeek = 7
      final profile = _createTestProfile(workoutDaysPerWeek: 7);

      // ACT: Serialize to JSON and deserialize back
      final json = profile.toJson();
      final deserialized = UserProfile.fromJson(json);

      // ASSERT: Deserialized profile should match original profile
      expect(deserialized.workoutDaysPerWeek, equals(7), 
          reason: 'workoutDaysPerWeek=7 should be preserved through serialization');
      _assertProfilesEqual(profile, deserialized);
    });

    test('Property: All valid workoutDaysPerWeek values (1-7) serialize correctly', () {
      // ARRANGE & ACT: Test all valid values in a loop
      for (int days = 1; days <= 7; days++) {
        final profile = _createTestProfile(workoutDaysPerWeek: days);
        
        // Serialize to JSON
        final json = profile.toJson();
        
        // Deserialize back
        final deserialized = UserProfile.fromJson(json);
        
        // ASSERT: Each value should serialize and deserialize correctly
        expect(deserialized.workoutDaysPerWeek, equals(days), 
            reason: 'workoutDaysPerWeek=$days should be preserved exactly through serialization');
        expect(json['workoutDaysPerWeek'], equals(days), 
            reason: 'JSON should contain workoutDaysPerWeek=$days');
      }
    });

    test('Property: Profile update preserves workoutDaysPerWeek changes', () {
      // ARRANGE: Create initial profile with workoutDaysPerWeek = 3
      final initialProfile = _createTestProfile(workoutDaysPerWeek: 3);

      // ACT: Update profile to workoutDaysPerWeek = 5
      final updatedProfile = initialProfile.copyWith(workoutDaysPerWeek: 5);
      
      // Serialize and deserialize the updated profile
      final json = updatedProfile.toJson();
      final deserialized = UserProfile.fromJson(json);

      // ASSERT: Updated value should be preserved
      expect(deserialized.workoutDaysPerWeek, equals(5), 
          reason: 'Updated workoutDaysPerWeek should be preserved');
      expect(deserialized.workoutDaysPerWeek, isNot(equals(3)), 
          reason: 'Old value should be replaced with new value');
    });

    test('Property: Multiple serialization cycles preserve workoutDaysPerWeek', () {
      // ARRANGE: Create profile with workoutDaysPerWeek = 4
      final profile = _createTestProfile(workoutDaysPerWeek: 4);

      // ACT: Perform multiple serialization/deserialization cycles
      UserProfile current = profile;
      for (int cycle = 0; cycle < 5; cycle++) {
        final json = current.toJson();
        current = UserProfile.fromJson(json);
        
        // ASSERT: Value should remain consistent across cycles
        expect(current.workoutDaysPerWeek, equals(4), 
            reason: 'workoutDaysPerWeek should remain 4 after cycle $cycle');
      }
    });

    test('Property: All profile fields are preserved during serialization', () {
      // ARRANGE: Create profile with all fields populated
      final profile = UserProfile(
        goal: FitnessGoal.gainMuscle,
        age: 28,
        weightKg: 75.5,
        heightCm: 180.0,
        fitnessLevel: FitnessLevel.intermediate,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 5,
        budget: BudgetLevel.medium,
      );

      // ACT: Serialize and deserialize
      final json = profile.toJson();
      final deserialized = UserProfile.fromJson(json);

      // ASSERT: All fields should be preserved
      expect(deserialized.goal, equals(profile.goal), 
          reason: 'Goal should be preserved');
      expect(deserialized.age, equals(profile.age), 
          reason: 'Age should be preserved');
      expect(deserialized.weightKg, equals(profile.weightKg), 
          reason: 'Weight should be preserved');
      expect(deserialized.heightCm, equals(profile.heightCm), 
          reason: 'Height should be preserved');
      expect(deserialized.fitnessLevel, equals(profile.fitnessLevel), 
          reason: 'Fitness level should be preserved');
      expect(deserialized.equipment, equals(profile.equipment), 
          reason: 'Equipment should be preserved');
      expect(deserialized.workoutDaysPerWeek, equals(profile.workoutDaysPerWeek), 
          reason: 'workoutDaysPerWeek should be preserved');
      expect(deserialized.budget, equals(profile.budget), 
          reason: 'Budget should be preserved');
    });

    test('Property: JSON contains correct workoutDaysPerWeek key and value', () {
      // ARRANGE: Create profile with workoutDaysPerWeek = 4
      final profile = _createTestProfile(workoutDaysPerWeek: 4);

      // ACT: Serialize to JSON
      final json = profile.toJson();

      // ASSERT: JSON should contain the correct key and value
      expect(json.containsKey('workoutDaysPerWeek'), isTrue, 
          reason: 'JSON should contain workoutDaysPerWeek key');
      expect(json['workoutDaysPerWeek'], equals(4), 
          reason: 'JSON workoutDaysPerWeek value should be 4');
      expect(json['workoutDaysPerWeek'], isA<int>(), 
          reason: 'JSON workoutDaysPerWeek should be an integer');
    });

    test('Property: copyWith preserves workoutDaysPerWeek when not updated', () {
      // ARRANGE: Create profile with workoutDaysPerWeek = 5
      final profile = _createTestProfile(workoutDaysPerWeek: 5);

      // ACT: Use copyWith to update other fields but not workoutDaysPerWeek
      final updated = profile.copyWith(age: 30, weightKg: 80.0);

      // ASSERT: workoutDaysPerWeek should remain unchanged
      expect(updated.workoutDaysPerWeek, equals(5), 
          reason: 'workoutDaysPerWeek should remain unchanged when not specified in copyWith');
      expect(updated.age, equals(30), 
          reason: 'Age should be updated');
      expect(updated.weightKg, equals(80.0), 
          reason: 'Weight should be updated');
    });

    test('Property: copyWith updates workoutDaysPerWeek when specified', () {
      // ARRANGE: Create profile with workoutDaysPerWeek = 3
      final profile = _createTestProfile(workoutDaysPerWeek: 3);

      // ACT: Use copyWith to update workoutDaysPerWeek
      final updated = profile.copyWith(workoutDaysPerWeek: 6);

      // ASSERT: workoutDaysPerWeek should be updated
      expect(updated.workoutDaysPerWeek, equals(6), 
          reason: 'workoutDaysPerWeek should be updated to 6');
      expect(profile.workoutDaysPerWeek, equals(3), 
          reason: 'Original profile should remain unchanged');
    });

    test('Property: Different profiles with different workoutDaysPerWeek values are distinct', () {
      // ARRANGE: Create profiles with different workoutDaysPerWeek values
      final profile1 = _createTestProfile(workoutDaysPerWeek: 2);
      final profile2 = _createTestProfile(workoutDaysPerWeek: 5);

      // ASSERT: Profiles should have different workoutDaysPerWeek values
      expect(profile1.workoutDaysPerWeek, equals(2), 
          reason: 'Profile 1 should have workoutDaysPerWeek=2');
      expect(profile2.workoutDaysPerWeek, equals(5), 
          reason: 'Profile 2 should have workoutDaysPerWeek=5');
      expect(profile1.workoutDaysPerWeek, isNot(equals(profile2.workoutDaysPerWeek)), 
          reason: 'Different profiles should have different workoutDaysPerWeek values');
    });
  });
}

/// Helper function to create a test profile with specified workoutDaysPerWeek
UserProfile _createTestProfile({required int workoutDaysPerWeek}) {
  return UserProfile(
    goal: FitnessGoal.loseWeight,
    age: 25,
    weightKg: 75.0,
    heightCm: 175.0,
    fitnessLevel: FitnessLevel.beginner,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: workoutDaysPerWeek,
    budget: BudgetLevel.medium,
  );
}

/// Helper function to assert that two profiles are equal
void _assertProfilesEqual(UserProfile expected, UserProfile actual) {
  expect(actual.goal, equals(expected.goal), 
      reason: 'Goal should match');
  expect(actual.age, equals(expected.age), 
      reason: 'Age should match');
  expect(actual.weightKg, equals(expected.weightKg), 
      reason: 'Weight should match');
  expect(actual.heightCm, equals(expected.heightCm), 
      reason: 'Height should match');
  expect(actual.fitnessLevel, equals(expected.fitnessLevel), 
      reason: 'Fitness level should match');
  expect(actual.equipment, equals(expected.equipment), 
      reason: 'Equipment should match');
  expect(actual.workoutDaysPerWeek, equals(expected.workoutDaysPerWeek), 
      reason: 'workoutDaysPerWeek should match');
  expect(actual.budget, equals(expected.budget), 
      reason: 'Budget should match');
}
