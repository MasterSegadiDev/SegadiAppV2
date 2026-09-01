abstract class EvidenceScanner {
  Future<List<String>?> scanDocuments({
    required int maxPages,
    bool allowGalleryImport,
  });
}
