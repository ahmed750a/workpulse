// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceRecordModel {
  String get id;
  @JsonKey(name: 'approved_early_leave_minutes')
  int get approvedEarlyLeaveMinutes;
  @JsonKey(name: 'unapproved_early_leave_minutes')
  int get unapprovedEarlyLeaveMinutes;
  @JsonKey(name: 'employee_id')
  String get employeeId;
  @JsonKey(name: 'attendance_date')
  String get attendanceDate;
  @JsonKey(name: 'check_in_at')
  String? get checkInAt;
  @JsonKey(name: 'check_out_at')
  String? get checkOutAt;
  String get status;
  @JsonKey(name: 'late_minutes')
  int get lateMinutes;
  @JsonKey(name: 'total_late_minutes')
  int get totalLateMinutes;
  @JsonKey(name: 'approved_late_minutes')
  int get approvedLateMinutes;
  @JsonKey(name: 'unapproved_late_minutes')
  int get unapprovedLateMinutes;
  @JsonKey(name: 'early_leave_minutes')
  int get earlyLeaveMinutes;
  @JsonKey(name: 'worked_minutes')
  int get workedMinutes;
  String? get notes;
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of AttendanceRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AttendanceRecordModelCopyWith<AttendanceRecordModel> get copyWith =>
      _$AttendanceRecordModelCopyWithImpl<AttendanceRecordModel>(
          this as AttendanceRecordModel, _$identity);

  /// Serializes this AttendanceRecordModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AttendanceRecordModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.approvedEarlyLeaveMinutes,
                    approvedEarlyLeaveMinutes) ||
                other.approvedEarlyLeaveMinutes == approvedEarlyLeaveMinutes) &&
            (identical(other.unapprovedEarlyLeaveMinutes,
                    unapprovedEarlyLeaveMinutes) ||
                other.unapprovedEarlyLeaveMinutes ==
                    unapprovedEarlyLeaveMinutes) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.attendanceDate, attendanceDate) ||
                other.attendanceDate == attendanceDate) &&
            (identical(other.checkInAt, checkInAt) ||
                other.checkInAt == checkInAt) &&
            (identical(other.checkOutAt, checkOutAt) ||
                other.checkOutAt == checkOutAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lateMinutes, lateMinutes) ||
                other.lateMinutes == lateMinutes) &&
            (identical(other.totalLateMinutes, totalLateMinutes) ||
                other.totalLateMinutes == totalLateMinutes) &&
            (identical(other.approvedLateMinutes, approvedLateMinutes) ||
                other.approvedLateMinutes == approvedLateMinutes) &&
            (identical(other.unapprovedLateMinutes, unapprovedLateMinutes) ||
                other.unapprovedLateMinutes == unapprovedLateMinutes) &&
            (identical(other.earlyLeaveMinutes, earlyLeaveMinutes) ||
                other.earlyLeaveMinutes == earlyLeaveMinutes) &&
            (identical(other.workedMinutes, workedMinutes) ||
                other.workedMinutes == workedMinutes) &&
            (identical(other.notes, notes) || other.notes == notes) &&
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
      approvedEarlyLeaveMinutes,
      unapprovedEarlyLeaveMinutes,
      employeeId,
      attendanceDate,
      checkInAt,
      checkOutAt,
      status,
      lateMinutes,
      totalLateMinutes,
      approvedLateMinutes,
      unapprovedLateMinutes,
      earlyLeaveMinutes,
      workedMinutes,
      notes,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'AttendanceRecordModel(id: $id, approvedEarlyLeaveMinutes: $approvedEarlyLeaveMinutes, unapprovedEarlyLeaveMinutes: $unapprovedEarlyLeaveMinutes, employeeId: $employeeId, attendanceDate: $attendanceDate, checkInAt: $checkInAt, checkOutAt: $checkOutAt, status: $status, lateMinutes: $lateMinutes, totalLateMinutes: $totalLateMinutes, approvedLateMinutes: $approvedLateMinutes, unapprovedLateMinutes: $unapprovedLateMinutes, earlyLeaveMinutes: $earlyLeaveMinutes, workedMinutes: $workedMinutes, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $AttendanceRecordModelCopyWith<$Res> {
  factory $AttendanceRecordModelCopyWith(AttendanceRecordModel value,
          $Res Function(AttendanceRecordModel) _then) =
      _$AttendanceRecordModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'approved_early_leave_minutes')
      int approvedEarlyLeaveMinutes,
      @JsonKey(name: 'unapproved_early_leave_minutes')
      int unapprovedEarlyLeaveMinutes,
      @JsonKey(name: 'employee_id') String employeeId,
      @JsonKey(name: 'attendance_date') String attendanceDate,
      @JsonKey(name: 'check_in_at') String? checkInAt,
      @JsonKey(name: 'check_out_at') String? checkOutAt,
      String status,
      @JsonKey(name: 'late_minutes') int lateMinutes,
      @JsonKey(name: 'total_late_minutes') int totalLateMinutes,
      @JsonKey(name: 'approved_late_minutes') int approvedLateMinutes,
      @JsonKey(name: 'unapproved_late_minutes') int unapprovedLateMinutes,
      @JsonKey(name: 'early_leave_minutes') int earlyLeaveMinutes,
      @JsonKey(name: 'worked_minutes') int workedMinutes,
      String? notes,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$AttendanceRecordModelCopyWithImpl<$Res>
    implements $AttendanceRecordModelCopyWith<$Res> {
  _$AttendanceRecordModelCopyWithImpl(this._self, this._then);

  final AttendanceRecordModel _self;
  final $Res Function(AttendanceRecordModel) _then;

  /// Create a copy of AttendanceRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? approvedEarlyLeaveMinutes = null,
    Object? unapprovedEarlyLeaveMinutes = null,
    Object? employeeId = null,
    Object? attendanceDate = null,
    Object? checkInAt = freezed,
    Object? checkOutAt = freezed,
    Object? status = null,
    Object? lateMinutes = null,
    Object? totalLateMinutes = null,
    Object? approvedLateMinutes = null,
    Object? unapprovedLateMinutes = null,
    Object? earlyLeaveMinutes = null,
    Object? workedMinutes = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      approvedEarlyLeaveMinutes: null == approvedEarlyLeaveMinutes
          ? _self.approvedEarlyLeaveMinutes
          : approvedEarlyLeaveMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      unapprovedEarlyLeaveMinutes: null == unapprovedEarlyLeaveMinutes
          ? _self.unapprovedEarlyLeaveMinutes
          : unapprovedEarlyLeaveMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      employeeId: null == employeeId
          ? _self.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      attendanceDate: null == attendanceDate
          ? _self.attendanceDate
          : attendanceDate // ignore: cast_nullable_to_non_nullable
              as String,
      checkInAt: freezed == checkInAt
          ? _self.checkInAt
          : checkInAt // ignore: cast_nullable_to_non_nullable
              as String?,
      checkOutAt: freezed == checkOutAt
          ? _self.checkOutAt
          : checkOutAt // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      lateMinutes: null == lateMinutes
          ? _self.lateMinutes
          : lateMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalLateMinutes: null == totalLateMinutes
          ? _self.totalLateMinutes
          : totalLateMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      approvedLateMinutes: null == approvedLateMinutes
          ? _self.approvedLateMinutes
          : approvedLateMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      unapprovedLateMinutes: null == unapprovedLateMinutes
          ? _self.unapprovedLateMinutes
          : unapprovedLateMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      earlyLeaveMinutes: null == earlyLeaveMinutes
          ? _self.earlyLeaveMinutes
          : earlyLeaveMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      workedMinutes: null == workedMinutes
          ? _self.workedMinutes
          : workedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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

/// Adds pattern-matching-related methods to [AttendanceRecordModel].
extension AttendanceRecordModelPatterns on AttendanceRecordModel {
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
    TResult Function(_AttendanceRecordModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceRecordModel() when $default != null:
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
    TResult Function(_AttendanceRecordModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceRecordModel():
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
    TResult? Function(_AttendanceRecordModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceRecordModel() when $default != null:
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
            @JsonKey(name: 'approved_early_leave_minutes')
            int approvedEarlyLeaveMinutes,
            @JsonKey(name: 'unapproved_early_leave_minutes')
            int unapprovedEarlyLeaveMinutes,
            @JsonKey(name: 'employee_id') String employeeId,
            @JsonKey(name: 'attendance_date') String attendanceDate,
            @JsonKey(name: 'check_in_at') String? checkInAt,
            @JsonKey(name: 'check_out_at') String? checkOutAt,
            String status,
            @JsonKey(name: 'late_minutes') int lateMinutes,
            @JsonKey(name: 'total_late_minutes') int totalLateMinutes,
            @JsonKey(name: 'approved_late_minutes') int approvedLateMinutes,
            @JsonKey(name: 'unapproved_late_minutes') int unapprovedLateMinutes,
            @JsonKey(name: 'early_leave_minutes') int earlyLeaveMinutes,
            @JsonKey(name: 'worked_minutes') int workedMinutes,
            String? notes,
            @JsonKey(name: 'created_at') String? createdAt,
            @JsonKey(name: 'updated_at') String? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceRecordModel() when $default != null:
        return $default(
            _that.id,
            _that.approvedEarlyLeaveMinutes,
            _that.unapprovedEarlyLeaveMinutes,
            _that.employeeId,
            _that.attendanceDate,
            _that.checkInAt,
            _that.checkOutAt,
            _that.status,
            _that.lateMinutes,
            _that.totalLateMinutes,
            _that.approvedLateMinutes,
            _that.unapprovedLateMinutes,
            _that.earlyLeaveMinutes,
            _that.workedMinutes,
            _that.notes,
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
            @JsonKey(name: 'approved_early_leave_minutes')
            int approvedEarlyLeaveMinutes,
            @JsonKey(name: 'unapproved_early_leave_minutes')
            int unapprovedEarlyLeaveMinutes,
            @JsonKey(name: 'employee_id') String employeeId,
            @JsonKey(name: 'attendance_date') String attendanceDate,
            @JsonKey(name: 'check_in_at') String? checkInAt,
            @JsonKey(name: 'check_out_at') String? checkOutAt,
            String status,
            @JsonKey(name: 'late_minutes') int lateMinutes,
            @JsonKey(name: 'total_late_minutes') int totalLateMinutes,
            @JsonKey(name: 'approved_late_minutes') int approvedLateMinutes,
            @JsonKey(name: 'unapproved_late_minutes') int unapprovedLateMinutes,
            @JsonKey(name: 'early_leave_minutes') int earlyLeaveMinutes,
            @JsonKey(name: 'worked_minutes') int workedMinutes,
            String? notes,
            @JsonKey(name: 'created_at') String? createdAt,
            @JsonKey(name: 'updated_at') String? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceRecordModel():
        return $default(
            _that.id,
            _that.approvedEarlyLeaveMinutes,
            _that.unapprovedEarlyLeaveMinutes,
            _that.employeeId,
            _that.attendanceDate,
            _that.checkInAt,
            _that.checkOutAt,
            _that.status,
            _that.lateMinutes,
            _that.totalLateMinutes,
            _that.approvedLateMinutes,
            _that.unapprovedLateMinutes,
            _that.earlyLeaveMinutes,
            _that.workedMinutes,
            _that.notes,
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
            @JsonKey(name: 'approved_early_leave_minutes')
            int approvedEarlyLeaveMinutes,
            @JsonKey(name: 'unapproved_early_leave_minutes')
            int unapprovedEarlyLeaveMinutes,
            @JsonKey(name: 'employee_id') String employeeId,
            @JsonKey(name: 'attendance_date') String attendanceDate,
            @JsonKey(name: 'check_in_at') String? checkInAt,
            @JsonKey(name: 'check_out_at') String? checkOutAt,
            String status,
            @JsonKey(name: 'late_minutes') int lateMinutes,
            @JsonKey(name: 'total_late_minutes') int totalLateMinutes,
            @JsonKey(name: 'approved_late_minutes') int approvedLateMinutes,
            @JsonKey(name: 'unapproved_late_minutes') int unapprovedLateMinutes,
            @JsonKey(name: 'early_leave_minutes') int earlyLeaveMinutes,
            @JsonKey(name: 'worked_minutes') int workedMinutes,
            String? notes,
            @JsonKey(name: 'created_at') String? createdAt,
            @JsonKey(name: 'updated_at') String? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceRecordModel() when $default != null:
        return $default(
            _that.id,
            _that.approvedEarlyLeaveMinutes,
            _that.unapprovedEarlyLeaveMinutes,
            _that.employeeId,
            _that.attendanceDate,
            _that.checkInAt,
            _that.checkOutAt,
            _that.status,
            _that.lateMinutes,
            _that.totalLateMinutes,
            _that.approvedLateMinutes,
            _that.unapprovedLateMinutes,
            _that.earlyLeaveMinutes,
            _that.workedMinutes,
            _that.notes,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AttendanceRecordModel implements AttendanceRecordModel {
  const _AttendanceRecordModel(
      {required this.id,
      @JsonKey(name: 'approved_early_leave_minutes')
      required this.approvedEarlyLeaveMinutes,
      @JsonKey(name: 'unapproved_early_leave_minutes')
      required this.unapprovedEarlyLeaveMinutes,
      @JsonKey(name: 'employee_id') required this.employeeId,
      @JsonKey(name: 'attendance_date') required this.attendanceDate,
      @JsonKey(name: 'check_in_at') this.checkInAt,
      @JsonKey(name: 'check_out_at') this.checkOutAt,
      required this.status,
      @JsonKey(name: 'late_minutes') required this.lateMinutes,
      @JsonKey(name: 'total_late_minutes') this.totalLateMinutes = 0,
      @JsonKey(name: 'approved_late_minutes') this.approvedLateMinutes = 0,
      @JsonKey(name: 'unapproved_late_minutes') this.unapprovedLateMinutes = 0,
      @JsonKey(name: 'early_leave_minutes') required this.earlyLeaveMinutes,
      @JsonKey(name: 'worked_minutes') required this.workedMinutes,
      this.notes,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});
  factory _AttendanceRecordModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordModelFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'approved_early_leave_minutes')
  final int approvedEarlyLeaveMinutes;
  @override
  @JsonKey(name: 'unapproved_early_leave_minutes')
  final int unapprovedEarlyLeaveMinutes;
  @override
  @JsonKey(name: 'employee_id')
  final String employeeId;
  @override
  @JsonKey(name: 'attendance_date')
  final String attendanceDate;
  @override
  @JsonKey(name: 'check_in_at')
  final String? checkInAt;
  @override
  @JsonKey(name: 'check_out_at')
  final String? checkOutAt;
  @override
  final String status;
  @override
  @JsonKey(name: 'late_minutes')
  final int lateMinutes;
  @override
  @JsonKey(name: 'total_late_minutes')
  final int totalLateMinutes;
  @override
  @JsonKey(name: 'approved_late_minutes')
  final int approvedLateMinutes;
  @override
  @JsonKey(name: 'unapproved_late_minutes')
  final int unapprovedLateMinutes;
  @override
  @JsonKey(name: 'early_leave_minutes')
  final int earlyLeaveMinutes;
  @override
  @JsonKey(name: 'worked_minutes')
  final int workedMinutes;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  /// Create a copy of AttendanceRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AttendanceRecordModelCopyWith<_AttendanceRecordModel> get copyWith =>
      __$AttendanceRecordModelCopyWithImpl<_AttendanceRecordModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AttendanceRecordModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AttendanceRecordModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.approvedEarlyLeaveMinutes,
                    approvedEarlyLeaveMinutes) ||
                other.approvedEarlyLeaveMinutes == approvedEarlyLeaveMinutes) &&
            (identical(other.unapprovedEarlyLeaveMinutes,
                    unapprovedEarlyLeaveMinutes) ||
                other.unapprovedEarlyLeaveMinutes ==
                    unapprovedEarlyLeaveMinutes) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.attendanceDate, attendanceDate) ||
                other.attendanceDate == attendanceDate) &&
            (identical(other.checkInAt, checkInAt) ||
                other.checkInAt == checkInAt) &&
            (identical(other.checkOutAt, checkOutAt) ||
                other.checkOutAt == checkOutAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lateMinutes, lateMinutes) ||
                other.lateMinutes == lateMinutes) &&
            (identical(other.totalLateMinutes, totalLateMinutes) ||
                other.totalLateMinutes == totalLateMinutes) &&
            (identical(other.approvedLateMinutes, approvedLateMinutes) ||
                other.approvedLateMinutes == approvedLateMinutes) &&
            (identical(other.unapprovedLateMinutes, unapprovedLateMinutes) ||
                other.unapprovedLateMinutes == unapprovedLateMinutes) &&
            (identical(other.earlyLeaveMinutes, earlyLeaveMinutes) ||
                other.earlyLeaveMinutes == earlyLeaveMinutes) &&
            (identical(other.workedMinutes, workedMinutes) ||
                other.workedMinutes == workedMinutes) &&
            (identical(other.notes, notes) || other.notes == notes) &&
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
      approvedEarlyLeaveMinutes,
      unapprovedEarlyLeaveMinutes,
      employeeId,
      attendanceDate,
      checkInAt,
      checkOutAt,
      status,
      lateMinutes,
      totalLateMinutes,
      approvedLateMinutes,
      unapprovedLateMinutes,
      earlyLeaveMinutes,
      workedMinutes,
      notes,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'AttendanceRecordModel(id: $id, approvedEarlyLeaveMinutes: $approvedEarlyLeaveMinutes, unapprovedEarlyLeaveMinutes: $unapprovedEarlyLeaveMinutes, employeeId: $employeeId, attendanceDate: $attendanceDate, checkInAt: $checkInAt, checkOutAt: $checkOutAt, status: $status, lateMinutes: $lateMinutes, totalLateMinutes: $totalLateMinutes, approvedLateMinutes: $approvedLateMinutes, unapprovedLateMinutes: $unapprovedLateMinutes, earlyLeaveMinutes: $earlyLeaveMinutes, workedMinutes: $workedMinutes, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$AttendanceRecordModelCopyWith<$Res>
    implements $AttendanceRecordModelCopyWith<$Res> {
  factory _$AttendanceRecordModelCopyWith(_AttendanceRecordModel value,
          $Res Function(_AttendanceRecordModel) _then) =
      __$AttendanceRecordModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'approved_early_leave_minutes')
      int approvedEarlyLeaveMinutes,
      @JsonKey(name: 'unapproved_early_leave_minutes')
      int unapprovedEarlyLeaveMinutes,
      @JsonKey(name: 'employee_id') String employeeId,
      @JsonKey(name: 'attendance_date') String attendanceDate,
      @JsonKey(name: 'check_in_at') String? checkInAt,
      @JsonKey(name: 'check_out_at') String? checkOutAt,
      String status,
      @JsonKey(name: 'late_minutes') int lateMinutes,
      @JsonKey(name: 'total_late_minutes') int totalLateMinutes,
      @JsonKey(name: 'approved_late_minutes') int approvedLateMinutes,
      @JsonKey(name: 'unapproved_late_minutes') int unapprovedLateMinutes,
      @JsonKey(name: 'early_leave_minutes') int earlyLeaveMinutes,
      @JsonKey(name: 'worked_minutes') int workedMinutes,
      String? notes,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$AttendanceRecordModelCopyWithImpl<$Res>
    implements _$AttendanceRecordModelCopyWith<$Res> {
  __$AttendanceRecordModelCopyWithImpl(this._self, this._then);

  final _AttendanceRecordModel _self;
  final $Res Function(_AttendanceRecordModel) _then;

  /// Create a copy of AttendanceRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? approvedEarlyLeaveMinutes = null,
    Object? unapprovedEarlyLeaveMinutes = null,
    Object? employeeId = null,
    Object? attendanceDate = null,
    Object? checkInAt = freezed,
    Object? checkOutAt = freezed,
    Object? status = null,
    Object? lateMinutes = null,
    Object? totalLateMinutes = null,
    Object? approvedLateMinutes = null,
    Object? unapprovedLateMinutes = null,
    Object? earlyLeaveMinutes = null,
    Object? workedMinutes = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_AttendanceRecordModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      approvedEarlyLeaveMinutes: null == approvedEarlyLeaveMinutes
          ? _self.approvedEarlyLeaveMinutes
          : approvedEarlyLeaveMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      unapprovedEarlyLeaveMinutes: null == unapprovedEarlyLeaveMinutes
          ? _self.unapprovedEarlyLeaveMinutes
          : unapprovedEarlyLeaveMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      employeeId: null == employeeId
          ? _self.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      attendanceDate: null == attendanceDate
          ? _self.attendanceDate
          : attendanceDate // ignore: cast_nullable_to_non_nullable
              as String,
      checkInAt: freezed == checkInAt
          ? _self.checkInAt
          : checkInAt // ignore: cast_nullable_to_non_nullable
              as String?,
      checkOutAt: freezed == checkOutAt
          ? _self.checkOutAt
          : checkOutAt // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      lateMinutes: null == lateMinutes
          ? _self.lateMinutes
          : lateMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalLateMinutes: null == totalLateMinutes
          ? _self.totalLateMinutes
          : totalLateMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      approvedLateMinutes: null == approvedLateMinutes
          ? _self.approvedLateMinutes
          : approvedLateMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      unapprovedLateMinutes: null == unapprovedLateMinutes
          ? _self.unapprovedLateMinutes
          : unapprovedLateMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      earlyLeaveMinutes: null == earlyLeaveMinutes
          ? _self.earlyLeaveMinutes
          : earlyLeaveMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      workedMinutes: null == workedMinutes
          ? _self.workedMinutes
          : workedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
