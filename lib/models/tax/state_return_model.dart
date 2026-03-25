/// =============================================================================
/// State Tax Return Model
/// 
/// Represents a state income tax return linked to a federal return.
/// State returns are filed separately but share data from the federal return.
/// =============================================================================

import 'package:tcm_return_pilot/models/tax/enums/tax_enums.dart';

/// State income tax return
/// 
/// Key Points:
/// - Links to federal return via returnId
/// - Uses USState enum for state identification
/// - Most states start from federal AGI
/// - Some states have no income tax (handled by USState.hasNoIncomeTax)
class StateReturn {
  final String? id;
  final String returnId;

  /// US state (uses enum)
  final USState state;

  /// Return status (draft, ready, filed, etc.)
  final ReturnStatus status;

  /// Residency status for the tax year
  final StateResidencyStatus residencyStatus;

  /// Number of months as resident (for part-year)
  final int? monthsAsResident;

  // ---------------------------------------------------------------------------
  // Income from Federal
  // ---------------------------------------------------------------------------
  
  /// Federal AGI imported to state return
  final double federalAgi;

  // ---------------------------------------------------------------------------
  // State Adjustments
  // ---------------------------------------------------------------------------
  
  /// Additions to federal income (state-specific items)
  final double stateAdditions;

  /// Subtractions from federal income
  final double stateSubtractions;

  /// State-specific adjustments total
  final double stateAdjustments;

  // ---------------------------------------------------------------------------
  // State Tax Calculation
  // ---------------------------------------------------------------------------
  
  /// State taxable income
  final double stateTaxableIncome;

  /// State tax before credits
  final double stateTaxBeforeCredits;

  /// State tax credits
  final double stateTaxCredits;

  /// Net state tax
  final double stateTaxDue;

  // ---------------------------------------------------------------------------
  // State Withholding and Payments
  // ---------------------------------------------------------------------------
  
  /// State tax withheld from W-2s
  final double stateWithheld;

  /// State estimated tax payments
  final double stateEstimatedPayments;

  /// Total state payments
  final double stateTotalPayments;

  // ---------------------------------------------------------------------------
  // State Refund/Balance Due
  // ---------------------------------------------------------------------------
  
  /// Amount of state refund
  final double stateRefund;

  /// Amount owed to state
  final double stateAmountOwed;

  // ---------------------------------------------------------------------------
  // Specific State Considerations
  // ---------------------------------------------------------------------------
  
  /// State-specific data (varies by state)
  final Map<String, dynamic>? stateSpecificData;

