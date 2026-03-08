# IRS Tax Forms Implementation

## Overview

This document details the implementation specifications for IRS tax forms required for e-file compliance, including Form 1040, related schedules, and supporting forms.

---

## 1. Form 1040 - Individual Income Tax Return

### 1.1 Form Structure

```dart
class Form1040 {
  final String taxYear;
  final FilingStatus filingStatus;
  
  // Personal Information
  final TaxpayerInfo primaryTaxpayer;
  final TaxpayerInfo? spouse;
  final bool presidentialCampaignFund;
  final bool spousePresidentialCampaignFund;
  
  // Digital Assets Question (Required since 2022)
  final bool receivedDigitalAssets;
  
  // Dependents
  final List<Dependent> dependents;
  
  // Income Section (Lines 1-11)
  final IncomeSection income;
  
  // Adjustments (Line 11 - from Schedule 1)
  final double adjustmentsToIncome;
  
  // AGI (Line 11)
  final double adjustedGrossIncome;
  
  // Deductions (Lines 12-14)
  final DeductionSection deductions;
  
  // Taxable Income (Line 15)
  final double taxableIncome;
  
  // Tax & Credits (Lines 16-24)
  final TaxSection tax;
  
  // Payments (Lines 25-33)
  final PaymentsSection payments;
  
  // Refund or Amount Owed (Lines 34-38)
  final RefundOrOwedSection refundOrOwed;
  
  // Third Party Designee
  final ThirdPartyDesignee? designee;
  
  // Signatures
  final SignatureSection signatures;
  
  const Form1040({
    required this.taxYear,
    required this.filingStatus,
    required this.primaryTaxpayer,
    this.spouse,
    this.presidentialCampaignFund = false,
    this.spousePresidentialCampaignFund = false,
    this.receivedDigitalAssets = false,
    this.dependents = const [],
    required this.income,
    this.adjustmentsToIncome = 0,
    required this.adjustedGrossIncome,
    required this.deductions,
    required this.taxableIncome,
    required this.tax,
    required this.payments,
    required this.refundOrOwed,
    this.designee,
    required this.signatures,
  });
}
```

### 1.2 Income Section

```dart
class IncomeSection {
  // Line 1 - Wages, salaries, tips
  final double wages;                    // Line 1a
  final double householdEmployeeWages;   // Line 1b
  final double tipIncomeNotOnW2;         // Line 1c
  final double medicaidWaiverPayments;   // Line 1d
  final double employerDependentCare;    // Line 1e
  final double adoptionBenefits;         // Line 1f
  final double form8919Wages;            // Line 1g
  final double otherEarnedIncome;        // Line 1h
  final double nontaxableCombatPay;      // Line 1i (election)
  final double totalWages;               // Line 1z
  
  // Line 2 - Interest
  final double taxExemptInterest;        // Line 2a
  final double taxableInterest;          // Line 2b
  
  // Line 3 - Dividends
  final double qualifiedDividends;       // Line 3a
  final double ordinaryDividends;        // Line 3b
  
  // Line 4 - IRA Distributions
  final double iraDistributionsGross;    // Line 4a
  final double iraDistributionsTaxable;  // Line 4b
  
  // Line 5 - Pensions and Annuities
  final double pensionsGross;            // Line 5a
  final double pensionsTaxable;          // Line 5b
  
  // Line 6 - Social Security
  final double socialSecurityGross;      // Line 6a
  final double socialSecurityTaxable;    // Line 6b
  
  // Line 7 - Capital Gains
  final double capitalGainOrLoss;        // Line 7
  
  // Line 8 - Additional Income from Schedule 1
  final double schedule1AdditionalIncome; // Line 8
  
  // Line 9 - Total Income
  final double totalIncome;              // Line 9
  
  const IncomeSection({
    this.wages = 0,
    this.householdEmployeeWages = 0,
    this.tipIncomeNotOnW2 = 0,
    this.medicaidWaiverPayments = 0,
    this.employerDependentCare = 0,
    this.adoptionBenefits = 0,
    this.form8919Wages = 0,
    this.otherEarnedIncome = 0,
    this.nontaxableCombatPay = 0,
    this.totalWages = 0,
    this.taxExemptInterest = 0,
    this.taxableInterest = 0,
    this.qualifiedDividends = 0,
    this.ordinaryDividends = 0,
    this.iraDistributionsGross = 0,
    this.iraDistributionsTaxable = 0,
    this.pensionsGross = 0,
    this.pensionsTaxable = 0,
    this.socialSecurityGross = 0,
    this.socialSecurityTaxable = 0,
    this.capitalGainOrLoss = 0,
    this.schedule1AdditionalIncome = 0,
    this.totalIncome = 0,
  });
  
  double calculateTotalWages() {
    return wages + householdEmployeeWages + tipIncomeNotOnW2 +
           medicaidWaiverPayments + employerDependentCare + 
           adoptionBenefits + form8919Wages + otherEarnedIncome;
  }
  
  double calculateTotalIncome() {
    return totalWages + taxableInterest + ordinaryDividends +
           iraDistributionsTaxable + pensionsTaxable + 
           socialSecurityTaxable + capitalGainOrLoss + 
           schedule1AdditionalIncome;
  }
}
```

