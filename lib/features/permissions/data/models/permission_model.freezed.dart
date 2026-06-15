// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'permission_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PermissionModel {
  String get id;
  @JsonKey(name: 'employee_id')
  String get employeeId;
  @JsonKey(name: 'permission_date')
  String get permissionDate;
  @JsonKey(name: 'start_time')
  String get startTime;
  @JsonKey(name: 'end_time')
  String get endTime;
  @JsonKey(name: 'total_minutes')
  int get totalMinutes;
  String get type;
  String get reason;
  String get status;
  @JsonKey(name: 'reviewed_by')
  String? get reviewedBy;
  @JsonKey(name: 'reviewed_at')
  String? get reviewedAt;
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason;
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of PermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PermissionModelCopyWith<PermissionModel> get copyWith =>
      _$PermissionModelCopyWithImpl<PermissionModel>(
          this as PermissionModel, _$identity);

  /// Serializes this PermissionModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PermissionModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.permissionDate, permissionDate) ||
                other.permissionDate == permissionDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
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
      employeeId,
      permissionDate,
      startTime,
      endTime,
      totalMinutes,
      type,
      reason,
      status,
      reviewedBy,
      reviewedAt,
      rejectionReason,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'PermissionModel(id: $id, employeeId: $employeeId, permissionDate: $permissionDate, startTime: $startTime, endTime: $endTime, totalMinutes: $totalMinutes, type: $type, reason: $reason, status: $status, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $PermissionModelCopyWith<$Res> {
  factory $PermissionModelCopyWith(
          PermissionModel value, $Res Function(PermissionModel) _then) =
      _$PermissionModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'employee_id') String employeeId,
      @JsonKey(name: 'permission_date') String permissionDate,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime,
      @JsonKey(name: 'total_minutes') int totalMinutes,
      String type,
      String reason,
      String status,
      @JsonKey(name: 'reviewed_by') String? reviewedBy,
      @JsonKey(name: 'reviewed_at') String? reviewedAt,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$PermissionModelCopyWithImpl<$Res>
    implements $PermissionModelCopyWith<$Res> {
  _$PermissionModelCopyWithImpl(this._self, this._then);

  final PermissionModel _self;
  final $Res Function(PermissionModel) _then;

  /// Create a copy of PermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? permissionDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? totalMinutes = null,
    Object? type = null,
    Object? reason = null,
    Object? status = null,
    Object? reviewedBy = freezed,
    Object? reviewedAt = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _self.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      permissionDate: null == permissionDate
          ? _self.permissionDate
          : permissionDate // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      totalMinutes: null == totalMinutes
          ? _self.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      reviewedBy: freezed == reviewedBy
          ? _self.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _self.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _self.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
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

/// Adds pattern-matching-related methods to [PermissionModel].
extension PermissionModelPatterns on PermissionModel {
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
    TResult Function(_PermissionModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PermissionModel() when $default != null:
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
    TResult Function(_PermissionModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PermissionModel():
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
    TResult? Function(_PermissionModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PermissionModel() when $default != null:
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
            @JsonKey(name: 'employee_id') String employeeId,
            @JsonKey(name: 'permission_date') String permissionDate,
            @JsonKey(name: 'start_time') String startTime,
            @JsonKey(name: 'end_time') String endTime,
            @JsonKey(name: 'total_minutes') int totalMinutes,
            String type,
            String reason,
            String status,
            @JsonKey(name: 'reviewed_by') String? reviewedBy,
            @JsonKey(name: 'reviewed_at') String? reviewedAt,
            @JsonKey(name: 'rejection_reason') String? rejectionReason,
            @JsonKey(name: 'created_at') String? createdAt,
            @JsonKey(name: 'updated_at') String? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PermissionModel() when $default != null:
        return $default(
            _that.id,
            _that.employeeId,
            _that.permissionDate,
            _that.startTime,
            _that.endTime,
            _that.totalMinutes,
            _that.type,
            _that.reason,
            _that.status,
            _that.reviewedBy,
            _that.reviewedAt,
            _that.rejectionReason,
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
            @JsonKey(name: 'employee_id') String employeeId,
            @JsonKey(name: 'permission_date') String permissionDate,
            @JsonKey(name: 'start_time') String startTime,
            @JsonKey(name: 'end_time') String endTime,
            @JsonKey(name: 'total_minutes') int totalMinutes,
            String type,
            String reason,
            String status,
            @JsonKey(name: 'reviewed_by') String? reviewedBy,
            @JsonKey(name: 'reviewed_at') String? reviewedAt,
            @JsonKey(name: 'rejection_reason') String? rejectionReason,
            @JsonKey(name: 'created_at') String? createdAt,
            @JsonKey(name: 'updated_at') String? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PermissionModel():
        return $default(
            _that.id,
            _that.employeeId,
            _that.permissionDate,
            _that.startTime,
            _that.endTime,
            _that.totalMinutes,
            _that.type,
            _that.reason,
            _that.status,
            _that.reviewedBy,
            _that.reviewedAt,
            _that.rejectionReason,
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
            @JsonKey(name: 'employee_id') String employeeId,
            @JsonKey(name: 'permission_date') String permissionDate,
            @JsonKey(name: 'start_time') String startTime,
            @JsonKey(name: 'end_time') String endTime,
            @JsonKey(name: 'total_minutes') int totalMinutes,
            String type,
            String reason,
            String status,
            @JsonKey(name: 'reviewed_by') String? reviewedBy,
            @JsonKey(name: 'reviewed_at') String? reviewedAt,
            @JsonKey(name: 'rejection_reason') String? rejectionReason,
            @JsonKey(name: 'created_at') String? createdAt,
            @JsonKey(name: 'updated_at') String? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PermissionModel() when $default != null:
        return $default(
            _that.id,
            _that.employeeId,
            _that.permissionDate,
            _that.startTime,
            _that.endTime,
            _that.totalMinutes,
            _that.type,
            _that.reason,
            _that.status,
            _that.reviewedBy,
            _that.reviewedAt,
            _that.rejectionReason,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PermissionModel implements PermissionModel {
  const _PermissionModel(
      {required this.id,
      @JsonKey(name: 'employee_id') required this.employeeId,
      @JsonKey(name: 'permission_date') required this.permissionDate,
      @JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') required this.endTime,
      @JsonKey(name: 'total_minutes') required this.totalMinutes,
      required this.type,
      required this.reason,
      required this.status,
      @JsonKey(name: 'reviewed_by') this.reviewedBy,
      @JsonKey(name: 'reviewed_at') this.reviewedAt,
      @JsonKey(name: 'rejection_reason') this.rejectionReason,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});
  factory _PermissionModel.fromJson(Map<String, dynamic> json) =>
      _$PermissionModelFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'employee_id')
  final String employeeId;
  @override
  @JsonKey(name: 'permission_date')
  final String permissionDate;
  @override
  @JsonKey(name: 'start_time')
  final String startTime;
  @override
  @JsonKey(name: 'end_time')
  final String endTime;
  @override
  @JsonKey(name: 'total_minutes')
  final int totalMinutes;
  @override
  final String type;
  @override
  final String reason;
  @override
  final String status;
  @override
  @JsonKey(name: 'reviewed_by')
  final String? reviewedBy;
  @override
  @JsonKey(name: 'reviewed_at')
  final String? reviewedAt;
  @override
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  /// Create a copy of PermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PermissionModelCopyWith<_PermissionModel> get copyWith =>
      __$PermissionModelCopyWithImpl<_PermissionModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PermissionModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PermissionModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.permissionDate, permissionDate) ||
                other.permissionDate == permissionDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
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
      employeeId,
      permissionDate,
      startTime,
      endTime,
      totalMinutes,
      type,
      reason,
      status,
      reviewedBy,
      reviewedAt,
      rejectionReason,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'PermissionModel(id: $id, employeeId: $employeeId, permissionDate: $permissionDate, startTime: $startTime, endTime: $endTime, totalMinutes: $totalMinutes, type: $type, reason: $reason, status: $status, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$PermissionModelCopyWith<$Res>
    implements $PermissionModelCopyWith<$Res> {
  factory _$PermissionModelCopyWith(
          _PermissionModel value, $Res Function(_PermissionModel) _then) =
      __$PermissionModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'employee_id') String employeeId,
      @JsonKey(name: 'permission_date') String permissionDate,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime,
      @JsonKey(name: 'total_minutes') int totalMinutes,
      String type,
      String reason,
      String status,
      @JsonKey(name: 'reviewed_by') String? reviewedBy,
      @JsonKey(name: 'reviewed_at') String? reviewedAt,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$PermissionModelCopyWithImpl<$Res>
    implements _$PermissionModelCopyWith<$Res> {
  __$PermissionModelCopyWithImpl(this._self, this._then);

  final _PermissionModel _self;
  final $Res Function(_PermissionModel) _then;

  /// Create a copy of PermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? permissionDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? totalMinutes = null,
    Object? type = null,
    Object? reason = null,
    Object? status = null,
    Object? reviewedBy = freezed,
    Object? reviewedAt = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_PermissionModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _self.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      permissionDate: null == permissionDate
          ? _self.permissionDate
          : permissionDate // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      totalMinutes: null == totalMinutes
          ? _self.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      reviewedBy: freezed == reviewedBy
          ? _self.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _self.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _self.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
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
