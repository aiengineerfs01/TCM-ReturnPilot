import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/update_password_screen.dart';
import 'package:tcm_return_pilot/presentation/interview/interview_screen.dart';
import 'package:tcm_return_pilot/presentation/mfa/enroll_page.dart';
import 'package:tcm_return_pilot/presentation/mfa/verify_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = 'HomeScreen';
  static const String routePath = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.of(context).primaryBackground,
        // body: Obx(() {
        //   return Column(children: [Text('Home Screen')]);
        // }),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, InterviewScreen.routePath),

                child: Text('Interview Screen'),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => _authController.logout(),
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
