import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

class BackArrow extends StatefulWidget {
  final VoidCallback? onTap;
  const BackArrow({super.key, this.onTap});

  @override
  State<BackArrow> createState() => _BackArrowState();
}

class _BackArrowState extends State<BackArrow> {
  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap:
          widget.onTap ??
          () async {
            Navigator.pop(context);
          },
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
