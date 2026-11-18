// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_tracking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeightTracking _$WeightTrackingFromJson(Map<String, dynamic> json) {
  return _WeightTracking.fromJson(json);
}

/// @nodoc
mixin _$WeightTracking {
  /// User ID
  String get userId => throw _privateConstructorUsedError;

  /// List of weight measurements over time
  List<WeightMeasurement> get measurements =>
      throw _privateConstructorUsedError;

  /// Current weight (most recent measurement)
  double get currentWeight => throw _privateConstructorUsedError;

  /// Starting weight (first measurement)
  double get startingWeight => throw _privateConstructorUsedError;

  /// Goal weight
  double get goalWeight => throw _privateConstructorUsedError;

  /// Weight change from start to current
  double get totalChange => throw _privateConstructorUsedError;

  /// Average weekly change
  double get averageWeeklyChange => throw _privateConstructorUsedError;

  /// Projected date to reach goal (if trend continues)
  DateTime? get projectedGoalDate => throw _privateConstructorUsedError;

  /// Date range for this tracking data
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WeightTracking value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WeightTracking value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WeightTracking value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this WeightTracking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeightTracking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeightTrackingCopyWith<WeightTracking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeightTrackingCopyWith<$Res> {
  factory $WeightTrackingCopyWith(
    WeightTracking value,
    $Res Function(WeightTracking) then,
  ) = _$WeightTrackingCopyWithImpl<$Res, WeightTracking>;
  @useResult
  $Res call({
    String userId,
    List<WeightMeasurement> measurements,
    double currentWeight,
    double startingWeight,
    double goalWeight,
    double totalChange,
    double averageWeeklyChange,
    DateTime? projectedGoalDate,
    DateTime startDate,
    DateTime endDate,
  });
}

/// @nodoc
class _$WeightTrackingCopyWithImpl<$Res, $Val extends WeightTracking>
    implements $WeightTrackingCopyWith<$Res> {
  _$WeightTrackingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeightTracking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? measurements = null,
    Object? currentWeight = null,
    Object? startingWeight = null,
    Object? goalWeight = null,
    Object? totalChange = null,
    Object? averageWeeklyChange = null,
    Object? projectedGoalDate = freezed,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            measurements: null == measurements
                ? _value.measurements
                : measurements // ignore: cast_nullable_to_non_nullable
                      as List<WeightMeasurement>,
            currentWeight: null == currentWeight
                ? _value.currentWeight
                : currentWeight // ignore: cast_nullable_to_non_nullable
                      as double,
            startingWeight: null == startingWeight
                ? _value.startingWeight
                : startingWeight // ignore: cast_nullable_to_non_nullable
                      as double,
            goalWeight: null == goalWeight
                ? _value.goalWeight
                : goalWeight // ignore: cast_nullable_to_non_nullable
                      as double,
            totalChange: null == totalChange
                ? _value.totalChange
                : totalChange // ignore: cast_nullable_to_non_nullable
                      as double,
            averageWeeklyChange: null == averageWeeklyChange
                ? _value.averageWeeklyChange
                : averageWeeklyChange // ignore: cast_nullable_to_non_nullable
                      as double,
            projectedGoalDate: freezed == projectedGoalDate
                ? _value.projectedGoalDate
                : projectedGoalDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$WeightTrackingImplCopyWith<$Res>
    implements $WeightTrackingCopyWith<$Res> {
  factory _$$WeightTrackingImplCopyWith(
    _$WeightTrackingImpl value,
    $Res Function(_$WeightTrackingImpl) then,
  ) = __$$WeightTrackingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    List<WeightMeasurement> measurements,
    double currentWeight,
    double startingWeight,
    double goalWeight,
    double totalChange,
    double averageWeeklyChange,
    DateTime? projectedGoalDate,
    DateTime startDate,
    DateTime endDate,
  });
}

