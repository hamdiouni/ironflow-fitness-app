// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consistency_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConsistencyMetrics _$ConsistencyMetricsFromJson(Map<String, dynamic> json) {
  return _ConsistencyMetrics.fromJson(json);
}

/// @nodoc
mixin _$ConsistencyMetrics {
  /// User ID
  String get userId => throw _privateConstructorUsedError;

  /// Total number of workouts in period
  int get totalWorkouts => throw _privateConstructorUsedError;

  /// Number of weeks in the tracking period
  int get totalWeeks => throw _privateConstructorUsedError;

  /// Average workouts per week
  double get averageWorkoutsPerWeek => throw _privateConstructorUsedError;

  /// Current streak (consecutive days with workouts)
  int get currentStreak => throw _privateConstructorUsedError;

  /// Longest streak achieved
  int get longestStreak => throw _privateConstructorUsedError;

  /// Adherence rate (0.0 to 1.0)
  /// Based on planned vs completed workouts
  double get adherenceRate => throw _privateConstructorUsedError;

  /// Weekly consistency data for heatmap
  List<WeeklyConsistency> get weeklyData => throw _privateConstructorUsedError;

  /// Most active day of week (0 = Monday, 6 = Sunday)
  int get mostActiveDay => throw _privateConstructorUsedError;

  /// Least active day of week
  int get leastActiveDay => throw _privateConstructorUsedError;

  /// Average workout duration in minutes
  double get averageDuration => throw _privateConstructorUsedError;

  /// Date range for these metrics
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ConsistencyMetrics value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ConsistencyMetrics value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ConsistencyMetrics value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ConsistencyMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConsistencyMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConsistencyMetricsCopyWith<ConsistencyMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsistencyMetricsCopyWith<$Res> {
  factory $ConsistencyMetricsCopyWith(
    ConsistencyMetrics value,
    $Res Function(ConsistencyMetrics) then,
  ) = _$ConsistencyMetricsCopyWithImpl<$Res, ConsistencyMetrics>;
  @useResult
  $Res call({
    String userId,
    int totalWorkouts,
    int totalWeeks,
    double averageWorkoutsPerWeek,
    int currentStreak,
    int longestStreak,
    double adherenceRate,
    List<WeeklyConsistency> weeklyData,
    int mostActiveDay,
    int leastActiveDay,
    double averageDuration,
    DateTime startDate,
    DateTime endDate,
  });
}

/// @nodoc
class _$ConsistencyMetricsCopyWithImpl<$Res, $Val extends ConsistencyMetrics>
    implements $ConsistencyMetricsCopyWith<$Res> {
  _$ConsistencyMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConsistencyMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalWorkouts = null,
    Object? totalWeeks = null,
    Object? averageWorkoutsPerWeek = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? adherenceRate = null,
    Object? weeklyData = null,
    Object? mostActiveDay = null,
    Object? leastActiveDay = null,
    Object? averageDuration = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalWorkouts: null == totalWorkouts
                ? _value.totalWorkouts
                : totalWorkouts // ignore: cast_nullable_to_non_nullable
                      as int,
            totalWeeks: null == totalWeeks
                ? _value.totalWeeks
                : totalWeeks // ignore: cast_nullable_to_non_nullable
                      as int,
            averageWorkoutsPerWeek: null == averageWorkoutsPerWeek
                ? _value.averageWorkoutsPerWeek
                : averageWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
                      as double,
            currentStreak: null == currentStreak
                ? _value.currentStreak
                : currentStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            longestStreak: null == longestStreak
                ? _value.longestStreak
                : longestStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            adherenceRate: null == adherenceRate
                ? _value.adherenceRate
                : adherenceRate // ignore: cast_nullable_to_non_nullable
                      as double,
            weeklyData: null == weeklyData
                ? _value.weeklyData
                : weeklyData // ignore: cast_nullable_to_non_nullable
                      as List<WeeklyConsistency>,
            mostActiveDay: null == mostActiveDay
                ? _value.mostActiveDay
                : mostActiveDay // ignore: cast_nullable_to_non_nullable
                      as int,
            leastActiveDay: null == leastActiveDay
                ? _value.leastActiveDay
                : leastActiveDay // ignore: cast_nullable_to_non_nullable
                      as int,
            averageDuration: null == averageDuration
                ? _value.averageDuration
                : averageDuration // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ConsistencyMetricsImplCopyWith<$Res>
    implements $ConsistencyMetricsCopyWith<$Res> {
  factory _$$ConsistencyMetricsImplCopyWith(
    _$ConsistencyMetricsImpl value,
    $Res Function(_$ConsistencyMetricsImpl) then,
  ) = __$$ConsistencyMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    int totalWorkouts,
    int totalWeeks,
    double averageWorkoutsPerWeek,
    int currentStreak,
    int longestStreak,
    double adherenceRate,
    List<WeeklyConsistency> weeklyData,
    int mostActiveDay,
    int leastActiveDay,
    double averageDuration,
    DateTime startDate,
    DateTime endDate,
  });
}

