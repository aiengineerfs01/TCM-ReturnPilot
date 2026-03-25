/// A centralized class for accessing compile-time environment variables.
/// These values are provided using --dart-define when you build or run the app.
class EnvironmentService {
  /// The base API URL of your backend.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.default.com',
  );

  /// Supabase Project URL
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase Anon Key
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// The current environment name (e.g., development, staging, production).
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  /// Open AI API Key
  static const String openAIApiKey = String.fromEnvironment('OPENAI_API_KEY');

  /// Open AI Assistent ID
  static const String openAIAssistantId = String.fromEnvironment('ASSISTANT_ID');

  /// Optional helper to check environment type.
  static bool get isProduction => appEnv.toLowerCase() == 'production';
  static bool get isDevelopment => appEnv.toLowerCase() == 'development';
  static bool get isStaging => appEnv.toLowerCase() == 'staging';
}
