// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationSettings _$NotificationSettingsFromJson(Map<String, dynamic> json) {
  return _NotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettings {
  /// Whether notifications are enabled
  bool get isEnabled => throw _privateConstructorUsedError;

  /// Hour of the day for reminder (0-23)
  int get reminderHour => throw _privateConstructorUsedError;

  /// Minute of the hour for reminder (0-59)
  int get reminderMinute => throw _privateConstructorUsedError;

  /// Whether to show achievement notifications
  bool get showAchievements => throw _privateConstructorUsedError;

  /// Whether to show streak notifications
  bool get showStreakReminders => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_NotificationSettings value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_NotificationSettings value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_NotificationSettings value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationSettingsCopyWith<NotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsCopyWith<$Res> {
  factory $NotificationSettingsCopyWith(
    NotificationSettings value,
    $Res Function(NotificationSettings) then,
  ) = _$NotificationSettingsCopyWithImpl<$Res, NotificationSettings>;
  @useResult
  $Res call({
    bool isEnabled,
    int reminderHour,
    int reminderMinute,
    bool showAchievements,
    bool showStreakReminders,
  });
}

/// @nodoc
class _$NotificationSettingsCopyWithImpl<
  $Res,
  $Val extends NotificationSettings
>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? reminderHour = null,
    Object? reminderMinute = null,
    Object? showAchievements = null,
    Object? showStreakReminders = null,
  }) {
    return _then(
      _value.copyWith(
            isEnabled: null == isEnabled
                ? _value.isEnabled
                : isEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            reminderHour: null == reminderHour
                ? _value.reminderHour
                : reminderHour // ignore: cast_nullable_to_non_nullable
                      as int,
            reminderMinute: null == reminderMinute
                ? _value.reminderMinute
                : reminderMinute // ignore: cast_nullable_to_non_nullable
                      as int,
            showAchievements: null == showAchievements
                ? _value.showAchievements
                : showAchievements // ignore: cast_nullable_to_non_nullable
                      as bool,
            showStreakReminders: null == showStreakReminders
                ? _value.showStreakReminders
                : showStreakReminders // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationSettingsImplCopyWith<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  factory _$$NotificationSettingsImplCopyWith(
    _$NotificationSettingsImpl value,
    $Res Function(_$NotificationSettingsImpl) then,
  ) = __$$NotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isEnabled,
    int reminderHour,
    int reminderMinute,
    bool showAchievements,
    bool showStreakReminders,
  });
}

/// @nodoc
class __$$NotificationSettingsImplCopyWithImpl<$Res>
    extends _$NotificationSettingsCopyWithImpl<$Res, _$NotificationSettingsImpl>
    implements _$$NotificationSettingsImplCopyWith<$Res> {
  __$$NotificationSettingsImplCopyWithImpl(
    _$NotificationSettingsImpl _value,
    $Res Function(_$NotificationSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? reminderHour = null,
    Object? reminderMinute = null,
    Object? showAchievements = null,
    Object? showStreakReminders = null,
  }) {
    return _then(
      _$NotificationSettingsImpl(
        isEnabled: null == isEnabled
            ? _value.isEnabled
            : isEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        reminderHour: null == reminderHour
            ? _value.reminderHour
            : reminderHour // ignore: cast_nullable_to_non_nullable
                  as int,
        reminderMinute: null == reminderMinute
            ? _value.reminderMinute
            : reminderMinute // ignore: cast_nullable_to_non_nullable
                  as int,
        showAchievements: null == showAchievements
            ? _value.showAchievements
            : showAchievements // ignore: cast_nullable_to_non_nullable
                  as bool,
        showStreakReminders: null == showStreakReminders
            ? _value.showStreakReminders
            : showStreakReminders // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationSettingsImpl implements _NotificationSettings {
  const _$NotificationSettingsImpl({
    required this.isEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.showAchievements,
    required this.showStreakReminders,
  });

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

  /// Whether notifications are enabled
  @override
  final bool isEnabled;

  /// Hour of the day for reminder (0-23)
  @override
  final int reminderHour;

  /// Minute of the hour for reminder (0-59)
  @override
  final int reminderMinute;

  /// Whether to show achievement notifications
  @override
  final bool showAchievements;

  /// Whether to show streak notifications
  @override
  final bool showStreakReminders;

  @override
  String toString() {
    return 'NotificationSettings(isEnabled: $isEnabled, reminderHour: $reminderHour, reminderMinute: $reminderMinute, showAchievements: $showAchievements, showStreakReminders: $showStreakReminders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsImpl &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.reminderHour, reminderHour) ||
                other.reminderHour == reminderHour) &&
            (identical(other.reminderMinute, reminderMinute) ||
                other.reminderMinute == reminderMinute) &&
            (identical(other.showAchievements, showAchievements) ||
                other.showAchievements == showAchievements) &&
            (identical(other.showStreakReminders, showStreakReminders) ||
                other.showStreakReminders == showStreakReminders));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isEnabled,
    reminderHour,
    reminderMinute,
    showAchievements,
    showStreakReminders,
  );

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
  get copyWith =>
      __$$NotificationSettingsImplCopyWithImpl<_$NotificationSettingsImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_NotificationSettings value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_NotificationSettings value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_NotificationSettings value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsImplToJson(this);
  }
}

abstract class _NotificationSettings implements NotificationSettings {
  const factory _NotificationSettings({
    required final bool isEnabled,
    required final int reminderHour,
    required final int reminderMinute,
    required final bool showAchievements,
    required final bool showStreakReminders,
  }) = _$NotificationSettingsImpl;

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

  /// Whether notifications are enabled
  @override
  bool get isEnabled;

  /// Hour of the day for reminder (0-23)
  @override
  int get reminderHour;

  /// Minute of the hour for reminder (0-59)
  @override
  int get reminderMinute;

  /// Whether to show achievement notifications
  @override
  bool get showAchievements;

  /// Whether to show streak notifications
  @override
  bool get showStreakReminders;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
