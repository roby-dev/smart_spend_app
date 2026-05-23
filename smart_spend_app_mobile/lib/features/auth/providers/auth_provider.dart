import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_spend_app/config/env/app_env.dart';
import 'package:smart_spend_app/features/auth/data/auth_remote_datasource.dart';
import 'package:smart_spend_app/features/auth/data/token_storage.dart';
import 'package:smart_spend_app/features/auth/domain/user_profile.dart';

enum AuthStatus { signedOut, signingIn, signedIn, error }

class AuthState {
  final AuthStatus status;
  final String? error;
  final UserProfile? profile;

  const AuthState({
    this.status = AuthStatus.signedOut,
    this.error,
    this.profile,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    UserProfile? profile,
  }) => AuthState(
    status: status ?? this.status,
    error: error,
    profile: profile ?? this.profile,
  );
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

class AuthNotifier extends Notifier<AuthState> {
  static bool _googleInitialized = false;

  late final AuthRemoteDatasource _remote;
  late final TokenStorage _storage;

  @override
  AuthState build() {
    _remote = ref.watch(authRemoteDatasourceProvider);
    _storage = ref.watch(tokenStorageProvider);
    _restore();
    return const AuthState();
  }

  /// Restores a persisted session (tokens + profile) on startup.
  Future<void> _restore() async {
    if (await _storage.read() == null) return;
    final profile = await _storage.readProfile();
    state = state.copyWith(status: AuthStatus.signedIn, profile: profile);
  }

  Future<bool> hasSession() async {
    return (await _storage.read()) != null;
  }

  /// Ensures there is a valid session, triggering Google Sign-In if needed.
  /// Returns true when authenticated.
  Future<bool> ensureAuthenticated() async {
    if (await hasSession()) {
      state = state.copyWith(status: AuthStatus.signedIn);
      return true;
    }
    return signInWithGoogle();
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.signingIn, error: null);
    try {
      final signIn = GoogleSignIn.instance;
      if (!_googleInitialized) {
        await signIn.initialize(serverClientId: AppEnv.googleServerClientId);
        _googleInitialized = true;
      }

      final account = await signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        state = state.copyWith(status: AuthStatus.error, error: 'No idToken');
        return false;
      }

      final tokens = await _remote.loginWithGoogle(idToken);
      await _storage.save(tokens);

      final profile = UserProfile(
        name: account.displayName,
        email: account.email,
        photoUrl: account.photoUrl,
      );
      await _storage.saveProfile(profile);

      state = state.copyWith(status: AuthStatus.signedIn, profile: profile);
      return true;
    } on GoogleSignInException catch (e) {
      final canceled = e.code == GoogleSignInExceptionCode.canceled;
      state = state.copyWith(
        status: canceled ? AuthStatus.signedOut : AuthStatus.error,
        error: canceled ? null : e.description,
      );
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      final tokens = await _storage.read();
      if (tokens != null) {
        await _remote.logout(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );
      }
    } catch (_) {
      // Ignore network errors on logout — clear locally regardless.
    }
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _storage.clear();
    state = const AuthState(status: AuthStatus.signedOut);
  }
}
