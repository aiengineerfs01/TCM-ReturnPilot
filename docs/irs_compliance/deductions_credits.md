# Deductions & Credits Implementation

## Overview

This document details all tax deductions and credits available for individual tax returns, including eligibility rules, calculation formulas, and implementation specifications.

---

## 1. Standard vs. Itemized Deductions

### 1.1 Decision Logic

```dart
class DeductionDecisionService {
  
  DeductionResult determineOptimalDeduction({
    required FilingStatus filingStatus,
    required int taxpayerAge,
    required bool taxpayerIsBlind,
    required int? spouseAge,
    required bool spouseIsBlind,
    required ItemizedDeductions itemized,
    required bool canBeClaimedAsDependent,
  }) {
    final standardDeduction = _calculateStandardDeduction(
      filingStatus: filingStatus,
      taxpayerAge: taxpayerAge,
      taxpayerIsBlind: taxpayerIsBlind,
      spouseAge: spouseAge,
      spouseIsBlind: spouseIsBlind,
      canBeClaimedAsDependent: canBeClaimedAsDependent,
    );
    
    final itemizedTotal = itemized.calculateTotal();
    
    // Certain situations force itemizing
    final mustItemize = _checkMustItemize(filingStatus);
    
    if (mustItemize) {
      return DeductionResult(
        type: DeductionType.itemized,
        amount: itemizedTotal,
        reason: 'Filing status requires itemizing',
      );
    }
    
    // Choose higher deduction
    if (itemizedTotal > standardDeduction) {
      return DeductionResult(
        type: DeductionType.itemized,
        amount: itemizedTotal,
        reason: 'Itemized deductions exceed standard deduction by \$${(itemizedTotal - standardDeduction).toStringAsFixed(2)}',
      );
    } else {
      return DeductionResult(
        type: DeductionType.standard,
        amount: standardDeduction,
        reason: itemizedTotal > 0 
            ? 'Standard deduction exceeds itemized by \$${(standardDeduction - itemizedTotal).toStringAsFixed(2)}'
            : 'Standard deduction is most beneficial',
      );
    }
  }
  
  double _calculateStandardDeduction({
    required FilingStatus filingStatus,
    required int taxpayerAge,
    required bool taxpayerIsBlind,
    required int? spouseAge,
    required bool spouseIsBlind,
    required bool canBeClaimedAsDependent,
  }) {
    // 2024 Standard Deduction Amounts
    double base = switch (filingStatus) {
      FilingStatus.single => 14600,
      FilingStatus.marriedFilingJointly => 29200,
      FilingStatus.marriedFilingSeparately => 14600,
      FilingStatus.headOfHousehold => 21900,
      FilingStatus.qualifyingSurvivingSpouse => 29200,
    };
    
    // Limited if can be claimed as dependent
    if (canBeClaimedAsDependent) {
      base = min(base, 1300 + earnedIncome); // Greater of $1,300 or earned income + $450
    }
    
    // Additional amounts for age 65+ or blind
    double additional = switch (filingStatus) {
      FilingStatus.single || FilingStatus.headOfHousehold => 1950,
      _ => 1550,
    };
    
    // Primary taxpayer additions
    if (taxpayerAge >= 65) base += additional;
    if (taxpayerIsBlind) base += additional;
    
    // Spouse additions (married statuses)
    if (filingStatus == FilingStatus.marriedFilingJointly ||
        filingStatus == FilingStatus.qualifyingSurvivingSpouse) {
      if (spouseAge != null && spouseAge >= 65) base += additional;
      if (spouseIsBlind) base += additional;
    }
    
    return base;
  }
  
  bool _checkMustItemize(FilingStatus status) {
    // MFS: If spouse itemizes, you must itemize
    // Dual-status aliens
    // Short tax year due to change in accounting period
    return false; // Check specific circumstances
  }
}

class DeductionResult {
  final DeductionType type;
  final double amount;
  final String reason;
  
  const DeductionResult({
    required this.type,
    required this.amount,
    required this.reason,
  });
}

enum DeductionType { standard, itemized }
```

### 1.2 Itemized Deductions Model

