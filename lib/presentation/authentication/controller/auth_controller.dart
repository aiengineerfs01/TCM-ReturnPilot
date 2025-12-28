import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tcm_return_pilot/models/identity_verification_model.dart';
import 'package:tcm_return_pilot/models/profile_model.dart';
import 'package:tcm_return_pilot/presentation/authentication/signin_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/complete_profile_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/verification_progress_view.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/verification_rejected_view.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/verify_identity_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/welcome_consent_screen.dart';
import 'package:tcm_return_pilot/presentation/home/home_screen.dart';
import 'package:tcm_return_pilot/presentation/mfa/enroll_page.dart';
import 'package:tcm_return_pilot/presentation/mfa/verify_page.dart';
import 'package:tcm_return_pilot/presentation/onboarding/onboarding_screen.dart';
import 'package:tcm_return_pilot/services/auth_service.dart';
import 'package:tcm_return_pilot/services/identity_verification_service.dart';
import 'package:tcm_return_pilot/services/storage_service.dart';
import 'package:tcm_return_pilot/services/supabase_service.dart';
import 'package:tcm_return_pilot/utils/enums.dart';
import 'package:tcm_return_pilot/utils/snackbar.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool _isLoading = false.obs;
  final Rxn<User> user = Rxn<User>();
  final RxString _errorMessage = ''.obs;
  bool _isManualLogout = false;
  bool _isInitialized = false;

  static final SupabaseClient _supabaseClient = SupabaseService.client;

  // Add service instance
  final IdentityVerificationService _verificationService =
      IdentityVerificationService();

  // Getters
  bool get isLoading => _isLoading.value;
  User? get currentUser => user.value;
  String get errorMessage => _errorMessage.value;
  SupabaseService get supabaseClient => SupabaseService();

  // Setters
  set isLoading(bool value) => _isLoading.value = value;
  set currentUser(User? value) => user.value = value;
  set errorMessage(String value) => _errorMessage.value = value;

  // ------------------------------
  // INIT
  // ------------------------------
  @override
  void onInit() {
    super.onInit();
    user.value = _authService.currentUser;

    // Listen for auth/session state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final newUser = event.session?.user;
      if (!_isInitialized) return;

      if (newUser != null) {
        user.value = newUser;
      } else {
        if (_isManualLogout) {
          _isManualLogout = false; // reset flag
          return; // don't show expired message for manual logout
        }

        // Session expired or user signed out
        user.value = null;
        _handleSessionExpired();
      }
    });
  }

  // ------------------------------
  // CHECK AUTH STATUS (for SplashScreen)
  // ------------------------------
  Future<void> checkAuthStatus() async {
    try {
      isLoading = true;

      final currentSession = Supabase.instance.client.auth.currentSession;

      if (currentSession != null) {
        user.value = currentSession.user;
        // Session exists (AAL2) — go through profile/identity checks
        await handlePostMfa();
      } else {
        Get.offAllNamed(OnboardingScreen.routePath);
      }
    } catch (e) {
      _showError('Error while checking session.');
      Get.offAllNamed(OnboardingScreen.routePath);
    } finally {
      isLoading = false;
    }
  }

  // ------------------------------
  // LOGIN
  // ------------------------------
  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      final response = await _authService.signIn(
        email: email,
        password: password,
      );
      currentUser = response.user;

      _showSuccess('Login successful!');
      await handlePostLogin();
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading = false;
      _isInitialized = true;
    }
  }

  // ------------------------------
  // HANDLE POST LOGIN
  // ------------------------------
  /// Called after password login (AAL1). Routes to MFA first.
  Future<void> handlePostLogin() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      Get.offAllNamed(SignInScreen.routePath);
      return;
    }

    // MFA FIRST — ensures AAL2 session before anything else
    final isMFAEnabled = await isUserMFAEnabled();
    if (isMFAEnabled) {
      Get.offAllNamed(MFAVerifyPage.routePath);
    } else {
      Get.offAllNamed(MFAEnrollPage.route);
    }
  }

  // ------------------------------
  // HANDLE POST MFA
  // ------------------------------
  /// Called after MFA verification succeeds (AAL2). Checks profile/identity status.
  Future<void> handlePostMfa() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      Get.offAllNamed(SignInScreen.routePath);
      return;
    }

    final profiles = await supabaseClient.getData(
      table: SupabaseTable.profiles,
      column: 'id',
      value: user.id,
    );

    if (profiles.isEmpty) {
      Get.offAllNamed(OnboardingScreen.routePath);
      return;
    }

    ProfileModel profile = ProfileModel.fromJson(profiles[0]);

    if (profile.isProfileCompleted == false) {
      Get.offAllNamed(CompleteProfileScreen.routePath);
    } else if (profile.identityVerificationStatus ==
        IdentityVerificationStatus.notStarted) {
      Get.offAllNamed(VerifyIdentityScreen.routePath);
    } else if (profile.identityVerificationStatus ==
        IdentityVerificationStatus.pending) {
      Get.offAllNamed(VerificationInProgressScreen.routePath);
    } else if (profile.identityVerificationStatus ==
        IdentityVerificationStatus.rejected) {
      Get.offAllNamed(VerificationRejectedScreen.routePath);
    } else {
      // Approved — consent check or home
      if (profile.checkedConsent == true) {
        Get.offAllNamed(HomeScreen.routePath);
      } else {
        Get.offAllNamed(WelcomeConsentScreen.routePath);
      }
    }
  }

  // ------------------------------
  // CHECK USER MFA ENABLE
  // ------------------------------

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

  // ------------------------------
  // SIGNUP
  // ------------------------------

  Future<void> signUp(String email, String password, String displayName) async {
    try {
      isLoading = true;

      final response = await _authService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        currentUser = response.user;

        _showSuccess(
          'Account created successfully! A verification email has been sent to your email address.',
        );
        Get.toNamed(SignInScreen.routePath);
      } else {
        _showError('Signup failed. Please try again.');
      }
    } on Exception catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } catch (e) {
      _showError('Unexpected error occurred during sign-up.');
    } finally {
      isLoading = false;
      _isInitialized = true;
    }
  }

  // ------------------------------
  // RESET PASSWORD
  // ------------------------------
  Future<void> resetPassword(String email) async {
    try {
      isLoading = true;
      final error = await _authService.resetPassword(email);

      if (error != null) {
        _showError(error);
      } else {
        _showSuccess(
          'Password reset link sent to registered email! Check your inbox.',
        );
        Get.offAllNamed(SignInScreen.routePath);
      }
    } catch (e) {
      _showError('Failed to send reset password email.');
    } finally {
      isLoading = false;
    }
  }

  // ------------------------------
  // RE-AUTHENTICATE WITH MFA
  // ------------------------------
  Future<bool> verifyMfaForSensitiveAction(String code) async {
    try {
      isLoading = true;

      final error = await _authService.reauthenticateMFA(code);

      if (error != null) {
        _showError(error);
        return false;
      }

      return true;
    } finally {
      isLoading = false;
    }
  }

  // ------------------------------
  // UPDATE PASSWORD
  // ------------------------------
  Future<void> updatePassword(String code, String newPassword) async {
    try {
      isLoading = true;

      // Re-authenticate with MFA
      final ok = await verifyMfaForSensitiveAction(code);
      if (!ok) return;

      final error = await _authService.updatePassword(newPassword);

      if (error != null) {
        _showError(error);
        return;
      }

      _showSuccess('Password updated successfully!');
      Get.offAllNamed(SignInScreen.routePath);
    } catch (e) {
      _showError('Failed to update password.');
    } finally {
      isLoading = false;
    }
  }

  // ------------------------------
  // CREATE PROFILE
  // ------------------------------

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

  // ------------------------------
  // UPDATE PROFILE CONSENT
  // ------------------------------
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

  // ------------------------------
  // Complete Profile
  // ------------------------------

  Future<void> completeProfile(
    String firstName,
    String lastName,
    String address,
    String phone,
    File? profileImage,
  ) async {
    try {
      isLoading = true;
      String? profleImageUrl = '';
      if (profileImage != null) {
        profleImageUrl = await supabaseClient.uploadFileToSupabaseBucket(
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

      Get.toNamed(VerifyIdentityScreen.routePath);
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
    }
  }

  // ------------------------------
  // SUBMIT IDENTITY VERIFICATION
  // ------------------------------
  Future<void> submitIdentityVerification({
    required File frontId,
    required File backId,
    required File selfie,
  }) async {
    try {
      isLoading = true;

      final result = await _verificationService.submitVerification(
        frontId: frontId,
        backId: backId,
        selfie: selfie,
      );

      if (result.isSuccess) {
        _showSuccess(result.message ?? 'Verification submitted successfully!');
        Get.offAllNamed(VerificationInProgressScreen.routePath);
      } else {
        _showError(result.errorMessage ?? 'Failed to submit verification');
      }
    } catch (e) {
      log('Error in submitIdentityVerification: $e');
      _showError('An error occurred while submitting verification');
    } finally {
      isLoading = false;
    }
  }

  // ------------------------------
  // GET VERIFICATION STATUS
  // ------------------------------
  Future<IdentityVerificationModel?> getVerificationStatus() async {
    try {
      return await _verificationService.getVerificationStatus();
    } catch (e) {
      log('Error getting verification status: $e');
      return null;
    }
  }

  // ------------------------------
  // RESUBMIT VERIFICATION
  // ------------------------------
  Future<void> resubmitVerification({
    File? frontId,
    File? backId,
    File? selfie,
  }) async {
    try {
      isLoading = true;

      final result = await _verificationService.resubmitVerification(
        frontId: frontId,
        backId: backId,
        selfie: selfie,
      );

      if (result.isSuccess) {
        _showSuccess(
          result.message ?? 'Verification resubmitted successfully!',
        );
        Get.offAllNamed(VerificationInProgressScreen.routePath);
      } else {
        _showError(result.errorMessage ?? 'Failed to resubmit verification');
      }
    } catch (e) {
      log('Error in resubmitVerification: $e');
      _showError('An error occurred while resubmitting verification');
    } finally {
      isLoading = false;
    }
  }

  // ------------------------------
  // CONTINUE FROM VERIFICATION IN PROGRESS
  // ------------------------------
  Future<void> onVerificationProgressContinue() async {
    try {
      isLoading = true;

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
          // Approved — go to consent or home
          final profiles = await supabaseClient.getData(
            table: SupabaseTable.profiles,
            column: 'id',
            value: currentUser?.id,
          );
          if (profiles.isNotEmpty) {
            ProfileModel profile = ProfileModel.fromJson(profiles[0]);
            if (profile.checkedConsent == true) {
              Get.offAllNamed(HomeScreen.routePath);
            } else {
              Get.offAllNamed(WelcomeConsentScreen.routePath);
            }
          } else {
            Get.offAllNamed(HomeScreen.routePath);
          }
          break;

        case IdentityVerificationStatus.rejected:
          // Show rejection screen with reason
          Get.offAllNamed(VerificationRejectedScreen.routePath);
          break;

        case IdentityVerificationStatus.notStarted:
          // Let user start verification
          Get.offAllNamed(VerifyIdentityScreen.routePath);
          break;
      }
    } catch (e) {
      log('onVerificationProgressContinue error: $e');
      _showError('Failed to continue. Try again.');
    } finally {
      isLoading = false;
    }
  }

  // ------------------------------
  // Check SignUp Consent
  // ------------------------------

  Future<void> checkSignUpConsent() async {
    try {
      final profiles = await supabaseClient.getData(
        table: SupabaseTable.profiles,
        column: 'id',
        value: currentUser?.id,
      );
      if (profiles.isNotEmpty) {
        ProfileModel profile = ProfileModel.fromJson(profiles[0]);
        if (profile.checkedConsent == null || profile.checkedConsent == false) {
          Get.offAllNamed(WelcomeConsentScreen.routePath);
        } else {
          Get.offAllNamed(HomeScreen.routePath);
        }
      } else {
        Get.offAllNamed(OnboardingScreen.routePath);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // ------------------------------
  // SIGN OUT
  // ------------------------------
  Future<void> logout() async {
    try {
      _isManualLogout = true;
      await _authService.signOut();
      await Preference.clear();
      user.value = null;
      _showSuccess('Signed out successfully.');
      Get.offAllNamed(SignInScreen.routePath);
    } catch (e) {
      _showError('Error while signing out.');
    }
  }

  // ------------------------------
  // PRIVATE HELPERS
  // ------------------------------
  void _showError(String message) {
    SnackbarHelper.showError(message);
  }

  void _showSuccess(String message) {
    SnackbarHelper.showSuccess(message);
  }

  void _handleSessionExpired() {
    SnackbarHelper.showError('Session expired. Please log in again.');
    Get.offAllNamed(SignInScreen.routePath);
  }

  // ------------------------------
  // CLEANUP
  // ------------------------------
  @override
  void onClose() {
    _isLoading.close();
    _errorMessage.close();
    user.close();
    super.onClose();
  }
}