/// @nodoc
class __$$WeightTrackingImplCopyWithImpl<$Res>
    extends _$WeightTrackingCopyWithImpl<$Res, _$WeightTrackingImpl>
    implements _$$WeightTrackingImplCopyWith<$Res> {
  __$$WeightTrackingImplCopyWithImpl(
    _$WeightTrackingImpl _value,
    $Res Function(_$WeightTrackingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeightTracking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? measurements = null,
    Object? currentWeight = null,
    Object? startingWeight = null,
    Object? goalWeight = null,
    Object? totalChange = null,
    Object? averageWeeklyChange = null,
    Object? projectedGoalDate = freezed,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(
      _$WeightTrackingImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        measurements: null == measurements
            ? _value._measurements
            : measurements // ignore: cast_nullable_to_non_nullable
                  as List<WeightMeasurement>,
        currentWeight: null == currentWeight
            ? _value.currentWeight
            : currentWeight // ignore: cast_nullable_to_non_nullable
                  as double,
        startingWeight: null == startingWeight
            ? _value.startingWeight
            : startingWeight // ignore: cast_nullable_to_non_nullable
                  as double,
        goalWeight: null == goalWeight
            ? _value.goalWeight
            : goalWeight // ignore: cast_nullable_to_non_nullable
                  as double,
        totalChange: null == totalChange
            ? _value.totalChange
            : totalChange // ignore: cast_nullable_to_non_nullable
                  as double,
        averageWeeklyChange: null == averageWeeklyChange
            ? _value.averageWeeklyChange
            : averageWeeklyChange // ignore: cast_nullable_to_non_nullable
                  as double,
        projectedGoalDate: freezed == projectedGoalDate
            ? _value.projectedGoalDate
            : projectedGoalDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$WeightTrackingImpl extends _WeightTracking {
  const _$WeightTrackingImpl({
    required this.userId,
    required final List<WeightMeasurement> measurements,
    required this.currentWeight,
    required this.startingWeight,
    required this.goalWeight,
    required this.totalChange,
    required this.averageWeeklyChange,
    this.projectedGoalDate,
    required this.startDate,
    required this.endDate,
  }) : _measurements = measurements,
       super._();

  factory _$WeightTrackingImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightTrackingImplFromJson(json);

  /// User ID
  @override
  final String userId;

  /// List of weight measurements over time
  final List<WeightMeasurement> _measurements;

  /// List of weight measurements over time
  @override
  List<WeightMeasurement> get measurements {
    if (_measurements is EqualUnmodifiableListView) return _measurements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_measurements);
  }

  /// Current weight (most recent measurement)
  @override
  final double currentWeight;

  /// Starting weight (first measurement)
  @override
  final double startingWeight;

  /// Goal weight
  @override
  final double goalWeight;

  /// Weight change from start to current
  @override
  final double totalChange;

  /// Average weekly change
  @override
  final double averageWeeklyChange;

  /// Projected date to reach goal (if trend continues)
  @override
  final DateTime? projectedGoalDate;

  /// Date range for this tracking data
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;

  @override
  String toString() {
    return 'WeightTracking(userId: $userId, measurements: $measurements, currentWeight: $currentWeight, startingWeight: $startingWeight, goalWeight: $goalWeight, totalChange: $totalChange, averageWeeklyChange: $averageWeeklyChange, projectedGoalDate: $projectedGoalDate, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightTrackingImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(
              other._measurements,
              _measurements,
            ) &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight) &&
            (identical(other.startingWeight, startingWeight) ||
                other.startingWeight == startingWeight) &&
            (identical(other.goalWeight, goalWeight) ||
                other.goalWeight == goalWeight) &&
            (identical(other.totalChange, totalChange) ||
                other.totalChange == totalChange) &&
            (identical(other.averageWeeklyChange, averageWeeklyChange) ||
                other.averageWeeklyChange == averageWeeklyChange) &&
            (identical(other.projectedGoalDate, projectedGoalDate) ||
                other.projectedGoalDate == projectedGoalDate) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    const DeepCollectionEquality().hash(_measurements),
    currentWeight,
    startingWeight,
    goalWeight,
    totalChange,
    averageWeeklyChange,
    projectedGoalDate,
    startDate,
    endDate,
  );

  /// Create a copy of WeightTracking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightTrackingImplCopyWith<_$WeightTrackingImpl> get copyWith =>
      __$$WeightTrackingImplCopyWithImpl<_$WeightTrackingImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WeightTracking value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WeightTracking value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WeightTracking value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightTrackingImplToJson(this);
  }
}

abstract class _WeightTracking extends WeightTracking {
  const factory _WeightTracking({
    required final String userId,
    required final List<WeightMeasurement> measurements,
    required final double currentWeight,
    required final double startingWeight,
    required final double goalWeight,
    required final double totalChange,
    required final double averageWeeklyChange,
    final DateTime? projectedGoalDate,
    required final DateTime startDate,
    required final DateTime endDate,
  }) = _$WeightTrackingImpl;
  const _WeightTracking._() : super._();

  factory _WeightTracking.fromJson(Map<String, dynamic> json) =
      _$WeightTrackingImpl.fromJson;

  /// User ID
  @override
  String get userId;

  /// List of weight measurements over time
  @override
  List<WeightMeasurement> get measurements;

  /// Current weight (most recent measurement)
  @override
  double get currentWeight;

  /// Starting weight (first measurement)
  @override
  double get startingWeight;

  /// Goal weight
  @override
  double get goalWeight;

  /// Weight change from start to current
  @override
  double get totalChange;

  /// Average weekly change
  @override
  double get averageWeeklyChange;

  /// Projected date to reach goal (if trend continues)
  @override
  DateTime? get projectedGoalDate;

  /// Date range for this tracking data
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;

  /// Create a copy of WeightTracking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeightTrackingImplCopyWith<_$WeightTrackingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeightMeasurement _$WeightMeasurementFromJson(Map<String, dynamic> json) {
  return _WeightMeasurement.fromJson(json);
}

