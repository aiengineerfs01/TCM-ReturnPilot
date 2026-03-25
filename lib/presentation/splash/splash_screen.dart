import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/presentation/authentication/cubit/auth_cubit.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/signin_screen.dart';
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
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      //Navigator.pushReplacementNamed(context, OnboardingScreen.routePath);
      //Navigator.pushReplacementNamed(context, SignInScreen.routePath);
    });
    Future.delayed(const Duration(seconds: 2), () {
      context.read<AuthCubit>().checkAuthStatus();
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
        backgroundColor: AppTheme.of(context).primary,
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MainLogo(),
               
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 67),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                      child: Text(
                        'Powered by',
                        style: poppinsRegular.copyWith(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.of(context).appGreen,
                        ),
                      ),
                    ),
                    Image.asset(
                      height: 60,
                      Strings.solvquestTaxLogo,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
