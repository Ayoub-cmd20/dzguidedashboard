import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
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
        final List<dynamic> results = await Future.wait([
          _appwrite.databases.listDocuments(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.inquiriesCollection,
            queries: [Query.orderDesc('\$createdAt'), Query.limit(100)],
          ),
          _appwrite.databases.listDocuments(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.placesCollection,
            queries: [Query.limit(100)],
          ),
        ]);

        final inquiryResponse = results[0] as models.DocumentList;
        final placesResponse = results[1] as models.DocumentList;

        final Map<String, String> placeNames = {};
        for (var doc in placesResponse.documents) {
          placeNames[doc.$id] = doc.data['name'] ?? 'Unknown Place';
        }

        final List<Map<String, dynamic>> inquiries = [];
        for (var doc in inquiryResponse.documents) {
          final placeName = placeNames[doc.data['placeId']] ?? 'Unknown Place';
          
          DateTime? eventDate;
          try {
            if (doc.data['eventDate'] != null) {
              eventDate = DateTime.parse(doc.data['eventDate']);
            }
          } catch (_) {}
          
          eventDate ??= DateTime.now();

          inquiries.add({
            'id': doc.$id,
            'venue': placeName,
            'inquirer': doc.data['userId'] ?? 'Unknown User',
            'email': doc.data['email'] ?? 'user@dzguide.com',
            'date': DateFormat('MMM dd, yyyy').format(eventDate),
            'capacity': '${doc.data['guestCount'] ?? 0} Guests',
            'status': doc.data['status'] ?? 'pending',
            'requirements': doc.data['requirements'] ?? 'No special requirements specified.',
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
              'requirements': 'Needs extra security and private entrance.',
            },
            {
              'id': '2', 'venue': 'Casbah Heritage Tour', 'inquirer': 'Sarah Smith',
              'email': 'sarah@example.com', 'date': 'May 22, 2024',
              'capacity': '2 Guests', 'status': 'confirmed',
              'requirements': 'Historical guide required.',
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
        if (event.id == '1' || event.id == '2') {
           throw AppwriteException('Cannot update simulated mock data. Please log in with a real Appwrite account.', 401);
        }

        await _appwrite.databases.updateDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.inquiriesCollection,
          documentId: event.id,
          data: {'status': event.status.toLowerCase()},
        );
        add(LoadInquiries());
      } catch (e) {
        String errorMessage = 'Failed to update status: ${e.toString()}';
        if (e.toString().contains('401')) {
           errorMessage = 'Permission Denied: Backend updates require a real admin session. Simulation mode is read-only.';
        }
        emit(InquiriesError(errorMessage));
        await Future.delayed(const Duration(seconds: 2));
        add(LoadInquiries());
      }
    });

    on<DeleteInquiry>((event, emit) async {
      try {
        if (event.id == '1' || event.id == '2') {
           throw AppwriteException('Cannot delete simulated mock data.', 401);
        }

        await _appwrite.databases.deleteDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.inquiriesCollection,
          documentId: event.id,
        );
        add(LoadInquiries());
      } catch (e) {
        String errorMessage = 'Failed to delete inquiry: ${e.toString()}';
        if (e.toString().contains('401')) {
           errorMessage = 'Permission Denied: Cannot delete documents in simulation mode.';
        }
        emit(InquiriesError(errorMessage));
        await Future.delayed(const Duration(seconds: 2));
        add(LoadInquiries());
      }
    });
  }
}
