import 'dart:io';
import 'dart:typed_data';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:segadi/features/trip_closure/domain/services/document_scanner.dart';

class MobileDocumentScanner implements DocumentScanner {
  @override
  Future<Uint8List?> scan() async {
    final images = await CunningDocumentScanner.getPictures();

    if (images == null || images.isEmpty) return null;

    final file = File(images.first);
    return await file.readAsBytes();
  }
}
