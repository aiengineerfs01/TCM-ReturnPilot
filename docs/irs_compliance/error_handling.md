# IRS Error Handling & Rejection Codes

## Overview

This document details IRS rejection codes, error handling procedures, and resolution workflows for e-filed returns per IRS Publication 4164 and MeF Business Rules.

---

## 1. IRS Rejection Types

### 1.1 Rejection Categories

```dart
enum RejectionCategory {
  businessRule,          // MeF Business Rule violation
  schemaValidation,      // XML schema validation error
  duplicateReturn,       // Return already filed
  identityMismatch,      // SSN/Name/DOB doesn't match IRS records
  priorYearAgi,          // Prior year AGI doesn't match
  pinValidation,         // Self-select PIN issues
  dependentClaimed,      // Dependent already claimed
  efin,                  // EFIN/ERO issues
  transmission,          // Transmission/communication errors
}

class IrsRejection {
  final String errorCode;
  final String errorCategory;
  final RejectionCategory category;
  final String description;
  final String resolution;
  final bool isRetryable;
  final bool requiresAmendment;
  final List<String> affectedFields;
  final String? supportDocUrl;
  
  const IrsRejection({
    required this.errorCode,
    required this.errorCategory,
    required this.category,
    required this.description,
    required this.resolution,
    required this.isRetryable,
    required this.requiresAmendment,
    required this.affectedFields,
    this.supportDocUrl,
  });
}
```

### 1.2 Common Rejection Codes

