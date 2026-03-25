/// =============================================================================
/// Dependent Model
/// 
/// Represents a dependent claimed on a tax return. Includes qualifying
/// criteria for various tax credits (CTC, EIC, Child Care Credit).
/// Used for Form 1040 dependents section and Schedule 8812.
/// =============================================================================

import 'package:tcm_return_pilot/models/tax/enums/tax_enums.dart';

/// Dependent information for tax credit calculations
/// 
/// A dependent can qualify for different credits based on:
/// - Age (under 17 for CTC, under 19 or 24 if student for EIC)
/// - Relationship to taxpayer
/// - Months lived with taxpayer
/// - Whether they provided more than half their own support
/// 
/// Example usage:
/// ```dart
/// final dependent = Dependent(
///   returnId: 'uuid-here',
///   firstName: 'Emily',
///   lastName: 'Smith',
///   ssn: '987-65-4321',
///   dateOfBirth: DateTime(2015, 6, 20),
///   relationship: DependentRelationship.daughter,
///   monthsLivedWithTaxpayer: 12,
/// );
/// 
/// // Check credit eligibility
/// if (dependent.qualifiesForChildTaxCredit(2024)) {
///   print('Eligible for up to \$2,000 CTC');
/// }
/// ```
class Dependent {
  /// Unique identifier for this dependent record
  final String? id;

  /// Reference to the parent tax return
  final String returnId;

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
  // Relationship & Residency
  // ---------------------------------------------------------------------------

  /// Relationship to the taxpayer
  final DependentRelationship relationship;

  /// Number of months lived with taxpayer during tax year (0-12)
  final int monthsLivedWithTaxpayer;

  // ---------------------------------------------------------------------------
  // Credit Eligibility Flags
  // ---------------------------------------------------------------------------

  /// Qualifies for Child Tax Credit (under 17 at end of year)
  final bool qualifiesForCtc;

  /// Qualifies for Earned Income Credit
  final bool qualifiesForEic;

  /// Qualifies for Child & Dependent Care Credit
  final bool qualifiesForChildCare;

  /// Qualifies for Credit for Other Dependents ($500)
  final bool qualifiesForOtherDependent;

  // ---------------------------------------------------------------------------
  // Additional Status
  // ---------------------------------------------------------------------------

  /// Is a full-time student (extends qualifying child age to 24)
  final bool isStudent;

  /// Is permanently and totally disabled
  final bool isDisabled;

  /// Dependent's gross income (if any)
  /// Used for qualifying relative test
  final double? grossIncome;

  // ---------------------------------------------------------------------------
  // Metadata
  // ---------------------------------------------------------------------------

  /// When this record was created
  final DateTime? createdAt;

  /// When this record was last updated
  final DateTime? updatedAt;

