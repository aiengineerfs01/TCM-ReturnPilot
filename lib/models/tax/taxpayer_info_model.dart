/// =============================================================================
/// Taxpayer Info Model
/// 
/// Represents personal information for primary taxpayer or spouse.
/// Contains sensitive data (SSN) that must be encrypted before storage.
/// Used for Form 1040 taxpayer identification section.
/// =============================================================================

import 'package:tcm_return_pilot/models/tax/address_model.dart';
import 'package:tcm_return_pilot/models/tax/enums/tax_enums.dart';

/// Personal information for a taxpayer (primary or spouse)
/// 
/// Note: SSN is stored as plain text in this model but MUST be encrypted
/// before saving to the database. The encryption/decryption is handled
/// by the TaxpayerService.
/// 
/// Example usage:
/// ```dart
/// final taxpayer = TaxpayerInfo(
///   returnId: 'uuid-here',
///   taxpayerType: TaxpayerType.primary,
///   firstName: 'John',
///   lastName: 'Smith',
///   ssn: '123-45-6789', // Will be encrypted before storage
///   dateOfBirth: DateTime(1980, 1, 15),
///   address: Address(...),
/// );
/// ```
class TaxpayerInfo {
  /// Unique identifier for this taxpayer record
  final String? id;

  /// Reference to the parent tax return
  final String returnId;

  /// Whether this is primary taxpayer or spouse
  final TaxpayerType taxpayerType;

  // ---------------------------------------------------------------------------
  // Personal Name Information
  // ---------------------------------------------------------------------------

  /// First name (required, max 50 chars)
  final String firstName;

  /// Middle initial (optional, single character)
  final String? middleInitial;

  /// Last name (required, max 50 chars)
  final String lastName;

  /// Name suffix (Jr, Sr, II, III, IV)
  final NameSuffix? suffix;

  // ---------------------------------------------------------------------------
  // Identification
  // ---------------------------------------------------------------------------

  /// Social Security Number (format: XXX-XX-XXXX or XXXXXXXXX)
  /// IMPORTANT: Must be encrypted before database storage
  final String ssn;

  /// Date of birth
  final DateTime dateOfBirth;

  // ---------------------------------------------------------------------------
  // Contact Information
  // ---------------------------------------------------------------------------

  /// Physical address
  final Address address;

  /// Phone number (10 digits, no formatting)
  final String? phone;

  /// Email address
  final String? email;

  /// Occupation (max 50 chars)
  final String? occupation;

  // ---------------------------------------------------------------------------
  // IRS Identity Protection
  // ---------------------------------------------------------------------------

  /// 6-digit Identity Protection PIN if issued by IRS
  /// Some taxpayers receive this after identity theft
  final String? ipPin;

  // ---------------------------------------------------------------------------
  // Prior Year Information (for e-file authentication)
  // ---------------------------------------------------------------------------

  /// Prior year Adjusted Gross Income (from last year's return)
  /// Used for Self-Select PIN authentication method
  final String? priorYearAgi;

  /// Prior year Self-Select PIN
  /// Alternative to AGI for authentication
  final String? priorYearPin;

  // ---------------------------------------------------------------------------
  // Metadata
  // ---------------------------------------------------------------------------

  /// When this record was created
  final DateTime? createdAt;

  /// When this record was last updated
  final DateTime? updatedAt;

