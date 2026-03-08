# Tax Calculation Engine Specifications

## Overview

This document specifies the tax calculation engine requirements, formulas, and implementation guidelines for IRS-compliant tax computations.

---

## 1. Tax Calculation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    TAX CALCULATION PIPELINE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐                                               │
│  │ Total Income │ ← W-2 + 1099s + Business + Other             │
│  └──────┬───────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────┐                                       │
│  │ Adjustments (Sch 1)  │ ← IRA, Student Loan Interest, etc.   │
│  └──────┬───────────────┘                                       │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────┐                                       │
│  │  Adjusted Gross      │ = Total Income - Adjustments         │
│  │  Income (AGI)        │                                       │
│  └──────┬───────────────┘                                       │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────┐                                       │
│  │ Deductions           │ ← MAX(Standard, Itemized)            │
│  └──────┬───────────────┘                                       │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────┐                                       │
│  │ Taxable Income       │ = AGI - Deductions                   │
│  └──────┬───────────────┘                                       │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────┐                                       │
│  │ Tax Liability        │ ← Apply Tax Brackets                 │
│  └──────┬───────────────┘                                       │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────┐                                       │
│  │ Credits              │ ← CTC, EIC, Education, etc.          │
│  └──────┬───────────────┘                                       │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────┐                                       │
│  │ Total Tax            │ = Liability - Credits + Other Taxes  │
│  └──────┬───────────────┘                                       │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────┐                                       │
│  │ Payments/Refund      │ = Withholding + Est. Payments - Tax  │
│  └──────────────────────┘                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. 2024 Tax Brackets

### 2.1 Single Filers

```dart
const singleBrackets2024 = [
  TaxBracket(min: 0, max: 11600, rate: 0.10),
  TaxBracket(min: 11600, max: 47150, rate: 0.12),
  TaxBracket(min: 47150, max: 100525, rate: 0.22),
  TaxBracket(min: 100525, max: 191950, rate: 0.24),
  TaxBracket(min: 191950, max: 243725, rate: 0.32),
  TaxBracket(min: 243725, max: 609350, rate: 0.35),
  TaxBracket(min: 609350, max: double.infinity, rate: 0.37),
];
```

### 2.2 Married Filing Jointly

```dart
const mfjBrackets2024 = [
  TaxBracket(min: 0, max: 23200, rate: 0.10),
  TaxBracket(min: 23200, max: 94300, rate: 0.12),
  TaxBracket(min: 94300, max: 201050, rate: 0.22),
  TaxBracket(min: 201050, max: 383900, rate: 0.24),
  TaxBracket(min: 383900, max: 487450, rate: 0.32),
  TaxBracket(min: 487450, max: 731200, rate: 0.35),
  TaxBracket(min: 731200, max: double.infinity, rate: 0.37),
];
```

### 2.3 Head of Household

```dart
const hohBrackets2024 = [
  TaxBracket(min: 0, max: 16550, rate: 0.10),
  TaxBracket(min: 16550, max: 63100, rate: 0.12),
  TaxBracket(min: 63100, max: 100500, rate: 0.22),
  TaxBracket(min: 100500, max: 191950, rate: 0.24),
  TaxBracket(min: 191950, max: 243700, rate: 0.32),
  TaxBracket(min: 243700, max: 609350, rate: 0.35),
  TaxBracket(min: 609350, max: double.infinity, rate: 0.37),
];
```

### 2.4 Married Filing Separately

```dart
const mfsBrackets2024 = [
  TaxBracket(min: 0, max: 11600, rate: 0.10),
  TaxBracket(min: 11600, max: 47150, rate: 0.12),
  TaxBracket(min: 47150, max: 100525, rate: 0.22),
  TaxBracket(min: 100525, max: 191950, rate: 0.24),
  TaxBracket(min: 191950, max: 243725, rate: 0.32),
  TaxBracket(min: 243725, max: 365600, rate: 0.35),
  TaxBracket(min: 365600, max: double.infinity, rate: 0.37),
];
```

