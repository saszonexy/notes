import 'package:equatable/equatable.dart';
import '../domain/user_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final AppUser user;
  Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
