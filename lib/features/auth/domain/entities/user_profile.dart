import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String userId,
    required String email,
    required String? name,
    required int? age,
    required String? gender,
    required String? fitnessLevel, // beginner, intermediate, advanced
    required List<String>? goals, // strength, hypertrophy, endurance, weight-loss
    required List<String>? equipment, // barbell, dumbbell, machine, bodyweight
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
