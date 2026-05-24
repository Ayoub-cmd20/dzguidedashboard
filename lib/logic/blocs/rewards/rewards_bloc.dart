import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/services/appwrite_service.dart';
import 'rewards_event.dart';
import 'rewards_state.dart';

class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  final AppwriteService _appwrite = AppwriteService();

  RewardsBloc() : super(RewardsInitial()) {
    on<LoadRewards>((event, emit) async {
      emit(RewardsLoading());
      try {
        final response = await _appwrite.databases.listDocuments(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.rewardsCollection,
          queries: [Query.orderDesc('\$createdAt')],
        );

        final rewards = response.documents.map((doc) {
          return {
            'id': doc.$id,
            'title': doc.data['title'],
            'description': doc.data['description'],
            'cost': doc.data['cost'],
            'category': doc.data['category'],
            'image': doc.data['imageUrl'],
            'expiry': doc.data['expiry'],
          };
        }).toList();

        emit(RewardsLoaded(rewards));
      } catch (e) {
        if (e is AppwriteException && (e.code == 401 || e.code == 404)) {
          final mockRewards = [
            {
              'id': '1', 'title': 'Saharan Luxury Dinner', 'description': 'Private 5-course dinner under the stars.',
              'cost': 5000, 'category': 'Dining', 'image': 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=800&q=80',
              'expiry': '2024-12-31',
            },
            {
              'id': '2', 'title': 'Private Algiers Guide', 'description': '8-hour expert local history guide.',
              'cost': 2000, 'category': 'Service', 'image': 'https://images.unsplash.com/photo-1596464716127-f2a82984de30?auto=format&fit=crop&w=800&q=80',
              'expiry': '2024-12-31',
            },
          ];
          emit(RewardsLoaded(mockRewards));
        } else {
          emit(RewardsError('Failed to load rewards: ${e.toString()}'));
        }
      }
    });

    on<AddReward>((event, emit) async {
      try {
        await _appwrite.databases.createDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.rewardsCollection,
          documentId: ID.unique(),
          data: event.reward,
        );
        add(LoadRewards());
      } catch (e) {
        emit(RewardsError('Failed to add reward: ${e.toString()}'));
      }
    });

    on<UpdateReward>((event, emit) async {
      try {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.rewardsCollection,
          documentId: event.id,
          data: event.reward,
        );
        add(LoadRewards());
      } catch (e) {
        emit(RewardsError('Failed to update reward: ${e.toString()}'));
      }
    });

    on<UpdateRewardCost>((event, emit) async {
      try {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.rewardsCollection,
          documentId: event.id,
          data: {'cost': event.newCost},
        );
        add(LoadRewards());
      } catch (e) {
        emit(RewardsError('Failed to update cost: ${e.toString()}'));
      }
    });

    on<DeleteReward>((event, emit) async {
      try {
        await _appwrite.databases.deleteDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.rewardsCollection,
          documentId: event.id,
        );
        add(LoadRewards());
      } catch (e) {
        emit(RewardsError('Failed to delete reward: ${e.toString()}'));
      }
    });
  }
}
