/// =============================================================================
/// Address Model
/// 
/// Represents a physical US address. Used for taxpayer addresses, employer
/// addresses, and any other location-based information on tax forms.
/// Follows IRS address formatting requirements.
/// =============================================================================

import 'package:tcm_return_pilot/models/tax/enums/tax_enums.dart';

/// Physical address model following IRS specifications
/// 
/// Example usage:
/// ```dart
/// final address = Address(
///   street1: '123 Main Street',
///   city: 'Anytown',
///   state: USState.ca,
///   zipCode: '90210',
/// );
/// print(address.formattedAddress); // 123 Main Street\nAnytown, CA 90210
/// ```
class Address {
  /// Primary street address (required)
  /// Max 35 characters per IRS spec
  final String street1;

  /// Secondary address line (apt, suite, etc.)
  /// Optional, max 35 characters
  final String? street2;

  /// City name (required)
  /// Max 22 characters per IRS spec
  final String city;

  /// State code as USState enum
  final USState state;

  /// 5-digit ZIP code (required)
  final String zipCode;

  /// 4-digit ZIP+4 extension (optional)
  final String? zipPlus4;

  /// Country code (defaults to US)
  final String country;

  const Address({
    required this.street1,
    this.street2,
    required this.city,
    required this.state,
    required this.zipCode,
    this.zipPlus4,
    this.country = 'US',
  });

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Returns full ZIP code with +4 if available
  /// Example: "90210" or "90210-1234"
  String get fullZip => zipPlus4 != null ? '$zipCode-$zipPlus4' : zipCode;

  /// Returns multi-line formatted address for display
  String get formattedAddress {
    final lines = [
      street1,
      if (street2 != null && street2!.isNotEmpty) street2!,
      '$city, ${state.code} $fullZip',
    ];
    return lines.join('\n');
  }

  /// Returns single-line address for compact display
  String get singleLineAddress {
    final parts = [
      street1,
      if (street2 != null && street2!.isNotEmpty) street2!,
      city,
      state.code,
      fullZip,
    ];
    return parts.join(', ');
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Create Address from JSON map (Supabase response)
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street1: json['street_address_1'] as String? ?? '',
      street2: json['street_address_2'] as String?,
      city: json['city'] as String? ?? '',
      state: USState.fromCode(json['state_code'] as String?) ?? USState.al,
      zipCode: json['zip_code'] as String? ?? '',
      zipPlus4: json['zip_plus_4'] as String?,
      country: json['country'] as String? ?? 'US',
    );
  }

  /// Convert to JSON map for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'street_address_1': street1,
      'street_address_2': street2,
      'city': city,
      'state_code': state.code,
      'zip_code': zipCode,
      'zip_plus_4': zipPlus4,
      'country': country,
    };
  }

  /// Convert to IRS XML format
  /// Used when generating e-file XML
  Map<String, dynamic> toXmlMap() {
    return {
      'AddressLine1Txt': street1,
      if (street2 != null && street2!.isNotEmpty) 'AddressLine2Txt': street2,
      'CityNm': city,
      'StateAbbreviationCd': state.code,
      'ZIPCd': zipCode,
    };
  }

  // ---------------------------------------------------------------------------
  // Utility Methods
  // ---------------------------------------------------------------------------

  /// Create a copy with optional parameter overrides
  Address copyWith({
    String? street1,
    String? street2,
    String? city,
    USState? state,
    String? zipCode,
    String? zipPlus4,
    String? country,
  }) {
    return Address(
      street1: street1 ?? this.street1,
      street2: street2 ?? this.street2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      zipPlus4: zipPlus4 ?? this.zipPlus4,
      country: country ?? this.country,
    );
  }

  @override
  String toString() => formattedAddress;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address &&
        other.street1 == street1 &&
        other.street2 == street2 &&
        other.city == city &&
        other.state == state &&
        other.zipCode == zipCode &&
        other.zipPlus4 == zipPlus4 &&
        other.country == country;
  }

  @override
  int get hashCode {
    return Object.hash(
      street1,
      street2,
      city,
      state,
      zipCode,
      zipPlus4,
      country,
    );
  }
}
