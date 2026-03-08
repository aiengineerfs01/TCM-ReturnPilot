import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

class BackArrow extends StatelessWidget {
  final VoidCallback? onTap;
  const BackArrow({super.key, this.onTap});

  static void safePop([BuildContext? context]) {
    if (context != null && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap ?? () => safePop(context),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.of(context).borderColor),
        ),
        child: Icon(
          Icons.arrow_back_ios_outlined,
          color: AppTheme.of(context).primaryText,
          size: 22,
        ),
      ),
    );
  }
}
