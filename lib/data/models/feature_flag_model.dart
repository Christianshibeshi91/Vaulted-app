import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_flag_model.freezed.dart';
part 'feature_flag_model.g.dart';

/// Feature flag stored in Firestore `/admin/featureFlags/{id}`.
@freezed
class FeatureFlagModel with _$FeatureFlagModel {
  const factory FeatureFlagModel({
    required String id,
    required String name,
    required String description,
    @Default(false) bool isEnabled,
    @Default(100) int rolloutPercentage,
    String? enabledBy,
    DateTime? enabledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FeatureFlagModel;

  factory FeatureFlagModel.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagModelFromJson(json);
}