### 1.3 Deduction Section

```dart
class DeductionSection {
  final bool itemizingDeductions;
  
  // Line 12 - Standard Deduction or Itemized Deductions
  final double standardDeduction;      // Line 12a (if not itemizing)
  final double charitableCashDonation; // Line 12b (non-itemizers up to $300/$600)
  final double itemizedDeductions;     // Line 12 (from Schedule A)
  
  // Line 13 - Qualified Business Income Deduction
  final double qbiDeduction;           // Line 13
  
  // Line 14 - Total Deductions
  final double totalDeductions;        // Line 14
  
  const DeductionSection({
    this.itemizingDeductions = false,
    this.standardDeduction = 0,
    this.charitableCashDonation = 0,
    this.itemizedDeductions = 0,
    this.qbiDeduction = 0,
    this.totalDeductions = 0,
  });
  
  // 2024 Standard Deduction amounts
  static double getStandardDeduction({
    required FilingStatus filingStatus,
    required int age,
    required bool isBlind,
    int? spouseAge,
    bool spouseIsBlind = false,
  }) {
    double base = switch (filingStatus) {
      FilingStatus.single => 14600,
      FilingStatus.marriedFilingJointly => 29200,
      FilingStatus.marriedFilingSeparately => 14600,
      FilingStatus.headOfHousehold => 21900,
      FilingStatus.qualifyingSurvivingSpouse => 29200,
    };
    
    // Additional amount for age 65+ or blind
    double additional = switch (filingStatus) {
      FilingStatus.single || 
      FilingStatus.headOfHousehold => 1950,
      _ => 1550,
    };
    
    // Primary taxpayer additions
    if (age >= 65) base += additional;
    if (isBlind) base += additional;
    
    // Spouse additions (MFJ only)
    if (filingStatus == FilingStatus.marriedFilingJointly ||
        filingStatus == FilingStatus.qualifyingSurvivingSpouse) {
      if (spouseAge != null && spouseAge >= 65) base += additional;
      if (spouseIsBlind) base += additional;
    }
    
    return base;
  }
}
```

### 1.4 Tax Section

```dart
class TaxSection {
  // Line 16 - Tax
  final double tax;                      // Line 16 (from Tax Table/computation)
  
  // Line 17 - Amount from Schedule 2, line 3
  final double schedule2Line3;           // Line 17
  
  // Line 18 - Add lines 16 and 17
  final double totalTax;                 // Line 18
  
  // Line 19 - Child Tax Credit / Credit for Other Dependents
  final double childTaxCredit;           // Line 19
  
  // Line 20 - Amount from Schedule 3, line 8
  final double schedule3Line8;           // Line 20
  
  // Line 21 - Add lines 19 and 20
  final double totalCredits;             // Line 21
  
  // Line 22 - Subtract line 21 from line 18
  final double taxAfterCredits;          // Line 22
  
  // Line 23 - Other taxes from Schedule 2
  final double otherTaxes;               // Line 23
  
  // Line 24 - Total Tax
  final double totalTaxDue;              // Line 24
  
  const TaxSection({
    this.tax = 0,
    this.schedule2Line3 = 0,
    this.totalTax = 0,
    this.childTaxCredit = 0,
    this.schedule3Line8 = 0,
    this.totalCredits = 0,
    this.taxAfterCredits = 0,
    this.otherTaxes = 0,
    this.totalTaxDue = 0,
  });
}
```

