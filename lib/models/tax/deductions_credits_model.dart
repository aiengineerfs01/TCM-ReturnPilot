/// =============================================================================
/// Deductions and Credits Models
/// 
/// Models for tax deductions (Standard/Itemized) and tax credits.
/// These directly affect the tax calculation on Form 1040.
/// =============================================================================

import 'package:tcm_return_pilot/models/tax/enums/tax_enums.dart';

// =============================================================================
// Adjustments to Income (Schedule 1, Part II)
// =============================================================================

/// Above-the-line adjustments that reduce Adjusted Gross Income (AGI)
/// 
/// These deductions are taken BEFORE calculating AGI, making them
/// more valuable than itemized deductions because they:
/// 1. Reduce AGI (affecting credit eligibility thresholds)
/// 2. Available even if taking standard deduction
class AdjustmentsToIncome {
  final String? id;
  final String returnId;

  // Schedule 1 Part II Line Items
  /// Line 11: Educator expenses (up to $300 per educator)
  final double educatorExpenses;

  /// Line 12: Certain business expenses of reservists, artists, etc.
  final double businessExpensesReservists;

  /// Line 13: Health savings account deduction
  final double healthSavingsAccount;

  /// Line 14: Moving expenses for Armed Forces
  final double movingExpensesMilitary;

  /// Line 15: Deductible part of self-employment tax (50%)
  final double selfEmploymentTaxDeduction;

  /// Line 16: Self-employed SEP, SIMPLE, and qualified plans
  final double selfEmployedSepSimple;

  /// Line 17: Self-employed health insurance deduction
  final double selfEmployedHealthInsurance;

  /// Line 18: Penalty on early withdrawal of savings (from 1099-INT Box 2)
  final double earlyWithdrawalPenalty;

  /// Line 19a: Alimony paid (divorces finalized before 2019)
  final double alimonyPaid;

  /// Line 19b: Recipient's SSN (required if alimony paid)
  final String? alimonyRecipientSsn;

  /// Line 20: IRA deduction
  final double traditionalIraDeduction;

  /// Line 21: Student loan interest deduction (up to $2,500)
  final double studentLoanInterest;

  /// Line 22: Reserved for future use (was tuition/fees)
  final double tuitionFeesDeduction;

  /// Line 24: Other adjustments
  final double otherAdjustments;
  final String? otherAdjustmentsDescription;

