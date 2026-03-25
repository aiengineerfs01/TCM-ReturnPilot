/// =============================================================================
/// W-2 Form Model
/// 
/// Represents IRS Form W-2 (Wage and Tax Statement).
/// Contains all 20+ boxes of W-2 data including wages, withholdings,
/// and employer information. Supports both federal and state data.
/// =============================================================================

import 'package:tcm_return_pilot/models/tax/address_model.dart';
import 'package:tcm_return_pilot/models/tax/enums/tax_enums.dart';

/// W-2 Form model following IRS specifications
/// 
/// The W-2 reports:
/// - Wages and other compensation (Box 1)
/// - Federal income tax withheld (Box 2)
/// - Social Security wages and tax (Boxes 3-4)
/// - Medicare wages and tax (Boxes 5-6)
/// - Various deductions and benefits (Box 12 codes)
/// - State and local information (Boxes 15-20)
/// 
/// Example usage:
/// ```dart
/// final w2 = W2Form(
///   returnId: 'uuid-here',
///   employerEin: '12-3456789',
///   employerName: 'Acme Corporation',
///   employerAddress: Address(...),
///   box1Wages: 75000.00,
///   box2FederalWithheld: 12500.00,
///   box3SsWages: 75000.00,
///   box4SsTax: 4650.00,
///   box5MedicareWages: 75000.00,
///   box6MedicareTax: 1087.50,
/// );
/// ```
class W2Form {
  /// Unique identifier for this W-2 record
  final String? id;

  /// Reference to the parent tax return
  final String returnId;

  // ---------------------------------------------------------------------------
  // Employer Information (Upper section of W-2)
  // ---------------------------------------------------------------------------

  /// Employer Identification Number (Box b)
  /// Format: XX-XXXXXXX
  final String employerEin;

  /// Employer name (Box c)
  final String employerName;

  /// Employer address (Box c)
  final Address employerAddress;

  /// Control number (Box d) - Optional
  /// Employer-assigned number for internal tracking
  final String? controlNumber;

  // ---------------------------------------------------------------------------
  // Core Wage and Tax Information (Boxes 1-6)
  // ---------------------------------------------------------------------------

  /// Box 1: Wages, tips, other compensation
  /// Taxable wages reported to IRS
  final double box1Wages;

  /// Box 2: Federal income tax withheld
  /// Amount withheld for federal taxes
  final double box2FederalWithheld;

  /// Box 3: Social Security wages
  /// Wages subject to Social Security tax (max $168,600 for 2024)
  final double box3SsWages;

  /// Box 4: Social Security tax withheld
  /// 6.2% of SS wages
  final double box4SsTax;

  /// Box 5: Medicare wages and tips
  /// Wages subject to Medicare tax (no cap)
  final double box5MedicareWages;

  /// Box 6: Medicare tax withheld
  /// 1.45% of Medicare wages (+0.9% over $200k)
  final double box6MedicareTax;

  // ---------------------------------------------------------------------------
  // Additional Information (Boxes 7-11, 14)
  // ---------------------------------------------------------------------------

  /// Box 7: Social Security tips
  /// Tips reported for Social Security
  final double box7SsTips;

  /// Box 8: Allocated tips
  /// Tips allocated by employer (not in Box 1)
  final double box8AllocatedTips;

  /// Box 10: Dependent care benefits
  /// Dependent care FSA benefits (up to $5,000)
  final double box10DependentCare;

  /// Box 11: Nonqualified plans
  /// Distributions from nonqualified deferred compensation plans
  final double box11NonqualifiedPlans;

  /// Box 14: Other
  /// Various employer-specific items
  final String? box14Other;

  // ---------------------------------------------------------------------------
  // Box 12: Special Items (Retirement, Benefits, etc.)
  // ---------------------------------------------------------------------------

  /// Box 12 entries with codes A through HH
  /// Each entry has a code and amount
  /// Common codes:
  /// - D: 401(k) contributions
  /// - DD: Health insurance cost
  /// - W: HSA contributions
  final List<Box12Entry> box12Entries;

  // ---------------------------------------------------------------------------
  // Box 13: Checkboxes
  // ---------------------------------------------------------------------------

  /// Box 13: Statutory employee
  /// Employee treated as self-employed for certain expenses
  final bool box13StatutoryEmployee;

  /// Box 13: Retirement plan
  /// Indicates employer offers retirement plan (affects IRA deduction)
  final bool box13RetirementPlan;

