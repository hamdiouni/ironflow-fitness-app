import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Service for generating images using FREE Hugging Face API
/// Uses Stable Diffusion model - 100% FREE, rate-limited
class ImageGenerationService {
  // Hugging Face Inference API (FREE tier)
  static const String _apiUrl =
      'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1';

  // Optional: Add your Hugging Face API token for faster inference
  // Get free token at: https://huggingface.co/settings/tokens
  // Leave empty for anonymous access (slower but still free)
  static const String _apiToken = ''; // Optional, leave empty for free access

  /// Generate an image from a text prompt
  /// Returns image bytes or null if generation fails
  Future<Uint8List?> generateImage(String prompt, {int retryCount = 0}) async {
    try {
      print('🎨 Generating image for: $prompt');

      final headers = {
        'Content-Type': 'application/json',
        if (_apiToken.isNotEmpty) 'Authorization': 'Bearer $_apiToken',
      };

      final body = jsonEncode({
        'inputs': prompt,
        'options': {
          'wait_for_model': true, // Wait if model is loading
        },
      });

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 60), // Generous timeout for free tier
      );

      if (response.statusCode == 200) {
        print('✅ Image generated successfully');
        return response.bodyBytes;
      } else if (response.statusCode == 503 && retryCount < 2) {
        // Model is loading, retry after a delay (max 2 retries)
        print('⏳ Model is loading, retrying in 10 seconds... (attempt ${retryCount + 1}/2)');
        await Future.delayed(const Duration(seconds: 10));
        return generateImage(prompt, retryCount: retryCount + 1); // Retry with counter
      } else {
        print('❌ Image generation failed: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Image generation error: $e');
      // CORS error on web - image generation not available in browser
      if (e.toString().contains('Failed to fetch') || e.toString().contains('CORS')) {
        print('⚠️ Image generation not available on web (CORS restriction)');
        print('💡 Image generation will work on Android/iOS apps');
      }
      return null;
    }
  }

  /// Generate a fitness-optimized image prompt
  /// Converts user request into a detailed prompt for better results
  String createFitnessPrompt(String userRequest) {
    // Clean up the request
    final cleanRequest = userRequest.toLowerCase().trim();

    // Add fitness-specific styling for better results
    final enhancedPrompt = '''
$userRequest, fitness illustration, professional diagram, clean background, 
high quality, detailed, anatomically correct, exercise demonstration, 
fitness guide style, clear and educational
'''.trim();

    return enhancedPrompt;
  }

  /// Check if a message likely needs an image
  bool shouldGenerateImage(String message) {
    final lowerMessage = message.toLowerCase();

    // Keywords that suggest image generation would be helpful
    final imageKeywords = [
      'show me',
      'what does',
      'how to',
      'demonstrate',
      'picture',
      'image',
      'diagram',
      'illustration',
      'visual',
      'form check',
      'proper form',
      'exercise',
      'workout',
      'muscle',
      'anatomy',
    ];

    return imageKeywords.any((keyword) => lowerMessage.contains(keyword));
  }
}

/// Pre-made exercise image database
/// Maps exercise names to free stock image URLs
class ExerciseImageDatabase {
  /// Get image URL for a specific exercise
  /// Returns null if no image is available
  static String? getExerciseImage(String exerciseName) {
    final cleanName = exerciseName.toLowerCase().trim();

    // Map of exercise names to free image URLs
    // Using Unsplash (free, no attribution required for this use)
    final exerciseImages = {
      // Chest exercises
      'bench press': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      'push up': 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800',
      'pushup': 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800',
      'chest press': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      'dumbbell press': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',

      // Back exercises
      'pull up': 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800',
      'pullup': 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800',
      'deadlift': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
      'row': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
      'lat pulldown': 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800',

      // Leg exercises
      'squat': 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
      'leg press': 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
      'lunge': 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
      'leg curl': 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
      'leg extension': 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',

      // Shoulder exercises
      'shoulder press': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      'lateral raise': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      'overhead press': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',

      // Arm exercises
      'bicep curl': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
      'tricep extension': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
      'dumbbell curl': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',

      // Core exercises
      'plank': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      'crunch': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      'sit up': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      'situp': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',

      // Cardio
      'running': 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
      'cycling': 'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800',
      'treadmill': 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',

      // General fitness
      'gym': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
      'workout': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
      'fitness': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
    };

    return exerciseImages[cleanName];
  }

  /// Extract exercise names from AI response text
  static List<String> extractExercises(String text) {
    final lowerText = text.toLowerCase();
    final exercises = <String>[];

    // Check for each exercise in our database
    final allExercises = [
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

    for (final exercise in allExercises) {
      if (lowerText.contains(exercise)) {
        exercises.add(exercise);
      }
    }

    return exercises.toSet().toList(); // Remove duplicates
  }
}
