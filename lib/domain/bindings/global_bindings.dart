import 'package:get/get.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true, // <-- ensures recreated if disposed
    );
  }
}
