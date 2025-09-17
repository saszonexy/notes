import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../data/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthLoading()) {
    _authService.user.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> register(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await _authService.signUp(email, password);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError("Register gagal")); 
      }
    } catch (e) {
      emit(AuthError(e.toString())); 
    }
  }

  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await _authService.signIn(email, password);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError("Login gagal")); 
      }
    } catch (e) {
      emit(AuthError(e.toString())); 
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    emit(Unauthenticated());
  }
}
