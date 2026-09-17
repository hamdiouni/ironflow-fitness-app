import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/image_generation_service.dart';

/// Provider for image generation service
final imageGenerationServiceProvider = Provider<ImageGenerationService>((ref) {
  return ImageGenerationService();
});

/// State for image generation
class ImageGenerationState {
  final bool isGenerating;
  final Uint8List? generatedImage;
  final String? error;
  final List<String> exerciseImages; // URLs of pre-made exercise images

  ImageGenerationState({
    this.isGenerating = false,
    this.generatedImage,
    this.error,
    this.exerciseImages = const [],
  });

  ImageGenerationState copyWith({
    bool? isGenerating,
    Uint8List? generatedImage,
    String? error,
    List<String>? exerciseImages,
  }) {
    return ImageGenerationState(
      isGenerating: isGenerating ?? this.isGenerating,
      generatedImage: generatedImage ?? this.generatedImage,
      error: error ?? this.error,
      exerciseImages: exerciseImages ?? this.exerciseImages,
    );
  }
}

/// Provider for image generation state
class ImageGenerationNotifier extends StateNotifier<ImageGenerationState> {
  final ImageGenerationService _service;

  ImageGenerationNotifier(this._service) : super(ImageGenerationState());

  /// Generate an image from a prompt
  Future<void> generateImage(String prompt) async {
    state = state.copyWith(
      isGenerating: true,
      error: null,
      generatedImage: null,
    );

    try {
      // Create fitness-optimized prompt
      final enhancedPrompt = _service.createFitnessPrompt(prompt);

      // Generate image
      final imageBytes = await _service.generateImage(enhancedPrompt);

      if (imageBytes != null) {
        state = state.copyWith(
          isGenerating: false,
          generatedImage: imageBytes,
        );
      } else {
        state = state.copyWith(
          isGenerating: false,
          error: 'Failed to generate image. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Error: $e',
      );
    }
  }

  /// Extract and load exercise images from AI response
  void loadExerciseImages(String aiResponse) {
    final exercises = ExerciseImageDatabase.extractExercises(aiResponse);
    final imageUrls = <String>[];

    for (final exercise in exercises) {
      final imageUrl = ExerciseImageDatabase.getExerciseImage(exercise);
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }

    state = state.copyWith(exerciseImages: imageUrls);
  }

  /// Clear generated image
  void clearImage() {
    state = state.copyWith(
      generatedImage: null,
      error: null,
      exerciseImages: [],
    );
  }

  /// Check if message should trigger image generation
  bool shouldGenerateImage(String message) {
    return _service.shouldGenerateImage(message);
  }
}

/// Provider for image generation notifier
final imageGenerationProvider =
    StateNotifierProvider<ImageGenerationNotifier, ImageGenerationState>((ref) {
  final service = ref.watch(imageGenerationServiceProvider);
  return ImageGenerationNotifier(service);
});