---

## 3. Tax Calculator Implementation

### 3.1 Core Calculator Class

```dart
class TaxCalculator {
  final int taxYear;
  final TaxReturnModel taxReturn;
  
  TaxCalculator({
    required this.taxYear,
    required this.taxReturn,
  });
  
  // Main calculation entry point
  TaxCalculationResult calculate() {
    // Step 1: Calculate total income
    final totalIncome = _calculateTotalIncome();
    
    // Step 2: Calculate adjustments (Schedule 1 Part II)
    final adjustments = _calculateAdjustments();
    
    // Step 3: Calculate AGI
    final agi = totalIncome - adjustments;
    
    // Step 4: Determine deduction amount
    final deduction = _calculateDeduction(agi);
    
    // Step 5: Calculate taxable income
    final taxableIncome = max(0, agi - deduction);
    
    // Step 6: Calculate base tax
    final baseTax = _calculateTaxFromBrackets(taxableIncome);
    
    // Step 7: Add other taxes (Schedule 2)
    final otherTaxes = _calculateOtherTaxes();
    
    // Step 8: Calculate total tax before credits
    final totalTaxBeforeCredits = baseTax + otherTaxes;
    
    // Step 9: Calculate credits (Schedule 3)
    final credits = _calculateCredits(agi, totalTaxBeforeCredits);
    
    // Step 10: Calculate total tax
    final totalTax = max(0, totalTaxBeforeCredits - credits.nonrefundable);
    
    // Step 11: Calculate payments
    final payments = _calculatePayments() + credits.refundable;
    
    // Step 12: Calculate refund or amount owed
    final refundOrOwed = payments - totalTax;
    
    return TaxCalculationResult(
      totalIncome: totalIncome,
      adjustments: adjustments,
      agi: agi,
      deduction: deduction,
      taxableIncome: taxableIncome,
      baseTax: baseTax,
      otherTaxes: otherTaxes,
      nonrefundableCredits: credits.nonrefundable,
      refundableCredits: credits.refundable,
      totalTax: totalTax,
      totalPayments: payments,
      refundOrOwed: refundOrOwed,
    );
  }
  
  // Calculate total income from all sources
  double _calculateTotalIncome() {
    double total = 0;
    
    // Wages (Form 1040 Line 1)
    total += taxReturn.w2Forms.fold(0.0, (sum, w2) => sum + w2.box1Wages);
    
    // Interest (Line 2b)
    total += taxReturn.interestIncome.taxable;
    
    // Dividends (Line 3b)
    total += taxReturn.dividendIncome.ordinary;
    
    // IRA distributions (Line 4b)
    total += taxReturn.iraDistributions.taxable;
    
    // Pensions/annuities (Line 5b)
    total += taxReturn.pensionIncome.taxable;
    
    // Social Security (Line 6b)
    total += _calculateTaxableSocialSecurity();
    
    // Capital gains (Line 7)
    total += taxReturn.capitalGains.netGain;
    
    // Schedule 1 Additional Income (Line 8)
    total += _calculateSchedule1Income();
    
    return total;
  }
  
  // Schedule 1 Part I - Additional Income
  double _calculateSchedule1Income() {
    double total = 0;
    
    // Line 1: Taxable refunds
    total += taxReturn.taxableStateRefunds;
    
    // Line 2a: Alimony received (pre-2019 divorces)
    total += taxReturn.alimonyReceived;
    
    // Line 3: Business income (Schedule C)
    total += taxReturn.businessIncome;
    
    // Line 4: Other gains (Form 4797)
    total += taxReturn.otherGains;
    
    // Line 5: Rental real estate (Schedule E)
    total += taxReturn.rentalIncome;
    
    // Line 6: Farm income (Schedule F)
    total += taxReturn.farmIncome;
    
    // Line 7: Unemployment compensation
    total += taxReturn.unemploymentComp;
    
    // Line 8: Other income
    total += taxReturn.otherIncome;
    
    return total;
  }
  
  // Schedule 1 Part II - Adjustments
  double _calculateAdjustments() {
    double total = 0;
    
    // Line 11: Educator expenses (max $300)
    total += min(taxReturn.educatorExpenses, 300);
    
    // Line 12: Reserved
    
    // Line 13: Health savings account
    total += taxReturn.hsaDeduction;
    
    // Line 14: Moving expenses (armed forces)
    total += taxReturn.movingExpenses;
    
    // Line 15: Self-employed deductions
    total += taxReturn.selfEmployedDeductions;
    
    // Line 16: Self-employed SEP/SIMPLE/qualified plans
    total += taxReturn.sepSimpleDeduction;
    
    // Line 17: Self-employed health insurance
    total += taxReturn.selfEmployedHealthInsurance;
    
    // Line 18: Penalty on early withdrawal of savings
    total += taxReturn.earlyWithdrawalPenalty;
    
    // Line 19: Alimony paid (pre-2019 divorces)
    total += taxReturn.alimonyPaid;
    
    // Line 20: IRA deduction
    total += _calculateIRADeduction();
    
    // Line 21: Student loan interest (max $2,500)
    total += min(taxReturn.studentLoanInterest, 2500);
    
    return total;
  }
  
  // IRA Deduction calculation
  double _calculateIRADeduction() {
    // Complex calculation based on:
    // - Filing status
    // - Modified AGI
    // - Retirement plan coverage
    // - Contribution amount
    
    final contribution = taxReturn.iraContribution;
    if (contribution == 0) return 0;
    
    final maxContribution = taxReturn.taxpayer.is50OrOlder ? 8000 : 7000;
    final allowedContribution = min(contribution, maxContribution);
    
    // Check if covered by retirement plan
    final coveredByPlan = taxReturn.w2Forms.any((w2) => w2.retirementPlan);
    
    if (!coveredByPlan) {
      return allowedContribution; // Full deduction
    }
    
    // Phase-out calculation based on filing status and MAGI
    // ... implementation details
    
    return allowedContribution;
  }
  
  // Calculate deduction (standard vs itemized)
  double _calculateDeduction(double agi) {
    final standardDeduction = _getStandardDeduction();
    final itemizedDeduction = _calculateItemizedDeduction(agi);
    
    // For most taxpayers, take the larger deduction
    // Exception: MFS where spouse itemizes
    if (taxReturn.filingStatus == FilingStatus.marriedFilingSeparately &&
        taxReturn.spouseItemizes) {
      return itemizedDeduction;
    }
    
    return max(standardDeduction, itemizedDeduction);
  }
  
  // Standard deduction with adjustments
  double _getStandardDeduction() {
    double base;
    
    switch (taxReturn.filingStatus) {
      case FilingStatus.single:
        base = 14600;
        break;
      case FilingStatus.marriedFilingJointly:
      case FilingStatus.qualifyingSurvivingSpouse:
        base = 29200;
        break;
      case FilingStatus.marriedFilingSeparately:
        base = 14600;
        break;
      case FilingStatus.headOfHousehold:
        base = 21900;
        break;
    }
    
    // Additional amounts for 65+/blind
    double additional = 0;
    const additionalSingle = 1950;
    const additionalMarried = 1550;
    
    if (taxReturn.filingStatus == FilingStatus.single ||
        taxReturn.filingStatus == FilingStatus.headOfHousehold) {
      if (taxReturn.taxpayer.is65OrOlder) additional += additionalSingle;
      if (taxReturn.taxpayer.isBlind) additional += additionalSingle;
    } else {
      if (taxReturn.taxpayer.is65OrOlder) additional += additionalMarried;
      if (taxReturn.taxpayer.isBlind) additional += additionalMarried;
      if (taxReturn.spouse?.is65OrOlder ?? false) additional += additionalMarried;
      if (taxReturn.spouse?.isBlind ?? false) additional += additionalMarried;
    }
    
    return base + additional;
  }
  
  // Itemized deduction (Schedule A)
  double _calculateItemizedDeduction(double agi) {
    final scheduleA = taxReturn.scheduleA;
    if (scheduleA == null) return 0;
    
    double total = 0;
    
    // Line 4: Medical expenses exceeding 7.5% of AGI
    final medicalFloor = agi * 0.075;
    total += max(0, scheduleA.medicalExpenses - medicalFloor);
    
    // Line 5-7: Taxes (SALT cap $10,000)
    final saltTotal = scheduleA.stateTaxes + 
                      scheduleA.localTaxes +
                      scheduleA.propertyTaxes;
    total += min(saltTotal, 10000);
    
    // Line 8-10: Interest
    total += scheduleA.homeMortgageInterest;
    total += scheduleA.investmentInterest;
    
    // Line 11-14: Gifts to charity
    total += _calculateCharitableDeduction(agi, scheduleA);
    
    // Line 15: Casualty/theft losses (federally declared disaster only)
    total += scheduleA.casualtyLosses;
    
    // Line 16: Other itemized deductions
    total += scheduleA.otherDeductions;
    
    return total;
  }
  
  // Charitable deduction with AGI limits
  double _calculateCharitableDeduction(double agi, ScheduleA scheduleA) {
    // Cash contributions limited to 60% of AGI
    // Non-cash contributions limited to 30% of AGI
    // Capital gain property to 50% organizations limited to 30%
    
    final cashLimit = agi * 0.60;
    final nonCashLimit = agi * 0.30;
    
    final cashDeduction = min(scheduleA.charitableCash, cashLimit);
    final nonCashDeduction = min(scheduleA.charitableNonCash, nonCashLimit);
    
    return cashDeduction + nonCashDeduction;
  }
  
  // Calculate tax from brackets
  double _calculateTaxFromBrackets(double taxableIncome) {
    if (taxableIncome <= 0) return 0;
    
    final brackets = _getBrackets();
    double tax = 0;
    double remainingIncome = taxableIncome;
    
    for (final bracket in brackets) {
      if (remainingIncome <= 0) break;
      
      final taxableInBracket = min(
        remainingIncome,
        bracket.max - bracket.min,
      );
      
      tax += taxableInBracket * bracket.rate;
      remainingIncome -= taxableInBracket;
    }
    
    return tax;
  }
  
  List<TaxBracket> _getBrackets() {
    switch (taxReturn.filingStatus) {
      case FilingStatus.single:
        return singleBrackets2024;
      case FilingStatus.marriedFilingJointly:
      case FilingStatus.qualifyingSurvivingSpouse:
        return mfjBrackets2024;
      case FilingStatus.headOfHousehold:
        return hohBrackets2024;
      case FilingStatus.marriedFilingSeparately:
        return mfsBrackets2024;
    }
  }
  
  // Schedule 2 - Other taxes
  double _calculateOtherTaxes() {
    double total = 0;
    
    // Alternative minimum tax
    total += _calculateAMT();
    
    // Self-employment tax
    total += _calculateSelfEmploymentTax();
    
    // Unreported Social Security/Medicare
    total += taxReturn.unreportedTips;
    
    // Additional Medicare tax (0.9% on wages over $200k single)
    total += _calculateAdditionalMedicareTax();
    
    // Net investment income tax (3.8%)
    total += _calculateNIIT();
    
    // Early distribution penalty (10%)
    total += _calculateEarlyDistributionPenalty();
    
    return total;
  }
  
  // Self-employment tax calculation
  double _calculateSelfEmploymentTax() {
    final selfEmploymentIncome = taxReturn.businessIncome;
    if (selfEmploymentIncome <= 0) return 0;
    
    // Calculate 92.35% of net self-employment earnings
    final netEarnings = selfEmploymentIncome * 0.9235;
    
    // Social Security portion (12.4% up to wage base)
    const sswageBase = 168600;
    final wagesForSS = taxReturn.w2Forms.fold(0.0, (sum, w2) => sum + w2.socialSecurityWages);
    final ssRemaining = max(0, sswageBase - wagesForSS);
    final ssTax = min(netEarnings, ssRemaining) * 0.124;
    
    // Medicare portion (2.9% on all earnings)
    final medicareTax = netEarnings * 0.029;
    
    return ssTax + medicareTax;
  }
  
  // Calculate credits
  TaxCredits _calculateCredits(double agi, double taxBeforeCredits) {
    double nonrefundable = 0;
    double refundable = 0;
    
    // Child Tax Credit (partially refundable)
    final ctc = _calculateChildTaxCredit(agi, taxBeforeCredits);
    nonrefundable += ctc.nonrefundable;
    refundable += ctc.refundable;
    
    // Credit for Other Dependents
    nonrefundable += _calculateOtherDependentCredit(agi);
    
    // Earned Income Credit (refundable)
    refundable += _calculateEIC(agi);
    
    // Education credits
    final education = _calculateEducationCredits(agi, taxBeforeCredits);
    nonrefundable += education.nonrefundable;
    refundable += education.refundable;
    
    // Child and Dependent Care Credit
    nonrefundable += _calculateCDCC(agi, taxBeforeCredits);
    
    // Retirement Savings Credit
    nonrefundable += _calculateSaversCredit(agi, taxBeforeCredits);
    
    // Foreign Tax Credit
    nonrefundable += min(taxReturn.foreignTaxPaid, taxBeforeCredits);
    
    // Residential energy credits
    nonrefundable += _calculateEnergyCredits();
    
    // Limit nonrefundable credits to tax liability
    nonrefundable = min(nonrefundable, taxBeforeCredits);
    
    return TaxCredits(
      nonrefundable: nonrefundable,
      refundable: refundable,
    );
  }
  
  // Child Tax Credit calculation
  ChildTaxCreditResult _calculateChildTaxCredit(double agi, double taxLiability) {
    final qualifyingChildren = taxReturn.dependents
        .where((d) => d.eligibleForCTC)
        .length;
    
    if (qualifyingChildren == 0) {
      return ChildTaxCreditResult(nonrefundable: 0, refundable: 0);
    }
    
    // $2,000 per qualifying child
    double creditPerChild = 2000;
    double totalCredit = qualifyingChildren * creditPerChild;
    
    // Phase-out calculation
    double threshold;
    switch (taxReturn.filingStatus) {
      case FilingStatus.marriedFilingJointly:
        threshold = 400000;
        break;
      default:
        threshold = 200000;
    }
    
    if (agi > threshold) {
      final excess = agi - threshold;
      final reduction = (excess / 1000).ceil() * 50;
      totalCredit = max(0, totalCredit - reduction);
    }
    
    // Split between refundable and nonrefundable
    final nonrefundable = min(totalCredit, taxLiability);
    
    // Additional CTC (refundable portion)
    // Limited to 15% of earned income over $2,500
    final earnedIncome = _calculateEarnedIncome();
    final potentialRefundable = max(0, (earnedIncome - 2500) * 0.15);
    final maxRefundable = min(1700, creditPerChild) * qualifyingChildren; // $1,700 per child
    final refundable = min(
      min(potentialRefundable, maxRefundable),
      totalCredit - nonrefundable,
    );
    
    return ChildTaxCreditResult(
      nonrefundable: nonrefundable,
      refundable: refundable,
    );
  }
  
  // Earned Income Credit calculation
  double _calculateEIC(double agi) {
    // Complex calculation based on:
    // - Filing status
    // - Number of qualifying children
    // - Earned income
    // - Investment income limit ($11,600 for 2024)
    
    if (taxReturn.investmentIncome > 11600) return 0;
    
    final earnedIncome = _calculateEarnedIncome();
    final qualifyingChildren = taxReturn.dependents
        .where((d) => d.eligibleForEIC)
        .length;
    
    // Look up in EIC tables based on filing status,
    // number of children, and income
    
    return _lookupEIC(
      filingStatus: taxReturn.filingStatus,
      qualifyingChildren: qualifyingChildren,
      earnedIncome: earnedIncome,
      agi: agi,
    );
  }
  
  double _lookupEIC({
    required FilingStatus filingStatus,
    required int qualifyingChildren,
    required double earnedIncome,
    required double agi,
  }) {
    // EIC phase-in, plateau, and phase-out ranges for 2024
    // Simplified - actual implementation uses IRS tables
    
    if (qualifyingChildren == 0) {
      // Max credit: $632
      // Phase-out starts: $9,800 (S/HoH) or $16,370 (MFJ)
      return 0; // Simplified
    } else if (qualifyingChildren == 1) {
      // Max credit: $4,213
      // Phase-out starts: $22,720 (S/HoH) or $29,290 (MFJ)
      return 0;
    } else if (qualifyingChildren == 2) {
      // Max credit: $6,960
      // Phase-out starts: $22,720 (S/HoH) or $29,290 (MFJ)
      return 0;
    } else {
      // 3+ children
      // Max credit: $7,830
      // Phase-out starts: $22,720 (S/HoH) or $29,290 (MFJ)
      return 0;
    }
  }
  
  // Calculate total payments/withholding
  double _calculatePayments() {
    double total = 0;
    
    // Federal income tax withheld from W-2s
    total += taxReturn.w2Forms.fold(
      0.0, 
      (sum, w2) => sum + w2.federalIncomeTaxWithheld,
    );
    
    // Federal tax withheld from 1099s
    total += taxReturn.form1099Int.fold(
      0.0,
      (sum, f) => sum + f.federalTaxWithheld,
    );
    total += taxReturn.form1099Div.fold(
      0.0,
      (sum, f) => sum + f.federalTaxWithheld,
    );
    total += taxReturn.form1099R.fold(
      0.0,
      (sum, f) => sum + f.federalTaxWithheld,
    );
    
    // Estimated tax payments
    total += taxReturn.estimatedTaxPayments;
    
    // Amount applied from prior year
    total += taxReturn.priorYearOverpayment;
    
    // Amount paid with extension
    total += taxReturn.extensionPayment;
    
    return total;
  }
  
  // Helper: Calculate earned income
  double _calculateEarnedIncome() {
    double earned = 0;
    
    // W-2 wages
    earned += taxReturn.w2Forms.fold(0.0, (sum, w2) => sum + w2.box1Wages);
    
    // Self-employment income (if positive)
    earned += max(0, taxReturn.businessIncome);
    
    // Combat pay election
    earned += taxReturn.combatPay;
    
    return earned;
  }
}
```

