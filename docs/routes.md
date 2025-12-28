# Routes & Screens

Centralized routing logic resides in [lib/route_generator.dart](../lib/route_generator.dart) using `PageTransition` for animations.

## Initial

- App root: [lib/base/app_view.dart](../lib/base/app_view.dart)
  - `initialRoute`: `IntroScreen.routePath`
  - Global binding: `GlobalBinding()`

## Auth + Onboarding

- `IntroScreen.routePath`: [lib/presentation/splash/intro_screen.dart](../lib/presentation/splash/intro_screen.dart)
- `SplashScreen.routePath`: [lib/presentation/splash/splash_screen.dart](../lib/presentation/splash/splash_screen.dart)
- `SignInScreen.routePath`: [lib/presentation/authentication/signin_screen.dart](../lib/presentation/authentication/signin_screen.dart)
- `SignUpScreen.routePath`: [lib/presentation/authentication/signup/signup_screen.dart](../lib/presentation/authentication/signup/signup_screen.dart)
- `ForgotPasswordScreen.routePath`: [lib/presentation/authentication/forgot_password.dart](../lib/presentation/authentication/forgot_password.dart)
- `UpdatePassword.route`: [lib/presentation/authentication/update_password_screen.dart](../lib/presentation/authentication/update_password_screen.dart)
- `WelcomeConsentScreen.routePath`: [lib/presentation/authentication/welcome_consent_screen.dart](../lib/presentation/authentication/welcome_consent_screen.dart)
- `OnboardingScreen.routePath`: [lib/presentation/onboarding/onboarding_screen.dart](../lib/presentation/onboarding/onboarding_screen.dart)

## Profile & Identity Verification

- `CompleteProfileScreen.routePath`: [lib/presentation/authentication/signup/complete_profile_screen.dart](../lib/presentation/authentication/signup/complete_profile_screen.dart)
- `VerifyIdentityScreen.routePath`: [lib/presentation/authentication/signup/verify_identity_screen.dart](../lib/presentation/authentication/signup/verify_identity_screen.dart)
- `VerificationInProgressScreen.routePath`: [lib/presentation/authentication/signup/verification_progress_view.dart](../lib/presentation/authentication/signup/verification_progress_view.dart)
- `IdentityVerifiedScreen.routePath`: [lib/presentation/authentication/signup/identity_verified_view.dart](../lib/presentation/authentication/signup/identity_verified_view.dart)

## MFA

- `MFAEnrollPage.route`: [lib/presentation/mfa/enroll_page.dart](../lib/presentation/mfa/enroll_page.dart)
- `MFAVerifyPage.routePath`: [lib/presentation/mfa/verify_page.dart](../lib/presentation/mfa/verify_page.dart)

## Home + Interview

- `HomeScreen.routePath`: [lib/presentation/home/home_screen.dart](../lib/presentation/home/home_screen.dart)
- `InterviewScreen.routePath`: [lib/presentation/interview/interview_screen.dart](../lib/presentation/interview/interview_screen.dart)

## Deep Link Example

- `EmailVerifyScreen.route`: [lib/presentation/authentication/email_verify_screen.dart](../lib/presentation/authentication/email_verify_screen.dart)
- Handled in [lib/base/app_view.dart](../lib/base/app_view.dart): `returnpilot-app://email/verify`
