class ProfileModel {
  final String id;
  final String email;
  final String? displayName;
  final bool? checkedConsent;
  final String? avatarUrl;
  final String createdAt;

  ProfileModel({
    required this.id,
    required this.email,
    this.displayName,
    this.checkedConsent,
    this.avatarUrl,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      email: json['email'],
      displayName: json['display_name'],
      checkedConsent: json['checked_consent'],
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'checked_consent': checkedConsent,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
    };
  }
}