```dart
class ItemizedDeductions {
  // Medical & Dental (exceeding 7.5% AGI threshold)
  final MedicalDeductions medical;
  
  // State and Local Taxes (SALT - capped at $10,000)
  final StateLocalTaxes salt;
  
  // Interest Paid
  final InterestDeductions interest;
  
  // Charitable Contributions
  final CharitableDeductions charitable;
  
  // Casualty & Theft Losses (federally declared disasters only)
  final CasualtyLosses casualty;
  
  // Other Deductions
  final OtherItemizedDeductions other;
  
  const ItemizedDeductions({
    this.medical = const MedicalDeductions(),
    this.salt = const StateLocalTaxes(),
    this.interest = const InterestDeductions(),
    this.charitable = const CharitableDeductions(),
    this.casualty = const CasualtyLosses(),
    this.other = const OtherItemizedDeductions(),
  });
  
  double calculateTotal() {
    return medical.deductibleAmount +
           salt.deductibleAmount +
           interest.total +
           charitable.total +
           casualty.deductibleAmount +
           other.total;
  }
}
```

---

## 2. Medical & Dental Deductions

```dart
class MedicalDeductions {
  final double agi;
  
  // Qualified expenses
  final double doctorsVisits;
  final double hospitalCare;
  final double surgicalFees;
  final double labFees;
  final double prescriptions;
  final double dentalCare;
  final double visionCare;
  final double medicalEquipment;
  final double longTermCare;
  final double healthInsurancePremiums; // If not pre-tax
  final double transportation; // Mileage to medical care
  final double nursingServices;
  final double mentalHealth;
  final double other;
  
  const MedicalDeductions({
    this.agi = 0,
    this.doctorsVisits = 0,
    this.hospitalCare = 0,
    this.surgicalFees = 0,
    this.labFees = 0,
    this.prescriptions = 0,
    this.dentalCare = 0,
    this.visionCare = 0,
    this.medicalEquipment = 0,
    this.longTermCare = 0,
    this.healthInsurancePremiums = 0,
    this.transportation = 0,
    this.nursingServices = 0,
    this.mentalHealth = 0,
    this.other = 0,
  });
  
  double get totalExpenses =>
      doctorsVisits + hospitalCare + surgicalFees + labFees +
      prescriptions + dentalCare + visionCare + medicalEquipment +
      longTermCare + healthInsurancePremiums + transportation +
      nursingServices + mentalHealth + other;
  
  double get threshold => agi * 0.075; // 7.5% of AGI
  
  double get deductibleAmount => max(0, totalExpenses - threshold);
  
  // 2024 Medical mileage rate
  static const medicalMileageRate = 0.21; // $0.21 per mile
  
  double calculateTransportationMileage(int miles) {
    return miles * medicalMileageRate;
  }
}
```

---

## 3. State and Local Tax (SALT) Deduction

```dart
class StateLocalTaxes {
  // Choose either income tax OR sales tax (not both)
  final StateLocalTaxChoice taxChoice;
  
  // Option 1: State & Local Income Tax
  final double stateIncomeTax;
  final double localIncomeTax;
  
  // Option 2: State & Local Sales Tax
  final double actualSalesTax;
  final double salesTaxTableAmount; // IRS tables based on income/state
  
  // Real Estate Taxes
  final double realEstateTax;
  
  // Personal Property Tax
  final double personalPropertyTax;
  
  const StateLocalTaxes({
    this.taxChoice = StateLocalTaxChoice.incomeTax,
    this.stateIncomeTax = 0,
    this.localIncomeTax = 0,
    this.actualSalesTax = 0,
    this.salesTaxTableAmount = 0,
    this.realEstateTax = 0,
    this.personalPropertyTax = 0,
  });
  
  double get selectedTax {
    return switch (taxChoice) {
      StateLocalTaxChoice.incomeTax => stateIncomeTax + localIncomeTax,
      StateLocalTaxChoice.salesTax => max(actualSalesTax, salesTaxTableAmount),
    };
  }
  
  double get totalBeforeCap =>
      selectedTax + realEstateTax + personalPropertyTax;
  
  // SALT Cap: $10,000 ($5,000 if MFS)
  double get deductibleAmount => min(totalBeforeCap, 10000);
  
  double getDeductibleAmount(FilingStatus status) {
    final cap = status == FilingStatus.marriedFilingSeparately ? 5000.0 : 10000.0;
    return min(totalBeforeCap, cap);
  }
}

enum StateLocalTaxChoice { incomeTax, salesTax }
```

---

## 4. Interest Deductions

