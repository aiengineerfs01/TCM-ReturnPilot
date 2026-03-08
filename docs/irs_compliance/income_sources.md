# Income Sources Documentation

## Overview

This document covers all income sources supported by IRS e-file, data collection requirements, and implementation specifications.

---

## 1. W-2 (Wage and Tax Statement)

### 1.1 W-2 Data Model

```dart
class W2Model {
  final String id;
  final String taxpayerId;
  final String taxYear;
  
  // Employer Information
  final String employerEIN;              // Box b: XX-XXXXXXX
  final String employerName;             // Box c
  final Address employerAddress;         // Box c
  final String? employerControlNumber;   // Box d (optional)
  
  // Employee Information
  final String employeeSSN;              // Box a
  final String employeeFirstName;        // Box e
  final String? employeeMiddleInitial;
  final String employeeLastName;         // Box e
  final String? employeeSuffix;
  final Address employeeAddress;         // Box f
  
  // Income Boxes
  final double wagesTipsOther;           // Box 1
  final double federalIncomeTaxWithheld; // Box 2
  final double socialSecurityWages;      // Box 3
  final double socialSecurityTaxWithheld;// Box 4
  final double medicareWages;            // Box 5
  final double medicareTaxWithheld;      // Box 6
  final double socialSecurityTips;       // Box 7
  final double allocatedTips;            // Box 8
  final double? dependentCareBenefits;   // Box 10
  final double? nonQualifiedPlans;       // Box 11
  
  // Deferred Compensation (Box 12)
  final List<W2Box12Entry> box12Entries;
  
  // Checkboxes (Box 13)
  final bool statutoryEmployee;          // Box 13
  final bool retirementPlan;             // Box 13
  final bool thirdPartySickPay;          // Box 13
  
  // Other
  final String? other;                   // Box 14
  
  // State/Local
  final List<W2StateTax> stateTaxes;     // Boxes 15-17
  final List<W2LocalTax> localTaxes;     // Boxes 18-20
}

class W2Box12Entry {
  final String code;  // A through HH
  final double amount;
}

class W2StateTax {
  final String state;              // Box 15
  final String? employerStateId;   // Box 15
  final double stateWages;         // Box 16
  final double stateTaxWithheld;   // Box 17
}

class W2LocalTax {
  final double localWages;         // Box 18
  final double localTaxWithheld;   // Box 19
  final String localityName;       // Box 20
}
```

### 1.2 Box 12 Codes Reference

```dart
const box12Codes = {
  'A': 'Uncollected social security or RRTA tax on tips',
  'B': 'Uncollected Medicare tax on tips',
  'C': 'Taxable cost of group-term life insurance over \$50,000',
  'D': 'Elective deferrals under 401(k) plan',
  'E': 'Elective deferrals under 403(b) plan',
  'F': 'Elective deferrals under 408(k)(6) SARSEP',
  'G': 'Elective deferrals under 457(b) plan',
  'H': 'Elective deferrals under 501(c)(18)(D) plan',
  'J': 'Nontaxable sick pay',
  'K': '20% excise tax on excess golden parachute payments',
  'L': 'Substantiated employee business expense reimbursements',
  'M': 'Uncollected social security on group-term life insurance',
  'N': 'Uncollected Medicare tax on group-term life insurance',
  'P': 'Excludable moving expense reimbursements',
  'Q': 'Nontaxable combat pay',
  'R': 'Employer contributions to Archer MSA',
  'S': 'Employee salary reduction contributions under 408(p) SIMPLE',
  'T': 'Adoption benefits',
  'V': 'Income from exercise of nonstatutory stock options',
  'W': 'Employer contributions to HSA',
  'Y': 'Deferrals under 409A nonqualified deferred compensation plan',
  'Z': 'Income under 409A nonqualified deferred compensation plan',
  'AA': 'Roth contributions under 401(k) plan',
  'BB': 'Roth contributions under 403(b) plan',
  'DD': 'Cost of employer-sponsored health coverage',
  'EE': 'Designated Roth contributions under 457(b) plan',
  'FF': 'Permitted benefits under qualified small employer HRA',
  'GG': 'Income from qualified equity grants under 83(i)',
  'HH': 'Aggregate deferrals under 83(i) elections',
};
```