### 3.2 Data Models

```dart
class TaxBracket {
  final double min;
  final double max;
  final double rate;
  
  const TaxBracket({
    required this.min,
    required this.max,
    required this.rate,
  });
}

class TaxCalculationResult {
  final double totalIncome;
  final double adjustments;
  final double agi;
  final double deduction;
  final double taxableIncome;
  final double baseTax;
  final double otherTaxes;
  final double nonrefundableCredits;
  final double refundableCredits;
  final double totalTax;
  final double totalPayments;
  final double refundOrOwed;
  
  bool get isRefund => refundOrOwed > 0;
  bool get isOwed => refundOrOwed < 0;
  double get refundAmount => isRefund ? refundOrOwed : 0;
  double get amountOwed => isOwed ? -refundOrOwed : 0;
  
  const TaxCalculationResult({
    required this.totalIncome,
    required this.adjustments,
    required this.agi,
    required this.deduction,
    required this.taxableIncome,
    required this.baseTax,
    required this.otherTaxes,
    required this.nonrefundableCredits,
    required this.refundableCredits,
    required this.totalTax,
    required this.totalPayments,
    required this.refundOrOwed,
  });
}

class TaxCredits {
  final double nonrefundable;
  final double refundable;
  
  double get total => nonrefundable + refundable;
  
  const TaxCredits({
    required this.nonrefundable,
    required this.refundable,
  });
}

class ChildTaxCreditResult {
  final double nonrefundable;
  final double refundable;
  
  const ChildTaxCreditResult({
    required this.nonrefundable,
    required this.refundable,
  });
}
```

