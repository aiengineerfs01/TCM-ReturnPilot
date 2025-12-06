import 'dart:developer';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tcm_return_pilot/models/profile_model.dart';
import 'package:tcm_return_pilot/presentation/authentication/signin_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/welcome_consent_screen.dart';
import 'package:tcm_return_pilot/presentation/home/home_screen.dart';
import 'package:tcm_return_pilot/presentation/mfa/enroll_page.dart';
import 'package:tcm_return_pilot/presentation/mfa/verify_page.dart';
import 'package:tcm_return_pilot/presentation/onboarding/onboarding_screen.dart';
import 'package:tcm_return_pilot/services/auth_service.dart';
import 'package:tcm_return_pilot/services/supabase_service.dart';
import 'package:tcm_return_pilot/utils/snackbar.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool _isLoading = false.obs;
  final Rxn<User> user = Rxn<User>();
  final RxString _errorMessage = ''.obs;
  bool _isManualLogout = false;
  bool _isInitialized = false;

  static final SupabaseClient _supabaseClient = SupabaseService.client;

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
          return; // 👈 don't show expired message for manual logout
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

        await checkSignUpConsent();
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
      //Get.toNamed(MFAVerifyPage.routePath);
      //await checkSignUpConsent();
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

  Future<void> handlePostLogin() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      Get.offAllNamed(SignInScreen.routePath);
      return;
    }

    final isMFAEnabled = await isUserMFAEnabled();

    if (isMFAEnabled) {
      // 🔐 Go to MFA verification screen
      Get.offAllNamed(MFAVerifyPage.routePath);
    } else {
      // 🧩 User hasn’t enrolled yet, go to enroll screen
      Get.offAllNamed(MFAEnrollPage.route);
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

        await createProfile(
          userId: currentUser?.id ?? '',
          email: currentUser?.email ?? '',
          displayName: displayName,
        );

        //_showSuccess('Account created successfully!');
        _showSuccess(
          'Account created successfully! A verification email has been sent to your email address.',
        );
        //Get.toNamed(MFAEnrollPage.routePath);
        Get.toNamed(SignInScreen.routePath);
        //Get.offAllNamed(WelcomeConsentScreen.routePath);
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

      await _supabaseClient.from(SupabaseTable.profile.name).insert(data);
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
          .from(SupabaseTable.profile.name)
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
  // Check SignUp Consent
  // ------------------------------

  Future<void> checkSignUpConsent() async {
    try {
      final profiles = await supabaseClient.getData(
        table: SupabaseTable.profile,
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
