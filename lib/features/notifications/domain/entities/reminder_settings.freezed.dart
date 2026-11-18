// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReminderSettings _$ReminderSettingsFromJson(Map<String, dynamic> json) {
  return _ReminderSettings.fromJson(json);
}

/// @nodoc
mixin _$ReminderSettings {
  // Workout reminders
  bool get workoutRemindersEnabled => throw _privateConstructorUsedError;
  TimeOfDayModel get workoutReminderTime =>
      throw _privateConstructorUsedError; // Meal reminders
  bool get mealRemindersEnabled => throw _privateConstructorUsedError;
  TimeOfDayModel get breakfastTime => throw _privateConstructorUsedError;
  TimeOfDayModel get lunchTime => throw _privateConstructorUsedError;
  TimeOfDayModel get dinnerTime =>
      throw _privateConstructorUsedError; // Streak reminders
  bool get streakRemindersEnabled => throw _privateConstructorUsedError;
  TimeOfDayModel get streakReminderTime =>
      throw _privateConstructorUsedError; // General settings
  bool get soundEnabled => throw _privateConstructorUsedError;
  bool get vibrationEnabled => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReminderSettings value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReminderSettings value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReminderSettings value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ReminderSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReminderSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReminderSettingsCopyWith<ReminderSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReminderSettingsCopyWith<$Res> {
  factory $ReminderSettingsCopyWith(
    ReminderSettings value,
    $Res Function(ReminderSettings) then,
  ) = _$ReminderSettingsCopyWithImpl<$Res, ReminderSettings>;
  @useResult
  $Res call({
    bool workoutRemindersEnabled,
    TimeOfDayModel workoutReminderTime,
    bool mealRemindersEnabled,
    TimeOfDayModel breakfastTime,
    TimeOfDayModel lunchTime,
    TimeOfDayModel dinnerTime,
    bool streakRemindersEnabled,
    TimeOfDayModel streakReminderTime,
    bool soundEnabled,
    bool vibrationEnabled,
  });

  $TimeOfDayModelCopyWith<$Res> get workoutReminderTime;
  $TimeOfDayModelCopyWith<$Res> get breakfastTime;
  $TimeOfDayModelCopyWith<$Res> get lunchTime;
  $TimeOfDayModelCopyWith<$Res> get dinnerTime;
  $TimeOfDayModelCopyWith<$Res> get streakReminderTime;
}

/// @nodoc
class _$ReminderSettingsCopyWithImpl<$Res, $Val extends ReminderSettings>
    implements $ReminderSettingsCopyWith<$Res> {
  _$ReminderSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReminderSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutRemindersEnabled = null,
    Object? workoutReminderTime = null,
    Object? mealRemindersEnabled = null,
    Object? breakfastTime = null,
    Object? lunchTime = null,
    Object? dinnerTime = null,
    Object? streakRemindersEnabled = null,
    Object? streakReminderTime = null,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            workoutRemindersEnabled: null == workoutRemindersEnabled
                ? _value.workoutRemindersEnabled
                : workoutRemindersEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            workoutReminderTime: null == workoutReminderTime
                ? _value.workoutReminderTime
                : workoutReminderTime // ignore: cast_nullable_to_non_nullable
                      as TimeOfDayModel,
            mealRemindersEnabled: null == mealRemindersEnabled
                ? _value.mealRemindersEnabled
                : mealRemindersEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            breakfastTime: null == breakfastTime
                ? _value.breakfastTime
                : breakfastTime // ignore: cast_nullable_to_non_nullable
                      as TimeOfDayModel,
            lunchTime: null == lunchTime
                ? _value.lunchTime
                : lunchTime // ignore: cast_nullable_to_non_nullable
                      as TimeOfDayModel,
            dinnerTime: null == dinnerTime
                ? _value.dinnerTime
                : dinnerTime // ignore: cast_nullable_to_non_nullable
                      as TimeOfDayModel,
            streakRemindersEnabled: null == streakRemindersEnabled
                ? _value.streakRemindersEnabled
                : streakRemindersEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            streakReminderTime: null == streakReminderTime
                ? _value.streakReminderTime
                : streakReminderTime // ignore: cast_nullable_to_non_nullable
                      as TimeOfDayModel,
            soundEnabled: null == soundEnabled
                ? _value.soundEnabled
                : soundEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            vibrationEnabled: null == vibrationEnabled
                ? _value.vibrationEnabled
                : vibrationEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of ReminderSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayModelCopyWith<$Res> get workoutReminderTime {
    return $TimeOfDayModelCopyWith<$Res>(_value.workoutReminderTime, (value) {
      return _then(_value.copyWith(workoutReminderTime: value) as $Val);
    });
  }

  /// Create a copy of ReminderSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayModelCopyWith<$Res> get breakfastTime {
    return $TimeOfDayModelCopyWith<$Res>(_value.breakfastTime, (value) {
      return _then(_value.copyWith(breakfastTime: value) as $Val);
    });
  }

  /// Create a copy of ReminderSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayModelCopyWith<$Res> get lunchTime {
    return $TimeOfDayModelCopyWith<$Res>(_value.lunchTime, (value) {
      return _then(_value.copyWith(lunchTime: value) as $Val);
    });
  }

  /// Create a copy of ReminderSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayModelCopyWith<$Res> get dinnerTime {
    return $TimeOfDayModelCopyWith<$Res>(_value.dinnerTime, (value) {
      return _then(_value.copyWith(dinnerTime: value) as $Val);
    });
  }

  /// Create a copy of ReminderSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayModelCopyWith<$Res> get streakReminderTime {
    return $TimeOfDayModelCopyWith<$Res>(_value.streakReminderTime, (value) {
      return _then(_value.copyWith(streakReminderTime: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReminderSettingsImplCopyWith<$Res>
    implements $ReminderSettingsCopyWith<$Res> {
  factory _$$ReminderSettingsImplCopyWith(
    _$ReminderSettingsImpl value,
    $Res Function(_$ReminderSettingsImpl) then,
  ) = __$$ReminderSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool workoutRemindersEnabled,
    TimeOfDayModel workoutReminderTime,
    bool mealRemindersEnabled,
    TimeOfDayModel breakfastTime,
    TimeOfDayModel lunchTime,
    TimeOfDayModel dinnerTime,
    bool streakRemindersEnabled,
    TimeOfDayModel streakReminderTime,
    bool soundEnabled,
    bool vibrationEnabled,
  });

  @override
  $TimeOfDayModelCopyWith<$Res> get workoutReminderTime;
  @override
  $TimeOfDayModelCopyWith<$Res> get breakfastTime;
  @override
  $TimeOfDayModelCopyWith<$Res> get lunchTime;
  @override
  $TimeOfDayModelCopyWith<$Res> get dinnerTime;
  @override
  $TimeOfDayModelCopyWith<$Res> get streakReminderTime;
}

/// @nodoc
class __$$ReminderSettingsImplCopyWithImpl<$Res>
    extends _$ReminderSettingsCopyWithImpl<$Res, _$ReminderSettingsImpl>
    implements _$$ReminderSettingsImplCopyWith<$Res> {
  __$$ReminderSettingsImplCopyWithImpl(
    _$ReminderSettingsImpl _value,
    $Res Function(_$ReminderSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReminderSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutRemindersEnabled = null,
    Object? workoutReminderTime = null,
    Object? mealRemindersEnabled = null,
    Object? breakfastTime = null,
    Object? lunchTime = null,
    Object? dinnerTime = null,
    Object? streakRemindersEnabled = null,
    Object? streakReminderTime = null,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
  }) {
    return _then(
      _$ReminderSettingsImpl(
        workoutRemindersEnabled: null == workoutRemindersEnabled
            ? _value.workoutRemindersEnabled
            : workoutRemindersEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        workoutReminderTime: null == workoutReminderTime
            ? _value.workoutReminderTime
            : workoutReminderTime // ignore: cast_nullable_to_non_nullable
                  as TimeOfDayModel,
        mealRemindersEnabled: null == mealRemindersEnabled
            ? _value.mealRemindersEnabled
            : mealRemindersEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        breakfastTime: null == breakfastTime
            ? _value.breakfastTime
            : breakfastTime // ignore: cast_nullable_to_non_nullable
                  as TimeOfDayModel,
        lunchTime: null == lunchTime
            ? _value.lunchTime
            : lunchTime // ignore: cast_nullable_to_non_nullable
                  as TimeOfDayModel,
        dinnerTime: null == dinnerTime
            ? _value.dinnerTime
            : dinnerTime // ignore: cast_nullable_to_non_nullable
                  as TimeOfDayModel,
        streakRemindersEnabled: null == streakRemindersEnabled
            ? _value.streakRemindersEnabled
            : streakRemindersEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        streakReminderTime: null == streakReminderTime
            ? _value.streakReminderTime
            : streakReminderTime // ignore: cast_nullable_to_non_nullable
                  as TimeOfDayModel,
        soundEnabled: null == soundEnabled
            ? _value.soundEnabled
            : soundEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        vibrationEnabled: null == vibrationEnabled
            ? _value.vibrationEnabled
            : vibrationEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReminderSettingsImpl implements _ReminderSettings {
  const _$ReminderSettingsImpl({
    this.workoutRemindersEnabled = false,
    this.workoutReminderTime = const TimeOfDayModel(hour: 18, minute: 0),
    this.mealRemindersEnabled = false,
    this.breakfastTime = const TimeOfDayModel(hour: 8, minute: 0),
    this.lunchTime = const TimeOfDayModel(hour: 12, minute: 0),
    this.dinnerTime = const TimeOfDayModel(hour: 19, minute: 0),
    this.streakRemindersEnabled = false,
    this.streakReminderTime = const TimeOfDayModel(hour: 20, minute: 0),
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory _$ReminderSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReminderSettingsImplFromJson(json);

  // Workout reminders
  @override
  @JsonKey()
  final bool workoutRemindersEnabled;
  @override
  @JsonKey()
  final TimeOfDayModel workoutReminderTime;
  // Meal reminders
  @override
  @JsonKey()
  final bool mealRemindersEnabled;
  @override
  @JsonKey()
  final TimeOfDayModel breakfastTime;
  @override
  @JsonKey()
  final TimeOfDayModel lunchTime;
  @override
  @JsonKey()
  final TimeOfDayModel dinnerTime;
  // Streak reminders
  @override
  @JsonKey()
  final bool streakRemindersEnabled;
  @override
  @JsonKey()
  final TimeOfDayModel streakReminderTime;
  // General settings
  @override
  @JsonKey()
  final bool soundEnabled;
  @override
  @JsonKey()
  final bool vibrationEnabled;

  @override
  String toString() {
    return 'ReminderSettings(workoutRemindersEnabled: $workoutRemindersEnabled, workoutReminderTime: $workoutReminderTime, mealRemindersEnabled: $mealRemindersEnabled, breakfastTime: $breakfastTime, lunchTime: $lunchTime, dinnerTime: $dinnerTime, streakRemindersEnabled: $streakRemindersEnabled, streakReminderTime: $streakReminderTime, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReminderSettingsImpl &&
            (identical(
                  other.workoutRemindersEnabled,
                  workoutRemindersEnabled,
                ) ||
                other.workoutRemindersEnabled == workoutRemindersEnabled) &&
            (identical(other.workoutReminderTime, workoutReminderTime) ||
                other.workoutReminderTime == workoutReminderTime) &&
            (identical(other.mealRemindersEnabled, mealRemindersEnabled) ||
                other.mealRemindersEnabled == mealRemindersEnabled) &&
            (identical(other.breakfastTime, breakfastTime) ||
                other.breakfastTime == breakfastTime) &&
            (identical(other.lunchTime, lunchTime) ||
                other.lunchTime == lunchTime) &&
            (identical(other.dinnerTime, dinnerTime) ||
                other.dinnerTime == dinnerTime) &&
            (identical(other.streakRemindersEnabled, streakRemindersEnabled) ||
                other.streakRemindersEnabled == streakRemindersEnabled) &&
            (identical(other.streakReminderTime, streakReminderTime) ||
                other.streakReminderTime == streakReminderTime) &&
            (identical(other.soundEnabled, soundEnabled) ||
                other.soundEnabled == soundEnabled) &&
            (identical(other.vibrationEnabled, vibrationEnabled) ||
                other.vibrationEnabled == vibrationEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    workoutRemindersEnabled,
    workoutReminderTime,
    mealRemindersEnabled,
    breakfastTime,
    lunchTime,
    dinnerTime,
    streakRemindersEnabled,
    streakReminderTime,
    soundEnabled,
    vibrationEnabled,
  );

  /// Create a copy of ReminderSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReminderSettingsImplCopyWith<_$ReminderSettingsImpl> get copyWith =>
      __$$ReminderSettingsImplCopyWithImpl<_$ReminderSettingsImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReminderSettings value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReminderSettings value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReminderSettings value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ReminderSettingsImplToJson(this);
  }
}

abstract class _ReminderSettings implements ReminderSettings {
  const factory _ReminderSettings({
    final bool workoutRemindersEnabled,
    final TimeOfDayModel workoutReminderTime,
    final bool mealRemindersEnabled,
    final TimeOfDayModel breakfastTime,
    final TimeOfDayModel lunchTime,
    final TimeOfDayModel dinnerTime,
    final bool streakRemindersEnabled,
    final TimeOfDayModel streakReminderTime,
    final bool soundEnabled,
    final bool vibrationEnabled,
  }) = _$ReminderSettingsImpl;

  factory _ReminderSettings.fromJson(Map<String, dynamic> json) =
      _$ReminderSettingsImpl.fromJson;

  // Workout reminders
  @override
  bool get workoutRemindersEnabled;
  @override
  TimeOfDayModel get workoutReminderTime; // Meal reminders
  @override
  bool get mealRemindersEnabled;
  @override
  TimeOfDayModel get breakfastTime;
  @override
  TimeOfDayModel get lunchTime;
  @override
  TimeOfDayModel get dinnerTime; // Streak reminders
  @override
  bool get streakRemindersEnabled;
  @override
  TimeOfDayModel get streakReminderTime; // General settings
  @override
  bool get soundEnabled;
  @override
  bool get vibrationEnabled;

  /// Create a copy of ReminderSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReminderSettingsImplCopyWith<_$ReminderSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeOfDayModel _$TimeOfDayModelFromJson(Map<String, dynamic> json) {
  return _TimeOfDayModel.fromJson(json);
}

/// @nodoc
mixin _$TimeOfDayModel {
  int get hour => throw _privateConstructorUsedError;
  int get minute => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TimeOfDayModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TimeOfDayModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TimeOfDayModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this TimeOfDayModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeOfDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeOfDayModelCopyWith<TimeOfDayModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeOfDayModelCopyWith<$Res> {
  factory $TimeOfDayModelCopyWith(
    TimeOfDayModel value,
    $Res Function(TimeOfDayModel) then,
  ) = _$TimeOfDayModelCopyWithImpl<$Res, TimeOfDayModel>;
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class _$TimeOfDayModelCopyWithImpl<$Res, $Val extends TimeOfDayModel>
    implements $TimeOfDayModelCopyWith<$Res> {
  _$TimeOfDayModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeOfDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hour = null, Object? minute = null}) {
    return _then(
      _value.copyWith(
            hour: null == hour
                ? _value.hour
                : hour // ignore: cast_nullable_to_non_nullable
                      as int,
            minute: null == minute
                ? _value.minute
                : minute // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimeOfDayModelImplCopyWith<$Res>
    implements $TimeOfDayModelCopyWith<$Res> {
  factory _$$TimeOfDayModelImplCopyWith(
    _$TimeOfDayModelImpl value,
    $Res Function(_$TimeOfDayModelImpl) then,
  ) = __$$TimeOfDayModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class __$$TimeOfDayModelImplCopyWithImpl<$Res>
    extends _$TimeOfDayModelCopyWithImpl<$Res, _$TimeOfDayModelImpl>
    implements _$$TimeOfDayModelImplCopyWith<$Res> {
  __$$TimeOfDayModelImplCopyWithImpl(
    _$TimeOfDayModelImpl _value,
    $Res Function(_$TimeOfDayModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimeOfDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hour = null, Object? minute = null}) {
    return _then(
      _$TimeOfDayModelImpl(
        hour: null == hour
            ? _value.hour
            : hour // ignore: cast_nullable_to_non_nullable
                  as int,
        minute: null == minute
            ? _value.minute
            : minute // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeOfDayModelImpl implements _TimeOfDayModel {
  const _$TimeOfDayModelImpl({required this.hour, required this.minute});

  factory _$TimeOfDayModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeOfDayModelImplFromJson(json);

  @override
  final int hour;
  @override
  final int minute;

  @override
  String toString() {
    return 'TimeOfDayModel(hour: $hour, minute: $minute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeOfDayModelImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute);

  /// Create a copy of TimeOfDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeOfDayModelImplCopyWith<_$TimeOfDayModelImpl> get copyWith =>
      __$$TimeOfDayModelImplCopyWithImpl<_$TimeOfDayModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TimeOfDayModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TimeOfDayModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TimeOfDayModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeOfDayModelImplToJson(this);
  }
}

abstract class _TimeOfDayModel implements TimeOfDayModel {
  const factory _TimeOfDayModel({
    required final int hour,
    required final int minute,
  }) = _$TimeOfDayModelImpl;

  factory _TimeOfDayModel.fromJson(Map<String, dynamic> json) =
      _$TimeOfDayModelImpl.fromJson;

  @override
  int get hour;
  @override
  int get minute;

  /// Create a copy of TimeOfDayModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeOfDayModelImplCopyWith<_$TimeOfDayModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
