import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SafePopScope extends StatelessWidget {
  final Widget child;
  final Future<bool> Function()? onBack;
  final bool allowAppExit;

  const SafePopScope({
    super.key,
    required this.child,
    this.onBack,
    this.allowAppExit = false,
  });

  Future<bool> _handlePop(BuildContext context) async {
    if (onBack != null) {
      return await onBack!();
    }
    final canPop = Navigator.canPop(context);
    if (canPop) {
      Navigator.pop(context);
      return false;
    }
    if (allowAppExit) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handlePop(context);
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
