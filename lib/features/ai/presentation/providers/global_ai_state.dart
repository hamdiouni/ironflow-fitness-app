import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/insight.dart';

part 'global_ai_state.freezed.dart';

/// State for the Global AI Coach feature
///
/// Manages insights, loading states, errors, and quick feedback across all contexts.
/// Uses maps keyed by InsightContext for efficient context-specific access.
///
/// **State Structure:**
/// - insights: Map of context to list of insights (memory cache)
/// - lastUpdated: Map of context to last update timestamp
/// - isLoading: Map of context to loading state
/// - errors: Map of context to error messages
/// - quickFeedback: Optional quick feedback insight (post-workout)
///
/// **Requirements:**
/// - 3.1: Maintain separate insight lists for each Context
/// - 3.2: Track loading state per context
/// - 3.3: Track last update timestamp per context
@Freezed(toJson: false, fromJson: false)
class GlobalAIState with _$GlobalAIState {
  const factory GlobalAIState({
    /// Map of context to list of insights (memory cache)
    /// 
    /// This is the primary in-memory cache for quick access to insights.
    /// Each context maintains its own list of 2-3 prioritized insights.
    @Default({}) Map<InsightContext, List<Insight>> insights,
    
    /// Map of context to last update timestamp
    /// 
    /// Tracks when insights were last generated for each context.
    /// Used for change detection and cache staleness checks.
    @Default({}) Map<InsightContext, DateTime> lastUpdated,
    
    /// Map of context to loading state
    /// 
    /// Indicates whether insights are currently being generated for a context.
    /// UI uses this to show loading indicators.
    @Default({}) Map<InsightContext, bool> isLoading,
    
    /// Map of context to error messages
    /// 
    /// Stores error messages when insight generation fails for a context.
    /// UI uses this to show error states with retry options.
    @Default({}) Map<InsightContext, String?> errors,
    
    /// Quick feedback insight shown after workout completion
    /// 
    /// This is a special insight that appears in a bottom sheet immediately
    /// after a workout is completed. It celebrates achievements like PRs,
    /// volume records, or consistency milestones.
    /// 
    /// Null when no quick feedback is pending.
    Insight? quickFeedback,
  }) = _GlobalAIState;

  const GlobalAIState._();

  /// Get insights for a specific context
  /// 
  /// Returns an empty list if no insights exist for the context.
  List<Insight> getInsights(InsightContext context) {
    return insights[context] ?? [];
  }

  /// Check if insights are loading for a specific context
  /// 
  /// Returns false if no loading state exists for the context.
  bool isLoadingForContext(InsightContext context) {
    return isLoading[context] ?? false;
  }

  /// Get error message for a specific context
  /// 
  /// Returns null if no error exists for the context.
  String? getError(InsightContext context) {
    return errors[context];
  }

  /// Get last updated timestamp for a specific context
  /// 
  /// Returns null if insights have never been generated for the context.
  DateTime? getLastUpdated(InsightContext context) {
    return lastUpdated[context];
  }

  /// Check if any context is currently loading
  /// 
  /// Useful for showing a global loading indicator.
  bool get isAnyLoading {
    return isLoading.values.any((loading) => loading);
  }

  /// Check if any context has an error
  /// 
  /// Useful for showing a global error indicator.
  bool get hasAnyError {
    return errors.isNotEmpty;
  }

  /// Get total number of insights across all contexts
  /// 
  /// Useful for analytics and debugging.
  int get totalInsightCount {
    return insights.values.fold(0, (sum, list) => sum + list.length);
  }

  /// Check if quick feedback is pending
  /// 
  /// Returns true if there's a quick feedback insight to show.
  bool get hasQuickFeedback {
    return quickFeedback != null;
  }
}
