import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// In-app notification stored in Firestore `/users/{uid}/notifications/{id}`.
@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String title,
    required String message,
    @Default('info') String type,
    @Default(false) bool read,
    String? actionRoute,
    Map<String, dynamic>? actionParams,
    required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

/// Notification type constants.
abstract final class NotificationType {
  static const info = 'info';
  static const success = 'success';
  static const warning = 'warning';
  static const danger = 'danger';
  static const system = 'system';

  static const all = [info, success, warning, danger, system];

  static String label(String type) => switch (type) {
        info => 'Info',
        success => 'Success',
        warning => 'Warning',
        danger => 'Alert',
        system => 'System',
        _ => type,
      };
}