```dart
class IrsRejectionCodes {
  // Identity & Authentication Errors
  static const identityRejections = <String, IrsRejection>{
    'IND-031': IrsRejection(
      errorCode: 'IND-031',
      errorCategory: 'Individual',
      category: RejectionCategory.identityMismatch,
      description: 'Primary taxpayer SSN and name do not match IRS records',
      resolution: 'Verify SSN and name match Social Security card exactly. Contact SSA if records need updating.',
      isRetryable: true,
      requiresAmendment: false,
      affectedFields: ['primarySSN', 'primaryFirstName', 'primaryLastName'],
      supportDocUrl: 'https://www.irs.gov/identity-theft-fraud-scams/get-an-identity-protection-pin',
    ),
    
    'IND-032': IrsRejection(
      errorCode: 'IND-032',
      errorCategory: 'Individual',
      category: RejectionCategory.identityMismatch,
      description: 'Spouse SSN and name do not match IRS records',
      resolution: 'Verify spouse SSN and name match Social Security card exactly.',
      isRetryable: true,
      requiresAmendment: false,
      affectedFields: ['spouseSSN', 'spouseFirstName', 'spouseLastName'],
    ),
    
    'IND-180': IrsRejection(
      errorCode: 'IND-180',
      errorCategory: 'Individual',
      category: RejectionCategory.identityMismatch,
      description: 'Primary taxpayer date of birth does not match IRS records',
      resolution: 'Verify date of birth is correct. Contact SSA if records need updating.',
      isRetryable: true,
      requiresAmendment: false,
      affectedFields: ['primaryDateOfBirth'],
    ),
  };
  
  // Prior Year AGI Errors
  static const agiRejections = <String, IrsRejection>{
    'IND-031-04': IrsRejection(
      errorCode: 'IND-031-04',
      errorCategory: 'Individual',
      category: RejectionCategory.priorYearAgi,
      description: 'Prior year AGI does not match IRS records',
      resolution: 'Use exact AGI from prior year return line 11. If using Get Transcript, use AGI shown. If no prior return, enter 0.',
      isRetryable: true,
      requiresAmendment: false,
      affectedFields: ['priorYearAGI'],
      supportDocUrl: 'https://www.irs.gov/individuals/get-transcript',
    ),
    
    'IND-032-04': IrsRejection(
      errorCode: 'IND-032-04',
      errorCategory: 'Individual',
      category: RejectionCategory.priorYearAgi,
      description: 'Spouse prior year AGI does not match IRS records',
      resolution: 'Verify spouse AGI from prior year return. Use AGI from their return if filed separately last year.',
      isRetryable: true,
      requiresAmendment: false,
      affectedFields: ['spousePriorYearAGI'],
    ),
  };
  
  // IP PIN Errors
  static const ipPinRejections = <String, IrsRejection>{
    'IND-181': IrsRejection(
      errorCode: 'IND-181',
      errorCategory: 'Individual',
      category: RejectionCategory.pinValidation,
      description: 'Primary taxpayer Identity Protection PIN is missing or invalid',
      resolution: 'An IP PIN is required for this taxpayer. Retrieve IP PIN from IRS online or by mail.',
      isRetryable: true,
      requiresAmendment: false,
      affectedFields: ['primaryIPPIN'],
      supportDocUrl: 'https://www.irs.gov/identity-theft-fraud-scams/get-an-identity-protection-pin',
    ),
    
    'IND-182': IrsRejection(
      errorCode: 'IND-182',
      errorCategory: 'Individual',
      category: RejectionCategory.pinValidation,
      description: 'Spouse Identity Protection PIN is missing or invalid',
      resolution: 'An IP PIN is required for the spouse. Retrieve IP PIN from IRS online or by mail.',
      isRetryable: true,
      requiresAmendment: false,
      affectedFields: ['spouseIPPIN'],
    ),
  };
  
  // Dependent Errors
  static const dependentRejections = <String, IrsRejection>{
    'IND-510': IrsRejection(
      errorCode: 'IND-510',
      errorCategory: 'Individual',
      category: RejectionCategory.dependentClaimed,
      description: 'Dependent SSN has been used on another return',
      resolution: 'The dependent may have been claimed on another return or filed their own return claiming themselves. Verify dependency eligibility.',
      isRetryable: false, // Cannot retry without resolution
      requiresAmendment: false,
      affectedFields: ['dependentSSN'],
    ),
    
    'IND-511': IrsRejection(
      errorCode: 'IND-511',
      errorCategory: 'Individual',
      category: RejectionCategory.dependentClaimed,
      description: 'Dependent SSN has been used as primary or spouse SSN on another return',
      resolution: 'Dependent cannot be claimed if they filed their own return. Verify dependent status.',
      isRetryable: false,
      requiresAmendment: false,
      affectedFields: ['dependentSSN'],
    ),
  };
  
  // Duplicate Return Errors
  static const duplicateRejections = <String, IrsRejection>{
    'IND-515': IrsRejection(
      errorCode: 'IND-515',
      errorCategory: 'Individual',
      category: RejectionCategory.duplicateReturn,
      description: 'A return for this SSN has already been filed and accepted',
      resolution: 'A return has already been filed for this tax year. If you did not file, identity theft may have occurred.',
      isRetryable: false,
      requiresAmendment: true, // Must paper file or file amended
      affectedFields: ['primarySSN'],
      supportDocUrl: 'https://www.irs.gov/identity-theft-fraud-scams/identity-theft-victim-assistance',
    ),
  };
  
  // EFIN Errors
  static const efinRejections = <String, IrsRejection>{
    'R0000-500': IrsRejection(
      errorCode: 'R0000-500',
      errorCategory: 'EFIN',
      category: RejectionCategory.efin,
      description: 'EFIN is not valid or not authorized to submit returns',
      resolution: 'Contact your transmitter or verify EFIN authorization with IRS.',
      isRetryable: false,
      requiresAmendment: false,
      affectedFields: ['efin'],
    ),
  };
  
  // Schema Validation Errors
  static const schemaRejections = <String, IrsRejection>{
    'X0000-005': IrsRejection(
      errorCode: 'X0000-005',
      errorCategory: 'Schema',
      category: RejectionCategory.schemaValidation,
      description: 'XML schema validation failed - required element missing',
      resolution: 'Review return for missing required fields. Ensure all mandatory elements are present.',
      isRetryable: true,
      requiresAmendment: false,
      affectedFields: [], // Depends on specific error
    ),
    
    'X0000-006': IrsRejection(
      errorCode: 'X0000-006',
      errorCategory: 'Schema',
      category: RejectionCategory.schemaValidation,
      description: 'XML schema validation failed - invalid data format',
      resolution: 'Review field formats. Ensure dates, amounts, and identifiers match expected formats.',
      isRetryable: true,
      requiresAmendment: false,
      affectedFields: [],
    ),
  };
  
  // Get rejection details by code
  static IrsRejection? getByCode(String code) {
    return identityRejections[code] ??
           agiRejections[code] ??
           ipPinRejections[code] ??
           dependentRejections[code] ??
           duplicateRejections[code] ??
           efinRejections[code] ??
           schemaRejections[code];
  }
  
  // Get all rejections for category
  static List<IrsRejection> getByCategory(RejectionCategory category) {
    final all = [
      ...identityRejections.values,
      ...agiRejections.values,
      ...ipPinRejections.values,
      ...dependentRejections.values,
      ...duplicateRejections.values,
      ...efinRejections.values,
      ...schemaRejections.values,
    ];
    return all.where((r) => r.category == category).toList();
  }
}
```

