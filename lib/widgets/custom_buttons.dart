import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/app_colors.dart';
import 'package:tcm_return_pilot/constants/typography.dart';

class PrimaryButton extends StatelessWidget {
  final String? title;
  final Color bgColor;
  final Color textColor;
  final TextStyle? textStyle;
  final Color disabledColor;
  final Color disabledTextColor;
  final Color borderColor;
  final Function()? onTap;
  final Widget? child;
  final double width;
  final double height;
  final double borderRadius;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    this.title,
    this.textStyle,
    this.bgColor = AppColors.primaryColor,
    this.textColor = AppColors.primaryBackground,
    this.disabledColor = AppColors.lightGrey,
    this.disabledTextColor = AppColors.primaryColor,
    this.borderColor = Colors.transparent,
    required this.onTap,
    this.child,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 5,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: height,
      minWidth: width,
      color: bgColor,
      disabledColor: disabledColor,
      elevation: 0,
      disabledTextColor: disabledTextColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: borderColor),
      ),
      onPressed: isLoading ? null : onTap,
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : child ??
              Text(
                title ?? '',
                style:
                    textStyle ??
                    poppinsMedium.copyWith(color: textColor, fontSize: 14),
              ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final Widget child;
  final Color bgColor;
  final Color textColor;
  final Function()? onTap;
  final double width;
  final double borderRadius;
  final Color disabledColor;
  final Color borderColor;
  final Color disabledTextColor;

  const SecondaryButton({
    super.key,
    required this.child,
    this.bgColor = AppColors.primaryColor,
    this.textColor = AppColors.primaryBackground,
    this.borderColor = AppColors.primaryColor,
    this.onTap,
    this.width = double.infinity,
    this.borderRadius = 5,
    this.disabledColor = AppColors.lightGrey,
    this.disabledTextColor = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 48,
      minWidth: width,
      color: bgColor,
      elevation: 0,
      disabledColor: disabledColor,
      disabledTextColor: disabledTextColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: borderColor),
      ),
      onPressed: onTap,
      child: child,
    );
  }
}

class UnderlineTextButton extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final Color? color;

  const UnderlineTextButton({
    super.key,
    this.onTap,
    required this.title,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: poppinsRegular.copyWith(
          fontSize: 14,
          decoration: TextDecoration.underline,
          decorationColor: color ?? Colors.white,
          color: color,
        ),
      ),
    );
  }
}
