import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

Future<CloudinaryFile> createCloudinaryFile(XFile image) async {
  final file = File(image.path);
  if (!await file.exists()) {
    throw StateError('The selected image is no longer available.');
  }
  return CloudinaryFile.fromFile(
    file.path,
    resourceType: CloudinaryResourceType.Image,
  );
}