```dart
class InterestDeductions {
  // Home Mortgage Interest
  final List<MortgageInterest> mortgages;
  
  // Points Paid
  final double pointsPaidOnPurchase;
  final double refinancePointsCurrentYear;
  
  // Mortgage Insurance Premiums
  final double mortgageInsurance; // PMI (AGI limit applies)
  
  // Investment Interest
  final double investmentInterest; // Limited to net investment income
  final double netInvestmentIncome;
  
  const InterestDeductions({
    this.mortgages = const [],
    this.pointsPaidOnPurchase = 0,
    this.refinancePointsCurrentYear = 0,
    this.mortgageInsurance = 0,
    this.investmentInterest = 0,
    this.netInvestmentIncome = 0,
  });
  
  double get mortgageInterestTotal {
    // Acquisition debt limit: $750,000 (or $1M if before 12/16/2017)
    double total = 0;
    double qualifiedDebt = 0;
    
    for (final mortgage in mortgages) {
      final limit = mortgage.originationDate.isBefore(DateTime(2017, 12, 16))
          ? 1000000.0
          : 750000.0;
      
      if (qualifiedDebt + mortgage.principalBalance <= limit) {
        total += mortgage.interestPaid;
        qualifiedDebt += mortgage.principalBalance;
      } else {
        // Prorate if over limit
        final qualifiedPortion = (limit - qualifiedDebt) / mortgage.principalBalance;
        total += mortgage.interestPaid * qualifiedPortion;
        break;
      }
    }
    
    return total;
  }
  
  double get deductibleInvestmentInterest =>
      min(investmentInterest, netInvestmentIncome);
  
  double get total =>
      mortgageInterestTotal +
      pointsPaidOnPurchase +
      refinancePointsCurrentYear +
      mortgageInsurance +
      deductibleInvestmentInterest;
}

class MortgageInterest {
  final String lenderName;
  final String? lenderEIN;
  final double interestPaid;
  final double principalBalance;
  final DateTime originationDate;
  final MortgageType mortgageType;
  
  const MortgageInterest({
    required this.lenderName,
    this.lenderEIN,
    required this.interestPaid,
    required this.principalBalance,
    required this.originationDate,
    this.mortgageType = MortgageType.acquisition,
  });
}

enum MortgageType { acquisition, homeEquity, refinance }
```

---

## 5. Charitable Contributions

```dart
class CharitableDeductions {
  final double agi;
  
  // Cash Contributions
  final List<CashDonation> cashDonations;
  
  // Non-Cash Contributions
  final List<NonCashDonation> nonCashDonations;
  
  // Carryover from prior years
  final double carryoverFromPriorYears;
  
  const CharitableDeductions({
    this.agi = 0,
    this.cashDonations = const [],
    this.nonCashDonations = const [],
    this.carryoverFromPriorYears = 0,
  });
  
  double get totalCash => cashDonations.fold(0, (sum, d) => sum + d.amount);
  
  double get totalNonCash => nonCashDonations.fold(0, (sum, d) => sum + d.fairMarketValue);
  
  // AGI Limits
  double get cashLimit => agi * 0.60;  // 60% AGI for most cash
  double get nonCashLimit => agi * 0.30; // 30% AGI for property
  double get appreciatedPropertyLimit => agi * 0.20; // 20% for appreciated capital gain property
  
  double get total {
    // Apply limits
    final deductibleCash = min(totalCash, cashLimit);
    final deductibleNonCash = min(totalNonCash, nonCashLimit);
    final carryover = min(carryoverFromPriorYears, agi * 0.60 - deductibleCash);
    
    return deductibleCash + deductibleNonCash + carryover;
  }
  
  double get carryforwardToNextYear {
    final excess = (totalCash - cashLimit) + (totalNonCash - nonCashLimit);
    return max(0, excess);
  }
}

class CashDonation {
  final String organizationName;
  final String? ein;
  final double amount;
  final DateTime date;
  final DonationType type;
  
  const CashDonation({
    required this.organizationName,
    this.ein,
    required this.amount,
    required this.date,
    this.type = DonationType.publicCharity,
  });
}

class NonCashDonation {
  final String organizationName;
  final String description;
  final double fairMarketValue;
  final double costBasis;
  final DateTime dateAcquired;
  final DateTime dateDonated;
  final String? appraisalRequired; // Required if FMV > $5,000
  
  const NonCashDonation({
    required this.organizationName,
    required this.description,
    required this.fairMarketValue,
    required this.costBasis,
    required this.dateAcquired,
    required this.dateDonated,
    this.appraisalRequired,
  });
  
  bool get requiresAppraisal => fairMarketValue > 5000;
  bool get requiresForm8283 => fairMarketValue > 500;
}

enum DonationType {
  publicCharity,     // 60% AGI limit
  privateFoundation, // 30% AGI limit
  capitalGainProperty, // 20% AGI limit
}
```

---

## 6. Above-the-Line Deductions (Adjustments to Income)

