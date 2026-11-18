// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AISuggestion _$AISuggestionFromJson(Map<String, dynamic> json) {
  return _AISuggestion.fromJson(json);
}

/// @nodoc
mixin _$AISuggestion {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get actionType =>
      throw _privateConstructorUsedError; // 'exercise_swap', 'progression', 'nutrition', etc.
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AISuggestion value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AISuggestion value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AISuggestion value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this AISuggestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AISuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AISuggestionCopyWith<AISuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AISuggestionCopyWith<$Res> {
  factory $AISuggestionCopyWith(
    AISuggestion value,
    $Res Function(AISuggestion) then,
  ) = _$AISuggestionCopyWithImpl<$Res, AISuggestion>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String actionType,
    Map<String, dynamic> payload,
    double confidence,
  });
}

/// @nodoc
class _$AISuggestionCopyWithImpl<$Res, $Val extends AISuggestion>
    implements $AISuggestionCopyWith<$Res> {
  _$AISuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AISuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? actionType = null,
    Object? payload = null,
    Object? confidence = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            actionType: null == actionType
                ? _value.actionType
                : actionType // ignore: cast_nullable_to_non_nullable
                      as String,
            payload: null == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AISuggestionImplCopyWith<$Res>
    implements $AISuggestionCopyWith<$Res> {
  factory _$$AISuggestionImplCopyWith(
    _$AISuggestionImpl value,
    $Res Function(_$AISuggestionImpl) then,
  ) = __$$AISuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String actionType,
    Map<String, dynamic> payload,
    double confidence,
  });
}

/// @nodoc
class __$$AISuggestionImplCopyWithImpl<$Res>
    extends _$AISuggestionCopyWithImpl<$Res, _$AISuggestionImpl>
    implements _$$AISuggestionImplCopyWith<$Res> {
  __$$AISuggestionImplCopyWithImpl(
    _$AISuggestionImpl _value,
    $Res Function(_$AISuggestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AISuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? actionType = null,
    Object? payload = null,
    Object? confidence = null,
  }) {
    return _then(
      _$AISuggestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        actionType: null == actionType
            ? _value.actionType
            : actionType // ignore: cast_nullable_to_non_nullable
                  as String,
        payload: null == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AISuggestionImpl implements _AISuggestion {
  const _$AISuggestionImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.actionType,
    final Map<String, dynamic> payload = const {},
    this.confidence = 0.8,
  }) : _payload = payload;

  factory _$AISuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AISuggestionImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String actionType;
  // 'exercise_swap', 'progression', 'nutrition', etc.
  final Map<String, dynamic> _payload;
  // 'exercise_swap', 'progression', 'nutrition', etc.
  @override
  @JsonKey()
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  @override
  @JsonKey()
  final double confidence;

  @override
  String toString() {
    return 'AISuggestion(id: $id, title: $title, description: $description, actionType: $actionType, payload: $payload, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AISuggestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    actionType,
    const DeepCollectionEquality().hash(_payload),
    confidence,
  );

  /// Create a copy of AISuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AISuggestionImplCopyWith<_$AISuggestionImpl> get copyWith =>
      __$$AISuggestionImplCopyWithImpl<_$AISuggestionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AISuggestion value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AISuggestion value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AISuggestion value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AISuggestionImplToJson(this);
  }
}

abstract class _AISuggestion implements AISuggestion {
  const factory _AISuggestion({
    required final String id,
    required final String title,
    required final String description,
    required final String actionType,
    final Map<String, dynamic> payload,
    final double confidence,
  }) = _$AISuggestionImpl;

  factory _AISuggestion.fromJson(Map<String, dynamic> json) =
      _$AISuggestionImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get actionType; // 'exercise_swap', 'progression', 'nutrition', etc.
  @override
  Map<String, dynamic> get payload;
  @override
  double get confidence;

  /// Create a copy of AISuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AISuggestionImplCopyWith<_$AISuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIResponse _$AIResponseFromJson(Map<String, dynamic> json) {
  return _AIResponse.fromJson(json);
}

