// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'performance_prediction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PerformancePrediction _$PerformancePredictionFromJson(
  Map<String, dynamic> json,
) {
  return _PerformancePrediction.fromJson(json);
}

/// @nodoc
mixin _$PerformancePrediction {
  /// User ID
  String get userId => throw _privateConstructorUsedError;

  /// Exercise-specific predictions
  List<ExercisePrediction> get exercisePredictions =>
      throw _privateConstructorUsedError;

  /// Overall strength prediction
  OverallPrediction get overallStrength => throw _privateConstructorUsedError;

  /// Weight goal prediction
  OverallPrediction? get weightGoal => throw _privateConstructorUsedError;

  /// Consistency prediction
  OverallPrediction get consistency => throw _privateConstructorUsedError;

  /// Confidence level (0.0 to 1.0)
  double get confidenceLevel => throw _privateConstructorUsedError;

  /// Date when prediction was generated
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Prediction timeframe (e.g., 30, 60, 90 days)
  int get predictionDays => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PerformancePrediction value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PerformancePrediction value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PerformancePrediction value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this PerformancePrediction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PerformancePrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PerformancePredictionCopyWith<PerformancePrediction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerformancePredictionCopyWith<$Res> {
  factory $PerformancePredictionCopyWith(
    PerformancePrediction value,
    $Res Function(PerformancePrediction) then,
  ) = _$PerformancePredictionCopyWithImpl<$Res, PerformancePrediction>;
  @useResult
  $Res call({
    String userId,
    List<ExercisePrediction> exercisePredictions,
    OverallPrediction overallStrength,
    OverallPrediction? weightGoal,
    OverallPrediction consistency,
    double confidenceLevel,
    DateTime generatedAt,
    int predictionDays,
  });

  $OverallPredictionCopyWith<$Res> get overallStrength;
  $OverallPredictionCopyWith<$Res>? get weightGoal;
  $OverallPredictionCopyWith<$Res> get consistency;
}

/// @nodoc
class _$PerformancePredictionCopyWithImpl<
  $Res,
  $Val extends PerformancePrediction
>
    implements $PerformancePredictionCopyWith<$Res> {
  _$PerformancePredictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PerformancePrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? exercisePredictions = null,
    Object? overallStrength = null,
    Object? weightGoal = freezed,
    Object? consistency = null,
    Object? confidenceLevel = null,
    Object? generatedAt = null,
    Object? predictionDays = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            exercisePredictions: null == exercisePredictions
                ? _value.exercisePredictions
                : exercisePredictions // ignore: cast_nullable_to_non_nullable
                      as List<ExercisePrediction>,
            overallStrength: null == overallStrength
                ? _value.overallStrength
                : overallStrength // ignore: cast_nullable_to_non_nullable
                      as OverallPrediction,
            weightGoal: freezed == weightGoal
                ? _value.weightGoal
                : weightGoal // ignore: cast_nullable_to_non_nullable
                      as OverallPrediction?,
            consistency: null == consistency
                ? _value.consistency
                : consistency // ignore: cast_nullable_to_non_nullable
                      as OverallPrediction,
            confidenceLevel: null == confidenceLevel
                ? _value.confidenceLevel
                : confidenceLevel // ignore: cast_nullable_to_non_nullable
                      as double,
            generatedAt: null == generatedAt
                ? _value.generatedAt
                : generatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            predictionDays: null == predictionDays
                ? _value.predictionDays
                : predictionDays // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of PerformancePrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OverallPredictionCopyWith<$Res> get overallStrength {
    return $OverallPredictionCopyWith<$Res>(_value.overallStrength, (value) {
      return _then(_value.copyWith(overallStrength: value) as $Val);
    });
  }

  /// Create a copy of PerformancePrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OverallPredictionCopyWith<$Res>? get weightGoal {
    if (_value.weightGoal == null) {
      return null;
    }

    return $OverallPredictionCopyWith<$Res>(_value.weightGoal!, (value) {
      return _then(_value.copyWith(weightGoal: value) as $Val);
    });
  }

  /// Create a copy of PerformancePrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OverallPredictionCopyWith<$Res> get consistency {
    return $OverallPredictionCopyWith<$Res>(_value.consistency, (value) {
      return _then(_value.copyWith(consistency: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PerformancePredictionImplCopyWith<$Res>
    implements $PerformancePredictionCopyWith<$Res> {
  factory _$$PerformancePredictionImplCopyWith(
    _$PerformancePredictionImpl value,
    $Res Function(_$PerformancePredictionImpl) then,
  ) = __$$PerformancePredictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    List<ExercisePrediction> exercisePredictions,
    OverallPrediction overallStrength,
    OverallPrediction? weightGoal,
    OverallPrediction consistency,
    double confidenceLevel,
    DateTime generatedAt,
    int predictionDays,
  });

  @override
  $OverallPredictionCopyWith<$Res> get overallStrength;
  @override
  $OverallPredictionCopyWith<$Res>? get weightGoal;
  @override
  $OverallPredictionCopyWith<$Res> get consistency;
}

/// @nodoc
class __$$PerformancePredictionImplCopyWithImpl<$Res>
    extends
        _$PerformancePredictionCopyWithImpl<$Res, _$PerformancePredictionImpl>
    implements _$$PerformancePredictionImplCopyWith<$Res> {
  __$$PerformancePredictionImplCopyWithImpl(
    _$PerformancePredictionImpl _value,
    $Res Function(_$PerformancePredictionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PerformancePrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? exercisePredictions = null,
    Object? overallStrength = null,
    Object? weightGoal = freezed,
    Object? consistency = null,
    Object? confidenceLevel = null,
    Object? generatedAt = null,
    Object? predictionDays = null,
  }) {
    return _then(
      _$PerformancePredictionImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        exercisePredictions: null == exercisePredictions
            ? _value._exercisePredictions
            : exercisePredictions // ignore: cast_nullable_to_non_nullable
                  as List<ExercisePrediction>,
        overallStrength: null == overallStrength
            ? _value.overallStrength
            : overallStrength // ignore: cast_nullable_to_non_nullable
                  as OverallPrediction,
        weightGoal: freezed == weightGoal
            ? _value.weightGoal
            : weightGoal // ignore: cast_nullable_to_non_nullable
                  as OverallPrediction?,
        consistency: null == consistency
            ? _value.consistency
            : consistency // ignore: cast_nullable_to_non_nullable
                  as OverallPrediction,
        confidenceLevel: null == confidenceLevel
            ? _value.confidenceLevel
            : confidenceLevel // ignore: cast_nullable_to_non_nullable
                  as double,
        generatedAt: null == generatedAt
            ? _value.generatedAt
            : generatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        predictionDays: null == predictionDays
            ? _value.predictionDays
            : predictionDays // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PerformancePredictionImpl extends _PerformancePrediction {
  const _$PerformancePredictionImpl({
    required this.userId,
    required final List<ExercisePrediction> exercisePredictions,
    required this.overallStrength,
    this.weightGoal,
    required this.consistency,
    required this.confidenceLevel,
    required this.generatedAt,
    required this.predictionDays,
  }) : _exercisePredictions = exercisePredictions,
       super._();

  factory _$PerformancePredictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PerformancePredictionImplFromJson(json);

  /// User ID
  @override
  final String userId;

  /// Exercise-specific predictions
  final List<ExercisePrediction> _exercisePredictions;

  /// Exercise-specific predictions
  @override
  List<ExercisePrediction> get exercisePredictions {
    if (_exercisePredictions is EqualUnmodifiableListView)
      return _exercisePredictions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercisePredictions);
  }

  /// Overall strength prediction
  @override
  final OverallPrediction overallStrength;

  /// Weight goal prediction
  @override
  final OverallPrediction? weightGoal;

  /// Consistency prediction
  @override
  final OverallPrediction consistency;

  /// Confidence level (0.0 to 1.0)
  @override
  final double confidenceLevel;

  /// Date when prediction was generated
  @override
  final DateTime generatedAt;

  /// Prediction timeframe (e.g., 30, 60, 90 days)
  @override
  final int predictionDays;

  @override
  String toString() {
    return 'PerformancePrediction(userId: $userId, exercisePredictions: $exercisePredictions, overallStrength: $overallStrength, weightGoal: $weightGoal, consistency: $consistency, confidenceLevel: $confidenceLevel, generatedAt: $generatedAt, predictionDays: $predictionDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerformancePredictionImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(
              other._exercisePredictions,
              _exercisePredictions,
            ) &&
            (identical(other.overallStrength, overallStrength) ||
                other.overallStrength == overallStrength) &&
            (identical(other.weightGoal, weightGoal) ||
                other.weightGoal == weightGoal) &&
            (identical(other.consistency, consistency) ||
                other.consistency == consistency) &&
            (identical(other.confidenceLevel, confidenceLevel) ||
                other.confidenceLevel == confidenceLevel) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.predictionDays, predictionDays) ||
                other.predictionDays == predictionDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    const DeepCollectionEquality().hash(_exercisePredictions),
    overallStrength,
    weightGoal,
    consistency,
    confidenceLevel,
    generatedAt,
    predictionDays,
  );

  /// Create a copy of PerformancePrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PerformancePredictionImplCopyWith<_$PerformancePredictionImpl>
  get copyWith =>
      __$$PerformancePredictionImplCopyWithImpl<_$PerformancePredictionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PerformancePrediction value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PerformancePrediction value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PerformancePrediction value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PerformancePredictionImplToJson(this);
  }
}

