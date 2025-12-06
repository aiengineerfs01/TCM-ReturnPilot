import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/domain/bindings/global_bindings.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/email_verify_screen.dart';
import 'package:tcm_return_pilot/presentation/mfa/enroll_page.dart';
import 'package:tcm_return_pilot/presentation/splash/splash_screen.dart';
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
    return GetMaterialApp(
      initialBinding: GlobalBinding(),
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routePath,
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.of(context).primaryBackground,
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppTheme.of(context).primary,
        ),
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
