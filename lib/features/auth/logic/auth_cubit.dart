// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'auth_state.dart';
import '../data/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthLoading()) {
    _authService.user.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
        _saveFcmToken(user.uid); 
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
        await _saveFcmToken(user.uid); 
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
        await _saveFcmToken(user.uid); 
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

  Future<void> _saveFcmToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {'fcmToken': token},
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      print("Gagal menyimpan FCM token: $e");
    }
  }
}
