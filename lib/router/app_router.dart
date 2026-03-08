import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tcm_return_pilot/presentation/authentication/cubit/auth_cubit.dart';
import 'package:tcm_return_pilot/presentation/splash/intro_screen.dart';
import 'package:tcm_return_pilot/presentation/splash/splash_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/signin_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/signup_screen.dart';
import 'package:tcm_return_pilot/presentation/onboarding/onboarding_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/forgot_password.dart';
import 'package:tcm_return_pilot/presentation/authentication/email_verify_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/update_password_screen.dart';
import 'package:tcm_return_pilot/presentation/mfa/enroll_page.dart';
import 'package:tcm_return_pilot/presentation/mfa/verify_page.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/complete_profile_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/verify_identity_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/verification_progress_view.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/verification_rejected_view.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/identity_verified_view.dart';
import 'package:tcm_return_pilot/presentation/authentication/welcome_consent_screen.dart';
import 'package:tcm_return_pilot/presentation/main/main_nav_screen.dart';
import 'package:tcm_return_pilot/presentation/home/home_screen.dart';
import 'package:tcm_return_pilot/presentation/interview/interview_screen.dart';
import 'package:tcm_return_pilot/presentation/tax/screens/tax_dashboard_screen.dart';
import 'package:tcm_return_pilot/presentation/tax/screens/income_forms_screen.dart';
import 'package:tcm_return_pilot/presentation/tax/screens/w2_form_screen.dart';
import 'package:tcm_return_pilot/presentation/tax/screens/form_1099_screen.dart';
import 'package:tcm_return_pilot/presentation/tax/screens/personal_info_screen.dart';
import 'package:tcm_return_pilot/presentation/tax/screens/deductions_screen.dart';
import 'package:tcm_return_pilot/presentation/tax/screens/review_screen.dart';
import 'package:tcm_return_pilot/presentation/tax/screens/enhanced_review_screen.dart';
import 'package:tcm_return_pilot/widgets/tax/document_management_widget.dart';

/// Converts a [Stream] into a [ChangeNotifier] so GoRouter can listen
/// for auth-state changes via [refreshListenable].
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static GoRouter router(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      routes: _routes,
    );
  }

  static final List<RouteBase> _routes = [
    _goRoute('/', const IntroScreen()),
    _goRoute('/splash', const SplashScreen()),
    _goRoute('/sign-in', const SignInScreen()),
    _goRoute('/sign-up', const SignUpScreen()),
    _goRoute('/onboarding', const OnboardingScreen()),
    _goRoute('/forgot-password', const ForgotPasswordScreen()),
    _goRoute('/email/verify', const EmailVerifyScreen()),
    _goRoute('/update-password', const UpdatePassword()),
    _goRoute('/mfa-enroll', const MFAEnrollPage()),
    _goRoute('/mfa-verify', const MFAVerifyPage()),
    _goRoute('/complete-profile', const CompleteProfileScreen()),
    _goRoute('/verify-identity', const VerifyIdentityScreen()),
    _goRoute('/verification-progress', const VerificationInProgressScreen()),
    _goRoute('/verification-rejected', const VerificationRejectedScreen()),
    _goRoute('/identity-verified', const IdentityVerifiedScreen()),
    _goRoute('/welcome-consent', const WelcomeConsentScreen()),
    _goRoute('/main', const MainNavScreen()),
    _goRoute('/home', const HomeScreen()),
    _goRoute('/interview', const InterviewScreen()),
    _goRoute('/tax-dashboard', const TaxDashboardScreen()),
    _goRoute('/income-forms', const IncomeFormsScreen()),
    _goRoute('/w2-form', const W2FormScreen()),
    _goRoute('/form-1099', const Form1099Screen()),
    _goRoute('/personal-info', const PersonalInfoScreen()),
    _goRoute('/deductions', const DeductionsScreen()),
    _goRoute('/review', const ReviewScreen()),
    _goRoute('/enhanced-review', const EnhancedReviewScreen()),
    _goRoute('/document-management', const DocumentManagementWidget()),
  ];

  /// Helper that builds a [GoRoute] with a right-to-left slide transition.
  static GoRoute _goRoute(String path, Widget screen) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: screen,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
