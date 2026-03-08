import 'package:flutter_bloc/flutter_bloc.dart';

// =============================================================================
// Main Nav State
// =============================================================================

class MainNavState {
  final int currentIndex;
  final bool hasStartedInterview;

  const MainNavState({
    this.currentIndex = 0,
    this.hasStartedInterview = false,
  });

  MainNavState copyWith({
    int? currentIndex,
    bool? hasStartedInterview,
  }) {
    return MainNavState(
      currentIndex: currentIndex ?? this.currentIndex,
      hasStartedInterview: hasStartedInterview ?? this.hasStartedInterview,
    );
  }
}

// =============================================================================
// Main Nav Cubit
// =============================================================================

class MainNavCubit extends Cubit<MainNavState> {
  MainNavCubit() : super(const MainNavState());

  // ---------------------------------------------------------------------------
  // Tab Indices
  // ---------------------------------------------------------------------------

  static const int homeTab = 0;
  static const int documentsTab = 1;
  static const int interviewTab = 2;
  static const int supportTab = 3;
  static const int settingsTab = 4;

  // ---------------------------------------------------------------------------
  // Methods
  // ---------------------------------------------------------------------------

  /// Change the current selected tab
  void changeTab(int index) {
    emit(state.copyWith(currentIndex: index));
  }

  /// Navigate to a specific tab by name
  void navigateToHome() => changeTab(homeTab);
  void navigateToDocuments() => changeTab(documentsTab);
  void navigateToInterview() => changeTab(interviewTab);
  void navigateToSupport() => changeTab(supportTab);
  void navigateToSettings() => changeTab(settingsTab);

  /// Mark interview as started (user has passed welcome screen)
  void markInterviewStarted() {
    emit(state.copyWith(hasStartedInterview: true));
  }

  /// Reset interview state (for logout or restart)
  void resetInterviewState() {
    emit(state.copyWith(hasStartedInterview: false));
  }

  /// Reset all state
  void reset() {
    emit(const MainNavState());
  }
}
