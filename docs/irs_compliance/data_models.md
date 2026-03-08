# Consolidated Data Models

## Overview

This document provides a comprehensive reference of all data models required for IRS e-file compliance, their relationships, and database schema mappings.

---

## 1. Entity Relationship Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│      User       │────<│   Tax Return    │────<│  State Return   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        │                       │                       │
        ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│Identity Verify  │     │     Income      │     │State Withholding│
└─────────────────┘     │    Documents    │     └─────────────────┘
                        │  (W2, 1099, etc)│
                        └─────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Dependents    │     │   Deductions    │     │    Credits      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                │
                                ▼
                        ┌─────────────────┐
                        │   Signatures    │
                        │    & Consent    │
                        └─────────────────┘
                                │
                                ▼
                        ┌─────────────────┐
                        │  E-File Trans   │
                        │   & Ack         │
                        └─────────────────┘
```

---

## 2. Core Domain Models

### 2.1 User & Authentication

```dart
/// User profile with tax-specific information
class TaxUser {
  final String id;
  final String email;
  final String? phone;
  final UserProfile profile;
  final IdentityVerificationStatus identityStatus;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  
  const TaxUser({
    required this.id,
    required this.email,
    this.phone,
    required this.profile,
    required this.identityStatus,
    required this.createdAt,
    required this.lastLoginAt,
  });
}

class UserProfile {
  final String firstName;
  final String middleName;
  final String lastName;
  final String? suffix;          // Jr, Sr, III, etc.
  final String ssn;              // Encrypted
  final DateTime dateOfBirth;
  final Address address;
  final String? occupation;
  
  const UserProfile({
    required this.firstName,
    this.middleName = '',
    required this.lastName,
    this.suffix,
    required this.ssn,
    required this.dateOfBirth,
    required this.address,
    this.occupation,
  });
  
  String get fullName {
    final parts = [firstName, middleName, lastName, suffix]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.join(' ');
  }
  
  String get legalName => '$firstName $lastName${suffix != null ? ' $suffix' : ''}';
}

class Address {
  final String street1;
  final String? street2;
  final String city;
  final String state;
  final String zipCode;
  final String? zipPlus4;
  final String country;
  
  const Address({
    required this.street1,
    this.street2,
    required this.city,
    required this.state,
    required this.zipCode,
    this.zipPlus4,
    this.country = 'US',
  });
  
  String get fullZip => zipPlus4 != null ? '$zipCode-$zipPlus4' : zipCode;
  
  String get formattedAddress {
    final lines = [
      street1,
      if (street2 != null && street2!.isNotEmpty) street2!,
      '$city, $state $fullZip',
    ];
    return lines.join('\n');
  }
  
  Map<String, dynamic> toXml() => {
    'AddressLine1Txt': street1,
    if (street2 != null) 'AddressLine2Txt': street2,
    'CityNm': city,
    'StateAbbreviationCd': state,
    'ZIPCd': zipCode,
  };
}
```

### 2.2 Tax Return Master

```dart
/// Main tax return entity
class TaxReturn {
  final String id;
  final String oderId;
  final int taxYear;
  final FilingStatus filingStatus;
  final ReturnStatus status;
  
  // Taxpayer Info
  final TaxpayerInfo primaryTaxpayer;
  final TaxpayerInfo? spouse;
  final List<Dependent> dependents;
  
  // Income
  final IncomeData income;
  
  // Adjustments
  final AdjustmentsToIncome adjustments;
  
  // Deductions
  final DeductionData deductions;
  
  // Credits
  final CreditData credits;
  
  // Tax Calculation
  final TaxCalculation taxCalculation;
  
  // Payments
  final PaymentData payments;
  
  // Refund/Balance Due
  final RefundData refund;
  
  // Signatures
  final SignatureData? signatures;
  
  // E-File
  final EFileStatus? eFileStatus;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? preparedBy;
  
