import 'dart:developer';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';
import 'package:tcm_return_pilot/services/supabase_service.dart';
import 'package:tcm_return_pilot/widgets/custom_snackbar.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseService.client;

  // -------------------------
  // SIGN UP
  // -------------------------

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'returnpilot-app://callback/email/verify',
      );

      if (response.user == null) {
        throw AuthException('Signup failed. Please try again.');
      }
      return response;
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw AuthException('Something went wrong during sign up.');
    }
  }

  // -------------------------
  // LOGIN
  // -------------------------
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw AuthException('No user found for the provided credentials.');
      }
      return response;
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw AuthException('Something went wrong during sign in.');
    }
  }

  // -------------------------
  // VERIFY MFA
  // -------------------------
  Future<void> verifyMfa({
    required String factorId,
    required String code,
  }) async {
    try {
      // Step 1 — Create MFA challenge
      final challenge = await _supabase.auth.mfa.challenge(factorId: factorId);

      // Step 2 — Verify user input code
      await _supabase.auth.mfa.verify(
        factorId: factorId,
        challengeId: challenge.id,
        code: code,
      );

      // Step 3 — Refresh session
      await _supabase.auth.refreshSession();

      // Step 4 - Route via AuthController to check profile/identity status
      Get.find<AuthController>().handlePostMfa();
    } on AuthException catch (e) {
      AppSnackBar.show(title: 'Error', message: e.message);
    } catch (e) {
      AppSnackBar.show(title: 'Error', message: 'Something went wrong.');
    }
  }

  // -------------------------
  // VERIFY MFA (auto-fetch factor)
  // -------------------------
  Future<void> verifyTotpCode(String code) async {
    final authController = Get.find<AuthController>();
    try {
      authController.isLoading = true;
      // Step 1 — Fetch current MFA factors
      final factorsResponse = await _supabase.auth.mfa.listFactors();

      // Step 2 — Pick the first TOTP factor (active)
      final factor = factorsResponse.totp.firstOrNull;
      if (factor == null) {
        throw AuthException('No TOTP factor found for this user.');
      }

      // Step 3 — Create challenge
      final challenge = await _supabase.auth.mfa.challenge(factorId: factor.id);

      // Step 4 — Verify TOTP code
      await _supabase.auth.mfa.verify(
        factorId: factor.id,
        challengeId: challenge.id,
        code: code,
      );

      // Step 5 — Refresh session
      await _supabase.auth.refreshSession();

      // Step 6 - Route via AuthController to check profile/identity status
      Get.find<AuthController>().handlePostMfa();
    } on AuthException catch (e) {
      log(e.toString());
      AppSnackBar.show(title: 'Error', message: e.message);
    } catch (e) {
      log(e.toString());
      AppSnackBar.show(
        title: 'Error',
        message: 'Unexpected error occurred during MFA verification.',
      );
    } finally {
      authController.isLoading = false;
    }
  }

  // -------------------------
  // RESET PASSWORD (send email)
  // -------------------------
  Future<String?> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'returnpilot-app://callback/password/update',
      );

      return null; // Success
    } on AuthException catch (e) {
      return _handleResetPasswordError(e);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> reauthenticateMFA(String code) async {
    try {
      final factors = await _supabase.auth.mfa.listFactors();
      final factor = factors.totp.firstOrNull;

      if (factor == null) {
        return "No active MFA factor found.";
      }

      // Create challenge
      final challenge = await _supabase.auth.mfa.challenge(factorId: factor.id);

      // Verify code → Refreshes session to AAL2
      await _supabase.auth.mfa.verify(
        factorId: factor.id,
        challengeId: challenge.id,
        code: code,
      );

      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to re-authenticate.";
    }
  }

  // -------------------------
  // UPDATE PASSWORD (after reset or logged in)
  // -------------------------
  Future<String?> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return null; // Success
    } on AuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // -------------------------
  // SIGN OUT
  // -------------------------
  Future<String?> signOut() async {
    try {
      await _supabase.auth.signOut();
      return null; // Success
    } on AuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // -------------------------
  // CURRENT USER
  // -------------------------
  User? get currentUser => _supabase.auth.currentUser;

  // -------------------------
  // PRIVATE: Error Handling
  // -------------------------
  String _handleAuthError(AuthException e) {
    switch (e.message.toLowerCase()) {
      case 'invalid login credentials':
        return 'Incorrect email or password.';
      case 'email not confirmed':
        return 'Please verify your email before logging in.';
      case 'user already registered':
        return 'This email is already registered.';
      default:
        return e.message;
    }
  }

  String _handleResetPasswordError(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('user not found')) {
      return 'No account found with this email.';
    }

    if (msg.contains('email not confirmed')) {
      return 'Your email is not verified. Please verify first.';
    }

    return e.message;
  }
}
