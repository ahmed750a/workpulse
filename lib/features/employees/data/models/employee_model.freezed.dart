// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmployeeModel {
  String get id;
  String get email;
  @JsonKey(name: 'full_name')
  String get fullName;
  String? get role;
  String? get department;
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of EmployeeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EmployeeModelCopyWith<EmployeeModel> get copyWith =>
      _$EmployeeModelCopyWithImpl<EmployeeModel>(
          this as EmployeeModel, _$identity);

  /// Serializes this EmployeeModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EmployeeModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, email, fullName, role, department, isActive, createdAt);

  @override
  String toString() {
    return 'EmployeeModel(id: $id, email: $email, fullName: $fullName, role: $role, department: $department, isActive: $isActive, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $EmployeeModelCopyWith<$Res> {
  factory $EmployeeModelCopyWith(
          EmployeeModel value, $Res Function(EmployeeModel) _then) =
      _$EmployeeModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String email,
      @JsonKey(name: 'full_name') String fullName,
      String? role,
      String? department,
      @JsonKey(name: 'is_active') bool? isActive,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class _$EmployeeModelCopyWithImpl<$Res>
    implements $EmployeeModelCopyWith<$Res> {
  _$EmployeeModelCopyWithImpl(this._self, this._then);

  final EmployeeModel _self;
  final $Res Function(EmployeeModel) _then;

  /// Create a copy of EmployeeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = null,
    Object? role = freezed,
    Object? department = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _self.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      role: freezed == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _self.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [EmployeeModel].
extension EmployeeModelPatterns on EmployeeModel {
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
    TResult Function(_EmployeeModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EmployeeModel() when $default != null:
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
    TResult Function(_EmployeeModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EmployeeModel():
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
    TResult? Function(_EmployeeModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EmployeeModel() when $default != null:
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
            String email,
            @JsonKey(name: 'full_name') String fullName,
            String? role,
            String? department,
            @JsonKey(name: 'is_active') bool? isActive,
            @JsonKey(name: 'created_at') String? createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EmployeeModel() when $default != null:
        return $default(_that.id, _that.email, _that.fullName, _that.role,
            _that.department, _that.isActive, _that.createdAt);
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
            String email,
            @JsonKey(name: 'full_name') String fullName,
            String? role,
            String? department,
            @JsonKey(name: 'is_active') bool? isActive,
            @JsonKey(name: 'created_at') String? createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EmployeeModel():
        return $default(_that.id, _that.email, _that.fullName, _that.role,
            _that.department, _that.isActive, _that.createdAt);
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
            String email,
            @JsonKey(name: 'full_name') String fullName,
            String? role,
            String? department,
            @JsonKey(name: 'is_active') bool? isActive,
            @JsonKey(name: 'created_at') String? createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EmployeeModel() when $default != null:
        return $default(_that.id, _that.email, _that.fullName, _that.role,
            _that.department, _that.isActive, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _EmployeeModel implements EmployeeModel {
  const _EmployeeModel(
      {required this.id,
      required this.email,
      @JsonKey(name: 'full_name') required this.fullName,
      this.role,
      this.department,
      @JsonKey(name: 'is_active') this.isActive,
      @JsonKey(name: 'created_at') this.createdAt});
  factory _EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final String? role;
  @override
  final String? department;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  /// Create a copy of EmployeeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EmployeeModelCopyWith<_EmployeeModel> get copyWith =>
      __$EmployeeModelCopyWithImpl<_EmployeeModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$EmployeeModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EmployeeModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, email, fullName, role, department, isActive, createdAt);

  @override
  String toString() {
    return 'EmployeeModel(id: $id, email: $email, fullName: $fullName, role: $role, department: $department, isActive: $isActive, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$EmployeeModelCopyWith<$Res>
    implements $EmployeeModelCopyWith<$Res> {
  factory _$EmployeeModelCopyWith(
          _EmployeeModel value, $Res Function(_EmployeeModel) _then) =
      __$EmployeeModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      @JsonKey(name: 'full_name') String fullName,
      String? role,
      String? department,
      @JsonKey(name: 'is_active') bool? isActive,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class __$EmployeeModelCopyWithImpl<$Res>
    implements _$EmployeeModelCopyWith<$Res> {
  __$EmployeeModelCopyWithImpl(this._self, this._then);

  final _EmployeeModel _self;
  final $Res Function(_EmployeeModel) _then;

  /// Create a copy of EmployeeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = null,
    Object? role = freezed,
    Object? department = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_EmployeeModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _self.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      role: freezed == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _self.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