### 1.3 W-2 Validation Rules

```dart
class W2Validator {
  static List<String> validate(W2Model w2) {
    final errors = <String>[];
    
    // EIN validation
    if (!_isValidEIN(w2.employerEIN)) {
      errors.add('Invalid employer EIN format');
    }
    
    // Box 3 cannot exceed Social Security wage base
    const sswageBase2024 = 168600;
    if (w2.socialSecurityWages > sswageBase2024) {
      errors.add('Social Security wages exceed annual limit');
    }
    
    // Box 4 validation (6.2% of Box 3)
    final expectedSSTax = w2.socialSecurityWages * 0.062;
    if ((w2.socialSecurityTaxWithheld - expectedSSTax).abs() > 1) {
      errors.add('Social Security tax withheld does not match wages');
    }
    
    // Box 6 validation (1.45% of Box 5)
    final expectedMedicareTax = w2.medicareWages * 0.0145;
    if ((w2.medicareTaxWithheld - expectedMedicareTax).abs() > 1) {
      errors.add('Medicare tax withheld does not match wages');
    }
    
    // Additional Medicare (0.9% on wages over $200k)
    if (w2.medicareWages > 200000) {
      // Additional Medicare tax may apply
    }
    
    return errors;
  }
  
  static bool _isValidEIN(String ein) {
    final cleaned = ein.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length == 9;
  }
}
```

---

## 2. 1099 Forms

### 2.1 1099-INT (Interest Income)

```dart
class Form1099INT {
  final String id;
  final String taxpayerId;
  final String taxYear;
  
  // Payer Information
  final String payerName;
  final String payerTIN;              // EIN or SSN
  final Address payerAddress;
  
  // Recipient (copied from taxpayer)
  final String recipientSSN;
  
  // Income Boxes
  final double interestIncome;         // Box 1
  final double earlyWithdrawalPenalty; // Box 2
  final double interestOnUSBonds;      // Box 3
  final double federalTaxWithheld;     // Box 4
  final double investmentExpenses;     // Box 5
  final double foreignTaxPaid;         // Box 6
  final String? foreignCountry;        // Box 7
  final double taxExemptInterest;      // Box 8
  final double specifiedPrivateBondInterest; // Box 9
  final double marketDiscount;         // Box 10
  final double bondPremium;            // Box 11
  final double bondPremiumTreasury;    // Box 12
  final double bondPremiumTaxExempt;   // Box 13
  final String? cusipNumber;           // Box 14
  
  // State Information
  final String? stateId;               // Box 15
  final double? stateIncome;           // Box 16
  final double? stateTaxWithheld;      // Box 17
}
```

### 2.2 1099-DIV (Dividends)

```dart
class Form1099DIV {
  final String id;
  final String taxpayerId;
  final String taxYear;
  
  // Payer Information
  final String payerName;
  final String payerTIN;
  final Address payerAddress;
  
  // Dividend Boxes
  final double totalOrdinaryDividends;      // Box 1a
  final double qualifiedDividends;          // Box 1b
  final double totalCapitalGainDistribution;// Box 2a
  final double unrecaptured1250Gain;        // Box 2b
  final double section1202Gain;             // Box 2c
  final double collectiblesGain;            // Box 2d
  final double section897Dividends;         // Box 2e
  final double section897CapitalGain;       // Box 2f
  final double nondividendDistributions;    // Box 3
  final double federalTaxWithheld;          // Box 4
  final double section199ADividends;        // Box 5
  final double investmentExpenses;          // Box 6
  final double foreignTaxPaid;              // Box 7
  final String? foreignCountry;             // Box 8
  final double cashLiquidation;             // Box 9
  final double noncashLiquidation;          // Box 10
  final bool fatcaFilingRequired;           // Box 11
  final double exemptInterestDividends;     // Box 12
  final double specifiedPrivateBondDividends;// Box 13
  
  // State
  final String? stateId;                    // Box 14
  final double? stateTaxWithheld;           // Box 15
}
```

### 2.3 1099-G (Government Payments)

