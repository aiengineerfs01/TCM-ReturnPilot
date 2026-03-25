import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm_return_pilot/models/tax/tax_models.dart';
import 'package:tcm_return_pilot/services/tax/tax_calculation_service.dart';
import 'package:tcm_return_pilot/services/tax/tax_return_service.dart';
import 'package:tcm_return_pilot/utils/tax/tax_validators.dart';

// =============================================================================
// Tax Return State
// =============================================================================

class TaxReturnState {
  final CompleteTaxReturn? currentReturn;
  final bool isLoading;
  final bool isSaving;
  final List<TaxValidationError> validationErrors;
  final List<TaxReturn> userReturns;
  final int currentStep;
  final TaxSummary? taxSummary;

  const TaxReturnState({
    this.currentReturn,
    this.isLoading = false,
    this.isSaving = false,
    this.validationErrors = const [],
    this.userReturns = const [],
    this.currentStep = 0,
    this.taxSummary,
  });

  TaxReturnState copyWith({
    CompleteTaxReturn? currentReturn,
    bool clearCurrentReturn = false,
    bool? isLoading,
    bool? isSaving,
    List<TaxValidationError>? validationErrors,
    List<TaxReturn>? userReturns,
    int? currentStep,
    TaxSummary? taxSummary,
    bool clearTaxSummary = false,
  }) {
    return TaxReturnState(
      currentReturn:
          clearCurrentReturn ? null : (currentReturn ?? this.currentReturn),
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      validationErrors: validationErrors ?? this.validationErrors,
      userReturns: userReturns ?? this.userReturns,
      currentStep: currentStep ?? this.currentStep,
      taxSummary: clearTaxSummary ? null : (taxSummary ?? this.taxSummary),
    );
  }
}

// =============================================================================
// Tax Summary Model
// =============================================================================

class TaxSummary {
  final double totalIncome;
  final double adjustmentsToIncome;
  final double agi;
  final double deductions;
  final double taxableIncome;
  final double federalIncomeTax;
  final double selfEmploymentTax;
  final double totalTax;
  final double totalCredits;
  final double totalRefundableCredits;
  final double totalWithholding;
  final double totalPayments;
  final double refundAmount;
  final double amountOwed;
  final double effectiveRate;
  final double marginalRate;

  const TaxSummary({
    required this.totalIncome,
    required this.adjustmentsToIncome,
    required this.agi,
    required this.deductions,
    required this.taxableIncome,
    required this.federalIncomeTax,
    required this.selfEmploymentTax,
    required this.totalTax,
    required this.totalCredits,
    required this.totalRefundableCredits,
    required this.totalWithholding,
    required this.totalPayments,
    required this.refundAmount,
    required this.amountOwed,
    required this.effectiveRate,
    required this.marginalRate,
  });

  /// Check if getting a refund
  bool get isGettingRefund => refundAmount > 0;

  /// Check if owes money
  bool get owesMoney => amountOwed > 0;

  /// Get effective rate as percentage string
  String get effectiveRatePercent =>
      '${(effectiveRate * 100).toStringAsFixed(1)}%';

  /// Get marginal rate as percentage string
  String get marginalRatePercent =>
      '${(marginalRate * 100).toStringAsFixed(0)}%';
}

// =============================================================================
// Tax Return Cubit
// =============================================================================

class TaxReturnCubit extends Cubit<TaxReturnState> {
  TaxReturnCubit({
    required TaxReturnService returnService,
  })  : _returnService = returnService,
        super(const TaxReturnState()) {
    loadUserReturns();
  }

  final TaxReturnService _returnService;

  // ===========================================================================
  // Computed Properties (Getters)
  // ===========================================================================

  TaxReturn? get taxReturn => state.currentReturn?.taxReturn;
  String? get returnId => taxReturn?.id;
  FilingStatus get filingStatus =>
      taxReturn?.filingStatus ?? FilingStatus.single;
  int get taxYear => taxReturn?.taxYear ?? DateTime.now().year;
  ReturnStatus get returnStatus => taxReturn?.status ?? ReturnStatus.draft;
  bool get isEditable => taxReturn?.isEditable ?? false;
  bool get canSubmit =>
      taxReturn?.canBeSubmitted == true && state.validationErrors.isEmpty;
  TaxpayerInfo? get primaryTaxpayer => state.currentReturn?.primaryTaxpayer;
  TaxpayerInfo? get spouseTaxpayer => state.currentReturn?.spouseTaxpayer;
  List<W2Form> get w2Forms => state.currentReturn?.w2Forms ?? [];
  List<Dependent> get dependents => state.currentReturn?.dependents ?? [];
  double get completionPercentage =>
      (taxReturn?.completionPercentage ?? 0).toDouble();
  bool get hasIncome => (state.currentReturn?.totalW2Wages ?? 0) > 0;