---

## 4. Form 1040 Line Mappings

```dart
// Form 1040 line-by-line mapping
class Form1040LineMapper {
  static Map<String, dynamic> mapToForm1040(TaxCalculationResult result, TaxReturnModel taxReturn) {
    return {
      // Income Section
      'line1a': taxReturn.w2TotalWages,                    // Wages
      'line1b': taxReturn.householdEmployerWages,          // Household employee wages
      'line1c': taxReturn.tipNotReported,                  // Tip income not reported
      'line1d': taxReturn.medicaidWaiverPayments,          // Medicaid waiver
      'line1e': taxReturn.dependentCareBenefits,           // Dependent care (taxable)
      'line1f': taxReturn.adoptionBenefits,                // Adoption benefits
      'line1g': taxReturn.form8919Wages,                   // Wages Form 8919
      'line1h': taxReturn.otherEarnedIncome,               // Other earned income
      'line1i': taxReturn.nontaxableCombatPay,             // Combat pay election
      'line1z': result.totalIncome,                        // Total income line 1
      
      'line2a': taxReturn.taxExemptInterest,               // Tax-exempt interest
      'line2b': taxReturn.taxableInterest,                 // Taxable interest
      
      'line3a': taxReturn.qualifiedDividends,              // Qualified dividends
      'line3b': taxReturn.ordinaryDividends,               // Ordinary dividends
      
      'line4a': taxReturn.iraDistributionsTotal,           // IRA distributions
      'line4b': taxReturn.iraDistributionsTaxable,         // Taxable amount
      
      'line5a': taxReturn.pensionsTotal,                   // Pensions and annuities
      'line5b': taxReturn.pensionsTaxable,                 // Taxable amount
      
      'line6a': taxReturn.socialSecurityTotal,             // Social Security
      'line6b': taxReturn.socialSecurityTaxable,           // Taxable amount
      
      'line7': taxReturn.capitalGainOrLoss,                // Capital gain/loss
      
      'line8': taxReturn.schedule1Line10,                  // Additional income
      
      'line9': result.totalIncome,                         // Total income
      
      'line10': result.adjustments,                        // Adjustments to income
      
      'line11': result.agi,                                // AGI
      
      'line12': result.deduction,                          // Standard/itemized deduction
      
      'line13': taxReturn.qbidDeduction,                   // Qualified business income
      
      'line14': result.taxableIncome,                      // Taxable income
      
      // Tax and Credits
      'line16': result.baseTax,                            // Tax
      'line17': taxReturn.schedule2Line3,                  // Amount from Schedule 2
      'line18': result.baseTax + result.otherTaxes,        // Total tax before credits
      
      'line19': taxReturn.childDependentCareCredit,        // Child/dependent care
      'line20': taxReturn.educationCredits,                // Education credits
      'line21': taxReturn.schedule3Line8,                  // Other credits
      'line22': result.nonrefundableCredits,               // Total credits
      
      'line23': 0,                                         // Reserved
      
      'line24': result.totalTax,                           // Total tax
      
      // Payments
      'line25a': taxReturn.w2FederalWithholding,           // W-2 withholding
      'line25b': taxReturn.form1099Withholding,            // 1099 withholding
      'line25c': taxReturn.otherWithholding,               // Other withholding
      'line25d': taxReturn.totalWithholding,               // Total withholding
      
      'line26': taxReturn.estimatedTaxPayments,            // Estimated tax payments
      
      'line27': result.refundableCredits,                  // Earned income credit
      'line28': taxReturn.additionalChildTaxCredit,        // Additional CTC
      'line29': taxReturn.americanOpportunityCredit,       // AOTC refundable
      'line30': 0,                                         // Reserved
      'line31': taxReturn.schedule3Line15,                 // Other refundable credits
      'line32': 0,                                         // Reserved
      
      'line33': result.totalPayments,                      // Total payments
      
      // Refund or Amount Owed
      'line34': result.refundAmount,                       // Overpayment
      'line35a': taxReturn.refundAmount,                   // Refund amount
      'line35b': taxReturn.routingNumber,                  // Direct deposit routing
      'line35c': taxReturn.accountType,                    // Checking/savings
      'line35d': taxReturn.accountNumber,                  // Account number
      
      'line36': taxReturn.appliedToNextYear,               // Applied to next year
      
      'line37': result.amountOwed,                         // Amount you owe
      'line38': taxReturn.estimatedTaxPenalty,             // Estimated tax penalty
    };
  }
}
```