### 1.5 Payments Section

```dart
class PaymentsSection {
  // Line 25 - Federal Tax Withheld
  final double federalWithholding;       // Line 25a (from W-2s)
  final double form1099Withholding;      // Line 25b
  final double otherWithholding;         // Line 25c
  final double totalWithholding;         // Line 25d
  
  // Line 26 - Estimated Tax Payments
  final double estimatedTaxPayments;     // Line 26
  
  // Line 27 - Earned Income Credit
  final double earnedIncomeCredit;       // Line 27
  final double nontaxableCombatPayUsed;  // Line 27a (if elected)
  final double priorYearEarnedIncome;    // Line 27b (if elected)
  
  // Line 28 - Additional Child Tax Credit
  final double additionalChildTaxCredit; // Line 28
  
  // Line 29 - American Opportunity Credit
  final double americanOpportunityCredit; // Line 29
  
  // Line 30 - Reserved
  
  // Line 31 - Amount from Schedule 3, line 15
  final double schedule3Line15;          // Line 31
  
  // Line 32 - Add lines 27, 28, 29, 31
  final double refundableCredits;        // Line 32
  
  // Line 33 - Total Payments
  final double totalPayments;            // Line 33
  
  const PaymentsSection({
    this.federalWithholding = 0,
    this.form1099Withholding = 0,
    this.otherWithholding = 0,
    this.totalWithholding = 0,
    this.estimatedTaxPayments = 0,
    this.earnedIncomeCredit = 0,
    this.nontaxableCombatPayUsed = 0,
    this.priorYearEarnedIncome = 0,
    this.additionalChildTaxCredit = 0,
    this.americanOpportunityCredit = 0,
    this.schedule3Line15 = 0,
    this.refundableCredits = 0,
    this.totalPayments = 0,
  });
}
```

### 1.6 Refund/Amount Owed Section

```dart
class RefundOrOwedSection {
  // Line 34 - Overpayment (if payments > tax)
  final double overpayment;              // Line 34
  
  // Line 35 - Amount to be refunded
  final double refundAmount;             // Line 35a
  final BankAccountInfo? directDeposit;  // Lines 35b, 35c, 35d
  
  // Line 36 - Applied to next year's estimated tax
  final double appliedToNextYear;        // Line 36
  
  // Line 37 - Amount Owed
  final double amountOwed;               // Line 37
  
  // Line 38 - Estimated Tax Penalty
  final double estimatedTaxPenalty;      // Line 38
  
  const RefundOrOwedSection({
    this.overpayment = 0,
    this.refundAmount = 0,
    this.directDeposit,
    this.appliedToNextYear = 0,
    this.amountOwed = 0,
    this.estimatedTaxPenalty = 0,
  });
}

class BankAccountInfo {
  final String routingNumber;        // Line 35b
  final BankAccountType accountType; // Line 35c
  final String accountNumber;        // Line 35d
  
  const BankAccountInfo({
    required this.routingNumber,
    required this.accountType,
    required this.accountNumber,
  });
}

enum BankAccountType { checking, savings }
```

---

## 2. Schedule 1 - Additional Income and Adjustments

### 2.1 Part I - Additional Income

