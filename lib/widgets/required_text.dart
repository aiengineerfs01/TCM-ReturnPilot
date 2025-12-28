import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

class RequiredText extends StatelessWidget {
  final String text;
  const RequiredText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return RichText(
      text: TextSpan(
        text: text,
        style: poppinsMedium.copyWith(color: theme.appSecondary, fontSize: 14),
        children: [
          TextSpan(
            text: ' *',
            style: poppinsMedium.copyWith(color: Colors.red, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