abstract class _PerformancePrediction extends PerformancePrediction {
  const factory _PerformancePrediction({
    required final String userId,
    required final List<ExercisePrediction> exercisePredictions,
    required final OverallPrediction overallStrength,
    final OverallPrediction? weightGoal,
    required final OverallPrediction consistency,
    required final double confidenceLevel,
    required final DateTime generatedAt,
    required final int predictionDays,
  }) = _$PerformancePredictionImpl;
  const _PerformancePrediction._() : super._();

  factory _PerformancePrediction.fromJson(Map<String, dynamic> json) =
      _$PerformancePredictionImpl.fromJson;

  /// User ID
  @override
  String get userId;

  /// Exercise-specific predictions
  @override
  List<ExercisePrediction> get exercisePredictions;

  /// Overall strength prediction
  @override
  OverallPrediction get overallStrength;

  /// Weight goal prediction
  @override
  OverallPrediction? get weightGoal;

  /// Consistency prediction
  @override
  OverallPrediction get consistency;

  /// Confidence level (0.0 to 1.0)
  @override
  double get confidenceLevel;

  /// Date when prediction was generated
  @override
  DateTime get generatedAt;

  /// Prediction timeframe (e.g., 30, 60, 90 days)
  @override
  int get predictionDays;

  /// Create a copy of PerformancePrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PerformancePredictionImplCopyWith<_$PerformancePredictionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExercisePrediction _$ExercisePredictionFromJson(Map<String, dynamic> json) {
  return _ExercisePrediction.fromJson(json);
}