```dart
class Form1099G {
  final String id;
  final String taxpayerId;
  final String taxYear;
  
  // Payer (Government Agency)
  final String payerName;
  final String payerTIN;
  final Address payerAddress;
  
  // Payment Boxes
  final double unemploymentCompensation;    // Box 1
  final double stateLocalTaxRefund;         // Box 2
  final int taxYear;                        // Box 3 (year of refund)
  final double federalTaxWithheld;          // Box 4
  final double rtaaPayments;                // Box 5 (Reemployment Trade Adjustment)
  final double taxableGrants;               // Box 6
  final double agriculturePayments;         // Box 7
  final bool tradeOrBusiness;               // Box 8 (checkbox)
  final double marketGainLoss;              // Box 9
  
  // State
  final String? stateId;                    // Box 10a
  final String? stateIdNo;                  // Box 10b
  final double? stateTaxWithheld;           // Box 11
}
```

### 2.4 1099-R (Retirement Distributions)

```dart
class Form1099R {
  final String id;
  final String taxpayerId;
  final String taxYear;
  
  // Payer
  final String payerName;
  final String payerTIN;
  final Address payerAddress;
  
  // Distribution Boxes
  final double grossDistribution;           // Box 1
  final double taxableAmount;               // Box 2a
  final bool taxableAmountNotDetermined;    // Box 2b checkbox
  final bool totalDistribution;             // Box 2b checkbox
  final double capitalGain;                 // Box 3
  final double federalTaxWithheld;          // Box 4
  final double employeeContributions;       // Box 5
  final double netUnrealizedAppreciation;   // Box 6
  final String distributionCode;            // Box 7 (1, 2, 3, 4, 7, etc.)
  final String? secondDistributionCode;     // Box 7 (second code if applicable)
  final bool iraSepSimple;                  // Box 7 IRA/SEP/SIMPLE checkbox
  final double otherAmount;                 // Box 8
  final double percentageTotalDistribution; // Box 9a
  final double totalEmployeeContributions;  // Box 9b
  final double allocableToIRR;              // Box 10
  final String? firstYearDesignatedRoth;    // Box 11
  
  // State/Local
  final String? state;                      // Box 12
  final String? payerStateId;               // Box 13
  final double? stateDistribution;          // Box 14
  final double? stateTaxWithheld;           // Box 15
  final String? localityName;               // Box 16
  final double? localDistribution;          // Box 17
  final double? localTaxWithheld;           // Box 18
}

// Distribution Codes
const distributionCodes = {
  '1': 'Early distribution, no known exception',
  '2': 'Early distribution, exception applies',
  '3': 'Disability',
  '4': 'Death',
  '5': 'Prohibited transaction',
  '6': 'Section 1035 exchange',
  '7': 'Normal distribution',
  '8': 'Excess contributions plus earnings',
  '9': 'Cost of current life insurance',
  'A': 'May be eligible for 10-year tax option',
  'B': 'Designated Roth account distribution',
  'C': 'Reportable death benefits under 6050Y',
  'D': 'Annuity payments from nonqualified plans',
  'E': 'Section 415 payment',
  'F': 'Charitable gift annuity',
  'G': 'Direct rollover to qualified plan',
  'H': 'Direct rollover to Roth IRA',
  'J': 'Early distribution from Roth IRA',
  'K': 'Distribution of traditional IRA assets',
  'L': 'Loan treated as distribution',
  'M': 'Qualified plan loan offset',
  'N': 'Recharacterized IRA contribution',
  'P': 'Excess contributions plus earnings (alternative)',
  'Q': 'Qualified distribution from Roth IRA',
  'R': 'Recharacterized Roth IRA contribution',
  'S': 'Early distribution from SIMPLE IRA',
  'T': 'Roth IRA distribution',
  'U': 'Dividend distribution from ESOP',
  'W': 'IRA contribution or qualified HSA funding',
};
```

### 2.5 1099-NEC (Non-Employee Compensation)

```dart
class Form1099NEC {
  final String id;
  final String taxpayerId;
  final String taxYear;
  
  // Payer
  final String payerName;
  final String payerTIN;
  final Address payerAddress;
  
  // Payment
  final double nonemployeeCompensation;     // Box 1
  final bool directSalesIndicator;          // Box 2
  final double federalTaxWithheld;          // Box 4
  
  // State
  final String? state;                      // Box 5
  final String? payerStateId;               // Box 6
  final double? stateIncome;                // Box 7
}
```

### 2.6 1099-MISC (Miscellaneous Income)

