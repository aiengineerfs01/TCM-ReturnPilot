import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/signin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = 'OnboardingScreen';
  static const String routePath = '/onboardingScreen';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildOnboardingPage({
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 30, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: poppinsSemiBold.copyWith(
              fontSize: 30,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: Text(
              subtitle,
              style: poppinsRegular.copyWith(
                fontSize: 15,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
          const Spacer(),
          Align(
            alignment: AlignmentDirectional(1, 0),
            child: Image.asset(
              imagePath,
              width: 330,
              fit: BoxFit.cover,
              alignment: const Alignment(0, 1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: Container(
          padding: EdgeInsets.only(top: 50),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                children: [
                  _buildOnboardingPage(
                    title: 'The best app for manage your taxation',
                    subtitle:
                        'Committed to accuracy and progress guiding every taxpayer toward confident, compliant growth.',
                    imagePath: 'assets/images/onboarding1.png',
                  ),
                  _buildOnboardingPage(
                    title: 'Simple and easy\nto control your\ntaxation',
                    subtitle:
                        'Always moving forward with smart, simple, and secure tax solutions making filing easy and stress-free.',
                    imagePath: 'assets/images/onboarding2.png',
                  ),
                  Stack(
                    alignment: AlignmentDirectional.bottomStart,
                    children: [
                      _buildOnboardingPage(
                        title:
                            'Smart Filing That Protects Your Hard-Earned Money',
                        subtitle:
                            'File with confidence knowing every deduction is maximized and your return stays fully compliant.',
                        imagePath: 'assets/images/onboarding3.png',
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 30,
                          bottom: 30,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              SignInScreen.routePath,
                            );
                          },
                          child: Text(
                            'Skip',
                            style: poppinsMedium.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: SlideEffect(
                      spacing: 8,
                      radius: 8,
                      dotWidth: 8,
                      dotHeight: 8,
                      dotColor: Colors.white,
                      activeDotColor: AppTheme.of(context).primary,
                    ),
                    onDotClicked: (index) async {
                      await _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
