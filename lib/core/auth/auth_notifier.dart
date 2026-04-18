import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../services/supabase_service.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _bind();
  }

  Stream<AuthState>? _authStream;
  late final StreamSubscription<AuthState>? _sub;
  bool _mockLoggedIn = false;

  bool get isLoggedIn {
    if (!SupabaseService.isInitialized) return _mockLoggedIn;
    return SupabaseService.client.auth.currentSession != null;
  }

  void setMockLoggedIn(bool value) {
    if (SupabaseService.isInitialized) return;
    if (_mockLoggedIn == value) return;
    _mockLoggedIn = value;
    notifyListeners();
  }

  void _bind() {
    if (!SupabaseService.isInitialized) {
      _sub = null;
      return;
    }

    _authStream = SupabaseService.client.auth.onAuthStateChange;
    _sub = _authStream!.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

