import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Core user model persisted in Firestore `/users/{uid}`.
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? avatarUrl,
    @Default('user') String role,
    @Default('free') String plan,
    @Default(false) bool mfaEnabled,
    @Default(false) bool biometricEnabled,
    @Default(false) bool onboardingComplete,
    String? pushToken,
    @Default(5) int autoLockMinutes,
    Map<String, bool>? notificationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    @Default(0) int loginCount,
    @Default(false) bool isSuspended,
    String? suspensionReason,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
