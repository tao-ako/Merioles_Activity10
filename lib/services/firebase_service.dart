import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

import '../models/inventory_item.dart';
import '../utils/cloudinary_file_stub.dart'
    if (dart.library.io) '../utils/cloudinary_file_io.dart'
    as cloudinary_file;

class FirebaseService {
  FirebaseService({
    required this.userId,
    FirebaseFirestore? firestore,
    ImagePicker? imagePicker,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _imagePicker = imagePicker ?? ImagePicker();

  final String userId;
  final FirebaseFirestore _firestore;
  final ImagePicker _imagePicker;

  static const String cloudName = 'jhytwdsk';
  static const String uploadPreset = 'DariBadi';

  CloudinaryPublic get _cloudinary {
    if (cloudName == 'YOUR_CLOUDINARY_CLOUD_NAME' ||
        uploadPreset == 'YOUR_UNSIGNED_UPLOAD_PRESET') {
      throw StateError(
        'Configure cloudName and uploadPreset in FirebaseService before '
        'uploading images.',
      );
    }
    return CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }

  CollectionReference<Map<String, dynamic>> get _items =>
      _firestore.collection('users').doc(userId).collection('items');

  Stream<List<InventoryItem>> watchItems() {
    return _items
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(InventoryItem.fromDocument)
              .toList(growable: false),
        );
  }

  Future<XFile?> pickImageForAddItem() async {
    return _imagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<String> uploadImage(XFile image) async {
    final cloudinaryFile = await cloudinary_file.createCloudinaryFile(image);
    final response = await _cloudinary.uploadFile(cloudinaryFile);
    final imageUrl = response.secureUrl.trim();
    final uri = Uri.tryParse(imageUrl);
    if (imageUrl.isEmpty ||
        uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      throw StateError('Cloudinary returned an invalid image URL.');
    }
    return imageUrl;
  }

  Future<void> addItem({
    required String name,
    required num quantity,
    String? imageUrl,
  }) async {
    final data = <String, Object?>{
      'name': name,
      'quantity': quantity,
      'isFavorite': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (imageUrl != null) {
      final uri = Uri.tryParse(imageUrl);
      if (imageUrl.trim().isEmpty ||
          uri == null ||
          (uri.scheme != 'https' && uri.scheme != 'http') ||
          uri.host.isEmpty) {
        throw ArgumentError.value(imageUrl, 'imageUrl', 'Must be a valid URL.');
      }
      data['image_url'] = imageUrl;
    }
    await _items.add(data);
  }

  Future<void> updateItem({
    required String id,
    required String name,
    required num quantity,
  }) async {
    await _items.doc(id).update({'name': name, 'quantity': quantity});
  }

  Future<void> setFavorite({
    required String id,
    required bool isFavorite,
  }) async {
    await _items.doc(id).update({'isFavorite': isFavorite});
  }

  Future<void> deleteItem(String id) async {
    await _items.doc(id).delete();
  }
}