---

## 2. Error Handling Service

### 2.1 Rejection Handler

```dart
class RejectionHandlerService {
  final SupabaseClient _supabase;
  final NotificationService _notificationService;
  final AuditLogService _auditService;
  
  RejectionHandlerService(
    this._supabase,
    this._notificationService,
    this._auditService,
  );
  
  Future<RejectionAnalysis> analyzeRejection({
    required String returnId,
    required String errorCode,
    required String errorMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    // Look up rejection details
    final rejection = IrsRejectionCodes.getByCode(errorCode);
    
    // Determine resolution path
    final resolutionPath = _determineResolutionPath(rejection, errorCode);
    
    // Log rejection
    await _logRejection(
      returnId: returnId,
      errorCode: errorCode,
      errorMessage: errorMessage,
      rejection: rejection,
    );
    
    // Create analysis result
    final analysis = RejectionAnalysis(
      errorCode: errorCode,
      rejection: rejection,
      resolutionPath: resolutionPath,
      userGuidance: _generateUserGuidance(rejection, errorCode, errorMessage),
      requiredActions: _getRequiredActions(rejection),
      canAutoRetry: resolutionPath == ResolutionPath.autoRetry,
    );
    
    // Send notification to user
    await _notificationService.sendRejectionNotification(
      returnId: returnId,
      analysis: analysis,
    );
    
    return analysis;
  }
  
  ResolutionPath _determineResolutionPath(IrsRejection? rejection, String errorCode) {
    if (rejection == null) {
      return ResolutionPath.manualReview;
    }
    
    if (rejection.requiresAmendment) {
      return ResolutionPath.amendment;
    }
    
    if (!rejection.isRetryable) {
      return ResolutionPath.manualReview;
    }
    
    // Identity mismatches can often be auto-corrected
    if (rejection.category == RejectionCategory.identityMismatch) {
      return ResolutionPath.userCorrection;
    }
    
    // AGI issues need user to provide correct value
    if (rejection.category == RejectionCategory.priorYearAgi) {
      return ResolutionPath.userCorrection;
    }
    
    // IP PIN issues require user action
    if (rejection.category == RejectionCategory.pinValidation) {
      return ResolutionPath.userCorrection;
    }
    
    return ResolutionPath.userCorrection;
  }
  
  String _generateUserGuidance(
    IrsRejection? rejection,
    String errorCode,
    String errorMessage,
  ) {
    if (rejection != null) {
      return '''
## Your return was rejected

**Error Code:** $errorCode

**What happened:** ${rejection.description}

**How to fix it:** ${rejection.resolution}

${rejection.supportDocUrl != null ? '[Learn more](${rejection.supportDocUrl})' : ''}
''';
    }
    
    return '''
## Your return was rejected

**Error Code:** $errorCode

**IRS Message:** $errorMessage

Our team is reviewing this error. We'll contact you with next steps.
''';
  }
  
  List<RequiredAction> _getRequiredActions(IrsRejection? rejection) {
    if (rejection == null) {
      return [RequiredAction.contactSupport];
    }
    
    final actions = <RequiredAction>[];
    
    switch (rejection.category) {
      case RejectionCategory.identityMismatch:
        actions.add(RequiredAction.verifyPersonalInfo);
        actions.add(RequiredAction.updateSSARecords);
        break;
      case RejectionCategory.priorYearAgi:
        actions.add(RequiredAction.providePriorYearAGI);
        actions.add(RequiredAction.requestTranscript);
        break;
      case RejectionCategory.pinValidation:
        actions.add(RequiredAction.obtainIPPIN);
        break;
      case RejectionCategory.dependentClaimed:
        actions.add(RequiredAction.verifyDependentEligibility);
        actions.add(RequiredAction.contactSupport);
        break;
      case RejectionCategory.duplicateReturn:
        actions.add(RequiredAction.verifyIdentityTheft);
        actions.add(RequiredAction.fileForm14039);
        break;
      default:
        actions.add(RequiredAction.reviewReturn);
    }
    
    return actions;
  }
  
  Future<void> _logRejection({
    required String returnId,
    required String errorCode,
    required String errorMessage,
    IrsRejection? rejection,
  }) async {
    await _supabase.from('return_rejections').insert({
      'return_id': returnId,
      'error_code': errorCode,
      'error_message': errorMessage,
      'error_category': rejection?.errorCategory,
      'rejection_category': rejection?.category.name,
      'is_retryable': rejection?.isRetryable ?? false,
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await _auditService.log(
      eventType: AuditEventType.returnRejected,
      action: 'Return rejected by IRS',
      resourceType: 'tax_return',
      resourceId: returnId,
      metadata: {
        'error_code': errorCode,
        'error_message': errorMessage,
        'is_retryable': rejection?.isRetryable ?? false,
      },
    );
  }
}

enum ResolutionPath {
  autoRetry,       // System can automatically retry
  userCorrection,  // User needs to make changes
  manualReview,    // Staff needs to review
  amendment,       // Must file amended return
  paperFile,       // Must paper file
}

enum RequiredAction {
  verifyPersonalInfo,
  updateSSARecords,
  providePriorYearAGI,
  requestTranscript,
  obtainIPPIN,
  verifyDependentEligibility,
  verifyIdentityTheft,
  fileForm14039,
  reviewReturn,
  contactSupport,
}

class RejectionAnalysis {
  final String errorCode;
  final IrsRejection? rejection;
  final ResolutionPath resolutionPath;
  final String userGuidance;
  final List<RequiredAction> requiredActions;
  final bool canAutoRetry;
  
  const RejectionAnalysis({
    required this.errorCode,
    this.rejection,
    required this.resolutionPath,
    required this.userGuidance,
    required this.requiredActions,
    required this.canAutoRetry,
  });
}
```

