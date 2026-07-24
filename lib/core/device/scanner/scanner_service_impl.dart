import 'package:cunning_document_scanner/cunning_document_scanner.dart';

import '../image/image_compressor_service.dart';
import 'scanner_service.dart';

class ScannerServiceImpl implements ScannerService {
  final ImageCompressorService imageCompressorService;

  ScannerServiceImpl({
    required this.imageCompressorService,
  });

  @override
  Future<List<String>> scanDocument() async {
    try {
      final List<String>? images = await CunningDocumentScanner.getPictures();

      if (images == null || images.isEmpty) {
        return [];
      }

      final compressedImages = <String>[];

      for (final image in images) {
        final compressed = await imageCompressorService.compress(image);

        compressedImages.add(compressed.path);
      }

      return compressedImages;
    } catch (_) {
      return [];
    }
  }
}
