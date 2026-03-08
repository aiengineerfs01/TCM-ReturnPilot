# Taxpayer Data Collection & Validation

## Overview

This document specifies all taxpayer information required for IRS e-filing, validation rules, and UI implementation guidelines.

---

## 1. Primary Taxpayer Information

### 1.1 Personal Identification

```dart
// Proposed Model: TaxpayerModel
class TaxpayerModel {
  // Primary Identification
  final String id;                        // UUID
  final String firstName;                 // Required, max 35 chars
  final String? middleInitial;            // Optional, 1 char
  final String lastName;                  // Required, max 35 chars
  final String? suffix;                   // Jr., Sr., III, etc.
  final String ssn;                       // XXX-XX-XXXX, encrypted
  final DateTime dateOfBirth;             // Required for age-based credits
  
  // Contact Information
  final String? email;                    // For notifications
  final String? phoneNumber;              // For IRS contact
  
  // Address
  final Address currentAddress;           // Required
  
  // Filing Information
  final FilingStatus filingStatus;        // Required
  final bool isBlind;                     // For standard deduction
  final bool claimedAsDependent;          // By another taxpayer
  final bool is65OrOlder;                 // Computed from DOB
  final String? occupation;               // Required for e-file
  
  // Identity PIN (optional)
  final String? identityProtectionPin;    // 6-digit IRS IP PIN
}
```

### 1.2 SSN Validation Rules

```dart
// SSN Validation
class SSNValidator {
  static bool isValid(String ssn) {
    // Remove formatting
    final cleaned = ssn.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleaned.length != 9) return false;
    
    // IRS Invalid SSN Rules:
    // - Cannot start with 9 (reserved for ITIN)
    // - Cannot be 000-XX-XXXX
    // - Cannot be XXX-00-XXXX
    // - Cannot be XXX-XX-0000
    // - Cannot be 666-XX-XXXX (historical)
    // - Cannot be 123-45-6789 or other test SSNs
    
    final area = cleaned.substring(0, 3);
    final group = cleaned.substring(3, 5);
    final serial = cleaned.substring(5, 9);
    
    if (area == '000' || area == '666' || area[0] == '9') return false;
    if (group == '00') return false;
    if (serial == '0000') return false;
    
    // Test SSNs (IRS uses these for testing)
    const testSSNs = [
      '123456789', '987654321', '000000000',
      '111111111', '222222222', '333333333',
    ];
    if (testSSNs.contains(cleaned)) return false;
    
    return true;
  }
  
  static String format(String ssn) {
    final cleaned = ssn.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 9) return ssn;
    return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 5)}-${cleaned.substring(5, 9)}';
  }
}
```

### 1.3 Address Model

```dart
class Address {
  final String streetAddress1;     // Required, max 35 chars
  final String? streetAddress2;    // Optional, max 35 chars
  final String city;               // Required, max 22 chars
  final String state;              // 2-letter code
  final String zipCode;            // 5 or 9 digit
  final String? country;           // For foreign addresses
  final bool isForeign;            // Default: false
  final String? foreignProvince;   // If foreign
  final String? foreignPostalCode; // If foreign
  
  // Address Validation
  bool isValid() {
    if (streetAddress1.isEmpty || streetAddress1.length > 35) return false;
    if (city.isEmpty || city.length > 22) return false;
    if (!_isValidState(state)) return false;
    if (!_isValidZip(zipCode)) return false;
    return true;
  }
  
  static bool _isValidState(String state) {
    const validStates = [
      'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
      'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
      'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
      'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
      'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
      'DC', 'PR', 'VI', 'GU', 'AS', 'MP', // Territories
    ];
    return validStates.contains(state.toUpperCase());
  }
  
  static bool _isValidZip(String zip) {
    final cleaned = zip.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length == 5 || cleaned.length == 9;
  }
}
```

---

## 2. Filing Status

### 2.1 Status Types

