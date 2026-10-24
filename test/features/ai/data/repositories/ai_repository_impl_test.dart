import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_service.dart';
import 'package:progression_tracker/features/ai/data/repositories/ai_repository_impl.dart';

void main() {
  group('AIRepositoryImpl context policy', () {
    test('returns empty context when no consent-gated builder is injected',
        () async {
      final repository = AIRepositoryImpl(
        aiService: AIService(apiKey: 'test-key'),
      );

      expect(await repository.getContext(), isEmpty);
    });

    test('returns caller-supplied context from the injected builder', () async {
      final repository = AIRepositoryImpl(
        aiService: AIService(apiKey: 'test-key'),
        contextBuilder: () async => 'CONSENTED_CONTEXT',
      );

      expect(await repository.getContext(), 'CONSENTED_CONTEXT');
    });

    test('context builder failures fall back to empty context', () async {
      final repository = AIRepositoryImpl(
        aiService: AIService(apiKey: 'test-key'),
        contextBuilder: () async => throw StateError('gather failed'),
      );

      expect(await repository.getContext(), isEmpty);
    });
  });
}
