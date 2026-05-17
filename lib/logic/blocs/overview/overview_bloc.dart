import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/services/appwrite_service.dart';
import 'overview_event.dart';
import 'overview_state.dart';
import 'package:intl/intl.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  final AppwriteService _appwrite = AppwriteService();

  OverviewBloc() : super(OverviewInitial()) {
    on<LoadOverviewData>((event, emit) async {
      emit(OverviewLoading());
      try {
        // 1. Fetch Stats in parallel
        final results = await Future.wait([
          // Total Travelers (Users)
          // Note: listUsers requires Admin API key or special permissions. 
          // For now, we fetch from a 'traveler_metadata' or simulate if not accessible.
          _appwrite.databases.listDocuments(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.placesCollection,
            queries: [Query.limit(1)],
          ),
          // Pending Inquiries
          _appwrite.databases.listDocuments(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.inquiriesCollection,
            queries: [Query.equal('status', 'pending')],
          ),
          // Recent Inquiries (Detailed list)
          _appwrite.databases.listDocuments(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.inquiriesCollection,
            queries: [Query.orderDesc('\$createdAt'), Query.limit(5)],
          ),
        ]);

        final totalPlaces = (results[0]).total;
        final pendingInquiriesCount = (results[1]).total;
        final recentInquiriesDocs = (results[2]).documents;

        // 2. Build Stats List
        final stats = [
          {'title': 'Active Destinations', 'value': totalPlaces.toString(), 'trend': 'Live', 'icon': 'mapPin'},
          {'title': 'Pending Inquiries', 'value': pendingInquiriesCount.toString(), 'trend': 'Action Required', 'icon': 'clock'},
          {'title': 'Points Redeemed', 'value': '850K', 'trend': '+18%', 'icon': 'gift'}, // Placeholder for now
          {'title': 'Global Travelers', 'value': '12.8K', 'trend': '+12%', 'icon': 'users'}, // Placeholder
        ];

        // 3. Resolve Venue Names for Recent Inquiries
        final List<Map<String, dynamic>> inquiries = [];
        for (var doc in recentInquiriesDocs) {
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
            'venue': venueName,
            'inquirer': 'User ${doc.data['userId'].toString().substring(0, 5)}',
            'date': DateFormat('MMM dd, yyyy').format(DateTime.parse(doc.data['eventDate'])),
            'capacity': '${doc.data['guestCount']} Guests',
            'status': doc.data['status'][0].toUpperCase() + doc.data['status'].substring(1),
          });
        }

        emit(OverviewLoaded(stats: stats, recentInquiries: inquiries));
      } catch (e) {
        emit(OverviewError('Failed to load dashboard: ${e.toString()}'));
      }
    });
  }
}
