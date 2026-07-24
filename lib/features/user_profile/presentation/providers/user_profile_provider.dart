import 'package:flutter_riverpod/legacy.dart';

import '../../../../app/di/injection_container.dart';
import '../../domain/use_cases/get_user_profile_usecase.dart';
import '../state/user_profile_state.dart';
import '../view_models/user_profile_notifier.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>(
  (ref) {
    return UserProfileNotifier(
      getIt<GetUserProfileUseCase>(),
    );
  },
);
