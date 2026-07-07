import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/retailer_config.dart';

/// Firestore serialization for [RetailerConfig].
///
/// Maps to/from `retailer_configs/{retailerId}` documents.
class RetailerConfigModel extends RetailerConfig {
  const RetailerConfigModel({
    required super.id,
    required super.name,
    required super.brandColor,
    required super.balanceCheckUrl,
    required super.phase,
    required super.cardNumberLength,
    required super.pinLength,
    required super.pinRequired,
    super.cardNumberSelector,
    super.pinSelector,
    super.submitSelector,
    super.balanceResultSelector,
    super.captchaSelector,
    super.jsAutoFill,
    super.jsExtractBalance,
    super.jsCaptchaDetect,
    super.status,
    super.lastVerified,
    super.updatedAt,
  });

  factory RetailerConfigModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return RetailerConfigModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      brandColor: data['brandColor'] as String? ?? '#8A8694',
      balanceCheckUrl: data['balanceCheckUrl'] as String? ?? '',
      phase: RetailerPhase.fromString(data['phase'] as String? ?? 'redirect'),
      cardNumberLength: data['cardNumberLength'] as int? ?? 16,
      pinLength: data['pinLength'] as int? ?? 4,
      pinRequired: data['pinRequired'] as bool? ?? true,
      cardNumberSelector: data['cardNumberSelector'] as String?,
      pinSelector: data['pinSelector'] as String?,
      submitSelector: data['submitSelector'] as String?,
      balanceResultSelector: data['balanceResultSelector'] as String?,
      captchaSelector: data['captchaSelector'] as String?,
      jsAutoFill: data['jsAutoFill'] as String?,
      jsExtractBalance: data['jsExtractBalance'] as String?,
      jsCaptchaDetect: data['jsCaptchaDetect'] as String?,
      status:
          RetailerStatus.fromString(data['status'] as String? ?? 'active'),
      lastVerified: (data['lastVerified'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'brandColor': brandColor,
        'balanceCheckUrl': balanceCheckUrl,
        'phase': phase.name,
        'cardNumberLength': cardNumberLength,
        'pinLength': pinLength,
        'pinRequired': pinRequired,
        if (cardNumberSelector != null) 'cardNumberSelector': cardNumberSelector,
        if (pinSelector != null) 'pinSelector': pinSelector,
        if (submitSelector != null) 'submitSelector': submitSelector,
        if (balanceResultSelector != null)
          'balanceResultSelector': balanceResultSelector,
        if (captchaSelector != null) 'captchaSelector': captchaSelector,
        if (jsAutoFill != null) 'jsAutoFill': jsAutoFill,
        if (jsExtractBalance != null) 'jsExtractBalance': jsExtractBalance,
        if (jsCaptchaDetect != null) 'jsCaptchaDetect': jsCaptchaDetect,
        'status': status.name,
        if (lastVerified != null)
          'lastVerified': Timestamp.fromDate(lastVerified!),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
