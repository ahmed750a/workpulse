// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_break_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceBreakModel {
  String get id;
  @JsonKey(name: 'attendance_record_id')
  String get attendanceRecordId;
  @JsonKey(name: 'employee_id')
  String get employeeId;
  @JsonKey(name: 'break_start_at')
  String get breakStartAt;
  @JsonKey(name: 'break_end_at')
  String? get breakEndAt;
  @JsonKey(name: 'break_minutes')
  int get breakMinutes;
  String get status;
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of AttendanceBreakModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AttendanceBreakModelCopyWith<AttendanceBreakModel> get copyWith =>
      _$AttendanceBreakModelCopyWithImpl<AttendanceBreakModel>(
          this as AttendanceBreakModel, _$identity);

  /// Serializes this AttendanceBreakModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AttendanceBreakModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.attendanceRecordId, attendanceRecordId) ||
                other.attendanceRecordId == attendanceRecordId) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.breakStartAt, breakStartAt) ||
                other.breakStartAt == breakStartAt) &&
            (identical(other.breakEndAt, breakEndAt) ||
                other.breakEndAt == breakEndAt) &&
            (identical(other.breakMinutes, breakMinutes) ||
                other.breakMinutes == breakMinutes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      attendanceRecordId,
      employeeId,
      breakStartAt,
      breakEndAt,
      breakMinutes,
      status,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'AttendanceBreakModel(id: $id, attendanceRecordId: $attendanceRecordId, employeeId: $employeeId, breakStartAt: $breakStartAt, breakEndAt: $breakEndAt, breakMinutes: $breakMinutes, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $AttendanceBreakModelCopyWith<$Res> {
  factory $AttendanceBreakModelCopyWith(AttendanceBreakModel value,
          $Res Function(AttendanceBreakModel) _then) =
      _$AttendanceBreakModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'attendance_record_id') String attendanceRecordId,
      @JsonKey(name: 'employee_id') String employeeId,
      @JsonKey(name: 'break_start_at') String breakStartAt,
      @JsonKey(name: 'break_end_at') String? breakEndAt,
      @JsonKey(name: 'break_minutes') int breakMinutes,
      String status,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$AttendanceBreakModelCopyWithImpl<$Res>
    implements $AttendanceBreakModelCopyWith<$Res> {
  _$AttendanceBreakModelCopyWithImpl(this._self, this._then);

  final AttendanceBreakModel _self;
  final $Res Function(AttendanceBreakModel) _then;

  /// Create a copy of AttendanceBreakModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? attendanceRecordId = null,
    Object? employeeId = null,
    Object? breakStartAt = null,
    Object? breakEndAt = freezed,
    Object? breakMinutes = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      attendanceRecordId: null == attendanceRecordId
          ? _self.attendanceRecordId
          : attendanceRecordId // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _self.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      breakStartAt: null == breakStartAt
          ? _self.breakStartAt
          : breakStartAt // ignore: cast_nullable_to_non_nullable
              as String,
      breakEndAt: freezed == breakEndAt
          ? _self.breakEndAt
          : breakEndAt // ignore: cast_nullable_to_non_nullable
              as String?,
      breakMinutes: null == breakMinutes
          ? _self.breakMinutes
          : breakMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AttendanceBreakModel].
