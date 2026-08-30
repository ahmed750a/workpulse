// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_schedule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkScheduleModel {
  String get id;
  String get name;
  @JsonKey(name: 'start_time')
  String get startTime;
  @JsonKey(name: 'end_time')
  String get endTime;
  @JsonKey(name: 'grace_minutes')
  int get graceMinutes;
  @JsonKey(name: 'work_days')
  List<int> get workDays;
  @JsonKey(name: 'is_default')
  bool get isDefault;
  @JsonKey(name: 'schedule_type')
  String get scheduleType;
  @JsonKey(name: 'required_minutes')
  int get requiredMinutes;
  @JsonKey(name: 'allow_check_in_after_end_time')
  bool get allowCheckInAfterEndTime;
  @JsonKey(name: 'geofence_enabled')
  bool get geofenceEnabled;
  @JsonKey(name: 'geofence_lat')
  double? get geofenceLat;
  @JsonKey(name: 'geofence_lng')
  double? get geofenceLng;
  @JsonKey(name: 'geofence_radius_m')
  int get geofenceRadiusM;
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of WorkScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WorkScheduleModelCopyWith<WorkScheduleModel> get copyWith =>
      _$WorkScheduleModelCopyWithImpl<WorkScheduleModel>(
          this as WorkScheduleModel, _$identity);

  /// Serializes this WorkScheduleModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WorkScheduleModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.graceMinutes, graceMinutes) ||
                other.graceMinutes == graceMinutes) &&
            const DeepCollectionEquality().equals(other.workDays, workDays) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.scheduleType, scheduleType) ||
                other.scheduleType == scheduleType) &&
            (identical(other.requiredMinutes, requiredMinutes) ||
                other.requiredMinutes == requiredMinutes) &&
            (identical(
                    other.allowCheckInAfterEndTime, allowCheckInAfterEndTime) ||
                other.allowCheckInAfterEndTime == allowCheckInAfterEndTime) &&
            (identical(other.geofenceEnabled, geofenceEnabled) ||
                other.geofenceEnabled == geofenceEnabled) &&
            (identical(other.geofenceLat, geofenceLat) ||
                other.geofenceLat == geofenceLat) &&
            (identical(other.geofenceLng, geofenceLng) ||
                other.geofenceLng == geofenceLng) &&
            (identical(other.geofenceRadiusM, geofenceRadiusM) ||
                other.geofenceRadiusM == geofenceRadiusM) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      startTime,
      endTime,
      graceMinutes,
      const DeepCollectionEquality().hash(workDays),
      isDefault,
      scheduleType,
      requiredMinutes,
      allowCheckInAfterEndTime,
      geofenceEnabled,
      geofenceLat,
      geofenceLng,
      geofenceRadiusM,
      createdAt);

  @override
  String toString() {
    return 'WorkScheduleModel(id: $id, name: $name, startTime: $startTime, endTime: $endTime, graceMinutes: $graceMinutes, workDays: $workDays, isDefault: $isDefault, scheduleType: $scheduleType, requiredMinutes: $requiredMinutes, allowCheckInAfterEndTime: $allowCheckInAfterEndTime, geofenceEnabled: $geofenceEnabled, geofenceLat: $geofenceLat, geofenceLng: $geofenceLng, geofenceRadiusM: $geofenceRadiusM, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $WorkScheduleModelCopyWith<$Res> {
  factory $WorkScheduleModelCopyWith(
          WorkScheduleModel value, $Res Function(WorkScheduleModel) _then) =
      _$WorkScheduleModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime,
      @JsonKey(name: 'grace_minutes') int graceMinutes,
      @JsonKey(name: 'work_days') List<int> workDays,
      @JsonKey(name: 'is_default') bool isDefault,
      @JsonKey(name: 'schedule_type') String scheduleType,
      @JsonKey(name: 'required_minutes') int requiredMinutes,
      @JsonKey(name: 'allow_check_in_after_end_time')
      bool allowCheckInAfterEndTime,
      @JsonKey(name: 'geofence_enabled') bool geofenceEnabled,
      @JsonKey(name: 'geofence_lat') double? geofenceLat,
      @JsonKey(name: 'geofence_lng') double? geofenceLng,
      @JsonKey(name: 'geofence_radius_m') int geofenceRadiusM,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class _$WorkScheduleModelCopyWithImpl<$Res>
    implements $WorkScheduleModelCopyWith<$Res> {
  _$WorkScheduleModelCopyWithImpl(this._self, this._then);

  final WorkScheduleModel _self;
  final $Res Function(WorkScheduleModel) _then;

  /// Create a copy of WorkScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? graceMinutes = null,
    Object? workDays = null,
    Object? isDefault = null,
    Object? scheduleType = null,
    Object? requiredMinutes = null,
    Object? allowCheckInAfterEndTime = null,
    Object? geofenceEnabled = null,
    Object? geofenceLat = freezed,
    Object? geofenceLng = freezed,
    Object? geofenceRadiusM = null,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      graceMinutes: null == graceMinutes
          ? _self.graceMinutes
          : graceMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      workDays: null == workDays
          ? _self.workDays
          : workDays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      isDefault: null == isDefault
          ? _self.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      scheduleType: null == scheduleType
          ? _self.scheduleType
          : scheduleType // ignore: cast_nullable_to_non_nullable
              as String,
      requiredMinutes: null == requiredMinutes
          ? _self.requiredMinutes
          : requiredMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      allowCheckInAfterEndTime: null == allowCheckInAfterEndTime
          ? _self.allowCheckInAfterEndTime
          : allowCheckInAfterEndTime // ignore: cast_nullable_to_non_nullable
              as bool,
      geofenceEnabled: null == geofenceEnabled
          ? _self.geofenceEnabled
          : geofenceEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      geofenceLat: freezed == geofenceLat
          ? _self.geofenceLat
          : geofenceLat // ignore: cast_nullable_to_non_nullable
              as double?,
      geofenceLng: freezed == geofenceLng
          ? _self.geofenceLng
          : geofenceLng // ignore: cast_nullable_to_non_nullable
              as double?,
      geofenceRadiusM: null == geofenceRadiusM
          ? _self.geofenceRadiusM
          : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [WorkScheduleModel].
extension WorkScheduleModelPatterns on WorkScheduleModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WorkScheduleModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkScheduleModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WorkScheduleModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkScheduleModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WorkScheduleModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkScheduleModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            @JsonKey(name: 'start_time') String startTime,
            @JsonKey(name: 'end_time') String endTime,
            @JsonKey(name: 'grace_minutes') int graceMinutes,
            @JsonKey(name: 'work_days') List<int> workDays,
            @JsonKey(name: 'is_default') bool isDefault,
            @JsonKey(name: 'schedule_type') String scheduleType,
            @JsonKey(name: 'required_minutes') int requiredMinutes,
            @JsonKey(name: 'allow_check_in_after_end_time')
            bool allowCheckInAfterEndTime,
            @JsonKey(name: 'geofence_enabled') bool geofenceEnabled,
            @JsonKey(name: 'geofence_lat') double? geofenceLat,
            @JsonKey(name: 'geofence_lng') double? geofenceLng,
            @JsonKey(name: 'geofence_radius_m') int geofenceRadiusM,
            @JsonKey(name: 'created_at') String? createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WorkScheduleModel() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.startTime,
            _that.endTime,
            _that.graceMinutes,
            _that.workDays,
            _that.isDefault,
            _that.scheduleType,
            _that.requiredMinutes,
            _that.allowCheckInAfterEndTime,
            _that.geofenceEnabled,
            _that.geofenceLat,
            _that.geofenceLng,
            _that.geofenceRadiusM,
            _that.createdAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            @JsonKey(name: 'start_time') String startTime,
            @JsonKey(name: 'end_time') String endTime,
            @JsonKey(name: 'grace_minutes') int graceMinutes,
            @JsonKey(name: 'work_days') List<int> workDays,
            @JsonKey(name: 'is_default') bool isDefault,
            @JsonKey(name: 'schedule_type') String scheduleType,
            @JsonKey(name: 'required_minutes') int requiredMinutes,
            @JsonKey(name: 'allow_check_in_after_end_time')
            bool allowCheckInAfterEndTime,
            @JsonKey(name: 'geofence_enabled') bool geofenceEnabled,
            @JsonKey(name: 'geofence_lat') double? geofenceLat,
            @JsonKey(name: 'geofence_lng') double? geofenceLng,
            @JsonKey(name: 'geofence_radius_m') int geofenceRadiusM,
            @JsonKey(name: 'created_at') String? createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkScheduleModel():
        return $default(
            _that.id,
            _that.name,
            _that.startTime,
            _that.endTime,
            _that.graceMinutes,
            _that.workDays,
            _that.isDefault,
            _that.scheduleType,
            _that.requiredMinutes,
            _that.allowCheckInAfterEndTime,
            _that.geofenceEnabled,
            _that.geofenceLat,
            _that.geofenceLng,
            _that.geofenceRadiusM,
            _that.createdAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            @JsonKey(name: 'start_time') String startTime,
            @JsonKey(name: 'end_time') String endTime,
            @JsonKey(name: 'grace_minutes') int graceMinutes,
            @JsonKey(name: 'work_days') List<int> workDays,
            @JsonKey(name: 'is_default') bool isDefault,
            @JsonKey(name: 'schedule_type') String scheduleType,
            @JsonKey(name: 'required_minutes') int requiredMinutes,
            @JsonKey(name: 'allow_check_in_after_end_time')
            bool allowCheckInAfterEndTime,
            @JsonKey(name: 'geofence_enabled') bool geofenceEnabled,
            @JsonKey(name: 'geofence_lat') double? geofenceLat,
            @JsonKey(name: 'geofence_lng') double? geofenceLng,
            @JsonKey(name: 'geofence_radius_m') int geofenceRadiusM,
            @JsonKey(name: 'created_at') String? createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkScheduleModel() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.startTime,
            _that.endTime,
            _that.graceMinutes,
            _that.workDays,
            _that.isDefault,
            _that.scheduleType,
            _that.requiredMinutes,
            _that.allowCheckInAfterEndTime,
            _that.geofenceEnabled,
            _that.geofenceLat,
            _that.geofenceLng,
            _that.geofenceRadiusM,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WorkScheduleModel implements WorkScheduleModel {
  const _WorkScheduleModel(
      {required this.id,
      required this.name,
      @JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') required this.endTime,
      @JsonKey(name: 'grace_minutes') required this.graceMinutes,
      @JsonKey(name: 'work_days') required final List<int> workDays,
      @JsonKey(name: 'is_default') required this.isDefault,
      @JsonKey(name: 'schedule_type') required this.scheduleType,
      @JsonKey(name: 'required_minutes') required this.requiredMinutes,
      @JsonKey(name: 'allow_check_in_after_end_time')
      this.allowCheckInAfterEndTime = true,
      @JsonKey(name: 'geofence_enabled') this.geofenceEnabled = false,
      @JsonKey(name: 'geofence_lat') this.geofenceLat,
      @JsonKey(name: 'geofence_lng') this.geofenceLng,
      @JsonKey(name: 'geofence_radius_m') this.geofenceRadiusM = 100,
      @JsonKey(name: 'created_at') this.createdAt})
      : _workDays = workDays;
  factory _WorkScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$WorkScheduleModelFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'start_time')
  final String startTime;
  @override
  @JsonKey(name: 'end_time')
  final String endTime;
  @override
  @JsonKey(name: 'grace_minutes')
  final int graceMinutes;
  final List<int> _workDays;
  @override
  @JsonKey(name: 'work_days')
  List<int> get workDays {
    if (_workDays is EqualUnmodifiableListView) return _workDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workDays);
  }

  @override
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @override
  @JsonKey(name: 'schedule_type')
  final String scheduleType;
  @override
  @JsonKey(name: 'required_minutes')
  final int requiredMinutes;
  @override
  @JsonKey(name: 'allow_check_in_after_end_time')
  final bool allowCheckInAfterEndTime;
  @override
  @JsonKey(name: 'geofence_enabled')
  final bool geofenceEnabled;
  @override
  @JsonKey(name: 'geofence_lat')
  final double? geofenceLat;
  @override
  @JsonKey(name: 'geofence_lng')
  final double? geofenceLng;
  @override
  @JsonKey(name: 'geofence_radius_m')
  final int geofenceRadiusM;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  /// Create a copy of WorkScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WorkScheduleModelCopyWith<_WorkScheduleModel> get copyWith =>
      __$WorkScheduleModelCopyWithImpl<_WorkScheduleModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WorkScheduleModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WorkScheduleModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.graceMinutes, graceMinutes) ||
                other.graceMinutes == graceMinutes) &&
            const DeepCollectionEquality().equals(other._workDays, _workDays) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.scheduleType, scheduleType) ||
                other.scheduleType == scheduleType) &&
            (identical(other.requiredMinutes, requiredMinutes) ||
                other.requiredMinutes == requiredMinutes) &&
            (identical(
                    other.allowCheckInAfterEndTime, allowCheckInAfterEndTime) ||
                other.allowCheckInAfterEndTime == allowCheckInAfterEndTime) &&
            (identical(other.geofenceEnabled, geofenceEnabled) ||
                other.geofenceEnabled == geofenceEnabled) &&
            (identical(other.geofenceLat, geofenceLat) ||
                other.geofenceLat == geofenceLat) &&
            (identical(other.geofenceLng, geofenceLng) ||
                other.geofenceLng == geofenceLng) &&
            (identical(other.geofenceRadiusM, geofenceRadiusM) ||
                other.geofenceRadiusM == geofenceRadiusM) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      startTime,
      endTime,
      graceMinutes,
      const DeepCollectionEquality().hash(_workDays),
      isDefault,
      scheduleType,
      requiredMinutes,
      allowCheckInAfterEndTime,
      geofenceEnabled,
      geofenceLat,
      geofenceLng,
      geofenceRadiusM,
      createdAt);

  @override
  String toString() {
    return 'WorkScheduleModel(id: $id, name: $name, startTime: $startTime, endTime: $endTime, graceMinutes: $graceMinutes, workDays: $workDays, isDefault: $isDefault, scheduleType: $scheduleType, requiredMinutes: $requiredMinutes, allowCheckInAfterEndTime: $allowCheckInAfterEndTime, geofenceEnabled: $geofenceEnabled, geofenceLat: $geofenceLat, geofenceLng: $geofenceLng, geofenceRadiusM: $geofenceRadiusM, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$WorkScheduleModelCopyWith<$Res>
    implements $WorkScheduleModelCopyWith<$Res> {
  factory _$WorkScheduleModelCopyWith(
          _WorkScheduleModel value, $Res Function(_WorkScheduleModel) _then) =
      __$WorkScheduleModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime,
      @JsonKey(name: 'grace_minutes') int graceMinutes,
      @JsonKey(name: 'work_days') List<int> workDays,
      @JsonKey(name: 'is_default') bool isDefault,
      @JsonKey(name: 'schedule_type') String scheduleType,
      @JsonKey(name: 'required_minutes') int requiredMinutes,
      @JsonKey(name: 'allow_check_in_after_end_time')
      bool allowCheckInAfterEndTime,
      @JsonKey(name: 'geofence_enabled') bool geofenceEnabled,
      @JsonKey(name: 'geofence_lat') double? geofenceLat,
      @JsonKey(name: 'geofence_lng') double? geofenceLng,
      @JsonKey(name: 'geofence_radius_m') int geofenceRadiusM,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class __$WorkScheduleModelCopyWithImpl<$Res>
    implements _$WorkScheduleModelCopyWith<$Res> {
  __$WorkScheduleModelCopyWithImpl(this._self, this._then);

  final _WorkScheduleModel _self;
  final $Res Function(_WorkScheduleModel) _then;

  /// Create a copy of WorkScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? graceMinutes = null,
    Object? workDays = null,
    Object? isDefault = null,
    Object? scheduleType = null,
    Object? requiredMinutes = null,
    Object? allowCheckInAfterEndTime = null,
    Object? geofenceEnabled = null,
    Object? geofenceLat = freezed,
    Object? geofenceLng = freezed,
    Object? geofenceRadiusM = null,
    Object? createdAt = freezed,
  }) {
    return _then(_WorkScheduleModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      graceMinutes: null == graceMinutes
          ? _self.graceMinutes
          : graceMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      workDays: null == workDays
          ? _self._workDays
          : workDays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      isDefault: null == isDefault
          ? _self.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      scheduleType: null == scheduleType
          ? _self.scheduleType
          : scheduleType // ignore: cast_nullable_to_non_nullable
              as String,
      requiredMinutes: null == requiredMinutes
          ? _self.requiredMinutes
          : requiredMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      allowCheckInAfterEndTime: null == allowCheckInAfterEndTime
          ? _self.allowCheckInAfterEndTime
          : allowCheckInAfterEndTime // ignore: cast_nullable_to_non_nullable
              as bool,
      geofenceEnabled: null == geofenceEnabled
          ? _self.geofenceEnabled
          : geofenceEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      geofenceLat: freezed == geofenceLat
          ? _self.geofenceLat
          : geofenceLat // ignore: cast_nullable_to_non_nullable
              as double?,
      geofenceLng: freezed == geofenceLng
          ? _self.geofenceLng
          : geofenceLng // ignore: cast_nullable_to_non_nullable
              as double?,
      geofenceRadiusM: null == geofenceRadiusM
          ? _self.geofenceRadiusM
          : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
