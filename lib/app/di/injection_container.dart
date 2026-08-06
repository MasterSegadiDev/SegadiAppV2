import 'package:get_it/get_it.dart';

import 'auth_injection.dart';
import 'user_profile_injection.dart';
import 'core_injection.dart';
import 'scanner_injection.dart';
import 'image_injection.dart';
import 'location_injection.dart';
import 'firebase_injection.dart';
import 'notification_injection.dart';
import 'services_injection.dart';
import 'checklist_injection.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  await setupCoreDependencies();
  await setupAuthDependencies();
  await setupUserProfileDependencies();
  await setupScannerDependencies();
  await setupImageDependencies();
  await setupLocationDependencies();
  await setupFirebaseDependencies();
  await setupNotificationDependencies();
  await setupServicesDependencies();
  await setupChecklistDependencies();
}
