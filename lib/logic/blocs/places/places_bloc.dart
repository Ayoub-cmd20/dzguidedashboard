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
          // Parse categories - could be stored as JSON string or list
          List<String> categories = [];
          try {
            if (doc.data['categories'] is List) {
              categories = List<String>.from(doc.data['categories']);
            } else if (doc.data['categories'] is String) {
              categories = (doc.data['categories'] as String).split(',').map((c) => c.trim()).toList();
            }
          } catch (_) {
            categories = ['General'];
          }

          return {
            'id': doc.$id,
            'name': doc.data['name'],
            'description': doc.data['description'],
            'imageUrl': doc.data['imageUrl'],
            'categories': categories,
            'lat': doc.data['lat'],
            'lng': doc.data['lng'],
            'rating': doc.data['rating'] ?? 0.0,
            'reviewsCount': doc.data['reviewsCount'] ?? 0,
            'favoritesCount': doc.data['favoritesCount'] ?? 0,
            'isLive': doc.data['isLive'] ?? false,
          };
        }).toList();

        emit(PlacesLoaded(places));
      } catch (e) {
        emit(PlacesError('Failed to load places: ${e.toString()}'));
      }
    });

    on<AddPlace>((event, emit) async {
      try {
        final placeData = {
          'name': event.place['name'] ?? '',
          'description': event.place['description'] ?? '',
          'imageUrl': event.place['imageUrl'] ?? '',
          'categories': event.place['categories'] is String 
              ? event.place['categories']
              : (event.place['categories'] as List?)?.join(',') ?? 'General',
          'lat': event.place['lat'] ?? 0.0,
          'lng': event.place['lng'] ?? 0.0,
          'rating': event.place['rating'] ?? 0.0,
          'reviewsCount': event.place['reviewsCount'] ?? 0,
          'favoritesCount': event.place['favoritesCount'] ?? 0,
          'isLive': event.place['isLive'] ?? false,
        };

        await _appwrite.databases.createDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.placesCollection,
          documentId: ID.unique(),
          data: placeData,
        );
        add(LoadPlaces());
      } catch (e) {
        emit(PlacesError('Failed to add place: ${e.toString()}'));
      }
    });

    on<UpdatePlaceStatus>((event, emit) async {
      try {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.placesCollection,
          documentId: event.id,
          data: {'isLive': event.isLive},
        );
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