/// @nodoc
class __$$ConsistencyMetricsImplCopyWithImpl<$Res>
    extends _$ConsistencyMetricsCopyWithImpl<$Res, _$ConsistencyMetricsImpl>
    implements _$$ConsistencyMetricsImplCopyWith<$Res> {
  __$$ConsistencyMetricsImplCopyWithImpl(
    _$ConsistencyMetricsImpl _value,
    $Res Function(_$ConsistencyMetricsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConsistencyMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalWorkouts = null,
    Object? totalWeeks = null,
    Object? averageWorkoutsPerWeek = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? adherenceRate = null,
    Object? weeklyData = null,
    Object? mostActiveDay = null,
    Object? leastActiveDay = null,
    Object? averageDuration = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(
      _$ConsistencyMetricsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalWorkouts: null == totalWorkouts
            ? _value.totalWorkouts
            : totalWorkouts // ignore: cast_nullable_to_non_nullable
                  as int,
        totalWeeks: null == totalWeeks
            ? _value.totalWeeks
            : totalWeeks // ignore: cast_nullable_to_non_nullable
                  as int,
        averageWorkoutsPerWeek: null == averageWorkoutsPerWeek
            ? _value.averageWorkoutsPerWeek
            : averageWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
                  as double,
        currentStreak: null == currentStreak
            ? _value.currentStreak
            : currentStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        longestStreak: null == longestStreak
            ? _value.longestStreak
            : longestStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        adherenceRate: null == adherenceRate
            ? _value.adherenceRate
            : adherenceRate // ignore: cast_nullable_to_non_nullable
                  as double,
        weeklyData: null == weeklyData
            ? _value._weeklyData
            : weeklyData // ignore: cast_nullable_to_non_nullable
                  as List<WeeklyConsistency>,
        mostActiveDay: null == mostActiveDay
            ? _value.mostActiveDay
            : mostActiveDay // ignore: cast_nullable_to_non_nullable
                  as int,
        leastActiveDay: null == leastActiveDay
            ? _value.leastActiveDay
            : leastActiveDay // ignore: cast_nullable_to_non_nullable
                  as int,
        averageDuration: null == averageDuration
            ? _value.averageDuration
            : averageDuration // ignore: cast_nullable_to_non_nullable
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
class _$ConsistencyMetricsImpl extends _ConsistencyMetrics {
  const _$ConsistencyMetricsImpl({
    required this.userId,
    required this.totalWorkouts,
    required this.totalWeeks,
    required this.averageWorkoutsPerWeek,
    required this.currentStreak,
    required this.longestStreak,
    required this.adherenceRate,
    required final List<WeeklyConsistency> weeklyData,
    required this.mostActiveDay,
    required this.leastActiveDay,
    required this.averageDuration,
    required this.startDate,
    required this.endDate,
  }) : _weeklyData = weeklyData,
       super._();

  factory _$ConsistencyMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsistencyMetricsImplFromJson(json);

  /// User ID
  @override
  final String userId;

  /// Total number of workouts in period
  @override
  final int totalWorkouts;

  /// Number of weeks in the tracking period
  @override
  final int totalWeeks;

  /// Average workouts per week
  @override
  final double averageWorkoutsPerWeek;

  /// Current streak (consecutive days with workouts)
  @override
  final int currentStreak;

  /// Longest streak achieved
  @override
  final int longestStreak;

  /// Adherence rate (0.0 to 1.0)
  /// Based on planned vs completed workouts
  @override
  final double adherenceRate;

  /// Weekly consistency data for heatmap
  final List<WeeklyConsistency> _weeklyData;

  /// Weekly consistency data for heatmap
  @override
  List<WeeklyConsistency> get weeklyData {
    if (_weeklyData is EqualUnmodifiableListView) return _weeklyData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeklyData);
  }

  /// Most active day of week (0 = Monday, 6 = Sunday)
  @override
  final int mostActiveDay;

  /// Least active day of week
  @override
  final int leastActiveDay;

  /// Average workout duration in minutes
  @override
  final double averageDuration;

  /// Date range for these metrics
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;

  @override
  String toString() {
    return 'ConsistencyMetrics(userId: $userId, totalWorkouts: $totalWorkouts, totalWeeks: $totalWeeks, averageWorkoutsPerWeek: $averageWorkoutsPerWeek, currentStreak: $currentStreak, longestStreak: $longestStreak, adherenceRate: $adherenceRate, weeklyData: $weeklyData, mostActiveDay: $mostActiveDay, leastActiveDay: $leastActiveDay, averageDuration: $averageDuration, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsistencyMetricsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.totalWeeks, totalWeeks) ||
                other.totalWeeks == totalWeeks) &&
            (identical(other.averageWorkoutsPerWeek, averageWorkoutsPerWeek) ||
                other.averageWorkoutsPerWeek == averageWorkoutsPerWeek) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.adherenceRate, adherenceRate) ||
                other.adherenceRate == adherenceRate) &&
            const DeepCollectionEquality().equals(
              other._weeklyData,
              _weeklyData,
            ) &&
            (identical(other.mostActiveDay, mostActiveDay) ||
                other.mostActiveDay == mostActiveDay) &&
            (identical(other.leastActiveDay, leastActiveDay) ||
                other.leastActiveDay == leastActiveDay) &&
            (identical(other.averageDuration, averageDuration) ||
                other.averageDuration == averageDuration) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    totalWorkouts,
    totalWeeks,
    averageWorkoutsPerWeek,
    currentStreak,
    longestStreak,
    adherenceRate,
    const DeepCollectionEquality().hash(_weeklyData),
    mostActiveDay,
    leastActiveDay,
    averageDuration,
    startDate,
    endDate,
  );

  /// Create a copy of ConsistencyMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsistencyMetricsImplCopyWith<_$ConsistencyMetricsImpl> get copyWith =>
      __$$ConsistencyMetricsImplCopyWithImpl<_$ConsistencyMetricsImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ConsistencyMetrics value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ConsistencyMetrics value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ConsistencyMetrics value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsistencyMetricsImplToJson(this);
  }
}

