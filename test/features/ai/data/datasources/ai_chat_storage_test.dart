import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_chat_storage.dart';
import 'package:progression_tracker/features/ai/domain/entities/chat_message.dart';

void main() {
  late Directory tempDir;
  late Box chatBox;

  ChatMessage message(String id) {
    return ChatMessage(
      id: id,
      role: 'user',
      content: 'Message $id',
      timestamp: DateTime(2026, 1, 1, 12),
    );
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('ai_chat_scope_');
    Hive.init(tempDir.path);
    chatBox = await Hive.openBox('ai_chat_history');
  });

  setUp(() async {
    await chatBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('chat history is stored separately for each user', () async {
    final aliceStorage = AIChatStorage(userId: 'Alice');
    final bobStorage = AIChatStorage(userId: 'bob');

    await aliceStorage.saveMessages(<ChatMessage>[message('Alice-1')]);
    await bobStorage.saveMessages(<ChatMessage>[message('bob-1')]);

    expect(
      (await aliceStorage.loadMessages()).map((item) => item.id),
      <String>['Alice-1'],
    );
    expect(
      (await bobStorage.loadMessages()).map((item) => item.id),
      <String>['bob-1'],
    );
    expect(chatBox.containsKey('messages_alice'), isTrue);
    expect(chatBox.containsKey('messages_bob'), isTrue);
    expect(chatBox.containsKey('messages'), isFalse);
  });

  test('legacy chat history is adopted only by the first scoped user',
      () async {
    await AIChatStorage().saveMessages(<ChatMessage>[message('legacy-1')]);
    final aliceStorage = AIChatStorage(userId: 'Alice');
    final bobStorage = AIChatStorage(userId: 'bob');

    expect(
      (await aliceStorage.loadMessages()).map((item) => item.id),
      <String>['legacy-1'],
    );
    expect(await bobStorage.loadMessages(), isEmpty);
    expect(chatBox.containsKey('messages_alice'), isTrue);
    expect(chatBox.containsKey('messages'), isFalse);
  });

  test('clearMessages removes only the scoped user history', () async {
    final aliceStorage = AIChatStorage(userId: 'Alice');
    final bobStorage = AIChatStorage(userId: 'bob');
    await aliceStorage.saveMessages(<ChatMessage>[message('Alice-1')]);
    await bobStorage.saveMessages(<ChatMessage>[message('bob-1')]);

    await aliceStorage.clearMessages();

    expect(await aliceStorage.loadMessages(), isEmpty);
    expect((await bobStorage.loadMessages()).single.id, 'bob-1');
  });
}
