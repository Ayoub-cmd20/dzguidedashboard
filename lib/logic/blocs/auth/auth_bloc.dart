import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/services/appwrite_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AppwriteService _appwrite = AppwriteService();

  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _appwrite.account.get();
        emit(Authenticated(user));
      } catch (e) {
        emit(Unauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _appwrite.account.createEmailPasswordSession(
          email: event.email,
          password: event.password,
        );
        final user = await _appwrite.account.get();
        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError('Login failed: ${e.toString()}'));
        emit(Unauthenticated());
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _appwrite.account.deleteSession(sessionId: 'current');
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError('Logout failed: ${e.toString()}'));
      }
    });
  }
}