  // ---------------------------------------------------------------------------
  // Timestamps
  // ---------------------------------------------------------------------------
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StateReturn({
    this.id,
    required this.returnId,
    required this.state,
    this.status = ReturnStatus.draft,
    this.residencyStatus = StateResidencyStatus.fullYearResident,
    this.monthsAsResident,
    this.federalAgi = 0,
    this.stateAdditions = 0,
    this.stateSubtractions = 0,
    this.stateAdjustments = 0,
    this.stateTaxableIncome = 0,
    this.stateTaxBeforeCredits = 0,
    this.stateTaxCredits = 0,
    this.stateTaxDue = 0,
    this.stateWithheld = 0,
    this.stateEstimatedPayments = 0,
    this.stateTotalPayments = 0,
    this.stateRefund = 0,
    this.stateAmountOwed = 0,
    this.stateSpecificData,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if state has income tax
  bool get hasStateTax => !state.hasNoIncomeTax;

  /// Get state name for display
  String get stateName => state.displayName;

  /// Calculate if getting refund
  bool get isGettingRefund => stateRefund > 0;

  /// Calculate if owes money
  bool get owesMoney => stateAmountOwed > 0;

  /// Calculate state adjusted income
  double get stateAdjustedIncome =>
      federalAgi + stateAdditions - stateSubtractions + stateAdjustments;

  /// Check if return can be submitted
  bool get canBeSubmitted =>
      status == ReturnStatus.readyToFile && hasStateTax;

  /// Create a new state return from federal return
  factory StateReturn.fromFederal({
    required String returnId,
    required USState state,
    required double federalAgi,
    StateResidencyStatus residencyStatus = StateResidencyStatus.fullYearResident,
  }) {
    return StateReturn(
      returnId: returnId,
      state: state,
      federalAgi: federalAgi,
      residencyStatus: residencyStatus,
      status: ReturnStatus.draft,
    );
  }

  factory StateReturn.fromJson(Map<String, dynamic> json) {
    return StateReturn(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      state: USState.fromString(json['state'] as String?),
      status: ReturnStatus.fromString(json['status'] as String?),
      residencyStatus: StateResidencyStatus.fromString(json['residency_status'] as String?),
      monthsAsResident: json['months_as_resident'] as int?,
      federalAgi: (json['federal_agi'] as num?)?.toDouble() ?? 0,
      stateAdditions: (json['state_additions'] as num?)?.toDouble() ?? 0,
      stateSubtractions: (json['state_subtractions'] as num?)?.toDouble() ?? 0,
      stateAdjustments: (json['state_adjustments'] as num?)?.toDouble() ?? 0,
      stateTaxableIncome: (json['state_taxable_income'] as num?)?.toDouble() ?? 0,
      stateTaxBeforeCredits: (json['state_tax_before_credits'] as num?)?.toDouble() ?? 0,
      stateTaxCredits: (json['state_tax_credits'] as num?)?.toDouble() ?? 0,
      stateTaxDue: (json['state_tax_due'] as num?)?.toDouble() ?? 0,
      stateWithheld: (json['state_withheld'] as num?)?.toDouble() ?? 0,
      stateEstimatedPayments: (json['state_estimated_payments'] as num?)?.toDouble() ?? 0,
      stateTotalPayments: (json['state_total_payments'] as num?)?.toDouble() ?? 0,
      stateRefund: (json['state_refund'] as num?)?.toDouble() ?? 0,
      stateAmountOwed: (json['state_amount_owed'] as num?)?.toDouble() ?? 0,
      stateSpecificData: json['state_specific_data'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'state': state.value,
      'status': status.value,
      'residency_status': residencyStatus.value,
      'months_as_resident': monthsAsResident,
      'federal_agi': federalAgi,
      'state_additions': stateAdditions,
      'state_subtractions': stateSubtractions,
      'state_adjustments': stateAdjustments,
      'state_taxable_income': stateTaxableIncome,
      'state_tax_before_credits': stateTaxBeforeCredits,
      'state_tax_credits': stateTaxCredits,
      'state_tax_due': stateTaxDue,
      'state_withheld': stateWithheld,
      'state_estimated_payments': stateEstimatedPayments,
      'state_total_payments': stateTotalPayments,
      'state_refund': stateRefund,
      'state_amount_owed': stateAmountOwed,
      'state_specific_data': stateSpecificData,
    };
  }

  StateReturn copyWith({
    String? id,
    String? returnId,
    USState? state,
    ReturnStatus? status,
    StateResidencyStatus? residencyStatus,
    int? monthsAsResident,
    double? federalAgi,
    double? stateAdditions,
    double? stateSubtractions,
    double? stateAdjustments,
    double? stateTaxableIncome,
    double? stateTaxBeforeCredits,
    double? stateTaxCredits,
    double? stateTaxDue,
    double? stateWithheld,
    double? stateEstimatedPayments,
    double? stateTotalPayments,
    double? stateRefund,
    double? stateAmountOwed,
    Map<String, dynamic>? stateSpecificData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StateReturn(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      state: state ?? this.state,
      status: status ?? this.status,
      residencyStatus: residencyStatus ?? this.residencyStatus,
      monthsAsResident: monthsAsResident ?? this.monthsAsResident,
      federalAgi: federalAgi ?? this.federalAgi,
      stateAdditions: stateAdditions ?? this.stateAdditions,
      stateSubtractions: stateSubtractions ?? this.stateSubtractions,
      stateAdjustments: stateAdjustments ?? this.stateAdjustments,
      stateTaxableIncome: stateTaxableIncome ?? this.stateTaxableIncome,
      stateTaxBeforeCredits: stateTaxBeforeCredits ?? this.stateTaxBeforeCredits,
      stateTaxCredits: stateTaxCredits ?? this.stateTaxCredits,
      stateTaxDue: stateTaxDue ?? this.stateTaxDue,
      stateWithheld: stateWithheld ?? this.stateWithheld,
      stateEstimatedPayments: stateEstimatedPayments ?? this.stateEstimatedPayments,
      stateTotalPayments: stateTotalPayments ?? this.stateTotalPayments,
      stateRefund: stateRefund ?? this.stateRefund,
      stateAmountOwed: stateAmountOwed ?? this.stateAmountOwed,
      stateSpecificData: stateSpecificData ?? this.stateSpecificData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// =============================================================================
// State Residency Status
// =============================================================================

/// Residency status for state tax purposes
enum StateResidencyStatus {
  fullYearResident('full_year_resident', 'Full Year Resident'),
  partYearResident('part_year_resident', 'Part Year Resident'),
  nonResident('non_resident', 'Non-Resident');

  final String value;
  final String displayName;

  const StateResidencyStatus(this.value, this.displayName);

  static StateResidencyStatus fromString(String? value) {
    return StateResidencyStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StateResidencyStatus.fullYearResident,
    );
  }
}
