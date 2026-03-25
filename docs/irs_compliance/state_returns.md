# State Tax Returns Integration

## Overview

This document details state tax return requirements, state-specific forms, multi-state filing scenarios, and integration with federal return data for state e-filing.

---

## 1. State Tax Return Overview

### 1.1 State Filing Requirements

```dart
enum StateFilingRequirement {
  noStateTax,           // No state income tax (9 states)
  fullReturn,           // Standard state return required
  limitedReturn,        // Only certain income types taxed
  localityRequired,     // Additional local/city taxes
}

class StateTaxInfo {
  final String stateCode;
  final String stateName;
  final StateFilingRequirement requirement;
  final bool supportsEFile;
  final String? eFileProvider;
  final List<String> requiredForms;
  final double? flatTaxRate;           // For flat tax states
  final List<TaxBracket>? brackets;    // For graduated tax states
  final double standardDeduction;
  final double personalExemption;
  
  const StateTaxInfo({
    required this.stateCode,
    required this.stateName,
    required this.requirement,
    required this.supportsEFile,
    this.eFileProvider,
    required this.requiredForms,
    this.flatTaxRate,
    this.brackets,
    required this.standardDeduction,
    required this.personalExemption,
  });
}

// States with no income tax
const noIncomeTaxStates = [
  'AK', // Alaska
  'FL', // Florida
  'NV', // Nevada
  'SD', // South Dakota
  'TN', // Tennessee (no wage tax, interest/dividends only until 2021)
  'TX', // Texas
  'WA', // Washington
  'WY', // Wyoming
  'NH', // New Hampshire (interest/dividends only)
];
```

### 1.2 State Tax Database

```dart
class StateTaxDatabase {
  // 2024 State Tax Rates (simplified - actual implementation would be more detailed)
  static const Map<String, StateTaxInfo> states = {
    'CA': StateTaxInfo(
      stateCode: 'CA',
      stateName: 'California',
      requirement: StateFilingRequirement.fullReturn,
      supportsEFile: true,
      eFileProvider: 'FTB',
      requiredForms: ['540', '540NR'],
      brackets: [
        TaxBracket(min: 0, max: 10412, rate: 0.01),
        TaxBracket(min: 10412, max: 24684, rate: 0.02),
        TaxBracket(min: 24684, max: 38959, rate: 0.04),
        TaxBracket(min: 38959, max: 54081, rate: 0.06),
        TaxBracket(min: 54081, max: 68350, rate: 0.08),
        TaxBracket(min: 68350, max: 349137, rate: 0.093),
        TaxBracket(min: 349137, max: 418961, rate: 0.103),
        TaxBracket(min: 418961, max: 698271, rate: 0.113),
        TaxBracket(min: 698271, max: double.infinity, rate: 0.123),
      ],
      standardDeduction: 5363,
      personalExemption: 144,
    ),
    
    'NY': StateTaxInfo(
      stateCode: 'NY',
      stateName: 'New York',
      requirement: StateFilingRequirement.localityRequired,
      supportsEFile: true,
      eFileProvider: 'NYS DTF',
      requiredForms: ['IT-201', 'IT-203'],
      brackets: [
        TaxBracket(min: 0, max: 8500, rate: 0.04),
        TaxBracket(min: 8500, max: 11700, rate: 0.045),
        TaxBracket(min: 11700, max: 13900, rate: 0.0525),
        TaxBracket(min: 13900, max: 80650, rate: 0.055),
        TaxBracket(min: 80650, max: 215400, rate: 0.06),
        TaxBracket(min: 215400, max: 1077550, rate: 0.0685),
        TaxBracket(min: 1077550, max: 5000000, rate: 0.0965),
        TaxBracket(min: 5000000, max: 25000000, rate: 0.103),
        TaxBracket(min: 25000000, max: double.infinity, rate: 0.109),
      ],
      standardDeduction: 8000,
      personalExemption: 0,
    ),
    
    'TX': StateTaxInfo(
      stateCode: 'TX',
      stateName: 'Texas',
      requirement: StateFilingRequirement.noStateTax,
      supportsEFile: false,
      requiredForms: [],
      standardDeduction: 0,
      personalExemption: 0,
    ),
    
    'FL': StateTaxInfo(
      stateCode: 'FL',
      stateName: 'Florida',
      requirement: StateFilingRequirement.noStateTax,
      supportsEFile: false,
      requiredForms: [],
      standardDeduction: 0,
      personalExemption: 0,
    ),
    
    'IL': StateTaxInfo(
      stateCode: 'IL',
      stateName: 'Illinois',
      requirement: StateFilingRequirement.fullReturn,
      supportsEFile: true,
      eFileProvider: 'IDOR',
      requiredForms: ['IL-1040'],
      flatTaxRate: 0.0495,
      standardDeduction: 0, // IL uses exemptions, not standard deduction
      personalExemption: 2425,
    ),
    
    // Add all 50 states...
  };
  
  static StateTaxInfo? getState(String stateCode) {
    return states[stateCode.toUpperCase()];
  }
  
  static bool requiresFiling(String stateCode) {
    final state = getState(stateCode);
    if (state == null) return false;
    return state.requirement != StateFilingRequirement.noStateTax;
  }
}
```