```dart
enum FilingStatus {
  single,
  marriedFilingJointly,
  marriedFilingSeparately,
  headOfHousehold,
  qualifyingSurvivingSpouse,
}

extension FilingStatusX on FilingStatus {
  String get code {
    switch (this) {
      case FilingStatus.single: return '1';
      case FilingStatus.marriedFilingJointly: return '2';
      case FilingStatus.marriedFilingSeparately: return '3';
      case FilingStatus.headOfHousehold: return '4';
      case FilingStatus.qualifyingSurvivingSpouse: return '5';
    }
  }
  
  String get label {
    switch (this) {
      case FilingStatus.single: return 'Single';
      case FilingStatus.marriedFilingJointly: return 'Married Filing Jointly';
      case FilingStatus.marriedFilingSeparately: return 'Married Filing Separately';
      case FilingStatus.headOfHousehold: return 'Head of Household';
      case FilingStatus.qualifyingSurvivingSpouse: return 'Qualifying Surviving Spouse';
    }
  }
  
  int get standardDeduction2024 {
    switch (this) {
      case FilingStatus.single: return 14600;
      case FilingStatus.marriedFilingJointly: return 29200;
      case FilingStatus.marriedFilingSeparately: return 14600;
      case FilingStatus.headOfHousehold: return 21900;
      case FilingStatus.qualifyingSurvivingSpouse: return 29200;
    }
  }
}
```

### 2.2 Filing Status Determination Logic

```dart
class FilingStatusDeterminer {
  static List<FilingStatus> getEligibleStatuses({
    required bool isMarried,
    required bool livedWithSpouse,
    required bool hasQualifyingPerson,
    required bool spouseDiedIn2023Or2024,
    required bool hasDependentChild,
  }) {
    List<FilingStatus> eligible = [];
    
    if (!isMarried) {
      eligible.add(FilingStatus.single);
      
      if (hasQualifyingPerson) {
        eligible.add(FilingStatus.headOfHousehold);
      }
    } else {
      eligible.add(FilingStatus.marriedFilingJointly);
      eligible.add(FilingStatus.marriedFilingSeparately);
      
      // Head of Household while married
      if (!livedWithSpouse && hasQualifyingPerson) {
        eligible.add(FilingStatus.headOfHousehold);
      }
    }
    
    // Qualifying Surviving Spouse
    if (spouseDiedIn2023Or2024 && hasDependentChild) {
      eligible.add(FilingStatus.qualifyingSurvivingSpouse);
    }
    
    return eligible;
  }
}
```

---

## 3. Spouse Information (If MFJ)

### 3.1 Spouse Model

```dart
class SpouseModel {
  final String firstName;
  final String? middleInitial;
  final String lastName;
  final String? suffix;
  final String ssn;                       // Encrypted
  final DateTime dateOfBirth;
  final bool isBlind;
  final bool is65OrOlder;
  final String? occupation;
  final String? identityProtectionPin;
  
  // For MFS, also need:
  final String? spouseItemizedDeductions;  // If MFS and spouse itemizes
}
```

---

## 4. Dependent Information

### 4.1 Dependent Model

```dart
class DependentModel {
  final String firstName;
  final String? middleInitial;
  final String lastName;
  final String? suffix;
  final String ssn;                        // Or ITIN/ATIN
  final String relationship;               // See relationship codes
  final DateTime dateOfBirth;
  final int monthsLivedInHome;            // Must be >6 for most credits
  
  // Qualifying Tests
  final bool isQualifyingChild;           // Computed
  final bool isQualifyingRelative;        // Computed
  final bool eligibleForCTC;              // Child Tax Credit
  final bool eligibleForODC;              // Other Dependent Credit
  final bool eligibleForEIC;              // Earned Income Credit
  final bool eligibleForCDCC;             // Child & Dependent Care Credit
  final bool eligibleForHOH;              // Head of Household
  
  // Status
  final bool isStudent;                   // Full-time student
  final bool isPermanentlyDisabled;
  final bool providedOwnSupport;          // > 50%
  
  // Income
  final double grossIncome;               // For relative test
}

// IRS Relationship Codes
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
  sisterInLaw,
  brotherInLaw,
  sonInLaw,
  daughterInLaw,
  motherInLaw,
  fatherInLaw,
  none,  // Unrelated person living with taxpayer
}
```

### 4.2 Dependent Qualification Logic

