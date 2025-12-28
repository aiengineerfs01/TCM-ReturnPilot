import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// A wrapper widget that handles system back button safely.
/// Prevents black screen when there's no route to pop.
/// 
/// Usage:
/// ```dart
/// SafePopScope(
///   child: Scaffold(...),
/// )
/// ```
/// 
/// Or with custom back action:
/// ```dart
/// SafePopScope(
///   onBack: () => showExitDialog(),
///   child: Scaffold(...),
/// )
/// ```
class SafePopScope extends StatelessWidget {
  final Widget child;
  
  /// Custom back action. If null, uses safe pop behavior.
  /// Return `true` to allow pop, `false` to prevent it.
  final Future<bool> Function()? onBack;
  
  /// If true, allows exiting the app when at root. Default: false.
  final bool allowAppExit;

  const SafePopScope({
    super.key,
    required this.child,
    this.onBack,
    this.allowAppExit = false,
  });

  Future<bool> _handlePop() async {
    if (onBack != null) {
      return await onBack!();
    }

    // Check if we can pop
    final canPop = Get.key?.currentState?.canPop() ?? false;
    
    if (canPop) {
      Get.back();
      return false; // We handled it manually
    }
    
    // No route to pop
    if (allowAppExit) {
      return true; // Allow system to exit app
    }
    
    // Don't allow pop (prevents black screen)
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // We handle it manually
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await _handlePop();
        if (shouldPop && context.mounted) {
          // Allow system back (exit app)
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}

/// Extension for easy access to safe pop functionality
extension SafeNavigator on GetInterface {
  /// Safely pops the current route. Does nothing if no route to pop.
  void safeBack() {
    if (Get.key?.currentState?.canPop() ?? false) {
      Get.back();
    }
  }
  
  /// Returns true if there's a route that can be popped
  bool get canGoBack => Get.key?.currentState?.canPop() ?? false;
}