---

## 2. State Return Models

### 2.1 State Return Model

```dart
class StateReturn {
  final String id;
  final String federalReturnId;
  final String stateCode;
  final int taxYear;
  final StateResidencyStatus residencyStatus;
  final StateReturnStatus status;
  
  // Income (often different from federal)
  final double stateWages;
  final double stateAdjustments;
  final double stateAGI;
  final double stateDeductions;
  final double stateTaxableIncome;
  
  // Tax Calculations
  final double stateTax;
  final double stateCredits;
  final double stateWithholding;
  final double stateEstimatedPayments;
  final double stateRefundOrOwed;
  
  // State-Specific Data
  final Map<String, dynamic> stateSpecificData;
  
  const StateReturn({
    required this.id,
    required this.federalReturnId,
    required this.stateCode,
    required this.taxYear,
    required this.residencyStatus,
    required this.status,
    required this.stateWages,
    required this.stateAdjustments,
    required this.stateAGI,
    required this.stateDeductions,
    required this.stateTaxableIncome,
    required this.stateTax,
    required this.stateCredits,
    required this.stateWithholding,
    required this.stateEstimatedPayments,
    required this.stateRefundOrOwed,
    this.stateSpecificData = const {},
  });
}

enum StateResidencyStatus {
  resident,           // Full-year resident
  nonResident,        // Non-resident (earned income in state)
  partYearResident,   // Moved in/out during year
}

enum StateReturnStatus {
  notStarted,
  inProgress,
  readyToFile,
  submitted,
  accepted,
  rejected,
}
```

### 2.2 Multi-State Filing

```dart
class MultiStateManager {
  // Determine which states need returns
  List<RequiredStateReturn> determineRequiredStates({
    required String residenceState,
    required List<W2> w2Forms,
    required List<Form1099> form1099s,
    required List<StateIncome> otherStateIncome,
  }) {
    final required = <RequiredStateReturn>[];
    
    // Always file in residence state (if it has income tax)
    if (StateTaxDatabase.requiresFiling(residenceState)) {
      required.add(RequiredStateReturn(
        stateCode: residenceState,
        reason: StateFilingReason.residency,
        residencyStatus: StateResidencyStatus.resident,
      ));
    }
    
    // Check W-2s for income earned in other states
    for (final w2 in w2Forms) {
      if (w2.stateCode != null && 
          w2.stateCode != residenceState &&
          StateTaxDatabase.requiresFiling(w2.stateCode!)) {
        if (!required.any((r) => r.stateCode == w2.stateCode)) {
          required.add(RequiredStateReturn(
            stateCode: w2.stateCode!,
            reason: StateFilingReason.incomeEarned,
            residencyStatus: StateResidencyStatus.nonResident,
            incomeAmount: w2.stateWages ?? w2.wages,
          ));
        }
      }
    }
    
    // Check other state income sources
    for (final income in otherStateIncome) {
      if (income.stateCode != residenceState &&
          StateTaxDatabase.requiresFiling(income.stateCode)) {
        if (!required.any((r) => r.stateCode == income.stateCode)) {
          required.add(RequiredStateReturn(
            stateCode: income.stateCode,
            reason: income.filingReason,
            residencyStatus: StateResidencyStatus.nonResident,
            incomeAmount: income.amount,
          ));
        }
      }
    }
    
    return required;
  }
  
  // Calculate credit for taxes paid to other states
  double calculateOtherStateCredit({
    required String residenceState,
    required double residenceStateTax,
    required List<StateTaxPaid> otherStateTaxes,
    required double federalAGI,
  }) {
    // Most states allow credit for taxes paid to other states
    // Limited to the lesser of:
    // 1. Tax actually paid to other state
    // 2. Residence state tax on that income
    
    double totalCredit = 0;
    
    for (final otherTax in otherStateTaxes) {
      // Calculate what residence state tax would be on that income
      final incomeRatio = otherTax.incomeAmount / federalAGI;
      final residenceTaxOnIncome = residenceStateTax * incomeRatio;
      
      // Credit is lesser of actual paid or residence state tax
      final credit = min(otherTax.taxPaid, residenceTaxOnIncome);
      totalCredit += credit;
    }
    
    // Total credit cannot exceed residence state tax
    return min(totalCredit, residenceStateTax);
  }
}

class RequiredStateReturn {
  final String stateCode;
  final StateFilingReason reason;
  final StateResidencyStatus residencyStatus;
  final double? incomeAmount;
  
  const RequiredStateReturn({
    required this.stateCode,
    required this.reason,
    required this.residencyStatus,
    this.incomeAmount,
  });
}

enum StateFilingReason {
  residency,           // Live in the state
  incomeEarned,        // Earned income in state
  propertyIncome,      // Rental/property income in state
  businessIncome,      // Business income from state
  retirementIncome,    // Retirement income sourced to state
}

class StateIncome {
  final String stateCode;
  final double amount;
  final StateFilingReason filingReason;
  
  const StateIncome({
    required this.stateCode,
    required this.amount,
    required this.filingReason,
  });
}

class StateTaxPaid {
  final String stateCode;
  final double taxPaid;
  final double incomeAmount;
  
  const StateTaxPaid({
    required this.stateCode,
    required this.taxPaid,
    required this.incomeAmount,
  });
}
```