  const TaxReturn({
    required this.id,
    required this.oderId,
    required this.taxYear,
    required this.filingStatus,
    required this.status,
    required this.primaryTaxpayer,
    this.spouse,
    this.dependents = const [],
    required this.income,
    required this.adjustments,
    required this.deductions,
    required this.credits,
    required this.taxCalculation,
    required this.payments,
    required this.refund,
    this.signatures,
    this.eFileStatus,
    required this.createdAt,
    required this.updatedAt,
    this.preparedBy,
  });
}

enum FilingStatus {
  single,
  marriedFilingJointly,
  marriedFilingSeparately,
  headOfHousehold,
  qualifyingWidow,
}

enum ReturnStatus {
  notStarted,
  inProgress,
  readyForReview,
  readyToFile,
  submitted,
  accepted,
  rejected,
  amended,
}

class TaxpayerInfo {
  final String firstName;
  final String middleInitial;
  final String lastName;
  final String? suffix;
  final String ssn;                    // Encrypted
  final DateTime dateOfBirth;
  final Address address;
  final String? occupation;
  final String? ipPin;                 // Identity Protection PIN
  final String? priorYearAGI;
  final String? priorYearSelfSelectPIN;
  
  const TaxpayerInfo({
    required this.firstName,
    this.middleInitial = '',
    required this.lastName,
    this.suffix,
    required this.ssn,
    required this.dateOfBirth,
    required this.address,
    this.occupation,
    this.ipPin,
    this.priorYearAGI,
    this.priorYearSelfSelectPIN,
  });
}
```

### 2.3 Dependent

```dart
class Dependent {
  final String id;
  final String firstName;
  final String middleInitial;
  final String lastName;
  final String? suffix;
  final String ssn;
  final DateTime dateOfBirth;
  final DependentRelationship relationship;
  final int monthsLivedWithTaxpayer;
  
  // Qualifying criteria
  final bool qualifiesForChildTaxCredit;
  final bool qualifiesForEIC;
  final bool qualifiesForChildCare;
  final bool qualifiesForOtherDependent;
  final bool isStudent;
  final bool isDisabled;
  
  // Income (if any)
  final double? grossIncome;
  
  const Dependent({
    required this.id,
    required this.firstName,
    this.middleInitial = '',
    required this.lastName,
    this.suffix,
    required this.ssn,
    required this.dateOfBirth,
    required this.relationship,
    required this.monthsLivedWithTaxpayer,
    this.qualifiesForChildTaxCredit = false,
    this.qualifiesForEIC = false,
    this.qualifiesForChildCare = false,
    this.qualifiesForOtherDependent = false,
    this.isStudent = false,
    this.isDisabled = false,
    this.grossIncome,
  });
  
  int getAge(int taxYear) => taxYear - dateOfBirth.year;
  
  bool isQualifyingChildForCTC(int taxYear) {
    return getAge(taxYear) < 17 && monthsLivedWithTaxpayer >= 6;
  }
}

enum DependentRelationship {
  son,
  daughter,
  stepson,
  stepdaughter,
  fosterChild,
  brother,
  sister,
  halfBrother,
  halfSister,
  stepbrother,
  stepsister,
  grandchild,
  niece,
  nephew,
  parent,
  grandparent,
  aunt,
  uncle,
  other,
}
```

---

## 3. Income Models

### 3.1 Income Data Container

```dart
class IncomeData {
  // Wages & Employment
  final List<W2Form> w2s;
  final double totalWages;
  
  // Interest
  final List<Form1099INT> form1099ints;
  final double taxableInterest;
  final double taxExemptInterest;
  
  // Dividends
  final List<Form1099DIV> form1099divs;
  final double ordinaryDividends;
  final double qualifiedDividends;
  
  // Business Income
  final List<ScheduleC> scheduleCs;
  final double netBusinessIncome;
  
  // Capital Gains
  final List<Form1099B> form1099bs;
  final double shortTermGains;
  final double longTermGains;
  
  // Rental Income
  final List<ScheduleE> scheduleEs;
  final double netRentalIncome;
  
