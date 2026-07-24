import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/providers/current_user_provider.dart';
import '../permission_service.dart';

final permissionServiceProvider = Provider<PermissionService>(
  (ref) {
    final currentUser = ref.watch(currentUserProvider);

    return PermissionService(
      currentUser: currentUser,
    );
  },
);