  /// Box 13: Third-party sick pay
  /// Sick pay from third-party payer
  final bool box13ThirdPartySickPay;

  // ---------------------------------------------------------------------------
  // State and Local Information (Boxes 15-20)
  // ---------------------------------------------------------------------------

  /// Box 15: State code
  final String? stateCode;

  /// Box 15: Employer's state ID number
  final String? stateEmployerId;

  /// Box 16: State wages, tips, etc.
  final double? stateWages;

  /// Box 17: State income tax withheld
  final double? stateTaxWithheld;

  /// Box 18: Local wages, tips, etc.
  final String? localityName;

  /// Box 18: Local wages amount
  final double? localWages;

  /// Box 19: Local income tax withheld
  final double? localTaxWithheld;

  // ---------------------------------------------------------------------------
  // Metadata
  // ---------------------------------------------------------------------------

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const W2Form({
    this.id,
    required this.returnId,
    required this.employerEin,
    required this.employerName,
    required this.employerAddress,
    this.controlNumber,
    required this.box1Wages,
    required this.box2FederalWithheld,
    required this.box3SsWages,
    required this.box4SsTax,
    required this.box5MedicareWages,
    required this.box6MedicareTax,
    this.box7SsTips = 0,
    this.box8AllocatedTips = 0,
    this.box10DependentCare = 0,
    this.box11NonqualifiedPlans = 0,
    this.box12Entries = const [],
    this.box13StatutoryEmployee = false,
    this.box13RetirementPlan = false,
    this.box13ThirdPartySickPay = false,
    this.box14Other,
    this.stateCode,
    this.stateEmployerId,
    this.stateWages,
    this.stateTaxWithheld,
    this.localityName,
    this.localWages,
    this.localTaxWithheld,
    this.createdAt,
    this.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Formatted EIN for display (XX-XXXXXXX)
  String get formattedEin {
    final clean = employerEin.replaceAll('-', '');
    if (clean.length != 9) return employerEin;
    return '${clean.substring(0, 2)}-${clean.substring(2)}';
  }

  /// Total 401(k) contributions from Box 12
  double get total401kContributions {
    return box12Entries
        .where((e) => ['D', 'AA'].contains(e.code.toUpperCase()))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Total HSA contributions from Box 12 (Code W)
  double get totalHsaContributions {
    return box12Entries
        .where((e) => e.code.toUpperCase() == 'W')
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get Box 12 amount by code
  double? getBox12Amount(String code) {
    final entry = box12Entries.firstWhere(
      (e) => e.code.toUpperCase() == code.toUpperCase(),
      orElse: () => Box12Entry(code: code, amount: 0),
    );
    return entry.amount > 0 ? entry.amount : null;
  }

  /// Summary string for display
  String get summary => '$employerName - \$${box1Wages.toStringAsFixed(2)}';

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Create W2Form from JSON map (Supabase response)
  factory W2Form.fromJson(Map<String, dynamic> json) {
    // Parse Box 12 entries from JSONB array
    List<Box12Entry> box12 = [];
    if (json['box_12_entries'] != null) {
      final entries = json['box_12_entries'] as List;
      box12 = entries
          .map((e) => Box12Entry.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return W2Form(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      employerEin: json['employer_ein'] as String,
      employerName: json['employer_name'] as String,
      employerAddress: Address(
        street1: json['employer_street_1'] as String? ?? '',
        street2: json['employer_street_2'] as String?,
        city: json['employer_city'] as String? ?? '',
        state: USState.fromCode(json['employer_state'] as String?) ?? USState.al,
        zipCode: json['employer_zip'] as String? ?? '',
      ),
      controlNumber: json['control_number'] as String?,
      box1Wages: (json['box_1_wages'] as num?)?.toDouble() ?? 0,
      box2FederalWithheld: (json['box_2_federal_withheld'] as num?)?.toDouble() ?? 0,
      box3SsWages: (json['box_3_ss_wages'] as num?)?.toDouble() ?? 0,
      box4SsTax: (json['box_4_ss_tax'] as num?)?.toDouble() ?? 0,
      box5MedicareWages: (json['box_5_medicare_wages'] as num?)?.toDouble() ?? 0,
      box6MedicareTax: (json['box_6_medicare_tax'] as num?)?.toDouble() ?? 0,
      box7SsTips: (json['box_7_ss_tips'] as num?)?.toDouble() ?? 0,
      box8AllocatedTips: (json['box_8_allocated_tips'] as num?)?.toDouble() ?? 0,
      box10DependentCare: (json['box_10_dependent_care'] as num?)?.toDouble() ?? 0,
      box11NonqualifiedPlans: (json['box_11_nonqualified_plans'] as num?)?.toDouble() ?? 0,
      box12Entries: box12,
      box13StatutoryEmployee: json['box_13_statutory_employee'] as bool? ?? false,
      box13RetirementPlan: json['box_13_retirement_plan'] as bool? ?? false,
      box13ThirdPartySickPay: json['box_13_third_party_sick_pay'] as bool? ?? false,
      box14Other: json['box_14_other'] as String?,
      stateCode: json['state_code'] as String?,
      stateEmployerId: json['state_employer_id'] as String?,
      stateWages: (json['state_wages'] as num?)?.toDouble(),
      stateTaxWithheld: (json['state_tax_withheld'] as num?)?.toDouble(),
      localityName: json['locality_name'] as String?,
      localWages: (json['local_wages'] as num?)?.toDouble(),
      localTaxWithheld: (json['local_tax_withheld'] as num?)?.toDouble(),
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
      'employer_ein': employerEin,
      'employer_name': employerName,
      'employer_street_1': employerAddress.street1,
      'employer_street_2': employerAddress.street2,
      'employer_city': employerAddress.city,
      'employer_state': employerAddress.state.code,
      'employer_zip': employerAddress.fullZip,
      'control_number': controlNumber,
      'box_1_wages': box1Wages,
      'box_2_federal_withheld': box2FederalWithheld,
      'box_3_ss_wages': box3SsWages,
      'box_4_ss_tax': box4SsTax,
      'box_5_medicare_wages': box5MedicareWages,
      'box_6_medicare_tax': box6MedicareTax,
      'box_7_ss_tips': box7SsTips,
      'box_8_allocated_tips': box8AllocatedTips,
      'box_10_dependent_care': box10DependentCare,
      'box_11_nonqualified_plans': box11NonqualifiedPlans,
      'box_12_entries': box12Entries.map((e) => e.toJson()).toList(),
      'box_13_statutory_employee': box13StatutoryEmployee,
      'box_13_retirement_plan': box13RetirementPlan,
      'box_13_third_party_sick_pay': box13ThirdPartySickPay,
      'box_14_other': box14Other,
      'state_code': stateCode,
      'state_employer_id': stateEmployerId,
      'state_wages': stateWages,
      'state_tax_withheld': stateTaxWithheld,
      'locality_name': localityName,
      'local_wages': localWages,
      'local_tax_withheld': localTaxWithheld,
    };
  }

  /// Convert to IRS XML format for e-file
  Map<String, dynamic> toXmlMap() {
    return {
      'EmployerEIN': employerEin.replaceAll('-', ''),
      'EmployerNameControlTxt': _getNameControl(employerName),
      'EmployerName': {
        'BusinessNameLine1Txt': employerName,
      },
      'EmployerUSAddress': employerAddress.toXmlMap(),
      if (controlNumber != null) 'ControlNum': controlNumber,
      'WagesAmt': box1Wages.round(),
      'WithholdingAmt': box2FederalWithheld.round(),
      'SocialSecurityWagesAmt': box3SsWages.round(),
      'SocialSecurityTaxAmt': box4SsTax.round(),
      'MedicareWagesAndTipsAmt': box5MedicareWages.round(),
      'MedicareTaxWithheldAmt': box6MedicareTax.round(),
      if (box7SsTips > 0) 'SocialSecurityTipsAmt': box7SsTips.round(),
      if (box8AllocatedTips > 0) 'AllocatedTipsAmt': box8AllocatedTips.round(),
      if (box10DependentCare > 0) 'DependentCareBenefitsAmt': box10DependentCare.round(),
      if (box11NonqualifiedPlans > 0) 'NonqualifiedPlansAmt': box11NonqualifiedPlans.round(),
      if (box12Entries.isNotEmpty)
        'EmployersUseGrp': box12Entries.map((e) => e.toXmlMap()).toList(),
      if (box13StatutoryEmployee) 'StatutoryEmployeeInd': 'X',
      if (box13RetirementPlan) 'RetirementPlanInd': 'X',
      if (box13ThirdPartySickPay) 'ThirdPartySickPayInd': 'X',
    };
  }

  /// Get IRS name control (first 4 chars of business name, uppercase)
  String _getNameControl(String name) {
    final cleaned = name.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    return cleaned.length >= 4 ? cleaned.substring(0, 4) : cleaned;
  }

  // ---------------------------------------------------------------------------
  // Utility Methods
  // ---------------------------------------------------------------------------

  /// Create a copy with optional parameter overrides
  W2Form copyWith({
    String? id,
    String? returnId,
    String? employerEin,
    String? employerName,
    Address? employerAddress,
    String? controlNumber,
    double? box1Wages,
    double? box2FederalWithheld,
    double? box3SsWages,
    double? box4SsTax,
    double? box5MedicareWages,
    double? box6MedicareTax,
    double? box7SsTips,
    double? box8AllocatedTips,
    double? box10DependentCare,
    double? box11NonqualifiedPlans,
    List<Box12Entry>? box12Entries,
    bool? box13StatutoryEmployee,
    bool? box13RetirementPlan,
    bool? box13ThirdPartySickPay,
    String? box14Other,
    String? stateCode,
    String? stateEmployerId,
    double? stateWages,
    double? stateTaxWithheld,
    String? localityName,
    double? localWages,
    double? localTaxWithheld,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return W2Form(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      employerEin: employerEin ?? this.employerEin,
      employerName: employerName ?? this.employerName,
      employerAddress: employerAddress ?? this.employerAddress,
      controlNumber: controlNumber ?? this.controlNumber,
      box1Wages: box1Wages ?? this.box1Wages,
      box2FederalWithheld: box2FederalWithheld ?? this.box2FederalWithheld,
      box3SsWages: box3SsWages ?? this.box3SsWages,
      box4SsTax: box4SsTax ?? this.box4SsTax,
      box5MedicareWages: box5MedicareWages ?? this.box5MedicareWages,
      box6MedicareTax: box6MedicareTax ?? this.box6MedicareTax,
      box7SsTips: box7SsTips ?? this.box7SsTips,
      box8AllocatedTips: box8AllocatedTips ?? this.box8AllocatedTips,
      box10DependentCare: box10DependentCare ?? this.box10DependentCare,
      box11NonqualifiedPlans: box11NonqualifiedPlans ?? this.box11NonqualifiedPlans,
      box12Entries: box12Entries ?? this.box12Entries,
      box13StatutoryEmployee: box13StatutoryEmployee ?? this.box13StatutoryEmployee,
      box13RetirementPlan: box13RetirementPlan ?? this.box13RetirementPlan,
      box13ThirdPartySickPay: box13ThirdPartySickPay ?? this.box13ThirdPartySickPay,
      box14Other: box14Other ?? this.box14Other,
      stateCode: stateCode ?? this.stateCode,
      stateEmployerId: stateEmployerId ?? this.stateEmployerId,
      stateWages: stateWages ?? this.stateWages,
      stateTaxWithheld: stateTaxWithheld ?? this.stateTaxWithheld,
      localityName: localityName ?? this.localityName,
      localWages: localWages ?? this.localWages,
      localTaxWithheld: localTaxWithheld ?? this.localTaxWithheld,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'W2Form($employerName, wages: \$${box1Wages.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is W2Form && other.id == id && other.returnId == returnId;
  }

  @override
  int get hashCode => Object.hash(id, returnId);
}

// =============================================================================
// Box 12 Entry Helper Class
// =============================================================================

/// Represents a single Box 12 entry with code and amount
/// 
/// Common codes include:
/// - D: 401(k) elective deferrals
/// - E: 403(b) elective deferrals
/// - W: HSA employer contributions
/// - DD: Health insurance cost (informational)
/// - AA: Designated Roth contributions to 401(k)
class Box12Entry {
  /// Box 12 code (A through HH)
  final String code;

  /// Amount for this code
  final double amount;

  const Box12Entry({
    required this.code,
    required this.amount,
  });

  /// Get description for this code
  String get description {
    final enumValue = W2Box12Code.fromCode(code);
    return enumValue?.description ?? 'Unknown code';
  }

  /// Create from JSON
  factory Box12Entry.fromJson(Map<String, dynamic> json) {
    return Box12Entry(
      code: json['code'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'amount': amount,
    };
  }

  /// Convert to IRS XML format
  Map<String, dynamic> toXmlMap() {
    return {
      'EmployersUseCd': code.toUpperCase(),
      'EmployersUseAmt': amount.round(),
    };
  }

  @override
  String toString() => 'Box12Entry($code: \$${amount.toStringAsFixed(2)})';
}
