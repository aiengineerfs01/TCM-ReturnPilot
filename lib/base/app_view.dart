import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/domain/theme/theme_cubit.dart';
import 'package:tcm_return_pilot/presentation/authentication/cubit/auth_cubit.dart';
import 'package:tcm_return_pilot/presentation/main/cubit/main_nav_cubit.dart';
import 'package:tcm_return_pilot/presentation/interview/cubit/interview_welcome_cubit.dart';
import 'package:tcm_return_pilot/router/app_router.dart';
import 'package:tcm_return_pilot/utils/snackbar.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final AuthCubit _authCubit;
  late final ThemeCubit _themeCubit;
  late final GoRouter _router;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit();
    _themeCubit = ThemeCubit();
    _router = AppRouter.router(_authCubit);

    // Handle deep link when app is already running
    // _appLinks.uriLinkStream.listen((Uri? uri) {
    //   if (uri != null) _handleDeepLink(uri);
    // });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'returnpilot-app' && uri.path == '/email/verify') {
      _router.go('/email/verify');
    }
  }

  @override
  void dispose() {
    _authCubit.close();
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
        BlocProvider<MainNavCubit>(create: (_) => MainNavCubit()),
        BlocProvider<InterviewWelcomeCubit>(create: (_) => InterviewWelcomeCubit()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) => current.navigationRoute != null,
        listener: (context, state) {
          if (state.navigationRoute != null) {
            _router.go(state.navigationRoute!);
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              title: Strings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.flutterThemeMode,
              routerConfig: _router,
              scaffoldMessengerKey: SnackbarHelper.messengerKey,
            );
          },
        ),
      ),
    );
  }
}
