import 'package:tcm_return_pilot/utils/enums.dart';

class IdentityVerificationModel {
  final String?  id;
  final String userId;
  final String?  frontIdUrl;
  final String? backIdUrl;
  final String? selfieUrl;
  final IdentityVerificationStatus status;
  final String? reviewedBy;
  final DateTime?  reviewedAt;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  IdentityVerificationModel({
    this.id,
    required this.userId,
    this.frontIdUrl,
    this.backIdUrl,
    this.selfieUrl,
    this.status = IdentityVerificationStatus.notStarted,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    this.submittedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory IdentityVerificationModel.fromJson(Map<String, dynamic> json) {
    return IdentityVerificationModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      frontIdUrl: json['front_id_url'] as String?,
      backIdUrl: json['back_id_url'] as String?,
      selfieUrl:  json['selfie_url'] as String?,
      status: IdentityVerificationStatus.fromString(json['status'] as String? ),
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ?  DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt:  json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'front_id_url': frontIdUrl,
      'back_id_url': backIdUrl,
      'selfie_url': selfieUrl,
      'status': status.value,
      'submitted_at': submittedAt?. toIso8601String(),
    };
  }

  IdentityVerificationModel copyWith({
    String? id,
    String? userId,
    String?  frontIdUrl,
    String?  backIdUrl,
    String?  selfieUrl,
    IdentityVerificationStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IdentityVerificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      frontIdUrl: frontIdUrl ?? this.frontIdUrl,
      backIdUrl: backIdUrl ?? this.backIdUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isComplete =>
      frontIdUrl != null && backIdUrl != null && selfieUrl != null;
}