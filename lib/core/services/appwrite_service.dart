import 'package:appwrite/appwrite.dart';
import 'dart:io';
import 'dart:typed_data';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();

  factory AppwriteService() {
    return _instance;
  }

  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = '69b3f38b00343fcaac9e';
  static const String databaseId = 'dz_guide_db';

  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Storage storage;

  AppwriteService._internal() {
    client = Client().setEndpoint(endpoint).setProject(projectId);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }

  // Collection IDs
  static const String placesCollection = 'places';
  static const String inquiriesCollection = 'inquiries';
  static const String rewardsCollection = 'rewards';
  static const String usersCollection = 'users';
  static const String adminsCollection = 'admins';
  static const String eventsCollection = 'events';
  static const String analyticsCollection = 'analytics';

  // Bucket IDs
  static const String placesBucket = 'bucket_places';

  // Collection field names
  static const String fieldId = '\$id';
  static const String fieldCreatedAt = '\$createdAt';
  static const String fieldUpdatedAt = '\$UpdatedAt';

  String getImageUrl(String bucketId, String fileId) {
    return '$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId';
  }

  Future<String> uploadImage(File file, String fileName) async {
    try {
      final response = await storage.createFile(
        bucketId: placesBucket,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: fileName),
      );
      return response.$id;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      final response = await storage.createFile(
        bucketId: placesBucket,
        fileId: ID.unique(),
        file: InputFile.fromBytes(bytes: bytes, filename: fileName),
      );
      return response.$id;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Overview data fetching - optimized single method
  Future<Map<String, dynamic>> getOverviewData() async {
    try {
      // Fetch all data in parallel
      final List<dynamic> results = await Future.wait([
        // Get all stats
        databases.listDocuments(
          databaseId: databaseId,
          collectionId: placesCollection,
          queries: [Query.limit(1)],
        ),
        databases.listDocuments(
          databaseId: databaseId,
          collectionId: inquiriesCollection,
          queries: [Query.equal('status', 'pending'), Query.limit(1)],
        ),
        databases.listDocuments(
          databaseId: databaseId,
          collectionId: usersCollection,
          queries: [Query.limit(1)],
        ),
        databases.listDocuments(
          databaseId: databaseId,
          collectionId: rewardsCollection,
          queries: [Query.limit(1)],
        ),
        // Get recent inquiries with place details
        databases.listDocuments(
          databaseId: databaseId,
          collectionId: inquiriesCollection,
          queries: [Query.orderDesc('\$createdAt'), Query.limit(5)],
        ),
        // Get all places for name resolution (more efficient than N+1 queries)
        databases.listDocuments(
          databaseId: databaseId,
          collectionId: placesCollection,
          queries: [Query.limit(100)],
        ),
        // Get analytics data for the chart
        getAnalyticsData(),
      ]);

      final totalPlaces = results[0].total;
      final pendingInquiriesCount = results[1].total;
      final totalUsers = results[2].total;
      final totalRewards = results[3].total;
      final recentInquiriesDocs = results[4].documents;
      final allPlacesDocs = results[5].documents;
      final List<Map<String, dynamic>> analyticsData = results[6];

      // Create place lookup map for efficient name resolution
      final Map<String, String> placeNames = {};
      for (var place in allPlacesDocs) {
        placeNames[place.$id] = place.data['name'] ?? 'Unknown Place';
      }

      // Build inquiries with place names (no additional API calls)
      final List<Map<String, dynamic>> inquiries = [];
      for (var doc in recentInquiriesDocs) {
        final placeName = placeNames[doc.data['placeId']] ?? 'Unknown Place';
        final status = (doc.data['status'] ?? 'pending').toString();
        final statusFormatted = status[0].toUpperCase() + status.substring(1);

        inquiries.add({
          'id': doc.$id, // Added ID
          'venue': placeName,
          'inquirer': doc.data['userId'],
          'date': doc.data['eventDate'],
          'capacity': '${doc.data['guestCount']} Guests',
          'status': statusFormatted,
          'requirements': doc.data['requirements'] ?? 'No special requirements specified.', // Added requirements
          'placeId': doc.data['placeId'],
        });
      }

      return {
        'stats': [
          {
            'title': 'Active Destinations',
            'value': totalPlaces.toString(),
            'trend': 'Live',
            'icon': 'mapPin',
          },
          {
            'title': 'Pending Inquiries',
            'value': pendingInquiriesCount.toString(),
            'trend': 'Action Required',
            'icon': 'clock',
          },
          {
            'title': 'Global Travelers',
            'value': totalUsers.toString(),
            'trend': 'Active Users',
            'icon': 'users',
          },
          {
            'title': 'Available Rewards',
            'value': totalRewards.toString(),
            'trend': 'In Catalog',
            'icon': 'gift',
          },
        ],
        'recentInquiries': inquiries,
        'analyticsData': analyticsData,
      };
    } catch (e) {
      throw Exception('Failed to fetch overview data: $e');
    }
  }

  // Get analytics data for the traveler metrics chart
  Future<List<Map<String, dynamic>>> getAnalyticsData({int? year}) async {
    try {
      final currentYear = year ?? DateTime.now().year;

      // Try to fetch pre-aggregated analytics data
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: analyticsCollection,
        queries: [Query.equal('year', currentYear), Query.orderAsc('month')],
      );

      // If analytics table has real data, use it
      if (response.documents.isNotEmpty) {
        return response.documents
            .map(
              (doc) => {
                'month': doc.data['month'],
                'year': doc.data['year'],
                'luxuryBookings': doc.data['luxuryBookings'] ?? 0,
                'eliteActivity': doc.data['eliteActivity'] ?? 0,
                'totalUsers': doc.data['totalUsers'] ?? 0,
                'newInquiries': doc.data['newInquiries'] ?? 0,
              },
            )
            .toList();
      }

      // If analytics table is empty, try to compute from raw data
      return await _computeAnalyticsFromRawData(currentYear);
    } catch (e) {
      return _generateEmptyCollectionMessage();
    }
  }

  // Compute analytics by aggregating from inquiries and users tables
  Future<List<Map<String, dynamic>>> _computeAnalyticsFromRawData(
    int year,
  ) async {
    try {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final List<Map<String, dynamic>> analyticsData = [];

      // Get all inquiries for the year
      final allInquiries = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: inquiriesCollection,
        queries: [Query.limit(10000)],
      );

      // Get total unique users
      final usersData = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: usersCollection,
        queries: [Query.limit(1)],
      );
      final totalUsers = usersData.total;

      // Process each month
      for (int monthIndex = 0; monthIndex < 12; monthIndex++) {
        int monthNumber = monthIndex + 1;

        int luxuryBookings = 0;
        int newInquiries = 0;

        for (var inquiry in allInquiries.documents) {
          try {
            final eventDate = DateTime.parse(inquiry.data['eventDate']);
            if (eventDate.year == year && eventDate.month == monthNumber) {
              newInquiries++;
              luxuryBookings++;
            }
          } catch (e) {}
        }

        int eliteActivity = (luxuryBookings * 0.4).toInt();

        analyticsData.add({
          'month': months[monthIndex],
          'year': year,
          'luxuryBookings': luxuryBookings,
          'eliteActivity': eliteActivity,
          'totalUsers': totalUsers,
          'newInquiries': newInquiries,
        });
      }

      return analyticsData;
    } catch (e) {
      return _generateEmptyCollectionMessage();
    }
  }

  List<Map<String, dynamic>> _generateEmptyCollectionMessage() {
    return [
      {
        'month': 'No Data',
        'year': DateTime.now().year,
        'luxuryBookings': 0,
        'eliteActivity': 0,
        'totalUsers': 0,
        'newInquiries': 0,
        'message':
            'Analytics collection is empty. Please add data to see metrics.',
      },
    ];
  }

  // Update or create analytics data for a specific month
  Future<void> updateAnalyticsData({
    required String month,
    required int year,
    required int luxuryBookings,
    required int eliteActivity,
    required int totalUsers,
    required int newInquiries,
  }) async {
    try {
      final existing = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: analyticsCollection,
        queries: [Query.equal('month', month), Query.equal('year', year)],
      );

      final data = {
        'luxuryBookings': luxuryBookings,
        'eliteActivity': eliteActivity,
        'totalUsers': totalUsers,
        'newInquiries': newInquiries,
      };

      if (existing.documents.isNotEmpty) {
        await databases.updateDocument(
          databaseId: databaseId,
          collectionId: analyticsCollection,
          documentId: existing.documents.first.$id,
          data: data,
        );
      } else {
        await databases.createDocument(
          databaseId: databaseId,
          collectionId: analyticsCollection,
          documentId: ID.unique(),
          data: {'month': month, 'year': year, ...data},
        );
      }
    } catch (e) {
      throw Exception('Failed to update analytics data: $e');
    }
  }
}