  // Retirement
  final List<Form1099R> form1099rs;
  final double taxableIRADistributions;
  final double taxablePensions;
  final double socialSecurityBenefits;
  final double taxableSocialSecurity;
  
  // Other Income
  final List<Form1099MISC> form1099miscs;
  final List<Form1099NEC> form1099necs;
  final List<Form1099G> form1099gs;
  final List<ScheduleK1> scheduleK1s;
  final double otherIncome;
  
  // Totals (Form 1040)
  final double totalIncome;        // Line 9
  
  const IncomeData({
    this.w2s = const [],
    this.totalWages = 0,
    this.form1099ints = const [],
    this.taxableInterest = 0,
    this.taxExemptInterest = 0,
    this.form1099divs = const [],
    this.ordinaryDividends = 0,
    this.qualifiedDividends = 0,
    this.scheduleCs = const [],
    this.netBusinessIncome = 0,
    this.form1099bs = const [],
    this.shortTermGains = 0,
    this.longTermGains = 0,
    this.scheduleEs = const [],
    this.netRentalIncome = 0,
    this.form1099rs = const [],
    this.taxableIRADistributions = 0,
    this.taxablePensions = 0,
    this.socialSecurityBenefits = 0,
    this.taxableSocialSecurity = 0,
    this.form1099miscs = const [],
    this.form1099necs = const [],
    this.form1099gs = const [],
    this.scheduleK1s = const [],
    this.otherIncome = 0,
    this.totalIncome = 0,
  });
}
```

### 3.2 W-2 Model

```dart
class W2Form {
  final String id;
  final String employerEIN;
  final String employerName;
  final Address employerAddress;
  final String? controlNumber;
  
  // Boxes 1-20
  final double box1Wages;                    // Wages, tips, other comp
  final double box2FederalWithheld;          // Federal income tax withheld
  final double box3SocialSecurityWages;      // Social security wages
  final double box4SocialSecurityTax;        // Social security tax withheld
  final double box5MedicareWages;            // Medicare wages
  final double box6MedicareTax;              // Medicare tax withheld
  final double box7SocialSecurityTips;       // Social security tips
  final double box8AllocatedTips;            // Allocated tips
  // Box 9 is blank
  final double box10DependentCareBenefits;   // Dependent care benefits
  final double box11NonqualifiedPlans;       // Nonqualified plans
  final List<Box12Entry> box12;              // See codes A-HH
  final bool box13StatutoryEmployee;
  final bool box13RetirementPlan;
  final bool box13ThirdPartySickPay;
  final String? box14Other;                   // Other
  
  // State & Local (boxes 15-20)
  final String? stateCode;
  final String? stateEmployerID;
  final double? stateWages;
  final double? stateIncomeTax;
  final String? localityName;
  final double? localWages;
  final double? localIncomeTax;
  
  const W2Form({
    required this.id,
    required this.employerEIN,
    required this.employerName,
    required this.employerAddress,
    this.controlNumber,
    required this.box1Wages,
    required this.box2FederalWithheld,
    required this.box3SocialSecurityWages,
    required this.box4SocialSecurityTax,
    required this.box5MedicareWages,
    required this.box6MedicareTax,
    this.box7SocialSecurityTips = 0,
    this.box8AllocatedTips = 0,
    this.box10DependentCareBenefits = 0,
    this.box11NonqualifiedPlans = 0,
    this.box12 = const [],
    this.box13StatutoryEmployee = false,
    this.box13RetirementPlan = false,
    this.box13ThirdPartySickPay = false,
    this.box14Other,
    this.stateCode,
    this.stateEmployerID,
    this.stateWages,
    this.stateIncomeTax,
    this.localityName,
    this.localWages,
    this.localIncomeTax,
  });
}

class Box12Entry {
  final String code;   // A through HH
  final double amount;
  
  const Box12Entry({required this.code, required this.amount});
  
  String get description => _box12Codes[code] ?? 'Unknown';
  