/// @nodoc
mixin _$WeightMeasurement {
  /// Date of measurement
  DateTime get date => throw _privateConstructorUsedError;

  /// Weight in kg or lbs
  double get weight => throw _privateConstructorUsedError;

  /// Optional note about the measurement
  String? get note => throw _privateConstructorUsedError;

  /// Body fat percentage (optional)
  double? get bodyFatPercentage => throw _privateConstructorUsedError;

  /// Muscle mass (optional)
  double? get muscleMass => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WeightMeasurement value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WeightMeasurement value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WeightMeasurement value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this WeightMeasurement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeightMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeightMeasurementCopyWith<WeightMeasurement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeightMeasurementCopyWith<$Res> {
  factory $WeightMeasurementCopyWith(
    WeightMeasurement value,
    $Res Function(WeightMeasurement) then,
  ) = _$WeightMeasurementCopyWithImpl<$Res, WeightMeasurement>;
  @useResult
  $Res call({
    DateTime date,
    double weight,
    String? note,
    double? bodyFatPercentage,
    double? muscleMass,
  });
}

/// @nodoc
class _$WeightMeasurementCopyWithImpl<$Res, $Val extends WeightMeasurement>
    implements $WeightMeasurementCopyWith<$Res> {
  _$WeightMeasurementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeightMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? weight = null,
    Object? note = freezed,
    Object? bodyFatPercentage = freezed,
    Object? muscleMass = freezed,
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
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            bodyFatPercentage: freezed == bodyFatPercentage
                ? _value.bodyFatPercentage
                : bodyFatPercentage // ignore: cast_nullable_to_non_nullable
                      as double?,
            muscleMass: freezed == muscleMass
                ? _value.muscleMass
                : muscleMass // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeightMeasurementImplCopyWith<$Res>
    implements $WeightMeasurementCopyWith<$Res> {
  factory _$$WeightMeasurementImplCopyWith(
    _$WeightMeasurementImpl value,
    $Res Function(_$WeightMeasurementImpl) then,
  ) = __$$WeightMeasurementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime date,
    double weight,
    String? note,
    double? bodyFatPercentage,
    double? muscleMass,
  });
}

/// @nodoc
class __$$WeightMeasurementImplCopyWithImpl<$Res>
    extends _$WeightMeasurementCopyWithImpl<$Res, _$WeightMeasurementImpl>
    implements _$$WeightMeasurementImplCopyWith<$Res> {
  __$$WeightMeasurementImplCopyWithImpl(
    _$WeightMeasurementImpl _value,
    $Res Function(_$WeightMeasurementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeightMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? weight = null,
    Object? note = freezed,
    Object? bodyFatPercentage = freezed,
    Object? muscleMass = freezed,
  }) {
    return _then(
      _$WeightMeasurementImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        bodyFatPercentage: freezed == bodyFatPercentage
            ? _value.bodyFatPercentage
            : bodyFatPercentage // ignore: cast_nullable_to_non_nullable
                  as double?,
        muscleMass: freezed == muscleMass
            ? _value.muscleMass
            : muscleMass // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeightMeasurementImpl implements _WeightMeasurement {
  const _$WeightMeasurementImpl({
    required this.date,
    required this.weight,
    this.note,
    this.bodyFatPercentage,
    this.muscleMass,
  });

  factory _$WeightMeasurementImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightMeasurementImplFromJson(json);

  /// Date of measurement
  @override
  final DateTime date;

  /// Weight in kg or lbs
  @override
  final double weight;

  /// Optional note about the measurement
  @override
  final String? note;

  /// Body fat percentage (optional)
  @override
  final double? bodyFatPercentage;

  /// Muscle mass (optional)
  @override
  final double? muscleMass;

  @override
  String toString() {
    return 'WeightMeasurement(date: $date, weight: $weight, note: $note, bodyFatPercentage: $bodyFatPercentage, muscleMass: $muscleMass)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightMeasurementImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.bodyFatPercentage, bodyFatPercentage) ||
                other.bodyFatPercentage == bodyFatPercentage) &&
            (identical(other.muscleMass, muscleMass) ||
                other.muscleMass == muscleMass));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    weight,
    note,
    bodyFatPercentage,
    muscleMass,
  );

  /// Create a copy of WeightMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightMeasurementImplCopyWith<_$WeightMeasurementImpl> get copyWith =>
      __$$WeightMeasurementImplCopyWithImpl<_$WeightMeasurementImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WeightMeasurement value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WeightMeasurement value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WeightMeasurement value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightMeasurementImplToJson(this);
  }
}

abstract class _WeightMeasurement implements WeightMeasurement {
  const factory _WeightMeasurement({
    required final DateTime date,
    required final double weight,
    final String? note,
    final double? bodyFatPercentage,
    final double? muscleMass,
  }) = _$WeightMeasurementImpl;

  factory _WeightMeasurement.fromJson(Map<String, dynamic> json) =
      _$WeightMeasurementImpl.fromJson;

  /// Date of measurement
  @override
  DateTime get date;

  /// Weight in kg or lbs
  @override
  double get weight;

  /// Optional note about the measurement
  @override
  String? get note;

  /// Body fat percentage (optional)
  @override
  double? get bodyFatPercentage;

  /// Muscle mass (optional)
  @override
  double? get muscleMass;

  /// Create a copy of WeightMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeightMeasurementImplCopyWith<_$WeightMeasurementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
