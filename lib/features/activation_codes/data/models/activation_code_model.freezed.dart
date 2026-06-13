// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activation_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivationCodeModel {
  String get id;
  String get code;
  @JsonKey(name: 'full_name')
  String get fullName;
  String get email;
  String get role;
  @JsonKey(name: 'is_used')
  bool get isUsed;
  @JsonKey(name: 'expires_at')
  String get expiresAt;
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of ActivationCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActivationCodeModelCopyWith<ActivationCodeModel> get copyWith =>
      _$ActivationCodeModelCopyWithImpl<ActivationCodeModel>(
          this as ActivationCodeModel, _$identity);

  /// Serializes this ActivationCodeModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActivationCodeModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.isUsed, isUsed) || other.isUsed == isUsed) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, code, fullName, email, role,
      isUsed, expiresAt, createdAt);

  @override
  String toString() {
    return 'ActivationCodeModel(id: $id, code: $code, fullName: $fullName, email: $email, role: $role, isUsed: $isUsed, expiresAt: $expiresAt, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $ActivationCodeModelCopyWith<$Res> {
  factory $ActivationCodeModelCopyWith(
          ActivationCodeModel value, $Res Function(ActivationCodeModel) _then) =
      _$ActivationCodeModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String code,
      @JsonKey(name: 'full_name') String fullName,
      String email,
      String role,
      @JsonKey(name: 'is_used') bool isUsed,
      @JsonKey(name: 'expires_at') String expiresAt,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class _$ActivationCodeModelCopyWithImpl<$Res>
    implements $ActivationCodeModelCopyWith<$Res> {
  _$ActivationCodeModelCopyWithImpl(this._self, this._then);

  final ActivationCodeModel _self;
  final $Res Function(ActivationCodeModel) _then;

  /// Create a copy of ActivationCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? fullName = null,
    Object? email = null,
    Object? role = null,
    Object? isUsed = null,
    Object? expiresAt = null,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _self.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      isUsed: null == isUsed
          ? _self.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ActivationCodeModel].
extension ActivationCodeModelPatterns on ActivationCodeModel {
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
    TResult Function(_ActivationCodeModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActivationCodeModel() when $default != null:
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
    TResult Function(_ActivationCodeModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivationCodeModel():
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
    TResult? Function(_ActivationCodeModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivationCodeModel() when $default != null:
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
            String code,
            @JsonKey(name: 'full_name') String fullName,
            String email,
            String role,
            @JsonKey(name: 'is_used') bool isUsed,
            @JsonKey(name: 'expires_at') String expiresAt,
            @JsonKey(name: 'created_at') String? createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActivationCodeModel() when $default != null:
        return $default(_that.id, _that.code, _that.fullName, _that.email,
            _that.role, _that.isUsed, _that.expiresAt, _that.createdAt);
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
            String code,
            @JsonKey(name: 'full_name') String fullName,
            String email,
            String role,
            @JsonKey(name: 'is_used') bool isUsed,
            @JsonKey(name: 'expires_at') String expiresAt,
            @JsonKey(name: 'created_at') String? createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivationCodeModel():
        return $default(_that.id, _that.code, _that.fullName, _that.email,
            _that.role, _that.isUsed, _that.expiresAt, _that.createdAt);
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
            String code,
            @JsonKey(name: 'full_name') String fullName,
            String email,
            String role,
            @JsonKey(name: 'is_used') bool isUsed,
            @JsonKey(name: 'expires_at') String expiresAt,
            @JsonKey(name: 'created_at') String? createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivationCodeModel() when $default != null:
        return $default(_that.id, _that.code, _that.fullName, _that.email,
            _that.role, _that.isUsed, _that.expiresAt, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ActivationCodeModel implements ActivationCodeModel {
  const _ActivationCodeModel(
      {required this.id,
      required this.code,
      @JsonKey(name: 'full_name') required this.fullName,
      required this.email,
      required this.role,
      @JsonKey(name: 'is_used') required this.isUsed,
      @JsonKey(name: 'expires_at') required this.expiresAt,
      @JsonKey(name: 'created_at') this.createdAt});
  factory _ActivationCodeModel.fromJson(Map<String, dynamic> json) =>
      _$ActivationCodeModelFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final String email;
  @override
  final String role;
  @override
  @JsonKey(name: 'is_used')
  final bool isUsed;
  @override
  @JsonKey(name: 'expires_at')
  final String expiresAt;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  /// Create a copy of ActivationCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActivationCodeModelCopyWith<_ActivationCodeModel> get copyWith =>
      __$ActivationCodeModelCopyWithImpl<_ActivationCodeModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ActivationCodeModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ActivationCodeModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.isUsed, isUsed) || other.isUsed == isUsed) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, code, fullName, email, role,
      isUsed, expiresAt, createdAt);

  @override
  String toString() {
    return 'ActivationCodeModel(id: $id, code: $code, fullName: $fullName, email: $email, role: $role, isUsed: $isUsed, expiresAt: $expiresAt, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$ActivationCodeModelCopyWith<$Res>
    implements $ActivationCodeModelCopyWith<$Res> {
  factory _$ActivationCodeModelCopyWith(_ActivationCodeModel value,
          $Res Function(_ActivationCodeModel) _then) =
      __$ActivationCodeModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String code,
      @JsonKey(name: 'full_name') String fullName,
      String email,
      String role,
      @JsonKey(name: 'is_used') bool isUsed,
      @JsonKey(name: 'expires_at') String expiresAt,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class __$ActivationCodeModelCopyWithImpl<$Res>
    implements _$ActivationCodeModelCopyWith<$Res> {
  __$ActivationCodeModelCopyWithImpl(this._self, this._then);

  final _ActivationCodeModel _self;
  final $Res Function(_ActivationCodeModel) _then;

  /// Create a copy of ActivationCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? fullName = null,
    Object? email = null,
    Object? role = null,
    Object? isUsed = null,
    Object? expiresAt = null,
    Object? createdAt = freezed,
  }) {
    return _then(_ActivationCodeModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _self.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      isUsed: null == isUsed
          ? _self.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