  /// Line 26: Total adjustments
  final double totalAdjustments;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdjustmentsToIncome({
    this.id,
    required this.returnId,
    this.educatorExpenses = 0,
    this.businessExpensesReservists = 0,
    this.healthSavingsAccount = 0,
    this.movingExpensesMilitary = 0,
    this.selfEmploymentTaxDeduction = 0,
    this.selfEmployedSepSimple = 0,
    this.selfEmployedHealthInsurance = 0,
    this.earlyWithdrawalPenalty = 0,
    this.alimonyPaid = 0,
    this.alimonyRecipientSsn,
    this.traditionalIraDeduction = 0,
    this.studentLoanInterest = 0,
    this.tuitionFeesDeduction = 0,
    this.otherAdjustments = 0,
    this.otherAdjustmentsDescription,
    this.totalAdjustments = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Calculate total adjustments from all line items
  double calculateTotal() {
    return educatorExpenses +
        businessExpensesReservists +
        healthSavingsAccount +
        movingExpensesMilitary +
        selfEmploymentTaxDeduction +
        selfEmployedSepSimple +
        selfEmployedHealthInsurance +
        earlyWithdrawalPenalty +
        alimonyPaid +
        traditionalIraDeduction +
        studentLoanInterest +
        tuitionFeesDeduction +
        otherAdjustments;
  }

  factory AdjustmentsToIncome.fromJson(Map<String, dynamic> json) {
    return AdjustmentsToIncome(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      educatorExpenses: (json['educator_expenses'] as num?)?.toDouble() ?? 0,
      businessExpensesReservists: (json['business_expenses_reservists'] as num?)?.toDouble() ?? 0,
      healthSavingsAccount: (json['health_savings_account'] as num?)?.toDouble() ?? 0,
      movingExpensesMilitary: (json['moving_expenses_military'] as num?)?.toDouble() ?? 0,
      selfEmploymentTaxDeduction: (json['self_employment_tax_deduction'] as num?)?.toDouble() ?? 0,
      selfEmployedSepSimple: (json['self_employed_sep_simple'] as num?)?.toDouble() ?? 0,
      selfEmployedHealthInsurance: (json['self_employed_health_insurance'] as num?)?.toDouble() ?? 0,
      earlyWithdrawalPenalty: (json['early_withdrawal_penalty'] as num?)?.toDouble() ?? 0,
      alimonyPaid: (json['alimony_paid'] as num?)?.toDouble() ?? 0,
      alimonyRecipientSsn: json['alimony_recipient_ssn'] as String?,
      traditionalIraDeduction: (json['traditional_ira_deduction'] as num?)?.toDouble() ?? 0,
      studentLoanInterest: (json['student_loan_interest'] as num?)?.toDouble() ?? 0,
      tuitionFeesDeduction: (json['tuition_fees_deduction'] as num?)?.toDouble() ?? 0,
      otherAdjustments: (json['other_adjustments'] as num?)?.toDouble() ?? 0,
      otherAdjustmentsDescription: json['other_adjustments_description'] as String?,
      totalAdjustments: (json['total_adjustments'] as num?)?.toDouble() ?? 0,
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
      'educator_expenses': educatorExpenses,
      'business_expenses_reservists': businessExpensesReservists,
      'health_savings_account': healthSavingsAccount,
      'moving_expenses_military': movingExpensesMilitary,
      'self_employment_tax_deduction': selfEmploymentTaxDeduction,
      'self_employed_sep_simple': selfEmployedSepSimple,
      'self_employed_health_insurance': selfEmployedHealthInsurance,
      'early_withdrawal_penalty': earlyWithdrawalPenalty,
      'alimony_paid': alimonyPaid,
      'alimony_recipient_ssn': alimonyRecipientSsn,
      'traditional_ira_deduction': traditionalIraDeduction,
      'student_loan_interest': studentLoanInterest,
      'tuition_fees_deduction': tuitionFeesDeduction,
      'other_adjustments': otherAdjustments,
      'other_adjustments_description': otherAdjustmentsDescription,
      'total_adjustments': totalAdjustments,
    };
  }

  AdjustmentsToIncome copyWith({
    String? id,
    String? returnId,
    double? educatorExpenses,
    double? businessExpensesReservists,
    double? healthSavingsAccount,
    double? movingExpensesMilitary,
    double? selfEmploymentTaxDeduction,
    double? selfEmployedSepSimple,
    double? selfEmployedHealthInsurance,
    double? earlyWithdrawalPenalty,
    double? alimonyPaid,
    String? alimonyRecipientSsn,
    double? traditionalIraDeduction,
    double? studentLoanInterest,
    double? tuitionFeesDeduction,
    double? otherAdjustments,
    String? otherAdjustmentsDescription,
    double? totalAdjustments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdjustmentsToIncome(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      educatorExpenses: educatorExpenses ?? this.educatorExpenses,
      businessExpensesReservists: businessExpensesReservists ?? this.businessExpensesReservists,
      healthSavingsAccount: healthSavingsAccount ?? this.healthSavingsAccount,
      movingExpensesMilitary: movingExpensesMilitary ?? this.movingExpensesMilitary,
      selfEmploymentTaxDeduction: selfEmploymentTaxDeduction ?? this.selfEmploymentTaxDeduction,
      selfEmployedSepSimple: selfEmployedSepSimple ?? this.selfEmployedSepSimple,
      selfEmployedHealthInsurance: selfEmployedHealthInsurance ?? this.selfEmployedHealthInsurance,
      earlyWithdrawalPenalty: earlyWithdrawalPenalty ?? this.earlyWithdrawalPenalty,
      alimonyPaid: alimonyPaid ?? this.alimonyPaid,
      alimonyRecipientSsn: alimonyRecipientSsn ?? this.alimonyRecipientSsn,
      traditionalIraDeduction: traditionalIraDeduction ?? this.traditionalIraDeduction,
      studentLoanInterest: studentLoanInterest ?? this.studentLoanInterest,
      tuitionFeesDeduction: tuitionFeesDeduction ?? this.tuitionFeesDeduction,
      otherAdjustments: otherAdjustments ?? this.otherAdjustments,
      otherAdjustmentsDescription: otherAdjustmentsDescription ?? this.otherAdjustmentsDescription,
      totalAdjustments: totalAdjustments ?? this.totalAdjustments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// =============================================================================
// Deductions (Standard or Itemized - Schedule A)
// =============================================================================

/// Tax deductions reduce taxable income
/// 
/// Taxpayer chooses the GREATER of:
/// - Standard deduction (based on filing status)
/// - Itemized deductions (Schedule A)
class Deductions {
  final String? id;
  final String returnId;

  /// Choice: standard or itemized
  final DeductionType deductionType;

  // ---------------------------------------------------------------------------
  // Standard Deduction
  // ---------------------------------------------------------------------------
  
  /// Standard deduction amount (based on filing status and age)
  final double standardDeductionAmount;

  // ---------------------------------------------------------------------------
  // Itemized Deductions (Schedule A)
  // ---------------------------------------------------------------------------
  
  // Medical and Dental Expenses (Lines 1-4)
  /// Total medical expenses
  final double medicalExpensesTotal;
  /// 7.5% of AGI threshold
  final double medicalExpensesThreshold;
  /// Deductible amount (total - threshold)
  final double medicalExpensesDeductible;

  // Taxes Paid (Lines 5-7) - SALT Capped at $10,000
  /// State and local income taxes paid
  final double stateLocalIncomeTax;
  /// State and local sales taxes (alternative to income tax)
  final double stateLocalSalesTax;
  /// Real estate taxes
  final double realEstateTaxes;
  /// Personal property taxes
  final double personalPropertyTaxes;
  /// Total SALT (capped at $10,000 for 2018-2025)
  final double saltTotal;

  // Interest Paid (Lines 8-10)
  /// Home mortgage interest and points (Form 1098)
  final double homeMortgageInterest;
  /// Points paid on home purchase
  final double homeMortgagePoints;
  /// Investment interest expense (limited to investment income)
  final double investmentInterest;

  // Charitable Contributions (Lines 11-14)
  /// Cash contributions (60% AGI limit)
  final double charitableCash;
  /// Non-cash contributions (clothing, etc.)
  final double charitableNoncash;
  /// Carryover from prior year
  final double charitableCarryover;

  // Casualty and Theft Losses (Line 15)
  /// Only federally declared disaster losses
  final double casualtyTheftLosses;

  // Other Itemized Deductions (Line 16)
  final double otherItemized;
  final String? otherItemizedDescription;

  // ---------------------------------------------------------------------------
  // Totals
  // ---------------------------------------------------------------------------
  
  /// Total itemized deductions (Schedule A Line 17)
  final double totalItemizedDeductions;

  /// QBI Deduction (Section 199A) - 20% of qualified business income
  final double qbiDeduction;

  /// Final deduction used (greater of standard or itemized)
  final double totalDeductions;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Deductions({
    this.id,
    required this.returnId,
    required this.deductionType,
    this.standardDeductionAmount = 0,
    this.medicalExpensesTotal = 0,
    this.medicalExpensesThreshold = 0,
    this.medicalExpensesDeductible = 0,
    this.stateLocalIncomeTax = 0,
    this.stateLocalSalesTax = 0,
    this.realEstateTaxes = 0,
    this.personalPropertyTaxes = 0,
    this.saltTotal = 0,
    this.homeMortgageInterest = 0,
    this.homeMortgagePoints = 0,
    this.investmentInterest = 0,
    this.charitableCash = 0,
    this.charitableNoncash = 0,
    this.charitableCarryover = 0,
    this.casualtyTheftLosses = 0,
    this.otherItemized = 0,
    this.otherItemizedDescription,
    this.totalItemizedDeductions = 0,
    this.qbiDeduction = 0,
    this.totalDeductions = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Calculate SALT total with $10,000 cap
  double calculateSaltTotal() {
    final total = stateLocalIncomeTax + 
        stateLocalSalesTax + 
        realEstateTaxes + 
        personalPropertyTaxes;
    return total > 10000 ? 10000 : total; // SALT cap
  }

  /// Calculate total charitable contributions
  double get totalCharitable => charitableCash + charitableNoncash + charitableCarryover;

  /// Calculate total itemized deductions
  double calculateItemizedTotal() {
    return medicalExpensesDeductible +
        saltTotal +
        homeMortgageInterest +
        homeMortgagePoints +
        investmentInterest +
        charitableCash +
        charitableNoncash +
        charitableCarryover +
        casualtyTheftLosses +
        otherItemized;
  }

  /// Check if itemizing is beneficial
  bool shouldItemize() => totalItemizedDeductions > standardDeductionAmount;

  factory Deductions.fromJson(Map<String, dynamic> json) {
    return Deductions(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      deductionType: DeductionType.fromString(json['deduction_type'] as String?),
      standardDeductionAmount: (json['standard_deduction_amount'] as num?)?.toDouble() ?? 0,
      medicalExpensesTotal: (json['medical_expenses_total'] as num?)?.toDouble() ?? 0,
      medicalExpensesThreshold: (json['medical_expenses_threshold'] as num?)?.toDouble() ?? 0,
      medicalExpensesDeductible: (json['medical_expenses_deductible'] as num?)?.toDouble() ?? 0,
      stateLocalIncomeTax: (json['state_local_income_tax'] as num?)?.toDouble() ?? 0,
      stateLocalSalesTax: (json['state_local_sales_tax'] as num?)?.toDouble() ?? 0,
      realEstateTaxes: (json['real_estate_taxes'] as num?)?.toDouble() ?? 0,
      personalPropertyTaxes: (json['personal_property_taxes'] as num?)?.toDouble() ?? 0,
      saltTotal: (json['salt_total'] as num?)?.toDouble() ?? 0,
      homeMortgageInterest: (json['home_mortgage_interest'] as num?)?.toDouble() ?? 0,
      homeMortgagePoints: (json['home_mortgage_points'] as num?)?.toDouble() ?? 0,
      investmentInterest: (json['investment_interest'] as num?)?.toDouble() ?? 0,
      charitableCash: (json['charitable_cash'] as num?)?.toDouble() ?? 0,
      charitableNoncash: (json['charitable_noncash'] as num?)?.toDouble() ?? 0,
      charitableCarryover: (json['charitable_carryover'] as num?)?.toDouble() ?? 0,
      casualtyTheftLosses: (json['casualty_theft_losses'] as num?)?.toDouble() ?? 0,
      otherItemized: (json['other_itemized'] as num?)?.toDouble() ?? 0,
      otherItemizedDescription: json['other_itemized_description'] as String?,
      totalItemizedDeductions: (json['total_itemized_deductions'] as num?)?.toDouble() ?? 0,
      qbiDeduction: (json['qbi_deduction'] as num?)?.toDouble() ?? 0,
      totalDeductions: (json['total_deductions'] as num?)?.toDouble() ?? 0,
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
      'deduction_type': deductionType.value,
      'standard_deduction_amount': standardDeductionAmount,
      'medical_expenses_total': medicalExpensesTotal,
      'medical_expenses_threshold': medicalExpensesThreshold,
      'medical_expenses_deductible': medicalExpensesDeductible,
      'state_local_income_tax': stateLocalIncomeTax,
      'state_local_sales_tax': stateLocalSalesTax,
      'real_estate_taxes': realEstateTaxes,
      'personal_property_taxes': personalPropertyTaxes,
      'salt_total': saltTotal,
      'home_mortgage_interest': homeMortgageInterest,
      'home_mortgage_points': homeMortgagePoints,
      'investment_interest': investmentInterest,
      'charitable_cash': charitableCash,
      'charitable_noncash': charitableNoncash,
      'charitable_carryover': charitableCarryover,
      'casualty_theft_losses': casualtyTheftLosses,
      'other_itemized': otherItemized,
      'other_itemized_description': otherItemizedDescription,
      'total_itemized_deductions': totalItemizedDeductions,
      'qbi_deduction': qbiDeduction,
      'total_deductions': totalDeductions,
    };
  }

  Deductions copyWith({
    String? id,
    String? returnId,
    DeductionType? deductionType,
    double? standardDeductionAmount,
    double? medicalExpensesTotal,
    double? medicalExpensesThreshold,
    double? medicalExpensesDeductible,
    double? stateLocalIncomeTax,
    double? stateLocalSalesTax,
    double? realEstateTaxes,
    double? personalPropertyTaxes,
    double? saltTotal,
    double? homeMortgageInterest,
    double? homeMortgagePoints,
    double? investmentInterest,
    double? charitableCash,
    double? charitableNoncash,
    double? charitableCarryover,
    double? casualtyTheftLosses,
    double? otherItemized,
    String? otherItemizedDescription,
    double? totalItemizedDeductions,
    double? qbiDeduction,
    double? totalDeductions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Deductions(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      deductionType: deductionType ?? this.deductionType,
      standardDeductionAmount: standardDeductionAmount ?? this.standardDeductionAmount,
      medicalExpensesTotal: medicalExpensesTotal ?? this.medicalExpensesTotal,
      medicalExpensesThreshold: medicalExpensesThreshold ?? this.medicalExpensesThreshold,
      medicalExpensesDeductible: medicalExpensesDeductible ?? this.medicalExpensesDeductible,
      stateLocalIncomeTax: stateLocalIncomeTax ?? this.stateLocalIncomeTax,
      stateLocalSalesTax: stateLocalSalesTax ?? this.stateLocalSalesTax,
      realEstateTaxes: realEstateTaxes ?? this.realEstateTaxes,
      personalPropertyTaxes: personalPropertyTaxes ?? this.personalPropertyTaxes,
      saltTotal: saltTotal ?? this.saltTotal,
      homeMortgageInterest: homeMortgageInterest ?? this.homeMortgageInterest,
      homeMortgagePoints: homeMortgagePoints ?? this.homeMortgagePoints,
      investmentInterest: investmentInterest ?? this.investmentInterest,
      charitableCash: charitableCash ?? this.charitableCash,
      charitableNoncash: charitableNoncash ?? this.charitableNoncash,
      charitableCarryover: charitableCarryover ?? this.charitableCarryover,
      casualtyTheftLosses: casualtyTheftLosses ?? this.casualtyTheftLosses,
      otherItemized: otherItemized ?? this.otherItemized,
      otherItemizedDescription: otherItemizedDescription ?? this.otherItemizedDescription,
      totalItemizedDeductions: totalItemizedDeductions ?? this.totalItemizedDeductions,
      qbiDeduction: qbiDeduction ?? this.qbiDeduction,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// =============================================================================
// Tax Credits
// =============================================================================

/// Tax credits directly reduce tax liability (more valuable than deductions)
/// 
/// Two types:
/// - Nonrefundable: Can only reduce tax to $0
/// - Refundable: Can result in a refund even if no tax owed
class Credits {
  final String? id;
  final String returnId;

  // ---------------------------------------------------------------------------
  // Nonrefundable Credits (reduce tax liability only to $0)
  // ---------------------------------------------------------------------------
  
  /// Child Tax Credit - up to $2,000 per qualifying child under 17
  final double childTaxCredit;

  /// Credit for Other Dependents - $500 per dependent not qualifying for CTC
  final double creditOtherDependents;

  /// Child and Dependent Care Credit - up to $3,000 for one, $6,000 for two+
  final double childDependentCareCredit;

  /// American Opportunity Credit - up to $2,500 per student (first 4 years)
  final double educationCreditsAoc;

  /// Lifetime Learning Credit - up to $2,000 per return
  final double educationCreditsLlc;

  /// Retirement Savings Contributions Credit (Saver's Credit) - up to $1,000
  final double retirementSavingsCredit;

  /// Residential Energy Credit - for energy efficient home improvements
  final double residentialEnergyCredit;

  /// Foreign Tax Credit - taxes paid to foreign countries
  final double foreignTaxCredit;

  /// Credit for Elderly or Disabled (Schedule R)
  final double elderlyDisabledCredit;

  /// Other nonrefundable credits
  final double otherNonrefundableCredits;

  /// Total nonrefundable credits
  final double totalNonrefundableCredits;

  // ---------------------------------------------------------------------------
  // Refundable Credits (can result in refund)
  // ---------------------------------------------------------------------------
  
  /// Earned Income Credit (EIC/EITC) - based on earned income and dependents
  final double earnedIncomeCredit;

  /// Additional Child Tax Credit - refundable portion of CTC
  final double additionalChildTaxCredit;

  /// American Opportunity Credit (refundable portion) - 40% of AOC
  final double americanOpportunityRefundable;

  /// Net Premium Tax Credit - ACA marketplace health insurance credit
  final double netPremiumTaxCredit;

  /// Recovery Rebate Credit - for missed stimulus payments
  final double recoveryRebateCredit;

  /// Other refundable credits
  final double otherRefundableCredits;

  /// Total refundable credits
  final double totalRefundableCredits;

  // ---------------------------------------------------------------------------
  // Total
  // ---------------------------------------------------------------------------
  
  /// Total all credits
  final double totalCredits;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Credits({
    this.id,
    required this.returnId,
    this.childTaxCredit = 0,
    this.creditOtherDependents = 0,
    this.childDependentCareCredit = 0,
    this.educationCreditsAoc = 0,
    this.educationCreditsLlc = 0,
    this.retirementSavingsCredit = 0,
    this.residentialEnergyCredit = 0,
    this.foreignTaxCredit = 0,
    this.elderlyDisabledCredit = 0,
    this.otherNonrefundableCredits = 0,
    this.totalNonrefundableCredits = 0,
    this.earnedIncomeCredit = 0,
    this.additionalChildTaxCredit = 0,
    this.americanOpportunityRefundable = 0,
    this.netPremiumTaxCredit = 0,
    this.recoveryRebateCredit = 0,
    this.otherRefundableCredits = 0,
    this.totalRefundableCredits = 0,
    this.totalCredits = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Calculate total nonrefundable credits
  double calculateNonrefundableTotal() {
    return childTaxCredit +
        creditOtherDependents +
        childDependentCareCredit +
        educationCreditsAoc +
        educationCreditsLlc +
        retirementSavingsCredit +
        residentialEnergyCredit +
        foreignTaxCredit +
        elderlyDisabledCredit +
        otherNonrefundableCredits;
  }

  /// Calculate total refundable credits
  double calculateRefundableTotal() {
    return earnedIncomeCredit +
        additionalChildTaxCredit +
        americanOpportunityRefundable +
        netPremiumTaxCredit +
        recoveryRebateCredit +
        otherRefundableCredits;
  }

  /// Calculate total education credits (can't take both AOC and LLC for same student)
  double get totalEducationCredits => educationCreditsAoc + educationCreditsLlc;

  factory Credits.fromJson(Map<String, dynamic> json) {
    return Credits(
      id: json['id'] as String?,
      returnId: json['return_id'] as String,
      childTaxCredit: (json['child_tax_credit'] as num?)?.toDouble() ?? 0,
      creditOtherDependents: (json['credit_other_dependents'] as num?)?.toDouble() ?? 0,
      childDependentCareCredit: (json['child_dependent_care_credit'] as num?)?.toDouble() ?? 0,
      educationCreditsAoc: (json['education_credits_aoc'] as num?)?.toDouble() ?? 0,
      educationCreditsLlc: (json['education_credits_llc'] as num?)?.toDouble() ?? 0,
      retirementSavingsCredit: (json['retirement_savings_credit'] as num?)?.toDouble() ?? 0,
      residentialEnergyCredit: (json['residential_energy_credit'] as num?)?.toDouble() ?? 0,
      foreignTaxCredit: (json['foreign_tax_credit'] as num?)?.toDouble() ?? 0,
      elderlyDisabledCredit: (json['elderly_disabled_credit'] as num?)?.toDouble() ?? 0,
      otherNonrefundableCredits: (json['other_nonrefundable_credits'] as num?)?.toDouble() ?? 0,
      totalNonrefundableCredits: (json['total_nonrefundable_credits'] as num?)?.toDouble() ?? 0,
      earnedIncomeCredit: (json['earned_income_credit'] as num?)?.toDouble() ?? 0,
      additionalChildTaxCredit: (json['additional_child_tax_credit'] as num?)?.toDouble() ?? 0,
      americanOpportunityRefundable: (json['american_opportunity_refundable'] as num?)?.toDouble() ?? 0,
      netPremiumTaxCredit: (json['net_premium_tax_credit'] as num?)?.toDouble() ?? 0,
      recoveryRebateCredit: (json['recovery_rebate_credit'] as num?)?.toDouble() ?? 0,
      otherRefundableCredits: (json['other_refundable_credits'] as num?)?.toDouble() ?? 0,
      totalRefundableCredits: (json['total_refundable_credits'] as num?)?.toDouble() ?? 0,
      totalCredits: (json['total_credits'] as num?)?.toDouble() ?? 0,
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
      'child_tax_credit': childTaxCredit,
      'credit_other_dependents': creditOtherDependents,
      'child_dependent_care_credit': childDependentCareCredit,
      'education_credits_aoc': educationCreditsAoc,
      'education_credits_llc': educationCreditsLlc,
      'retirement_savings_credit': retirementSavingsCredit,
      'residential_energy_credit': residentialEnergyCredit,
      'foreign_tax_credit': foreignTaxCredit,
      'elderly_disabled_credit': elderlyDisabledCredit,
      'other_nonrefundable_credits': otherNonrefundableCredits,
      'total_nonrefundable_credits': totalNonrefundableCredits,
      'earned_income_credit': earnedIncomeCredit,
      'additional_child_tax_credit': additionalChildTaxCredit,
      'american_opportunity_refundable': americanOpportunityRefundable,
      'net_premium_tax_credit': netPremiumTaxCredit,
      'recovery_rebate_credit': recoveryRebateCredit,
      'other_refundable_credits': otherRefundableCredits,
      'total_refundable_credits': totalRefundableCredits,
      'total_credits': totalCredits,
    };
  }

  Credits copyWith({
    String? id,
    String? returnId,
    double? childTaxCredit,
    double? creditOtherDependents,
    double? childDependentCareCredit,
    double? educationCreditsAoc,
    double? educationCreditsLlc,
    double? retirementSavingsCredit,
    double? residentialEnergyCredit,
    double? foreignTaxCredit,
    double? elderlyDisabledCredit,
    double? otherNonrefundableCredits,
    double? totalNonrefundableCredits,
    double? earnedIncomeCredit,
    double? additionalChildTaxCredit,
    double? americanOpportunityRefundable,
    double? netPremiumTaxCredit,
    double? recoveryRebateCredit,
    double? otherRefundableCredits,
    double? totalRefundableCredits,
    double? totalCredits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Credits(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      childTaxCredit: childTaxCredit ?? this.childTaxCredit,
      creditOtherDependents: creditOtherDependents ?? this.creditOtherDependents,
      childDependentCareCredit: childDependentCareCredit ?? this.childDependentCareCredit,
      educationCreditsAoc: educationCreditsAoc ?? this.educationCreditsAoc,
      educationCreditsLlc: educationCreditsLlc ?? this.educationCreditsLlc,
      retirementSavingsCredit: retirementSavingsCredit ?? this.retirementSavingsCredit,
      residentialEnergyCredit: residentialEnergyCredit ?? this.residentialEnergyCredit,
      foreignTaxCredit: foreignTaxCredit ?? this.foreignTaxCredit,
      elderlyDisabledCredit: elderlyDisabledCredit ?? this.elderlyDisabledCredit,
      otherNonrefundableCredits: otherNonrefundableCredits ?? this.otherNonrefundableCredits,
      totalNonrefundableCredits: totalNonrefundableCredits ?? this.totalNonrefundableCredits,
      earnedIncomeCredit: earnedIncomeCredit ?? this.earnedIncomeCredit,
      additionalChildTaxCredit: additionalChildTaxCredit ?? this.additionalChildTaxCredit,
      americanOpportunityRefundable: americanOpportunityRefundable ?? this.americanOpportunityRefundable,
      netPremiumTaxCredit: netPremiumTaxCredit ?? this.netPremiumTaxCredit,
      recoveryRebateCredit: recoveryRebateCredit ?? this.recoveryRebateCredit,
      otherRefundableCredits: otherRefundableCredits ?? this.otherRefundableCredits,
      totalRefundableCredits: totalRefundableCredits ?? this.totalRefundableCredits,
      totalCredits: totalCredits ?? this.totalCredits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
