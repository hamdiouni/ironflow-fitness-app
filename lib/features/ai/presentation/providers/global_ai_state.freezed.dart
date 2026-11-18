// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_ai_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GlobalAIState {
  /// Map of context to list of insights (memory cache)
  ///
  /// This is the primary in-memory cache for quick access to insights.
  /// Each context maintains its own list of 2-3 prioritized insights.
  Map<InsightContext, List<Insight>> get insights =>
      throw _privateConstructorUsedError;

  /// Map of context to last update timestamp
  ///
  /// Tracks when insights were last generated for each context.
  /// Used for change detection and cache staleness checks.
  Map<InsightContext, DateTime> get lastUpdated =>
      throw _privateConstructorUsedError;

  /// Map of context to loading state
  ///
  /// Indicates whether insights are currently being generated for a context.
  /// UI uses this to show loading indicators.
  Map<InsightContext, bool> get isLoading => throw _privateConstructorUsedError;

  /// Map of context to error messages
  ///
  /// Stores error messages when insight generation fails for a context.
  /// UI uses this to show error states with retry options.
  Map<InsightContext, String?> get errors => throw _privateConstructorUsedError;

  /// Quick feedback insight shown after workout completion
  ///
  /// This is a special insight that appears in a bottom sheet immediately
  /// after a workout is completed. It celebrates achievements like PRs,
  /// volume records, or consistency milestones.
  ///
  /// Null when no quick feedback is pending.
  Insight? get quickFeedback => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GlobalAIState value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GlobalAIState value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GlobalAIState value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of GlobalAIState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GlobalAIStateCopyWith<GlobalAIState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlobalAIStateCopyWith<$Res> {
  factory $GlobalAIStateCopyWith(
    GlobalAIState value,
    $Res Function(GlobalAIState) then,
  ) = _$GlobalAIStateCopyWithImpl<$Res, GlobalAIState>;
  @useResult
  $Res call({
    Map<InsightContext, List<Insight>> insights,
    Map<InsightContext, DateTime> lastUpdated,
    Map<InsightContext, bool> isLoading,
    Map<InsightContext, String?> errors,
    Insight? quickFeedback,
  });

  $InsightCopyWith<$Res>? get quickFeedback;
}

