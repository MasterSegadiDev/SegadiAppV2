import '../../core/device/image/image_compressor_service.dart';
import '../../core/device/scanner/scanner_service.dart';
import '../../core/device/scanner/scanner_service_impl.dart';

import 'injection_container.dart';

Future<void> setupScannerDependencies() async {
  getIt.registerLazySingleton<ScannerService>(
    () => ScannerServiceImpl(
      imageCompressorService: getIt<ImageCompressorService>(),
    ),
  );
}