```dart
class AboveTheLineDeductions {
  // Educator Expenses (up to $300)
  final double educatorExpenses;
  
  // Health Savings Account (HSA)
  final double hsaDeduction;
  
  // Self-Employment Tax Deduction (50% of SE tax)
  final double selfEmploymentTaxDeduction;
  
  // Self-Employed Health Insurance
  final double selfEmployedHealthInsurance;
  
  // Self-Employed Retirement (SEP, SIMPLE, Qualified plans)
  final double selfEmployedRetirement;
  
  // Penalty on Early Withdrawal of Savings
  final double earlyWithdrawalPenalty;
  
  // Alimony Paid (pre-2019 agreements only)
  final double alimonyPaid;
  final String? alimonyRecipientSSN;
  
  // IRA Deduction
  final double iraDeduction;
  
  // Student Loan Interest (up to $2,500)
  final double studentLoanInterest;
  
  // Moving Expenses (Military only)
  final double movingExpenses;
  
  // Reservist/Performing Artist/Fee-basis Government
  final double reservistExpenses;
  
  const AboveTheLineDeductions({
    this.educatorExpenses = 0,
    this.hsaDeduction = 0,
    this.selfEmploymentTaxDeduction = 0,
    this.selfEmployedHealthInsurance = 0,
    this.selfEmployedRetirement = 0,
    this.earlyWithdrawalPenalty = 0,
    this.alimonyPaid = 0,
    this.alimonyRecipientSSN,
    this.iraDeduction = 0,
    this.studentLoanInterest = 0,
    this.movingExpenses = 0,
    this.reservistExpenses = 0,
  });
  
  double get total =>
      min(educatorExpenses, 300) +
      hsaDeduction +
      selfEmploymentTaxDeduction +
      selfEmployedHealthInsurance +
      selfEmployedRetirement +
      earlyWithdrawalPenalty +
      alimonyPaid +
      iraDeduction +
      min(studentLoanInterest, 2500) +
      movingExpenses +
      reservistExpenses;
}
```

---

## 7. Child Tax Credit (CTC)

```dart
class ChildTaxCreditCalculator {
  // 2024 Credit amounts
  static const creditPerChild = 2000.0;    // Under 17
  static const creditPerOther = 500.0;     // Other dependents
  static const refundableMax = 1700.0;     // Max refundable (ACTC)
  
  // Phase-out thresholds
  static const mfjThreshold = 400000.0;
  static const otherThreshold = 200000.0;
  static const phaseOutRate = 0.05;        // $50 per $1,000 over
  
  ChildTaxCreditResult calculate({
    required double modifiedAGI,
    required FilingStatus filingStatus,
    required List<Dependent> dependents,
    required double taxLiability,
    required double earnedIncome,
  }) {
    // Count qualifying children and other dependents
    int qualifyingChildren = 0;
    int otherDependents = 0;
    
    for (final dep in dependents) {
      if (dep.qualifiesForChildTaxCredit) {
        qualifyingChildren++;
      } else if (dep.qualifiesForOtherDependentCredit) {
        otherDependents++;
      }
    }
    
    // Calculate base credit
    final baseCredit = (qualifyingChildren * creditPerChild) +
                       (otherDependents * creditPerOther);
    
    // Apply phase-out
    final threshold = filingStatus == FilingStatus.marriedFilingJointly
        ? mfjThreshold
        : otherThreshold;
    
    double reduction = 0;
    if (modifiedAGI > threshold) {
      final excessIncome = modifiedAGI - threshold;
      final phaseOutUnits = (excessIncome / 1000).ceil();
      reduction = phaseOutUnits * 50;
    }
    
    final allowedCredit = max(0, baseCredit - reduction);
    
    // Split into nonrefundable and refundable portions
    final nonrefundableCredit = min(allowedCredit, taxLiability);
    
    // Calculate Additional Child Tax Credit (refundable)
    final refundablePortion = _calculateACTC(
      allowedCredit: allowedCredit,
      nonrefundableUsed: nonrefundableCredit,
      earnedIncome: earnedIncome,
      qualifyingChildren: qualifyingChildren,
    );
    
    return ChildTaxCreditResult(
      childTaxCredit: nonrefundableCredit,
      additionalChildTaxCredit: refundablePortion,
      totalCredit: nonrefundableCredit + refundablePortion,
      qualifyingChildren: qualifyingChildren,
      otherDependents: otherDependents,
    );
  }
  
  double _calculateACTC({
    required double allowedCredit,
    required double nonrefundableUsed,
    required double earnedIncome,
    required int qualifyingChildren,
  }) {
    // Remaining credit after nonrefundable portion
    final remainingCredit = allowedCredit - nonrefundableUsed;
    if (remainingCredit <= 0) return 0;
    
    // Max refundable per child
    final maxRefundable = qualifyingChildren * refundableMax;
    
    // Based on earned income (15% of earned income over $2,500)
    final earnedIncomeBasedACTC = max(0, (earnedIncome - 2500) * 0.15);
    
    return min(remainingCredit, min(maxRefundable, earnedIncomeBasedACTC));
  }
}

class ChildTaxCreditResult {
  final double childTaxCredit;           // Nonrefundable (Line 19)
  final double additionalChildTaxCredit; // Refundable (Line 28)
  final double totalCredit;
  final int qualifyingChildren;
  final int otherDependents;
  
  const ChildTaxCreditResult({
    required this.childTaxCredit,
    required this.additionalChildTaxCredit,
    required this.totalCredit,
    required this.qualifyingChildren,
    required this.otherDependents,
  });
}
```

