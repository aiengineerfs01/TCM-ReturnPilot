import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

class MainLogo extends StatelessWidget {
  final Color? color;
  final double? width;
  const MainLogo({super.key, this.color, this.width = 330});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 352,
        height: 352,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.of(context).primaryLight,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 35, left: 15, right: 15),
          child: Center(child: Image.asset(Strings.appLogo)),
        ),
      ),
    );
  }
}
