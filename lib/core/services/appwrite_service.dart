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
}