---

## 8. Earned Income Credit (EIC)

```dart
class EarnedIncomeCreditCalculator {
  // 2024 EIC Parameters
  static const parameters = {
    0: EICParameters(maxCredit: 632, phaseInRate: 0.0765, phaseOutRate: 0.0765,
        earnedIncomeThreshold: 8260, phaseOutBegin: 9800, phaseOutEnd: 17520),
    1: EICParameters(maxCredit: 4213, phaseInRate: 0.34, phaseOutRate: 0.1598,
        earnedIncomeThreshold: 12390, phaseOutBegin: 21560, phaseOutEnd: 49622),
    2: EICParameters(maxCredit: 6960, phaseInRate: 0.40, phaseOutRate: 0.2106,
        earnedIncomeThreshold: 17400, phaseOutBegin: 21560, phaseOutEnd: 55529),
    3: EICParameters(maxCredit: 7830, phaseInRate: 0.45, phaseOutRate: 0.2106,
        earnedIncomeThreshold: 17400, phaseOutBegin: 21560, phaseOutEnd: 59899),
  };
  
  EarnedIncomeCreditResult calculate({
    required double earnedIncome,
    required double agi,
    required FilingStatus filingStatus,
    required int qualifyingChildren,
    required int taxpayerAge,
    required bool hasSelfEmployment,
    required double investmentIncome,
  }) {
    // Investment income limit: $11,600 (2024)
    if (investmentIncome > 11600) {
      return EarnedIncomeCreditResult.ineligible(
        reason: 'Investment income exceeds \$11,600 limit',
      );
    }
    
    // No children - age requirement (25-64)
    if (qualifyingChildren == 0 && (taxpayerAge < 25 || taxpayerAge > 64)) {
      return EarnedIncomeCreditResult.ineligible(
        reason: 'Must be 25-64 to claim EIC with no children',
      );
    }
    
    // Cap at 3+ children (same parameters)
    final children = min(qualifyingChildren, 3);
    final params = parameters[children]!;
    
    // MFJ has higher phase-out thresholds
    final phaseOutBegin = filingStatus == FilingStatus.marriedFilingJointly
        ? params.phaseOutBeginMFJ
        : params.phaseOutBegin;
    
    final phaseOutEnd = filingStatus == FilingStatus.marriedFilingJointly
        ? params.phaseOutEndMFJ
        : params.phaseOutEnd;
    
    // Use larger of earned income or AGI for phase-out
    final incomeForPhaseOut = max(earnedIncome, agi);
    
    // Calculate credit
    double credit;
    
    if (earnedIncome <= params.earnedIncomeThreshold) {
      // Phase-in: credit = earnedIncome * phase-in rate
      credit = earnedIncome * params.phaseInRate;
    } else if (incomeForPhaseOut <= phaseOutBegin) {
      // Plateau: max credit
      credit = params.maxCredit;
    } else if (incomeForPhaseOut < phaseOutEnd) {
      // Phase-out
      final reduction = (incomeForPhaseOut - phaseOutBegin) * params.phaseOutRate;
      credit = max(0, params.maxCredit - reduction);
    } else {
      // Over phase-out
      credit = 0;
    }
    
    return EarnedIncomeCreditResult(
      credit: credit.roundToDouble(),
      qualifyingChildren: qualifyingChildren,
      eligibilityMet: credit > 0,
    );
  }
}

class EICParameters {
  final double maxCredit;
  final double phaseInRate;
  final double phaseOutRate;
  final double earnedIncomeThreshold;
  final double phaseOutBegin;
  final double phaseOutEnd;
  
  // MFJ gets additional $7,210 added to phase-out thresholds
  double get phaseOutBeginMFJ => phaseOutBegin + 7210;
  double get phaseOutEndMFJ => phaseOutEnd + 7210;
  
  const EICParameters({
    required this.maxCredit,
    required this.phaseInRate,
    required this.phaseOutRate,
    required this.earnedIncomeThreshold,
    required this.phaseOutBegin,
    required this.phaseOutEnd,
  });
}

class EarnedIncomeCreditResult {
  final double credit;
  final int qualifyingChildren;
  final bool eligibilityMet;
  final String? ineligibleReason;
  
  const EarnedIncomeCreditResult({
    required this.credit,
    required this.qualifyingChildren,
    required this.eligibilityMet,
    this.ineligibleReason,
  });
  
  factory EarnedIncomeCreditResult.ineligible({required String reason}) {
    return EarnedIncomeCreditResult(
      credit: 0,
      qualifyingChildren: 0,
      eligibilityMet: false,
      ineligibleReason: reason,
    );
  }
}
```