```dart
class Schedule1 {
  // Part I - Additional Income
  final double taxableRefunds;           // Line 1
  final double alimonyReceived;          // Line 2a
  final String? alimonyPayerSSN;         // Line 2b
  final double businessIncome;           // Line 3 (from Schedule C)
  final double otherGainsLosses;         // Line 4 (from Form 4797)
  final double rentalRealEstate;         // Line 5 (from Schedule E)
  final double farmIncome;               // Line 6 (from Schedule F)
  final double unemploymentCompensation; // Line 7
  final double otherIncome;              // Line 8 (combined 8a-8z)
  
  // Lines 8a-8z Details
  final double netOperatingLoss;         // Line 8a
  final double gamblingIncome;           // Line 8b
  final double cancellationOfDebt;       // Line 8c
  final double foreignEarnedIncome;      // Line 8d
  final double taxableHSADistributions;  // Line 8e
  final double alaskaDividend;           // Line 8f
  final double juryDutyPay;              // Line 8g
  final double prizeAwards;              // Line 8h
  final double activityNotForProfit;     // Line 8i
  final double stockOptions;             // Line 8j
  final double incomeFromESPP;           // Line 8k
  final double excessGoldenParachute;    // Line 8l
  final double excessRothDistribution;   // Line 8m
  final double interestSection1341;      // Line 8n
  final double otherIncomeDescriptions;  // Line 8z
  
  final double totalAdditionalIncome;    // Line 10
  
  // Part II - Adjustments to Income
  final double educatorExpenses;         // Line 11
  final double businessExpensesReservists; // Line 12
  final double hsaDeduction;             // Line 13
  final double movingExpenses;           // Line 14
  final double selfEmploymentTaxDeduction; // Line 15
  final double selfEmployedSEPSimple;    // Line 16
  final double selfEmployedHealthInsurance; // Line 17
  final double penaltyEarlyWithdrawal;   // Line 18
  final double alimonyPaid;              // Line 19a
  final String? alimonyRecipientSSN;     // Line 19b
  final double iraDeduction;             // Line 20
  final double studentLoanInterest;      // Line 21
  final double reservedLine22;           // Line 22 (reserved)
  final double archerMSADeduction;       // Line 23
  final double otherAdjustments;         // Line 24 (combined 24a-24z)
  
  final double totalAdjustments;         // Line 26
  
  const Schedule1({
    this.taxableRefunds = 0,
    this.alimonyReceived = 0,
    this.alimonyPayerSSN,
    this.businessIncome = 0,
    this.otherGainsLosses = 0,
    this.rentalRealEstate = 0,
    this.farmIncome = 0,
    this.unemploymentCompensation = 0,
    this.otherIncome = 0,
    this.netOperatingLoss = 0,
    this.gamblingIncome = 0,
    this.cancellationOfDebt = 0,
    this.foreignEarnedIncome = 0,
    this.taxableHSADistributions = 0,
    this.alaskaDividend = 0,
    this.juryDutyPay = 0,
    this.prizeAwards = 0,
    this.activityNotForProfit = 0,
    this.stockOptions = 0,
    this.incomeFromESPP = 0,
    this.excessGoldenParachute = 0,
    this.excessRothDistribution = 0,
    this.interestSection1341 = 0,
    this.otherIncomeDescriptions = 0,
    this.totalAdditionalIncome = 0,
    this.educatorExpenses = 0,
    this.businessExpensesReservists = 0,
    this.hsaDeduction = 0,
    this.movingExpenses = 0,
    this.selfEmploymentTaxDeduction = 0,
    this.selfEmployedSEPSimple = 0,
    this.selfEmployedHealthInsurance = 0,
    this.penaltyEarlyWithdrawal = 0,
    this.alimonyPaid = 0,
    this.alimonyRecipientSSN,
    this.iraDeduction = 0,
    this.studentLoanInterest = 0,
    this.reservedLine22 = 0,
    this.archerMSADeduction = 0,
    this.otherAdjustments = 0,
    this.totalAdjustments = 0,
  });
}
```

---

## 3. Schedule 2 - Additional Taxes

```dart
class Schedule2 {
  // Part I - Tax
  final double alternativeMinimumTax;    // Line 1
  final double excessAdvancePremiumCredit; // Line 2
  final double partITotal;               // Line 3
  
  // Part II - Other Taxes
  final double selfEmploymentTax;        // Line 4
  final double unreportedSocialSecurity; // Line 5
  final double additionalMedicare;       // Line 6
  final double additionalTaxIRAs;        // Line 7
  final double householdEmploymentTax;   // Line 8
  final double repaymentFirstTimeBuyer;  // Line 9
  final double netInvestmentIncomeTax;   // Line 10 (3.8% NIIT)
  final double uncollectedSocialSecurity; // Line 11
  final double interestSection409A;      // Line 12
  final double additionalTaxQualifiedPlans; // Line 13
  final double recaptureTaxes;           // Line 14
  final double section965Installment;    // Line 15
  final double otherAdditionalTaxes;     // Line 16
  final double reservedLine17;           // Line 17
  final double totalOtherTaxes;          // Line 18
  final double totalAdditionalTaxes;     // Line 19
  
  const Schedule2({
    this.alternativeMinimumTax = 0,
    this.excessAdvancePremiumCredit = 0,
    this.partITotal = 0,
    this.selfEmploymentTax = 0,
    this.unreportedSocialSecurity = 0,
    this.additionalMedicare = 0,
    this.additionalTaxIRAs = 0,
    this.householdEmploymentTax = 0,
    this.repaymentFirstTimeBuyer = 0,
    this.netInvestmentIncomeTax = 0,
    this.uncollectedSocialSecurity = 0,
    this.interestSection409A = 0,
    this.additionalTaxQualifiedPlans = 0,
    this.recaptureTaxes = 0,
    this.section965Installment = 0,
    this.otherAdditionalTaxes = 0,
    this.reservedLine17 = 0,
    this.totalOtherTaxes = 0,
    this.totalAdditionalTaxes = 0,
  });
}
```

