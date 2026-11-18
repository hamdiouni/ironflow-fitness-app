// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'strength_progression.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StrengthProgression _$StrengthProgressionFromJson(Map<String, dynamic> json) {
  return _StrengthProgression.fromJson(json);
}

/// @nodoc
mixin _$StrengthProgression {
  /// Exercise ID
  String get exerciseId => throw _privateConstructorUsedError;

  /// Exercise name
  String get exerciseName => throw _privateConstructorUsedError;

  /// Muscle group targeted
  String get muscleGroup => throw _privateConstructorUsedError;

  /// List of data points over time
  List<StrengthDataPoint> get dataPoints => throw _privateConstructorUsedError;

  /// Current one-rep max (1RM) estimate
  double get currentOneRepMax => throw _privateConstructorUsedError;

  /// Previous one-rep max for comparison
  double get previousOneRepMax => throw _privateConstructorUsedError;

  /// Percentage change in 1RM
  double get percentageChange => throw _privateConstructorUsedError;

  /// Total volume lifted (weight × reps × sets)
  double get totalVolume => throw _privateConstructorUsedError;

  /// Date range for this progression data
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StrengthProgression value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StrengthProgression value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StrengthProgression value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this StrengthProgression to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StrengthProgression
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StrengthProgressionCopyWith<StrengthProgression> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrengthProgressionCopyWith<$Res> {
  factory $StrengthProgressionCopyWith(
    StrengthProgression value,
    $Res Function(StrengthProgression) then,
  ) = _$StrengthProgressionCopyWithImpl<$Res, StrengthProgression>;
  @useResult
  $Res call({
    String exerciseId,
    String exerciseName,
    String muscleGroup,
    List<StrengthDataPoint> dataPoints,
    double currentOneRepMax,
    double previousOneRepMax,
    double percentageChange,
    double totalVolume,
    DateTime startDate,
    DateTime endDate,
  });
}

/// @nodoc
class _$StrengthProgressionCopyWithImpl<$Res, $Val extends StrengthProgression>
    implements $StrengthProgressionCopyWith<$Res> {
  _$StrengthProgressionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StrengthProgression
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? muscleGroup = null,
    Object? dataPoints = null,
    Object? currentOneRepMax = null,
    Object? previousOneRepMax = null,
    Object? percentageChange = null,
    Object? totalVolume = null,
    Object? startDate = null,
    Object? endDate = null,
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
            muscleGroup: null == muscleGroup
                ? _value.muscleGroup
                : muscleGroup // ignore: cast_nullable_to_non_nullable
                      as String,
            dataPoints: null == dataPoints
                ? _value.dataPoints
                : dataPoints // ignore: cast_nullable_to_non_nullable
                      as List<StrengthDataPoint>,
            currentOneRepMax: null == currentOneRepMax
                ? _value.currentOneRepMax
                : currentOneRepMax // ignore: cast_nullable_to_non_nullable
                      as double,
            previousOneRepMax: null == previousOneRepMax
                ? _value.previousOneRepMax
                : previousOneRepMax // ignore: cast_nullable_to_non_nullable
                      as double,
            percentageChange: null == percentageChange
                ? _value.percentageChange
                : percentageChange // ignore: cast_nullable_to_non_nullable
                      as double,
            totalVolume: null == totalVolume
                ? _value.totalVolume
                : totalVolume // ignore: cast_nullable_to_non_nullable
                      as double,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StrengthProgressionImplCopyWith<$Res>
    implements $StrengthProgressionCopyWith<$Res> {
  factory _$$StrengthProgressionImplCopyWith(
    _$StrengthProgressionImpl value,
    $Res Function(_$StrengthProgressionImpl) then,
  ) = __$$StrengthProgressionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String exerciseId,
    String exerciseName,
    String muscleGroup,
    List<StrengthDataPoint> dataPoints,
    double currentOneRepMax,
    double previousOneRepMax,
    double percentageChange,
    double totalVolume,
    DateTime startDate,
    DateTime endDate,
  });
}

