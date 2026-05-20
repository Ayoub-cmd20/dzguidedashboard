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
            'imageUrl': doc.data['imageUrl'],
            'expiry': doc.data['expiry'],
          };
        }).toList();

        emit(RewardsLoaded(rewards));
      } catch (e) {
        emit(RewardsError('Failed to load rewards: ${e.toString()}'));
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
