import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/domain/theme/pin_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/signin_screen.dart';
import 'package:tcm_return_pilot/presentation/mfa/widgets/enroll_mfa_guide_dialog.dart';
import 'package:tcm_return_pilot/services/auth_service.dart';
import 'package:tcm_return_pilot/services/supabase_service.dart';
import 'package:tcm_return_pilot/utils/dialogs.dart';
import 'package:tcm_return_pilot/widgets/custom_snackbar.dart';

class MFAEnrollPage extends StatefulWidget {
  //static const route = '/mfa/enroll';
  static const route = '/callback/mfa/enroll';
  const MFAEnrollPage({super.key});

  static const String routeName = 'MFAEnrollPage';
  static const String routePath = '/mfaEnrollPage';

  @override
  State<MFAEnrollPage> createState() => _MFAEnrollPageState();
}

class _MFAEnrollPageState extends State<MFAEnrollPage> {
  final _enrollFuture = SupabaseService.client.auth.mfa.enroll(
    issuer: Strings.appName,
  );
  final AuthService _authService = AuthService();
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      showAppDialog(context, EnrollMfaGuideDialog());
                    },
                    child: Icon(
                      Icons.info_outline,
                      size: 25,
                      color: AppTheme.of(context).accent3,
                    ),
                  ),
                  Text('Setup MFA', style: AppTheme.of(context).headlineSmall),
                  GestureDetector(
                    onTap: () async {
                      var result = await _authService.signOut();
                      if (result != null) {
                        AppSnackBar.show(
                          title: 'Error',
                          message: result.toString(),
                        );
                      }
                      if (context.mounted) {
                        Navigator.pushNamed(context, SignInScreen.routePath);
                      }
                    },
                    child: Icon(
                      Icons.logout,
                      size: 25,
                      color: AppTheme.of(context).error,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _enrollFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final response = snapshot.data!;
                  final qrCodeUrl = response.totp?.qrCode;
                  final secret = response.totp?.secret;
                  final factorId = response.id;

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    children: [
                      Text(
                        'Open your authentication app and add this app via QR code or by pasting the code below.',
                        style: AppTheme.of(context).labelMedium,
                      ),
                      const SizedBox(height: 16),
                      SvgPicture.string(
                        qrCodeUrl ?? '',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              secret ?? '',
                              style: AppTheme.of(context).titleMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: secret ?? ''),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to your clip board'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enter the code shown in your authentication app.',
                        style: AppTheme.of(context).labelMedium,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Pinput(
                          length: 6,
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          defaultPinTheme: AppPinThemes.defaultTheme(context),
                          focusedPinTheme: AppPinThemes.focusedTheme(context),
                          submittedPinTheme: AppPinThemes.submittedTheme(
                            context,
                          ),
                          onCompleted: (value) async {
                            await _authService.verifyMfa(
                              factorId: factorId,
                              code: value,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
