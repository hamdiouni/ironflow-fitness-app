import 'package:progression_tracker/core/utils/app_logger.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:progression_tracker/features/ai/domain/entities/chat_message.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';

/// Persists and loads AI chat message history using Hive.
class AIChatStorage {
  static const String _boxName = 'ai_chat_history';
  static const String _messagesKey = 'messages';

  /// Account that owns chat history read/written by this instance.
  /// Existing constructions without a user keep the legacy key.
  final String? userId;

  AIChatStorage({this.userId});

  String? get _scopeUserId =>
      RecordOwnershipRules.storageScope(userId);

  String get _scopedMessagesKey {
    final scopeUserId = _scopeUserId;
    return scopeUserId == null
        ? _messagesKey
        : '${_messagesKey}_$scopeUserId';
  }

  Future<dynamic> _rawMessages(Box box) async {
    final scopedRaw = box.get(_scopedMessagesKey);
    if (scopedRaw != null || _scopedMessagesKey == _messagesKey) {
      return scopedRaw;
    }

    // One-time adoption of a pre-scoping chat history, only when no
    // account-scoped history exists yet. Chat messages carry no owner
    // field, so the legacy history cannot be attributed safely after
    // scoped histories have been created.
    final hasScopedHistory = box.keys.any(
      (key) => key.toString().startsWith('${_messagesKey}_'),
    );
    if (hasScopedHistory) return null;

    final legacyRaw = box.get(_messagesKey);
    if (legacyRaw == null) return null;
    await box.put(_scopedMessagesKey, legacyRaw);
    await box.delete(_messagesKey);
    return legacyRaw;
  }

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
      final raw = await _rawMessages(box);
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
      await box.put(_scopedMessagesKey, encodedList);
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
      await box.delete(_scopedMessagesKey);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [AIChatStorage] Error clearing chat history: $e');
      }
    }
  }
}

final aiChatStorageProvider = Provider<AIChatStorage?>((ref) {
  final userId =
      ref.watch(currentUserIdProvider) ?? RecordOwnershipRules.guestUserId;
  return AIChatStorage(userId: userId);
});
