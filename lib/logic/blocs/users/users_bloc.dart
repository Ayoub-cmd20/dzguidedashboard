import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc() : super(UsersInitial()) {
    on<LoadUsers>((event, emit) async {
      emit(UsersLoading());
      try {
        await Future.delayed(const Duration(milliseconds: 800));
        final mockUsers = [
          {
            'id': 'u1',
            'name': 'Zinedine Zidane',
            'email': 'zizou@algeria.dz',
            'tier': 'Platinum',
            'points': 25000,
            'joined': 'Jan 2023',
            'avatar': 'https://ui-avatars.com/api/?name=Zinedine+Zidane&background=006633&color=fff',
          },
          {
            'id': 'u2',
            'name': 'Riyad Mahrez',
            'email': 'riyad.m@algeria.dz',
            'tier': 'Gold',
            'points': 12400,
            'joined': 'Mar 2023',
            'avatar': 'https://ui-avatars.com/api/?name=Riyad+Mahrez&background=7317cf&color=fff',
          },
          {
            'id': 'u3',
            'name': 'Sofia Boutella',
            'email': 'sofia.b@algeria.dz',
            'tier': 'Silver',
            'points': 5200,
            'joined': 'June 2023',
            'avatar': 'https://ui-avatars.com/api/?name=Sofia+Boutella&background=D21034&color=fff',
          },
        ];
        emit(UsersLoaded(mockUsers));
      } catch (e) {
        emit(UsersError('Failed to load users'));
      }
    });

    on<UpdateUserTier>((event, emit) {
      if (state is UsersLoaded) {
        final currentUsers = (state as UsersLoaded).users;
        final updatedUsers = currentUsers.map((u) {
          if (u['id'] == event.userId) {
            return {...u, 'tier': event.tier};
          }
          return u;
        }).toList();
        emit(UsersLoaded(updatedUsers));
      }
    });
  }
}
