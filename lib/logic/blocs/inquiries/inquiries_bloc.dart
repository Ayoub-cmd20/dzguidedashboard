import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/services/appwrite_service.dart';
import 'inquiries_event.dart';
import 'inquiries_state.dart';
import 'package:intl/intl.dart';

class InquiriesBloc extends Bloc<InquiriesEvent, InquiriesState> {
  final AppwriteService _appwrite = AppwriteService();

  InquiriesBloc() : super(InquiriesInitial()) {
    on<LoadInquiries>((event, emit) async {
      emit(InquiriesLoading());
      try {
        final response = await _appwrite.databases.listDocuments(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.inquiriesCollection,
          queries: [Query.orderDesc('\$createdAt')],
        );

        final List<Map<String, dynamic>> inquiries = [];
        for (var doc in response.documents) {
          String placeName = 'Loading...';
          try {
            final place = await _appwrite.databases.getDocument(
              databaseId: AppwriteService.databaseId,
              collectionId: AppwriteService.placesCollection,
              documentId: doc.data['placeId'],
            );
            placeName = place.data['name'];
          } catch (_) {
            placeName = 'Unknown Place';
          }

          final eventDate = DateTime.parse(doc.data['eventDate']);

          inquiries.add({
            'id': doc.$id,
            'venue': placeName,
            'inquirer': doc.data['userId'],
            'email': 'user@dzguide.com', // Default or fetch if available
            'date': DateFormat('MMM dd, yyyy').format(eventDate),
            'capacity': '${doc.data['guestCount']} Guests',
            'status': doc.data['status'] ?? 'pending',
          });
        }
        
        emit(InquiriesLoaded(inquiries));
      } catch (e) {
        if (e is AppwriteException && (e.code == 401 || e.code == 404)) {
          final List<Map<String, dynamic>> mockInquiries = [
            {
              'id': '1', 'venue': 'Royal Saharan Suite', 'inquirer': 'John Doe',
              'email': 'john@example.com', 'date': 'May 20, 2024',
              'capacity': '4 Guests', 'status': 'pending',
            },
            {
              'id': '2', 'venue': 'Casbah Heritage Tour', 'inquirer': 'Sarah Smith',
              'email': 'sarah@example.com', 'date': 'May 22, 2024',
              'capacity': '2 Guests', 'status': 'confirmed',
            },
          ];
          emit(InquiriesLoaded(mockInquiries));
        } else {
          emit(InquiriesError('Failed to load inquiries: ${e.toString()}'));
        }
      }
    });

    on<UpdateInquiryStatus>((event, emit) async {
      try {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.inquiriesCollection,
          documentId: event.id,
          data: {'status': event.status.toLowerCase()},
        );
        add(LoadInquiries()); // Reload to get fresh data
      } catch (e) {
        emit(InquiriesError('Failed to update status: ${e.toString()}'));
      }
    });
  }
}
