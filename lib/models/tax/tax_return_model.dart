/// =============================================================================
/// Tax Return Model
/// 
/// Master model representing a federal tax return (Form 1040).
/// This is the central entity that contains references to all tax data
/// including income, deductions, credits, and calculated totals.
/// =============================================================================

import 'package:tcm_return_pilot/models/tax/enums/tax_enums.dart';

/// Master tax return model for Form 1040
/// 
/// This model represents the complete state of a tax return including:
/// - Filing status and taxpayer information references
/// - Calculated income totals
/// - Deduction amounts
/// - Credit amounts
/// - Payment/withholding totals
/// - Refund or amount owed
/// 
/// Example usage:
/// ```dart
/// final taxReturn = TaxReturn(
///   userId: 'user-uuid',
///   taxYear: 2024,
///   filingStatus: FilingStatus.single,
/// );
/// 
/// // Check if ready to file
/// if (taxReturn.canBeSubmitted) {
///   await taxService.submitReturn(taxReturn);
/// }
/// ```
class TaxReturn {
  /// Unique identifier for this tax return
  final String? id;

  /// Reference to the user who owns this return
  final String userId;

  /// Tax year this return is for (e.g., 2024)
  final int taxYear;

  /// Filing status selection
  final FilingStatus filingStatus;

  /// Current status in the return workflow
  final ReturnStatus status;

  // ---------------------------------------------------------------------------
  // Calculated Income Totals (Form 1040 Lines)
  // ---------------------------------------------------------------------------

  /// Line 9: Total income before adjustments
  /// Sum of wages, interest, dividends, business income, capital gains, etc.
  final double totalIncome;

  /// Line 11: Adjusted Gross Income (AGI)
  /// Total income minus adjustments (Schedule 1 Part II)
  final double adjustedGrossIncome;

  /// Line 12: Standard or itemized deduction amount
  final double totalDeductions;

  /// Line 15: Taxable income
  /// AGI minus deductions minus QBI deduction
  final double taxableIncome;

  /// Line 16-24: Total tax before credits
  final double totalTax;

  /// Line 32: Total credits
  final double totalCredits;

  /// Line 33: Total payments and withholdings
  final double totalPayments;

  /// Line 34/35: Refund amount (if positive)
  /// Calculated as: Total Payments - (Total Tax - Total Credits)
  final double refundAmount;

  /// Line 37: Amount owed (if totalTax > totalPayments)
  final double amountOwed;

  // ---------------------------------------------------------------------------
  // Metadata
  // ---------------------------------------------------------------------------

  /// When this return was created
  final DateTime createdAt;

  /// When this return was last updated
  final DateTime updatedAt;

  /// When return was submitted to IRS (if applicable)
  final DateTime? submittedAt;

  /// Who prepared this return (for audit purposes)
  final String? preparedBy;

  const TaxReturn({
    this.id,
    required this.userId,
    required this.taxYear,
    required this.filingStatus,
    this.status = ReturnStatus.notStarted,
    this.totalIncome = 0,
    this.adjustedGrossIncome = 0,
    this.totalDeductions = 0,
    this.taxableIncome = 0,
    this.totalTax = 0,
    this.totalCredits = 0,
    this.totalPayments = 0,
    this.refundAmount = 0,
    this.amountOwed = 0,
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
    this.preparedBy,
  });

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Check if return can still be edited
  bool get isEditable => status.isEditable;

  /// Check if return has been submitted
  bool get isSubmitted => status.isSubmitted;

  /// Check if return is complete and ready to file
  bool get isReadyToFile => status == ReturnStatus.readyToFile;

  /// Check if return was accepted by IRS
  bool get isAccepted => status == ReturnStatus.accepted;

  /// Check if return was rejected by IRS
  bool get isRejected => status == ReturnStatus.rejected;

  /// Check if taxpayer is getting a refund
  bool get isGettingRefund => refundAmount > 0;

  /// Check if taxpayer owes money
  bool get owesBalance => amountOwed > 0;

  /// Get standard deduction amount for this filing status and tax year
  double get standardDeductionAmount => filingStatus.standardDeduction2024;

  /// Net result (positive = refund, negative = owed)
  double get netResult => refundAmount - amountOwed;

  /// Summary string for display
  String get summary {
    if (isGettingRefund) {
      return 'Refund: \$${refundAmount.toStringAsFixed(2)}';
    } else if (owesBalance) {
      return 'Owed: \$${amountOwed.toStringAsFixed(2)}';
    }
    return '\$0 due';
  }

  /// Check if all required fields are complete for submission
  /// This is a basic check - actual validation is more comprehensive
  bool get canBeSubmitted {
    return status == ReturnStatus.readyToFile ||
        status == ReturnStatus.readyForReview;
  }

  // ---------------------------------------------------------------------------
  // Validation Helpers
  // ---------------------------------------------------------------------------

