import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_colors.dart';
import 'package:tcm_return_pilot/presentation/authentication/cubit/auth_cubit.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/services/storage_service.dart';
import 'package:tcm_return_pilot/utils/validators.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/custom_text_field.dart';
import 'package:tcm_return_pilot/widgets/solvquest_logo.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String routeName = 'SignInScreen';
  static const String routePath = '/signInScreen';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  void _loadRememberedEmail() {
    final savedEmail = Preference.rememberedEmail;
    if (savedEmail.isNotEmpty) {
      _emailController.text = savedEmail;
      _rememberMe = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.of(context).primaryBackground,
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
          return Stack(
            children: [
              // Top blue curved background
              ClipPath(
                clipper: _BottomCurveClipper(),
                child: Container(
                  height: size.height * 0.73,
                  width: size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.light.darkBlue,
                        AppTheme.of(context).primary,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),

                        /// Back Arrow
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(Strings.arrowBack, height: 10),
                            Image.asset(Strings.appLogo2, width: 200),
                            Image.asset(
                              Strings.arrowBack,
                              height: 10,
                              color: Colors.transparent,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        /// Welcome text
                        Text(
                          'Welcome Back,',
                          style: poppinsSemiBold.copyWith(
                            fontSize: 26,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to continue!',
                          style: poppinsMedium.copyWith(
                            fontSize: 16,
                            color: AppTheme.of(context).grey2,
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// Email
                        Text(
                          'Email Address',
                          style: poppinsMedium.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: 'Enter your email address',
                          controller: _emailController,
                          focusBorderColor: Colors.white,
                          inputTextStyle: poppinsRegular.copyWith(
                            color: Colors.white,
                          ),
                          validator: Validator.emailValidator,
                        ),

                        const SizedBox(height: 20),

                        /// Password
                        Text(
                          'Password',
                          style: poppinsMedium.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: 'Enter your password',
                          focusBorderColor: Colors.white,
                          suffixIcon: _passwordVisible
                              ? Icons.visibility_off
                              : Icons.remove_red_eye,
                          isSuffixIcon: true,
                          isPassword: !_passwordVisible,
                          onSuffixIconPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          controller: _passwordController,
                          inputTextStyle: poppinsRegular.copyWith(
                            color: Colors.white,
                          ),
                          validator: Validator.passwordValidator,
                        ),

                        const SizedBox(height: 16),

                        /// Remember + Forgot
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Transform.scale(
                                scale: 0.8,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me?',
                              style: poppinsRegular.copyWith(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => context.push('/forgot-password'),
                              child: Text(
                                'Forget Password?',
                                style: poppinsRegular.copyWith(
                                  color: AppTheme.of(context).appGreen,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Spacer(),

                        /// Bottom white area content (button + text + logo)
                        // We add extra spacing so content visually sits
                        // in the white area created by the curve.
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /// Sign In button
                            SizedBox(
                              width: double.infinity,
                              child: PrimaryButton(
                                title: 'Sign In',
                                isLoading: state.isLoading,
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final email = _emailController.text.trim();
                                    // Save or clear remembered email
                                    if (_rememberMe) {
                                      await Preference.setRememberedEmail(
                                        email,
                                      );
                                    } else {
                                      await Preference.clearRememberedEmail();
                                    }
                                    await context.read<AuthCubit>().login(
                                      email,
                                      _passwordController.text.trim(),
                                    );
                                  }
                                },
                              ),
                            ),

                            const SizedBox(height: 9),

                            /// Sign up text
                            RichText(
                              text: TextSpan(
                                style: poppinsRegular.copyWith(fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: "Don’t have an account? ",
                                    style: poppinsRegular.copyWith(
                                      color: theme.black1,
                                      fontSize: 15,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Sign up",
                                    style: poppinsMedium.copyWith(
                                      color: AppTheme.of(context).appGreen,
                                      fontSize: 15.5,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => context.push('/sign-up'),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            SolvquestLogo(height: 45),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Custom clipper to match the big curve at the bottom of the blue area
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start at top-left
    path.lineTo(0, 0);

    // Go down left edge
    path.lineTo(0, size.height * 1.0);

    // Big convex arc from left to right
    //final controlPoint = Offset(size.width * 0.5, size.height * 0.98);
    final controlPoint = Offset(size.width * 0.5, size.height * 0.98);
    final endPoint = Offset(size.width, size.height * 0.82);

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // Up right edge to top-right
    path.lineTo(size.width, 0);

    // Close back to start
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