  static const _box12Codes = {
    'A': 'Uncollected Social Security or RRTA tax on tips',
    'B': 'Uncollected Medicare tax on tips',
    'C': 'Taxable cost of group-term life insurance over \$50,000',
    'D': 'Elective deferrals to a 401(k)',
    'E': 'Elective deferrals to a 403(b)',
    'F': 'Elective deferrals to a 408(k)(6) SEP',
    'G': 'Elective deferrals to a 457(b)',
    'H': 'Elective deferrals to a 501(c)(18)(D)',
    'J': 'Nontaxable sick pay',
    'K': '20% excise tax on excess golden parachute payments',
    'L': 'Substantiated employee business expense reimbursements',
    'M': 'Uncollected Social Security or RRTA tax on group-term life',
    'N': 'Uncollected Medicare tax on group-term life',
    'P': 'Excludable moving expense reimbursements paid to armed forces',
    'Q': 'Nontaxable combat pay',
    'R': 'Employer contributions to Archer MSA',
    'S': 'Employee salary reduction to SIMPLE',
    'T': 'Adoption benefits',
    'V': 'Income from exercise of nonstatutory stock options',
    'W': 'Employer contributions to HSA',
    'Y': 'Deferrals under 409A nonqualified deferred compensation',
    'Z': 'Income under 409A nonqualified deferred compensation',
    'AA': 'Designated Roth contributions to 401(k)',
    'BB': 'Designated Roth contributions to 403(b)',
    'DD': 'Cost of employer-sponsored health coverage',
    'EE': 'Designated Roth contributions to governmental 457(b)',
    'FF': 'Permitted benefits under QSEHRA',
    'GG': 'Income from qualified equity grants under 83(i)',
    'HH': 'Aggregate deferrals under 83(i)',
  };
}
```

---

## 4. Deduction & Credit Models

### 4.1 Deductions

```dart
class DeductionData {
  final DeductionType deductionType;
  final double standardDeduction;
  final ItemizedDeductions? itemizedDeductions;
  final double qualifiedBusinessIncome;  // Section 199A
  final double totalDeductions;
  
  const DeductionData({
    required this.deductionType,
    required this.standardDeduction,
    this.itemizedDeductions,
    this.qualifiedBusinessIncome = 0,
    required this.totalDeductions,
  });
}

enum DeductionType { standard, itemized }

class ItemizedDeductions {
  // Schedule A
  final double medicalExpenses;
  final double medicalExpensesAllowed;  // After 7.5% AGI threshold
  
  // State & Local Taxes (SALT - capped at $10,000)
  final double stateIncomeTax;
  final double realEstateTax;
  final double personalPropertyTax;
  final double saltTotal;              // Capped
  
  // Interest
  final double homeMortgageInterest;
  final double investmentInterest;
  
  // Charitable
  final double charitableCash;
  final double charitableNonCash;
  final double charitableCarryover;
  final double charitableTotal;
  
  // Casualty & Theft
  final double casualtyLoss;           // Federally declared disasters only
  
  // Other
  final double otherDeductions;
  
  final double totalItemized;
  
  const ItemizedDeductions({
    this.medicalExpenses = 0,
    this.medicalExpensesAllowed = 0,
    this.stateIncomeTax = 0,
    this.realEstateTax = 0,
    this.personalPropertyTax = 0,
    this.saltTotal = 0,
    this.homeMortgageInterest = 0,
    this.investmentInterest = 0,
    this.charitableCash = 0,
    this.charitableNonCash = 0,
    this.charitableCarryover = 0,
    this.charitableTotal = 0,
    this.casualtyLoss = 0,
    this.otherDeductions = 0,
    required this.totalItemized,
  });
}
```

### 4.2 Credits

```dart
class CreditData {
  // Nonrefundable Credits
  final double childTaxCredit;
  final double creditForOtherDependents;
  final double childAndDependentCareCredit;
  final double educationCredits;
  final double retirementSavingsCredit;
  final double residentialEnergyCredit;
  final double foreignTaxCredit;
  final double otherNonrefundableCredits;
  final double totalNonrefundable;
  
