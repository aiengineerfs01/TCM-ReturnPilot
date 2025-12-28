import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/widgets/app_logo.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.only(top: 55, bottom: 5, left: 24, right: 24),
      width: double.infinity,
      color: theme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => BackArrow.safePop(),
            child: Image.asset(Strings.arrowBack, height: 10),
          ),
          const AppLogo(width: 200),
          Image.asset(Strings.arrowBack, height: 10, color: Colors.transparent),
        ],
      ),
    );
  }
}
