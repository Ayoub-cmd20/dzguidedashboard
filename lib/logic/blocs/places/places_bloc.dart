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
              categories = (doc.data['categories'] as String)
                  .split(',')
                  .map((c) => c.trim())
                  .toList();
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
        if (e is AppwriteException && (e.code == 401 || e.code == 404)) {
          final List<Map<String, dynamic>> mockPlaces = [
            {
              'id': '1',
              'name': 'Royal Saharan Suite',
              'description': 'A luxury desert experience in the heart of the Sahara.',
              'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80',
              'categories': ['Luxury', 'Stay'],
              'lat': 24.0, 'lng': 5.0,
              'rating': 4.9, 'reviewsCount': 128, 'favoritesCount': 560, 'isLive': true,
            },
            {
              'id': '2',
              'name': 'Casbah Heritage Tour',
              'description': 'Walking tour through the ancient streets of Algiers.',
              'imageUrl': 'https://images.unsplash.com/photo-1596464716127-f2a82984de30?auto=format&fit=crop&w=800&q=80',
              'categories': ['Culture', 'Adventure'],
              'lat': 36.7, 'lng': 3.0,
              'rating': 4.8, 'reviewsCount': 245, 'favoritesCount': 1020, 'isLive': true,
            },
            {
              'id': '3',
              'name': 'Timgad Roman Ruins',
              'description': 'Explore the well-preserved Roman city of Timgad.',
              'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=800&q=80',
              'categories': ['History', 'Nature'],
              'lat': 35.4, 'lng': 6.4,
              'rating': 4.7, 'reviewsCount': 89, 'favoritesCount': 340, 'isLive': true,
            },
          ];
          emit(PlacesLoaded(mockPlaces));
        } else {
          emit(PlacesError('Failed to load places: ${e.toString()}'));
        }
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

    on<UpdatePlace>((event, emit) async {
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

        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.placesCollection,
          documentId: event.id,
          data: placeData,
        );
        add(LoadPlaces());
      } catch (e) {
        emit(PlacesError('Failed to update place: ${e.toString()}'));
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