  const TaxpayerInfo({
    this.id,
    required this.returnId,
    required this.taxpayerType,
    required this.firstName,
    this.middleInitial,
    required this.lastName,
    this.suffix,
    required this.ssn,
    required this.dateOfBirth,
    required this.address,
    this.phone,
    this.email,
    this.occupation,
    this.ipPin,
    this.priorYearAgi,
    this.priorYearPin,
    this.createdAt,
    this.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Full legal name for tax forms
  /// Example: "John A Smith Jr"
  String get fullName {
    final parts = [
      firstName,
      if (middleInitial != null && middleInitial!.isNotEmpty) middleInitial,
      lastName,
      if (suffix != null) suffix!.displayName,
    ];
    return parts.join(' ');
  }

  /// Name in "Last, First" format for some IRS forms
  String get lastFirstName => '$lastName, $firstName';

  /// Masked SSN for display (XXX-XX-1234)
  String get maskedSsn {
    final cleanSsn = ssn.replaceAll('-', '');
    if (cleanSsn.length != 9) return '***-**-****';
    return 'XXX-XX-${cleanSsn.substring(5)}';
  }

  /// Age based on current date
  int get currentAge {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Age at end of specific tax year
  int ageAtEndOfYear(int taxYear) {
    // Age at end of tax year (December 31)
    int age = taxYear - dateOfBirth.year;
    return age;
  }

  /// Check if taxpayer is 65 or older at end of tax year
  /// (Qualifies for additional standard deduction)
  bool isAge65OrOlder(int taxYear) => ageAtEndOfYear(taxYear) >= 65;

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Create TaxpayerInfo from JSON map (Supabase response)
  /// Note: SSN comes back decrypted from the service layer
  factory TaxpayerInfo.fromJson(Map<String, dynamic> json) {
    return TaxpayerInfo(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      taxpayerType: TaxpayerType.fromString(json['taxpayer_type'] as String?),
      firstName: json['first_name'] as String,
      middleInitial: json['middle_initial'] as String?,
      lastName: json['last_name'] as String,
      suffix: NameSuffix.fromString(json['suffix'] as String?),
      ssn: json['ssn'] as String? ?? '', // Decrypted by service
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      address: Address.fromJson({
        'street_address_1': json['street_address_1'],
        'street_address_2': json['street_address_2'],
        'city': json['city'],
        'state_code': json['state_code'],
        'zip_code': json['zip_code'],
        'zip_plus_4': json['zip_plus_4'],
      }),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      occupation: json['occupation'] as String?,
      ipPin: json['ip_pin'] as String?, // Decrypted by service
      priorYearAgi: json['prior_year_agi'] as String?, // Decrypted by service
      priorYearPin: json['prior_year_pin'] as String?, // Decrypted by service
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON map for Supabase insert/update
  /// Note: SSN and other sensitive fields will be encrypted by service layer
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'taxpayer_type': taxpayerType.value,
      'first_name': firstName,
      'middle_initial': middleInitial,
      'last_name': lastName,
      'suffix': suffix?.value,
      'ssn': ssn, // Will be encrypted by service
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      // Flatten address fields
      ...address.toJson(),
      'phone': phone,
      'email': email,
      'occupation': occupation,
      'ip_pin': ipPin, // Will be encrypted by service
      'prior_year_agi': priorYearAgi, // Will be encrypted by service
      'prior_year_pin': priorYearPin, // Will be encrypted by service
    };
  }

  /// Convert to IRS XML format for e-file
  Map<String, dynamic> toXmlMap() {
    return {
      'PersonNm': fullName,
      'PersonFirstNm': firstName,
      if (middleInitial != null) 'PersonMiddleInitial': middleInitial,
      'PersonLastNm': lastName,
      if (suffix != null) 'SuffixNm': suffix!.value,
      'SSN': ssn.replaceAll('-', ''), // No dashes for IRS
      'BirthDt': _formatDateForIrs(dateOfBirth),
      'USAddress': address.toXmlMap(),
      if (occupation != null) 'OccupationTxt': occupation,
      if (ipPin != null) 'IdentityProtectionPIN': ipPin,
    };
  }

  /// Format date as YYYY-MM-DD for IRS
  String _formatDateForIrs(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // Utility Methods
  // ---------------------------------------------------------------------------

  /// Create a copy with optional parameter overrides
  TaxpayerInfo copyWith({
    String? id,
    String? returnId,
    TaxpayerType? taxpayerType,
    String? firstName,
    String? middleInitial,
    String? lastName,
    NameSuffix? suffix,
    String? ssn,
    DateTime? dateOfBirth,
    Address? address,
    String? phone,
    String? email,
    String? occupation,
    String? ipPin,
    String? priorYearAgi,
    String? priorYearPin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxpayerInfo(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      taxpayerType: taxpayerType ?? this.taxpayerType,
      firstName: firstName ?? this.firstName,
      middleInitial: middleInitial ?? this.middleInitial,
      lastName: lastName ?? this.lastName,
      suffix: suffix ?? this.suffix,
      ssn: ssn ?? this.ssn,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      occupation: occupation ?? this.occupation,
      ipPin: ipPin ?? this.ipPin,
      priorYearAgi: priorYearAgi ?? this.priorYearAgi,
      priorYearPin: priorYearPin ?? this.priorYearPin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'TaxpayerInfo($fullName, ${taxpayerType.displayName})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxpayerInfo &&
        other.id == id &&
        other.returnId == returnId &&
        other.taxpayerType == taxpayerType;
  }

  @override
  int get hashCode => Object.hash(id, returnId, taxpayerType);
}