  const Dependent({
    this.id,
    required this.returnId,
    required this.firstName,
    this.middleInitial,
    required this.lastName,
    this.suffix,
    required this.ssn,
    required this.dateOfBirth,
    required this.relationship,
    required this.monthsLivedWithTaxpayer,
    this.qualifiesForCtc = false,
    this.qualifiesForEic = false,
    this.qualifiesForChildCare = false,
    this.qualifiesForOtherDependent = false,
    this.isStudent = false,
    this.isDisabled = false,
    this.grossIncome,
    this.createdAt,
    this.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Full name for display
  String get fullName {
    final parts = [
      firstName,
      if (middleInitial != null && middleInitial!.isNotEmpty) middleInitial,
      lastName,
      if (suffix != null) suffix!.displayName,
    ];
    return parts.join(' ');
  }

  /// Masked SSN for display (XXX-XX-1234)
  String get maskedSsn {
    final cleanSsn = ssn.replaceAll('-', '');
    if (cleanSsn.length != 9) return '***-**-****';
    return 'XXX-XX-${cleanSsn.substring(5)}';
  }

  /// Current age
  int get currentAge {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // ---------------------------------------------------------------------------
  // Credit Eligibility Methods
  // ---------------------------------------------------------------------------

  /// Calculate age at end of tax year
  int ageAtEndOfYear(int taxYear) {
    return taxYear - dateOfBirth.year;
  }

  /// Check if dependent qualifies for Child Tax Credit
  /// Requirements:
  /// - Under age 17 at end of tax year
  /// - Lived with taxpayer for more than half the year
  /// - Valid SSN
  /// - Qualifying child relationship
  bool qualifiesForChildTaxCredit(int taxYear) {
    final age = ageAtEndOfYear(taxYear);
    return age < 17 &&
        monthsLivedWithTaxpayer >= 6 &&
        relationship.isQualifyingChildRelationship &&
        ssn.replaceAll('-', '').length == 9;
  }

  /// Check if dependent qualifies for Earned Income Credit
  /// Requirements vary by age and student/disability status
  bool qualifiesForEarnedIncomeCredit(int taxYear) {
    final age = ageAtEndOfYear(taxYear);

    // Must be under 19, or under 24 if full-time student
    // No age limit if permanently disabled
    if (isDisabled) return true;
    if (isStudent && age < 24) return true;
    if (age < 19) return true;

    return false;
  }

  /// Check if dependent qualifies for Child & Dependent Care Credit
  /// Requirements:
  /// - Under age 13, OR
  /// - Physically/mentally incapable of self-care
  bool qualifiesForDependentCareCredit(int taxYear) {
    final age = ageAtEndOfYear(taxYear);
    return age < 13 || isDisabled;
  }

  /// Check if dependent qualifies as "Other Dependent" ($500 credit)
  /// For dependents who don't qualify for CTC but meet dependency tests
  bool qualifiesAsOtherDependent(int taxYear) {
    // Typically for older children, qualifying relatives, or
    // children without valid SSN
    final age = ageAtEndOfYear(taxYear);

    // Age 17 or older, or doesn't meet CTC requirements
    if (age >= 17 && relationship.isQualifyingChildRelationship) {
      return true;
    }

    // Qualifying relative (parent, etc.)
    if (!relationship.isQualifyingChildRelationship) {
      return true;
    }

    return false;
  }

  /// Get maximum CTC amount for this dependent
  /// $2,000 for qualifying children under 17
  double getChildTaxCreditAmount(int taxYear) {
    if (qualifiesForChildTaxCredit(taxYear)) {
      return 2000.0; // 2024 amount
    }
    return 0.0;
  }

  /// Get credit for other dependents amount
  /// $500 for dependents who don't qualify for CTC
  double getOtherDependentCreditAmount(int taxYear) {
    if (!qualifiesForChildTaxCredit(taxYear) && qualifiesAsOtherDependent(taxYear)) {
      return 500.0;
    }
    return 0.0;
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Create Dependent from JSON map (Supabase response)
  factory Dependent.fromJson(Map<String, dynamic> json) {
    return Dependent(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      firstName: json['first_name'] as String,
      middleInitial: json['middle_initial'] as String?,
      lastName: json['last_name'] as String,
      suffix: NameSuffix.fromString(json['suffix'] as String?),
      ssn: json['ssn'] as String? ?? '', // Decrypted by service
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      relationship: DependentRelationship.fromString(json['relationship'] as String?),
      monthsLivedWithTaxpayer: json['months_lived_with_taxpayer'] as int? ?? 0,
      qualifiesForCtc: json['qualifies_for_ctc'] as bool? ?? false,
      qualifiesForEic: json['qualifies_for_eic'] as bool? ?? false,
      qualifiesForChildCare: json['qualifies_for_child_care'] as bool? ?? false,
      qualifiesForOtherDependent: json['qualifies_for_other_dependent'] as bool? ?? false,
      isStudent: json['is_student'] as bool? ?? false,
      isDisabled: json['is_disabled'] as bool? ?? false,
      grossIncome: (json['gross_income'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON map for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'first_name': firstName,
      'middle_initial': middleInitial,
      'last_name': lastName,
      'suffix': suffix?.value,
      'ssn': ssn, // Will be encrypted by service
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'relationship': relationship.value,
      'months_lived_with_taxpayer': monthsLivedWithTaxpayer,
      'qualifies_for_ctc': qualifiesForCtc,
      'qualifies_for_eic': qualifiesForEic,
      'qualifies_for_child_care': qualifiesForChildCare,
      'qualifies_for_other_dependent': qualifiesForOtherDependent,
      'is_student': isStudent,
      'is_disabled': isDisabled,
      'gross_income': grossIncome,
    };
  }

  /// Convert to IRS XML format for e-file
  Map<String, dynamic> toXmlMap() {
    return {
      'DependentFirstNm': firstName,
      if (middleInitial != null) 'DependentMiddleInitial': middleInitial,
      'DependentLastNm': lastName,
      if (suffix != null) 'DependentSuffixNm': suffix!.value,
      'DependentSSN': ssn.replaceAll('-', ''),
      'DependentRelationshipCd': _getIrsRelationshipCode(),
      'EligibleForChildTaxCreditInd': qualifiesForCtc ? 'X' : null,
      'EligibleForODCInd': qualifiesForOtherDependent ? 'X' : null,
    };
  }

  /// Get IRS relationship code for XML
  String _getIrsRelationshipCode() {
    // IRS uses specific codes in e-file XML
    switch (relationship) {
      case DependentRelationship.son:
        return 'SON';
      case DependentRelationship.daughter:
        return 'DAUGHTER';
      case DependentRelationship.stepson:
        return 'STEPSON';
      case DependentRelationship.stepdaughter:
        return 'STEPDAUGHTER';
      case DependentRelationship.fosterChild:
        return 'FOSTER CHILD';
      case DependentRelationship.grandchild:
        return 'GRANDCHILD';
      case DependentRelationship.brother:
        return 'BROTHER';
      case DependentRelationship.sister:
        return 'SISTER';
      case DependentRelationship.halfBrother:
        return 'HALF BROTHER';
      case DependentRelationship.halfSister:
        return 'HALF SISTER';
      case DependentRelationship.stepbrother:
        return 'STEPBROTHER';
      case DependentRelationship.stepsister:
        return 'STEPSISTER';
      case DependentRelationship.niece:
        return 'NIECE';
      case DependentRelationship.nephew:
        return 'NEPHEW';
      case DependentRelationship.parent:
        return 'PARENT';
      case DependentRelationship.grandparent:
        return 'GRANDPARENT';
      case DependentRelationship.aunt:
        return 'AUNT';
      case DependentRelationship.uncle:
        return 'UNCLE';
      case DependentRelationship.other:
        return 'OTHER';
    }
  }

  // ---------------------------------------------------------------------------
  // Utility Methods
  // ---------------------------------------------------------------------------

  /// Create a copy with optional parameter overrides
  Dependent copyWith({
    String? id,
    String? returnId,
    String? firstName,
    String? middleInitial,
    String? lastName,
    NameSuffix? suffix,
    String? ssn,
    DateTime? dateOfBirth,
    DependentRelationship? relationship,
    int? monthsLivedWithTaxpayer,
    bool? qualifiesForCtc,
    bool? qualifiesForEic,
    bool? qualifiesForChildCare,
    bool? qualifiesForOtherDependent,
    bool? isStudent,
    bool? isDisabled,
    double? grossIncome,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dependent(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      firstName: firstName ?? this.firstName,
      middleInitial: middleInitial ?? this.middleInitial,
      lastName: lastName ?? this.lastName,
      suffix: suffix ?? this.suffix,
      ssn: ssn ?? this.ssn,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      relationship: relationship ?? this.relationship,
      monthsLivedWithTaxpayer: monthsLivedWithTaxpayer ?? this.monthsLivedWithTaxpayer,
      qualifiesForCtc: qualifiesForCtc ?? this.qualifiesForCtc,
      qualifiesForEic: qualifiesForEic ?? this.qualifiesForEic,
      qualifiesForChildCare: qualifiesForChildCare ?? this.qualifiesForChildCare,
      qualifiesForOtherDependent: qualifiesForOtherDependent ?? this.qualifiesForOtherDependent,
      isStudent: isStudent ?? this.isStudent,
      isDisabled: isDisabled ?? this.isDisabled,
      grossIncome: grossIncome ?? this.grossIncome,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Dependent($fullName, ${relationship.displayName}, age: $currentAge)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dependent && other.id == id && other.returnId == returnId;
  }

  @override
  int get hashCode => Object.hash(id, returnId);
}
