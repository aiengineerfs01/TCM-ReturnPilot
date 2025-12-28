import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

abstract class _Key {
  static const String accessToken = 'accessToken';
  static const String refreshAccessToken = 'refreshAccessToken';
  static const String appLanguage = 'appLanguage';
  static const String tcmThreadId = 'tcm_thread_id';
  static const String rememberedEmail = 'remembered_email';
  static Map<String, dynamic> defaultValues = {
    _Key.accessToken: '',
    _Key.refreshAccessToken: '',
    _Key.appLanguage: '',
    _Key.tcmThreadId: '',
  };
}

class Preference {
  static final Preference _preference = Preference._();

  factory Preference() => _preference;

  Preference._();

  static late final SharedPreferences _instance;
  static final String tokenInitialValue = _Key.defaultValues[_Key.accessToken];
  static final String refreshTokenInitialValue =
      _Key.defaultValues[_Key.refreshAccessToken];
  static final String appLanguageInitialValue =
      _Key.defaultValues[_Key.appLanguage];

  static const themeStatus = "THEMESTATUS";

  static bool get isTokenAvailable => accessToken.isNotEmpty;

  static Future<void> init() async {
    try {
      _instance = await SharedPreferences.getInstance();
    } catch (error) {
      log('Error: $error');
      rethrow;
    }
  }

  static String get accessToken {
    return _instance.getString(_Key.accessToken) ?? tokenInitialValue;
  }

  static Future setAccessToken(String accessToken) async {
    log('set Access accessToken: $accessToken');
    await _instance.setString(_Key.accessToken, accessToken);
  }

  static String get tcmThreadId {
    return _instance.getString(_Key.tcmThreadId) ?? '';
  }

  static Future setTcmThreadId(String id) async {
    await _instance.setString(_Key.tcmThreadId, id);
  }

  static String get refreshAccessToken {
    return _instance.getString(_Key.refreshAccessToken) ??
        refreshTokenInitialValue;
  }

  static Future setRefreshAccessToken(String refreshAccessToken) async {
    await _instance.setString(_Key.refreshAccessToken, refreshAccessToken);
  }

  static String get appLanguage {
    return _instance.getString(_Key.appLanguage) ?? appLanguageInitialValue;
  }

  static Future setAppLanguage(String appLanguage) async {
    await _instance.setString(_Key.appLanguage, appLanguage);
  }

  static Future setDarkTheme(bool value) async {
    _instance.setBool(themeStatus, value);
  }

  /// Dark Theme Preferences
  /// Boolean property here showing either dark mode enable or not
  static Future<bool> get getDarkTheme async {
    return _instance.getBool(themeStatus) ?? false;
  }

  // -------------------------
  // REMEMBER ME (email only)
  // -------------------------
  static String get rememberedEmail {
    return _instance.getString(_Key.rememberedEmail) ?? '';
  }

  static Future<void> setRememberedEmail(String email) async {
    await _instance.setString(_Key.rememberedEmail, email);
  }

  static Future<void> clearRememberedEmail() async {
    await _instance.remove(_Key.rememberedEmail);
  }

  /// Clears all preferences except remembered email (for logout)
  static Future<bool> clear() async {
    final email = rememberedEmail; // preserve
    final result = await _instance.clear();
    if (email.isNotEmpty) {
      await setRememberedEmail(email); // restore
    }
    return result;
  }
}
