import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/services/appwrite_service.dart';
import 'places_event.dart';
import 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final AppwriteService _appwrite = AppwriteService();

  PlacesBloc() : super(PlacesInitial()) {
    on<LoadPlaces>((event, emit) async {
      emit(PlacesLoading());
      try {
        final response = await _appwrite.databases.listDocuments(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.placesCollection,
          queries: [Query.orderDesc('\$createdAt')],
        );

        final List<Map<String, dynamic>> places = response.documents.map((doc) {
          return {
            'id': doc.$id,
            'title': doc.data['name'],
            'category': (doc.data['categories'] as List).isNotEmpty 
                ? doc.data['categories'][0] 
                : 'General',
            'rating': doc.data['rating'],
            'status': doc.data['reviewsCount'] > 0 ? 'Live' : 'New', // Example logic
            'location': doc.data['description'].toString().split('.').first, // Simple excerpt
            'image': doc.data['imageUrl'],
            'description': doc.data['description'],
            'lat': doc.data['lat'],
            'lng': doc.data['lng'],
          };
        }).toList();

        emit(PlacesLoaded(places));
      } catch (e) {
        emit(PlacesError('Failed to load places: ${e.toString()}'));
      }
    });

    on<AddPlace>((event, emit) async {
      try {
        await _appwrite.databases.createDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.placesCollection,
          documentId: ID.unique(),
          data: event.place,
        );
        add(LoadPlaces());
      } catch (e) {
        emit(PlacesError('Failed to add place: ${e.toString()}'));
      }
    });

    on<UpdatePlaceStatus>((event, emit) async {
      // In Appwrite, we might have a 'status' field or use 'enabled'
      // For now, let's assume we update a field if it exists, or just log
      try {
        // Example: update rating as a proxy for 'status' toggle if no status field exists
        // Actually, the schema has no status field. We can add it or skip.
        // Let's assume we reload for now.
        add(LoadPlaces());
      } catch (e) {
        emit(PlacesError('Failed to update status: ${e.toString()}'));
      }
    });

    on<DeletePlace>((event, emit) async {
      try {
        await _appwrite.databases.deleteDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.placesCollection,
          documentId: event.id,
        );
        add(LoadPlaces());
      } catch (e) {
        emit(PlacesError('Failed to delete place: ${e.toString()}'));
      }
    });
  }
}