```dart
class DependentQualifier {
  static bool isQualifyingChild({
    required DependentModel dependent,
    required TaxpayerModel taxpayer,
    required int taxYear,
  }) {
    // 1. Relationship Test
    final qualifyingRelationships = [
      DependentRelationship.son,
      DependentRelationship.daughter,
      DependentRelationship.stepson,
      DependentRelationship.stepdaughter,
      DependentRelationship.fosterChild,
      DependentRelationship.brother,
      DependentRelationship.sister,
      DependentRelationship.halfBrother,
      DependentRelationship.halfSister,
      DependentRelationship.stepbrother,
      DependentRelationship.stepsister,
      DependentRelationship.grandchild,
      DependentRelationship.niece,
      DependentRelationship.nephew,
    ];
    if (!qualifyingRelationships.contains(dependent.relationship)) {
      return false;
    }
    
    // 2. Age Test
    final ageAtEndOfYear = taxYear - dependent.dateOfBirth.year;
    final under19 = ageAtEndOfYear < 19;
    final under24AndStudent = ageAtEndOfYear < 24 && dependent.isStudent;
    final anyAgeIfDisabled = dependent.isPermanentlyDisabled;
    
    if (!under19 && !under24AndStudent && !anyAgeIfDisabled) {
      return false;
    }
    
    // 3. Residency Test
    if (dependent.monthsLivedInHome < 6) return false;
    
    // 4. Support Test
    if (dependent.providedOwnSupport) return false;
    
    // 5. Joint Return Test (would need additional data)
    
    return true;
  }
  
  static bool isQualifyingRelative({
    required DependentModel dependent,
    required TaxpayerModel taxpayer,
    required int taxYear,
  }) {
    // 1. Not a Qualifying Child of anyone
    
    // 2. Member of household OR qualifying relationship
    
    // 3. Gross Income Test ($4,700 for 2024)
    final grossIncomeLimit = 4700; // Updated annually
    if (dependent.grossIncome > grossIncomeLimit) return false;
    
    // 4. Support Test - taxpayer provides >50%
    
    return true;
  }
  
  static bool eligibleForChildTaxCredit({
    required DependentModel dependent,
    required int taxYear,
  }) {
    final ageAtEndOfYear = taxYear - dependent.dateOfBirth.year;
    return ageAtEndOfYear < 17 && dependent.isQualifyingChild;
  }
}
```

---

## 5. UI Implementation Guide

### 5.1 Screen Flow

```
┌─────────────────────┐
│   Filing Status     │  Step 1: Determine filing status
│   Selection         │  → Affects all subsequent screens
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Primary Taxpayer   │  Step 2: Your information
│   Information       │  → Name, SSN, DOB, Address
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Spouse Info        │  Step 3: Only if MFJ/MFS
│  (Conditional)      │  → Spouse name, SSN, DOB
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Dependents        │  Step 4: Add dependents
│   (Multiple)        │  → For each: name, SSN, relationship
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Review & Confirm   │  Step 5: Summary screen
│                     │  → Verify all information
└─────────────────────┘
```

### 5.2 Required Screens

| Screen | Purpose | Fields |
|--------|---------|--------|
| `FilingStatusScreen` | Determine filing status | Questions to determine status |
| `PersonalInfoScreen` | Primary taxpayer info | Name, SSN, DOB, occupation |
| `AddressScreen` | Current address | Street, city, state, zip |
| `SpouseInfoScreen` | Spouse information | Same as primary |
| `DependentListScreen` | List all dependents | Add/edit/remove dependents |
| `AddDependentScreen` | Single dependent entry | Dependent details |
| `ReviewPersonalScreen` | Review all personal info | Summary view |

### 5.3 Input Masking

```dart
// SSN Input Formatter
class SSNInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 9; i++) {
      if (i == 3 || i == 5) buffer.write('-');
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Phone Input Formatter
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 10; i++) {
      if (i == 0) buffer.write('(');
      if (i == 3) buffer.write(') ');
      if (i == 6) buffer.write('-');
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// ZIP Code Formatter
class ZipCodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 9; i++) {
      if (i == 5) buffer.write('-');
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
```

---

## 6. Data Security Requirements

### 6.1 SSN Encryption

```dart
// SSN must be encrypted at rest
class SSNEncryption {
  // Use AES-256 encryption
  // Key management via secure key store
  // Never store plain SSN in database
  // Mask display: XXX-XX-1234 (last 4 only)
  
  static String mask(String ssn) {
    if (ssn.length < 4) return '***-**-****';
    return 'XXX-XX-${ssn.substring(ssn.length - 4)}';
  }
}
```

### 6.2 Audit Requirements

```dart
// All taxpayer data access must be logged
class TaxpayerDataAuditLog {
  final String action;          // 'view', 'create', 'update', 'delete'
  final String userId;          // Who performed action
  final String taxpayerId;      // Whose data was accessed
  final String dataType;        // 'ssn', 'address', etc.
  final DateTime timestamp;
  final String ipAddress;
  final String deviceInfo;
}
```

---

## 7. Database Schema

### 7.1 Supabase Tables

