import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/constants/app_colors.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/signin_screen.dart';
import 'package:tcm_return_pilot/presentation/mfa/enroll_page.dart';
import 'package:tcm_return_pilot/presentation/onboarding/onboarding_screen.dart';
import 'package:tcm_return_pilot/widgets/main_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = 'SplashScreen';
  static const String routePath = '/splashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authController = Get.put(AuthController(), permanent: true);
  //final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(seconds: 3), () {
    //   if (!mounted) return;
    //   Navigator.pushReplacementNamed(context, SignInScreen.routePath);
    // });
    Future.delayed(const Duration(seconds: 2), () {
      _authController.checkAuthStatus();
      //Navigator.pushNamed(context, MFAEnrollPage.routePath);
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [AppColors.primaryColor, AppColors.blueColor],
  //         ),
  //       ),
  //       child: Center(child: Image.asset(Strings.appLogo)),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Color(0xFF0B0B0F),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              stops: [0, 1],
              begin: AlignmentDirectional(0, -1),
              end: AlignmentDirectional(0, 1),
            ),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MainLogo(),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                    child: Text(
                      'powered by',
                      style: AppTheme.of(context).bodyMedium.override(
                        fontFamily: AppTheme.of(context).bodyMediumFamily,
                        color: AppTheme.of(context).secondaryBackground,
                        fontSize: 13,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic,
                        lineHeight: 1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            Strings.symbolLogo,
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            Strings.solvquestLogo,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'AI tax & compliance service',
                      style: AppTheme.of(context).bodyMedium.override(
                        fontFamily: AppTheme.of(context).bodyMediumFamily,
                        color: AppTheme.of(context).secondaryBackground,
                        fontSize: 12,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
