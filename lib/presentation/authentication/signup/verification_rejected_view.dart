import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup/verify_identity_screen.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/safe_pop_scope.dart';
import 'package:tcm_return_pilot/widgets/solvquest_logo.dart';

class VerificationRejectedScreen extends StatefulWidget {
  const VerificationRejectedScreen({super.key});

  static const String routeName = 'VerificationRejectedScreen';
  static const String routePath = '/verification-rejected';

  @override
  State<VerificationRejectedScreen> createState() =>
      _VerificationRejectedScreenState();
}

class _VerificationRejectedScreenState
    extends State<VerificationRejectedScreen> {
  final AuthController _authController = Get.find<AuthController>();
  String? _rejectionReason;
  bool _isLoadingReason = true;

  @override
  void initState() {
    super.initState();
    _loadRejectionReason();
  }

  Future<void> _loadRejectionReason() async {
    final status = await _authController.getVerificationStatus();
    setState(() {
      _rejectionReason = status?.rejectionReason;
      _isLoadingReason = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return SafePopScope(
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Rejection Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: theme.error,
                  ),
                ),

                const SizedBox(height: 35),

                // Title
                Text(
                  'Verification Rejected',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 26,
                    color: theme.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                "Unfortunately, we couldn't verify your identity.\nPlease review the reason below and try again.",
                style: poppinsRegular.copyWith(
                  fontSize: 15,
                  color: theme.black1,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Rejection Reason Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: theme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reason for Rejection',
                          style: poppinsSemiBold.copyWith(
                            fontSize: 14,
                            color: theme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _isLoadingReason
                        ? const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Text(
                            _rejectionReason ??
                                'The documents provided could not be verified. Please ensure all images are clear and match the requirements.',
                            style: poppinsRegular.copyWith(
                              fontSize: 14,
                              color: theme.primaryText,
                              height: 1.5,
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // Retry Verification Button
              Obx(
                () => PrimaryButton(
                  title: 'Retry Verification',
                  isLoading: _authController.isLoading,
                  onTap: () {
                    Get.offAllNamed(VerifyIdentityScreen.routePath);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Logout Button
              TextButton(
                onPressed: () => _authController.logout(),
                child: Text(
                  'Log out',
                  style: poppinsMedium.copyWith(
                    color: theme.primaryText,
                    fontSize: 14,
                  ),
                ),
              ),

              const Spacer(),

              // Solvquest Logo
              const Center(child: SolvquestLogo(height: 45)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