---

## 3. State-Specific Forms

### 3.1 California Forms

```dart
class CaliforniaForms {
  // Form 540 - California Resident Income Tax Return
  static Form540 generateForm540({
    required FederalReturn federalReturn,
    required StateReturn stateReturn,
  }) {
    return Form540(
      // Personal Info
      taxYear: federalReturn.taxYear,
      filingStatus: federalReturn.filingStatus,
      primarySSN: federalReturn.primarySSN,
      spouseSSN: federalReturn.spouseSSN,
      
      // Income - CA starts with federal AGI
      federalAGI: federalReturn.agi,
      caAdditions: _calculateCAAdditions(federalReturn),
      caSubtractions: _calculateCASubtractions(federalReturn),
      caAGI: stateReturn.stateAGI,
      
      // Deductions
      standardDeduction: stateReturn.stateDeductions,
      itemizedDeductions: null, // If itemizing
      
      // Tax
      taxableIncome: stateReturn.stateTaxableIncome,
      tax: stateReturn.stateTax,
      
      // Credits
      exemptionCredits: _calculateExemptionCredits(federalReturn),
      otherCredits: stateReturn.stateCredits,
      
      // Payments
      withholding: stateReturn.stateWithholding,
      estimatedPayments: stateReturn.stateEstimatedPayments,
      
      // Result
      refundOrOwed: stateReturn.stateRefundOrOwed,
    );
  }
  
  static double _calculateCAAdditions(FederalReturn federal) {
    double additions = 0;
    
    // CA doesn't conform to certain federal deductions
    // Example: CA limited SALT deduction before federal TCJA
    
    // State tax refund (if deducted federally)
    additions += federal.stateTaxRefund ?? 0;
    
    // Other CA-specific additions
    
    return additions;
  }
  
  static double _calculateCASubtractions(FederalReturn federal) {
    double subtractions = 0;
    
    // Social Security is not taxed in CA
    subtractions += federal.socialSecurityBenefits ?? 0;
    
    // Railroad retirement
    subtractions += federal.railroadRetirement ?? 0;
    
    // CA lottery winnings
    subtractions += federal.caLotteryWinnings ?? 0;
    
    return subtractions;
  }
  
  static double _calculateExemptionCredits(FederalReturn federal) {
    const exemptionCredit = 144.0; // 2024
    
    int exemptions = 1; // Primary
    if (federal.filingStatus == FilingStatus.marriedFilingJointly) {
      exemptions += 1; // Spouse
    }
    exemptions += federal.dependents.length;
    
    return exemptions * exemptionCredit;
  }
}

class Form540 {
  final int taxYear;
  final FilingStatus filingStatus;
  final String primarySSN;
  final String? spouseSSN;
  final double federalAGI;
  final double caAdditions;
  final double caSubtractions;
  final double caAGI;
  final double standardDeduction;
  final double? itemizedDeductions;
  final double taxableIncome;
  final double tax;
  final double exemptionCredits;
  final double otherCredits;
  final double withholding;
  final double estimatedPayments;
  final double refundOrOwed;
  
  const Form540({
    required this.taxYear,
    required this.filingStatus,
    required this.primarySSN,
    this.spouseSSN,
    required this.federalAGI,
    required this.caAdditions,
    required this.caSubtractions,
    required this.caAGI,
    required this.standardDeduction,
    this.itemizedDeductions,
    required this.taxableIncome,
    required this.tax,
    required this.exemptionCredits,
    required this.otherCredits,
    required this.withholding,
    required this.estimatedPayments,
    required this.refundOrOwed,
  });
}
```

