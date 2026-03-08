import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tcm_return_pilot/models/identity_verification_model.dart';
import 'package:tcm_return_pilot/models/profile_model.dart';
import 'package:tcm_return_pilot/services/auth_service.dart';
import 'package:tcm_return_pilot/services/identity_verification_service.dart';
import 'package:tcm_return_pilot/services/storage_service.dart';
import 'package:tcm_return_pilot/services/supabase_service.dart';
import 'package:tcm_return_pilot/utils/enums.dart';
import 'package:tcm_return_pilot/utils/snackbar.dart';

// =============================================================================
// Auth State
// =============================================================================

class AuthState {
  final bool isLoading;
  final User? user;
  final String errorMessage;
  final String? navigationRoute;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage = '',
    this.navigationRoute,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    bool clearUser = false,
    String? errorMessage,
    String? navigationRoute,
    bool clearNavigation = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: errorMessage ?? this.errorMessage,
      navigationRoute:
          clearNavigation ? null : (navigationRoute ?? this.navigationRoute),
    );
  }
}

// =============================================================================
// Auth Cubit
// =============================================================================

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState()) {
    _init();
  }

  final AuthService _authService = AuthService();
  final IdentityVerificationService _verificationService =
      IdentityVerificationService();

  static final SupabaseClient _supabaseClient = SupabaseService.client;
  final SupabaseService _supabaseService = SupabaseService();

  bool _isManualLogout = false;
  bool _isInitialized = false;

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------

  User? get currentUser => state.user;
  bool get isLoading => state.isLoading;
  String get errorMessage => state.errorMessage;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  void _init() {
    // Set current user from the auth service
    emit(state.copyWith(user: _authService.currentUser));

    // Listen for auth / session state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final newUser = event.session?.user;
      if (!_isInitialized) return;

      if (newUser != null) {
        emit(state.copyWith(user: newUser));
      } else {
        if (_isManualLogout) {
          _isManualLogout = false;
          return;
        }
        // Session expired or user signed out
        emit(state.copyWith(clearUser: true));
        _handleSessionExpired();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Navigation helper
  // ---------------------------------------------------------------------------

  /// Emit a navigation route, then immediately clear it so the UI only
  /// reacts once.
  void _navigate(String route) {
    emit(state.copyWith(navigationRoute: route));
    emit(state.copyWith(clearNavigation: true));
  }

  // ---------------------------------------------------------------------------
  // Route constants (GoRouter paths)
  // ---------------------------------------------------------------------------

  static const String _onboarding = '/onboarding';
  static const String _signIn = '/sign-in';
  static const String _mfaVerify = '/mfa-verify';
  static const String _mfaEnroll = '/mfa-enroll';
  static const String _completeProfile = '/complete-profile';
  static const String _verifyIdentity = '/verify-identity';
  static const String _verificationProgress = '/verification-progress';
  static const String _verificationRejected = '/verification-rejected';
  static const String _welcomeConsent = '/welcome-consent';
  static const String _main = '/main';

  // ---------------------------------------------------------------------------
  // CHECK AUTH STATUS (for SplashScreen)
  // ---------------------------------------------------------------------------

  Future<void> checkAuthStatus() async {
    try {
      emit(state.copyWith(isLoading: true));

      final currentSession = Supabase.instance.client.auth.currentSession;

      if (currentSession != null) {
        emit(state.copyWith(user: currentSession.user));
        await handlePostMfa();
      } else {
        _navigate(_onboarding);
      }
    } catch (e) {
      _showError('Error while checking session.');
      _navigate(_onboarding);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------

  Future<void> login(String email, String password) async {
    try {
      emit(state.copyWith(isLoading: true));
      final response = await _authService.signIn(
        email: email,
        password: password,
      );
      emit(state.copyWith(user: response.user));

      _showSuccess('Login successful!');
      await handlePostLogin();
    } catch (e) {
      _showError(e.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
      _isInitialized = true;
    }
  }

  // ---------------------------------------------------------------------------
  // HANDLE POST LOGIN
  // ---------------------------------------------------------------------------

  /// Called after password login (AAL1). Routes to MFA first.
  Future<void> handlePostLogin() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      _navigate(_signIn);
      return;
    }

    final isMFAEnabled = await isUserMFAEnabled();
    if (isMFAEnabled) {
      _navigate(_mfaVerify);
    } else {
      _navigate(_mfaEnroll);
    }
  }

  // ---------------------------------------------------------------------------
  // HANDLE POST MFA
  // ---------------------------------------------------------------------------

  /// Called after MFA verification succeeds (AAL2). Checks profile/identity.
  Future<void> handlePostMfa() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      _navigate(_signIn);
      return;
    }

    final profiles = await _supabaseService.getData(
      table: SupabaseTable.profiles,
      column: 'id',
      value: user.id,
    );

    if (profiles.isEmpty) {
      _navigate(_onboarding);
      return;
    }

    final ProfileModel profile = ProfileModel.fromJson(profiles[0]);

    if (profile.isProfileCompleted == false) {
      _navigate(_completeProfile);
    } else if (profile.identityVerificationStatus ==
        IdentityVerificationStatus.notStarted) {
      _navigate(_verifyIdentity);
    } else if (profile.identityVerificationStatus ==
        IdentityVerificationStatus.pending) {
      _navigate(_verificationProgress);
    } else if (profile.identityVerificationStatus ==
        IdentityVerificationStatus.rejected) {
      _navigate(_verificationRejected);
    } else {
      // Approved — consent check or home
      if (profile.checkedConsent == true) {
        _navigate(_main);
      } else {
        _navigate(_welcomeConsent);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // CHECK USER MFA ENABLE
  // ---------------------------------------------------------------------------

  Future<bool> isUserMFAEnabled() async {
    try {
      final response = await _supabaseClient.auth.mfa.listFactors();
      final factors = response.totp;
      return factors.isNotEmpty;
    } catch (e) {
      log('MFA check failed: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // SIGNUP
  // ---------------------------------------------------------------------------

  Future<void> signUp(
      String email, String password, String displayName) async {
    try {
      emit(state.copyWith(isLoading: true));

      final response = await _authService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        emit(state.copyWith(user: response.user));

        _showSuccess(
          'Account created successfully! A verification email has been sent to your email address.',
        );
        _navigate(_signIn);
      } else {
        _showError('Signup failed. Please try again.');
      }
    } on Exception catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } catch (e) {
      _showError('Unexpected error occurred during sign-up.');
    } finally {
      emit(state.copyWith(isLoading: false));
      _isInitialized = true;
    }
  }

  // ---------------------------------------------------------------------------
  // RESET PASSWORD
  // ---------------------------------------------------------------------------

  Future<void> resetPassword(String email) async {
    try {
      emit(state.copyWith(isLoading: true));
      final error = await _authService.resetPassword(email);

      if (error != null) {
        _showError(error);
      } else {
        _showSuccess(
          'Password reset link sent to registered email! Check your inbox.',
        );
        _navigate(_signIn);
      }
    } catch (e) {
      _showError('Failed to send reset password email.');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  // ---------------------------------------------------------------------------
  // RE-AUTHENTICATE WITH MFA
  // ---------------------------------------------------------------------------

  Future<bool> verifyMfaForSensitiveAction(String code) async {
    try {
      emit(state.copyWith(isLoading: true));

      final error = await _authService.reauthenticateMFA(code);

      if (error != null) {
        _showError(error);
        return false;
      }

      return true;
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE PASSWORD
  // ---------------------------------------------------------------------------

  Future<void> updatePassword(String code, String newPassword) async {
    try {
      emit(state.copyWith(isLoading: true));

      final ok = await verifyMfaForSensitiveAction(code);
      if (!ok) return;

      final error = await _authService.updatePassword(newPassword);

      if (error != null) {
        _showError(error);
        return;
      }

      _showSuccess('Password updated successfully!');
      _navigate(_signIn);
    } catch (e) {
      _showError('Failed to update password.');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  // ---------------------------------------------------------------------------
  // CREATE PROFILE
  // ---------------------------------------------------------------------------

  static Future<void> createProfile({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    try {
      final data = {
        'id': userId,
        'email': email,
        'display_name': displayName ?? '',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient.from(SupabaseTable.profiles.name).insert(data);
    } on PostgrestException catch (e) {
      log('Error creating profile: ${e.message}');
    } catch (e) {
      log('Error creating profile: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE PROFILE CONSENT
  // ---------------------------------------------------------------------------

  Future<void> updateProfileConsent({
    required String userId,
    required bool checkedConsent,
  }) async {
    try {
      final data = {'checked_consent': checkedConsent};
      await _supabaseClient
          .from(SupabaseTable.profiles.name)
          .update(data)
          .eq('id', userId);
    } on PostgrestException catch (e) {
      log('Error updating profile consent: ${e.message}');
    } catch (e) {
      log('Error updating profile consent: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // COMPLETE PROFILE
  // ---------------------------------------------------------------------------

  Future<void> completeProfile(
    String firstName,
    String lastName,
    String address,
    String phone,
    File? profileImage,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      String? profleImageUrl = '';
      if (profileImage != null) {
        profleImageUrl = await _supabaseService.uploadFileToSupabaseBucket(
          file: profileImage,
          bucketName: 'profile_media',
          folder: 'profile',
        );
      }
      final data = {
        'first_name': firstName,
        'last_name': lastName,
        'address': address,
        'phone': phone,
        'profile_image': profleImageUrl,
        'is_profile_completed': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _supabaseClient
          .from(SupabaseTable.profiles.name)
          .update(data)
          .eq('id', currentUser?.id.toString() ?? '');

      _navigate(_verifyIdentity);
    } catch (e) {
      log(e.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  // ---------------------------------------------------------------------------
  // SUBMIT IDENTITY VERIFICATION
  // ---------------------------------------------------------------------------

  Future<void> submitIdentityVerification({
    required File frontId,
    required File backId,
    required File selfie,
  }) async {
    try {
      emit(state.copyWith(isLoading: true));

      final result = await _verificationService.submitVerification(
        frontId: frontId,
        backId: backId,
        selfie: selfie,
      );

      if (result.isSuccess) {
        _showSuccess(result.message ?? 'Verification submitted successfully!');
        _navigate(_verificationProgress);
      } else {
        _showError(result.errorMessage ?? 'Failed to submit verification');
      }
    } catch (e) {
      log('Error in submitIdentityVerification: $e');
      _showError('An error occurred while submitting verification');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  // ---------------------------------------------------------------------------
  // GET VERIFICATION STATUS
  // ---------------------------------------------------------------------------

  Future<IdentityVerificationModel?> getVerificationStatus() async {
    try {
      return await _verificationService.getVerificationStatus();
    } catch (e) {
      log('Error getting verification status: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // RESUBMIT VERIFICATION
  // ---------------------------------------------------------------------------

  Future<void> resubmitVerification({
    File? frontId,
    File? backId,
    File? selfie,
  }) async {
    try {
      emit(state.copyWith(isLoading: true));

      final result = await _verificationService.resubmitVerification(
        frontId: frontId,
        backId: backId,
        selfie: selfie,
      );

      if (result.isSuccess) {
        _showSuccess(
          result.message ?? 'Verification resubmitted successfully!',
        );
        _navigate(_verificationProgress);
      } else {
        _showError(result.errorMessage ?? 'Failed to resubmit verification');
      }
    } catch (e) {
      log('Error in resubmitVerification: $e');
      _showError('An error occurred while resubmitting verification');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  // ---------------------------------------------------------------------------
  // CONTINUE FROM VERIFICATION IN PROGRESS
  // ---------------------------------------------------------------------------

  Future<void> onVerificationProgressContinue() async {
    try {
      emit(state.copyWith(isLoading: true));

      final model = await getVerificationStatus();
      if (model == null) {
        _showError('Unable to fetch verification status.');
        return;
      }

      switch (model.status) {
        case IdentityVerificationStatus.pending:
          _showSuccess('Still under review. Please check back later.');
          break;

        case IdentityVerificationStatus.approved:
          final profiles = await _supabaseService.getData(
            table: SupabaseTable.profiles,
            column: 'id',
            value: currentUser?.id,
          );
          if (profiles.isNotEmpty) {
            final ProfileModel profile = ProfileModel.fromJson(profiles[0]);
            if (profile.checkedConsent == true) {
              _navigate(_main);
            } else {
              _navigate(_welcomeConsent);
            }
          } else {
            _navigate(_main);
          }
          break;

        case IdentityVerificationStatus.rejected:
          _navigate(_verificationRejected);
          break;

        case IdentityVerificationStatus.notStarted:
          _navigate(_verifyIdentity);
          break;
      }
    } catch (e) {
      log('onVerificationProgressContinue error: $e');
      _showError('Failed to continue. Try again.');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  // ---------------------------------------------------------------------------
  // CHECK SIGNUP CONSENT
  // ---------------------------------------------------------------------------

  Future<void> checkSignUpConsent() async {
    try {
      final profiles = await _supabaseService.getData(
        table: SupabaseTable.profiles,
        column: 'id',
        value: currentUser?.id,
      );
      if (profiles.isNotEmpty) {
        final ProfileModel profile = ProfileModel.fromJson(profiles[0]);
        if (profile.checkedConsent == null || profile.checkedConsent == false) {
          _navigate(_welcomeConsent);
        } else {
          _navigate(_main);
        }
      } else {
        _navigate(_onboarding);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // SIGN OUT
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    try {
      _isManualLogout = true;
      await _authService.signOut();
      await Preference.clear();
      emit(state.copyWith(clearUser: true));
      _showSuccess('Signed out successfully.');
      _navigate(_signIn);
    } catch (e) {
      _showError('Error while signing out.');
    }
  }

  // ---------------------------------------------------------------------------
  // PRIVATE HELPERS
  // ---------------------------------------------------------------------------

  void _showError(String message) {
    SnackbarHelper.showError(message);
  }

  void _showSuccess(String message) {
    SnackbarHelper.showSuccess(message);
  }

  void _handleSessionExpired() {
    SnackbarHelper.showError('Session expired. Please log in again.');
    _navigate(_signIn);
  }
}