  // Refundable Credits
  final double earnedIncomeCredit;
  final double additionalChildTaxCredit;
  final double americanOpportunityRefundable;
  final double premiumTaxCredit;
  final double otherRefundableCredits;
  final double totalRefundable;
  
  // Schedule 8812 Detail
  final Schedule8812? schedule8812;
  
  // Schedule EIC Detail
  final ScheduleEIC? scheduleEIC;
  
  const CreditData({
    this.childTaxCredit = 0,
    this.creditForOtherDependents = 0,
    this.childAndDependentCareCredit = 0,
    this.educationCredits = 0,
    this.retirementSavingsCredit = 0,
    this.residentialEnergyCredit = 0,
    this.foreignTaxCredit = 0,
    this.otherNonrefundableCredits = 0,
    this.totalNonrefundable = 0,
    this.earnedIncomeCredit = 0,
    this.additionalChildTaxCredit = 0,
    this.americanOpportunityRefundable = 0,
    this.premiumTaxCredit = 0,
    this.otherRefundableCredits = 0,
    this.totalRefundable = 0,
    this.schedule8812,
    this.scheduleEIC,
  });
}

class Schedule8812 {
  final int qualifyingChildrenCount;
  final double creditAmount;
  final double additionalCreditAmount;
  final double totalCredit;
  
  const Schedule8812({
    required this.qualifyingChildrenCount,
    required this.creditAmount,
    required this.additionalCreditAmount,
    required this.totalCredit,
  });
}

class ScheduleEIC {
  final List<EICChild> qualifyingChildren;
  final double earnedIncome;
  final double creditAmount;
  
  const ScheduleEIC({
    required this.qualifyingChildren,
    required this.earnedIncome,
    required this.creditAmount,
  });
}

class EICChild {
  final String name;
  final String ssn;
  final DateTime dateOfBirth;
  final String relationship;
  final int monthsLived;
  
  const EICChild({
    required this.name,
    required this.ssn,
    required this.dateOfBirth,
    required this.relationship,
    required this.monthsLived,
  });
}
```

---

## 5. Tax Calculation & Payment Models

### 5.1 Tax Calculation

```dart
class TaxCalculation {
  // Income
  final double totalIncome;           // Line 9
  final double adjustmentsToIncome;   // Line 10
  final double agi;                   // Line 11
  final double deductions;            // Line 12
  final double taxableIncome;         // Line 15
  
  // Tax
  final double taxFromTables;         // Line 16 (or Schedule D)
  final double additionalTaxes;       // Schedule 2, Part I
  final double totalTax;              // Line 18
  
  // Credits
  final double totalCredits;          // Line 21
  final double taxAfterCredits;       // Line 22
  
  // Other Taxes
  final double otherTaxes;            // Schedule 2, Part II
  final double totalTaxLiability;     // Line 24
  
  const TaxCalculation({
    required this.totalIncome,
    required this.adjustmentsToIncome,
    required this.agi,
    required this.deductions,
    required this.taxableIncome,
    required this.taxFromTables,
    this.additionalTaxes = 0,
    required this.totalTax,
    required this.totalCredits,
    required this.taxAfterCredits,
    this.otherTaxes = 0,
    required this.totalTaxLiability,
  });
}
```

### 5.2 Payments

```dart
class PaymentData {
  final double federalWithholding;       // From W-2s
  final double estimatedTaxPayments;     // Form 1040-ES
  final double appliedFromPriorYear;     // Overpayment applied
  final double excessSocialSecurity;     // Multiple employers
  final double additionalPayments;       // Other payments
  final double refundableCredits;        // EIC, ACTC, etc.
  final double totalPayments;
  
  const PaymentData({
    required this.federalWithholding,
    this.estimatedTaxPayments = 0,
    this.appliedFromPriorYear = 0,
    this.excessSocialSecurity = 0,
    this.additionalPayments = 0,
    required this.refundableCredits,
    required this.totalPayments,
  });
}
```

---

## 6. Database Schema Summary

```sql
-- All tables in logical order