---

## 3. Client-Side Validation

### 3.1 Pre-Submission Validation

```dart
class PreSubmissionValidator {
  // Run all validations before e-file submission
  Future<ValidationResult> validateReturn(TaxReturn taxReturn) async {
    final errors = <ValidationError>[];
    final warnings = <ValidationWarning>[];
    
    // Required field validation
    errors.addAll(_validateRequiredFields(taxReturn));
    
    // SSN format validation
    errors.addAll(_validateSSNFormats(taxReturn));
    
    // Calculation validation
    errors.addAll(_validateCalculations(taxReturn));
    
    // Business rule validation
    errors.addAll(await _validateBusinessRules(taxReturn));
    
    // Dependent validation
    errors.addAll(_validateDependents(taxReturn));
    
    // Income validation
    errors.addAll(_validateIncome(taxReturn));
    
    // Generate warnings for common rejection causes
    warnings.addAll(_generateWarnings(taxReturn));
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  List<ValidationError> _validateRequiredFields(TaxReturn taxReturn) {
    final errors = <ValidationError>[];
    
    // Primary taxpayer
    if (taxReturn.primarySSN.isEmpty) {
      errors.add(ValidationError(
        field: 'primarySSN',
        code: 'REQUIRED_FIELD',
        message: 'Primary SSN is required',
        severity: ErrorSeverity.error,
      ));
    }
    
    if (taxReturn.firstName.isEmpty) {
      errors.add(ValidationError(
        field: 'firstName',
        code: 'REQUIRED_FIELD',
        message: 'First name is required',
        severity: ErrorSeverity.error,
      ));
    }
    
    if (taxReturn.lastName.isEmpty) {
      errors.add(ValidationError(
        field: 'lastName',
        code: 'REQUIRED_FIELD',
        message: 'Last name is required',
        severity: ErrorSeverity.error,
      ));
    }
    
    // Filing status specific validations
    if (taxReturn.filingStatus == FilingStatus.marriedFilingJointly) {
      if (taxReturn.spouseSSN?.isEmpty ?? true) {
        errors.add(ValidationError(
          field: 'spouseSSN',
          code: 'REQUIRED_FIELD',
          message: 'Spouse SSN is required for MFJ filing',
          severity: ErrorSeverity.error,
        ));
      }
    }
    
    // Signature validation
    if (!taxReturn.hasValidSignature) {
      errors.add(ValidationError(
        field: 'signature',
        code: 'MISSING_SIGNATURE',
        message: 'Electronic signature is required',
        severity: ErrorSeverity.error,
      ));
    }
    
    return errors;
  }
  
  List<ValidationError> _validateSSNFormats(TaxReturn taxReturn) {
    final errors = <ValidationError>[];
    
    if (!SSNValidator.isValidFormat(taxReturn.primarySSN)) {
      errors.add(ValidationError(
        field: 'primarySSN',
        code: 'INVALID_SSN_FORMAT',
        message: 'Primary SSN format is invalid',
        severity: ErrorSeverity.error,
      ));
    }
    
    if (taxReturn.spouseSSN != null && 
        !SSNValidator.isValidFormat(taxReturn.spouseSSN!)) {
      errors.add(ValidationError(
        field: 'spouseSSN',
        code: 'INVALID_SSN_FORMAT',
        message: 'Spouse SSN format is invalid',
        severity: ErrorSeverity.error,
      ));
    }
    
    for (final dependent in taxReturn.dependents) {
      if (!SSNValidator.isValidFormat(dependent.ssn)) {
        errors.add(ValidationError(
          field: 'dependentSSN',
          code: 'INVALID_SSN_FORMAT',
          message: 'Dependent ${dependent.firstName} SSN format is invalid',
          severity: ErrorSeverity.error,
        ));
      }
    }
    
    return errors;
  }
  
  List<ValidationError> _validateCalculations(TaxReturn taxReturn) {
    final errors = <ValidationError>[];
    
    // Verify total income
    final calculatedTotalIncome = taxReturn.wages + 
        taxReturn.interestIncome + 
        taxReturn.dividendIncome +
        taxReturn.businessIncome +
        taxReturn.capitalGains +
        taxReturn.otherIncome;
    
    if ((calculatedTotalIncome - taxReturn.totalIncome).abs() > 0.01) {
      errors.add(ValidationError(
        field: 'totalIncome',
        code: 'CALCULATION_ERROR',
        message: 'Total income calculation mismatch',
        severity: ErrorSeverity.error,
      ));
    }
    
    // Verify AGI
    final calculatedAGI = taxReturn.totalIncome - taxReturn.adjustmentsToIncome;
    if ((calculatedAGI - taxReturn.agi).abs() > 0.01) {
      errors.add(ValidationError(
        field: 'agi',
        code: 'CALCULATION_ERROR',
        message: 'AGI calculation mismatch',
        severity: ErrorSeverity.error,
      ));
    }
    
    // Verify taxable income
    final calculatedTaxableIncome = taxReturn.agi - taxReturn.totalDeductions;
    if ((calculatedTaxableIncome - taxReturn.taxableIncome).abs() > 0.01) {
      errors.add(ValidationError(
        field: 'taxableIncome',
        code: 'CALCULATION_ERROR',
        message: 'Taxable income calculation mismatch',
        severity: ErrorSeverity.error,
      ));
    }
    
    return errors;
  }
  
  Future<List<ValidationError>> _validateBusinessRules(TaxReturn taxReturn) async {
    final errors = <ValidationError>[];
    
    // Earned Income Credit eligibility
    if (taxReturn.claimsEIC) {
      final eicEligible = await _checkEICEligibility(taxReturn);
      if (!eicEligible) {
        errors.add(ValidationError(
          field: 'earnedIncomeCredit',
          code: 'EIC_NOT_ELIGIBLE',
          message: 'Not eligible for Earned Income Credit based on income or filing status',
          severity: ErrorSeverity.error,
        ));
      }
    }
    
    // Child Tax Credit eligibility
    if (taxReturn.claimsChildTaxCredit) {
      for (final dependent in taxReturn.dependents) {
        if (!_isQualifyingChild(dependent, taxReturn.taxYear)) {
          errors.add(ValidationError(
            field: 'childTaxCredit',
            code: 'CTC_NOT_ELIGIBLE',
            message: '${dependent.firstName} does not qualify for Child Tax Credit',
            severity: ErrorSeverity.error,
          ));
        }
      }
    }
    
    return errors;
  }
  
  List<ValidationWarning> _generateWarnings(TaxReturn taxReturn) {
    final warnings = <ValidationWarning>[];
    
    // Name matching warnings
    warnings.add(ValidationWarning(
      field: 'firstName',
      code: 'NAME_MATCH_WARNING',
      message: 'Ensure your name matches your Social Security card exactly. '
               'Common issues: Jr/Sr suffixes, hyphenated names, middle names.',
    ));
    
    // Prior year AGI warning
    if (taxReturn.priorYearAGI == 0) {
      warnings.add(ValidationWarning(
        field: 'priorYearAGI',
        code: 'ZERO_AGI_WARNING',
        message: 'Prior year AGI is \$0. This is correct only if you did not file '
                 'a return last year or your AGI was actually \$0.',
      ));
    }
    
    // IP PIN warning
    warnings.add(ValidationWarning(
      field: 'ipPin',
      code: 'IP_PIN_WARNING',
      message: 'If you received an Identity Protection PIN from the IRS, '
               'you must enter it. Returns without required IP PINs will be rejected.',
    ));
    
    return warnings;
  }
  
  Future<bool> _checkEICEligibility(TaxReturn taxReturn) async {
    // EIC income limits for 2024
    final eicLimits = {
      0: 17640,  // No qualifying children
      1: 46560,  // 1 qualifying child
      2: 52918,  // 2 qualifying children
      3: 56838,  // 3+ qualifying children
    };
    
    final qualifyingChildren = taxReturn.dependents
        .where((d) => d.qualifiesForEIC)
        .length;
    
    final limit = eicLimits[qualifyingChildren.clamp(0, 3)]!;
    
    return taxReturn.earnedIncome <= limit;
  }
  
  bool _isQualifyingChild(Dependent dependent, int taxYear) {
    final age = taxYear - dependent.dateOfBirth.year;
    return age < 17;
  }
}

class ValidationError {
  final String field;
  final String code;
  final String message;
  final ErrorSeverity severity;
  
  const ValidationError({
    required this.field,
    required this.code,
    required this.message,
    required this.severity,
  });
}

class ValidationWarning {
  final String field;
  final String code;
  final String message;
  
  const ValidationWarning({
    required this.field,
    required this.code,
    required this.message,
  });
}

class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;
  final List<ValidationWarning> warnings;
  
  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
}

enum ErrorSeverity { error, warning, info }
```