---

## 4. Schedule 3 - Additional Credits and Payments

```dart
class Schedule3 {
  // Part I - Nonrefundable Credits
  final double foreignTaxCredit;         // Line 1
  final double childDependentCareCredit; // Line 2
  final double educationCredits;         // Line 3
  final double retirementSavingsCredit;  // Line 4
  final double energyCredits;            // Line 5
  final double otherNonrefundableCredits; // Line 6
  final double totalNonrefundableCredits; // Line 8
  
  // Part II - Other Payments and Refundable Credits
  final double netPremiumTaxCredit;      // Line 9
  final double amountPaidWithExtension;  // Line 10
  final double excessSocialSecurity;     // Line 11
  final double creditForFederalFuel;     // Line 12
  final double otherPaymentsCredits;     // Line 13
  final double totalOtherPayments;       // Line 15
  
  const Schedule3({
    this.foreignTaxCredit = 0,
    this.childDependentCareCredit = 0,
    this.educationCredits = 0,
    this.retirementSavingsCredit = 0,
    this.energyCredits = 0,
    this.otherNonrefundableCredits = 0,
    this.totalNonrefundableCredits = 0,
    this.netPremiumTaxCredit = 0,
    this.amountPaidWithExtension = 0,
    this.excessSocialSecurity = 0,
    this.creditForFederalFuel = 0,
    this.otherPaymentsCredits = 0,
    this.totalOtherPayments = 0,
  });
}
```

---

## 5. Schedule A - Itemized Deductions

```dart
class ScheduleA {
  // Medical and Dental Expenses
  final double medicalDentalExpenses;    // Line 1
  final double agiAmount;                // Line 2
  final double medicalThreshold;         // Line 3 (7.5% of AGI)
  final double deductibleMedical;        // Line 4
  
  // Taxes You Paid
  final double stateLocalIncomeTax;      // Line 5a
  final double stateLocalSalesTax;       // Line 5b (alternative)
  final double realEstateTax;            // Line 5c
  final double personalPropertyTax;      // Line 5d
  final double totalStateTaxes;          // Line 5e (limited to $10,000)
  final double otherTaxes;               // Line 6
  final double totalTaxesPaid;           // Line 7
  
  // Interest You Paid
  final double homeMortgageInterest;     // Line 8a
  final double homeMortgageNotReported;  // Line 8b
  final double points;                   // Line 8c
  final double mortgageInsurance;        // Line 8d
  final double investmentInterest;       // Line 9
  final double totalInterest;            // Line 10
  
  // Gifts to Charity
  final double charityCash;              // Line 11
  final double charityNonCash;           // Line 12
  final double charityCarryover;         // Line 13
  final double totalCharity;             // Line 14
  
  // Casualty and Theft Losses
  final double casualtyTheftLoss;        // Line 15
  
  // Other Itemized Deductions
  final double otherDeductions;          // Line 16
  
  // Total Itemized Deductions
  final double totalItemizedDeductions;  // Line 17
  
  const ScheduleA({
    this.medicalDentalExpenses = 0,
    this.agiAmount = 0,
    this.medicalThreshold = 0,
    this.deductibleMedical = 0,
    this.stateLocalIncomeTax = 0,
    this.stateLocalSalesTax = 0,
    this.realEstateTax = 0,
    this.personalPropertyTax = 0,
    this.totalStateTaxes = 0,
    this.otherTaxes = 0,
    this.totalTaxesPaid = 0,
    this.homeMortgageInterest = 0,
    this.homeMortgageNotReported = 0,
    this.points = 0,
    this.mortgageInsurance = 0,
    this.investmentInterest = 0,
    this.totalInterest = 0,
    this.charityCash = 0,
    this.charityNonCash = 0,
    this.charityCarryover = 0,
    this.totalCharity = 0,
    this.casualtyTheftLoss = 0,
    this.otherDeductions = 0,
    this.totalItemizedDeductions = 0,
  });
  
  // Calculate total itemized deductions
  double calculate() {
    final saltCapped = min(totalStateTaxes, 10000); // SALT cap
    
    return deductibleMedical + 
           saltCapped + 
           otherTaxes +
           totalInterest +
           totalCharity +
           casualtyTheftLoss +
           otherDeductions;
  }
}
```