---

## 5. Validation Rules

### 5.1 Business Rules Implementation

```dart
class TaxCalculationValidator {
  final TaxReturnModel taxReturn;
  final TaxCalculationResult result;
  
  List<ValidationError> validate() {
    final errors = <ValidationError>[];
    
    // Rule: Social Security wages cannot exceed wage base
    for (final w2 in taxReturn.w2Forms) {
      if (w2.socialSecurityWages > 168600) {
        errors.add(ValidationError(
          code: 'SS_WAGES_EXCEED_LIMIT',
          message: 'Social Security wages exceed annual limit',
          field: 'w2.socialSecurityWages',
        ));
      }
    }
    
    // Rule: AGI must be non-negative for most calculations
    // (Can be negative in loss situations)
    
    // Rule: Taxable income cannot exceed AGI
    if (result.taxableIncome > result.agi) {
      errors.add(ValidationError(
        code: 'TAXABLE_EXCEEDS_AGI',
        message: 'Taxable income cannot exceed AGI',
        field: 'taxableIncome',
      ));
    }
    
    // Rule: Credits cannot exceed tax liability (for nonrefundable)
    // Already handled in calculation
    
    // Rule: EIC has specific qualification requirements
    // ... more rules
    
    return errors;
  }
}

class ValidationError {
  final String code;
  final String message;
  final String? field;
  final String? suggestedFix;
  
  const ValidationError({
    required this.code,
    required this.message,
    this.field,
    this.suggestedFix,
  });
}
```

