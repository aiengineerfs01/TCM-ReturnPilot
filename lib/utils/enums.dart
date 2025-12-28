// Add or update this enum
import 'package:tcm_return_pilot/services/supabase_service.dart';

enum IdentityVerificationStatus {
  notStarted('not_started'),
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const IdentityVerificationStatus(this. value);

  static IdentityVerificationStatus fromString(String?  value) {
    return IdentityVerificationStatus.values. firstWhere(
      (e) => e.value == value,
      orElse: () => IdentityVerificationStatus.notStarted,
    );
  }
}

// // Add to SupabaseTable enum
// enum SupabaseTable {
//   profiles,
//   identityVerifications, // Add this
//   // ... other tables
// }

// Extension to get table name
extension SupabaseTableExtension on SupabaseTable {
  String get name {
    switch (this) {
      case SupabaseTable. profiles:
        return 'profiles';
      case SupabaseTable.identity_verifications:
        return 'identity_verifications';
      // ... other cases
      case SupabaseTable.users:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SupabaseTable.chat_thread:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SupabaseTable.chat_messages:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SupabaseTable.chat_media:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}