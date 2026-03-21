import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_model.freezed.dart';
part 'alert_model.g.dart';

/// Admin alert stored in Firestore `/admin/alerts/{id}`.
@freezed
class AlertModel with _$AlertModel {
  const factory AlertModel({
    required String id,
    required String title,
    required String message,
    required String severity, // critical, warning, info
    required String category, // security, fraud, system, users
    @Default(false) bool isAcknowledged,
    @Default(false) bool isResolved,
    String? acknowledgedBy,
    String? resolvedBy,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
    required DateTime createdAt,
    Map<String, dynamic>? metadata,
  }) = _AlertModel;

  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);
}

/// Severity constants for display styling.
abstract final class AlertSeverity {
  static const critical = 'critical';
  static const warning = 'warning';
  static const info = 'info';

  static const all = [critical, warning, info];

  static String label(String severity) => switch (severity) {
        critical => 'Critical',
        warning => 'Warning',
        info => 'Info',
        _ => severity,
      };
}

/// Category constants for filtering.
abstract final class AlertCategory {
  static const security = 'security';
  static const fraud = 'fraud';
  static const system = 'system';
  static const users = 'users';

  static const all = [security, fraud, system, users];

  static String label(String category) => switch (category) {
        security => 'Security',
        fraud => 'Fraud',
        system => 'System',
        users => 'Users',
        _ => category,
      };
}
