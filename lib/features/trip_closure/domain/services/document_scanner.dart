import 'dart:typed_data';

abstract class DocumentScanner {
  Future<Uint8List?> scan();
}