```dart
class Form1099MISC {
  final String id;
  final String taxpayerId;
  final String taxYear;
  
  // Payer
  final String payerName;
  final String payerTIN;
  final Address payerAddress;
  
  // Income Boxes
  final double rents;                       // Box 1
  final double royalties;                   // Box 2
  final double otherIncome;                 // Box 3
  final double federalTaxWithheld;          // Box 4
  final double fishingBoatProceeds;         // Box 5
  final double medicalPayments;             // Box 6
  final bool directSales;                   // Box 7
  final double substitutePayments;          // Box 8
  final double cropInsurance;               // Box 9
  final double grossAttorneyProceeds;       // Box 10
  final double section409ADeferral;         // Box 12
  final double excessGoldenParachute;       // Box 13
  final double nonQualifiedDeferredComp;    // Box 14
  final double section409AIncome;           // Box 15
  
  // State
  final String? state;                      // Box 16
  final String? payerStateId;               // Box 17
  final double? stateIncome;                // Box 18
}
```

### 2.7 1099-K (Payment Card/Third Party Transactions)

```dart
class Form1099K {
  final String id;
  final String taxpayerId;
  final String taxYear;
  
  // Filer (Payment Settlement Entity)
  final String filerName;
  final String filerTIN;
  final Address filerAddress;
  final String? filerPhone;
  
  // Payee
  final String payeeSSN;
  final String payeeName;
  
  // Amounts
  final double grossAmount;                 // Box 1a
  final double cardNotPresent;              // Box 1b
  final String? numberOfPaymentTransactions;// Box 2
  final double federalTaxWithheld;          // Box 3
  
  // Monthly breakdown
  final double january;                     // Box 5a
  final double february;                    // Box 5b
  final double march;                       // Box 5c
  final double april;                       // Box 5d
  final double may;                         // Box 5e
  final double june;                        // Box 5f
  final double july;                        // Box 5g
  final double august;                      // Box 5h
  final double september;                   // Box 5i
  final double october;                     // Box 5j
  final double november;                    // Box 5k
  final double december;                    // Box 5l
  
  // State
  final String? state;                      // Box 6
  final String? payerStateId;               // Box 7
  final double? stateIncome;                // Box 8
}
```

---

## 3. Other Income Sources

### 3.1 Social Security Benefits (SSA-1099)

```dart
class FormSSA1099 {
  final String id;
  final String taxpayerId;
  final String taxYear;
  
  final String beneficiarySSN;
  final String beneficiaryName;
  
  final double totalBenefitsPaid;           // Box 3
  final double benefitsRepaid;              // Box 4
  final double netBenefits;                 // Box 5
  final double voluntaryFederalTaxWithheld; // Box 6
  
  // Taxable calculation (0%, 50%, or 85% taxable)
  double calculateTaxableAmount({
    required double modifiedAGI,
    required FilingStatus filingStatus,
  }) {
    // Complex calculation based on combined income
    // and filing status thresholds
    return 0; // Implementation needed
  }
}
```

### 3.2 Self-Employment Income

```dart
class SelfEmploymentIncome {
  final String id;
  final String taxpayerId;
  final String taxYear;
  
  // Business Information
  final String businessName;
  final String? businessEIN;
  final String businessType;              // Sole proprietor, single-member LLC
  final String principalBusinessCode;     // 6-digit NAICS code
  final String businessDescription;
  final Address businessAddress;
  
  // Accounting Method
  final AccountingMethod accountingMethod;
  final bool materialParticipation;
  
  // Income
  final double grossReceipts;
  final double returns;
  final double costOfGoodsSold;
  
  // Expenses (Schedule C)
  final double advertising;
  final double carAndTruck;
  final double commissions;
  final double contractLabor;
  final double depletion;
  final double depreciation;
  final double employeeBenefits;
  final double insurance;
  final double mortgageInterest;
  final double otherInterest;
  final double legalServices;
  final double officeExpense;
  final double pensionPlans;
  final double rentVehicles;
  final double rentProperty;
  final double repairs;
  final double supplies;
  final double taxes;
  final double travel;
  final double mealsDeductible;           // 50% limitation
  final double utilities;
  final double wages;
  final double otherExpenses;
  
  // Home Office
  final bool hasHomeOffice;
  final double? homeOfficeSqFt;
  final double? homeTotalSqFt;
}

enum AccountingMethod {
  cash,
  accrual,
  other,
}
```

