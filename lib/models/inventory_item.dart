import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.isFavorite,
    this.imageUrl,
  });

  final String id;
  final String name;
  final num quantity;
  final bool isFavorite;
  final String? imageUrl;

  factory InventoryItem.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final name = data['name'];
    final quantity = data['quantity'];
    final isFavorite = data['isFavorite'];
    final rawImageUrl = data['image_url'];

    if (name is! String ||
        quantity is! num ||
        isFavorite is! bool ||
        (rawImageUrl != null && rawImageUrl is! String)) {
      throw FormatException(
        'Item ${document.id} has missing or invalid fields.',
      );
    }

    final imageUrl = (rawImageUrl as String?)?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final uri = Uri.tryParse(imageUrl);
      if (uri == null ||
          (uri.scheme != 'https' && uri.scheme != 'http') ||
          uri.host.isEmpty) {
        throw FormatException('Item ${document.id} has an invalid image URL.');
      }
    }

    return InventoryItem(
      id: document.id,
      name: name,
      quantity: quantity,
      isFavorite: isFavorite,
      imageUrl: imageUrl?.isEmpty == true ? null : imageUrl,
    );
  }
}
