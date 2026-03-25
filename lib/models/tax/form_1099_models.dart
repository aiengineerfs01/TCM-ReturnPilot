/// =============================================================================
/// 1099 Form Models
/// 
/// Contains models for various 1099 forms used to report different types
/// of income to the IRS. Each form has specific boxes and requirements.
/// =============================================================================

import 'package:tcm_return_pilot/models/tax/enums/tax_enums.dart';

// =============================================================================
// Form 1099-INT (Interest Income)
// =============================================================================

/// Form 1099-INT reports interest income from banks, brokerages, etc.
/// 
/// Common scenarios:
/// - Bank account interest
/// - CD interest
/// - Treasury bond interest (Box 3)
/// - Tax-exempt municipal bond interest (Box 8)
class Form1099Int {
  final String? id;
  final String returnId;

  // Payer Information
  final String payerName;
  final String payerTin;
  final String? payerStreet;
  final String? payerCity;
  final String? payerState;
  final String? payerZip;

  // Box amounts
  final double box1InterestIncome;           // Taxable interest
  final double box2EarlyWithdrawalPenalty;   // Early withdrawal penalty (deductible)
  final double box3InterestUsBonds;          // Interest on U.S. Savings Bonds
  final double box4FederalWithheld;          // Federal tax withheld
  final double box8TaxExemptInterest;        // Tax-exempt interest
  final double box9PrivateActivityBond;      // Private activity bond AMT interest
  final double box10MarketDiscount;          // Market discount
  final double box11BondPremium;             // Bond premium

  // State information
  final String? stateCode;
  final String? stateId;
  final double? stateTaxWithheld;

  final DateTime? createdAt;

  const Form1099Int({
    this.id,
    required this.returnId,
    required this.payerName,
    required this.payerTin,
    this.payerStreet,
    this.payerCity,
    this.payerState,
    this.payerZip,
    this.box1InterestIncome = 0,
    this.box2EarlyWithdrawalPenalty = 0,
    this.box3InterestUsBonds = 0,
    this.box4FederalWithheld = 0,
    this.box8TaxExemptInterest = 0,
    this.box9PrivateActivityBond = 0,
    this.box10MarketDiscount = 0,
    this.box11BondPremium = 0,
    this.stateCode,
    this.stateId,
    this.stateTaxWithheld,
    this.createdAt,
  });

  /// Total taxable interest (Box 1 + Box 3)
  double get totalTaxableInterest => box1InterestIncome + box3InterestUsBonds;

  /// Summary for display
  String get summary => '$payerName - \$${box1InterestIncome.toStringAsFixed(2)}';

