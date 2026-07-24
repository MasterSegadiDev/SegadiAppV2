import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

import '../../constants/image_constants.dart';
import 'compressed_image.dart';
import 'image_compressor_service.dart';

class ImageCompressorServiceImpl implements ImageCompressorService {
  @override
  Future<CompressedImage> compress(
    String imagePath,
  ) async {
    final originalFile = File(imagePath);

    final originalSize = await originalFile.length();

    final extension = path.extension(imagePath);

    final targetPath = imagePath.replaceFirst(
      extension,
      '_compressed$extension',
    );

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      targetPath,
      quality: ImageConstants.quality,
      minWidth: ImageConstants.minWidth,
      minHeight: ImageConstants.minHeight,
      keepExif: true,
    );

    if (compressedFile == null) {
      throw Exception(
        'No fue posible comprimir la imagen.',
      );
    }

    final compressedSize = await File(compressedFile.path).length();

    return CompressedImage(
      path: compressedFile.path,
      originalSize: originalSize,
      compressedSize: compressedSize,
    );
  }
}