---

## 9. Education Credits

```dart
class EducationCreditsCalculator {
  
  EducationCreditResult calculate({
    required double modifiedAGI,
    required FilingStatus filingStatus,
    required List<StudentExpense> students,
  }) {
    double totalAOTC = 0;
    double totalLLC = 0;
    final studentResults = <StudentCreditResult>[];
    
    for (final student in students) {
      final result = _calculateForStudent(
        student: student,
        modifiedAGI: modifiedAGI,
        filingStatus: filingStatus,
      );
      studentResults.add(result);
      
      if (result.creditType == EducationCreditType.aotc) {
        totalAOTC += result.credit;
      } else {
        totalLLC += result.credit;
      }
    }
    
    return EducationCreditResult(
      americanOpportunityCredit: totalAOTC,
      lifetimeLearningCredit: totalLLC,
      studentResults: studentResults,
    );
  }
  
  StudentCreditResult _calculateForStudent({
    required StudentExpense student,
    required double modifiedAGI,
    required FilingStatus filingStatus,
  }) {
    // AOTC is generally more beneficial - check eligibility first
    if (_eligibleForAOTC(student)) {
      final aotc = _calculateAOTC(
        qualifiedExpenses: student.qualifiedExpenses,
        modifiedAGI: modifiedAGI,
        filingStatus: filingStatus,
      );
      
      if (aotc.credit > 0) {
        return StudentCreditResult(
          studentName: student.studentName,
          creditType: EducationCreditType.aotc,
          credit: aotc.credit,
          refundablePortion: aotc.refundable,
          nonrefundablePortion: aotc.nonrefundable,
        );
      }
    }
    
    // Fall back to LLC
    final llc = _calculateLLC(
      qualifiedExpenses: student.qualifiedExpenses,
      modifiedAGI: modifiedAGI,
      filingStatus: filingStatus,
    );
    
    return StudentCreditResult(
      studentName: student.studentName,
      creditType: EducationCreditType.llc,
      credit: llc,
      refundablePortion: 0, // LLC is not refundable
      nonrefundablePortion: llc,
    );
  }
  
  bool _eligibleForAOTC(StudentExpense student) {
    return student.yearInSchool <= 4 &&          // First 4 years
           student.enrolledHalfTime &&            // At least half-time
           student.yearsAOTCClaimed < 4 &&        // Haven't claimed 4 times
           !student.hasFelonyDrugConviction &&    // No drug felony
           student.pursuesDegree;                 // Pursuing degree
  }
  
  AOTCResult _calculateAOTC({
    required double qualifiedExpenses,
    required double modifiedAGI,
    required FilingStatus filingStatus,
  }) {
    // AOTC: 100% of first $2,000 + 25% of next $2,000 = max $2,500
    final expenses = min(qualifiedExpenses, 4000);
    double baseCredit;
    
    if (expenses <= 2000) {
      baseCredit = expenses;
    } else {
      baseCredit = 2000 + (expenses - 2000) * 0.25;
    }
    
    // Phase-out: $80,000-$90,000 (Single), $160,000-$180,000 (MFJ)
    final thresholds = filingStatus == FilingStatus.marriedFilingJointly
        ? (begin: 160000.0, end: 180000.0)
        : (begin: 80000.0, end: 90000.0);
    
    final credit = _applyPhaseOut(
      baseCredit: baseCredit,
      magi: modifiedAGI,
      phaseOutBegin: thresholds.begin,
      phaseOutEnd: thresholds.end,
    );
    
    // 40% refundable, 60% nonrefundable
    return AOTCResult(
      credit: credit,
      refundable: credit * 0.40,
      nonrefundable: credit * 0.60,
    );
  }
  
  double _calculateLLC({
    required double qualifiedExpenses,
    required double modifiedAGI,
    required FilingStatus filingStatus,
  }) {
    // LLC: 20% of first $10,000 = max $2,000
    final baseCredit = min(qualifiedExpenses, 10000) * 0.20;
    
    // Phase-out: $80,000-$90,000 (Single), $160,000-$180,000 (MFJ)
    final thresholds = filingStatus == FilingStatus.marriedFilingJointly
        ? (begin: 160000.0, end: 180000.0)
        : (begin: 80000.0, end: 90000.0);
    
    return _applyPhaseOut(
      baseCredit: baseCredit,
      magi: modifiedAGI,
      phaseOutBegin: thresholds.begin,
      phaseOutEnd: thresholds.end,
    );
  }
  
  double _applyPhaseOut({
    required double baseCredit,
    required double magi,
    required double phaseOutBegin,
    required double phaseOutEnd,
  }) {
    if (magi <= phaseOutBegin) return baseCredit;
    if (magi >= phaseOutEnd) return 0;
    
    final ratio = (phaseOutEnd - magi) / (phaseOutEnd - phaseOutBegin);
    return baseCredit * ratio;
  }
}

class StudentExpense {
  final String studentName;
  final String ssn;
  final double qualifiedExpenses; // Tuition, fees, books, supplies
  final int yearInSchool;         // 1-4 for AOTC eligibility
  final bool enrolledHalfTime;
  final int yearsAOTCClaimed;     // Max 4
  final bool hasFelonyDrugConviction;
  final bool pursuesDegree;
  final String institutionEIN;
  
  const StudentExpense({
    required this.studentName,
    required this.ssn,
    required this.qualifiedExpenses,
    this.yearInSchool = 1,
    this.enrolledHalfTime = true,
    this.yearsAOTCClaimed = 0,
    this.hasFelonyDrugConviction = false,
    this.pursuesDegree = true,
    required this.institutionEIN,
  });
}

enum EducationCreditType { aotc, llc }
```

