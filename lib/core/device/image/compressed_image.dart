class CompressedImage {
  final String path;

  final int originalSize;

  final int compressedSize;

  const CompressedImage({
    required this.path,
    required this.originalSize,
    required this.compressedSize,
  });

  double get compressionRatio {
    if (originalSize == 0) {
      return 0;
    }

    return compressedSize / originalSize;
  }

  double get compressionPercent {
    return (1 - compressionRatio) * 100;
  }
}
