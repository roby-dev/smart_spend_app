/// Central configuration for backend connectivity and Google Sign-In.
///
/// Fill these two values before running the cloud backup feature:
///
/// 1. [backendBaseUrl] — the public Railway URL of the NestJS backend,
///    without a trailing slash. Example: https://smart-spend-api.up.railway.app
///
/// 2. [googleServerClientId] — the **Web** OAuth 2.0 client ID from Google
///    Cloud Console. It MUST match the backend's GOOGLE_CLIENT_ID, because the
///    backend verifies the idToken audience against that exact value.
class AppEnv {
  AppEnv._();

  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://smartspendapp-production.up.railway.app',
  );

  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '570866028708-p5fmtno9qm4abubg7rg8k7sn4bsu41hf.apps.googleusercontent.com',
  );
}
