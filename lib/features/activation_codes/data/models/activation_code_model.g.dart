// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activation_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivationCodeModel _$ActivationCodeModelFromJson(Map<String, dynamic> json) =>
    _ActivationCodeModel(
      id: json['id'] as String,
      code: json['code'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isUsed: json['is_used'] as bool,
      expiresAt: json['expires_at'] as String,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$ActivationCodeModelToJson(
        _ActivationCodeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'full_name': instance.fullName,
      'email': instance.email,
      'role': instance.role,
      'is_used': instance.isUsed,
      'expires_at': instance.expiresAt,
      'created_at': instance.createdAt,
    };
