import 'package:flutter/material.dart';

void showAppDialog(BuildContext context, Widget child) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 12,
        backgroundColor: Colors.white,
        child: child,
      );
    },
  );
}
