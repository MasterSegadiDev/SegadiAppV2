import 'package:segadi/app/di/injection_container.dart';

import '../../core/device/image/image_compressor_service.dart';
import '../../core/device/image/image_compressor_service_impl.dart';

Future<void> setupImageDependencies() async {
  getIt.registerLazySingleton<ImageCompressorService>(
    () => ImageCompressorServiceImpl(),
  );
}
