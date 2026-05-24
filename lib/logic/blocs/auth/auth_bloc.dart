import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/models.dart' as models;
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

      // Simulation for development/admin credentials
      if (event.email == 'admin@dzguide.com' && event.password == 'admin123') {
        await Future.delayed(const Duration(seconds: 1));
        final Map<String, dynamic> adminData = {
          '\$id': 'admin_id',
          '\$createdAt': DateTime.now().toIso8601String(),
          '\$updatedAt': DateTime.now().toIso8601String(),
          'name': 'Super Admin',
          'registration': DateTime.now().toIso8601String(),
          'status': true,
          'labels': ['admin'],
          'passwordUpdate': DateTime.now().toIso8601String(),
          'email': 'admin@dzguide.com',
          'phone': '',
          'emailVerification': true,
          'phoneVerification': true,
          'mfa': false,
          'prefs': <String, dynamic>{},
          'accessedAt': DateTime.now().toIso8601String(),
          'targets': <dynamic>[],
        };
        final mockUser = models.User.fromMap(adminData);
        emit(Authenticated(mockUser));
        return;
      }

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