### 3.2 New York Forms

```dart
class NewYorkForms {
  // Form IT-201 - Resident Income Tax Return
  static FormIT201 generateIT201({
    required FederalReturn federalReturn,
    required StateReturn stateReturn,
    required NYCResidentInfo? nycInfo,
  }) {
    return FormIT201(
      taxYear: federalReturn.taxYear,
      filingStatus: federalReturn.filingStatus,
      
      // NY starts with federal AGI
      federalAGI: federalReturn.agi,
      nyAdditions: _calculateNYAdditions(federalReturn),
      nySubtractions: _calculateNYSubtractions(federalReturn),
      nyAGI: stateReturn.stateAGI,
      
      // NY Deductions
      nyStandardDeduction: _getNYStandardDeduction(federalReturn.filingStatus),
      nyItemizedDeductions: null,
      
      // NY Tax
      nyTaxableIncome: stateReturn.stateTaxableIncome,
      nyTax: stateReturn.stateTax,
      
      // NYC Tax (if applicable)
      isNYCResident: nycInfo?.isResident ?? false,
      nycTax: nycInfo?.tax ?? 0,
      
      // Yonkers Tax (if applicable)
      isYonkersResident: false,
      yonkersTax: 0,
      
      // Credits and payments
      credits: stateReturn.stateCredits,
      withholding: stateReturn.stateWithholding,
      estimatedPayments: stateReturn.stateEstimatedPayments,
      
      // Result
      refundOrOwed: stateReturn.stateRefundOrOwed,
    );
  }
  
  static double _getNYStandardDeduction(FilingStatus status) {
    // 2024 NY Standard Deductions
    return switch (status) {
      FilingStatus.single => 8000,
      FilingStatus.marriedFilingJointly => 16050,
      FilingStatus.marriedFilingSeparately => 8000,
      FilingStatus.headOfHousehold => 11200,
      FilingStatus.qualifyingWidow => 16050,
    };
  }
  
  static double _calculateNYAdditions(FederalReturn federal) {
    double additions = 0;
    
    // Interest on non-NY state/local bonds
    additions += federal.outOfStateBondInterest ?? 0;
    
    // Other NY additions
    
    return additions;
  }
  
  static double _calculateNYSubtractions(FederalReturn federal) {
    double subtractions = 0;
    
    // Interest on US government bonds
    subtractions += federal.usGovtBondInterest ?? 0;
    
    // Pensions from NY/local government
    subtractions += min(federal.nyGovtPension ?? 0, 20000);
    
    // Social Security (same as federal - partially taxable)
    // NY follows federal treatment
    
    return subtractions;
  }
}

class FormIT201 {
  final int taxYear;
  final FilingStatus filingStatus;
  final double federalAGI;
  final double nyAdditions;
  final double nySubtractions;
  final double nyAGI;
  final double nyStandardDeduction;
  final double? nyItemizedDeductions;
  final double nyTaxableIncome;
  final double nyTax;
  final bool isNYCResident;
  final double nycTax;
  final bool isYonkersResident;
  final double yonkersTax;
  final double credits;
  final double withholding;
  final double estimatedPayments;
  final double refundOrOwed;
  
  const FormIT201({
    required this.taxYear,
    required this.filingStatus,
    required this.federalAGI,
    required this.nyAdditions,
    required this.nySubtractions,
    required this.nyAGI,
    required this.nyStandardDeduction,
    this.nyItemizedDeductions,
    required this.nyTaxableIncome,
    required this.nyTax,
    required this.isNYCResident,
    required this.nycTax,
    required this.isYonkersResident,
    required this.yonkersTax,
    required this.credits,
    required this.withholding,
    required this.estimatedPayments,
    required this.refundOrOwed,
  });
  
  double get totalTax => nyTax + nycTax + yonkersTax;
}

class NYCResidentInfo {
  final bool isResident;
  final int monthsResident;
  final double tax;
  
  const NYCResidentInfo({
    required this.isResident,
    required this.monthsResident,
    required this.tax,
  });
}
```

