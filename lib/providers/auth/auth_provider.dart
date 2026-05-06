import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_model.dart';

final authServiceProvider = Provider((ref) => AuthService());

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  AuthState({this.user, this.isLoading = false, this.error, this.isInitialized = false});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error, bool? isInitialized}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._service) : super(AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      try {
        final user = await _service.getMe();
        state = state.copyWith(user: user, isInitialized: true);
      } catch (e) {
        await logout();
        state = state.copyWith(isInitialized: true);
      }
    } else {
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _service.login(username, password);
      state = state.copyWith(user: user, isLoading: false, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Đăng nhập thất bại. Vui lòng kiểm tra lại.");
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWith(isLoading: false, error: "Không lấy được Token từ Google");
        return false;
      }

      final user = await _service.googleLogin(idToken);
      state = state.copyWith(user: user, isLoading: false, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Đăng nhập Google thất bại.");
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = AuthState(isInitialized: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
