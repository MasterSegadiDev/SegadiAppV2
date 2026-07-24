import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/security/session_manager.dart';
import '../../domain/use_cases/get_user_profile_usecase.dart';
import '../state/user_profile_state.dart';

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;

  UserProfileNotifier(
    this.getUserProfileUseCase,
  ) : super(
          UserProfileState.initial(),
        );

  Future<void> loadProfile() async {
    if (state.status == UserProfileStatus.loading) {
      return;
    }

    state = UserProfileState.loading();

    try {
      final user = await SessionManager.getCurrentUser();

      if (user == null) {
        state = UserProfileState.error(
          errorMessage: 'Usuario no encontrado.',
        );
        return;
      }

      final profile = await getUserProfileUseCase(
        userId: user.id,
      );

      state = UserProfileState.loaded(
        profile,
      );
    } catch (e) {
      state = UserProfileState.error(
        errorMessage: e.toString(),
      );
    }
  }

  void clear() {
    state = UserProfileState.initial();
  }
}
