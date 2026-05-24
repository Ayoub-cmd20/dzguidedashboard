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
          collectionId: AppwriteService.usersCollection,
          queries: [Query.orderDesc('\$createdAt')],
        );

        final users = response.documents.map((doc) {
          final joinedDate = DateTime.parse(doc.$createdAt);
          return {
            'id': doc.$id,
            'name': doc.data['name'] ?? 'Unknown',
            'email': doc.data['email'] ?? 'N/A',
            'tier': doc.data['tier'] ?? 'Standard',
            'points': doc.data['points'] ?? 0,
            'avatar': doc.data['avatarUrl'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(doc.data['name'] ?? 'U')}&background=random',
            'joined': '${joinedDate.day}/${joinedDate.month}/${joinedDate.year}',
          };
        }).toList();

        emit(UsersLoaded(users));
      } catch (e) {
        if (e is AppwriteException && (e.code == 401 || e.code == 404)) {
          final mockUsers = [
            {
              'id': '1', 'name': 'Karim Algiers', 'email': 'karim@gmail.com', 'tier': 'Elite', 'points': 2400,
              'avatar': 'https://ui-avatars.com/api/?name=Karim+Algiers&background=006633&color=fff',
              'joined': '12/05/2024',
            },
            {
              'id': '2', 'name': 'Lydia Sahra', 'email': 'lydia@outlook.fr', 'tier': 'Explorer', 'points': 850,
              'avatar': 'https://ui-avatars.com/api/?name=Lydia+Sahra&background=D2143A&color=fff',
              'joined': '15/05/2024',
            },
          ];
          emit(UsersLoaded(mockUsers));
        } else {
          emit(UsersError('Failed to load users: ${e.toString()}'));
        }
      }
    });

    on<UpdateUserTier>((event, emit) async {
      try {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.usersCollection,
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
