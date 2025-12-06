import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tcm_return_pilot/constants/app_colors.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final String? initialValue;
  final TextStyle? hintStyle;
  final TextStyle? inputTextStyle;
  final IconData? suffixIcon;
  final Widget? prefixIcon;
  final Function? onPrefixIconPressed;
  final Function? onSuffixIconPressed;
  final bool isPassword;
  final bool readOnly;
  final Color? fillColor;
  final int maxLines;
  final bool showErrorMessage;
  final String suffixText;
  final Function()? onTap;
  final TextInputType keyBoardType;
  final Function(String?)? validator;
  final double verticalMargin;
  final double horizontalMargin;
  final EdgeInsets? contentPadding;
  final Color? outlineColor;
  final Color? focusBorderColor;
  final Color? hintColor;
  final TextAlign textAlign;
  final double radius;
  final bool isSuffixIcon;
  final Widget? prefix;
  final Function(String)? onChanged;
  final Function(String)? onSubmit;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final bool isEnable;

  const CustomTextField({
    super.key,
    this.hintText,
    this.initialValue,
    this.isEnable = true,
    this.isSuffixIcon = false,
    this.hintStyle,
    this.inputTextStyle,
    this.suffixIcon,
    this.prefixIcon,
    this.onSuffixIconPressed,
    this.onPrefixIconPressed,
    this.outlineColor,
    this.textAlign = TextAlign.start,
    this.isPassword = false,
    this.readOnly = false,
    this.showErrorMessage = true,
    this.horizontalMargin = 0,
    this.verticalMargin = 0,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 15,
    ),
    this.suffixText = '',
    this.validator,
    this.onTap,
    this.prefix,
    this.maxLines = 1,
    this.radius = 25,
    this.keyBoardType = TextInputType.text,
    this.inputFormatters = const [],
    this.textInputAction = TextInputAction.next,
    this.fillColor,
    this.focusBorderColor,
    this.hintColor,
    this.controller,
    this.onSubmit,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        vertical: verticalMargin,
        horizontal: horizontalMargin,
      ),
      child: TextFormField(
        initialValue: initialValue,
        enabled: isEnable,
        keyboardType: keyBoardType,
        obscuringCharacter: '•',
        validator: (value) => validator?.call(value),
        scrollPhysics: const BouncingScrollPhysics(),
        style: inputTextStyle ?? poppinsRegular,
        obscureText: isPassword,
        onChanged: onChanged,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        textInputAction: textInputAction,
        textAlign: textAlign,
        controller: controller,
        onFieldSubmitted: onSubmit,
        decoration: InputDecoration(
          //hintText: hintText,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: outlineColor ?? Colors.transparent),
          ),
          hintText: hintText,
          errorStyle: !showErrorMessage ? const TextStyle(height: 0) : null,
          hintStyle:
              hintStyle ??
              poppinsRegular.copyWith(
                color: hintColor ?? Colors.grey.shade500,
                fontSize: 16,
              ),
          suffixText: suffixText,
          contentPadding: contentPadding,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 20,
            minHeight: 20,
          ),
          suffixIcon: isSuffixIcon
              ? IconButton(
                  onPressed: () {
                    if (onSuffixIconPressed != null) onSuffixIconPressed!();
                  },
                  icon: Icon(suffixIcon, size: 20),
                )
              : null,
          prefixIcon: prefixIcon,
          filled: true,
          isDense: true,
          fillColor: fillColor ?? AppTheme.of(context).primaryBackground,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Colors.red),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: outlineColor ?? AppColors.grey3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: focusBorderColor ?? AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