extension AttendanceBreakModelPatterns on AttendanceBreakModel {
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
    TResult Function(_AttendanceBreakModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceBreakModel() when $default != null:
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
    TResult Function(_AttendanceBreakModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceBreakModel():
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
    TResult? Function(_AttendanceBreakModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceBreakModel() when $default != null:
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
            @JsonKey(name: 'attendance_record_id') String attendanceRecordId,
            @JsonKey(name: 'employee_id') String employeeId,
            @JsonKey(name: 'break_start_at') String breakStartAt,
            @JsonKey(name: 'break_end_at') String? breakEndAt,
            @JsonKey(name: 'break_minutes') int breakMinutes,
            String status,
            @JsonKey(name: 'created_at') String? createdAt,
            @JsonKey(name: 'updated_at') String? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceBreakModel() when $default != null:
        return $default(
            _that.id,
            _that.attendanceRecordId,
            _that.employeeId,
            _that.breakStartAt,
            _that.breakEndAt,
            _that.breakMinutes,
            _that.status,
            _that.createdAt,
            _that.updatedAt);
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
            @JsonKey(name: 'attendance_record_id') String attendanceRecordId,
            @JsonKey(name: 'employee_id') String employeeId,
            @JsonKey(name: 'break_start_at') String breakStartAt,
            @JsonKey(name: 'break_end_at') String? breakEndAt,
            @JsonKey(name: 'break_minutes') int breakMinutes,
            String status,
            @JsonKey(name: 'created_at') String? createdAt,
            @JsonKey(name: 'updated_at') String? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceBreakModel():
        return $default(
            _that.id,
            _that.attendanceRecordId,
            _that.employeeId,
            _that.breakStartAt,
            _that.breakEndAt,
            _that.breakMinutes,
            _that.status,
            _that.createdAt,
            _that.updatedAt);
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
            @JsonKey(name: 'attendance_record_id') String attendanceRecordId,
            @JsonKey(name: 'employee_id') String employeeId,
            @JsonKey(name: 'break_start_at') String breakStartAt,
            @JsonKey(name: 'break_end_at') String? breakEndAt,
            @JsonKey(name: 'break_minutes') int breakMinutes,
            String status,
            @JsonKey(name: 'created_at') String? createdAt,
            @JsonKey(name: 'updated_at') String? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceBreakModel() when $default != null:
        return $default(
            _that.id,
            _that.attendanceRecordId,
            _that.employeeId,
            _that.breakStartAt,
            _that.breakEndAt,
            _that.breakMinutes,
            _that.status,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AttendanceBreakModel implements AttendanceBreakModel {
  const _AttendanceBreakModel(
      {required this.id,
      @JsonKey(name: 'attendance_record_id') required this.attendanceRecordId,
      @JsonKey(name: 'employee_id') required this.employeeId,
      @JsonKey(name: 'break_start_at') required this.breakStartAt,
      @JsonKey(name: 'break_end_at') this.breakEndAt,
      @JsonKey(name: 'break_minutes') this.breakMinutes = 0,
      this.status = 'active',
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});
  factory _AttendanceBreakModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceBreakModelFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'attendance_record_id')
  final String attendanceRecordId;
  @override
  @JsonKey(name: 'employee_id')
  final String employeeId;
  @override
  @JsonKey(name: 'break_start_at')
  final String breakStartAt;
  @override
  @JsonKey(name: 'break_end_at')
  final String? breakEndAt;
  @override
  @JsonKey(name: 'break_minutes')
  final int breakMinutes;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  /// Create a copy of AttendanceBreakModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AttendanceBreakModelCopyWith<_AttendanceBreakModel> get copyWith =>
      __$AttendanceBreakModelCopyWithImpl<_AttendanceBreakModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AttendanceBreakModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AttendanceBreakModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.attendanceRecordId, attendanceRecordId) ||
                other.attendanceRecordId == attendanceRecordId) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.breakStartAt, breakStartAt) ||
                other.breakStartAt == breakStartAt) &&
            (identical(other.breakEndAt, breakEndAt) ||
                other.breakEndAt == breakEndAt) &&
            (identical(other.breakMinutes, breakMinutes) ||
                other.breakMinutes == breakMinutes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      attendanceRecordId,
      employeeId,
      breakStartAt,
      breakEndAt,
      breakMinutes,
      status,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'AttendanceBreakModel(id: $id, attendanceRecordId: $attendanceRecordId, employeeId: $employeeId, breakStartAt: $breakStartAt, breakEndAt: $breakEndAt, breakMinutes: $breakMinutes, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$AttendanceBreakModelCopyWith<$Res>
    implements $AttendanceBreakModelCopyWith<$Res> {
  factory _$AttendanceBreakModelCopyWith(_AttendanceBreakModel value,
          $Res Function(_AttendanceBreakModel) _then) =
      __$AttendanceBreakModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'attendance_record_id') String attendanceRecordId,
      @JsonKey(name: 'employee_id') String employeeId,
      @JsonKey(name: 'break_start_at') String breakStartAt,
      @JsonKey(name: 'break_end_at') String? breakEndAt,
      @JsonKey(name: 'break_minutes') int breakMinutes,
      String status,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$AttendanceBreakModelCopyWithImpl<$Res>
    implements _$AttendanceBreakModelCopyWith<$Res> {
  __$AttendanceBreakModelCopyWithImpl(this._self, this._then);

  final _AttendanceBreakModel _self;
  final $Res Function(_AttendanceBreakModel) _then;

  /// Create a copy of AttendanceBreakModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? attendanceRecordId = null,
    Object? employeeId = null,
    Object? breakStartAt = null,
    Object? breakEndAt = freezed,
    Object? breakMinutes = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_AttendanceBreakModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      attendanceRecordId: null == attendanceRecordId
          ? _self.attendanceRecordId
          : attendanceRecordId // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _self.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      breakStartAt: null == breakStartAt
          ? _self.breakStartAt
          : breakStartAt // ignore: cast_nullable_to_non_nullable
              as String,
      breakEndAt: freezed == breakEndAt
          ? _self.breakEndAt
          : breakEndAt // ignore: cast_nullable_to_non_nullable
              as String?,
      breakMinutes: null == breakMinutes
          ? _self.breakMinutes
          : breakMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