---

## 4. Rejection Resolution UI

### 4.1 Rejection Screen

```dart
class RejectionResolutionScreen extends GetView<RejectionController> {
  const RejectionResolutionScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Rejected'),
        backgroundColor: Colors.red.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _RejectionStatusCard(
              errorCode: controller.errorCode,
              errorMessage: controller.errorMessage,
            ),
            
            const SizedBox(height: 24),
            
            // What Happened
            Text(
              'What Happened',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.rejection.value?.description ?? 
              'Your return was rejected by the IRS.',
            )),
            
            const SizedBox(height: 24),
            
            // How to Fix
            Text(
              'How to Fix This',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.rejection.value?.resolution ??
              'Please review your return for errors.',
            )),
            
            const SizedBox(height: 24),
            
            // Required Actions
            if (controller.requiredActions.isNotEmpty) ...[
              Text(
                'Required Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...controller.requiredActions.map(
                (action) => _ActionItem(action: action),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Affected Fields
            if (controller.rejection.value?.affectedFields.isNotEmpty ?? false) ...[
              Text(
                'Fields to Review',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.rejection.value!.affectedFields
                    .map((field) => Chip(label: Text(field)))
                    .toList(),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.contactSupport,
                    child: const Text('Contact Support'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.canRetry 
                        ? controller.fixAndRetry 
                        : null,
                    child: const Text('Fix and Resubmit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectionStatusCard extends StatelessWidget {
  final String errorCode;
  final String errorMessage;
  
  const _RejectionStatusCard({
    required this.errorCode,
    required this.errorMessage,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: 48,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Code: $errorCode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final RequiredAction action;
  
  const _ActionItem({required this.action});
  
  @override
  Widget build(BuildContext context) {
    final actionInfo = _getActionInfo(action);
    
    return ListTile(
      leading: Icon(actionInfo.icon, color: Theme.of(context).primaryColor),
      title: Text(actionInfo.title),
      subtitle: Text(actionInfo.description),
      trailing: actionInfo.actionUrl != null
          ? TextButton(
              onPressed: () => _launchUrl(actionInfo.actionUrl!),
              child: const Text('Learn More'),
            )
          : null,
    );
  }
  
  _ActionInfo _getActionInfo(RequiredAction action) {
    return switch (action) {
      RequiredAction.verifyPersonalInfo => _ActionInfo(
        icon: Icons.person,
        title: 'Verify Personal Information',
        description: 'Check that your name, SSN, and date of birth are correct.',
      ),
      RequiredAction.updateSSARecords => _ActionInfo(
        icon: Icons.edit_document,
        title: 'Update SSA Records',
        description: 'If your information is correct but being rejected, you may need to update your Social Security records.',
        actionUrl: 'https://www.ssa.gov/',
      ),
      RequiredAction.providePriorYearAGI => _ActionInfo(
        icon: Icons.history,
        title: 'Enter Prior Year AGI',
        description: 'Enter the exact AGI from your previous year tax return (Line 11).',
      ),
      RequiredAction.requestTranscript => _ActionInfo(
        icon: Icons.description,
        title: 'Request IRS Transcript',
        description: 'Get your prior year AGI from an IRS transcript.',
        actionUrl: 'https://www.irs.gov/individuals/get-transcript',
      ),
      RequiredAction.obtainIPPIN => _ActionInfo(
        icon: Icons.pin,
        title: 'Get IP PIN',
        description: 'Obtain your Identity Protection PIN from the IRS.',
        actionUrl: 'https://www.irs.gov/identity-theft-fraud-scams/get-an-identity-protection-pin',
      ),
      RequiredAction.verifyDependentEligibility => _ActionInfo(
        icon: Icons.family_restroom,
        title: 'Verify Dependent Eligibility',
        description: 'Confirm your dependent meets all IRS requirements.',
      ),
      RequiredAction.verifyIdentityTheft => _ActionInfo(
        icon: Icons.security,
        title: 'Identity Theft Alert',
        description: 'A return may have been filed fraudulently using your information.',
        actionUrl: 'https://www.irs.gov/identity-theft-fraud-scams',
      ),
      RequiredAction.fileForm14039 => _ActionInfo(
        icon: Icons.article,
        title: 'File Form 14039',
        description: 'Report identity theft to the IRS.',
        actionUrl: 'https://www.irs.gov/pub/irs-pdf/f14039.pdf',
      ),
      RequiredAction.reviewReturn => _ActionInfo(
        icon: Icons.rate_review,
        title: 'Review Your Return',
        description: 'Check your return for errors or missing information.',
      ),
      RequiredAction.contactSupport => _ActionInfo(
        icon: Icons.support_agent,
        title: 'Contact Support',
        description: 'Our team can help resolve this issue.',
      ),
    };
  }
  
  void _launchUrl(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

class _ActionInfo {
  final IconData icon;
  final String title;
  final String description;
  final String? actionUrl;
  
  const _ActionInfo({
    required this.icon,
    required this.title,
    required this.description,
    this.actionUrl,
  });
}
```