  factory Form1099Int.fromJson(Map<String, dynamic> json) {
    return Form1099Int(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      payerName: json['payer_name'] as String,
      payerTin: json['payer_tin'] as String,
      payerStreet: json['payer_street'] as String?,
      payerCity: json['payer_city'] as String?,
      payerState: json['payer_state'] as String?,
      payerZip: json['payer_zip'] as String?,
      box1InterestIncome: (json['box_1_interest_income'] as num?)?.toDouble() ?? 0,
      box2EarlyWithdrawalPenalty: (json['box_2_early_withdrawal_penalty'] as num?)?.toDouble() ?? 0,
      box3InterestUsBonds: (json['box_3_interest_us_bonds'] as num?)?.toDouble() ?? 0,
      box4FederalWithheld: (json['box_4_federal_withheld'] as num?)?.toDouble() ?? 0,
      box8TaxExemptInterest: (json['box_8_tax_exempt_interest'] as num?)?.toDouble() ?? 0,
      box9PrivateActivityBond: (json['box_9_private_activity_bond'] as num?)?.toDouble() ?? 0,
      box10MarketDiscount: (json['box_10_market_discount'] as num?)?.toDouble() ?? 0,
      box11BondPremium: (json['box_11_bond_premium'] as num?)?.toDouble() ?? 0,
      stateCode: json['state_code'] as String?,
      stateId: json['state_id'] as String?,
      stateTaxWithheld: (json['state_tax_withheld'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'payer_name': payerName,
      'payer_tin': payerTin,
      'payer_street': payerStreet,
      'payer_city': payerCity,
      'payer_state': payerState,
      'payer_zip': payerZip,
      'box_1_interest_income': box1InterestIncome,
      'box_2_early_withdrawal_penalty': box2EarlyWithdrawalPenalty,
      'box_3_interest_us_bonds': box3InterestUsBonds,
      'box_4_federal_withheld': box4FederalWithheld,
      'box_8_tax_exempt_interest': box8TaxExemptInterest,
      'box_9_private_activity_bond': box9PrivateActivityBond,
      'box_10_market_discount': box10MarketDiscount,
      'box_11_bond_premium': box11BondPremium,
      'state_code': stateCode,
      'state_id': stateId,
      'state_tax_withheld': stateTaxWithheld,
    };
  }

  Form1099Int copyWith({
    String? id,
    String? returnId,
    String? payerName,
    String? payerTin,
    String? payerStreet,
    String? payerCity,
    String? payerState,
    String? payerZip,
    double? box1InterestIncome,
    double? box2EarlyWithdrawalPenalty,
    double? box3InterestUsBonds,
    double? box4FederalWithheld,
    double? box8TaxExemptInterest,
    double? box9PrivateActivityBond,
    double? box10MarketDiscount,
    double? box11BondPremium,
    String? stateCode,
    String? stateId,
    double? stateTaxWithheld,
    DateTime? createdAt,
  }) {
    return Form1099Int(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      payerName: payerName ?? this.payerName,
      payerTin: payerTin ?? this.payerTin,
      payerStreet: payerStreet ?? this.payerStreet,
      payerCity: payerCity ?? this.payerCity,
      payerState: payerState ?? this.payerState,
      payerZip: payerZip ?? this.payerZip,
      box1InterestIncome: box1InterestIncome ?? this.box1InterestIncome,
      box2EarlyWithdrawalPenalty: box2EarlyWithdrawalPenalty ?? this.box2EarlyWithdrawalPenalty,
      box3InterestUsBonds: box3InterestUsBonds ?? this.box3InterestUsBonds,
      box4FederalWithheld: box4FederalWithheld ?? this.box4FederalWithheld,
      box8TaxExemptInterest: box8TaxExemptInterest ?? this.box8TaxExemptInterest,
      box9PrivateActivityBond: box9PrivateActivityBond ?? this.box9PrivateActivityBond,
      box10MarketDiscount: box10MarketDiscount ?? this.box10MarketDiscount,
      box11BondPremium: box11BondPremium ?? this.box11BondPremium,
      stateCode: stateCode ?? this.stateCode,
      stateId: stateId ?? this.stateId,
      stateTaxWithheld: stateTaxWithheld ?? this.stateTaxWithheld,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// =============================================================================
// Form 1099-DIV (Dividend Income)
// =============================================================================

/// Form 1099-DIV reports dividend income from stocks, mutual funds, etc.
/// 
/// Key distinction:
/// - Ordinary dividends (Box 1a) - taxed at regular income rates
/// - Qualified dividends (Box 1b) - taxed at lower capital gains rates
class Form1099Div {
  final String? id;
  final String returnId;

  // Payer Information
  final String payerName;
  final String payerTin;

  // Box amounts
  final double box1aOrdinaryDividends;       // Total ordinary dividends
  final double box1bQualifiedDividends;      // Qualified dividends (lower tax rate)
  final double box2aCapitalGains;            // Total capital gain distributions
  final double box2bUnrecap1250Gain;         // Unrecaptured Section 1250 gain
  final double box2cSection1202Gain;         // Section 1202 gain
  final double box2dCollectiblesGain;        // Collectibles (28%) gain
  final double box3NondividendDist;          // Nondividend distributions
  final double box4FederalWithheld;          // Federal income tax withheld
  final double box5Section199a;              // Section 199A dividends
  final double box6InvestmentExpenses;       // Investment expenses
  final double box7ForeignTaxPaid;           // Foreign tax paid
  final String? box8ForeignCountry;          // Foreign country or U.S. possession
  final bool box11FatcaFiling;               // FATCA filing requirement
  final double box12ExemptInterestDividends; // Exempt-interest dividends
  final double box13PrivateActivity;         // Private activity bond interest AMT

  // State information
  final String? stateCode;
  final String? stateId;
  final double? stateTaxWithheld;

  final DateTime? createdAt;

  const Form1099Div({
    this.id,
    required this.returnId,
    required this.payerName,
    required this.payerTin,
    this.box1aOrdinaryDividends = 0,
    this.box1bQualifiedDividends = 0,
    this.box2aCapitalGains = 0,
    this.box2bUnrecap1250Gain = 0,
    this.box2cSection1202Gain = 0,
    this.box2dCollectiblesGain = 0,
    this.box3NondividendDist = 0,
    this.box4FederalWithheld = 0,
    this.box5Section199a = 0,
    this.box6InvestmentExpenses = 0,
    this.box7ForeignTaxPaid = 0,
    this.box8ForeignCountry,
    this.box11FatcaFiling = false,
    this.box12ExemptInterestDividends = 0,
    this.box13PrivateActivity = 0,
    this.stateCode,
    this.stateId,
    this.stateTaxWithheld,
    this.createdAt,
  });

  /// Summary for display
  String get summary => '$payerName - \$${box1aOrdinaryDividends.toStringAsFixed(2)}';

  factory Form1099Div.fromJson(Map<String, dynamic> json) {
    return Form1099Div(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      payerName: json['payer_name'] as String,
      payerTin: json['payer_tin'] as String,
      box1aOrdinaryDividends: (json['box_1a_ordinary_dividends'] as num?)?.toDouble() ?? 0,
      box1bQualifiedDividends: (json['box_1b_qualified_dividends'] as num?)?.toDouble() ?? 0,
      box2aCapitalGains: (json['box_2a_capital_gains'] as num?)?.toDouble() ?? 0,
      box2bUnrecap1250Gain: (json['box_2b_unrecap_1250_gain'] as num?)?.toDouble() ?? 0,
      box2cSection1202Gain: (json['box_2c_section_1202_gain'] as num?)?.toDouble() ?? 0,
      box2dCollectiblesGain: (json['box_2d_collectibles_gain'] as num?)?.toDouble() ?? 0,
      box3NondividendDist: (json['box_3_nondividend_dist'] as num?)?.toDouble() ?? 0,
      box4FederalWithheld: (json['box_4_federal_withheld'] as num?)?.toDouble() ?? 0,
      box5Section199a: (json['box_5_section_199a'] as num?)?.toDouble() ?? 0,
      box6InvestmentExpenses: (json['box_6_investment_expenses'] as num?)?.toDouble() ?? 0,
      box7ForeignTaxPaid: (json['box_7_foreign_tax_paid'] as num?)?.toDouble() ?? 0,
      box8ForeignCountry: json['box_8_foreign_country'] as String?,
      box11FatcaFiling: json['box_11_fatca_filing'] as bool? ?? false,
      box12ExemptInterestDividends: (json['box_12_exempt_interest_dividends'] as num?)?.toDouble() ?? 0,
      box13PrivateActivity: (json['box_13_private_activity'] as num?)?.toDouble() ?? 0,
      stateCode: json['state_code'] as String?,
      stateId: json['state_id'] as String?,
      stateTaxWithheld: (json['state_tax_withheld'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'payer_name': payerName,
      'payer_tin': payerTin,
      'box_1a_ordinary_dividends': box1aOrdinaryDividends,
      'box_1b_qualified_dividends': box1bQualifiedDividends,
      'box_2a_capital_gains': box2aCapitalGains,
      'box_2b_unrecap_1250_gain': box2bUnrecap1250Gain,
      'box_2c_section_1202_gain': box2cSection1202Gain,
      'box_2d_collectibles_gain': box2dCollectiblesGain,
      'box_3_nondividend_dist': box3NondividendDist,
      'box_4_federal_withheld': box4FederalWithheld,
      'box_5_section_199a': box5Section199a,
      'box_6_investment_expenses': box6InvestmentExpenses,
      'box_7_foreign_tax_paid': box7ForeignTaxPaid,
      'box_8_foreign_country': box8ForeignCountry,
      'box_11_fatca_filing': box11FatcaFiling,
      'box_12_exempt_interest_dividends': box12ExemptInterestDividends,
      'box_13_private_activity': box13PrivateActivity,
      'state_code': stateCode,
      'state_id': stateId,
      'state_tax_withheld': stateTaxWithheld,
    };
  }

  Form1099Div copyWith({
    String? id,
    String? returnId,
    String? payerName,
    String? payerTin,
    double? box1aOrdinaryDividends,
    double? box1bQualifiedDividends,
    double? box2aCapitalGains,
    double? box2bUnrecap1250Gain,
    double? box2cSection1202Gain,
    double? box2dCollectiblesGain,
    double? box3NondividendDist,
    double? box4FederalWithheld,
    double? box5Section199a,
    double? box6InvestmentExpenses,
    double? box7ForeignTaxPaid,
    String? box8ForeignCountry,
    bool? box11FatcaFiling,
    double? box12ExemptInterestDividends,
    double? box13PrivateActivity,
    String? stateCode,
    String? stateId,
    double? stateTaxWithheld,
    DateTime? createdAt,
  }) {
    return Form1099Div(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      payerName: payerName ?? this.payerName,
      payerTin: payerTin ?? this.payerTin,
      box1aOrdinaryDividends: box1aOrdinaryDividends ?? this.box1aOrdinaryDividends,
      box1bQualifiedDividends: box1bQualifiedDividends ?? this.box1bQualifiedDividends,
      box2aCapitalGains: box2aCapitalGains ?? this.box2aCapitalGains,
      box2bUnrecap1250Gain: box2bUnrecap1250Gain ?? this.box2bUnrecap1250Gain,
      box2cSection1202Gain: box2cSection1202Gain ?? this.box2cSection1202Gain,
      box2dCollectiblesGain: box2dCollectiblesGain ?? this.box2dCollectiblesGain,
      box3NondividendDist: box3NondividendDist ?? this.box3NondividendDist,
      box4FederalWithheld: box4FederalWithheld ?? this.box4FederalWithheld,
      box5Section199a: box5Section199a ?? this.box5Section199a,
      box6InvestmentExpenses: box6InvestmentExpenses ?? this.box6InvestmentExpenses,
      box7ForeignTaxPaid: box7ForeignTaxPaid ?? this.box7ForeignTaxPaid,
      box8ForeignCountry: box8ForeignCountry ?? this.box8ForeignCountry,
      box11FatcaFiling: box11FatcaFiling ?? this.box11FatcaFiling,
      box12ExemptInterestDividends: box12ExemptInterestDividends ?? this.box12ExemptInterestDividends,
      box13PrivateActivity: box13PrivateActivity ?? this.box13PrivateActivity,
      stateCode: stateCode ?? this.stateCode,
      stateId: stateId ?? this.stateId,
      stateTaxWithheld: stateTaxWithheld ?? this.stateTaxWithheld,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// =============================================================================
// Form 1099-R (Retirement Distributions)
// =============================================================================

/// Form 1099-R reports distributions from retirement accounts
/// 
/// Includes: IRAs, 401(k)s, pensions, annuities
/// Important: Distribution code in Box 7 determines tax treatment
class Form1099R {
  final String? id;
  final String returnId;

  // Payer Information
  final String payerName;
  final String payerTin;
  final String? payerStreet;
  final String? payerCity;
  final String? payerState;
  final String? payerZip;

  // Box amounts
  final double box1GrossDistribution;        // Gross distribution amount
  final double box2aTaxableAmount;           // Taxable amount
  final bool box2bTaxableNotDetermined;      // Taxable amount not determined
  final bool box2bTotalDistribution;         // Total distribution indicator
  final double box3CapitalGain;              // Capital gain
  final double box4FederalWithheld;          // Federal tax withheld
  final double box5EmployeeContributions;    // Employee contributions/insurance premiums
  final double box6NetUnrealizedAppreciation; // Net unrealized appreciation
  final String? box7DistributionCode;        // Distribution code(s) - CRITICAL
  final double box8OtherAmount;              // Other amount
  final double? box9aEmployeePercent;        // Your percentage of total distribution
  final double? box9bTotalEmployeeContributions;
  final double box10AmountAllocableIrr;      // Amount allocable to IRR
  final int? box11FirstYearRoth;             // First year of designated Roth
  final double box14StateTaxWithheld;        // State tax withheld
  final String? box15StatePayerNumber;       // State/Payer's state no.
  final double box16StateDistribution;       // State distribution

  // IRA/SEP/SIMPLE indicator
  final bool iraSepSimple;

  final DateTime? createdAt;

  const Form1099R({
    this.id,
    required this.returnId,
    required this.payerName,
    required this.payerTin,
    this.payerStreet,
    this.payerCity,
    this.payerState,
    this.payerZip,
    this.box1GrossDistribution = 0,
    this.box2aTaxableAmount = 0,
    this.box2bTaxableNotDetermined = false,
    this.box2bTotalDistribution = false,
    this.box3CapitalGain = 0,
    this.box4FederalWithheld = 0,
    this.box5EmployeeContributions = 0,
    this.box6NetUnrealizedAppreciation = 0,
    this.box7DistributionCode,
    this.box8OtherAmount = 0,
    this.box9aEmployeePercent,
    this.box9bTotalEmployeeContributions,
    this.box10AmountAllocableIrr = 0,
    this.box11FirstYearRoth,
    this.box14StateTaxWithheld = 0,
    this.box15StatePayerNumber,
    this.box16StateDistribution = 0,
    this.iraSepSimple = false,
    this.createdAt,
  });

  /// Check if this is an early distribution (potential 10% penalty)
  bool get isEarlyDistribution {
    if (box7DistributionCode == null) return false;
    return ['1', 'J', 'S'].contains(box7DistributionCode);
  }

  /// Get distribution code description
  String get distributionDescription {
    final code = DistributionCode.fromCode(box7DistributionCode);
    return code?.description ?? 'Unknown distribution type';
  }

  /// Summary for display
  String get summary => '$payerName - \$${box1GrossDistribution.toStringAsFixed(2)}';

  factory Form1099R.fromJson(Map<String, dynamic> json) {
    return Form1099R(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      payerName: json['payer_name'] as String,
      payerTin: json['payer_tin'] as String,
      payerStreet: json['payer_street'] as String?,
      payerCity: json['payer_city'] as String?,
      payerState: json['payer_state'] as String?,
      payerZip: json['payer_zip'] as String?,
      box1GrossDistribution: (json['box_1_gross_distribution'] as num?)?.toDouble() ?? 0,
      box2aTaxableAmount: (json['box_2a_taxable_amount'] as num?)?.toDouble() ?? 0,
      box2bTaxableNotDetermined: json['box_2b_taxable_not_determined'] as bool? ?? false,
      box2bTotalDistribution: json['box_2b_total_distribution'] as bool? ?? false,
      box3CapitalGain: (json['box_3_capital_gain'] as num?)?.toDouble() ?? 0,
      box4FederalWithheld: (json['box_4_federal_withheld'] as num?)?.toDouble() ?? 0,
      box5EmployeeContributions: (json['box_5_employee_contributions'] as num?)?.toDouble() ?? 0,
      box6NetUnrealizedAppreciation: (json['box_6_net_unrealized_appreciation'] as num?)?.toDouble() ?? 0,
      box7DistributionCode: json['box_7_distribution_code'] as String?,
      box8OtherAmount: (json['box_8_other_amount'] as num?)?.toDouble() ?? 0,
      box9aEmployeePercent: (json['box_9a_employee_percent'] as num?)?.toDouble(),
      box9bTotalEmployeeContributions: (json['box_9b_total_employee_contributions'] as num?)?.toDouble(),
      box10AmountAllocableIrr: (json['box_10_amount_allocable_irr'] as num?)?.toDouble() ?? 0,
      box11FirstYearRoth: json['box_11_first_year_roth'] as int?,
      box14StateTaxWithheld: (json['box_14_state_tax_withheld'] as num?)?.toDouble() ?? 0,
      box15StatePayerNumber: json['box_15_state_payer_number'] as String?,
      box16StateDistribution: (json['box_16_state_distribution'] as num?)?.toDouble() ?? 0,
      iraSepSimple: json['ira_sep_simple'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'payer_name': payerName,
      'payer_tin': payerTin,
      'payer_street': payerStreet,
      'payer_city': payerCity,
      'payer_state': payerState,
      'payer_zip': payerZip,
      'box_1_gross_distribution': box1GrossDistribution,
      'box_2a_taxable_amount': box2aTaxableAmount,
      'box_2b_taxable_not_determined': box2bTaxableNotDetermined,
      'box_2b_total_distribution': box2bTotalDistribution,
      'box_3_capital_gain': box3CapitalGain,
      'box_4_federal_withheld': box4FederalWithheld,
      'box_5_employee_contributions': box5EmployeeContributions,
      'box_6_net_unrealized_appreciation': box6NetUnrealizedAppreciation,
      'box_7_distribution_code': box7DistributionCode,
      'box_8_other_amount': box8OtherAmount,
      'box_9a_employee_percent': box9aEmployeePercent,
      'box_9b_total_employee_contributions': box9bTotalEmployeeContributions,
      'box_10_amount_allocable_irr': box10AmountAllocableIrr,
      'box_11_first_year_roth': box11FirstYearRoth,
      'box_14_state_tax_withheld': box14StateTaxWithheld,
      'box_15_state_payer_number': box15StatePayerNumber,
      'box_16_state_distribution': box16StateDistribution,
      'ira_sep_simple': iraSepSimple,
    };
  }

  Form1099R copyWith({
    String? id,
    String? returnId,
    String? payerName,
    String? payerTin,
    String? payerStreet,
    String? payerCity,
    String? payerState,
    String? payerZip,
    double? box1GrossDistribution,
    double? box2aTaxableAmount,
    bool? box2bTaxableNotDetermined,
    bool? box2bTotalDistribution,
    double? box3CapitalGain,
    double? box4FederalWithheld,
    double? box5EmployeeContributions,
    double? box6NetUnrealizedAppreciation,
    String? box7DistributionCode,
    double? box8OtherAmount,
    double? box9aEmployeePercent,
    double? box9bTotalEmployeeContributions,
    double? box10AmountAllocableIrr,
    int? box11FirstYearRoth,
    double? box14StateTaxWithheld,
    String? box15StatePayerNumber,
    double? box16StateDistribution,
    bool? iraSepSimple,
    DateTime? createdAt,
  }) {
    return Form1099R(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      payerName: payerName ?? this.payerName,
      payerTin: payerTin ?? this.payerTin,
      payerStreet: payerStreet ?? this.payerStreet,
      payerCity: payerCity ?? this.payerCity,
      payerState: payerState ?? this.payerState,
      payerZip: payerZip ?? this.payerZip,
      box1GrossDistribution: box1GrossDistribution ?? this.box1GrossDistribution,
      box2aTaxableAmount: box2aTaxableAmount ?? this.box2aTaxableAmount,
      box2bTaxableNotDetermined: box2bTaxableNotDetermined ?? this.box2bTaxableNotDetermined,
      box2bTotalDistribution: box2bTotalDistribution ?? this.box2bTotalDistribution,
      box3CapitalGain: box3CapitalGain ?? this.box3CapitalGain,
      box4FederalWithheld: box4FederalWithheld ?? this.box4FederalWithheld,
      box5EmployeeContributions: box5EmployeeContributions ?? this.box5EmployeeContributions,
      box6NetUnrealizedAppreciation: box6NetUnrealizedAppreciation ?? this.box6NetUnrealizedAppreciation,
      box7DistributionCode: box7DistributionCode ?? this.box7DistributionCode,
      box8OtherAmount: box8OtherAmount ?? this.box8OtherAmount,
      box9aEmployeePercent: box9aEmployeePercent ?? this.box9aEmployeePercent,
      box9bTotalEmployeeContributions: box9bTotalEmployeeContributions ?? this.box9bTotalEmployeeContributions,
      box10AmountAllocableIrr: box10AmountAllocableIrr ?? this.box10AmountAllocableIrr,
      box11FirstYearRoth: box11FirstYearRoth ?? this.box11FirstYearRoth,
      box14StateTaxWithheld: box14StateTaxWithheld ?? this.box14StateTaxWithheld,
      box15StatePayerNumber: box15StatePayerNumber ?? this.box15StatePayerNumber,
      box16StateDistribution: box16StateDistribution ?? this.box16StateDistribution,
      iraSepSimple: iraSepSimple ?? this.iraSepSimple,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// =============================================================================
// Form 1099-NEC (Nonemployee Compensation)
// =============================================================================

/// Form 1099-NEC reports nonemployee compensation (contractor/freelance income)
/// 
/// This income is subject to self-employment tax in addition to regular income tax.
/// Replaced Box 7 of Form 1099-MISC starting in 2020.
class Form1099Nec {
  final String? id;
  final String returnId;

  // Payer Information
  final String payerName;
  final String payerTin;
  final String? payerStreet;
  final String? payerCity;
  final String? payerState;
  final String? payerZip;

  // Box amounts
  final double box1NonemployeeCompensation;  // Nonemployee compensation
  final double box4FederalWithheld;          // Federal income tax withheld

  // State information
  final String? stateCode;
  final String? statePayerNumber;
  final double? stateIncome;
  final double? stateTaxWithheld;

  final DateTime? createdAt;

  const Form1099Nec({
    this.id,
    required this.returnId,
    required this.payerName,
    required this.payerTin,
    this.payerStreet,
    this.payerCity,
    this.payerState,
    this.payerZip,
    this.box1NonemployeeCompensation = 0,
    this.box4FederalWithheld = 0,
    this.stateCode,
    this.statePayerNumber,
    this.stateIncome,
    this.stateTaxWithheld,
    this.createdAt,
  });

  /// Summary for display
  String get summary => '$payerName - \$${box1NonemployeeCompensation.toStringAsFixed(2)}';

  factory Form1099Nec.fromJson(Map<String, dynamic> json) {
    return Form1099Nec(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      payerName: json['payer_name'] as String,
      payerTin: json['payer_tin'] as String,
      payerStreet: json['payer_street'] as String?,
      payerCity: json['payer_city'] as String?,
      payerState: json['payer_state'] as String?,
      payerZip: json['payer_zip'] as String?,
      box1NonemployeeCompensation: (json['box_1_nonemployee_compensation'] as num?)?.toDouble() ?? 0,
      box4FederalWithheld: (json['box_4_federal_withheld'] as num?)?.toDouble() ?? 0,
      stateCode: json['state_code'] as String?,
      statePayerNumber: json['state_payer_number'] as String?,
      stateIncome: (json['state_income'] as num?)?.toDouble(),
      stateTaxWithheld: (json['state_tax_withheld'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'payer_name': payerName,
      'payer_tin': payerTin,
      'payer_street': payerStreet,
      'payer_city': payerCity,
      'payer_state': payerState,
      'payer_zip': payerZip,
      'box_1_nonemployee_compensation': box1NonemployeeCompensation,
      'box_4_federal_withheld': box4FederalWithheld,
      'state_code': stateCode,
      'state_payer_number': statePayerNumber,
      'state_income': stateIncome,
      'state_tax_withheld': stateTaxWithheld,
    };
  }

  Form1099Nec copyWith({
    String? id,
    String? returnId,
    String? payerName,
    String? payerTin,
    String? payerStreet,
    String? payerCity,
    String? payerState,
    String? payerZip,
    double? box1NonemployeeCompensation,
    double? box4FederalWithheld,
    String? stateCode,
    String? statePayerNumber,
    double? stateIncome,
    double? stateTaxWithheld,
    DateTime? createdAt,
  }) {
    return Form1099Nec(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      payerName: payerName ?? this.payerName,
      payerTin: payerTin ?? this.payerTin,
      payerStreet: payerStreet ?? this.payerStreet,
      payerCity: payerCity ?? this.payerCity,
      payerState: payerState ?? this.payerState,
      payerZip: payerZip ?? this.payerZip,
      box1NonemployeeCompensation: box1NonemployeeCompensation ?? this.box1NonemployeeCompensation,
      box4FederalWithheld: box4FederalWithheld ?? this.box4FederalWithheld,
      stateCode: stateCode ?? this.stateCode,
      statePayerNumber: statePayerNumber ?? this.statePayerNumber,
      stateIncome: stateIncome ?? this.stateIncome,
      stateTaxWithheld: stateTaxWithheld ?? this.stateTaxWithheld,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// =============================================================================
// Form 1099-G (Government Payments)
// =============================================================================

/// Form 1099-G reports government payments like unemployment compensation
/// and state/local tax refunds
class Form1099G {
  final String? id;
  final String returnId;

  // Payer Information
  final String payerName;
  final String payerTin;

  // Box amounts
  final double box1Unemployment;             // Unemployment compensation
  final double box2StateLocalRefund;         // State or local income tax refunds
  final String? box3TaxYear;                 // Box 2 amount is for tax year
  final double box4FederalWithheld;          // Federal income tax withheld
  final double box5RtaaPayments;             // RTAA payments
  final double box6TaxableGrants;            // Taxable grants
  final double box7AgriculturePayments;      // Agriculture payments
  final double box9MarketGain;               // Market gain
  final double box10aStateTaxWithheld;       // State tax withheld
  final double box10bStateTaxWithheld;       // State tax withheld (2nd state)
  final String? box11State;                  // State

  final DateTime? createdAt;

  const Form1099G({
    this.id,
    required this.returnId,
    required this.payerName,
    required this.payerTin,
    this.box1Unemployment = 0,
    this.box2StateLocalRefund = 0,
    this.box3TaxYear,
    this.box4FederalWithheld = 0,
    this.box5RtaaPayments = 0,
    this.box6TaxableGrants = 0,
    this.box7AgriculturePayments = 0,
    this.box9MarketGain = 0,
    this.box10aStateTaxWithheld = 0,
    this.box10bStateTaxWithheld = 0,
    this.box11State,
    this.createdAt,
  });

  /// Summary for display
  String get summary {
    if (box1Unemployment > 0) {
      return '$payerName - Unemployment \$${box1Unemployment.toStringAsFixed(2)}';
    }
    return '$payerName - Tax Refund \$${box2StateLocalRefund.toStringAsFixed(2)}';
  }

  factory Form1099G.fromJson(Map<String, dynamic> json) {
    return Form1099G(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      payerName: json['payer_name'] as String,
      payerTin: json['payer_tin'] as String,
      box1Unemployment: (json['box_1_unemployment'] as num?)?.toDouble() ?? 0,
      box2StateLocalRefund: (json['box_2_state_local_refund'] as num?)?.toDouble() ?? 0,
      box3TaxYear: json['box_3_tax_year'] as String?,
      box4FederalWithheld: (json['box_4_federal_withheld'] as num?)?.toDouble() ?? 0,
      box5RtaaPayments: (json['box_5_rtaa_payments'] as num?)?.toDouble() ?? 0,
      box6TaxableGrants: (json['box_6_taxable_grants'] as num?)?.toDouble() ?? 0,
      box7AgriculturePayments: (json['box_7_agriculture_payments'] as num?)?.toDouble() ?? 0,
      box9MarketGain: (json['box_9_market_gain'] as num?)?.toDouble() ?? 0,
      box10aStateTaxWithheld: (json['box_10a_state_tax_withheld'] as num?)?.toDouble() ?? 0,
      box10bStateTaxWithheld: (json['box_10b_state_tax_withheld'] as num?)?.toDouble() ?? 0,
      box11State: json['box_11_state'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'payer_name': payerName,
      'payer_tin': payerTin,
      'box_1_unemployment': box1Unemployment,
      'box_2_state_local_refund': box2StateLocalRefund,
      'box_3_tax_year': box3TaxYear,
      'box_4_federal_withheld': box4FederalWithheld,
      'box_5_rtaa_payments': box5RtaaPayments,
      'box_6_taxable_grants': box6TaxableGrants,
      'box_7_agriculture_payments': box7AgriculturePayments,
      'box_9_market_gain': box9MarketGain,
      'box_10a_state_tax_withheld': box10aStateTaxWithheld,
      'box_10b_state_tax_withheld': box10bStateTaxWithheld,
      'box_11_state': box11State,
    };
  }

  Form1099G copyWith({
    String? id,
    String? returnId,
    String? payerName,
    String? payerTin,
    double? box1Unemployment,
    double? box2StateLocalRefund,
    String? box3TaxYear,
    double? box4FederalWithheld,
    double? box5RtaaPayments,
    double? box6TaxableGrants,
    double? box7AgriculturePayments,
    double? box9MarketGain,
    double? box10aStateTaxWithheld,
    double? box10bStateTaxWithheld,
    String? box11State,
    DateTime? createdAt,
  }) {
    return Form1099G(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      payerName: payerName ?? this.payerName,
      payerTin: payerTin ?? this.payerTin,
      box1Unemployment: box1Unemployment ?? this.box1Unemployment,
      box2StateLocalRefund: box2StateLocalRefund ?? this.box2StateLocalRefund,
      box3TaxYear: box3TaxYear ?? this.box3TaxYear,
      box4FederalWithheld: box4FederalWithheld ?? this.box4FederalWithheld,
      box5RtaaPayments: box5RtaaPayments ?? this.box5RtaaPayments,
      box6TaxableGrants: box6TaxableGrants ?? this.box6TaxableGrants,
      box7AgriculturePayments: box7AgriculturePayments ?? this.box7AgriculturePayments,
      box9MarketGain: box9MarketGain ?? this.box9MarketGain,
      box10aStateTaxWithheld: box10aStateTaxWithheld ?? this.box10aStateTaxWithheld,
      box10bStateTaxWithheld: box10bStateTaxWithheld ?? this.box10bStateTaxWithheld,
      box11State: box11State ?? this.box11State,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// =============================================================================
// Form SSA-1099 (Social Security Benefits)
// =============================================================================

/// Form SSA-1099 reports Social Security benefits received
/// 
/// Note: Social Security may be partially taxable depending on:
/// - Filing status
/// - Combined income (AGI + nontaxable interest + 50% of SS benefits)
class FormSsa1099 {
  final String? id;
  final String returnId;

  /// Beneficiary type (primary taxpayer or spouse)
  final TaxpayerType beneficiaryType;

  // Box amounts
  final double box3BenefitsPaid;             // Total benefits paid
  final double box4BenefitsRepaid;           // Benefits repaid to SSA
  final double box5NetBenefits;              // Net benefits (Box 3 - Box 4)
  final double box6VoluntaryWithheld;        // Voluntary federal income tax withheld

  // Calculated taxable amount (depends on AGI)
  final double taxableAmount;

  final DateTime? createdAt;

  const FormSsa1099({
    this.id,
    required this.returnId,
    required this.beneficiaryType,
    this.box3BenefitsPaid = 0,
    this.box4BenefitsRepaid = 0,
    this.box5NetBenefits = 0,
    this.box6VoluntaryWithheld = 0,
    this.taxableAmount = 0,
    this.createdAt,
  });

  /// Summary for display
  String get summary => 'Social Security - \$${box5NetBenefits.toStringAsFixed(2)}';

  factory FormSsa1099.fromJson(Map<String, dynamic> json) {
    return FormSsa1099(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      beneficiaryType: TaxpayerType.fromString(json['beneficiary_type'] as String?),
      box3BenefitsPaid: (json['box_3_benefits_paid'] as num?)?.toDouble() ?? 0,
      box4BenefitsRepaid: (json['box_4_benefits_repaid'] as num?)?.toDouble() ?? 0,
      box5NetBenefits: (json['box_5_net_benefits'] as num?)?.toDouble() ?? 0,
      box6VoluntaryWithheld: (json['box_6_voluntary_withheld'] as num?)?.toDouble() ?? 0,
      taxableAmount: (json['taxable_amount'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'return_id': returnId,
      'beneficiary_type': beneficiaryType.value,
      'box_3_benefits_paid': box3BenefitsPaid,
      'box_4_benefits_repaid': box4BenefitsRepaid,
      'box_5_net_benefits': box5NetBenefits,
      'box_6_voluntary_withheld': box6VoluntaryWithheld,
      'taxable_amount': taxableAmount,
    };
  }

  FormSsa1099 copyWith({
    String? id,
    String? returnId,
    TaxpayerType? beneficiaryType,
    double? box3BenefitsPaid,
    double? box4BenefitsRepaid,
    double? box5NetBenefits,
    double? box6VoluntaryWithheld,
    double? taxableAmount,
    DateTime? createdAt,
  }) {
    return FormSsa1099(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      beneficiaryType: beneficiaryType ?? this.beneficiaryType,
      box3BenefitsPaid: box3BenefitsPaid ?? this.box3BenefitsPaid,
      box4BenefitsRepaid: box4BenefitsRepaid ?? this.box4BenefitsRepaid,
      box5NetBenefits: box5NetBenefits ?? this.box5NetBenefits,
      box6VoluntaryWithheld: box6VoluntaryWithheld ?? this.box6VoluntaryWithheld,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