-- 1. Users & Auth (handled by Supabase Auth)
-- Reference: auth.users

-- 2. User Profiles
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  first_name TEXT NOT NULL,
  middle_name TEXT,
  last_name TEXT NOT NULL,
  suffix TEXT,
  ssn_encrypted BYTEA NOT NULL,
  ssn_last_four TEXT NOT NULL,
  date_of_birth DATE NOT NULL,
  street1 TEXT NOT NULL,
  street2 TEXT,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  zip_code TEXT NOT NULL,
  zip_plus4 TEXT,
  phone TEXT,
  occupation TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Identity Verifications
CREATE TABLE identity_verifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  verification_method TEXT NOT NULL,
  verification_status TEXT NOT NULL DEFAULT 'pending',
  provider_session_id TEXT,
  result JSONB,
  verified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Tax Returns (Master)
CREATE TABLE tax_returns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  tax_year INTEGER NOT NULL,
  filing_status TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'not_started',
  
  -- Calculated fields
  total_income DECIMAL(12,2) DEFAULT 0,
  agi DECIMAL(12,2) DEFAULT 0,
  taxable_income DECIMAL(12,2) DEFAULT 0,
  total_tax DECIMAL(12,2) DEFAULT 0,
  total_payments DECIMAL(12,2) DEFAULT 0,
  refund_or_owed DECIMAL(12,2) DEFAULT 0,
  
  -- E-file
  submission_id TEXT,
  submitted_at TIMESTAMPTZ,
  accepted_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, tax_year)
);