---

## 5. Database Schema

```sql
-- Return Rejections
CREATE TABLE return_rejections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  return_id UUID NOT NULL REFERENCES tax_returns(id),
  error_code TEXT NOT NULL,
  error_message TEXT NOT NULL,
  error_category TEXT,
  rejection_category TEXT,
  is_retryable BOOLEAN DEFAULT false,
  resolution_status TEXT DEFAULT 'pending',
  resolved_at TIMESTAMPTZ,
  resolution_notes TEXT,
  retry_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Rejection Resolutions
CREATE TABLE rejection_resolutions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  rejection_id UUID NOT NULL REFERENCES return_rejections(id),
  resolution_type TEXT NOT NULL,
  field_changed TEXT,
  old_value TEXT,
  new_value TEXT,
  resolved_by UUID REFERENCES auth.users(id),
  resolved_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rejections_return ON return_rejections(return_id);
CREATE INDEX idx_rejections_code ON return_rejections(error_code);
CREATE INDEX idx_rejections_status ON return_rejections(resolution_status);

-- RLS Policies
ALTER TABLE return_rejections ENABLE ROW LEVEL SECURITY;
ALTER TABLE rejection_resolutions ENABLE ROW LEVEL SECURITY;

CREATE POLICY rejection_owner_access ON return_rejections
  FOR ALL USING (
    return_id IN (SELECT id FROM tax_returns WHERE user_id = auth.uid())
  );
```

---

## 6. Implementation Checklist

- [ ] Implement IrsRejection model with all common codes
- [ ] Create RejectionHandlerService
- [ ] Build PreSubmissionValidator
- [ ] Create rejection resolution UI
- [ ] Implement rejection logging
- [ ] Add notification system for rejections
- [ ] Build retry workflow
- [ ] Create support escalation flow
- [ ] Implement database schema
- [ ] Add analytics for rejection tracking

---

## 7. Related Documents

- [E-File Transmission](./efile_transmission.md)
- [Taxpayer Data](./taxpayer_data.md)
- [Calculations](./calculations.md)
- [Testing & Validation](./testing_validation.md)