/// @nodoc
mixin _$AIResponse {
  String get id => throw _privateConstructorUsedError;
  AIResponseType get type => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  List<AISuggestion> get suggestions => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  bool get isActionable => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AIResponse value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AIResponse value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AIResponse value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this AIResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIResponseCopyWith<AIResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIResponseCopyWith<$Res> {
  factory $AIResponseCopyWith(
    AIResponse value,
    $Res Function(AIResponse) then,
  ) = _$AIResponseCopyWithImpl<$Res, AIResponse>;
  @useResult
  $Res call({
    String id,
    AIResponseType type,
    String text,
    List<AISuggestion> suggestions,
    Map<String, dynamic> data,
    bool isActionable,
  });
}

/// @nodoc
class _$AIResponseCopyWithImpl<$Res, $Val extends AIResponse>
    implements $AIResponseCopyWith<$Res> {
  _$AIResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? text = null,
    Object? suggestions = null,
    Object? data = null,
    Object? isActionable = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as AIResponseType,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            suggestions: null == suggestions
                ? _value.suggestions
                : suggestions // ignore: cast_nullable_to_non_nullable
                      as List<AISuggestion>,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            isActionable: null == isActionable
                ? _value.isActionable
                : isActionable // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AIResponseImplCopyWith<$Res>
    implements $AIResponseCopyWith<$Res> {
  factory _$$AIResponseImplCopyWith(
    _$AIResponseImpl value,
    $Res Function(_$AIResponseImpl) then,
  ) = __$$AIResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    AIResponseType type,
    String text,
    List<AISuggestion> suggestions,
    Map<String, dynamic> data,
    bool isActionable,
  });
}

/// @nodoc
class __$$AIResponseImplCopyWithImpl<$Res>
    extends _$AIResponseCopyWithImpl<$Res, _$AIResponseImpl>
    implements _$$AIResponseImplCopyWith<$Res> {
  __$$AIResponseImplCopyWithImpl(
    _$AIResponseImpl _value,
    $Res Function(_$AIResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? text = null,
    Object? suggestions = null,
    Object? data = null,
    Object? isActionable = null,
  }) {
    return _then(
      _$AIResponseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as AIResponseType,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        suggestions: null == suggestions
            ? _value._suggestions
            : suggestions // ignore: cast_nullable_to_non_nullable
                  as List<AISuggestion>,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        isActionable: null == isActionable
            ? _value.isActionable
            : isActionable // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AIResponseImpl implements _AIResponse {
  const _$AIResponseImpl({
    required this.id,
    required this.type,
    required this.text,
    final List<AISuggestion> suggestions = const [],
    final Map<String, dynamic> data = const {},
    this.isActionable = true,
  }) : _suggestions = suggestions,
       _data = data;

  factory _$AIResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIResponseImplFromJson(json);

  @override
  final String id;
  @override
  final AIResponseType type;
  @override
  final String text;
  final List<AISuggestion> _suggestions;
  @override
  @JsonKey()
  List<AISuggestion> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  final Map<String, dynamic> _data;
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  @JsonKey()
  final bool isActionable;

  @override
  String toString() {
    return 'AIResponse(id: $id, type: $type, text: $text, suggestions: $suggestions, data: $data, isActionable: $isActionable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(
              other._suggestions,
              _suggestions,
            ) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.isActionable, isActionable) ||
                other.isActionable == isActionable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    text,
    const DeepCollectionEquality().hash(_suggestions),
    const DeepCollectionEquality().hash(_data),
    isActionable,
  );

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIResponseImplCopyWith<_$AIResponseImpl> get copyWith =>
      __$$AIResponseImplCopyWithImpl<_$AIResponseImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AIResponse value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AIResponse value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AIResponse value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AIResponseImplToJson(this);
  }
}

abstract class _AIResponse implements AIResponse {
  const factory _AIResponse({
    required final String id,
    required final AIResponseType type,
    required final String text,
    final List<AISuggestion> suggestions,
    final Map<String, dynamic> data,
    final bool isActionable,
  }) = _$AIResponseImpl;

  factory _AIResponse.fromJson(Map<String, dynamic> json) =
      _$AIResponseImpl.fromJson;

  @override
  String get id;
  @override
  AIResponseType get type;
  @override
  String get text;
  @override
  List<AISuggestion> get suggestions;
  @override
  Map<String, dynamic> get data;
  @override
  bool get isActionable;

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIResponseImplCopyWith<_$AIResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
