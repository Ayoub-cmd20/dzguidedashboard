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
            'userId': doc.data['userId'],
            'placeId': doc.data['placeId'],
            'placeName': placeName,
            'eventDate': doc.data['eventDate'],
            'eventDateFormatted': DateFormat('MMM dd, yyyy').format(eventDate),
            'guestCount': doc.data['guestCount'],
            'requirements': doc.data['requirements'],
            'status': doc.data['status'] ?? 'pending',
          });
        }
        
        emit(InquiriesLoaded(inquiries));
      } catch (e) {
        emit(InquiriesError('Failed to load inquiries: ${e.toString()}'));
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