abstract class _ConsistencyMetrics extends ConsistencyMetrics {
  const factory _ConsistencyMetrics({
    required final String userId,
    required final int totalWorkouts,
    required final int totalWeeks,
    required final double averageWorkoutsPerWeek,
    required final int currentStreak,
    required final int longestStreak,
    required final double adherenceRate,
    required final List<WeeklyConsistency> weeklyData,
    required final int mostActiveDay,
    required final int leastActiveDay,
    required final double averageDuration,
    required final DateTime startDate,
    required final DateTime endDate,
  }) = _$ConsistencyMetricsImpl;
  const _ConsistencyMetrics._() : super._();

  factory _ConsistencyMetrics.fromJson(Map<String, dynamic> json) =
      _$ConsistencyMetricsImpl.fromJson;

  /// User ID
  @override
  String get userId;

  /// Total number of workouts in period
  @override
  int get totalWorkouts;

  /// Number of weeks in the tracking period
  @override
  int get totalWeeks;

  /// Average workouts per week
  @override
  double get averageWorkoutsPerWeek;

  /// Current streak (consecutive days with workouts)
  @override
  int get currentStreak;

  /// Longest streak achieved
  @override
  int get longestStreak;

  /// Adherence rate (0.0 to 1.0)
  /// Based on planned vs completed workouts
  @override
  double get adherenceRate;

  /// Weekly consistency data for heatmap
  @override
  List<WeeklyConsistency> get weeklyData;

  /// Most active day of week (0 = Monday, 6 = Sunday)
  @override
  int get mostActiveDay;

