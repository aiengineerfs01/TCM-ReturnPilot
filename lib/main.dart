import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tcm_return_pilot/base/app_view.dart';
import 'package:tcm_return_pilot/services/environment_service.dart';
import 'package:tcm_return_pilot/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Preference.init();

  // initializing Supabase
  await Supabase.initialize(
    url: EnvironmentService.supabaseUrl,
    anonKey: EnvironmentService.supabaseAnonKey,
  );

  runApp(const AppView());
}