-- 5. Taxpayer Info
CREATE TABLE taxpayer_info (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  taxpayer_type TEXT NOT NULL, -- 'primary' or 'spouse'
  first_name TEXT NOT NULL,
  middle_initial TEXT,
  last_name TEXT NOT NULL,
  suffix TEXT,
  ssn_encrypted BYTEA NOT NULL,
  date_of_birth DATE NOT NULL,
  occupation TEXT,
  ip_pin_encrypted BYTEA,
  prior_year_agi_encrypted BYTEA,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Dependents
CREATE TABLE dependents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  first_name TEXT NOT NULL,
  middle_initial TEXT,
  last_name TEXT NOT NULL,
  suffix TEXT,
  ssn_encrypted BYTEA NOT NULL,
  date_of_birth DATE NOT NULL,
  relationship TEXT NOT NULL,
  months_lived INTEGER NOT NULL,
  qualifies_ctc BOOLEAN DEFAULT FALSE,
  qualifies_eic BOOLEAN DEFAULT FALSE,
  qualifies_odtc BOOLEAN DEFAULT FALSE,
  is_student BOOLEAN DEFAULT FALSE,
  is_disabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Income Documents
CREATE TABLE w2_forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  employer_ein TEXT NOT NULL,
  employer_name TEXT NOT NULL,
  employer_address JSONB NOT NULL,
  box1_wages DECIMAL(12,2) NOT NULL,
  box2_federal_withheld DECIMAL(12,2) NOT NULL,
  box3_ss_wages DECIMAL(12,2) NOT NULL,
  box4_ss_tax DECIMAL(12,2) NOT NULL,
  box5_medicare_wages DECIMAL(12,2) NOT NULL,
  box6_medicare_tax DECIMAL(12,2) NOT NULL,
  box12_entries JSONB,
  box13_flags JSONB,
  state_info JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE form_1099_int (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  payer_name TEXT NOT NULL,
  payer_tin TEXT NOT NULL,
  interest_income DECIMAL(12,2) NOT NULL,
  early_withdrawal_penalty DECIMAL(12,2),
  federal_withheld DECIMAL(12,2),
  tax_exempt_interest DECIMAL(12,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Similar tables for 1099-DIV, 1099-R, 1099-NEC, 1099-MISC, 1099-G, 1099-B

-- 8. Deductions
CREATE TABLE deductions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  deduction_type TEXT NOT NULL,
  standard_deduction DECIMAL(12,2),
  itemized_total DECIMAL(12,2),
  medical_expenses DECIMAL(12,2),
  salt_total DECIMAL(12,2),
  mortgage_interest DECIMAL(12,2),
  charitable_contributions DECIMAL(12,2),
  qbi_deduction DECIMAL(12,2),
  total_deductions DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Credits
CREATE TABLE credits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  child_tax_credit DECIMAL(12,2) DEFAULT 0,
  other_dependent_credit DECIMAL(12,2) DEFAULT 0,
  earned_income_credit DECIMAL(12,2) DEFAULT 0,
  additional_child_tax_credit DECIMAL(12,2) DEFAULT 0,
  education_credits DECIMAL(12,2) DEFAULT 0,
  child_care_credit DECIMAL(12,2) DEFAULT 0,
  retirement_savings_credit DECIMAL(12,2) DEFAULT 0,
  other_credits DECIMAL(12,2) DEFAULT 0,
  total_nonrefundable DECIMAL(12,2) DEFAULT 0,
  total_refundable DECIMAL(12,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Signatures
CREATE TABLE return_signatures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  signer_type TEXT NOT NULL,
  signature_type TEXT NOT NULL,
  pin_encrypted BYTEA,
  signature_image_path TEXT,
  ip_address INET,
  user_agent TEXT,
  signed_at TIMESTAMPTZ NOT NULL,
  consent_given BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. E-File Submissions
CREATE TABLE efile_submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  submission_id TEXT NOT NULL UNIQUE,
  submission_type TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  xml_hash TEXT NOT NULL,
  submitted_at TIMESTAMPTZ NOT NULL,
  acknowledgment_received_at TIMESTAMPTZ,
  accepted_at TIMESTAMPTZ,
  rejected_at TIMESTAMPTZ,
  rejection_code TEXT,
  rejection_message TEXT,
  raw_acknowledgment JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. Refund Options
CREATE TABLE refund_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  refund_option TEXT NOT NULL,
  routing_number_encrypted BYTEA,
  account_number_encrypted BYTEA,
  account_type TEXT,
  account_last_four TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. Audit Log
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  event_type TEXT NOT NULL,
  action TEXT NOT NULL,
  resource_type TEXT,
  resource_id TEXT,
  ip_address INET,
  user_agent TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on all tables
-- (See individual documents for detailed RLS policies)
```

---

## 7. Model Relationships Map

```dart
// Relationships for ORM or manual queries

class ModelRelationships {
  static const relationships = {
    'TaxReturn': {
      'hasOne': ['TaxpayerInfo (primary)', 'TaxpayerInfo (spouse)', 'Deductions', 'Credits', 'RefundPreferences'],
      'hasMany': ['Dependents', 'W2Forms', 'Form1099s', 'StateReturns', 'Signatures', 'EFileSubmissions'],
      'belongsTo': ['User'],
    },
    'W2Form': {
      'belongsTo': ['TaxReturn'],
    },
    'Dependent': {
      'belongsTo': ['TaxReturn'],
    },
    'StateReturn': {
      'belongsTo': ['TaxReturn'],
      'hasMany': ['StateWithholding'],
    },
    // ... etc
  };
}
```

---

## 8. Implementation Checklist

- [ ] Implement all core models (TaxReturn, TaxpayerInfo, etc.)
- [ ] Create income document models (W2, 1099 series)
- [ ] Build deduction and credit models
- [ ] Implement tax calculation models
- [ ] Create signature and consent models
- [ ] Build e-file status models
- [ ] Set up database migrations
- [ ] Implement RLS policies
- [ ] Create model serialization/deserialization
- [ ] Add validation for all models
- [ ] Build repository layer for data access

---

## 9. Related Documents

- [Taxpayer Data](./taxpayer_data.md)
- [Income Sources](./income_sources.md)
- [Tax Forms](./tax_forms.md)
- [Deductions & Credits](./deductions_credits.md)
- [Security Compliance](./security_compliance.md)
