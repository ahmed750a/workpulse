// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceModel {
  String get id;
  String get employeeId;
  DateTime get date;
  String? get checkIn;
  String? get checkOut;
  bool? get isLate;
  bool? get isAbsent;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<AttendanceModel> get copyWith =>
      _$AttendanceModelCopyWithImpl<AttendanceModel>(
          this as AttendanceModel, _$identity);

  /// Serializes this AttendanceModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AttendanceModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            (identical(other.checkOut, checkOut) ||
                other.checkOut == checkOut) &&
            (identical(other.isLate, isLate) || other.isLate == isLate) &&
            (identical(other.isAbsent, isAbsent) ||
                other.isAbsent == isAbsent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, employeeId, date, checkIn, checkOut, isLate, isAbsent);

  @override
  String toString() {
    return 'AttendanceModel(id: $id, employeeId: $employeeId, date: $date, checkIn: $checkIn, checkOut: $checkOut, isLate: $isLate, isAbsent: $isAbsent)';
  }
}

/// @nodoc
abstract mixin class $AttendanceModelCopyWith<$Res> {
  factory $AttendanceModelCopyWith(
          AttendanceModel value, $Res Function(AttendanceModel) _then) =
      _$AttendanceModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String employeeId,
      DateTime date,
      String? checkIn,
      String? checkOut,
      bool? isLate,
      bool? isAbsent});
}

/// @nodoc
class _$AttendanceModelCopyWithImpl<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  _$AttendanceModelCopyWithImpl(this._self, this._then);

  final AttendanceModel _self;
  final $Res Function(AttendanceModel) _then;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? date = null,
    Object? checkIn = freezed,
    Object? checkOut = freezed,
    Object? isLate = freezed,
    Object? isAbsent = freezed,
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
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkIn: freezed == checkIn
          ? _self.checkIn
          : checkIn // ignore: cast_nullable_to_non_nullable
              as String?,
      checkOut: freezed == checkOut
          ? _self.checkOut
          : checkOut // ignore: cast_nullable_to_non_nullable
              as String?,
      isLate: freezed == isLate
          ? _self.isLate
          : isLate // ignore: cast_nullable_to_non_nullable
              as bool?,
      isAbsent: freezed == isAbsent
          ? _self.isAbsent
          : isAbsent // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AttendanceModel].
extension AttendanceModelPatterns on AttendanceModel {
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
    TResult Function(_AttendanceModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel() when $default != null:
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
    TResult Function(_AttendanceModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel():
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
    TResult? Function(_AttendanceModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel() when $default != null:
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
    TResult Function(String id, String employeeId, DateTime date,
            String? checkIn, String? checkOut, bool? isLate, bool? isAbsent)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel() when $default != null:
        return $default(_that.id, _that.employeeId, _that.date, _that.checkIn,
            _that.checkOut, _that.isLate, _that.isAbsent);
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
    TResult Function(String id, String employeeId, DateTime date,
            String? checkIn, String? checkOut, bool? isLate, bool? isAbsent)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel():
        return $default(_that.id, _that.employeeId, _that.date, _that.checkIn,
            _that.checkOut, _that.isLate, _that.isAbsent);
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
    TResult? Function(String id, String employeeId, DateTime date,
            String? checkIn, String? checkOut, bool? isLate, bool? isAbsent)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel() when $default != null:
        return $default(_that.id, _that.employeeId, _that.date, _that.checkIn,
            _that.checkOut, _that.isLate, _that.isAbsent);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AttendanceModel implements AttendanceModel {
  const _AttendanceModel(
      {required this.id,
      required this.employeeId,
      required this.date,
      this.checkIn,
      this.checkOut,
      this.isLate,
      this.isAbsent});
  factory _AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  @override
  final String id;
  @override
  final String employeeId;
  @override
  final DateTime date;
  @override
  final String? checkIn;
  @override
  final String? checkOut;
  @override
  final bool? isLate;
  @override
  final bool? isAbsent;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AttendanceModelCopyWith<_AttendanceModel> get copyWith =>
      __$AttendanceModelCopyWithImpl<_AttendanceModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AttendanceModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AttendanceModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            (identical(other.checkOut, checkOut) ||
                other.checkOut == checkOut) &&
            (identical(other.isLate, isLate) || other.isLate == isLate) &&
            (identical(other.isAbsent, isAbsent) ||
                other.isAbsent == isAbsent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, employeeId, date, checkIn, checkOut, isLate, isAbsent);

  @override
  String toString() {
    return 'AttendanceModel(id: $id, employeeId: $employeeId, date: $date, checkIn: $checkIn, checkOut: $checkOut, isLate: $isLate, isAbsent: $isAbsent)';
  }
}

/// @nodoc
abstract mixin class _$AttendanceModelCopyWith<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  factory _$AttendanceModelCopyWith(
          _AttendanceModel value, $Res Function(_AttendanceModel) _then) =
      __$AttendanceModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String employeeId,
      DateTime date,
      String? checkIn,
      String? checkOut,
      bool? isLate,
      bool? isAbsent});
}

/// @nodoc
class __$AttendanceModelCopyWithImpl<$Res>
    implements _$AttendanceModelCopyWith<$Res> {
  __$AttendanceModelCopyWithImpl(this._self, this._then);

  final _AttendanceModel _self;
  final $Res Function(_AttendanceModel) _then;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? date = null,
    Object? checkIn = freezed,
    Object? checkOut = freezed,
    Object? isLate = freezed,
    Object? isAbsent = freezed,
  }) {
    return _then(_AttendanceModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _self.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkIn: freezed == checkIn
          ? _self.checkIn
          : checkIn // ignore: cast_nullable_to_non_nullable
              as String?,
      checkOut: freezed == checkOut
          ? _self.checkOut
          : checkOut // ignore: cast_nullable_to_non_nullable
              as String?,
      isLate: freezed == isLate
          ? _self.isLate
          : isLate // ignore: cast_nullable_to_non_nullable
              as bool?,
      isAbsent: freezed == isAbsent
          ? _self.isAbsent
          : isAbsent // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

// dart format on