---

## 10. Other Common Credits

```dart
class OtherCreditsCalculator {
  // Child and Dependent Care Credit
  static ChildDependentCareResult calculateChildCareCredit({
    required double expenses,
    required double agi,
    required int qualifyingPersons,
    required double earnedIncome,
    required double spouseEarnedIncome,
    required FilingStatus filingStatus,
  }) {
    // Maximum expenses: $3,000 (one), $6,000 (two+)
    final maxExpenses = qualifyingPersons >= 2 ? 6000.0 : 3000.0;
    
    // Limited to lower earner's income (or taxpayer if single)
    final earnedIncomeLimit = filingStatus == FilingStatus.marriedFilingJointly
        ? min(earnedIncome, spouseEarnedIncome)
        : earnedIncome;
    
    final qualifiedExpenses = min(expenses, min(maxExpenses, earnedIncomeLimit));
    
    // Credit rate: 20-35% based on AGI
    final rate = _getChildCareRate(agi);
    
    return ChildDependentCareResult(
      credit: qualifiedExpenses * rate,
      rate: rate,
      qualifiedExpenses: qualifiedExpenses,
    );
  }
  
  static double _getChildCareRate(double agi) {
    if (agi <= 15000) return 0.35;
    if (agi <= 43000) return 0.35 - (((agi - 15000) / 2000).floor() * 0.01);
    return 0.20;
  }
  
  // Saver's Credit (Retirement Savings Contribution Credit)
  static double calculateSaversCredit({
    required double contributions,
    required double agi,
    required FilingStatus filingStatus,
  }) {
    // Max contribution: $2,000 ($4,000 MFJ)
    final maxContribution = filingStatus == FilingStatus.marriedFilingJointly
        ? 4000.0 : 2000.0;
    
    final qualifiedContribution = min(contributions, maxContribution);
    
    // Rate based on AGI
    final rate = _getSaversRate(agi, filingStatus);
    
    return qualifiedContribution * rate;
  }
  
  static double _getSaversRate(double agi, FilingStatus status) {
    // 2024 thresholds
    final thresholds = switch (status) {
      FilingStatus.marriedFilingJointly => (t1: 46000.0, t2: 50000.0, t3: 76500.0),
      FilingStatus.headOfHousehold => (t1: 34500.0, t2: 37500.0, t3: 57375.0),
      _ => (t1: 23000.0, t2: 25000.0, t3: 38250.0),
    };
    
    if (agi <= thresholds.t1) return 0.50;
    if (agi <= thresholds.t2) return 0.20;
    if (agi <= thresholds.t3) return 0.10;
    return 0;
  }
  
  // Foreign Tax Credit
  static double calculateForeignTaxCredit({
    required double foreignTaxPaid,
    required double foreignSourceIncome,
    required double totalIncome,
    required double usTaxLiability,
  }) {
    // Simplified: Limited to US tax on foreign income proportion
    final limit = usTaxLiability * (foreignSourceIncome / totalIncome);
    return min(foreignTaxPaid, limit);
  }
  
  // Residential Energy Credits
  static ResidentialEnergyResult calculateEnergyCredits({
    required double solarPanelCost,
    required double solarWaterHeaterCost,
    required double geothermalCost,
    required double windEnergyCost,
    required double fuelCellCost,
    required double batteryStorageCost,
    // Nonrefundable energy efficiency credits
    required double insulationCost,
    required double windowsCost,
    required double hvacCost,
  }) {
    // Residential Clean Energy Credit (25D) - 30%
    final cleanEnergyCosts = solarPanelCost + solarWaterHeaterCost +
        geothermalCost + windEnergyCost + fuelCellCost + batteryStorageCost;
    final cleanEnergyCredit = cleanEnergyCosts * 0.30;
    
    // Energy Efficient Home Improvement Credit (25C)
    // 30% up to annual limits
    final efficiencyCredit = min(insulationCost * 0.30, 1200) +
        min(windowsCost * 0.30, 600) +
        min(hvacCost * 0.30, 2000);
    
    return ResidentialEnergyResult(
      cleanEnergyCredit: cleanEnergyCredit, // No annual limit, carryforward
      energyEfficiencyCredit: min(efficiencyCredit, 3200), // $3,200 annual max
    );
  }
}
```

