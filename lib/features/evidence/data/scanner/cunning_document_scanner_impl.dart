import 'package:cunning_document_scanner/cunning_document_scanner.dart';

import '../../../../core/scanner/evidence_scanner.dart';

class CunningDocumentScannerImpl implements EvidenceScanner {
  @override
  Future<List<String>?> scanDocuments({
    required int maxPages,
    bool allowGalleryImport = false,
  }) async {
    return await CunningDocumentScanner.getPictures(
      noOfPages: maxPages,
    );
  }
}