---

## 6. Schedule B - Interest and Ordinary Dividends

```dart
class ScheduleB {
  // Part I - Interest
  final List<InterestEntry> interestEntries;  // Lines 1
  final double totalInterest;                  // Line 2
  final double excludableSavingsBond;          // Line 3
  final double reportableInterest;             // Line 4
  
  // Part II - Ordinary Dividends
  final List<DividendEntry> dividendEntries;  // Lines 5
  final double totalDividends;                 // Line 6
  
  // Part III - Foreign Accounts and Trusts
  final bool hasForeignAccount;                // Line 7a
  final String? foreignAccountCountry;         // Line 7b
  final bool hasForeignTrust;                  // Line 8
  
  const ScheduleB({
    this.interestEntries = const [],
    this.totalInterest = 0,
    this.excludableSavingsBond = 0,
    this.reportableInterest = 0,
    this.dividendEntries = const [],
    this.totalDividends = 0,
    this.hasForeignAccount = false,
    this.foreignAccountCountry,
    this.hasForeignTrust = false,
  });
}

class InterestEntry {
  final String payerName;
  final double amount;
  
  const InterestEntry({required this.payerName, required this.amount});
}

class DividendEntry {
  final String payerName;
  final double amount;
  
  const DividendEntry({required this.payerName, required this.amount});
}
```

---

## 7. Schedule C - Profit or Loss from Business

```dart
class ScheduleC {
  // Business Info
  final String businessName;
  final String principalBusinessCode;    // NAICS code
  final String? ein;
  final String businessAddress;
  final AccountingMethod accountingMethod;
  final bool participatedMaterially;
  final bool startedThisYear;
  final bool madePaymentsRequiring1099;
  final bool filed1099s;
  
  // Part I - Income
  final double grossReceipts;            // Line 1
  final double returns;                  // Line 2
  final double netReceipts;              // Line 3
  final double costOfGoodsSold;          // Line 4
  final double grossProfit;              // Line 5
  final double otherIncome;              // Line 6
  final double grossIncome;              // Line 7
  
  // Part II - Expenses
  final double advertising;              // Line 8
  final double carTruckExpenses;         // Line 9
  final double commissions;              // Line 10
  final double contractLabor;            // Line 11
  final double depletion;                // Line 12
  final double depreciation;             // Line 13
  final double employeeBenefit;          // Line 14
  final double insurance;                // Line 15
  final double interestMortgage;         // Line 16a
  final double interestOther;            // Line 16b
  final double legalProfessional;        // Line 17
  final double officeExpense;            // Line 18
  final double pensionProfit;            // Line 19
  final double rentVehicles;             // Line 20a
  final double rentOther;                // Line 20b
  final double repairs;                  // Line 21
  final double supplies;                 // Line 22
  final double taxes;                    // Line 23
  final double travel;                   // Line 24a
  final double meals;                    // Line 24b (50% deductible)
  final double utilities;                // Line 25
  final double wages;                    // Line 26
  final double otherExpenses;            // Line 27a
  final double totalExpenses;            // Line 28
  
  // Net Profit or Loss
  final double tentativeProfit;          // Line 29
  final double homeOfficeExpenses;       // Line 30 (from Form 8829)
  final double netProfitOrLoss;          // Line 31
  
  // At-Risk & Passive Activity Rules
  final bool allAtRisk;                  // Line 32a
  
  const ScheduleC({
    required this.businessName,
    required this.principalBusinessCode,
    this.ein,
    required this.businessAddress,
    this.accountingMethod = AccountingMethod.cash,
    this.participatedMaterially = true,
    this.startedThisYear = false,
    this.madePaymentsRequiring1099 = false,
    this.filed1099s = false,
    this.grossReceipts = 0,
    this.returns = 0,
    this.netReceipts = 0,
    this.costOfGoodsSold = 0,
    this.grossProfit = 0,
    this.otherIncome = 0,
    this.grossIncome = 0,
    this.advertising = 0,
    this.carTruckExpenses = 0,
    this.commissions = 0,
    this.contractLabor = 0,
    this.depletion = 0,
    this.depreciation = 0,
    this.employeeBenefit = 0,
    this.insurance = 0,
    this.interestMortgage = 0,
    this.interestOther = 0,
    this.legalProfessional = 0,
    this.officeExpense = 0,
    this.pensionProfit = 0,
    this.rentVehicles = 0,
    this.rentOther = 0,
    this.repairs = 0,
    this.supplies = 0,
    this.taxes = 0,
    this.travel = 0,
    this.meals = 0,
    this.utilities = 0,
    this.wages = 0,
    this.otherExpenses = 0,
    this.totalExpenses = 0,
    this.tentativeProfit = 0,
    this.homeOfficeExpenses = 0,
    this.netProfitOrLoss = 0,
    this.allAtRisk = true,
  });
}

enum AccountingMethod { cash, accrual, other }
```