---

## 4. State E-File Integration

### 4.1 State E-File Service

```dart
class StateEFileService {
  final MeFTransmissionService _federalTransmitter;
  final Map<String, StateTransmitter> _stateTransmitters;
  
  StateEFileService(
    this._federalTransmitter,
    this._stateTransmitters,
  );
  
  Future<StateSubmissionResult> submitStateReturn({
    required StateReturn stateReturn,
    required FederalReturn federalReturn,
  }) async {
    final state = StateTaxDatabase.getState(stateReturn.stateCode);
    
    if (state == null || !state.supportsEFile) {
      throw StateEFileException('State ${stateReturn.stateCode} does not support e-file');
    }
    
    // Get state-specific transmitter
    final transmitter = _stateTransmitters[stateReturn.stateCode];
    if (transmitter == null) {
      throw StateEFileException('No transmitter configured for ${stateReturn.stateCode}');
    }
    
    // Generate state XML
    final xml = await _generateStateXML(stateReturn, federalReturn, state);
    
    // Validate against state schema
    final validationResult = await transmitter.validateXML(xml);
    if (!validationResult.isValid) {
      return StateSubmissionResult.validationFailed(validationResult.errors);
    }
    
    // Submit to state
    final submission = await transmitter.submit(xml);
    
    return StateSubmissionResult.submitted(
      submissionId: submission.id,
      timestamp: submission.timestamp,
    );
  }
  
  Future<String> _generateStateXML(
    StateReturn stateReturn,
    FederalReturn federalReturn,
    StateTaxInfo state,
  ) async {
    // Each state has its own XML schema
    // This would use state-specific generators
    
    final generator = StateXMLGeneratorFactory.getGenerator(state.stateCode);
    return generator.generate(stateReturn, federalReturn);
  }
  
  Future<StateAcknowledgment> checkStateStatus(String submissionId, String stateCode) async {
    final transmitter = _stateTransmitters[stateCode];
    if (transmitter == null) {
      throw StateEFileException('No transmitter for $stateCode');
    }
    
    return transmitter.checkStatus(submissionId);
  }
}

abstract class StateTransmitter {
  Future<XMLValidationResult> validateXML(String xml);
  Future<StateSubmission> submit(String xml);
  Future<StateAcknowledgment> checkStatus(String submissionId);
}

class StateSubmissionResult {
  final bool success;
  final String? submissionId;
  final DateTime? timestamp;
  final List<String>? errors;
  
  const StateSubmissionResult._({
    required this.success,
    this.submissionId,
    this.timestamp,
    this.errors,
  });
  
  factory StateSubmissionResult.submitted({
    required String submissionId,
    required DateTime timestamp,
  }) => StateSubmissionResult._(
    success: true,
    submissionId: submissionId,
    timestamp: timestamp,
  );
  
  factory StateSubmissionResult.validationFailed(List<String> errors) =>
    StateSubmissionResult._(success: false, errors: errors);
}

class StateAcknowledgment {
  final String submissionId;
  final StateReturnStatus status;
  final String? rejectionCode;
  final String? rejectionMessage;
  final DateTime timestamp;
  
  const StateAcknowledgment({
    required this.submissionId,
    required this.status,
    this.rejectionCode,
    this.rejectionMessage,
    required this.timestamp,
  });
}
```

---

## 5. State Tax Calculator

### 5.1 State Tax Calculation Service

