import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tcm_return_pilot/presentation/authentication/email_verify_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/forgot_password.dart';
import 'package:tcm_return_pilot/presentation/authentication/signin_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/update_password_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/welcome_consent_screen.dart';
import 'package:tcm_return_pilot/presentation/home/home_screen.dart';
import 'package:tcm_return_pilot/presentation/interview/interview_screen.dart';
import 'package:tcm_return_pilot/presentation/mfa/enroll_page.dart';
import 'package:tcm_return_pilot/presentation/mfa/verify_page.dart';
import 'package:tcm_return_pilot/presentation/onboarding/onboarding_screen.dart';
import 'package:tcm_return_pilot/presentation/splash/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint("📌 generateRoute called with: ${settings.name}");
    debugPrint("📦 arguments: ${settings.arguments}");

    final uri = Uri.parse(settings.name!);
    final routeName = uri.path; // IGNORE query parameters

    switch (routeName) {
      case SplashScreen.routePath:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case SignInScreen.routePath:
        return PageTransition(
          child: const SignInScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case OnboardingScreen.routePath:
        return PageTransition(
          child: const OnboardingScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case ForgotPasswordScreen.routePath:
        return PageTransition(
          child: const ForgotPasswordScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case SignUpScreen.routePath:
        return PageTransition(
          child: const SignUpScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case WelcomeConsentScreen.routePath:
        return PageTransition(
          child: const WelcomeConsentScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case HomeScreen.routePath:
        return PageTransition(
          child: const HomeScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case InterviewScreen.routePath:
        return PageTransition(
          child: const InterviewScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case MFAEnrollPage.route:
        return PageTransition(
          child: const MFAEnrollPage(),
          type: PageTransitionType.rightToLeft,
        );

      case MFAVerifyPage.routePath:
        return PageTransition(
          child: const MFAVerifyPage(),
          type: PageTransitionType.rightToLeft,
        );

      case EmailVerifyScreen.route:
        return PageTransition(
          child: const EmailVerifyScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case UpdatePassword.route:
        return PageTransition(
          child: const UpdatePassword(),
          type: PageTransitionType.rightToLeft,
        );
      default:
        debugPrint("❌ Unknown route: ${settings.name}");
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text("Routing Error")),
          body: Center(
            child: Text(
              "❌ Unknown route:\n$routeName",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        );
      },
    );
  }
}
