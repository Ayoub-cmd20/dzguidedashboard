import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/services/appwrite_service.dart';
import 'admins_event.dart';
import 'admins_state.dart';

class AdminsBloc extends Bloc<AdminsEvent, AdminsState> {
  final AppwriteService _appwrite = AppwriteService();

  AdminsBloc() : super(AdminsInitial()) {
    on<LoadAdmins>((event, emit) async {
      emit(AdminsLoading());
      try {
        final response = await _appwrite.databases.listDocuments(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.adminsCollection,
          queries: [Query.orderDesc('\$createdAt')],
        );

        final admins = response.documents.map((doc) {
          return {
            'id': doc.$id,
            'userId': doc.data['userId'],
            'email': doc.data['email'],
            'role': doc.data['role'],
            'createdAt': doc.data['createdAt'],
          };
        }).toList();

        emit(AdminsLoaded(admins));
      } catch (e) {
        emit(AdminsError('Failed to load admins: ${e.toString()}'));
      }
    });

    on<AddAdmin>((event, emit) async {
      try {
        final adminData = {
          'userId': event.admin['userId'] ?? '',
          'email': event.admin['email'] ?? '',
          'role': event.admin['role'] ?? 'moderator',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await _appwrite.databases.createDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.adminsCollection,
          documentId: ID.unique(),
          data: adminData,
        );
        add(LoadAdmins());
      } catch (e) {
        emit(AdminsError('Failed to add admin: ${e.toString()}'));
      }
    });

    on<UpdateAdminRole>((event, emit) async {
      try {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.adminsCollection,
          documentId: event.userId,
          data: {'role': event.newRole},
        );
        add(LoadAdmins());
      } catch (e) {
        emit(AdminsError('Failed to update admin role: ${e.toString()}'));
      }
    });

    on<RemoveAdmin>((event, emit) async {
      try {
        await _appwrite.databases.deleteDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.adminsCollection,
          documentId: event.userId,
        );
        add(LoadAdmins());
      } catch (e) {
        emit(AdminsError('Failed to remove admin: ${e.toString()}'));
      }
    });
  }
}
