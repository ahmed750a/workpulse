import 'package:freezed_annotation/freezed_annotation.dart';

part 'activation_code_model.freezed.dart';
part 'activation_code_model.g.dart';

@freezed
abstract class ActivationCodeModel with _$ActivationCodeModel {
  const factory ActivationCodeModel({
    required String id,
    required String code,

    @JsonKey(name: 'full_name')
    required String fullName,

    required String email,
    required String role,

    @JsonKey(name: 'is_used')
    required bool isUsed,

    @JsonKey(name: 'expires_at')
    required String expiresAt,

    @JsonKey(name: 'created_at')
    String? createdAt,
  }) = _ActivationCodeModel;

  factory ActivationCodeModel.fromJson(Map<String, dynamic> json) =>
      _$ActivationCodeModelFromJson(json);
}