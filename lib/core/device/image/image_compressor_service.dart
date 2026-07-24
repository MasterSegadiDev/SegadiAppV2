import 'compressed_image.dart';

abstract class ImageCompressorService {
  Future<CompressedImage> compress(
    String imagePath,
  );
}