  // ===========================================================================
  // Return Management
  // ===========================================================================

  Future<void> loadUserReturns() async {
    emit(state.copyWith(isLoading: true));
    try {
      final returns = await _returnService.getAllReturns();
      emit(state.copyWith(userReturns: returns));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<String?> createNewReturn({
    int? taxYear,
    FilingStatus filingStatus = FilingStatus.single,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final year = taxYear ?? DateTime.now().year;
      final newReturn = await _returnService.createReturn(
        taxYear: year,
        filingStatus: filingStatus,
      );

      if (newReturn != null) {
        await loadUserReturns();
        await loadReturn(newReturn.id!);
        return newReturn.id;
      }
      return null;
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> loadReturn(String returnId) async {
    emit(state.copyWith(isLoading: true, validationErrors: []));
    try {
      final completeReturn =
          await _returnService.loadCompleteReturn(returnId);
      emit(state.copyWith(currentReturn: completeReturn));
      if (completeReturn != null) {
        recalculateTaxes();
        validateReturn();
      }
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void clearReturn() {
    emit(state.copyWith(
      clearCurrentReturn: true,
      clearTaxSummary: true,
      validationErrors: [],
      currentStep: 0,
    ));
  }

  Future<void> updateFilingStatus(FilingStatus status) async {
    if (taxReturn == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      final updated = taxReturn!.copyWith(filingStatus: status);
      await _returnService.updateReturn(updated);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  // ===========================================================================
  // Taxpayer Info Management
  // ===========================================================================

  Future<void> savePrimaryTaxpayer(TaxpayerInfo info) async {
    if (returnId == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      final taxpayerInfo = info.copyWith(
        returnId: returnId,
        taxpayerType: TaxpayerType.primary,
      );
      await _returnService.saveTaxpayerInfo(taxpayerInfo);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> saveSpouseTaxpayer(TaxpayerInfo info) async {
    if (returnId == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      final taxpayerInfo = info.copyWith(
        returnId: returnId,
        taxpayerType: TaxpayerType.spouse,
      );
      await _returnService.saveTaxpayerInfo(taxpayerInfo);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  // ===========================================================================
  // Dependent Management
  // ===========================================================================

  Future<void> addDependent(Dependent dependent) async {
    if (returnId == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      final dep = Dependent(
        returnId: returnId!,
        firstName: dependent.firstName,
        lastName: dependent.lastName,
        ssn: dependent.ssn,
        dateOfBirth: dependent.dateOfBirth,
        relationship: dependent.relationship,
        monthsLivedWithTaxpayer: dependent.monthsLivedWithTaxpayer,
        qualifiesForCtc: dependent.qualifiesForCtc,
        qualifiesForOtherDependent: dependent.qualifiesForOtherDependent,
      );
      await _returnService.saveDependent(dep);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> updateDependent(Dependent dependent) async {
    if (returnId == null || dependent.id == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      await _returnService.saveDependent(dependent);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> removeDependent(String dependentId) async {
    if (returnId == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      await _returnService.deleteDependent(dependentId, returnId!);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  // ===========================================================================
  // W-2 Management
  // ===========================================================================

  Future<void> addW2Form(W2Form w2) async {
    if (returnId == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      final form = w2.copyWith(returnId: returnId);
      await _returnService.saveW2Form(form);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> updateW2Form(W2Form w2) async {
    if (returnId == null || w2.id == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      await _returnService.saveW2Form(w2);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> removeW2Form(String w2Id) async {
    if (returnId == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      await _returnService.deleteW2Form(w2Id, returnId!);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  // ===========================================================================
  // 1099 Form Management
  // ===========================================================================

  Future<void> add1099Form<T>(T form) async {
    if (returnId == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      if (form is Form1099Int) {
        await _returnService
            .saveForm1099Int(form.copyWith(returnId: returnId));
      } else if (form is Form1099Div) {
        await _returnService
            .saveForm1099Div(form.copyWith(returnId: returnId));
      } else if (form is Form1099R) {
        await _returnService.saveForm1099R(form.copyWith(returnId: returnId));
      } else if (form is Form1099Nec) {
        await _returnService
            .saveForm1099Nec(form.copyWith(returnId: returnId));
      } else if (form is Form1099G) {
        await _returnService.saveForm1099G(form.copyWith(returnId: returnId));
      } else if (form is FormSsa1099) {
        await _returnService
            .saveFormSsa1099(form.copyWith(returnId: returnId));
      }
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  // ===========================================================================
  // Deductions and Credits Management
  // ===========================================================================

  Future<void> saveAdjustments(AdjustmentsToIncome adjustments) async {
    if (returnId == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      final adj = adjustments.copyWith(returnId: returnId);
      await _returnService.saveAdjustments(adj);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> saveDeductions(Deductions deductions) async {
    if (returnId == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      final ded = deductions.copyWith(returnId: returnId);
      await _returnService.saveDeductions(ded);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> saveCredits(Credits credits) async {
    if (returnId == null) return;

    emit(state.copyWith(isSaving: true));
    try {
      final cred = credits.copyWith(returnId: returnId);
      await _returnService.saveCredits(cred);
      await loadReturn(returnId!);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  // ===========================================================================
  // Tax Calculations
  // ===========================================================================

  void recalculateTaxes() {
    if (state.currentReturn == null) return;

    final complete = state.currentReturn!;

    // Calculate total income
    final totalW2Income = complete.totalW2Wages;
    final total1099Interest = complete.form1099Int.fold(
      0.0,
      (sum, f) => sum + f.box1InterestIncome,
    );
    final total1099Div = complete.form1099Div.fold(
      0.0,
      (sum, f) => sum + f.box1aOrdinaryDividends,
    );
    final total1099Nec = complete.form1099Nec.fold(
      0.0,
      (sum, f) => sum + f.box1NonemployeeCompensation,
    );
    final total1099R = complete.form1099R.fold(
      0.0,
      (sum, f) => sum + f.box2aTaxableAmount,
    );
    final total1099G = complete.form1099G.fold(
      0.0,
      (sum, f) => sum + f.box1Unemployment,
    );
    final totalSsa = complete.formSsa1099.fold(
      0.0,
      (sum, f) => sum + f.box5NetBenefits,
    );

    final totalIncome = totalW2Income +
        total1099Interest +
        total1099Div +
        total1099Nec +
        total1099R +
        total1099G +
        totalSsa;

    // Calculate adjustments
    final adjustmentsTotal = complete.adjustments?.totalAdjustments ?? 0;

    // Calculate AGI
    final agi = totalIncome - adjustmentsTotal;

    // Calculate deductions
    double deductionAmount;
    if (complete.deductions?.deductionType == DeductionType.itemized) {
      deductionAmount = complete.deductions?.totalItemizedDeductions ?? 0;
    } else {
      deductionAmount = TaxCalculationService.calculateStandardDeduction(
        filingStatus: filingStatus,
        is65OrOlder: primaryTaxpayer?.isAge65OrOlder(taxYear) ?? false,
        isBlind: false,
        spouseIs65OrOlder: spouseTaxpayer?.isAge65OrOlder(taxYear) ?? false,
        spouseIsBlind: false,
      );
    }

    // Calculate taxable income
    final taxableIncome = (agi - deductionAmount).clamp(0.0, double.infinity);

    // Calculate federal income tax
    final taxResult = TaxCalculationService.calculateFederalIncomeTax(
      taxableIncome: taxableIncome,
      filingStatus: filingStatus,
    );

    // Calculate self-employment tax
    final seTaxResult = TaxCalculationService.calculateSelfEmploymentTax(
      netSelfEmploymentIncome: total1099Nec,
      filingStatus: filingStatus,
      wageIncome: totalW2Income,
    );

    // Calculate credits
    final childTaxCredit = TaxCalculationService.calculateChildTaxCredit(
      qualifyingChildren: complete.qualifyingChildrenForCtc,
      agi: agi,
      filingStatus: filingStatus,
      taxLiability: taxResult.totalTax,
    );

    final eic = TaxCalculationService.calculateEarnedIncomeCredit(
      qualifyingChildren: complete.qualifyingChildrenForEic,
      earnedIncome: totalW2Income + total1099Nec,
      agi: agi,
      filingStatus: filingStatus,
    );

    final totalCredits = childTaxCredit.nonrefundableCredit +
        (complete.credits?.totalNonrefundableCredits ?? 0);

    final totalRefundableCredits = childTaxCredit.refundableCredit +
        eic +
        (complete.credits?.totalRefundableCredits ?? 0);

    // Calculate total tax
    final totalTax =
        (taxResult.totalTax + seTaxResult.totalSeTax - totalCredits)
            .clamp(0.0, double.infinity);

    // Calculate total payments
    final totalWithholding = complete.totalW2Withholding;
    final totalPayments = (complete.taxPayments?.totalPayments ?? 0) +
        totalWithholding +
        totalRefundableCredits;

    // Calculate refund or amount owed
    final refundOrOwed = totalPayments - totalTax;

    emit(state.copyWith(
      taxSummary: TaxSummary(
        totalIncome: totalIncome,
        adjustmentsToIncome: adjustmentsTotal,
        agi: agi,
        deductions: deductionAmount,
        taxableIncome: taxableIncome,
        federalIncomeTax: taxResult.totalTax,
        selfEmploymentTax: seTaxResult.totalSeTax,
        totalTax: totalTax,
        totalCredits: totalCredits,
        totalRefundableCredits: totalRefundableCredits,
        totalWithholding: totalWithholding,
        totalPayments: totalPayments,
        refundAmount: refundOrOwed > 0 ? refundOrOwed : 0,
        amountOwed: refundOrOwed < 0 ? -refundOrOwed : 0,
        effectiveRate: taxResult.effectiveRate,
        marginalRate: taxResult.marginalRate,
      ),
    ));
  }

  // ===========================================================================
  // Validation
  // ===========================================================================

  void validateReturn() {
    if (state.currentReturn == null) {
      emit(state.copyWith(validationErrors: []));
      return;
    }

    final errors = <TaxValidationError>[];

    // Validate primary taxpayer
    if (primaryTaxpayer == null) {
      errors.add(const TaxValidationError(
        errorCode: 'MISSING_PRIMARY',
        message: 'Primary taxpayer information is required',
        fieldName: 'primaryTaxpayer',
      ));
    } else {
      final ssnError =
          TaxValidators.validateSsnWithMessage(primaryTaxpayer!.ssn);
      if (ssnError != null) {
        errors.add(TaxValidationError(
          errorCode: 'INVALID_SSN',
          message: ssnError,
          fieldName: 'primaryTaxpayer.ssn',
        ));
      }

      final nameError = TaxValidators.validateNameWithMessage(
        primaryTaxpayer!.firstName,
        fieldName: 'First name',
      );
      if (nameError != null) {
        errors.add(TaxValidationError(
          errorCode: 'INVALID_NAME',
          message: nameError,
          fieldName: 'primaryTaxpayer.firstName',
        ));
      }
    }

    // Validate spouse for joint filers
    if (filingStatus == FilingStatus.marriedFilingJointly &&
        spouseTaxpayer == null) {
      errors.add(const TaxValidationError(
        errorCode: 'MISSING_SPOUSE',
        message: 'Spouse information is required for Married Filing Jointly',
        fieldName: 'spouseTaxpayer',
      ));
    }

    // Validate W-2 forms
    for (final w2 in w2Forms) {
      final einError = TaxValidators.validateEinWithMessage(w2.employerEin);
      if (einError != null) {
        errors.add(TaxValidationError(
          errorCode: 'INVALID_EIN',
          message: 'W-2 from ${w2.employerName}: $einError',
          fieldName: 'w2Forms.employerEin',
        ));
      }
    }

    // Validate dependents
    for (final dep in dependents) {
      final ssnError = TaxValidators.validateSsnWithMessage(dep.ssn);
      if (ssnError != null) {
        errors.add(TaxValidationError(
          errorCode: 'INVALID_DEPENDENT_SSN',
          message: 'Dependent ${dep.firstName}: $ssnError',
          fieldName: 'dependents.ssn',
        ));
      }
    }

    // Check for minimum income
    if (!hasIncome) {
      errors.add(const TaxValidationError(
        errorCode: 'NO_INCOME',
        message: 'No income has been entered',
        fieldName: 'income',
        severity: ValidationSeverity.warning,
      ));
    }

    emit(state.copyWith(validationErrors: errors));
  }

  bool hasError(String fieldName) {
    return state.validationErrors.any(
      (e) => e.fieldName == fieldName && e.severity == ValidationSeverity.error,
    );
  }

  String? getErrorMessage(String fieldName) {
    final error = state.validationErrors
        .where((e) => e.fieldName == fieldName)
        .firstOrNull;
    return error?.message;
  }

  // ===========================================================================
  // Wizard Navigation
  // ===========================================================================

  static const List<String> wizardSteps = [
    'Filing Status',
    'Personal Info',
    'Dependents',
    'Income',
    'Adjustments',
    'Deductions',
    'Credits',
    'Review',
    'E-File',
  ];

  void nextStep() {
    if (state.currentStep < wizardSteps.length - 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < wizardSteps.length) {
      emit(state.copyWith(currentStep: step));
    }
  }

  String get currentStepName => wizardSteps[state.currentStep];

  bool get canProceed {
    switch (state.currentStep) {
      case 0: // Filing Status
        return true;
      case 1: // Personal Info
        return primaryTaxpayer != null;
      case 2: // Dependents
        return true;
      case 3: // Income
        return hasIncome;
      default:
        return true;
    }
  }

  // ===========================================================================
  // Submission
  // ===========================================================================

  Future<bool> submitReturn() async {
    if (!canSubmit || returnId == null) return false;

    emit(state.copyWith(isSaving: true));
    try {
      await _returnService.updateReturnStatus(
        returnId!,
        ReturnStatus.readyToFile,
      );

      // TODO: Implement actual e-file submission logic

      return true;
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }
}
