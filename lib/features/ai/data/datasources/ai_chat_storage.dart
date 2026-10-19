import 'package:progression_tracker/core/utils/app_logger.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:progression_tracker/features/ai/domain/entities/chat_message.dart';

/// Persists and loads AI chat message history using Hive.
class AIChatStorage {
  static const String _boxName = 'ai_chat_history';
  static const String _messagesKey = 'messages';

  Future<Box?> get _box async {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        return Hive.box(_boxName);
      }
      return await Hive.openBox(_boxName);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [AIChatStorage] Hive not initialized or inaccessible: $e');
      }
      return null;
    }
  }

  /// Loads all stored chat messages in chronological order.
  Future<List<ChatMessage>> loadMessages() async {
    try {
      final box = await _box;
      if (box == null) return [];
      final raw = box.get(_messagesKey);
      if (raw == null) return [];

      if (raw is List) {
        final list = <ChatMessage>[];
        for (final item in raw) {
          try {
            if (item is String) {
              list.add(ChatMessage.fromJson(jsonDecode(item) as Map<String, dynamic>));
            } else if (item is Map) {
              list.add(ChatMessage.fromJson(Map<String, dynamic>.from(item)));
            }
          } catch (e) {
            if (kDebugMode) {
              AppLogger.debug('⚠️ [AIChatStorage] Failed to decode single chat message: $e');
            }
          }
        }
        return list;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [AIChatStorage] Error loading chat history: $e');
      }
      return [];
    }
  }

  /// Saves the full list of chat messages to persistent storage.
  Future<void> saveMessages(List<ChatMessage> messages) async {
    try {
      final box = await _box;
      if (box == null) return;
      final encodedList = messages.map((m) => jsonEncode(m.toJson())).toList();
      await box.put(_messagesKey, encodedList);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [AIChatStorage] Error saving chat history: $e');
      }
    }
  }

  /// Clears all stored chat messages.
  Future<void> clearMessages() async {
    try {
      final box = await _box;
      if (box == null) return;
      await box.delete(_messagesKey);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [AIChatStorage] Error clearing chat history: $e');
      }
    }
  }
}

final aiChatStorageProvider = Provider<AIChatStorage?>((ref) {
  return AIChatStorage();
});
