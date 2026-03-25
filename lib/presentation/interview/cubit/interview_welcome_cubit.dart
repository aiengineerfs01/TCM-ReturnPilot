import 'package:flutter_bloc/flutter_bloc.dart';

// =============================================================================
// Interview Welcome State
// =============================================================================

class InterviewWelcomeState {
  final int currentStep;
  final bool hasUploadedDocuments;
  final bool isLoading;

  const InterviewWelcomeState({
    this.currentStep = 0,
    this.hasUploadedDocuments = false,
    this.isLoading = false,
  });

  InterviewWelcomeState copyWith({
    int? currentStep,
    bool? hasUploadedDocuments,
    bool? isLoading,
  }) {
    return InterviewWelcomeState(
      currentStep: currentStep ?? this.currentStep,
      hasUploadedDocuments: hasUploadedDocuments ?? this.hasUploadedDocuments,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// =============================================================================
// Interview Welcome Cubit
// =============================================================================

class InterviewWelcomeCubit extends Cubit<InterviewWelcomeState> {
  InterviewWelcomeCubit() : super(const InterviewWelcomeState());

  // ---------------------------------------------------------------------------
  // Step Constants
  // ---------------------------------------------------------------------------

  /// 0 = Welcome screen (Welcome to ReturnPilot)
  /// 1 = Before We Begin screen
  /// 2 = Interview chat screen
  static const int welcomeStep = 0;
  static const int beforeWeBeginStep = 1;
  static const int interviewStep = 2;

  // ---------------------------------------------------------------------------
  // Computed Getters
  // ---------------------------------------------------------------------------

  /// Check if user is on welcome screen
  bool get isOnWelcomeScreen => state.currentStep == welcomeStep;

  /// Check if user is on before we begin screen
  bool get isOnBeforeWeBeginScreen => state.currentStep == beforeWeBeginStep;

  /// Check if user has started the interview
  bool get hasStartedInterview => state.currentStep >= interviewStep;

  // ---------------------------------------------------------------------------
  // Methods
  // ---------------------------------------------------------------------------

  /// Called when user taps "Start My Tax Return" on welcome screen
  void onStartTaxReturn() {
    emit(state.copyWith(currentStep: beforeWeBeginStep));
  }

  /// Called when user taps "Upload Documents Now"
  void onUploadDocuments() {
    // TODO: Implement document upload flow
    // For now, just mark as uploaded and proceed
    emit(state.copyWith(
      hasUploadedDocuments: true,
      currentStep: interviewStep,
    ));
  }

  /// Called when user taps "Start Interview"
  void onStartInterview() {
    emit(state.copyWith(currentStep: interviewStep));
  }

  /// Go back to previous step
  void goBack() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(const InterviewWelcomeState());
  }

  /// Set loading state
  void setLoading(bool loading) {
    emit(state.copyWith(isLoading: loading));
  }
}
