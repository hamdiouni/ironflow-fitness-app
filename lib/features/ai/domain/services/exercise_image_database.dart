/// Pre-made exercise image lookup mapping exercise names to stock image URLs.
class ExerciseImageDatabase {
  static const Map<String, String> _exerciseImages = {
    'bench press':
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'push up':
        'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800',
    'pushup':
        'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800',
    'chest press':
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'dumbbell press':
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'pull up':
        'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800',
    'pullup':
        'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800',
    'deadlift':
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
    'row':
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
    'lat pulldown':
        'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800',
    'squat':
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
    'leg press':
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
    'lunge':
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
    'leg curl':
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
    'leg extension':
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
    'shoulder press':
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'lateral raise':
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'overhead press':
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'bicep curl':
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
    'tricep extension':
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
    'dumbbell curl':
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
    'plank':
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'crunch':
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'sit up':
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'situp':
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    'running':
        'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
    'cycling':
        'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800',
    'treadmill':
        'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
    'gym':
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
    'workout':
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
    'fitness':
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
  };

  /// Returns an image URL for [exerciseName], or null when unmapped.
  static String? getExerciseImage(String exerciseName) {
    return _exerciseImages[exerciseName.toLowerCase().trim()];
  }

  /// Extracts known exercise names mentioned inside [text].
  static List<String> extractExercises(String text) {
    final lowerText = text.toLowerCase();
    const trackedExercises = [
      'bench press',
      'push up',
      'pushup',
      'pull up',
      'pullup',
      'deadlift',
      'squat',
      'lunge',
      'shoulder press',
      'lateral raise',
      'bicep curl',
      'tricep extension',
      'plank',
      'crunch',
      'running',
      'cycling',
    ];

    final found = <String>{};
    for (final exercise in trackedExercises) {
      if (lowerText.contains(exercise)) {
        found.add(exercise);
      }
    }
    return found.toList();
  }
}
