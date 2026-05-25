import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/services/appwrite_service.dart';
import 'events_event.dart';
import 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final AppwriteService _appwrite = AppwriteService();

  EventsBloc() : super(EventsInitial()) {
    on<LoadEvents>((event, emit) async {
      emit(EventsLoading());
      try {
        final response = await _appwrite.databases.listDocuments(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.eventsCollection,
          queries: [Query.orderDesc('\$createdAt')],
        );

        final events = response.documents.map((doc) {
          return {
            'id': doc.$id,
            'title': doc.data['title'] ?? '',
            'description': doc.data['description'] ?? '',
            'placeId': doc.data['placeId'] ?? '',
            'date': doc.data['date'] ?? '',
            'category': doc.data['category'] ?? '',
            'imageUrl': doc.data['imageUrl'] ?? '',
          };
        }).toList();

        emit(EventsLoaded(events));
      } catch (e) {
        if (e is AppwriteException && (e.code == 401 || e.code == 404)) {
          final mockEvents = [
            {
              'id': '1',
              'title': 'Timgad International Music Festival',
              'description':
                  'A grand celebration of music and culture featuring international and local artists.',
              'placeId': 'timgad',
              'date': '2024-07-25T18:00:00Z',
              'category': 'Music',
              'imageUrl':
                  'https://images.unsplash.com/photo-1514525253361-bee8718a747c?auto=format&fit=crop&w=800&q=80',
            },
            {
              'id': '2',
              'title': 'Sahara Desert Marathon',
              'description':
                  'An extreme sports event in the heart of the Sahara desert with runners from around the world.',
              'placeId': 'tindouf',
              'date': '2024-02-28T06:00:00Z',
              'category': 'Sports',
              'imageUrl':
                  'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=800&q=80',
            },
            {
              'id': '3',
              'title': 'Algiers International Book Fair',
              'description':
                  'A celebration of literature and publishing featuring authors, publishers, and book lovers.',
              'placeId': 'safex',
              'date': '2024-10-30T09:00:00Z',
              'category': 'Culture',
              'imageUrl':
                  'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=800&q=80',
            },
          ];
          emit(EventsLoaded(mockEvents));
        } else {
          emit(EventsError('Failed to load events: ${e.toString()}'));
        }
      }
    });

    on<AddEvent>((event, emit) async {
      try {
        await _appwrite.databases.createDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.eventsCollection,
          documentId: ID.unique(),
          data: event.event,
        );
        add(LoadEvents());
      } catch (e) {
        emit(EventsError('Failed to add event: ${e.toString()}'));
      }
    });

    on<UpdateEvent>((event, emit) async {
      try {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.eventsCollection,
          documentId: event.id,
          data: event.event,
        );
        add(LoadEvents());
      } catch (e) {
        emit(EventsError('Failed to update event: ${e.toString()}'));
      }
    });

    on<DeleteEvent>((event, emit) async {
      try {
        await _appwrite.databases.deleteDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.eventsCollection,
          documentId: event.id,
        );
        add(LoadEvents());
      } catch (e) {
        emit(EventsError('Failed to delete event: ${e.toString()}'));
      }
    });
  }
}
