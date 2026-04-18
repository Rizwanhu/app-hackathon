import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc({required AuthRepository repo})
      : _repo = repo,
        super(const AuthInitial()) {
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSigningOut());
    await _repo.signOut();
    emit(const AuthSignedOut());
  }
}

