import 'package:appwrite/appwrite.dart';

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
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);
    
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }

  // Collection IDs
  static const String placesCollection = 'places';
  static const String inquiriesCollection = 'inquiries';
  static const String eventsCollection = 'events';
  static const String reviewsCollection = 'reviews';
  static const String rewardsCollection = 'rewards';
  static const String usersCollection = 'users';

  // Bucket IDs
  static const String placesBucket = 'bucket_places';
  static const String eventsBucket = 'bucket_events';

  String getImageUrl(String bucketId, String fileId) {
    return '$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId';
  }
}
