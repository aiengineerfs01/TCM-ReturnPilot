import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:tcm_return_pilot/utils/enums.dart';

extension FileExtension on String {
  String get fileExt {
    if (!contains('.')) return "";
    return split('.').last.toLowerCase();
  }
}

extension DebugLog on Object {
  void logDebug([String? prefix]) {
    if (kDebugMode) {
      // Only prints in debug mode — never in release mode
      // Adds optional prefix for cleaner logs
      // Example: user.logDebug("USER DATA");
      if (prefix != null) {
        // ignore: avoid_print
        print("$prefix: $this");
      } else {
        // ignore: avoid_print
        print(this);
      }
    }
  }
}

extension ColorAlphaExtension on Color {
  /// Uses withAlpha internally but accepts opacity like withOpacity (0.0–1.0)
  Color withOpacityAlpha(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    final alpha = (opacity * 255).round();
    return withAlpha(alpha);
  }
}

extension IdentityVerificationStatusX on IdentityVerificationStatus {
  String get value {
    switch (this) {
      case IdentityVerificationStatus.notStarted:
        return 'not_started';
      case IdentityVerificationStatus.pending:
        return 'pending';
      case IdentityVerificationStatus.approved:
        return 'approved';
      case IdentityVerificationStatus.rejected:
        return 'rejected';
    }
  }

  static IdentityVerificationStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return IdentityVerificationStatus.pending;
      case 'approved':
        return IdentityVerificationStatus.approved;
      case 'rejected':
        return IdentityVerificationStatus.rejected;
      case 'not_started':
      default:
        return IdentityVerificationStatus.notStarted;
    }
  }
}
