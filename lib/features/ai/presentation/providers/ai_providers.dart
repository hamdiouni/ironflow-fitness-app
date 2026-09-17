import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/ai_service.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/repositories/ai_repository.dart';

/// Provider for AI Service
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// Provider for AI Repository
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return AIRepositoryImpl(aiService: aiService);
});
