import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/strings.dart';

class AppLogo extends StatelessWidget {
  final Color? color;
  final double? width;
  final double? height;

  const AppLogo({super.key, this.color, this.width = 100, this.height = 50});

  @override
  Widget build(BuildContext context) {
    return Image.asset(Strings.appLogo2, width: width, height: height);
  }
}