```dart
class StateTaxCalculator {
  double calculateStateTax({
    required String stateCode,
    required double taxableIncome,
    required FilingStatus filingStatus,
  }) {
    final state = StateTaxDatabase.getState(stateCode);
    if (state == null) return 0;
    
    if (state.requirement == StateFilingRequirement.noStateTax) {
      return 0;
    }
    
    // Flat tax states
    if (state.flatTaxRate != null) {
      return taxableIncome * state.flatTaxRate!;
    }
    
    // Graduated tax states
    if (state.brackets != null) {
      return _calculateGraduatedTax(taxableIncome, state.brackets!);
    }
    
    return 0;
  }
  
  double _calculateGraduatedTax(double income, List<TaxBracket> brackets) {
    double tax = 0;
    double remainingIncome = income;
    
    for (final bracket in brackets) {
      if (remainingIncome <= 0) break;
      
      final bracketSize = bracket.max - bracket.min;
      final taxableInBracket = min(remainingIncome, bracketSize);
      
      tax += taxableInBracket * bracket.rate;
      remainingIncome -= taxableInBracket;
    }
    
    return tax;
  }
  
  // Calculate effective state tax rate
  double calculateEffectiveRate({
    required String stateCode,
    required double taxableIncome,
    required FilingStatus filingStatus,
  }) {
    final tax = calculateStateTax(
      stateCode: stateCode,
      taxableIncome: taxableIncome,
      filingStatus: filingStatus,
    );
    
    return taxableIncome > 0 ? tax / taxableIncome : 0;
  }
  
  // Compare state tax burden
  Map<String, double> compareStateTaxes({
    required double taxableIncome,
    required FilingStatus filingStatus,
    required List<String> stateCodes,
  }) {
    final comparison = <String, double>{};
    
    for (final state in stateCodes) {
      comparison[state] = calculateStateTax(
        stateCode: state,
        taxableIncome: taxableIncome,
        filingStatus: filingStatus,
      );
    }
    
    return comparison;
  }
}
```

---

## 6. Database Schema

```sql
-- State Returns
CREATE TABLE state_returns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  federal_return_id UUID NOT NULL REFERENCES tax_returns(id),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  state_code TEXT NOT NULL,
  tax_year INTEGER NOT NULL,
  residency_status TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'not_started',
  
  -- Income
  state_wages DECIMAL(12,2) DEFAULT 0,
  state_adjustments DECIMAL(12,2) DEFAULT 0,
  state_agi DECIMAL(12,2) DEFAULT 0,
  state_deductions DECIMAL(12,2) DEFAULT 0,
  state_taxable_income DECIMAL(12,2) DEFAULT 0,
  
  -- Tax
  state_tax DECIMAL(12,2) DEFAULT 0,
  state_credits DECIMAL(12,2) DEFAULT 0,
  state_withholding DECIMAL(12,2) DEFAULT 0,
  state_estimated_payments DECIMAL(12,2) DEFAULT 0,
  state_refund_or_owed DECIMAL(12,2) DEFAULT 0,
  
  -- State-specific data
  state_specific_data JSONB DEFAULT '{}',
  
  -- E-file tracking
  submission_id TEXT,
  submitted_at TIMESTAMPTZ,
  accepted_at TIMESTAMPTZ,
  rejection_code TEXT,
  rejection_message TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(federal_return_id, state_code)
);

-- State Withholding (from W-2s)
CREATE TABLE state_withholding (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  state_return_id UUID NOT NULL REFERENCES state_returns(id),
  employer_ein TEXT NOT NULL,
  employer_name TEXT NOT NULL,
  state_code TEXT NOT NULL,
  state_wages DECIMAL(12,2) NOT NULL,
  state_tax_withheld DECIMAL(12,2) NOT NULL,
  local_wages DECIMAL(12,2),
  local_tax_withheld DECIMAL(12,2),
  locality_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_state_returns_federal ON state_returns(federal_return_id);
CREATE INDEX idx_state_returns_user ON state_returns(user_id);
CREATE INDEX idx_state_returns_state ON state_returns(state_code);

-- RLS Policies
ALTER TABLE state_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE state_withholding ENABLE ROW LEVEL SECURITY;

CREATE POLICY state_return_owner_access ON state_returns
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY withholding_owner_access ON state_withholding
  FOR ALL USING (
    state_return_id IN (SELECT id FROM state_returns WHERE user_id = auth.uid())
  );
```

---

## 7. Implementation Checklist

- [ ] Create StateTaxDatabase with all 50 states
- [ ] Implement state tax calculator for graduated/flat taxes
- [ ] Build multi-state determination logic
- [ ] Create state-specific form generators (CA, NY, etc.)
- [ ] Implement other state credit calculator
- [ ] Build state e-file integration
- [ ] Create state XML generators
- [ ] Add state rejection handling
- [ ] Implement database schema
- [ ] Build state selection UI

---

## 8. Related Documents

- [Tax Forms](./tax_forms.md)
- [Calculations](./calculations.md)
- [E-File Transmission](./efile_transmission.md)
- [Error Handling](./error_handling.md)
