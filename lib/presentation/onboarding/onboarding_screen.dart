import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_colors.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

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

  // List of onboarding image URLs
  final List<String> onboardingImages = [
    'https://nieyuuiajieavwhqkovg.supabase.co/storage/v1/object/public/app_media/onboarding_assets/onboarding_1.png',
    'https://nieyuuiajieavwhqkovg.supabase.co/storage/v1/object/public/app_media/onboarding_assets/onboarding_2.png',
    'https://nieyuuiajieavwhqkovg.supabase.co/storage/v1/object/public/app_media/onboarding_assets/onboarding_3.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // // Preload all onboarding images for instant display
    // for (var url in onboardingImages) {
    //   precacheImage(CachedNetworkImageProvider(url), context);
    // }
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
    return Stack(
      children: [
        // ---------- Background Image with CachedNetworkImage ----------
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: imagePath,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade300,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
            fadeInDuration: const Duration(milliseconds: 500),
            fadeOutDuration: const Duration(milliseconds: 500),
          ),
        ),

        // ---------- Blue Glow at Bottom ----------
        Positioned(
          bottom: -60,
          left: 0,
          right: 0,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.35),
                  blurRadius: 90,
                  spreadRadius: 40,
                  offset: const Offset(0, 40),
                ),
              ],
            ),
          ),
        ),

        // ---------- Gradient Overlay ----------
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),
        ),

        // ---------- Close (X) Button ----------
        Positioned(
          top: 40,
          right: 20,
          child: GestureDetector(
            onTap: () {
              context.push('/sign-in');
            },
            child: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ),

        // ---------- TEXT + NEXT BUTTON ----------
        Positioned(
          left: 25,
          right: 25,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: poppinsSemiBold.copyWith(
                  fontSize: 28,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: poppinsRegular.copyWith(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    if (_pageController.page == onboardingImages.length - 1) {
                      context.push('/sign-in');
                      //context.push('/identity-verified');
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  },
                  child: Container(
                    width: 158,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppColors.light.grey9,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Next",
                      style: poppinsMedium.copyWith(
                        fontSize: 16,
                        color: AppTheme.of(context).primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: PageView(
            controller: _pageController,
            children: [
              _buildOnboardingPage(
                title: 'The best app for manage your taxation',
                subtitle:
                    'Committed to accuracy and progress guiding every taxpayer toward confident, compliant growth.',
                imagePath: onboardingImages[0],
              ),
              _buildOnboardingPage(
                title: 'Smart Filing That Protects Your Hard-Earned Money',
                subtitle:
                    'File with confidence knowing every deduction is maximized and your return stays fully compliant.',
                imagePath: onboardingImages[1],
              ),
              _buildOnboardingPage(
                title: 'Simple and easy\nto control your\ntaxation',
                subtitle:
                    'Always moving forward with smart, simple, and secure tax solutions making filing easy and stress-free.',
                imagePath: onboardingImages[2],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
