import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthState, AuthChangeEvent;
import 'package:supabase_flutter/supabase_flutter.dart'
    as sb
    show AuthState, AuthChangeEvent;

import '../../../shared/models/profile.dart';
import 'app_auth_state.dart';

class AppAuthNotifier extends StateNotifier<AppAuthState> {
  AppAuthNotifier() : super(const AppAuthState.loading()) {
    _init();
  }

  StreamSubscription<sb.AuthState>? _sub;

  Future<void> _init() async {
    // Subscribe to ongoing auth changes first so no event is missed
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (event) => _handleAuthEvent(event),
    );

    // Bootstrap from existing session (avoids a full cold-start sign-in)
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      state = const AppAuthState.unauthenticated();
    } else {
      await _loadAndSetProfile(user.id);
    }
  }

  Future<void> _handleAuthEvent(sb.AuthState event) async {
    final user = event.session?.user;
    if (user == null) {
      state = const AppAuthState.unauthenticated();
    } else if (event.event == sb.AuthChangeEvent.signedIn ||
        event.event == sb.AuthChangeEvent.tokenRefreshed ||
        event.event == sb.AuthChangeEvent.userUpdated) {
      await _loadAndSetProfile(user.id);
    }
  }

  Future<void> _loadAndSetProfile(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      state = AppAuthState.authenticated(Profile.fromMap(data));
    } catch (_) {
      state = const AppAuthState.unauthenticated();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AppAuthState.loading();
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // State updated by stream listener after sign-in completes
    } on AuthException catch (e) {
      state = AppAuthState.unauthenticatedWithError(_mapAuthError(e.message));
    } catch (_) {
      state = AppAuthState.unauthenticatedWithError(
        'Errore di connessione. Riprova più tardi.',
      );
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    // Stream listener will update state to unauthenticated
  }

  String _mapAuthError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login') ||
        lower.contains('invalid credentials')) {
      return 'Email o password non corretti.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Conferma l\'indirizzo email prima di accedere.';
    }
    if (lower.contains('too many requests') || lower.contains('rate limit')) {
      return 'Troppi tentativi. Attendi qualche minuto.';
    }
    return 'Accesso non riuscito. Riprova.';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final appAuthProvider = StateNotifierProvider<AppAuthNotifier, AppAuthState>((
  ref,
) {
  return AppAuthNotifier();
});
