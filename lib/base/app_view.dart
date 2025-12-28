import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/domain/bindings/global_bindings.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/domain/theme/theme_controller.dart';
import 'package:tcm_return_pilot/presentation/authentication/email_verify_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/complete_profile_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/identity_verified_view.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/verification_progress_view.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/verification_rejected_view.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/verify_identity_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/welcome_consent_screen.dart';
import 'package:tcm_return_pilot/presentation/mfa/verify_page.dart';
import 'package:tcm_return_pilot/presentation/splash/intro_screen.dart';
import 'package:tcm_return_pilot/route_generator.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();

    ///Handle deep link when app is already running (foreground/background)
    // _appLinks.uriLinkStream.listen((Uri? uri) {
    //   if (uri != null) _handleDeepLink(uri);
    // });

    // Handle deep link when app starts cold (initial launch)
    //_checkInitialLink();
  }

  Future<void> _checkInitialLink() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleDeepLink(initialUri);
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'returnpilot-app' && uri.path == '/email/verify') {
      Get.toNamed(EmailVerifyScreen.route);
      //Supabase.instance.client.auth.linkIdentity(provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ThemeController before building
    Get.put(ThemeController(), permanent: true);

    return GetBuilder<ThemeController>(
      init: ThemeController.to,
      builder: (controller) => GetMaterialApp(
        initialBinding: GlobalBinding(),
        title: Strings.appName,
        debugShowCheckedModeBanner: false,
        initialRoute: IntroScreen.routePath,
        //initialRoute: WelcomeConsentScreen.routePath,
        //theme: AppTheme.darkTheme,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: controller.flutterThemeMode,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