---

## 8. Schedule D - Capital Gains and Losses

```dart
class ScheduleD {
  // Part I - Short-Term Capital Gains and Losses
  final List<CapitalTransaction> shortTermFromForm8949;  // Line 1a-1b
  final double shortTermCarryover;                        // Line 6
  final double netShortTermGainLoss;                      // Line 7
  
  // Part II - Long-Term Capital Gains and Losses
  final List<CapitalTransaction> longTermFromForm8949;   // Line 8a-8b
  final double longTermCarryover;                         // Line 14
  final double netLongTermGainLoss;                       // Line 15
  
  // Part III - Summary
  final double combinedGainLoss;                          // Line 16
  final bool qualifiedDividendWorksheet;                  // Line 17 checkbox
  final bool scheduleD28Percent;                          // Line 18 checkbox
  final bool scheduleDTaxWorksheet;                       // Line 19 checkbox
  final double capitalLossCarryover;                      // Line 21
  
  const ScheduleD({
    this.shortTermFromForm8949 = const [],
    this.shortTermCarryover = 0,
    this.netShortTermGainLoss = 0,
    this.longTermFromForm8949 = const [],
    this.longTermCarryover = 0,
    this.netLongTermGainLoss = 0,
    this.combinedGainLoss = 0,
    this.qualifiedDividendWorksheet = false,
    this.scheduleD28Percent = false,
    this.scheduleDTaxWorksheet = false,
    this.capitalLossCarryover = 0,
  });
  
  // Max capital loss deduction is $3,000 ($1,500 MFS)
  double getDeductibleLoss(FilingStatus status) {
    if (combinedGainLoss >= 0) return 0;
    
    final maxLoss = status == FilingStatus.marriedFilingSeparately 
        ? 1500.0 
        : 3000.0;
    
    return min(combinedGainLoss.abs(), maxLoss);
  }
}

class CapitalTransaction {
  final String description;
  final DateTime? dateAcquired;
  final DateTime dateSold;
  final double proceeds;
  final double costBasis;
  final double adjustment;
  final double gainOrLoss;
  final Form8949Code code;
  
  CapitalTransaction({
    required this.description,
    this.dateAcquired,
    required this.dateSold,
    required this.proceeds,
    required this.costBasis,
    this.adjustment = 0,
    required this.gainOrLoss,
    required this.code,
  });
  
  bool get isShortTerm {
    if (dateAcquired == null) return false;
    return dateSold.difference(dateAcquired!).inDays <= 365;
  }
}

enum Form8949Code {
  A, // Short-term, basis reported to IRS
  B, // Short-term, basis NOT reported
  C, // Short-term, no 1099-B
  D, // Long-term, basis reported to IRS
  E, // Long-term, basis NOT reported
  F, // Long-term, no 1099-B
}
```