/// @nodoc
class __$$StrengthProgressionImplCopyWithImpl<$Res>
    extends _$StrengthProgressionCopyWithImpl<$Res, _$StrengthProgressionImpl>
    implements _$$StrengthProgressionImplCopyWith<$Res> {
  __$$StrengthProgressionImplCopyWithImpl(
    _$StrengthProgressionImpl _value,
    $Res Function(_$StrengthProgressionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StrengthProgression
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? muscleGroup = null,
    Object? dataPoints = null,
    Object? currentOneRepMax = null,
    Object? previousOneRepMax = null,
    Object? percentageChange = null,
    Object? totalVolume = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(
      _$StrengthProgressionImpl(
        exerciseId: null == exerciseId
            ? _value.exerciseId
            : exerciseId // ignore: cast_nullable_to_non_nullable
                  as String,
        exerciseName: null == exerciseName
            ? _value.exerciseName
            : exerciseName // ignore: cast_nullable_to_non_nullable
                  as String,
        muscleGroup: null == muscleGroup
            ? _value.muscleGroup
            : muscleGroup // ignore: cast_nullable_to_non_nullable
                  as String,
        dataPoints: null == dataPoints
            ? _value._dataPoints
            : dataPoints // ignore: cast_nullable_to_non_nullable
                  as List<StrengthDataPoint>,
        currentOneRepMax: null == currentOneRepMax
            ? _value.currentOneRepMax
            : currentOneRepMax // ignore: cast_nullable_to_non_nullable
                  as double,
        previousOneRepMax: null == previousOneRepMax
            ? _value.previousOneRepMax
            : previousOneRepMax // ignore: cast_nullable_to_non_nullable
                  as double,
        percentageChange: null == percentageChange
            ? _value.percentageChange
            : percentageChange // ignore: cast_nullable_to_non_nullable
                  as double,
        totalVolume: null == totalVolume
            ? _value.totalVolume
            : totalVolume // ignore: cast_nullable_to_non_nullable
                  as double,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StrengthProgressionImpl extends _StrengthProgression {
  const _$StrengthProgressionImpl({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required final List<StrengthDataPoint> dataPoints,
    required this.currentOneRepMax,
    required this.previousOneRepMax,
    required this.percentageChange,
    required this.totalVolume,
    required this.startDate,
    required this.endDate,
  }) : _dataPoints = dataPoints,
       super._();

  factory _$StrengthProgressionImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrengthProgressionImplFromJson(json);

  /// Exercise ID
  @override
  final String exerciseId;

  /// Exercise name
  @override
  final String exerciseName;

  /// Muscle group targeted
  @override
  final String muscleGroup;

  /// List of data points over time
  final List<StrengthDataPoint> _dataPoints;

  /// List of data points over time
  @override
  List<StrengthDataPoint> get dataPoints {
    if (_dataPoints is EqualUnmodifiableListView) return _dataPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dataPoints);
  }

  /// Current one-rep max (1RM) estimate
  @override
  final double currentOneRepMax;

  /// Previous one-rep max for comparison
  @override
  final double previousOneRepMax;

  /// Percentage change in 1RM
  @override
  final double percentageChange;

  /// Total volume lifted (weight × reps × sets)
  @override
  final double totalVolume;

  /// Date range for this progression data
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;

  @override
  String toString() {
    return 'StrengthProgression(exerciseId: $exerciseId, exerciseName: $exerciseName, muscleGroup: $muscleGroup, dataPoints: $dataPoints, currentOneRepMax: $currentOneRepMax, previousOneRepMax: $previousOneRepMax, percentageChange: $percentageChange, totalVolume: $totalVolume, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrengthProgressionImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.muscleGroup, muscleGroup) ||
                other.muscleGroup == muscleGroup) &&
            const DeepCollectionEquality().equals(
              other._dataPoints,
              _dataPoints,
            ) &&
            (identical(other.currentOneRepMax, currentOneRepMax) ||
                other.currentOneRepMax == currentOneRepMax) &&
            (identical(other.previousOneRepMax, previousOneRepMax) ||
                other.previousOneRepMax == previousOneRepMax) &&
            (identical(other.percentageChange, percentageChange) ||
                other.percentageChange == percentageChange) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    exerciseId,
    exerciseName,
    muscleGroup,
    const DeepCollectionEquality().hash(_dataPoints),
    currentOneRepMax,
    previousOneRepMax,
    percentageChange,
    totalVolume,
    startDate,
    endDate,
  );

  /// Create a copy of StrengthProgression
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StrengthProgressionImplCopyWith<_$StrengthProgressionImpl> get copyWith =>
      __$$StrengthProgressionImplCopyWithImpl<_$StrengthProgressionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StrengthProgression value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StrengthProgression value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StrengthProgression value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$StrengthProgressionImplToJson(this);
  }
}

abstract class _StrengthProgression extends StrengthProgression {
  const factory _StrengthProgression({
    required final String exerciseId,
    required final String exerciseName,
    required final String muscleGroup,
    required final List<StrengthDataPoint> dataPoints,
    required final double currentOneRepMax,
    required final double previousOneRepMax,
    required final double percentageChange,
    required final double totalVolume,
    required final DateTime startDate,
    required final DateTime endDate,
  }) = _$StrengthProgressionImpl;
  const _StrengthProgression._() : super._();

  factory _StrengthProgression.fromJson(Map<String, dynamic> json) =
      _$StrengthProgressionImpl.fromJson;

  /// Exercise ID
  @override
  String get exerciseId;

  /// Exercise name
  @override
  String get exerciseName;

  /// Muscle group targeted
  @override
  String get muscleGroup;

  /// List of data points over time
  @override
  List<StrengthDataPoint> get dataPoints;

  /// Current one-rep max (1RM) estimate
  @override
  double get currentOneRepMax;

  /// Previous one-rep max for comparison
  @override
  double get previousOneRepMax;

  /// Percentage change in 1RM
  @override
  double get percentageChange;

  /// Total volume lifted (weight × reps × sets)
  @override
  double get totalVolume;

  /// Date range for this progression data
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;

  /// Create a copy of StrengthProgression
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StrengthProgressionImplCopyWith<_$StrengthProgressionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StrengthDataPoint _$StrengthDataPointFromJson(Map<String, dynamic> json) {
  return _StrengthDataPoint.fromJson(json);
}

/// @nodoc
mixin _$StrengthDataPoint {
  /// Date of the workout
  DateTime get date => throw _privateConstructorUsedError;

  /// Weight lifted (in kg or lbs)
  double get weight => throw _privateConstructorUsedError;

  /// Number of reps performed
  int get reps => throw _privateConstructorUsedError;

  /// Number of sets performed
  int get sets => throw _privateConstructorUsedError;

  /// Calculated volume (weight × reps × sets)
  double get volume => throw _privateConstructorUsedError;

  /// Estimated 1RM for this session
  double get estimatedOneRepMax => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StrengthDataPoint value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StrengthDataPoint value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StrengthDataPoint value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this StrengthDataPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StrengthDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StrengthDataPointCopyWith<StrengthDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrengthDataPointCopyWith<$Res> {
  factory $StrengthDataPointCopyWith(
    StrengthDataPoint value,
    $Res Function(StrengthDataPoint) then,
  ) = _$StrengthDataPointCopyWithImpl<$Res, StrengthDataPoint>;
  @useResult
  $Res call({
    DateTime date,
    double weight,
    int reps,
    int sets,
    double volume,
    double estimatedOneRepMax,
  });
}

/// @nodoc
class _$StrengthDataPointCopyWithImpl<$Res, $Val extends StrengthDataPoint>
    implements $StrengthDataPointCopyWith<$Res> {
  _$StrengthDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StrengthDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? weight = null,
    Object? reps = null,
    Object? sets = null,
    Object? volume = null,
    Object? estimatedOneRepMax = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double,
            reps: null == reps
                ? _value.reps
                : reps // ignore: cast_nullable_to_non_nullable
                      as int,
            sets: null == sets
                ? _value.sets
                : sets // ignore: cast_nullable_to_non_nullable
                      as int,
            volume: null == volume
                ? _value.volume
                : volume // ignore: cast_nullable_to_non_nullable
                      as double,
            estimatedOneRepMax: null == estimatedOneRepMax
                ? _value.estimatedOneRepMax
                : estimatedOneRepMax // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StrengthDataPointImplCopyWith<$Res>
    implements $StrengthDataPointCopyWith<$Res> {
  factory _$$StrengthDataPointImplCopyWith(
    _$StrengthDataPointImpl value,
    $Res Function(_$StrengthDataPointImpl) then,
  ) = __$$StrengthDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime date,
    double weight,
    int reps,
    int sets,
    double volume,
    double estimatedOneRepMax,
  });
}

/// @nodoc
class __$$StrengthDataPointImplCopyWithImpl<$Res>
    extends _$StrengthDataPointCopyWithImpl<$Res, _$StrengthDataPointImpl>
    implements _$$StrengthDataPointImplCopyWith<$Res> {
  __$$StrengthDataPointImplCopyWithImpl(
    _$StrengthDataPointImpl _value,
    $Res Function(_$StrengthDataPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StrengthDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? weight = null,
    Object? reps = null,
    Object? sets = null,
    Object? volume = null,
    Object? estimatedOneRepMax = null,
  }) {
    return _then(
      _$StrengthDataPointImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
        reps: null == reps
            ? _value.reps
            : reps // ignore: cast_nullable_to_non_nullable
                  as int,
        sets: null == sets
            ? _value.sets
            : sets // ignore: cast_nullable_to_non_nullable
                  as int,
        volume: null == volume
            ? _value.volume
            : volume // ignore: cast_nullable_to_non_nullable
                  as double,
        estimatedOneRepMax: null == estimatedOneRepMax
            ? _value.estimatedOneRepMax
            : estimatedOneRepMax // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StrengthDataPointImpl implements _StrengthDataPoint {
  const _$StrengthDataPointImpl({
    required this.date,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.volume,
    required this.estimatedOneRepMax,
  });

  factory _$StrengthDataPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrengthDataPointImplFromJson(json);

  /// Date of the workout
  @override
  final DateTime date;

  /// Weight lifted (in kg or lbs)
  @override
  final double weight;

  /// Number of reps performed
  @override
  final int reps;

  /// Number of sets performed
  @override
  final int sets;

  /// Calculated volume (weight × reps × sets)
  @override
  final double volume;

  /// Estimated 1RM for this session
  @override
  final double estimatedOneRepMax;

  @override
  String toString() {
    return 'StrengthDataPoint(date: $date, weight: $weight, reps: $reps, sets: $sets, volume: $volume, estimatedOneRepMax: $estimatedOneRepMax)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrengthDataPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.estimatedOneRepMax, estimatedOneRepMax) ||
                other.estimatedOneRepMax == estimatedOneRepMax));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    weight,
    reps,
    sets,
    volume,
    estimatedOneRepMax,
  );

  /// Create a copy of StrengthDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StrengthDataPointImplCopyWith<_$StrengthDataPointImpl> get copyWith =>
      __$$StrengthDataPointImplCopyWithImpl<_$StrengthDataPointImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StrengthDataPoint value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StrengthDataPoint value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StrengthDataPoint value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$StrengthDataPointImplToJson(this);
  }
}

abstract class _StrengthDataPoint implements StrengthDataPoint {
  const factory _StrengthDataPoint({
    required final DateTime date,
    required final double weight,
    required final int reps,
    required final int sets,
    required final double volume,
    required final double estimatedOneRepMax,
  }) = _$StrengthDataPointImpl;

  factory _StrengthDataPoint.fromJson(Map<String, dynamic> json) =
      _$StrengthDataPointImpl.fromJson;

  /// Date of the workout
  @override
  DateTime get date;

  /// Weight lifted (in kg or lbs)
  @override
  double get weight;

  /// Number of reps performed
  @override
  int get reps;

  /// Number of sets performed
  @override
  int get sets;

  /// Calculated volume (weight × reps × sets)
  @override
  double get volume;

  /// Estimated 1RM for this session
  @override
  double get estimatedOneRepMax;

  /// Create a copy of StrengthDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StrengthDataPointImplCopyWith<_$StrengthDataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