---

## 11. Deduction/Credit Summary Service

```dart
class DeductionCreditSummaryService {
  
  TaxBenefitsSummary calculateAllBenefits({
    required TaxpayerData taxpayer,
    required IncomeData income,
    required ExpenseData expenses,
    required DependentData dependents,
  }) {
    // Calculate AGI first
    final aboveLine = _calculateAboveLineDeductions(income, expenses);
    final agi = income.totalIncome - aboveLine.total;
    
    // Determine optimal deduction type
    final deductionDecision = DeductionDecisionService().determineOptimalDeduction(
      filingStatus: taxpayer.filingStatus,
      taxpayerAge: taxpayer.age,
      taxpayerIsBlind: taxpayer.isBlind,
      spouseAge: taxpayer.spouseAge,
      spouseIsBlind: taxpayer.spouseIsBlind ?? false,
      itemized: expenses.itemizedDeductions,
      canBeClaimedAsDependent: taxpayer.canBeClaimedAsDependent,
    );
    
    // Calculate taxable income
    final taxableIncome = max(0, agi - deductionDecision.amount);
    
    // Calculate all credits
    final ctc = ChildTaxCreditCalculator().calculate(
      modifiedAGI: agi,
      filingStatus: taxpayer.filingStatus,
      dependents: dependents.list,
      taxLiability: _calculateTax(taxableIncome, taxpayer.filingStatus),
      earnedIncome: income.earnedIncome,
    );
    
    final eic = EarnedIncomeCreditCalculator().calculate(
      earnedIncome: income.earnedIncome,
      agi: agi,
      filingStatus: taxpayer.filingStatus,
      qualifyingChildren: dependents.qualifyingChildrenForEIC,
      taxpayerAge: taxpayer.age,
      hasSelfEmployment: income.hasSelfEmployment,
      investmentIncome: income.investmentIncome,
    );
    
    // ... calculate other credits
    
    return TaxBenefitsSummary(
      adjustedGrossIncome: agi,
      deductionType: deductionDecision.type,
      totalDeduction: deductionDecision.amount,
      taxableIncome: taxableIncome,
      childTaxCredit: ctc,
      earnedIncomeCredit: eic,
      // ... other results
    );
  }
}
```

---

## 12. Implementation Checklist

- [ ] Implement DeductionDecisionService
- [ ] Implement standard deduction calculator
- [ ] Implement itemized deduction models
- [ ] Implement Child Tax Credit calculator
- [ ] Implement EIC calculator
- [ ] Implement education credits calculator
- [ ] Implement other credits (child care, saver's, energy)
- [ ] Create credit phase-out utilities
- [ ] Build deduction/credit optimization engine
- [ ] Add validation rules
- [ ] Create unit tests

---

## 13. Related Documents

- [Calculations](./calculations.md)
- [Tax Forms](./tax_forms.md)
- [Income Sources](./income_sources.md)
- [Taxpayer Data](./taxpayer_data.md)