---

## 9. Schedule E - Supplemental Income and Loss

```dart
class ScheduleE {
  // Part I - Rental Real Estate and Royalties
  final List<RentalProperty> properties;
  
  // Part II - Partnerships and S Corporations (K-1s)
  final List<PartnershipK1> partnerships;
  final List<SCorporationK1> sCorporations;
  
  // Part III - Estates and Trusts
  final List<EstateTrustK1> estateTrusts;
  
  // Part IV - Real Estate Mortgage Investment Conduits (REMICs)
  final List<RemicIncome> remics;
  
  // Part V - Summary
  final double totalNetIncome;
  final double totalNetLoss;
  final double netRentalIncome;
  
  const ScheduleE({
    this.properties = const [],
    this.partnerships = const [],
    this.sCorporations = const [],
    this.estateTrusts = const [],
    this.remics = const [],
    this.totalNetIncome = 0,
    this.totalNetLoss = 0,
    this.netRentalIncome = 0,
  });
}

class RentalProperty {
  final String propertyAddress;
  final PropertyType propertyType;
  final int fairRentalDays;
  final int personalUseDays;
  final bool qbiDeductionApplies;
  
  // Income
  final double rentsReceived;
  final double royaltiesReceived;
  
  // Expenses
  final double advertising;
  final double auto;
  final double cleaning;
  final double commissions;
  final double insurance;
  final double legalProfessional;
  final double management;
  final double mortgageInterest;
  final double otherInterest;
  final double repairs;
  final double supplies;
  final double taxes;
  final double utilities;
  final double depreciation;
  final double other;
  
  final double totalExpenses;
  final double netIncomeLoss;
  
  RentalProperty({
    required this.propertyAddress,
    required this.propertyType,
    this.fairRentalDays = 0,
    this.personalUseDays = 0,
    this.qbiDeductionApplies = false,
    this.rentsReceived = 0,
    this.royaltiesReceived = 0,
    this.advertising = 0,
    this.auto = 0,
    this.cleaning = 0,
    this.commissions = 0,
    this.insurance = 0,
    this.legalProfessional = 0,
    this.management = 0,
    this.mortgageInterest = 0,
    this.otherInterest = 0,
    this.repairs = 0,
    this.supplies = 0,
    this.taxes = 0,
    this.utilities = 0,
    this.depreciation = 0,
    this.other = 0,
    this.totalExpenses = 0,
    this.netIncomeLoss = 0,
  });
}

enum PropertyType {
  singleFamily,
  multiFamily,
  vacation,
  commercial,
  land,
  royalties,
  selfRental,
  other,
}
```

---

## 10. Form Requirement Matrix

| Scenario | Required Forms |
|----------|---------------|
| W-2 income only | Form 1040 |
| W-2 + Interest > $1,500 | Form 1040, Schedule B |
| W-2 + Self-employment | Form 1040, Schedule 1, Schedule C, Schedule SE |
| Itemizing deductions | Form 1040, Schedule A |
| Capital gains/losses | Form 1040, Schedule D, Form 8949 |
| Rental property | Form 1040, Schedule E |
| Educator expenses | Form 1040, Schedule 1 |
| Student loan interest | Form 1040, Schedule 1 |
| EIC claimed | Form 1040, Schedule EIC |
| Child tax credit | Form 1040, Schedule 8812 |
| Education credits | Form 1040, Form 8863 |

---

## 11. Implementation Checklist

- [ ] Implement Form1040 model
- [ ] Implement Schedule 1 model
- [ ] Implement Schedule 2 model
- [ ] Implement Schedule 3 model
- [ ] Implement Schedule A model
- [ ] Implement Schedule B model
- [ ] Implement Schedule C model
- [ ] Implement Schedule D model
- [ ] Implement Schedule E model
- [ ] Create form validators
- [ ] Build form requirement logic
- [ ] Create XML generators for each form

---

## 12. Related Documents

- [Calculations](./calculations.md)
- [Income Sources](./income_sources.md)
- [Deductions & Credits](./deductions_credits.md)
- [E-File Transmission](./efile_transmission.md)