### 3.3 Rental Income (Schedule E)

```dart
class RentalProperty {
  final String id;
  final String taxpayerId;
  final String taxYear;
  
  // Property Information
  final Address propertyAddress;
  final String propertyType;              // Single family, multi-family, etc.
  final int daysRented;
  final int daysPersonalUse;
  final bool qualifiedJointVenture;
  
  // Income
  final double rentsReceived;
  final double otherIncome;
  
  // Expenses
  final double advertising;
  final double autoTravel;
  final double cleaning;
  final double commissions;
  final double insurance;
  final double legal;
  final double managementFees;
  final double mortgageInterest;
  final double otherInterest;
  final double repairs;
  final double supplies;
  final double taxes;
  final double utilities;
  final double depreciation;
  final double otherExpenses;
}
```

---

## 4. Income Import Features

### 4.1 OCR/Document Scanning

```dart
class IncomeDocumentScanner {
  // Integration with document scanning service
  // Extract data from W-2, 1099 images
  
  Future<W2Model?> scanW2(File imageFile) async {
    // 1. Upload to OCR service
    // 2. Extract text regions
    // 3. Map to W-2 fields
    // 4. Return populated model or null if failed
    return null;
  }
  
  Future<Form1099INT?> scan1099INT(File imageFile) async {
    // Similar implementation
    return null;
  }
}
```

### 4.2 Payroll Integration

```dart
// Support for importing directly from payroll providers
class PayrollImporter {
  // Supported providers
  static const supportedProviders = [
    'ADP',
    'Paychex',
    'Gusto',
    'Paylocity',
    'Workday',
  ];
  
  Future<List<W2Model>> importW2s({
    required String provider,
    required String authToken,
  }) async {
    // Provider-specific API integration
    return [];
  }
}
```

### 4.3 IRS Account Transcript

```dart
// Integration with IRS Get Transcript
class IRSTranscriptService {
  Future<List<IncomeDocument>> getWageAndIncomeTranscript({
    required String ssn,
    required String dateOfBirth,
    required int taxYear,
  }) async {
    // IRS Get Transcript API integration
    // Returns all income documents on file with IRS
    return [];
  }
}
```

---

## 5. Database Schema

