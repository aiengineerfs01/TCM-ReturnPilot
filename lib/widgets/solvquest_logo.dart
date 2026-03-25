import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/strings.dart';

class SolvquestLogo extends StatelessWidget {
  final bool isBlue;
  final double height;
  const SolvquestLogo({super.key, this.isBlue = false, this.height = 60});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      height: height,
      isBlue || isDark ? Strings.solvquestTaxLogo : Strings.solvquestBlue,
      fit: BoxFit.cover,
    );
  }
}