---

## 6. Testing Requirements

### 6.1 Test Cases

```dart
// Tax calculation test cases
void main() {
  group('Tax Calculation Tests', () {
    test('Single filer with W-2 only', () {
      final taxReturn = TaxReturnModel(
        filingStatus: FilingStatus.single,
        w2Forms: [
          W2Model(box1Wages: 50000, federalIncomeTaxWithheld: 5000),
        ],
      );
      
      final result = TaxCalculator(taxYear: 2024, taxReturn: taxReturn).calculate();
      
      expect(result.totalIncome, equals(50000));
      expect(result.agi, equals(50000));
      expect(result.deduction, equals(14600)); // Standard deduction
      expect(result.taxableIncome, equals(35400));
      // Tax on 35,400: 10% of 11,600 + 12% of 23,800 = 4,016
      expect(result.baseTax, closeTo(4016, 1));
    });
    
    test('MFJ with children and CTC', () {
      // Test married filing jointly with child tax credit
    });
    
    test('Self-employed with Schedule C', () {
      // Test self-employment income and tax
    });
    
    test('EIC eligibility', () {
      // Test earned income credit calculation
    });
  });
}
```

---

## 7. Related Documents

- [Tax Forms](./tax_forms.md)
- [Income Sources](./income_sources.md)
- [Deductions & Credits](./deductions_credits.md)
- [Testing & Validation](./testing_validation.md)
