import 'package:tcm_return_pilot/utils/enums.dart';
import 'package:tcm_return_pilot/utils/extensions.dart';

class ProfileModel {
  final String id;
  final String? email;
  final String? displayName;
  final bool? checkedConsent;
  final String? tcmThreadId;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? phone;
  final String? avatarUrl;
  final bool? isProfileCompleted;
  final IdentityVerificationStatus identityVerificationStatus;
  final String createdAt;
  final String? updatedAt;

  ProfileModel({
    required this.id,
    this.email,
    this.displayName,
    this.checkedConsent,
    this.tcmThreadId,
    this.firstName,
    this.lastName,
    this.address,
    this.phone,
    this.avatarUrl,
    this.isProfileCompleted,
    required this.identityVerificationStatus,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      checkedConsent: json['checked_consent'] as bool?,
      tcmThreadId: json['tcm_thread_id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['profile_image'] as String?,
      isProfileCompleted: json['is_profile_completed'] as bool?,
      identityVerificationStatus: IdentityVerificationStatusX.fromString(
        json['identity_verification_status'] as String,
      ),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'checked_consent': checkedConsent,
      'tcm_thread_id': tcmThreadId,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'phone': phone,
      'profile_image': avatarUrl,
      'is_profile_completed': isProfileCompleted,
      'identity_verification_status':
          identityVerificationStatus.value, // ✅ enum → string
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
