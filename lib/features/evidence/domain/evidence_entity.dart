import 'dart:typed_data';

class EvidenceEntity {
  final String filename; // uuid local
  final Uint8List bytes;

  EvidenceEntity({
    required this.filename,
    required this.bytes,
  });
}
