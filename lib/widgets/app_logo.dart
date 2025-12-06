import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final Color? color;
  final double? width;
  const AppLogo({super.key, this.color, this.width = 330});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.asset(
              Strings.appLogo,
              width: 300,
              fit: BoxFit.cover,
              color: color,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 45, 50),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color ?? AppTheme.of(context).secondaryBackground,
                ),
              ),
              alignment: AlignmentDirectional(0, 0),
              child: Align(
                alignment: AlignmentDirectional(0, 0),
                child: Text(
                  'TM',
                  style: AppTheme.of(context).bodyLarge.override(
                    fontFamily: AppTheme.of(context).bodyLargeFamily,
                    color: color ?? AppTheme.of(context).secondaryBackground,
                    fontSize: 8,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