```sql
-- W-2 Forms
CREATE TABLE w2_forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taxpayer_id UUID REFERENCES taxpayers(id) NOT NULL,
  tax_year INTEGER NOT NULL,
  
  -- Employer
  employer_ein VARCHAR(10) NOT NULL,
  employer_name VARCHAR(100) NOT NULL,
  employer_address JSONB NOT NULL,
  employer_control_number VARCHAR(20),
  
  -- Employee
  employee_ssn_encrypted BYTEA NOT NULL,
  employee_name VARCHAR(100) NOT NULL,
  employee_address JSONB,
  
  -- Boxes 1-6
  box1_wages DECIMAL(12,2) DEFAULT 0,
  box2_fed_tax DECIMAL(12,2) DEFAULT 0,
  box3_ss_wages DECIMAL(12,2) DEFAULT 0,
  box4_ss_tax DECIMAL(12,2) DEFAULT 0,
  box5_medicare_wages DECIMAL(12,2) DEFAULT 0,
  box6_medicare_tax DECIMAL(12,2) DEFAULT 0,
  
  -- Additional boxes
  box7_ss_tips DECIMAL(12,2) DEFAULT 0,
  box8_allocated_tips DECIMAL(12,2) DEFAULT 0,
  box10_dependent_care DECIMAL(12,2) DEFAULT 0,
  box11_nonqualified DECIMAL(12,2) DEFAULT 0,
  
  -- Box 12 entries (JSONB array)
  box12_entries JSONB DEFAULT '[]',
  
  -- Box 13 checkboxes
  statutory_employee BOOLEAN DEFAULT FALSE,
  retirement_plan BOOLEAN DEFAULT FALSE,
  third_party_sick_pay BOOLEAN DEFAULT FALSE,
  
  -- Box 14
  other_info TEXT,
  
  -- State/local taxes (JSONB arrays)
  state_taxes JSONB DEFAULT '[]',
  local_taxes JSONB DEFAULT '[]',
  
  -- Metadata
  source VARCHAR(50) DEFAULT 'manual',  -- manual, import, scan
  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1099-INT Forms
CREATE TABLE form_1099_int (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taxpayer_id UUID REFERENCES taxpayers(id) NOT NULL,
  tax_year INTEGER NOT NULL,
  
  payer_name VARCHAR(100) NOT NULL,
  payer_tin VARCHAR(10) NOT NULL,
  payer_address JSONB NOT NULL,
  
  box1_interest DECIMAL(12,2) DEFAULT 0,
  box2_early_withdrawal_penalty DECIMAL(12,2) DEFAULT 0,
  box3_us_bond_interest DECIMAL(12,2) DEFAULT 0,
  box4_fed_tax DECIMAL(12,2) DEFAULT 0,
  box5_investment_expense DECIMAL(12,2) DEFAULT 0,
  box6_foreign_tax DECIMAL(12,2) DEFAULT 0,
  box7_foreign_country VARCHAR(50),
  box8_tax_exempt_interest DECIMAL(12,2) DEFAULT 0,
  box9_private_bond_interest DECIMAL(12,2) DEFAULT 0,
  box10_market_discount DECIMAL(12,2) DEFAULT 0,
  box11_bond_premium DECIMAL(12,2) DEFAULT 0,
  box12_treasury_premium DECIMAL(12,2) DEFAULT 0,
  box13_tax_exempt_premium DECIMAL(12,2) DEFAULT 0,
  box14_cusip VARCHAR(20),
  
  state_id VARCHAR(20),
  state_income DECIMAL(12,2) DEFAULT 0,
  state_tax DECIMAL(12,2) DEFAULT 0,
  
  source VARCHAR(50) DEFAULT 'manual',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Similar tables for other 1099 forms...

-- Income Summary View
CREATE VIEW income_summary AS
SELECT 
  t.id as taxpayer_id,
  t.tax_year,
  COALESCE(SUM(w.box1_wages), 0) as total_wages,
  COALESCE(SUM(i.box1_interest), 0) as total_interest,
  COALESCE(SUM(d.box1a_dividends), 0) as total_dividends,
  -- Add other income types
  COALESCE(SUM(w.box2_fed_tax), 0) + 
    COALESCE(SUM(i.box4_fed_tax), 0) as total_fed_withholding
FROM taxpayers t
LEFT JOIN w2_forms w ON t.id = w.taxpayer_id
LEFT JOIN form_1099_int i ON t.id = i.taxpayer_id
LEFT JOIN form_1099_div d ON t.id = d.taxpayer_id
GROUP BY t.id, t.tax_year;
```

---

## 6. UI Implementation

### 6.1 Income Entry Flow

```
┌─────────────────────────┐
│   Income Dashboard      │  Summary of all income sources
│   [+ Add Income]        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│   Select Income Type    │  W-2, 1099-INT, 1099-DIV, etc.
│   [Import] [Manual]     │
└───────────┬─────────────┘
            │
      ┌─────┴─────┐
      │           │
      ▼           ▼
┌───────────┐ ┌───────────┐
│  Scan/    │ │  Manual   │
│  Import   │ │  Entry    │
└─────┬─────┘ └─────┬─────┘
      │             │
      └──────┬──────┘
             │
             ▼
┌─────────────────────────┐
│   Review & Confirm      │  Verify extracted/entered data
└─────────────────────────┘
```

### 6.2 Required Screens

| Screen | Purpose |
|--------|---------|
| `IncomeDashboardScreen` | Overview of all income |
| `AddIncomeTypeScreen` | Select type of income to add |
| `W2EntryScreen` | W-2 form entry |
| `W2ReviewScreen` | W-2 review before save |
| `Form1099Screen` | Generic 1099 entry (dynamic) |
| `SelfEmploymentScreen` | Schedule C entry |
| `RentalIncomeScreen` | Schedule E entry |
| `IncomeImportScreen` | Import/scan documents |

---

## 7. Related Documents

- [Taxpayer Data](./taxpayer_data.md)
- [Tax Forms](./tax_forms.md)
- [Calculations](./calculations.md)
- [Data Models](./data_models.md)