/// @nodoc
class _$GlobalAIStateCopyWithImpl<$Res, $Val extends GlobalAIState>
    implements $GlobalAIStateCopyWith<$Res> {
  _$GlobalAIStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GlobalAIState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? insights = null,
    Object? lastUpdated = null,
    Object? isLoading = null,
    Object? errors = null,
    Object? quickFeedback = freezed,
  }) {
    return _then(
      _value.copyWith(
            insights: null == insights
                ? _value.insights
                : insights // ignore: cast_nullable_to_non_nullable
                      as Map<InsightContext, List<Insight>>,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as Map<InsightContext, DateTime>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as Map<InsightContext, bool>,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as Map<InsightContext, String?>,
            quickFeedback: freezed == quickFeedback
                ? _value.quickFeedback
                : quickFeedback // ignore: cast_nullable_to_non_nullable
                      as Insight?,
          )
          as $Val,
    );
  }

  /// Create a copy of GlobalAIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InsightCopyWith<$Res>? get quickFeedback {
    if (_value.quickFeedback == null) {
      return null;
    }

    return $InsightCopyWith<$Res>(_value.quickFeedback!, (value) {
      return _then(_value.copyWith(quickFeedback: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GlobalAIStateImplCopyWith<$Res>
    implements $GlobalAIStateCopyWith<$Res> {
  factory _$$GlobalAIStateImplCopyWith(
    _$GlobalAIStateImpl value,
    $Res Function(_$GlobalAIStateImpl) then,
  ) = __$$GlobalAIStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<InsightContext, List<Insight>> insights,
    Map<InsightContext, DateTime> lastUpdated,
    Map<InsightContext, bool> isLoading,
    Map<InsightContext, String?> errors,
    Insight? quickFeedback,
  });

  @override
  $InsightCopyWith<$Res>? get quickFeedback;
}

/// @nodoc
class __$$GlobalAIStateImplCopyWithImpl<$Res>
    extends _$GlobalAIStateCopyWithImpl<$Res, _$GlobalAIStateImpl>
    implements _$$GlobalAIStateImplCopyWith<$Res> {
  __$$GlobalAIStateImplCopyWithImpl(
    _$GlobalAIStateImpl _value,
    $Res Function(_$GlobalAIStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GlobalAIState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? insights = null,
    Object? lastUpdated = null,
    Object? isLoading = null,
    Object? errors = null,
    Object? quickFeedback = freezed,
  }) {
    return _then(
      _$GlobalAIStateImpl(
        insights: null == insights
            ? _value._insights
            : insights // ignore: cast_nullable_to_non_nullable
                  as Map<InsightContext, List<Insight>>,
        lastUpdated: null == lastUpdated
            ? _value._lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as Map<InsightContext, DateTime>,
        isLoading: null == isLoading
            ? _value._isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as Map<InsightContext, bool>,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as Map<InsightContext, String?>,
        quickFeedback: freezed == quickFeedback
            ? _value.quickFeedback
            : quickFeedback // ignore: cast_nullable_to_non_nullable
                  as Insight?,
      ),
    );
  }
}

/// @nodoc

class _$GlobalAIStateImpl extends _GlobalAIState {
  const _$GlobalAIStateImpl({
    final Map<InsightContext, List<Insight>> insights = const {},
    final Map<InsightContext, DateTime> lastUpdated = const {},
    final Map<InsightContext, bool> isLoading = const {},
    final Map<InsightContext, String?> errors = const {},
    this.quickFeedback,
  }) : _insights = insights,
       _lastUpdated = lastUpdated,
       _isLoading = isLoading,
       _errors = errors,
       super._();

  /// Map of context to list of insights (memory cache)
  ///
  /// This is the primary in-memory cache for quick access to insights.
  /// Each context maintains its own list of 2-3 prioritized insights.
  final Map<InsightContext, List<Insight>> _insights;

  /// Map of context to list of insights (memory cache)
  ///
  /// This is the primary in-memory cache for quick access to insights.
  /// Each context maintains its own list of 2-3 prioritized insights.
  @override
  @JsonKey()
  Map<InsightContext, List<Insight>> get insights {
    if (_insights is EqualUnmodifiableMapView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_insights);
  }

  /// Map of context to last update timestamp
  ///
  /// Tracks when insights were last generated for each context.
  /// Used for change detection and cache staleness checks.
  final Map<InsightContext, DateTime> _lastUpdated;

  /// Map of context to last update timestamp
  ///
  /// Tracks when insights were last generated for each context.
  /// Used for change detection and cache staleness checks.
  @override
  @JsonKey()
  Map<InsightContext, DateTime> get lastUpdated {
    if (_lastUpdated is EqualUnmodifiableMapView) return _lastUpdated;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_lastUpdated);
  }

  /// Map of context to loading state
  ///
  /// Indicates whether insights are currently being generated for a context.
  /// UI uses this to show loading indicators.
  final Map<InsightContext, bool> _isLoading;

  /// Map of context to loading state
  ///
  /// Indicates whether insights are currently being generated for a context.
  /// UI uses this to show loading indicators.
  @override
  @JsonKey()
  Map<InsightContext, bool> get isLoading {
    if (_isLoading is EqualUnmodifiableMapView) return _isLoading;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_isLoading);
  }

  /// Map of context to error messages
  ///
  /// Stores error messages when insight generation fails for a context.
  /// UI uses this to show error states with retry options.
  final Map<InsightContext, String?> _errors;

  /// Map of context to error messages
  ///
  /// Stores error messages when insight generation fails for a context.
  /// UI uses this to show error states with retry options.
  @override
  @JsonKey()
  Map<InsightContext, String?> get errors {
    if (_errors is EqualUnmodifiableMapView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_errors);
  }

  /// Quick feedback insight shown after workout completion
  ///
  /// This is a special insight that appears in a bottom sheet immediately
  /// after a workout is completed. It celebrates achievements like PRs,
  /// volume records, or consistency milestones.
  ///
  /// Null when no quick feedback is pending.
  @override
  final Insight? quickFeedback;

  @override
  String toString() {
    return 'GlobalAIState(insights: $insights, lastUpdated: $lastUpdated, isLoading: $isLoading, errors: $errors, quickFeedback: $quickFeedback)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlobalAIStateImpl &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            const DeepCollectionEquality().equals(
              other._lastUpdated,
              _lastUpdated,
            ) &&
            const DeepCollectionEquality().equals(
              other._isLoading,
              _isLoading,
            ) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            (identical(other.quickFeedback, quickFeedback) ||
                other.quickFeedback == quickFeedback));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_insights),
    const DeepCollectionEquality().hash(_lastUpdated),
    const DeepCollectionEquality().hash(_isLoading),
    const DeepCollectionEquality().hash(_errors),
    quickFeedback,
  );

  /// Create a copy of GlobalAIState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GlobalAIStateImplCopyWith<_$GlobalAIStateImpl> get copyWith =>
      __$$GlobalAIStateImplCopyWithImpl<_$GlobalAIStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GlobalAIState value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GlobalAIState value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GlobalAIState value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _GlobalAIState extends GlobalAIState {
  const factory _GlobalAIState({
    final Map<InsightContext, List<Insight>> insights,
    final Map<InsightContext, DateTime> lastUpdated,
    final Map<InsightContext, bool> isLoading,
    final Map<InsightContext, String?> errors,
    final Insight? quickFeedback,
  }) = _$GlobalAIStateImpl;
  const _GlobalAIState._() : super._();

  /// Map of context to list of insights (memory cache)
  ///
  /// This is the primary in-memory cache for quick access to insights.
  /// Each context maintains its own list of 2-3 prioritized insights.
  @override
  Map<InsightContext, List<Insight>> get insights;

  /// Map of context to last update timestamp
  ///
  /// Tracks when insights were last generated for each context.
  /// Used for change detection and cache staleness checks.
  @override
  Map<InsightContext, DateTime> get lastUpdated;

  /// Map of context to loading state
  ///
  /// Indicates whether insights are currently being generated for a context.
  /// UI uses this to show loading indicators.
  @override
  Map<InsightContext, bool> get isLoading;

  /// Map of context to error messages
  ///
  /// Stores error messages when insight generation fails for a context.
  /// UI uses this to show error states with retry options.
  @override
  Map<InsightContext, String?> get errors;

  /// Quick feedback insight shown after workout completion
  ///
  /// This is a special insight that appears in a bottom sheet immediately
  /// after a workout is completed. It celebrates achievements like PRs,
  /// volume records, or consistency milestones.
  ///
  /// Null when no quick feedback is pending.
  @override
  Insight? get quickFeedback;

  /// Create a copy of GlobalAIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GlobalAIStateImplCopyWith<_$GlobalAIStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
