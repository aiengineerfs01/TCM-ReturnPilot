import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

class BackArrow extends StatelessWidget {
  final VoidCallback? onTap;
  const BackArrow({super.key, this.onTap});

  /// Safely pops the current route. If no route to pop, does nothing.
  static void safePop([BuildContext? context]) {
    if (Get.key?.currentState?.canPop() ?? false) {
      Get.back();
    } else if (context != null && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    // If nothing to pop, do nothing (prevents black screen)
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