  /// Get list of missing required items
  List<String> getMissingRequirements() {
    final missing = <String>[];

    if (totalIncome == 0) {
      missing.add('No income entered');
    }

    // Add more validation checks as needed

    return missing;
  }

  /// Calculate completion percentage (0-100)
  int get completionPercentage {
    int completed = 0;
    int total = 5; // Number of major sections

    if (totalIncome > 0) completed++;
    if (totalDeductions > 0) completed++;
    if (totalPayments > 0) completed++;
    // Additional checks can be added

    return ((completed / total) * 100).round();
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Create TaxReturn from JSON map (Supabase response)
  factory TaxReturn.fromJson(Map<String, dynamic> json) {
    return TaxReturn(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      taxYear: json['tax_year'] as int,
      filingStatus: FilingStatus.fromString(json['filing_status'] as String?),
      status: ReturnStatus.fromString(json['return_status'] as String?),
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0,
      adjustedGrossIncome: (json['adjusted_gross_income'] as num?)?.toDouble() ?? 0,
      totalDeductions: (json['total_deductions'] as num?)?.toDouble() ?? 0,
      taxableIncome: (json['taxable_income'] as num?)?.toDouble() ?? 0,
      totalTax: (json['total_tax'] as num?)?.toDouble() ?? 0,
      totalCredits: (json['total_credits'] as num?)?.toDouble() ?? 0,
      totalPayments: (json['total_payments'] as num?)?.toDouble() ?? 0,
      refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0,
      amountOwed: (json['amount_owed'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      preparedBy: json['prepared_by'] as String?,
    );
  }

  /// Convert to JSON map for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'tax_year': taxYear,
      'filing_status': filingStatus.value,
      'return_status': status.value,
      'total_income': totalIncome,
      'adjusted_gross_income': adjustedGrossIncome,
      'total_deductions': totalDeductions,
      'taxable_income': taxableIncome,
      'total_tax': totalTax,
      'total_credits': totalCredits,
      'total_payments': totalPayments,
      'refund_amount': refundAmount,
      'amount_owed': amountOwed,
      if (submittedAt != null) 'submitted_at': submittedAt!.toIso8601String(),
      'prepared_by': preparedBy,
    };
  }

  /// Convert to IRS XML format header for e-file
  Map<String, dynamic> toXmlHeaderMap() {
    return {
      'TaxYr': taxYear.toString(),
      'FilingStatusCd': _getFilingStatusCode(),
    };
  }

  /// Get IRS filing status code for XML
  String _getFilingStatusCode() {
    switch (filingStatus) {
      case FilingStatus.single:
        return '1';
      case FilingStatus.marriedFilingJointly:
        return '2';
      case FilingStatus.marriedFilingSeparately:
        return '3';
      case FilingStatus.headOfHousehold:
        return '4';
      case FilingStatus.qualifyingWidow:
        return '5';
    }
  }

  // ---------------------------------------------------------------------------
  // Utility Methods
  // ---------------------------------------------------------------------------

  /// Create a copy with optional parameter overrides
  TaxReturn copyWith({
    String? id,
    String? userId,
    int? taxYear,
    FilingStatus? filingStatus,
    ReturnStatus? status,
    double? totalIncome,
    double? adjustedGrossIncome,
    double? totalDeductions,
    double? taxableIncome,
    double? totalTax,
    double? totalCredits,
    double? totalPayments,
    double? refundAmount,
    double? amountOwed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
    String? preparedBy,
  }) {
    return TaxReturn(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taxYear: taxYear ?? this.taxYear,
      filingStatus: filingStatus ?? this.filingStatus,
      status: status ?? this.status,
      totalIncome: totalIncome ?? this.totalIncome,
      adjustedGrossIncome: adjustedGrossIncome ?? this.adjustedGrossIncome,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      taxableIncome: taxableIncome ?? this.taxableIncome,
      totalTax: totalTax ?? this.totalTax,
      totalCredits: totalCredits ?? this.totalCredits,
      totalPayments: totalPayments ?? this.totalPayments,
      refundAmount: refundAmount ?? this.refundAmount,
      amountOwed: amountOwed ?? this.amountOwed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      preparedBy: preparedBy ?? this.preparedBy,
    );
  }

  /// Create a new return for the current tax year
  factory TaxReturn.newReturn({
    required String userId,
    int? taxYear,
    FilingStatus filingStatus = FilingStatus.single,
  }) {
    final now = DateTime.now();
    return TaxReturn(
      userId: userId,
      taxYear: taxYear ?? now.year - 1, // Default to prior year
      filingStatus: filingStatus,
      status: ReturnStatus.notStarted,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() =>
      'TaxReturn($taxYear, ${filingStatus.displayName}, ${status.displayName})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxReturn &&
        other.id == id &&
        other.userId == userId &&
        other.taxYear == taxYear;
  }

  @override
  int get hashCode => Object.hash(id, userId, taxYear);
}
