import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  static const String routeName = 'IntroScreen';
  static const String routePath = '/introScreen';

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 13), () {
      if (!mounted) return;
      context.go('/splash');
    });
  }

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
                Center(
                  child: DefaultTextStyle(
                    style: poppinsRegular.copyWith(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          "SCAN YOUR W-2,\n"
                          "GET YOUR INCOME TAX RETURNS FILED,\n"
                          "AND YOUR INCOME TAX REFUND IN\n"
                          "TWO DAYS OR LESS",
                          textAlign: TextAlign.center,
                          speed: Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                      pause: Duration(milliseconds: 200),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