```sql
-- Taxpayers table
CREATE TABLE taxpayers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  tax_year INTEGER NOT NULL,
  first_name VARCHAR(35) NOT NULL,
  middle_initial VARCHAR(1),
  last_name VARCHAR(35) NOT NULL,
  suffix VARCHAR(10),
  ssn_encrypted BYTEA NOT NULL,  -- Encrypted SSN
  ssn_last_four VARCHAR(4) NOT NULL,  -- For display
  date_of_birth DATE NOT NULL,
  is_blind BOOLEAN DEFAULT FALSE,
  is_65_or_older BOOLEAN,
  occupation VARCHAR(50),
  ip_pin VARCHAR(6),  -- Encrypted
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, tax_year)
);

-- Addresses table
CREATE TABLE taxpayer_addresses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taxpayer_id UUID REFERENCES taxpayers(id) NOT NULL,
  address_type VARCHAR(20) DEFAULT 'current',  -- current, previous
  street_address_1 VARCHAR(35) NOT NULL,
  street_address_2 VARCHAR(35),
  city VARCHAR(22) NOT NULL,
  state VARCHAR(2) NOT NULL,
  zip_code VARCHAR(10) NOT NULL,
  is_foreign BOOLEAN DEFAULT FALSE,
  country VARCHAR(50),
  foreign_province VARCHAR(50),
  foreign_postal_code VARCHAR(20),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Spouses table
CREATE TABLE spouses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taxpayer_id UUID REFERENCES taxpayers(id) NOT NULL,
  first_name VARCHAR(35) NOT NULL,
  middle_initial VARCHAR(1),
  last_name VARCHAR(35) NOT NULL,
  suffix VARCHAR(10),
  ssn_encrypted BYTEA NOT NULL,
  ssn_last_four VARCHAR(4) NOT NULL,
  date_of_birth DATE NOT NULL,
  is_blind BOOLEAN DEFAULT FALSE,
  is_65_or_older BOOLEAN,
  occupation VARCHAR(50),
  ip_pin VARCHAR(6),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(taxpayer_id)
);

-- Dependents table
CREATE TABLE dependents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taxpayer_id UUID REFERENCES taxpayers(id) NOT NULL,
  first_name VARCHAR(35) NOT NULL,
  middle_initial VARCHAR(1),
  last_name VARCHAR(35) NOT NULL,
  suffix VARCHAR(10),
  ssn_encrypted BYTEA,  -- May not have SSN
  ssn_last_four VARCHAR(4),
  date_of_birth DATE NOT NULL,
  relationship VARCHAR(30) NOT NULL,
  months_lived_in_home INTEGER NOT NULL,
  is_student BOOLEAN DEFAULT FALSE,
  is_permanently_disabled BOOLEAN DEFAULT FALSE,
  is_qualifying_child BOOLEAN,
  is_qualifying_relative BOOLEAN,
  eligible_ctc BOOLEAN DEFAULT FALSE,
  eligible_odc BOOLEAN DEFAULT FALSE,
  eligible_eic BOOLEAN DEFAULT FALSE,
  gross_income DECIMAL(12,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Filing status table
CREATE TABLE filing_status (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  taxpayer_id UUID REFERENCES taxpayers(id) NOT NULL,
  status VARCHAR(30) NOT NULL,
  spouse_ssn_encrypted BYTEA,  -- For MFS
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(taxpayer_id)
);
```

---

## 8. Integration with Existing App

### 8.1 Profile Model Extension

The existing `ProfileModel` should be extended to reference tax data:

```dart
// Add to ProfileModel
class ProfileModel {
  // ... existing fields ...
  
  // Tax-related references
  final String? activeTaxReturnId;    // Current tax return being prepared
  final List<String>? taxReturnIds;   // All tax returns for this user
  final bool hasPendingReturn;        // Return in progress
}
```

### 8.2 Interview Integration

The AI interview system can be used to collect taxpayer data:

```dart
// Interview prompts for taxpayer data
const taxpayerDataPrompts = {
  'filing_status': 'What is your current marital status?',
  'dependents': 'Do you have any dependents you can claim on your tax return?',
  'address': 'What is your current home address?',
  // ... more prompts
};
```

---

## Next Steps

1. **Create Models**: Implement Dart models in `lib/models/tax/`
2. **Create Validators**: Implement validation in `lib/utils/validators/`
3. **Create Screens**: Implement UI in `lib/presentation/tax/`
4. **Update Supabase**: Add tables via migrations
5. **Integrate Interview**: Add tax data collection to AI chat

---

## Related Documents

- [Tax Forms Implementation](./tax_forms.md)
- [Income Sources](./income_sources.md)
- [Data Models](./data_models.md)
