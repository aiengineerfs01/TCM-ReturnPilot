import 'package:get/get.dart';
import 'package:tcm_return_pilot/domain/theme/theme_controller.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    // Theme controller - must be initialized first for theme to work
    Get.put<ThemeController>(ThemeController(), permanent: true);
    
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true, // <-- ensures recreated if disposed
    );
  }
}