  /// Least active day of week
  @override
  int get leastActiveDay;

  /// Average workout duration in minutes
  @override
  double get averageDuration;

  /// Date range for these metrics
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;

  /// Create a copy of ConsistencyMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConsistencyMetricsImplCopyWith<_$ConsistencyMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyConsistency _$WeeklyConsistencyFromJson(Map<String, dynamic> json) {
  return _WeeklyConsistency.fromJson(json);
}

/// @nodoc
mixin _$WeeklyConsistency {
  /// Week start date
  DateTime get weekStart => throw _privateConstructorUsedError;

  /// Number of workouts completed this week
  int get workoutsCompleted => throw _privateConstructorUsedError;

  /// Number of workouts planned this week
  int get workoutsPlanned => throw _privateConstructorUsedError;

  /// Daily workout status (7 days, true = workout done)
  List<bool> get dailyStatus => throw _privateConstructorUsedError;

  /// Total volume for the week
  double get totalVolume => throw _privateConstructorUsedError;

  /// Adherence rate for this week (0.0 to 1.0)
  double get adherenceRate => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WeeklyConsistency value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WeeklyConsistency value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WeeklyConsistency value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this WeeklyConsistency to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyConsistency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyConsistencyCopyWith<WeeklyConsistency> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyConsistencyCopyWith<$Res> {
  factory $WeeklyConsistencyCopyWith(
    WeeklyConsistency value,
    $Res Function(WeeklyConsistency) then,
  ) = _$WeeklyConsistencyCopyWithImpl<$Res, WeeklyConsistency>;
  @useResult
  $Res call({
    DateTime weekStart,
    int workoutsCompleted,
    int workoutsPlanned,
    List<bool> dailyStatus,
    double totalVolume,
    double adherenceRate,
  });
}

/// @nodoc
class _$WeeklyConsistencyCopyWithImpl<$Res, $Val extends WeeklyConsistency>
    implements $WeeklyConsistencyCopyWith<$Res> {
  _$WeeklyConsistencyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyConsistency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? workoutsCompleted = null,
    Object? workoutsPlanned = null,
    Object? dailyStatus = null,
    Object? totalVolume = null,
    Object? adherenceRate = null,
  }) {
    return _then(
      _value.copyWith(
            weekStart: null == weekStart
                ? _value.weekStart
                : weekStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            workoutsCompleted: null == workoutsCompleted
                ? _value.workoutsCompleted
                : workoutsCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            workoutsPlanned: null == workoutsPlanned
                ? _value.workoutsPlanned
                : workoutsPlanned // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyStatus: null == dailyStatus
                ? _value.dailyStatus
                : dailyStatus // ignore: cast_nullable_to_non_nullable
                      as List<bool>,
            totalVolume: null == totalVolume
                ? _value.totalVolume
                : totalVolume // ignore: cast_nullable_to_non_nullable
                      as double,
            adherenceRate: null == adherenceRate
                ? _value.adherenceRate
                : adherenceRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeeklyConsistencyImplCopyWith<$Res>
    implements $WeeklyConsistencyCopyWith<$Res> {
  factory _$$WeeklyConsistencyImplCopyWith(
    _$WeeklyConsistencyImpl value,
    $Res Function(_$WeeklyConsistencyImpl) then,
  ) = __$$WeeklyConsistencyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime weekStart,
    int workoutsCompleted,
    int workoutsPlanned,
    List<bool> dailyStatus,
    double totalVolume,
    double adherenceRate,
  });
}

/// @nodoc
class __$$WeeklyConsistencyImplCopyWithImpl<$Res>
    extends _$WeeklyConsistencyCopyWithImpl<$Res, _$WeeklyConsistencyImpl>
    implements _$$WeeklyConsistencyImplCopyWith<$Res> {
  __$$WeeklyConsistencyImplCopyWithImpl(
    _$WeeklyConsistencyImpl _value,
    $Res Function(_$WeeklyConsistencyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeeklyConsistency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? workoutsCompleted = null,
    Object? workoutsPlanned = null,
    Object? dailyStatus = null,
    Object? totalVolume = null,
    Object? adherenceRate = null,
  }) {
    return _then(
      _$WeeklyConsistencyImpl(
        weekStart: null == weekStart
            ? _value.weekStart
            : weekStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        workoutsCompleted: null == workoutsCompleted
            ? _value.workoutsCompleted
            : workoutsCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        workoutsPlanned: null == workoutsPlanned
            ? _value.workoutsPlanned
            : workoutsPlanned // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyStatus: null == dailyStatus
            ? _value._dailyStatus
            : dailyStatus // ignore: cast_nullable_to_non_nullable
                  as List<bool>,
        totalVolume: null == totalVolume
            ? _value.totalVolume
            : totalVolume // ignore: cast_nullable_to_non_nullable
                  as double,
        adherenceRate: null == adherenceRate
            ? _value.adherenceRate
            : adherenceRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyConsistencyImpl implements _WeeklyConsistency {
  const _$WeeklyConsistencyImpl({
    required this.weekStart,
    required this.workoutsCompleted,
    required this.workoutsPlanned,
    required final List<bool> dailyStatus,
    required this.totalVolume,
    required this.adherenceRate,
  }) : _dailyStatus = dailyStatus;

  factory _$WeeklyConsistencyImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyConsistencyImplFromJson(json);

  /// Week start date
  @override
  final DateTime weekStart;

  /// Number of workouts completed this week
  @override
  final int workoutsCompleted;

  /// Number of workouts planned this week
  @override
  final int workoutsPlanned;

  /// Daily workout status (7 days, true = workout done)
  final List<bool> _dailyStatus;

  /// Daily workout status (7 days, true = workout done)
  @override
  List<bool> get dailyStatus {
    if (_dailyStatus is EqualUnmodifiableListView) return _dailyStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyStatus);
  }

  /// Total volume for the week
  @override
  final double totalVolume;

  /// Adherence rate for this week (0.0 to 1.0)
  @override
  final double adherenceRate;

  @override
  String toString() {
    return 'WeeklyConsistency(weekStart: $weekStart, workoutsCompleted: $workoutsCompleted, workoutsPlanned: $workoutsPlanned, dailyStatus: $dailyStatus, totalVolume: $totalVolume, adherenceRate: $adherenceRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyConsistencyImpl &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.workoutsCompleted, workoutsCompleted) ||
                other.workoutsCompleted == workoutsCompleted) &&
            (identical(other.workoutsPlanned, workoutsPlanned) ||
                other.workoutsPlanned == workoutsPlanned) &&
            const DeepCollectionEquality().equals(
              other._dailyStatus,
              _dailyStatus,
            ) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.adherenceRate, adherenceRate) ||
                other.adherenceRate == adherenceRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    weekStart,
    workoutsCompleted,
    workoutsPlanned,
    const DeepCollectionEquality().hash(_dailyStatus),
    totalVolume,
    adherenceRate,
  );

  /// Create a copy of WeeklyConsistency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyConsistencyImplCopyWith<_$WeeklyConsistencyImpl> get copyWith =>
      __$$WeeklyConsistencyImplCopyWithImpl<_$WeeklyConsistencyImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WeeklyConsistency value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WeeklyConsistency value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WeeklyConsistency value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyConsistencyImplToJson(this);
  }
}

abstract class _WeeklyConsistency implements WeeklyConsistency {
  const factory _WeeklyConsistency({
    required final DateTime weekStart,
    required final int workoutsCompleted,
    required final int workoutsPlanned,
    required final List<bool> dailyStatus,
    required final double totalVolume,
    required final double adherenceRate,
  }) = _$WeeklyConsistencyImpl;

  factory _WeeklyConsistency.fromJson(Map<String, dynamic> json) =
      _$WeeklyConsistencyImpl.fromJson;

  /// Week start date
  @override
  DateTime get weekStart;

  /// Number of workouts completed this week
  @override
  int get workoutsCompleted;

  /// Number of workouts planned this week
  @override
  int get workoutsPlanned;

  /// Daily workout status (7 days, true = workout done)
  @override
  List<bool> get dailyStatus;

  /// Total volume for the week
  @override
  double get totalVolume;

  /// Adherence rate for this week (0.0 to 1.0)
  @override
  double get adherenceRate;

  /// Create a copy of WeeklyConsistency
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyConsistencyImplCopyWith<_$WeeklyConsistencyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