/// @nodoc
mixin _$ExercisePrediction {
  /// Exercise ID
  String get exerciseId => throw _privateConstructorUsedError;

  /// Exercise name
  String get exerciseName => throw _privateConstructorUsedError;

  /// Current 1RM
  double get currentOneRepMax => throw _privateConstructorUsedError;

  /// Predicted 1RM
  double get predictedOneRepMax => throw _privateConstructorUsedError;

  /// Expected improvement percentage
  double get improvementPercentage => throw _privateConstructorUsedError;

  /// Suggested training approach
  String get trainingRecommendation => throw _privateConstructorUsedError;

  /// Confidence in this prediction (0.0 to 1.0)
  double get confidence => throw _privateConstructorUsedError;

  /// Historical data points used for prediction
  int get dataPointsUsed => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ExercisePrediction value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ExercisePrediction value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ExercisePrediction value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ExercisePrediction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExercisePrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExercisePredictionCopyWith<ExercisePrediction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExercisePredictionCopyWith<$Res> {
  factory $ExercisePredictionCopyWith(
    ExercisePrediction value,
    $Res Function(ExercisePrediction) then,
  ) = _$ExercisePredictionCopyWithImpl<$Res, ExercisePrediction>;
  @useResult
  $Res call({
    String exerciseId,
    String exerciseName,
    double currentOneRepMax,
    double predictedOneRepMax,
    double improvementPercentage,
    String trainingRecommendation,
    double confidence,
    int dataPointsUsed,
  });
}

/// @nodoc
class _$ExercisePredictionCopyWithImpl<$Res, $Val extends ExercisePrediction>
    implements $ExercisePredictionCopyWith<$Res> {
  _$ExercisePredictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExercisePrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? currentOneRepMax = null,
    Object? predictedOneRepMax = null,
    Object? improvementPercentage = null,
    Object? trainingRecommendation = null,
    Object? confidence = null,
    Object? dataPointsUsed = null,
  }) {
    return _then(
      _value.copyWith(
            exerciseId: null == exerciseId
                ? _value.exerciseId
                : exerciseId // ignore: cast_nullable_to_non_nullable
                      as String,
            exerciseName: null == exerciseName
                ? _value.exerciseName
                : exerciseName // ignore: cast_nullable_to_non_nullable
                      as String,
            currentOneRepMax: null == currentOneRepMax
                ? _value.currentOneRepMax
                : currentOneRepMax // ignore: cast_nullable_to_non_nullable
                      as double,
            predictedOneRepMax: null == predictedOneRepMax
                ? _value.predictedOneRepMax
                : predictedOneRepMax // ignore: cast_nullable_to_non_nullable
                      as double,
            improvementPercentage: null == improvementPercentage
                ? _value.improvementPercentage
                : improvementPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
            trainingRecommendation: null == trainingRecommendation
                ? _value.trainingRecommendation
                : trainingRecommendation // ignore: cast_nullable_to_non_nullable
                      as String,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            dataPointsUsed: null == dataPointsUsed
                ? _value.dataPointsUsed
                : dataPointsUsed // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExercisePredictionImplCopyWith<$Res>
    implements $ExercisePredictionCopyWith<$Res> {
  factory _$$ExercisePredictionImplCopyWith(
    _$ExercisePredictionImpl value,
    $Res Function(_$ExercisePredictionImpl) then,
  ) = __$$ExercisePredictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String exerciseId,
    String exerciseName,
    double currentOneRepMax,
    double predictedOneRepMax,
    double improvementPercentage,
    String trainingRecommendation,
    double confidence,
    int dataPointsUsed,
  });
}

/// @nodoc
class __$$ExercisePredictionImplCopyWithImpl<$Res>
    extends _$ExercisePredictionCopyWithImpl<$Res, _$ExercisePredictionImpl>
    implements _$$ExercisePredictionImplCopyWith<$Res> {
  __$$ExercisePredictionImplCopyWithImpl(
    _$ExercisePredictionImpl _value,
    $Res Function(_$ExercisePredictionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExercisePrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? currentOneRepMax = null,
    Object? predictedOneRepMax = null,
    Object? improvementPercentage = null,
    Object? trainingRecommendation = null,
    Object? confidence = null,
    Object? dataPointsUsed = null,
  }) {
    return _then(
      _$ExercisePredictionImpl(
        exerciseId: null == exerciseId
            ? _value.exerciseId
            : exerciseId // ignore: cast_nullable_to_non_nullable
                  as String,
        exerciseName: null == exerciseName
            ? _value.exerciseName
            : exerciseName // ignore: cast_nullable_to_non_nullable
                  as String,
        currentOneRepMax: null == currentOneRepMax
            ? _value.currentOneRepMax
            : currentOneRepMax // ignore: cast_nullable_to_non_nullable
                  as double,
        predictedOneRepMax: null == predictedOneRepMax
            ? _value.predictedOneRepMax
            : predictedOneRepMax // ignore: cast_nullable_to_non_nullable
                  as double,
        improvementPercentage: null == improvementPercentage
            ? _value.improvementPercentage
            : improvementPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
        trainingRecommendation: null == trainingRecommendation
            ? _value.trainingRecommendation
            : trainingRecommendation // ignore: cast_nullable_to_non_nullable
                  as String,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        dataPointsUsed: null == dataPointsUsed
            ? _value.dataPointsUsed
            : dataPointsUsed // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExercisePredictionImpl extends _ExercisePrediction {
  const _$ExercisePredictionImpl({
    required this.exerciseId,
    required this.exerciseName,
    required this.currentOneRepMax,
    required this.predictedOneRepMax,
    required this.improvementPercentage,
    required this.trainingRecommendation,
    required this.confidence,
    required this.dataPointsUsed,
  }) : super._();

  factory _$ExercisePredictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExercisePredictionImplFromJson(json);

  /// Exercise ID
  @override
  final String exerciseId;

  /// Exercise name
  @override
  final String exerciseName;

  /// Current 1RM
  @override
  final double currentOneRepMax;

  /// Predicted 1RM
  @override
  final double predictedOneRepMax;

  /// Expected improvement percentage
  @override
  final double improvementPercentage;

  /// Suggested training approach
  @override
  final String trainingRecommendation;

  /// Confidence in this prediction (0.0 to 1.0)
  @override
  final double confidence;

  /// Historical data points used for prediction
  @override
  final int dataPointsUsed;

  @override
  String toString() {
    return 'ExercisePrediction(exerciseId: $exerciseId, exerciseName: $exerciseName, currentOneRepMax: $currentOneRepMax, predictedOneRepMax: $predictedOneRepMax, improvementPercentage: $improvementPercentage, trainingRecommendation: $trainingRecommendation, confidence: $confidence, dataPointsUsed: $dataPointsUsed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExercisePredictionImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.currentOneRepMax, currentOneRepMax) ||
                other.currentOneRepMax == currentOneRepMax) &&
            (identical(other.predictedOneRepMax, predictedOneRepMax) ||
                other.predictedOneRepMax == predictedOneRepMax) &&
            (identical(other.improvementPercentage, improvementPercentage) ||
                other.improvementPercentage == improvementPercentage) &&
            (identical(other.trainingRecommendation, trainingRecommendation) ||
                other.trainingRecommendation == trainingRecommendation) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.dataPointsUsed, dataPointsUsed) ||
                other.dataPointsUsed == dataPointsUsed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    exerciseId,
    exerciseName,
    currentOneRepMax,
    predictedOneRepMax,
    improvementPercentage,
    trainingRecommendation,
    confidence,
    dataPointsUsed,
  );

  /// Create a copy of ExercisePrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExercisePredictionImplCopyWith<_$ExercisePredictionImpl> get copyWith =>
      __$$ExercisePredictionImplCopyWithImpl<_$ExercisePredictionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ExercisePrediction value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ExercisePrediction value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ExercisePrediction value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ExercisePredictionImplToJson(this);
  }
}

abstract class _ExercisePrediction extends ExercisePrediction {
  const factory _ExercisePrediction({
    required final String exerciseId,
    required final String exerciseName,
    required final double currentOneRepMax,
    required final double predictedOneRepMax,
    required final double improvementPercentage,
    required final String trainingRecommendation,
    required final double confidence,
    required final int dataPointsUsed,
  }) = _$ExercisePredictionImpl;
  const _ExercisePrediction._() : super._();

  factory _ExercisePrediction.fromJson(Map<String, dynamic> json) =
      _$ExercisePredictionImpl.fromJson;

  /// Exercise ID
  @override
  String get exerciseId;

  /// Exercise name
  @override
  String get exerciseName;

  /// Current 1RM
  @override
  double get currentOneRepMax;

  /// Predicted 1RM
  @override
  double get predictedOneRepMax;

  /// Expected improvement percentage
  @override
  double get improvementPercentage;

  /// Suggested training approach
  @override
  String get trainingRecommendation;

  /// Confidence in this prediction (0.0 to 1.0)
  @override
  double get confidence;

  /// Historical data points used for prediction
  @override
  int get dataPointsUsed;

  /// Create a copy of ExercisePrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExercisePredictionImplCopyWith<_$ExercisePredictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OverallPrediction _$OverallPredictionFromJson(Map<String, dynamic> json) {
  return _OverallPrediction.fromJson(json);
}

/// @nodoc
mixin _$OverallPrediction {
  /// Current value
  double get currentValue => throw _privateConstructorUsedError;

  /// Predicted value
  double get predictedValue => throw _privateConstructorUsedError;

  /// Change from current to predicted
  double get change => throw _privateConstructorUsedError;

  /// Percentage change
  double get percentageChange => throw _privateConstructorUsedError;

  /// Trend direction
  PredictionTrend get trend => throw _privateConstructorUsedError;

  /// Recommendation text
  String get recommendation => throw _privateConstructorUsedError;

  /// Confidence level (0.0 to 1.0)
  double get confidence => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OverallPrediction value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OverallPrediction value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OverallPrediction value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this OverallPrediction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OverallPrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OverallPredictionCopyWith<OverallPrediction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OverallPredictionCopyWith<$Res> {
  factory $OverallPredictionCopyWith(
    OverallPrediction value,
    $Res Function(OverallPrediction) then,
  ) = _$OverallPredictionCopyWithImpl<$Res, OverallPrediction>;
  @useResult
  $Res call({
    double currentValue,
    double predictedValue,
    double change,
    double percentageChange,
    PredictionTrend trend,
    String recommendation,
    double confidence,
  });
}

/// @nodoc
class _$OverallPredictionCopyWithImpl<$Res, $Val extends OverallPrediction>
    implements $OverallPredictionCopyWith<$Res> {
  _$OverallPredictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OverallPrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentValue = null,
    Object? predictedValue = null,
    Object? change = null,
    Object? percentageChange = null,
    Object? trend = null,
    Object? recommendation = null,
    Object? confidence = null,
  }) {
    return _then(
      _value.copyWith(
            currentValue: null == currentValue
                ? _value.currentValue
                : currentValue // ignore: cast_nullable_to_non_nullable
                      as double,
            predictedValue: null == predictedValue
                ? _value.predictedValue
                : predictedValue // ignore: cast_nullable_to_non_nullable
                      as double,
            change: null == change
                ? _value.change
                : change // ignore: cast_nullable_to_non_nullable
                      as double,
            percentageChange: null == percentageChange
                ? _value.percentageChange
                : percentageChange // ignore: cast_nullable_to_non_nullable
                      as double,
            trend: null == trend
                ? _value.trend
                : trend // ignore: cast_nullable_to_non_nullable
                      as PredictionTrend,
            recommendation: null == recommendation
                ? _value.recommendation
                : recommendation // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$OverallPredictionImplCopyWith<$Res>
    implements $OverallPredictionCopyWith<$Res> {
  factory _$$OverallPredictionImplCopyWith(
    _$OverallPredictionImpl value,
    $Res Function(_$OverallPredictionImpl) then,
  ) = __$$OverallPredictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double currentValue,
    double predictedValue,
    double change,
    double percentageChange,
    PredictionTrend trend,
    String recommendation,
    double confidence,
  });
}

/// @nodoc
class __$$OverallPredictionImplCopyWithImpl<$Res>
    extends _$OverallPredictionCopyWithImpl<$Res, _$OverallPredictionImpl>
    implements _$$OverallPredictionImplCopyWith<$Res> {
  __$$OverallPredictionImplCopyWithImpl(
    _$OverallPredictionImpl _value,
    $Res Function(_$OverallPredictionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OverallPrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentValue = null,
    Object? predictedValue = null,
    Object? change = null,
    Object? percentageChange = null,
    Object? trend = null,
    Object? recommendation = null,
    Object? confidence = null,
  }) {
    return _then(
      _$OverallPredictionImpl(
        currentValue: null == currentValue
            ? _value.currentValue
            : currentValue // ignore: cast_nullable_to_non_nullable
                  as double,
        predictedValue: null == predictedValue
            ? _value.predictedValue
            : predictedValue // ignore: cast_nullable_to_non_nullable
                  as double,
        change: null == change
            ? _value.change
            : change // ignore: cast_nullable_to_non_nullable
                  as double,
        percentageChange: null == percentageChange
            ? _value.percentageChange
            : percentageChange // ignore: cast_nullable_to_non_nullable
                  as double,
        trend: null == trend
            ? _value.trend
            : trend // ignore: cast_nullable_to_non_nullable
                  as PredictionTrend,
        recommendation: null == recommendation
            ? _value.recommendation
            : recommendation // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$OverallPredictionImpl extends _OverallPrediction {
  const _$OverallPredictionImpl({
    required this.currentValue,
    required this.predictedValue,
    required this.change,
    required this.percentageChange,
    required this.trend,
    required this.recommendation,
    required this.confidence,
  }) : super._();

  factory _$OverallPredictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$OverallPredictionImplFromJson(json);

  /// Current value
  @override
  final double currentValue;

  /// Predicted value
  @override
  final double predictedValue;

  /// Change from current to predicted
  @override
  final double change;

  /// Percentage change
  @override
  final double percentageChange;

  /// Trend direction
  @override
  final PredictionTrend trend;

  /// Recommendation text
  @override
  final String recommendation;

  /// Confidence level (0.0 to 1.0)
  @override
  final double confidence;

  @override
  String toString() {
    return 'OverallPrediction(currentValue: $currentValue, predictedValue: $predictedValue, change: $change, percentageChange: $percentageChange, trend: $trend, recommendation: $recommendation, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OverallPredictionImpl &&
            (identical(other.currentValue, currentValue) ||
                other.currentValue == currentValue) &&
            (identical(other.predictedValue, predictedValue) ||
                other.predictedValue == predictedValue) &&
            (identical(other.change, change) || other.change == change) &&
            (identical(other.percentageChange, percentageChange) ||
                other.percentageChange == percentageChange) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentValue,
    predictedValue,
    change,
    percentageChange,
    trend,
    recommendation,
    confidence,
  );

  /// Create a copy of OverallPrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OverallPredictionImplCopyWith<_$OverallPredictionImpl> get copyWith =>
      __$$OverallPredictionImplCopyWithImpl<_$OverallPredictionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OverallPrediction value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OverallPrediction value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OverallPrediction value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$OverallPredictionImplToJson(this);
  }
}

abstract class _OverallPrediction extends OverallPrediction {
  const factory _OverallPrediction({
    required final double currentValue,
    required final double predictedValue,
    required final double change,
    required final double percentageChange,
    required final PredictionTrend trend,
    required final String recommendation,
    required final double confidence,
  }) = _$OverallPredictionImpl;
  const _OverallPrediction._() : super._();

  factory _OverallPrediction.fromJson(Map<String, dynamic> json) =
      _$OverallPredictionImpl.fromJson;

  /// Current value
  @override
  double get currentValue;

  /// Predicted value
  @override
  double get predictedValue;

  /// Change from current to predicted
  @override
  double get change;

  /// Percentage change
  @override
  double get percentageChange;

  /// Trend direction
  @override
  PredictionTrend get trend;

  /// Recommendation text
  @override
  String get recommendation;

  /// Confidence level (0.0 to 1.0)
  @override
  double get confidence;

  /// Create a copy of OverallPrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OverallPredictionImplCopyWith<_$OverallPredictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
