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
        // Fetch all stats in parallel
        final results = await Future.wait([
          // Total Places
          _appwrite.databases.listDocuments(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.placesCollection,
            queries: [Query.limit(1)],
          ),
          // Pending Inquiries
          _appwrite.databases.listDocuments(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.inquiriesCollection,
            queries: [Query.equal('status', 'pending'), Query.limit(1)],
          ),
          // Total Users
          _appwrite.databases.listDocuments(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.usersCollection,
            queries: [Query.limit(1)],
          ),
          // Recent Inquiries (Detailed list)
          _appwrite.databases.listDocuments(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.inquiriesCollection,
            queries: [Query.orderDesc('\$createdAt'), Query.limit(5)],
          ),
          // Total Rewards
          _appwrite.databases.listDocuments(
            databaseId: AppwriteService.databaseId,
            collectionId: AppwriteService.rewardsCollection,
            queries: [Query.limit(1)],
          ),
        ]);

        final totalPlaces = (results[0]).total;
        final pendingInquiriesCount = (results[1]).total;
        final totalUsers = (results[2]).total;
        final recentInquiriesDocs = (results[3]).documents;
        final totalRewards = (results[4]).total;

        // Build Stats List from real data
        final stats = [
          {
            'title': 'Active Destinations',
            'value': totalPlaces.toString(),
            'trend': 'Live',
            'icon': 'mapPin'
          },
          {
            'title': 'Pending Inquiries',
            'value': pendingInquiriesCount.toString(),
            'trend': 'Action Required',
            'icon': 'clock'
          },
          {
            'title': 'Global Travelers',
            'value': totalUsers.toString(),
            'trend': 'Active Users',
            'icon': 'users'
          },
          {
            'title': 'Available Rewards',
            'value': totalRewards.toString(),
            'trend': 'In Catalog',
            'icon': 'gift'
          },
        ];

        // Resolve Venue Names for Recent Inquiries
        final List<Map<String, dynamic>> inquiries = [];
        for (var doc in recentInquiriesDocs) {
          String placeName = 'Unknown Place';
          try {
            final place = await _appwrite.databases.getDocument(
              databaseId: AppwriteService.databaseId,
              collectionId: AppwriteService.placesCollection,
              documentId: doc.data['placeId'],
            );
            placeName = place.data['name'];
          } catch (_) {
            // placeName remains 'Unknown Place'
          }

          final status = (doc.data['status'] ?? 'pending').toString();
          final statusFormatted = status[0].toUpperCase() + status.substring(1);

          inquiries.add({
            'placeName': placeName,
            'userId': doc.data['userId'],
            'eventDate': DateFormat('MMM dd, yyyy').format(DateTime.parse(doc.data['eventDate'])),
            'guestCount': doc.data['guestCount'],
            'status': statusFormatted,
          });
        }

        emit(OverviewLoaded(stats: stats, recentInquiries: inquiries));
      } catch (e) {
        emit(OverviewError('Failed to load dashboard: ${e.toString()}'));
      }
    });
  }
}
