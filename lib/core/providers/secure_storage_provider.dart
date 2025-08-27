import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';

/// Provider pour le service de stockage sécurisé
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.instance;
});

/// Provider pour vérifier si l'utilisateur est authentifié
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final token = await storage.getAuthToken();
  return token != null && token.isNotEmpty;
});

/// Provider pour récupérer le token d'authentification
final authTokenProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return storage.getAuthToken();
});

/// Provider pour récupérer la session utilisateur
final userSessionProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return storage.getUserSession();
});

/// Provider pour vérifier si la biométrie est activée
final isBiometricEnabledProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return storage.isBiometricEnabled();
});

/// Provider pour récupérer les données de la dernière session
final lastSessionDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return storage.getLastSessionData();
});

/// Notifier pour gérer l'état d'authentification
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final SecureStorageService _storage;
  
  AuthNotifier(this._storage) : super(const AsyncValue.loading()) {
    _loadAuthState();
  }
  
  Future<void> _loadAuthState() async {
    try {
      final token = await _storage.getAuthToken();
      final session = await _storage.getUserSession();
      
      if (token != null && session != null) {
        state = AsyncValue.data(
          AuthState.authenticated(
            token: token,
            userId: session['user_id'] as String?,
            userEmail: session['user_email'] as String?,
          ),
        );
      } else {
        state = const AsyncValue.data(AuthState.unauthenticated());
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> login({
    required String token,
    required String userId,
    String? email,
    String? refreshToken,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // Sauvegarder les tokens
      await _storage.saveAuthTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );
      
      // Sauvegarder la session
      await _storage.saveUserSession({
        'user_id': userId,
        'user_email': email,
        'login_time': DateTime.now().toIso8601String(),
      });
      
      state = AsyncValue.data(
        AuthState.authenticated(
          token: token,
          userId: userId,
          userEmail: email,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> logout() async {
    state = const AsyncValue.loading();
    
    try {
      await _storage.clearAuthData();
      state = const AsyncValue.data(AuthState.unauthenticated());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        await logout();
        return;
      }
      
      // TODO: Implémenter l'appel API pour rafraîchir le token
      // final newTokens = await _apiService.refreshToken(refreshToken);
      // await _storage.saveAuthTokens(...)
      
    } catch (e) {
      await logout();
    }
  }
}

/// État d'authentification
class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? userId;
  final String? userEmail;
  
  const AuthState({
    required this.isAuthenticated,
    this.token,
    this.userId,
    this.userEmail,
  });
  
  const AuthState.authenticated({
    required String this.token,
    this.userId,
    this.userEmail,
  }) : isAuthenticated = true;
  
  const AuthState.unauthenticated()
      : isAuthenticated = false,
        token = null,
        userId = null,
        userEmail = null;
}

/// Provider pour l'état d'authentification
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage);
});

/// Provider helper pour vérifier rapidement l'authentification
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(
    data: (state) => state.isAuthenticated,
    orElse: () => false,
  );
});

/// Provider pour récupérer l'ID utilisateur courant
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(
    data: (state) => state.userId,
    orElse: () => null,
  );
});