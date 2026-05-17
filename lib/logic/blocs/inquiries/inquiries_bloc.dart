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
          String venueName = 'Loading...';
          try {
            final place = await _appwrite.databases.getDocument(
              databaseId: AppwriteService.databaseId,
              collectionId: AppwriteService.placesCollection,
              documentId: doc.data['placeId'],
            );
            venueName = place.data['name'];
          } catch (_) {
            venueName = 'Unknown Venue';
          }

          inquiries.add({
            'id': doc.$id,
            'venue': venueName,
            'userId': doc.data['userId'],
            'date': DateFormat('MMM dd, yyyy').format(DateTime.parse(doc.data['eventDate'])),
            'capacity': '${doc.data['guestCount']} Guests',
            'status': doc.data['status'][0].toUpperCase() + doc.data['status'].substring(1),
            'requirements': doc.data['requirements'],
            // Mapping for UI consistency if needed
            'inquirer': 'User ${doc.data['userId'].toString().substring(0, 5)}', 
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
