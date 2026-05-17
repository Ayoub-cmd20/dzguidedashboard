import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/services/appwrite_service.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final AppwriteService _appwrite = AppwriteService();
  static const String usersCollectionId = 'users';

  UsersBloc() : super(UsersInitial()) {
    on<LoadUsers>((event, emit) async {
      emit(UsersLoading());
      try {
        final response = await _appwrite.databases.listDocuments(
          databaseId: AppwriteService.databaseId,
          collectionId: usersCollectionId,
          queries: [Query.orderDesc('\$createdAt')],
        );

        final users = response.documents.map((doc) {
          return {
            'id': doc.$id,
            'name': doc.data['name'],
            'email': doc.data['email'],
            'tier': doc.data['tier'],
            'points': doc.data['points'],
            'joined': doc.$createdAt,
            'avatar': doc.data['avatarUrl'] ?? 'https://ui-avatars.com/api/?name=${doc.data['name']}&background=random',
          };
        }).toList();

        emit(UsersLoaded(users));
      } catch (e) {
        emit(UsersError('Failed to load users: ${e.toString()}'));
      }
    });

    on<UpdateUserTier>((event, emit) async {
      try {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: usersCollectionId,
          documentId: event.userId,
          data: {'tier': event.tier},
        );
        add(LoadUsers());
      } catch (e) {
        emit(UsersError('Failed to update tier: ${e.toString()}'));
      }
    });
  }
}
