import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

Future<CloudinaryFile> createCloudinaryFile(XFile image) async {
  return CloudinaryFile.fromBytesData(
    await image.readAsBytes(),
    identifier: image.name,
    resourceType: CloudinaryResourceType.Image,
  );
}
